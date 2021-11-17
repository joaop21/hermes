defmodule Streamer do

  def start_streaming, do: Streamer.Binance.stream_tickers

end
