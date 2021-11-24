defmodule Streamer do

  @spec start_streaming :: :ok
  def start_streaming do
    Streamer.Binance.stream_tickers()
    Streamer.Kraken.stream_tickers()
  end

end
