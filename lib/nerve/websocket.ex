defmodule Nerve.Websocket do
  alias Nerve.Websocket.Payload

  require Logger

  def heartbeat_interval, do: 1
  def opcodes_name, do: %{
    :hello => 0,
    :identify => 1,
    :welcome => 2,
    :aboutme => 3,
    :dispatch => 4,
    :heartbeat => 5,
    :heartbeat_ack => 6,
    :goaway => 7
  }

  def handle_payload(data) do
    IO.inspect(data)
    payload = Payload.decode_payload!(data)
  end
end
