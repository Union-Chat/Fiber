defmodule Fiber.Application do
  @moduledoc """
  Supervisor responsible of Fiber worker management
  """

  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec
    Logger.info "Starting Fiber version #{Fiber.version}"

    hash = :crypto.hash(
             :sha,
             :os.system_time(:millisecond)
             |> Integer.to_string
           )
           |> Base.encode16
           |> String.downcase

    dispatch = :cowboy_router.compile([_: [{"/", Fiber.Websocket.Internal.Handler, [hash: hash]}]])
    {:ok, _} = :cowboy.start_clear(
      :http,
      [port: Application.get_env(:fiber, :int_port)],
      %{
        :env => %{
          :dispatch => dispatch
        }
      }
    )

    children = [
      # Supervisor
      {Task.Supervisor, name: Fiber.TaskSupervisor},
      # Redis
      Fiber.Redis,
      # Cluster
      worker(Fiber.Cluster, [hash])
    ]
    opts = [strategy: :one_for_one, name: Fiber.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
