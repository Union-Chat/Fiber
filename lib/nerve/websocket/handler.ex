defmodule Nerve.Websocket.Handler do
  @moduledoc """
  Websocket used to handle all incoming connections
  """

  alias Nerve.Cluster
  alias Nerve.Websocket
  alias Nerve.Websocket.Payload
  require Logger

  @behaviour :cowboy_websocket

  def init(req, state) do
    {:cowboy_websocket, req, state}
  end

  def terminate(_reason, _req, _state) do
    IO.inspect "terminate"
    :ok
  end

  def websocket_init(state), do: Payload.hello(state)

  def websocket_handle({:text, data}, state) do
    {status, payload} = Jason.decode(data)
    if status != :ok do
      Payload.no_u_tbh("Invalid JSON", state)
    else
      Websocket.handle_payload(payload, state)
    end
  end

  def websocket_handle(_, state), do: Payload.no_u_tbh("Invalid frame", state)

  # def websocket_info(:evt, state), do: {:reply, {:text, "aaa"}, state}
end
