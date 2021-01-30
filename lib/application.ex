defmodule Yams.Application do
  @moduledoc false
  # Yams Application and main process supervisor
  use Application


  @impl true
  def start(_type, _args) do
    :ssl.start()
    server_port = Application.fetch_env!(:yams, :server_port)
    children = [
      # Order matters when starting supervised processes that interact
      Yams.Database.Repo,
      Yams.Server.ConversationSupervisor,
      Yams.Server.ConversationRegistry,
      {Task.Supervisor, name: Yams.Server.AuthSupervisor},
      Yams.Server.ConnectionSupervisor,
      Yams.Server.ConnectionRegistry,
      {Yams.Server.SocketSupervisor, server_port}
    ]

    opts = [strategy: :one_for_one, name: Yams.Supervisor]
    Supervisor.start_link(children, opts)
  end

end