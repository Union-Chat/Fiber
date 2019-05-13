defmodule Nerve.Websocket do
  @moduledoc """
  Websocket used to handle all incoming connections
  """

  @behaviour :cowboy_websocket
  require Nerve.Websocket.Payload
  require Logger

  def init(req, state) do
    {:cowboy_websocket, req, state}
  end

  def terminate(_reason, _req, _state) do
    IO.inspect "terminate"
    :ok
  end

  def websocket_init(state) do
    {
      :reply,
      {
        :text,
        Nerve.Websocket.Payload.create_payload(
          1,
          %{
            :heartbeat_interval => 600,
            :worker => "nerve-meme"
          }
        )
      },
      state
    }
  end

  def websocket_info(info, state) do
    IO.inspect "info"
    IO.inspect info
    {:ok, state}
  end

  def websocket_handle(meme, state) do
    IO.inspect "handle"
    IO.inspect meme
    {:ok, state}
  end
end
