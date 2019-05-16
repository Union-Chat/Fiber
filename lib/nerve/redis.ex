defmodule Nerve.Redis do
  @pool 3

  # Child processes
  def child_spec(_opts) do
    %URI{host: host, userinfo: userinfo} = Application.get_env(:nerve, :redis_dsn)
                                           |> URI.parse

    children =
      if userinfo != nil and userinfo != "" do
        password =
          userinfo
          |> String.split(":", trim: true)
          |> hd
        for i <- 1..@pool do
          Supervisor.child_spec {Redix, [name: :"redix_#{i}", host: host, password: password]}, id: {Redix, i}
        end
      else
        for i <- 1..@pool do
          Supervisor.child_spec {Redix, [name: :"redix_#{i}", host: host]}, id: {Redix, i}
        end
      end

    %{
      id: RedixSupervisor,
      type: :supervisor,
      start: {Supervisor, :start_link, [children, [strategy: :one_for_one]]}
    }
  end

  # Queries
  def query(query) do
    Redix.command :"redix_#{random_index() + 1}", query
  end

  # random
  defp random_index() do
    [:positive]
    |> System.unique_integer
    |> rem @pool
  end
end
