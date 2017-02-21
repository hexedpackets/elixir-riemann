use Mix.Config

config :riemann, :address,
  host: {:system, "RIEMANN_HOST"},
  port: 5555
