import Config

config :msg,
  server_port: 9999

import_config "#{Mix.env()}.exs"