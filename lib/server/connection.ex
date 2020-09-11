defmodule Msg.Server.Connection do
  @moduledoc """
  This module allows interaction with the connection representing a remote device.
  """
  use GenServer, restart: :transient
  alias __MODULE__
  require Logger
  defstruct tls_socket: nil, client_name: nil, unique_id: nil


  @doc """
  Starts a `Msg.Server.Connection` process linked to the current process
  """
  def start_link(%Connection{} = conn), do: GenServer.start_link(__MODULE__, conn)


  @doc """
  Sends a message to the remote device.

  Returns `:ok` on sucess or `{:error, reason}` on failure.
  """
  def send_msg(pid, msg), do: GenServer.call(pid, {:send_msg, msg})


  @impl true
  def init(%Connection{tls_socket: tls_socket} = conn) do
    :ssl.controlling_process(tls_socket, self())
    {:ok, conn}
  end


  @impl true
  def handle_call({:send_msg, msg}, _from_pid, %Connection{tls_socket: tls_socket} = conn) do
    response = :ssl.send(tls_socket, msg)
    {:reply, response, conn}
  end


  @impl true
  def handle_info({:ssl_closed, _socket}, %Connection{tls_socket: _tls_socket} = conn) do
    Logger.info("Received TLS close, shutting down connection")
    {:stop, :normal, conn}
  end


  def decode_protobuf_length(<<msb::1, lsb::7, tail::binary>> = data, acc \\ <<>>) when is_binary(data) and is_binary(acc) do
     
  end


  @doc """
  Pads a protobuf base128 variant bitstring into a binary and converts into an integer
  """
  def protobuf_bitstring_to_int(<<msb::1, lsb::bitstring>> = data) when is_bitstring(data) do
    padding_bits = 8 - bit_size(data)
    <<int::integer-signed>> = <<msb::bitstring, 0::size(padding_bits), lsb::bitstring>>
    int
  end

end