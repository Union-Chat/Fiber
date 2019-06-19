defmodule Fiber.Websocket.Payload do
  @moduledoc """
  Payload handler for Fiber
  """

  alias Fiber.Websocket
  alias Fiber.Websocket.Payload.Builder

  def hello(state) do
    payload = encode_payload(
      Websocket.opcodes[:hello],
      %{
        :heartbeat_interval => Websocket.heartbeat_interval,
        :worker => "fiber-#{String.slice(state[:hash], 0, 6)}"
      },
      state
    )

    {:reply, payload, state}
  end

  def welcome(state) do
    payload = encode_payload(Websocket.opcodes[:welcome], "hi i'm dad", state)
    {:reply, payload, state}
  end

  def heartbeat_ack(state) do
    payload = encode_payload(Websocket.opcodes[:heartbeat_ack], "i heard u", state)
    {:reply, payload, state}
  end

  def no_u_tbh(error, state) do
    payload = encode_payload(Websocket.opcodes[:no_u_tbh], error, state)
    {:reply, [payload, {:close, 4400, error}], state}
  end

  def encode_payload(op, data, state) do
    encode_payload(op, data, nil, state)
  end

  def encode_payload(op, data, event, state) do
    payload = if event != nil do
      %{:op => op, :d => data, :e => event}
    else
      %{:op => op, :d => data}
    end

    Builder.encode(payload, state[:format], state[:compression])
  end
end
