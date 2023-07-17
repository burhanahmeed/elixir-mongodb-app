import Config

config :todo_app, port: 8081
config :todo_app, database_url: "mongoservice:27017"
config :todo_app, database: "sultanads"
config :todo_app, pool_size: 3
config :todo_app, :basic_auth, username: "abc", password: "abc"
config :todo_app, mysql_host: "mysqlservice"
config :todo_app, mysql_username: "admin"
config :todo_app, mysql_password: "d892j!k2iewA"
config :todo_app, mysql_database: "demo_db"
