defmodule Streamer do

  def start_streaming do
    #Streamer.Binance.stream_tickers
    Streamer.Kraken.stream_spread
  end

end
