import Config

config :todo_app, port: 8081
config :todo_app, database_url: "localhost:27017"
config :todo_app, database: "sultanads"
config :todo_app, pool_size: 3
config :todo_app, :basic_auth, username: "abc", password: "abc"
