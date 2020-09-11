defmodule Msg.Server.SocketAcceptor do
  @moduledoc """
  This module starts a task to listen on a TCP socket and accept incoming connections.

  Accpeted connections are passed off to `Msg.Server.Connection.Authenticator` tasks
  for further processing as fast as possible to allow more incoming connections to
  be handled.
  """
  use Task, restart: :permanent
  alias Msg.Server.Connection.Authenticator


  @doc """
  Starts a `Msg.Server.SocketAcceptor` process linked to the current process
  """
  def start_link(listen_socket), do: Task.start_link(__MODULE__, :accept_loop, [listen_socket])


  @doc """
  Accepts incomming TLS connections on the supplied `listen_socket` and passes the resulting
  socket off to a `Msg.Server.Connection.Authenticator` for further processing.

  Will continue listening until interrupted.
  """
  def accept_loop(listen_socket) do
    with {:ok, transport_socket} <- :ssl.transport_accept(listen_socket),
         {:ok, ssl_socket} <- :ssl.handshake(transport_socket)
    do
      Authenticator.authenticate(ssl_socket, Msg.Server.ConnectionSupervisor)
    end
    
    accept_loop(listen_socket)
  end

end