defmodule Riemann do
  @doc """
  Send a list of events synchronously.
  """
  def submit(events) when is_list(events) do
    events
    |> events_to_msg
    |> Riemann.Client.submit
  end
  def submit(event), do: [event] |> submit

  @doc """
  Send a list of events asynchronously.
  """
  def submit_async(events) when is_list(events) do
    events
    |> events_to_msg
    |> Riemann.Client.submit_async
  end
  def submit_async(event), do: [event] |> submit_async

  defp events_to_msg(events) do
    [events: Enum.map(events, &Riemann.Event.build/1)]
    |> Riemann.Protobuf.Msg.new
    |> Riemann.Protobuf.Msg.encode
  end
end
