defmodule Streamer.Ticker do
  @type t :: {
    pair :: String.t(),
    bid_price :: String.t(),
    bid_quantity :: String.t(),
    ask_price :: String.t(),
    ask_quantity :: String.t(),
  }
  defstruct [
    :pair,
    :bid_price,
    :bid_quantity,
    :ask_price,
    :ask_quantity
  ]
end
