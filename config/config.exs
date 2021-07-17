import Config

config :yams,
  server_port: 9999,
  acceptor_count: 4

config :yams, ecto_repos: [Yams.Database.Repo]

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n"


import_config "#{Mix.env()}.exs"
