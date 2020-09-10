defmodule Msg.Server.Connection.Authenticator do
  @moduledoc """
  This module is responsible for creating tasks that start TLS on sockets and
  perform authentication of the remote device using the supplied client certificate.
  """
  use Task
  alias Msg.Server.Connection

  @doc """
  Spawns a task to start TLS and perform authentication on a `socket`.

  If authentication is successful the socket will be placed into a `Msg.Server.Connection`
  to be run under the specified dynamic `supervisor`.

  This function is used for the side effect only. It returns no data.
  """
  def authenticate(socket, supervisor) do
    {:ok, pid} = Task.start(__MODULE__, :run, [socket, supervisor])
    :gen_tcp.controlling_process(socket, pid)
  end


  @doc """
  Starts TLS on a `socket` and runs authentication against the client certificate supplied
  by the remote device.

  If authentication is successful the socket is passed as part of a `Msg.Server.Connection`
  to the specified dynamic `supervisor`.

  Returns `:ok` on success or `{:error, reason}` on failure.
  """
  def run(socket, supervisor) do
    # Authenticate connection and place under the passed dynamic supervisor.
    # Use case to evaluate return from separate auth function and start child under
    #   supervisor or simply exit.
    {:ok, tls_socket} = :ssl.handshake(socket,
      [cacertfile: "./TestAuth.crt", certfile: "./TestServer.crt", keyfile: "./TestServer.key", verify: :verify_peer, fail_if_no_peer_cert: true])
    :ssl.setopts(tls_socket, [active: true])
    case true do
      false -> 
        {:error, :auth_failed}
      true -> 
        {:ok, pid} = DynamicSupervisor.start_child(supervisor, {Connection, %Connection{socket: socket, tls_socket: tls_socket}})
        result = :gen_tcp.controlling_process{socket, pid}
        :ok
    end
  end

end