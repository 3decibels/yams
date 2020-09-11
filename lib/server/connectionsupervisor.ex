defmodule Msg.Server.ConnectionSupervisor do
  @moduledoc """
  This module is responsible for the supervision of Msg.Server.Connection processes
  """
  use DynamicSupervisor

  @doc """
  Starts a `Msg.Server.ConnectionSupervisor` process linked to the current process
  """
  def start_link(init_arg), do: DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)


  @impl true
  def init(_init_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

end