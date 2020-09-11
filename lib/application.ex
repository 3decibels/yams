defmodule Msg.Application do
  @moduledoc false
  # Msg Application and master process supervisor
  use Application


  @impl true
  def start(_type, _args) do
    :ssl.start()
    server_port = Application.fetch_env!(:msg, :server_port)
    children = [
      # Order matters when starting supervised processes that interact
      Msg.Server.ConnectionSupervisor,
      {Msg.Server.SocketSupervisor, [server_port]}
    ]

    opts = [strategy: :one_for_one, name: Msg.Supervisor]
    Supervisor.start_link(children, opts)
  end

end