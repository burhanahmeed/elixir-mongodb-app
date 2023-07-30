import Config

config :todo_app, port: 8081
config :todo_app, database_url: "ac-ayvwbub-shard-00-02.qykuv69.mongodb.net:27017"
config :todo_app, database: "sultanads"
config :todo_app, pool_size: 3
config :todo_app, :basic_auth, username: "abc", password: "abc"
config :todo_app, mysql_host: "host.docker.internal"
# config :todo_app, mysql_username: "root"
config :todo_app, mysql_username: "admin"
config :todo_app, mysql_password: "d892j!k2iewA"
config :todo_app, mysql_database: "demo_db"
# config :todo_app, mysql_password: ""
# config :todo_app, mysql_database: "dev_mdom"

# db.createUser({user: "admin", pwd: "d892j!k2iewA", roles: [{ role: "readWrite", db: "sultanads" }]});
