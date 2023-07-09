defmodule TodoApp.Router do
  alias TodoApp.JsonUtils, as: JSON
  # Bring Plug.Router module into scope
  use Plug.Router
  # Attach the Logger to log incoming requests
  plug(Plug.Logger)

  # Tell Plug to match the incoming request with the defined endpoints
  plug(:match)
  # Once there is a match, parse the response body if the content-type
  # is application/json. The order is important here, as we only want to
  # parse the body if there is a matching route.(Using the Jayson parser)
  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )
  # Dispatch the connection to the matched handler
  plug(:dispatch)

  # Handler for GET request with "/" path
  get "/" do
    send_resp(conn, 200, "OK")
  end

  get "/health" do
    case Mongo.command(:mongo, ping: 1) do
      {:ok, _res} -> send_resp(conn, 200, "hi there")
      {:error, _res} -> send_resp(conn, 500, "shit happen")
    end
  end

  get "/users" do
    users = Mongo.find(:mongo, "users_customer", %{})
    |> Enum.map(&JSON.normaliseMongoId/1)
    |> Enum.to_list()
    |> Jason.encode!()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, users)
  end

  post "/users" do
    case conn.body_params do
      %{
        "firstname" => firstname,
        "lastname" => lastname,
        "email" => email,
        "password" => password
      } ->
        case Mongo.insert_one(:mongo, "users_customer", %{
          "firstname" => firstname,
          "lastname" => lastname,
          "email" => email,
          "password" => password
        }) do
          {:ok, user} ->
            record = Mongo.find_one(:mongo, "users_customer", %{_id: user.inserted_id})

            user_record = JSON.normaliseMongoId(record)
            |> Jason.encode!()

            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, user_record)

          {:error, _} ->
              send_resp(conn, 500, "Something went wrong")
        end
        _->
          send_resp(conn, 400, '')
    end
  end

  get "/users/:id" do
    doc = Mongo.find_one(:mongo, "users_customer", %{_id: BSON.ObjectId.decode!(id)})

    case doc do
      nil ->
        send_resp(conn, 404, "Not Found")

      %{} ->
        user =
          JSON.normaliseMongoId(doc)
          |> Jason.encode!()

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, user)

      {:error, _} ->
        send_resp(conn, 500, "Something went wrong")
    end
  end

  put "/users/:id" do
    case Mongo.find_one_and_update(
      :mongo,
      "users_customer",
      %{_id: BSON.ObjectId.decode!(id)},
      %{
        "$set":
          conn.body_params
          |> Map.take(["firstname", "lastname", "email", "password"])
          |> Enum.into(%{}, fn {key, value} -> {"#{key}", value} end)
      },
      return_document: :after
    ) do
      {:ok, doc} ->
        case doc do
          nil ->
            send_resp(conn, 404, "Not Found")

          _ ->
            post =
              JSON.normaliseMongoId(doc)
              |> Jason.encode!()

            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, post)
        end

      {:error, _} ->
        send_resp(conn, 500, "Something went wrong")
    end
  end

  delete "/users/:id" do
    Mongo.delete_one!(:mongo, "users_customer", %{_id: BSON.ObjectId.decode!(id)})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{id: id}))
  end

  # Fallback handler when there was no match
  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
