defmodule Msg.Server.ConnectionRegistry do
  @moduledoc """
  This module registers connection processes for lookup
  """

  @doc """
  Starts a `Msg.Server.ConnectionRegistry` process linked to the current process.
  """
  def start_link(), do: Registry.start_link(keys: :unique, name: __MODULE__, partitions: System.schedulers_online())


  @doc """
  Returns via tuple for lookups.
  """
  def via_tuple(key), do: {:via, Registry, {__MODULE__, key}}


  @doc """
  Returns a specification to start a connection registry under a supervisor.
  """
  def child_spec(_), do: Supervisor.child_spec(Registry, id: __MODULE__, start: {__MODULE__, :start_link, []})

end