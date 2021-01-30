defmodule Yams.Server.ConnectionSupervisor do
  @moduledoc """
  This module is responsible for the supervision of Yams.Server.Connection processes
  """
  use DynamicSupervisor

  @doc """
  Starts a `Yams.Server.ConnectionSupervisor` process linked to the current process
  """
  def start_link(init_arg), do: DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)


  @impl true
  def init(_init_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

end