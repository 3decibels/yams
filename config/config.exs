import Config

config :yams,
  server_port: 9999

import_config "#{Mix.env()}.exs"