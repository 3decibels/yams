import Config

config :yams,
  server_port: 9999

config :yams, ecto_repos: [Yams.Database.Repo]


import_config "#{Mix.env()}.exs"
