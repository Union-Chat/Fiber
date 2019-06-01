defmodule Nerve.Websocket.Internal.Handler do
  @moduledoc """
  Websocket used to handle all incoming internal connections
  """

  alias Nerve.Storage
  alias Nerve.Websocket
  alias Nerve.Websocket.Payload
  alias Nerve.Websocket.Internal
  alias Nerve.Websocket.Payload.Builder
  require Logger

  @behaviour :cowboy_websocket

  def init(req, state), do:
    Websocket.init_connection(req, state)

  def websocket_init(state), do:
    Websocket.init_socket(state)

  def terminate(_reason, _req, state) do
    if state[:app_name] do
      Logger.info "[Socket <int>] Client #{state[:app_name]}##{state[:client_id]} disconnected"
      Storage.delete_client(state[:app_name], state[:client_id])
    end
    :ok
  end

  def websocket_handle({:text, data}, state) do
    {status, payload} = Builder.decode(data, state[:format], state[:compression])
    if status != :ok do
      Payload.no_u_tbh("Unable to decode payload", state)
    else
      Internal.handle_payload(payload, state)
    end
  end

  def websocket_handle(_, state), do:
    Payload.no_u_tbh("Invalid frame", state)

  def websocket_info(:zombie, state), do:
    Payload.no_u_tbh("Heartbeat timed out", state)
end
