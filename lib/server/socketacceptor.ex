defmodule Msg.Server.SocketAcceptor do
  @moduledoc """
  This module starts a task to listen on a TCP socket and accept incoming connections.

  Accpeted connections are passed off to `Msg.Server.Connection.Authenticator` tasks
  for further processing as fast as possible to allow more incoming connections to
  be handled.
  """
  use Task
  alias Msg.Server.Connection.Authenticator


  @doc """
  Starts a `Msg.Server.SocketAcceptor` process linked to the current process
  """
  def start_link(port) do
    Task.start_link(__MODULE__, :accept, [port])
  end


  @doc """
  Listens on the specified TCP `port` number for incomming connections to accept.

  Accepted connections are passed off to a `Msg.Server.Connection.Authenticator` task
  for further processing.
  """
  def accept(port) when is_integer(port) do
    :ssl.start()
    {:ok, listen_socket} = :gen_tcp.listen(port, [reuseaddr: true, active: false])
    accept_loop(listen_socket)
  end


  @doc """
  Accepts incomming connections on the supplied `listen_socket` and passes the resulting
  socket off to a `Msg.Server.Connection.Authenticator` for further processing.

  Will continue listening until interrupted.
  """
  defp accept_loop(listen_socket) do
    {:ok, socket} = :gen_tcp.accept(listen_socket)
    # Move TLS functions and authentication out to a separate task?
    Authenticator.authenticate(socket, Msg.Server.ConnectionSupervisor)
    accept_loop(listen_socket)
  end

end