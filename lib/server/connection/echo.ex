defmodule Yams.Server.Connection.Echo do
  @moduledoc """
  This module implements a simple echo server on a TLS socket
  """
  use GenServer, restart: :temporary
  require Logger
  alias Yams.Server.Connection

  @doc """
  Starts a `Yams.Server.Connection.Echo` process linked to the current process
  """
  def start_link(%Connection{} = conn) do
    GenServer.start_link(__MODULE__, conn)
  end


  @impl true
  def init(%Connection{tls_socket: tls_socket, client_name: client_name} = conn) do
    Logger.info("Starting up echo server for client #{client_name}")
    :ssl.controlling_process(tls_socket, self())
    {:ok, conn}
  end


  @impl true
  def handle_info({:ssl, _socket, data}, %Connection{tls_socket: tls_socket} = conn) do
    :ssl.send(tls_socket, data)
    {:noreply, conn}
  end


  @impl true
  def handle_info({:ssl_closed, _socket}, conn) do
    Logger.info("Received TLS close, shutting down echo server")
    {:stop, :normal, conn}
  end


  @impl true
  def terminate(_reason, %Connection{tls_socket: tls_socket} = _conn), do: :ssl.close(tls_socket)

end