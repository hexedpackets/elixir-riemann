defmodule Riemann.Protobuf do
  use Protobuf, from: Path.join(:code.priv_dir(:riemann), "riemann.proto")
end
