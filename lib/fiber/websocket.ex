defmodule Fiber.Websocket do
  alias Fiber.Websocket.Payload

  def heartbeat_interval, do: 45000

  # We only need to access send opcodes by their name, and recv by their id
  def opcodes, do: %{
    :hello => 0,
    :welcome => 2,
    :goaway => 7,
    :no_u_tbh => 8,
    5 => :heartbeat
  }

  def init_connection(req, state) do
    query = URI.decode_query req[:qs]
    {
      :cowboy_websocket,
      req,
      state ++ [identified: false, format: query["format"] || "json", compression: query["compression"] || "noop"],
      %{
        # In theory we'll never hit this. It's just in case the custom heartbeat logic fails
        # to ensure we don't get dead connections flooding PIDs
        idle_timeout: heartbeat_interval + 25000
      }
    }
  end

  def init_socket (state) do
    new_state = heartbeat(state)
    Payload.hello(new_state)
  end

  def handle_payload(%{"op" => op, "d" => _}, state) do
    opcode = opcodes[op]
    if opcode != :identify && !state[:identified] do
      Payload.no_u_tbh("You must identify first", state)
      false
    else
      if opcode == :identify && state[:identified] do
        Payload.no_u_tbh("You're already authenticated", state)
        false
      else
        process_payload(op, state)
      end
    end
  end

  def handle_payload(_, state) do
    Payload.no_u_tbh("Invalid payload (structure)", state)
    false
  end

  def process_payload(op, state) do
    case opcodes[op] do
      :heartbeat ->
        handle_heartbeat state
        false
      _ ->
        true
    end
  end

  defp handle_heartbeat(state) do
    Process.cancel_timer(state[:timer])
    new_state = heartbeat(state)
    Payload.heartbeat_ack(new_state)
  end

  defp heartbeat (state) do
    new_state = Keyword.put(
      state,
      :timer,
      Process.send_after(
        self,
        :zombie,
        heartbeat_interval + 15000
      )
    )
    new_state
  end
end
