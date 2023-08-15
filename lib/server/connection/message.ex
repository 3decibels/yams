defmodule Yams.Server.Connection.Message do
  @moduledoc """
  Module defining connection message attributes and functions.
  """
  alias __MODULE__
  defstruct [:opcode, :data]

  @doc """
  Takes a message struct and encodes into message data format.
  """
  def encode_message(%Message{opcode: opcode, data: data} = _message) when is_atom(opcode) and is_binary(data) do
    <<atom_to_opcode(opcode)>> <> data
  end


  @doc """
  Takes message data and decodes to a Message struct.
  """
  def decode_message(data) when is_binary(data) do
    <<opcode::8-integer-unsigned, tail::binary>> = data
    %{opcode: opcode_to_atom(opcode), data: tail}
  end


  @doc """
  Takes an opcode integer and returns the corresponding atom.
  """
  def opcode_to_atom(opcode) when is_integer(opcode) do
    case opcode do
      1 -> :heartbeat_request
      2 -> :heartbeat_response
      3 -> :conversation_begin
      4 -> :conversation_end
      5 -> :conversation_reply
      _ -> :error
    end
  end


  @doc """
  Takes an opcode atom and returns the corresponding integer.
  """
  def atom_to_opcode(atom) when is_atom(atom) do
    case atom do
      :heartbeat_request  -> 1
      :heartbeat_response -> 2
      :conversation_begin -> 3
      :conversation_end   -> 4
      :conversation_reply -> 5
      _ -> :error
    end
  end

end