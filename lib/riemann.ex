defmodule Riemann do
  @doc """
  Send a list of events synchronously.
  """
  @spec submit(nonempty_list) :: :ok | {:error, atom}
  def submit(events) do
    events
    |> events_to_msg
    |> Msg.send
  end

  @doc """
  Send a list of events asynchronously.
  """
  @spec submit_async(nonempty_list) :: :ok | {:error, atom}
  def submit_async(events) do
    events
    |> events_to_msg
    |> Riemann.Protobuf.Msg.send_async
  end


  defp events_to_msg(events) do
    [events: Riemann.Protobuf.Event.list_to_events(events)]
    |> Riemann.Protobuf.Msg.new
  end
end
