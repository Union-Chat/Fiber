defmodule Nerve.Websocket do
  alias Nerve.Websocket.Payload

  require Logger

  def heartbeat_interval, do: 2000

  # We only map those that we send
  def opcodes_send, do: %{
    :hello => 0,
    :welcome => 2,
    :dispatch => 4,
    :heartbeat_ack => 6,
    :goaway => 7,
    :no_u_tbh => 8
  }

  # We only map those that we receive
  def opcodes_recv, do: %{
    1 => :identify,
    3 => :aboutme,
    4 => :dispatch,
    5 => :heartbeat
  }

  def handle_payload(%{"op" => op, "d" => data} = payload, state) do
    opcode = opcodes_recv[op]
    IO.inspect opcode
    IO.inspect data
    case opcode do
      _ -> Payload.no_u_tbh("Invalid OP code", state)
    end
  end

  def handle_payload(_, state), do: Payload.no_u_tbh("Invalid payload", state)
end
