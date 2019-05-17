defmodule Nerve.Websocket.Payload do
  @moduledoc """
  Payload handler for Nerve
  """

  alias Nerve.Websocket
  alias Nerve.Cluster

  def hello(state) do
    {:ok, payload} = encode_payload(
      Websocket.opcodes_send[:hello],
      %{
        :heartbeat_interval => Websocket.heartbeat_interval,
        :worker => "nerve-#{state[:hash]}"
      }
    )

    {:reply, {:text, payload}, state}
  end

  def no_u_tbh(error, state) do
    {:ok, payload} = encode_payload(
      Websocket.opcodes_send[:no_u_tbh],
      error
    )

    {
      :reply,
      [
        {:text, payload},
        {:close, 4400, error}
      ],
      state
    }
  end

  @doc """
  Creates a generic payload ready to be sent through the websocket

  ## Examples

      iex> Nerve.Websocket.Payload.encode_payload(1, "meme")
      ~S|{"d":"meme","op":1}|

      iex> Nerve.Websocket.Payload.encode_payload(0, %{:a => "b", :c => "d"})
      ~S|{"d":{"a":"b","c":"d"},"op":0}|
  """
  def encode_payload(op, data) do
    encode_payload(op, data, nil)
  end

  @doc """
  Creates a dispatch payload ready to be sent through the websocket. "e" key is only appended if event is not nil

  ## Examples

      iex> Nerve.Websocket.Payload.encode_payload(1, "meme", nil)
      ~S|{"d":"meme","op":1}|

      iex> Nerve.Websocket.Payload.encode_payload(0, %{:a => "b", :c => "d"}, nil)
      ~S|{"d":{"a":"b","c":"d"},"op":0}|

      iex> Nerve.Websocket.Payload.encode_payload(0, "meme", "EVENT")
      ~S|{"d":"meme","e":"EVENT","op":0}|
  """
  def encode_payload(op, data, event) do
    json = if event != nil do
      %{:op => op, :d => data, :e => event}
    else
      %{:op => op, :d => data}
    end

    Jason.encode(json)
  end
end
