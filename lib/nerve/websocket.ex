defmodule Nerve.Websocket do
  alias Nerve.Websocket.Payload

  require Logger

  def heartbeat_interval, do: 45000

  # We only need to access send opcodes by their name, and recv by their id
  def opcodes, do: %{
    :hello => 0,
    :welcome => 2,
    :dispatch => 4,
    :heartbeat_ack => 6,
    :goaway => 7,
    :no_u_tbh => 8,

    1 => :identify,
    3 => :aboutme,
    4 => :dispatch,
    5 => :heartbeat
  }

  ################
  # Handle incoming payload
  ################
  def handle_payload(%{"op" => op, "d" => data} = payload, state) do
    opcode = opcodes[op]
    if opcode != :identify && !state[:identified] do
      Payload.no_u_tbh("You must identify first", state)
    else
      if opcode == :identify && state[:identified] do
        Payload.no_u_tbh("You're already authenticated", state)
      else
        process_payload(payload, state)
      end
    end
  end

  def handle_payload(_, state),
      do: Payload.no_u_tbh("Invalid payload", state)

  defp process_payload(%{"op" => op, "d" => data} = payload, state) do
    case opcodes[op] do
      :identify -> handle_identify payload, state
      :aboutme -> handle_aboutme payload, state
      :heartbeat -> handle_heartbeat payload, state
      :dispatch -> handle_dispatch payload, state
      _ -> Payload.no_u_tbh("Invalid OP code", state)
    end
  end


  ################
  # Handle payload
  ################
  defp handle_identify(%{"d" => %{"app_name" => name, "client_id" => id, "password" => auth} = data}, state) do
    IO.inspect name
    IO.inspect id
    IO.inspect auth
    {:reply, {:text, "soon:tm:"}, state}
  end

  defp handle_aboutme(%{"d" => data}, state) do
    {:reply, {:text, "soon:tm:"}, state}
  end

  defp handle_heartbeat(_, state) do
    {:reply, {:text, "soon:tm:"}, state}
  end

  defp handle_dispatch(%{"d" => data, "e" => event}, state) do
    {:reply, {:text, "soon:tm:"}, state}
  end

  defp handle_identify(_, state),
       do: Payload.no_u_tbh("Invalid payload", state)

  defp handle_dispatch(_, state),
       do: Payload.no_u_tbh("Invalid payload", state)
end
