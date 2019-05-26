defmodule Nerve.Websocket.Handler do
  @moduledoc """
  Websocket used to handle all incoming connections
  """

  alias Nerve.Storage
  alias Nerve.Cluster
  alias Nerve.Websocket
  alias Nerve.Websocket.Payload
  require Logger

  @behaviour :cowboy_websocket

  def init(req, state) do
    {
      :cowboy_websocket,
      req,
      state ++ [identified: false],
      %{
        idle_timeout: Websocket.heartbeat_interval + 25000
      }
    }
  end

  def terminate(_reason, _req, state) do
    if state[:app_name] do
      Logger.info "[Socket] Client #{state[:app_name]}##{state[:client_id]} disconnected"
      Storage.delete_client(state[:app_name], state[:client_id])
    end
    :ok
  end

  def websocket_init(state) do
    new_state = Keyword.put(
      state,
      :timer,
      Process.send_after(
        self,
        :zombie,
        Websocket.heartbeat_interval + 15000
      )
    )
    Payload.hello(new_state)
  end

  def websocket_handle({:text, data}, state) do
    {status, payload} = Jason.decode(data)
    if status != :ok do
      Payload.no_u_tbh("Invalid JSON", state)
    else
      Websocket.handle_payload(payload, state)
    end
  end

  def websocket_handle(_, state), do:
    Payload.no_u_tbh("Invalid frame", state)

  def websocket_info(:zombie, state), do:
    Payload.no_u_tbh("Heartbeat timed out", state)
end
