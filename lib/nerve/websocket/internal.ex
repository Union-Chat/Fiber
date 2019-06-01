defmodule Nerve.Websocket.Internal do
  alias Nerve.Storage
  alias Nerve.Websocket
  alias Nerve.Websocket.Payload
  require Logger

  # We only need to access send opcodes by their name, and recv by their id
  def opcodes, do: %{
    :dispatch => 8,
    1 => :identify,
    7 => :aboutme,
    8 => :dispatch
  }

  ################
  # Handle incoming payload
  ################
  def handle_payload(payload, state) do
    continue = Websocket.handle_payload(payload, state)
    if continue do
      process_payload(payload, state)
    end
  end

  defp process_payload(%{"op" => op, "d" => data} = payload, state) do
    case opcodes[op] do
      :identify -> handle_identify data, state
      :aboutme -> handle_aboutme payload, state
      :dispatch -> handle_dispatch payload, state
      _ -> Payload.no_u_tbh("Invalid OP code", state)
    end
  end

  ################
  # Handle payload
  ################
  defp handle_identify(%{"app_name" => name, "client_id" => id, "password" => auth} = data, state)
       when is_binary(name) and is_binary(id) and is_binary(auth) do
    if auth == Application.get_env(:nerve, :password) do
      if !Storage.client_exists?(name, id) or data["reconnect"] do
        Logger.info "[Socket <int>] New client connected: #{name}##{id}"
        Storage.insert_client(name, id)
        Payload.welcome(state ++ [app_name: name, client_id: id])
      else
        Payload.no_u_tbh("This application with that client is already logged in!", state)
      end
    else
      Payload.no_u_tbh("Invalid password", state)
    end
  end

  defp handle_aboutme(%{"d" => data}, state) do
    # data will be considered as the new metadata
    Storage.update_identity(state[:app_name], state[:client_id], data)
  end

  defp handle_dispatch(%{"d" => data, "e" => event}, state) do
    {:reply, {:text, "soon:tm:"}, state}
  end

  # Bad payloads
  defp handle_identify(_, state),
       do: Payload.no_u_tbh("Invalid payload (data)", state)

  defp handle_dispatch(_, state),
       do: Payload.no_u_tbh("Invalid payload (data)", state)
end
