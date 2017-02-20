defmodule Riemann.Client do
  use GenServer

  def start_link(args) do
    state = args
    |> Map.put_new(:address, "localhost")
    |> Map.put_new(:port, 5555)
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:send, event}, _from, state) do
    {:reply. :ok, state}
  end

  def handle_cast({:send, event}, stat) do
    {:noreply, state}
  end
end
