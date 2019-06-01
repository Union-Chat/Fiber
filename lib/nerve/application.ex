defmodule Nerve.Application do
  @moduledoc """
  Supervisor responsible of Nerve worker management
  """

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec
    Logger.info "Starting Nerve version #{Nerve.version}"

    hash = :crypto.hash(
             :sha,
             :os.system_time(:millisecond)
             |> Integer.to_string
           )
           |> Base.encode16
           |> String.downcase

    dispatch = :cowboy_router.compile([_: [{"/", Nerve.Websocket.Internal.Handler, [hash: hash]}]])
    {:ok, _} = :cowboy.start_clear(
      :http,
      [port: Application.get_env(:nerve, :int_port)],
      %{
        :env => %{
          :dispatch => dispatch
        }
      }
    )

    children = [
      # Supervisor
      {Task.Supervisor, name: Nerve.TaskSupervisor},
      # Redis
      Nerve.Redis,
      # Cluster
      worker(Nerve.Cluster, [hash])
    ]
    opts = [strategy: :one_for_one, name: Nerve.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
