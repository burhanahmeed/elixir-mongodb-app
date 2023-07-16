defmodule TodoApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
alias Mix.Tasks.Compile.App

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: TodoApp.Worker.start_link(arg)
      # {TodoApp.Worker, arg}
      {
        Plug.Cowboy,
        scheme: :http,
        plug: TodoApp.Router,
        options: [port: Application.get_env(:todo_app, :port)]
      },
      {
        Mongo,
        name: :mongo,
        database: Application.get_env(:todo_app, :database),
        pool_size: Application.get_env(:todo_app, :pool_size),
        seed: [Application.get_env(:todo_app, :database_url)]
      },
      {
        MyXQL,
        name: :myxql,
        host: Application.get_env(:todo_app, :mysql_host),
        username: Application.get_env(:todo_app, :mysql_username),
        password: Application.get_env(:todo_app, :mysql_password),
        database: Application.get_env(:todo_app, :mysql_database),
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TodoApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
