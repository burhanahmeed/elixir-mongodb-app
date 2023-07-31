import Config

config :todo_app, port: 8081
config :todo_app, database_url: "mongodb://localhost:27017/sultanads"
config :todo_app, database: "sultanads"
config :todo_app, pool_size: 3
config :todo_app, :basic_auth, username: "abc", password: "abc"
config :todo_app, mysql_host: "localhost"
config :todo_app, mysql_username: "root"
config :todo_app, mysql_password: ""
config :todo_app, mysql_database: "dev_mdom"

# "mongodb+srv://admin:d892j!k2iewA@cluster0.qykuv69.mongodb.net/sultanads?retryWrites=true&w=majority&ssl=false"
