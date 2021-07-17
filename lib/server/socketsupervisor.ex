defmodule Yams.Server.SocketSupervisor do
  @moduledoc """
  This module opens a new socket for incoming connections and passes it to a static number
  of acceptor processes placed under supervision.
  """
  use Supervisor
  alias Yams.Server.SocketAcceptor
  require Logger


  @doc """
  Starts a `Yams.Server.SocketSupervisor` process linked to the current process
  """
  def start_link(port_number) when is_integer(port_number), do: Supervisor.start_link(__MODULE__, port_number, name: __MODULE__)


  @impl true
  def init(port_number) do
    ca_cert = Application.fetch_env!(:yams, :ca_cert)
    server_cert = Application.fetch_env!(:yams, :server_cert)
    server_key = Application.fetch_env!(:yams, :server_key)
    acceptor_count = Application.fetch_env!(:yams, :acceptor_count)

    # Open socket for listening
    with true <- File.exists?(ca_cert),
         true <- File.exists?(server_cert),
         true <- File.exists?(server_key),
         {:ok, listen_socket} <- :ssl.listen(port_number, [reuseaddr: true, cacertfile: ca_cert, certfile: server_cert,
      keyfile: server_key, verify: :verify_peer, fail_if_no_peer_cert: true])
    do
      children = for n <- 1..acceptor_count do
        Logger.info("Starting socket acceptor \##{n}")
        Supervisor.child_spec({SocketAcceptor, listen_socket}, id: :"socket_acceptor#{n}")
      end
      Supervisor.init(children, strategy: :one_for_one)
    else
      _ ->
        Logger.error("Failed to open SSL socket for listening")
        {:error, :socket_failure}
    end
  end

end