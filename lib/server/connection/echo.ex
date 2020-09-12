defmodule Msg.Server.Connection.Echo do
  @moduledoc """
  This module implements a simple echo server on a TLS socket
  """
  use GenServer, restart: :temporary
  require Logger
  alias Msg.Server.Connection

  @doc """
  Starts a `Msg.Server.Connection.Echo` process linked to the current process
  """
  def start_link(%Connection{} = conn) do
    GenServer.start_link(__MODULE__, conn)
  end


  @impl true
  def init(%Connection{tls_socket: tls_socket} = conn) do
    :ssl.controlling_process(tls_socket, self())
    {:ok, conn}
  end


  @impl true
  def handle_info({:ssl, _socket, data}, %Connection{tls_socket: tls_socket} = conn) do
    :ssl.send(tls_socket, data)
    {:noreply, conn}
  end


  @impl true
  def handle_info({:ssl_closed, _socket}, %Connection{tls_socket: _tls_socket} = conn) do
    Logger.info("Received TLS close, shutting down echo server")
    {:stop, :normal, conn}
  end

end