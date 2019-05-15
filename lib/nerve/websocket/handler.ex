defmodule Nerve.Websocket.Handler do
  @moduledoc """
  Websocket used to handle all incoming connections
  """

  alias Nerve.Websocket
  alias Nerve.Websocket.Payload

  require Logger

  @behaviour :cowboy_websocket

  def init(req, state) do
    IO.inspect req
    {:cowboy_websocket, req, state}
  end

  def terminate(_reason, _req, _state) do
    IO.inspect "terminate"
    :ok
  end

  def websocket_init(state) do
    {:ok, payload} = Payload.encode_payload(1, %{:heartbeat_interval => 600, :worker => "nerve-meme"})
    {:reply, {:text, payload}, state}
  end

  def websocket_info(info, state) do
    IO.inspect "info"
    IO.inspect info
    {:ok, state}
  end

  def websocket_handle({opcode, payload}, state) do
    IO.inspect state
    try do
      case opcode do
        :text -> Websocket.handle_payload(payload)
      end
      {:ok, state}
    rescue
      e -> {:stop, 4000}
    end
  end
end
