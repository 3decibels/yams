import Config

# This is an example environment-specific configuration.

config :yams,
  ca_cert: "path/to/server_ca.crt",
  server_cert: "path/to/server.crt",
  server_key: "path/to/server.key"

config :yams, Yams.Database.Repo,
  database: "yams_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"
