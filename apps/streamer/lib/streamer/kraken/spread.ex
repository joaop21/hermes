defmodule Streamer.Kraken.Spread do
  @type t :: {
    pair :: String.t(),
    bid_price :: String.t(),
    bid_volume :: String.t(),
    ask_price :: String.t(),
    ask_volume :: String.t(),
    timestamp :: String.t()
  }
  defstruct [
    :pair,
    :bid_price,
    :bid_volume,
    :ask_price,
    :ask_volume,
    :timestamp
  ]
end
