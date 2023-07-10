defmodule TodoApp.Router do
  alias TodoApp.JsonUtils, as: JSON
  # Bring Plug.Router module into scope
  use Plug.Router
  import Plug.BasicAuth
  # Attach the Logger to log incoming requests
  plug(Plug.Logger)

  # Tell Plug to match the incoming request with the defined endpoints
  plug(:match)
  plug(:basic_auth, Application.get_env(:todo_app, :basic_auth))
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

  get "/issues" do
    case MyXQL.query(:myxql, "SELECT * FROM good_issues") do
      {:ok, %{rows: result, columns: col}} ->
        formatted_result = Enum.map(result, fn row ->
          Enum.zip(col, row) |> Map.new()
        end)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(formatted_result))

      {:error, reason} ->
        send_resp(conn, 500, "Something went wrong")
    end
  end

  get "/issues/:id" do
    case MyXQL.query(:myxql, "SELECT * FROM good_issues WHERE id = #{id} LIMIT 1") do
      {:ok, %{rows: [result], columns: col}} ->
        formatted_result = Enum.zip(col, result) |> Map.new()

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(formatted_result))

      {:ok, %{rows: []}} ->
        send_resp(conn, 404, "Issue not found")

      {:error, reason} ->
        send_resp(conn, 500, "Something went wrong")
    end
  end

  post "/issues" do
    case conn.body_params do
      %{
        "item_id" => item_id,
        "gr_id" => gr_id,
        "nama_gi" => nama_gi,
        "nama_user" => nama_user
      } ->
        query = "INSERT INTO good_issues (item_id, gr_id, nama_gi, nama_user) VALUES (#{item_id}, #{gr_id}, '#{nama_gi}', '#{nama_user}')"
        case MyXQL.query(:myxql, query) do
          {:ok, _} ->
            send_resp(conn, 201, "Issue created")

          {:error, _reason} ->
            send_resp(conn, 500, "Something went wrong")
        end
        {:error, _} ->
          send_resp(conn, 400, "Invalid request body")
    end
  end

  # Fallback handler when there was no match
  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
