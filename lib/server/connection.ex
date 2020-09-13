defmodule Msg.Server.Connection do
  @moduledoc """
  This module allows interaction with the connection representing a remote device.
  """
  use GenServer, restart: :temporary
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


  # Initialize a connection with a TLS socket
  @impl true
  def init(%Connection{tls_socket: tls_socket} = conn) do
    :ssl.controlling_process(tls_socket, self())
    {:ok, conn}
  end


  # Handle a call to send a message over the connection
  @impl true
  def handle_call({:send_msg, msg}, _from_pid, %Connection{tls_socket: tls_socket} = conn) do
    response = :ssl.send(tls_socket, msg)
    {:reply, response, conn}
  end


  # Handle the TLS socket closing
  @impl true
  def handle_info({:ssl_closed, _socket}, %Connection{tls_socket: _tls_socket} = conn) do
    Logger.info("Received TLS close, shutting down connection")
    {:stop, :normal, conn}
  end


  # Nicely close the TLS socket on termination
  @impl true
  def terminate(_reason, %Connection{tls_socket: tls_socket} = _conn), do: :ssl.close(tls_socket)


  @doc """
  Takes a binary beginning with a base128 encoded length and returns a tuple with the decoded
  length as an integer and the original supplied data with the base128 integer stripped off.
  """
  def decode_protobuf_length(<<msb::1, lsb::7, tail::binary>> = data, acc \\ <<>>) when is_binary(data) and is_bitstring(acc) do
     case msb do
       0 -> {protobuf_bitstring_to_int(<<lsb::7, acc::bitstring>>), tail}
       1 -> decode_protobuf_length(tail, <<lsb::7, acc::bitstring>>)
     end
  end


  @doc """
  Pads a protobuf base128 variant bitstring into a binary and converts into an integer
  """
  def protobuf_bitstring_to_int(<<msb::1, lsb::bitstring>> = data) when is_bitstring(data) do
    padding_bits = 8 - rem(bit_size(data), 8)
    padded = <<msb::1, 0::size(padding_bits), lsb::bitstring>>
    padded_bits = bit_size(padded)
    <<int::size(padded_bits)-integer-signed>> = padded
    int
  end

end