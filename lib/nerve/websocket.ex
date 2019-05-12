defmodule Nerve.Websocket do
  @moduledoc """
  Websocket used to handle all incoming connections
  """

  @behaviour :cowboy_websocket
  require Logger

  def init(req, state) do
    {:cowboy_websocket, req, state}
  end

  def websocket_info(info, state) do
    IO.inspect info
    {:ok, state}
  end

  def websocket_handle({:text, content}, state) do
    IO.inspect content
    {:ok, state}
  end
end
