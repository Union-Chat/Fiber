defmodule Nerve.Mnesia do
  @moduledoc """
  Nerve's store Mnesia-baked. This is used to store all data used by the app
  """

  # Identify of clients
  @identity :identity
  # Clients
  @clients :clients
  # Sockets PIDs
  @sockets :sockets
  # Voice analysis data
  @analysis :analysis

  @doc """
  Initialize the store
  """
  def initialize do
    :mnesia.create_schema []
    :mnesia.start()
    :mnesia.create_table @identity, [attributes: [:composite_key, :value]]
    :mnesia.create_table @clients, [attributes: [:app_id, :client_ids]]
    :mnesia.create_table @sockets, [attributes: [:composite_key, :socket_pid]]
    :mnesia.create_table @analysis, [attributes: [:composite_key, :data]]
    :ok
  end

  @doc """
  Initializen't the store
  """
  @spec shutdown() :: :ok
  def shutdown do
    :mnesia.delete_table @identity
    :mnesia.delete_table @clients
    :mnesia.delete_table @sockets
    :mnesia.delete_table @analysis
    :mnesia.stop()
    :mnesia.delete_schema []
    :ok
  end

  ################
  # Identity
  ################

  ################
  # Clients
  ################

  ################
  # WS PIDs
  ################

  ################
  # Analysis
  ################
end
