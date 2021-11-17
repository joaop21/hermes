defmodule Streamer.Binance.Ticker do
  @type t :: {
    order_book_update_id :: non_neg_integer(),
    symbol :: String.t(),
    bid_price :: String.t(),
    bid_quantity :: String.t(),
    ask_price :: String.t(),
    ask_quantity :: String.t(),
  }
  defstruct [
    :order_book_update_id,
    :symbol,
    :bid_price,
    :bid_quantity,
    :ask_price,
    :ask_quantity
  ]
end
