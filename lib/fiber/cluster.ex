defmodule Fiber.Cluster do
  use GenServer
  alias Fiber.Storage
  alias Fiber.Redis
  require Logger

  @delay 100      # Delay between actions
  @interval 2000  # Delay between connection loop iterations

  def start_link(opts) do
    GenServer.start_link __MODULE__, opts
  end

  def init(hash) do
    Process.flag(:trap_exit, true)

    Logger.info "[Cluster] Initializing Fiber cluster"
    {:ok, hostname} = :inet.gethostname()
    {:ok, ip} = :inet.getaddr(hostname, :inet)
    hostname = to_string(hostname)
    ip = ip
         |> Tuple.to_list
         |> Enum.join(".")

    state = %{
      name: "#{hostname}_#{Application.get_env(:fiber, :int_port)}-#{Application.get_env(:fiber, :ext_port)}",
      cookie: Application.get_env(:fiber, :cookie),
      longname: nil,
      hostname: hostname,
      ip: ip,
      hash: hash,
    }

    # Start clustering
    Process.send_after self(), :start, @delay
    {:ok, state}
  end

  def terminate(reason, state) do
    registry_delete state[:hash]
    :normal
  end


  ################
  # Handlers
  ################
  def handle_info(:start, state) do
    unless Node.alive? do
      node_name = "#{state[:name]}@#{state[:ip]}"

      Logger.info "[Cluster] Starting node #{node_name}"
      {:ok, _} = node_name
                 |> String.to_atom
                 |> Node.start(:longnames)

      state[:cookie]
      |> String.to_atom
      |> Node.set_cookie

      Logger.info "[Cluster] Initializing store"
      Fiber.Storage.initialize()

      Logger.info "[Cluster] Adding node to registry"
      new_state = %{state | longname: node_name}
      registry_write new_state

      Logger.info "[Cluster] Node successfully fired up!"
      Process.send_after self(), :connect, @delay

      {:noreply, new_state}
    else
      Logger.warn "[Cluster] Tried to start an already alive node!"
      {:noreply, state}
    end
  end

  def handle_info(:connect, state) do
    registry_write state
    nodes = registry_read

    for {hash, longname} <- nodes do
      unless hash == state[:hash] do
        case Node.connect(String.to_atom longname) do
          true ->
            # All fine
            nil
          false ->
            Logger.debug "[Cluster] Node #{longname} is no longer available, removing from store"
            registry_delete hash
          :ignored ->
            Logger.debug "???"
        end
      end
    end

    # Queue next iteration
    Process.send_after self(), :connect, @interval
    {:noreply, state}
  end


  ################
  # Registry
  ################
  defp registry_read() do
    {:ok, res} = Redis.query ["HGETALL", "fiber:Registry"]

    res
    |> Enum.chunk_every(2)
    |> Enum.map(fn [a, b] -> {a, b} end)
    |> Enum.to_list
  end

  defp registry_write(state) do
    Redis.query ["HSET", "fiber:Registry", state[:hash], state[:longname]]
  end

  defp registry_delete(hash) do
    Redis.query ["HDEL", "fiber:Registry", hash]
  end
end
