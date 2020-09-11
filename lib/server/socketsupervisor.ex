defmodule Msg.Server.SocketSupervisor do
  @moduledoc """
  This module opens a new socket for incoming connections and passes it to a static number
  of acceptor processes placed under supervision.
  """
  use Supervisor
  alias Msg.Server.SocketAcceptor


  @doc """
  Starts a `Msg.Server.SocketSupervisor` process linked to the current process
  """
  def start_link(port_number) when is_integer(port_number) do
    Supervisor.start_link(__MODULE__, port_number, name: __MODULE__)
  end


  @impl true
  def init(port_number) do
    ca_cert = Application.fetch_env!(:msg, :ca_cert)
    server_cert = Application.fetch_env!(:msg, :server_cert)
    server_key = Application.fetch_env!(:msg, :server_key)

    # TODO: Add some error handling to check the certificate files exist
    # Open socket for listening
    {:ok, listen_socket} = :ssl.listen(port_number, [reuseaddr: true, cacertfile: ca_cert, certfile: server_cert,
      keyfile: server_key, verify: :verify_peer, fail_if_no_peer_cert: true])

    children = for n <- 1..4 do
      Supervisor.child_spec({SocketAcceptor, listen_socket}, id: :"socket_acceptor#{n}")
    end

    Supervisor.init(children, strategy: :one_for_one)
  end

end