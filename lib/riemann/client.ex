defmodule Riemann.Client do
  use GenServer
  require Logger

  @ok_msg Riemann.Protobuf.Msg.new(ok: true) |> Riemann.Protobuf.Msg.encode
  @error_msg Riemann.Protobuf.Msg.new(ok: false) |> Riemann.Protobuf.Msg.encode

  defp resolve_env_var({:system, name}), do: System.get_env(name)
  defp resolve_env_var(val), do: val

  def start_link(args) do
    state = args
    |> Keyword.put_new(:host, "localhost")
    |> Keyword.put_new(:port, 5555)
    |> Enum.map(fn {key, value} -> {key, resolve_env_var(value)} end)
    |> Enum.into(%{})
    |> Map.put(:from, nil)

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state = %{host: host, port: port}) do
    Logger.debug "Connecting to riemann at #{host}:#{port}..."

    tcp_opts = [:binary, nodelay: true, packet: 4, active: true]
    {:ok, conn} = :gen_tcp.connect(:erlang.binary_to_list(host), port, tcp_opts)
    {:ok, Map.put(state, :conn, conn)}
  end

  def handle_call({:send, msg}, from, state = %{conn: conn}) do
    :ok = :gen_tcp.send(conn, msg)
    {:noreply, %{state | from: from}}
  end

  def handle_cast({:send, msg}, state = %{conn: conn}) do
    :ok = :gen_tcp.send(conn, msg)
    {:noreply, state}
  end

  def handle_info({:tcp, _conn, @ok_msg}, state = %{from: nil}) do
    {:noreply, state}
  end

  def handle_info({:tcp, _conn, @ok_msg}, state = %{from: from}) do
    GenServer.reply(from, :ok)
    {:noreply, %{state | from: nil}}
  end

  def handle_info({:tcp, _conn, << @error_msg, _rest :: binary >> = msg}, state = %{from: from}) when is_tuple(from) do
    GenServer.reply(from, {:error, Riemann.Protobuf.Msg.decode(msg)})
    {:noreply, %{state | from: nil}}
  end

  def handle_info({:tcp_error, _conn, error}, state) do
    state = state
    |> Map.put(:conn, nil)
    |> Map.put(:from, nil)
    {:stop, error, state}
  end

  def submit(msg), do: GenServer.call(__MODULE__, {:send, msg})
  def submit_async(msg), do: GenServer.cast(__MODULE__, {:send, msg})
end
