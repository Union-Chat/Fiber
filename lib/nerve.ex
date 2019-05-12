defmodule Nerve do
  @moduledoc """
  Supervisor responsible of Nerve worker management
  """

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Logger.info "Starting Nerve"

    dispatch = :cowboy_router.compile([{:_, [{"/", Nerve.Websocket, []}]}])

    { :ok, _ } = :cowboy.start_clear(
      :http,
      [{:port, 8880}],
      %{:env => %{:dispatch => dispatch}}
    )

    children = []
    opts = [strategy: :one_for_one, name: Nerve.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
