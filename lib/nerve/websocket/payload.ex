defmodule Nerve.Websocket.Payload do
  @moduledoc """
  Payload handler for Nerve
  """

  @doc """
  Creates a generic payload ready to be sent through the websocket

  ## Examples

      iex> Nerve.Websocket.Payload.encode_payload(0, "meme")
      ~S|{"d":"meme","op":0}|

      iex> Nerve.Websocket.Payload.encode_payload(0, %{:a => "b", :c => "d"})
      ~S|{"d":{"a":"b","c":"d"},"op":0}|
  """
  def encode_payload(op, data) do
    encode_payload(0, data, nil)
  end

  @doc """
  Creates a dispatch payload ready to be sent through the websocket. "e" key is only appended if event is not nil

  ## Examples

      iex> Nerve.Websocket.Payload.encode_payload(0, "meme", nil)
      ~S|{"d":"meme","op":0}|

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

  @doc """
  Similar to encode_payload/2, except it will unwrap the error tuple and raise in case of errors
  """
  def encode_payload!(op, data) do
    encode_payload!(op, data, nil)
  end

  @doc """
  Similar to encode_payload/3, except it will unwrap the error tuple and raise in case of errors
  """
  def encode_payload!(op, data, event) do
    case encode_payload(op, data, event) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end


  @doc """
  Decodes a payload and validates if the payload is valid or not

  ## Examples

      iex> Nerve.Websocket.Payload.decode_payload("{\\"d\\":\\"meme\\",\\"e\\":\\"EVENT\\",\\"op\\":0}")
      {:ok, %{"d" => "meme", "e" => "EVENT", "op" => 0}}

      iex> Nerve.Websocket.Payload.decode_payload("{\\"d\\":\\"meme\\",\\"e\\":\\"EVENT\\",\\"op:0}")
      {:error, :invalid_syntax}

      # iex> Nerve.Websocket.Payload.decode_payload("{\\"d\\":\\"meme\\",\\"e\\":\\"EVENT\\"}")
      # {:error, :invalid_struct}
  """
  def decode_payload(payload) do
    case Jason.decode(payload) do
      # todo: validate
      {:ok, json} -> {:ok, json}
      {:error, error} -> {:error, :invalid_syntax}
    end
  end

  @doc """
  Similar to decode_payload/1, except it will unwrap the error tuple and raise in case of errors
  """
  def decode_payload!(payload) do
    case decode_payload(payload) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end
end
