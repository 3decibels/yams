defmodule Msg.Server.Connection do
  use GenServer
  defstruct socket: nil, tls_socket: nil, client_name: nil, unique_id: nil

  def start_link(%Msg.Server.Connection{} = default) do
    GenServer.start_link(__MODULE__, default)
  end


  def send_msg(pid, msg) do
    GenServer.call(pid, {:send_msg, msg})
  end


  @impl true
  def init(%Msg.Server.Connection{} = conn) do
    {:ok, conn}
  end


  @impl true
  def handle_call({:send_msg, msg}, from_pid, conn) do
    # Send message to client and respond with success or failure
    {:reply, :ok, conn}
  end

end