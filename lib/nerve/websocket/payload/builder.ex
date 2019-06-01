defmodule Nerve.Websocket.Payload.Builder do
  def encode(payload, format, compression) do
    # encoded =
    encode_paylaod(payload, format)
    # compress_payload(encoded, compression)
  end

  def decode(payload, format, compression) do
    # decompressed = decompress_payload(payload, compression)
    decode_paylaod(payload, format)
  end

  ################
  # Payload encoding
  ################
  defp encode_paylaod(payload, format) do
    case format do
      "etf" ->
        encoded = :erlang.term_to_binary payload
        {:binary, encoded}
      "msgpack" ->
        {:ok, encoded} = Msgpax.pack payload
        {:binary, encoded}
      _ ->
        {:ok, encoded} = Jason.encode payload
        {:text, encoded}
    end
  end

  defp decode_paylaod(payload, format) do
    # we have to be more careful while decoding as data comes from untrusted sources (aka users)
    case format do
      "etf" ->
        # decode in safe mode to prevent DoS attacks. See http://erlang.org/doc/man/erlang.html#binary_to_term-1
        try do
          decoded = :erlang.binary_to_term payload, [:safe]
          {:ok, decoded}
        rescue
          _ -> {:error, nil}
        end
      "msgpack" ->
        {state, decoded} = Msgpax.unpack payload
        case state do
          :ok -> {:ok, decoded}
          :error -> {:error, nil}
        end
      _ ->
        {state, decoded} = Jason.decode payload
        case state do
          :ok -> {:ok, decoded}
          :error -> {:error, nil}
        end
    end
  end
end
