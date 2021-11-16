defmodule Streamer do

  def start_streaming do
    Streamer.Binance.start_link(["BTCEUR","ETHEUR"])
  end

end
