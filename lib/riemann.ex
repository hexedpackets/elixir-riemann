defmodule Riemann do
  @doc """
  Send a list of events synchronously.
  """
  @spec submit(nonempty_list) :: :ok | {:error, atom}
  def submit(events) do
    events
    |> events_to_msg
    |> Riemann.Client.submit
  end

  @doc """
  Send a list of events asynchronously.
  """
  @spec submit_async(nonempty_list) :: :ok | {:error, atom}
  def submit_async(events) do
    events
    |> events_to_msg
    |> Riemann.Client.submit_async
  end


  defp events_to_msg(events) do
    [events: Enum.map(events, &Riemann.Event.build/1)]
    |> Riemann.Protobuf.Msg.new
    |> Riemann.Protobuf.Msg.encode
  end
end
