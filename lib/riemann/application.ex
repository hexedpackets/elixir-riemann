defmodule Riemann.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    address = Application.get_env(:riemann, :address) || []

    children = [
      worker(Riemann.Client, [address], restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: Riemann.Supervisor, max_restarts: 2, max_seconds: 1]
    Supervisor.start_link(children, opts)
  end
end
