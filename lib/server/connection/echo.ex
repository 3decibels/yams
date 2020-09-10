defmodule Msg.Server.Connection.Echo do
  @moduledoc """
  This module implements a simple echo server on a TLS socket
  """
  use GenServer
  alias __MODULE__
  defstruct tls_socket: nil

  @doc """
  Starts a `Msg.Server.Connection.Echo` process linked to the current process
  """
  def start_link(%Echo{} = conn) do
    GenServer.start_link(__MODULE__, conn)
  end


  impl true
  def init(%Echo{tls_socket: _tls_socket} = conn) do
    {:ok, conn}
  end


  @impl true
  def handle_info({:ssl, _socket_info, data}, %Echo{tls_socket: tls_socket} = conn) do
    :ssl.send(tls_socket, data)
    {:no_response, conn}
  end
end