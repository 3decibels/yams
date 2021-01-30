defmodule Yams.Server.Connection do
  @moduledoc """
  This module allows interaction with the connection representing a remote device.
  """
  use GenServer, restart: :temporary
  alias __MODULE__
  require Logger
  defstruct [:tls_socket, :client_name, :distinguished_name, :unique_id]


  @doc """
  Starts a `Yams.Server.Connection` process linked to the current process.
  """
  def start_link(%Connection{client_name: client_name} = conn), do: GenServer.start_link(
    __MODULE__, conn, name: via_tuple(client_name))


  @doc """
  Sends a message to the remote device.

  Returns `:ok` on sucess or `{:error, reason}` on failure.
  """
  def send_msg(client_name, msg), do: GenServer.call(via_tuple(client_name), {:send_msg, msg})


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


  # Allow processes to interact with the connection via connection registry
  defp via_tuple(client_name), do: Yams.Server.ConnectionRegistry.via_tuple{__MODULE__, client_name}


  @doc """
  Takes a binary beginning with a base128 varint encoded length and returns a tuple with the decoded
  length as an integer and the original supplied data with the base128 integer removed.
  """
  def decode_protobuf_length(data, acc \\ <<>>)
  def decode_protobuf_length(<<0::1, lsb::7, tail::binary>>, acc) when is_bitstring(acc), do: {decode_base128_int(<<lsb::7, acc::bitstring>>), tail}
  def decode_protobuf_length(<<1::1, lsb::7, tail::binary>>, acc) when is_bitstring(acc), do: decode_protobuf_length(tail, <<lsb::7, acc::bitstring>>)


  @doc """
  Converts a base128 varint bitstring into an unsigned integer.

  Assumes the varint has already been converted into the correct form with the most significant bits
  in each group dropped and the remaining groups rearranged into the expected form (first group last,
  next group before the first, etc).
  """
  def decode_base128_int(data) when is_bitstring(data) and rem(bit_size(data), 7) == 0 do
    data_size = bit_size(data)
    <<int::size(data_size)-integer-unsigned>> = data
    int
  end

end