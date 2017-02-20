defmodule Riemann.Mixfile do
  use Mix.Project

  @version File.read!("VERSION") |> String.strip

  def project do
    [app: :riemann,
     version: @version,
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package()]
  end

  def application do
    [extra_applications: [:logger, :exprotobuf],
     mod: {Riemann.Application, []}]
  end

  defp deps do
    [
      {:exprotobuf, "~> 1.2.5"},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp package do
    [maintainers: ["William Huba"],
     licenses: ["MIT"],
     links: %{"GitHub": "https://github.com/hexedpackets/elixir-riemann",
              "Riemann": "http://riemann.io"}]
  end
end
