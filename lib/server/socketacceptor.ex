defmodule Yams.Server.SocketAcceptor do
  @moduledoc """
  This module starts a task to listen on a TCP socket and accept incoming connections.

  Accpeted connections are passed off to `Yams.Server.Connection.Authenticator` tasks
  for further processing as fast as possible to allow more incoming connections to
  be handled.
  """
  use Task, restart: :permanent
  require Logger


  @doc """
  Starts a `Yams.Server.SocketAcceptor` process linked to the current process
  """
  def start_link(listen_socket), do: Task.start_link(__MODULE__, :accept_loop, [listen_socket])


  @doc """
  Accepts incomming TLS connections on the supplied `listen_socket` and passes the resulting
  socket off to a `Yams.Server.Connection.Authenticator` for further processing.

  Will continue listening until interrupted.
  """
  def accept_loop(listen_socket) do
    with {:ok, transport_socket} <- :ssl.transport_accept(listen_socket),
         {:ok, ssl_socket} <- :ssl.handshake(transport_socket)
    do
      Task.Supervisor.start_child(Yams.Server.AuthSupervisor, Yams.Server.Connection.Authenticator,
        :run, [ssl_socket, Yams.Server.ConnectionSupervisor])
    else
      {:error, {:tls_alert, {:certificate_required, _}}} -> Logger.info("Peer did not present client certificate, closing connection")
    end

    accept_loop(listen_socket)
  end

end