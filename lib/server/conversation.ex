defmodule Yams.Server.Conversation do
  @moduledoc """
  This module persists information about conversations between devices and routes messages between them.
  """
  use GenServer, restart: :temporary
  alias __MODULE__
  require Logger
  defstruct [:uuid, participants: [], message_history: []]

  @doc """
  Starts a `Yams.Server.Conversation` process linked to the current process.
  """
  def start_link(%Conversation{participants: participants, uuid: uuid} = conv) when is_list(participants) and is_integer(uuid),
    do: GenServer.start_link(__MODULE__, conv, name: via_tuple(uuid))

  def start_link(%Conversation{participants: participants} = conv) when is_list(participants) do
    uuid = UUID.uuid4() |> UUID.string_to_binary!()
    conv = %Conversation{conv | uuid: uuid}
    GenServer.start_link(__MODULE__, conv, name: via_tuple(uuid))
  end


  # Initialize a conversation
  @impl true
  def init(%Conversation{} = conv), do: {:ok, conv}


  # Allow processes to interact with the connection via conversation registry
  defp via_tuple(uuid), do: Yams.Server.ConnectionRegistry.via_tuple{__MODULE__, uuid}

end