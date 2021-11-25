defprotocol Streamer.TickersProducer do
  @spec process_ticker(any()) :: Streamer.Ticker.ticker()
  def process_ticker(ticker)
end
