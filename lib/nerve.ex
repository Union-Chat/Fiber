defmodule Nerve do
  @moduledoc """
  Supervisor responsible of Nerve worker management
  """

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.info("Starting Nerve")

    children = []

    opts = [strategy: :one_for_one, name: Nerve.Supervisor]
    Supervisor.start_link(children, opts)
  end
end