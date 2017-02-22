defmodule Riemann.Event do

  def host do
    case Application.get_env(:riemann, :event_host) do
      nil ->
        {:ok, hostname} = :inet.gethostname
        hostname
      {:system, name} -> System.get_env(name) |> :erlang.list_to_binary()
      val when is_binary(val) -> val
      val when is_list(val) -> :erlang.list_to_binary()
    end
  end

  def build(event) when is_map(event) do
    %{host: host(), time: :erlang.system_time(:seconds)}
    |> Map.merge(event)
    |> Map.update(:attributes, [], fn attributes -> Enum.map(attributes, &build_attribute/1) end)
    |> set_metric()
    |> Map.to_list()
    |> Riemann.Protobuf.Event.new()
  end

  def build(event) do
    event
    |> Enum.into(%{})
    |> build()
  end

  defp build_attribute({key, value}) do
    Riemann.Protobuf.Attribute.new(key: to_string(key), value: to_string(value))
  end

  defp set_metric(event = %{metric: metric}) when is_integer(metric), do: Map.put(event, :metric_sint64, metric)
  defp set_metric(event = %{metric: metric}) when is_float(metric), do: Map.put(event, :metric_d, metric)
  defp set_metric(event), do: raise ArgumentError, "No metric provided for event #{inspect event}"
end
