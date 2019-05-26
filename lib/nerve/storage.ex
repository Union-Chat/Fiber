defmodule Nerve.Storage do
  @moduledoc """
  Nerve's store Mnesia-baked. This is used to store all data used by the app
  """

  # Identify of clients
  @identity :identity
  # Clients
  @clients :clients
  # Voice analysis data
  @analysis :analysis

  @doc """
  Initialize the store
  """
  def initialize do
    :mnesia.create_schema []
    :mnesia.start()
    :mnesia.create_table @clients, [attributes: [:app_id, :client_ids]]
    :mnesia.create_table @identity, [attributes: [:composite_key, :value]]
    :mnesia.create_table @analysis, [attributes: [:composite_key, :data]]
    :ok
  end

  @doc """
  Initializen't the store
  """
  def shutdown do
    :mnesia.delete_table @clients
    :mnesia.delete_table @identity
    :mnesia.delete_table @analysis
    :mnesia.stop()
    :mnesia.delete_schema []
    :ok
  end

  ################
  # Clients
  ################
  def insert_client(app_name, client_id) do
    unless client_exists?(app_name, client_id) do
      :mnesia.transaction(
        fn ->
          clients = :mnesia.wread {@clients, app_name}
          case clients do
            [data] ->
              {@clients, ^app_name, clients} = data
              :mnesia.write {@clients, app_name, MapSet.put(clients, client_id)}
            _ ->
              :mnesia.write {@clients, app_name, MapSet.new([client_id])}
          end
        end
      )
      :ok
    else
      {:error, "Client #{client_id} is already registered as #{app_name}!"}
    end
  end

  def get_clients(app_name) do
    res =
      :mnesia.transaction(fn -> :mnesia.wread {@clients, app_name} end)
    case res do
      {:atomic, [data]} -> # Clients found
        {@clients, ^app_name, clients} = data
        {:ok, clients}
      {:atomic, []} -> # No clients for that application
        {:ok, MapSet.new()}
      {:aborted, reason} -> # rip
        {:error, {:mnesia_aborted, reason}}
    end
  end

  def client_exists?(app_name, client_id) do
    {:ok, clients} = get_clients app_name
    MapSet.member? clients, client_id
  end

  def delete_client(app_name, client_id) do
    :mnesia.transaction(
      fn ->
        clients = :mnesia.wread {@clients, app_name}
        case clients do
          [data] ->
            {@clients, ^app_name, clients} = data
            :mnesia.write {@clients, app_name, MapSet.delete(clients, client_id)}
          # todo: delete their metadata too
        end
      end
    )
    :ok
  end

  ################
  # Identity
  ################
  def update_identity(app_name, client_id, metadata) do
    if client_exists?(app_name, client_id) do
      res = :mnesia.transaction(
        fn ->
          metadata
          |> Map.keys
          |> Enum.each(fn key -> :mnesia.write {@identity, {app_name, client_id, key}, metadata[key]} end)
        end
      )
      case res do
        {:atomic, _} ->
          :ok
        {:aborted, reason} -> # rip
          {:error, {:mnesia_aborted, reason}}
      end
    else
      {:error, {:no_client}}
    end
  end

  ################
  # Analysis
  ################
end
