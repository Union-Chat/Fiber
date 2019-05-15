defmodule Nerve.Cluster do

  use GenServer
  require Logger

  @delay 100
  @interval 2000

  def start_link(opts) do
    GenServer.start_link __MODULE__, opts
  end

  def init(_) do
    Logger.info "[Cluster] Initializing Nerve cluster"
    {:ok, hostname} = :inet.gethostname()
    {:ok, ip} = :inet.getaddr(hostname, :inet)

    hostname = to_string(hostname)
    ip = ip
         |> Tuple.to_list
         |> Enum.join(".")

    hash =
      :crypto.hash(
        :sha,
        :os.system_time(:millisecond)
        |> Integer.to_string
      )
      |> Base.encode16
      |> String.downcase

    state = %{
      name: "Nerve_#{hostname}_#{Application.get_env(:nerve, :port)}",
      group: "Nerve",
      cookie: Application.get_env(:nerve, :cookie),
      longname: nil,
      hostname: hostname,
      ip: ip,
      hash: hash,
    }

    # Start clustering
    Process.send_after self(), :start, @delay
    {:ok, state}
  end

  ################
  # Handlers
  ################
  def handle_info(:start, state) do
    unless Node.alive? do
      node_name = "#{state[:name]}@#{state[:ip]}"

      Logger.info "[Cluster] Starting node #{node_name}"
      {:ok, _} = Node.start String.to_atom(node_name), :longnames
      Node.set_cookie String.to_atom(state[:cookie])

      Logger.info "[Cluster] Initializing store"
      Nerve.Mnesia.initialize()

      Logger.info "[Cluster] Node successfully fired up! Starting clustering"
      Process.send_after self(), :cluster, @delay

      {:noreply, state}
    else
      Logger.warn "[Cluster] Tried to start an already alive node"
      {:noreply, state}
    end
  end

  def handle_info(:cluster, state) do
    IO.puts "memes tbh"
    {:noreply, state}
  end
end
