defmodule Nerve.Websocket.Payload do
  @moduledoc """
  Payload handler for Nerve
  """

  @doc """
  Creates a generic payload ready to be sent through the websocket

  ## Examples

      iex> Nerve.Websocket.Payload.create_payload(0, "meme")
      ~S|{"d":"meme","op":0}|

      iex> Nerve.Websocket.Payload.create_payload(0, %{:a => "b", :c => "d"})
      ~S|{"d":{"a":"b","c":"d"},"op":0}|
  """
  def create_payload(op, data) do
    json = %{
      :op => op,
      :d => data
    }

    Jason.encode!(json)
  end

  @doc """
  Creates a dispatch payload ready to be sent through the websocket

  ## Examples

      iex> Nerve.Websocket.Payload.create_payload(0, "meme", "EVENT")
      ~S|{"d":"meme","e":"EVENT","op":0}|
  """
  def create_payload(0, data, event) do
    json = %{
      :op => 0,
      :d => data,
      :e => event
    }

    Jason.encode!(json)
  end
end
