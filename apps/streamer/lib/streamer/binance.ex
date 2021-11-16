defmodule Streamer.Binance do
  use WebSockex

  require Logger

  alias Streamer.Binance.TradeEvent

  @base_endpoint "wss://stream.binance.com:9443/stream?streams="

  def start_link(symbols) do
    symbols
    |> Enum.map(&String.downcase/1)
    |> Enum.map(&(Kernel.<>(&1, "@trade")))
    |> Enum.join("/")
    |> (&(@base_endpoint <> &1)).()
    |> WebSockex.start_link(__MODULE__, nil)
  end

  def handle_frame({_type, msg}, state) do
    case Jason.decode(msg) do
      {:ok, event} -> process_event(event)
      {:error, _} -> Logger.error("Unable to parse msg: #{msg}")
    end
    {:ok, state}
  end

  defp process_event(%{"data" => %{"e" => "trade"} = event}) do
    trade_event = %TradeEvent{
      :event_type => event["e"],
      :event_time => event["E"],
      :symbol => event["s"],
      :trade_id => event["t"],
      :price => event["p"],
      :quantity => event["q"],
      :buyer_order_id => event["b"],
      :seller_order_id => event["a"],
      :trade_time => event["T"],
      :buyer_market_maker => event["m"]
    }
    Logger.info("Trade event received " <> "#{trade_event.symbol}@#{trade_event.price}")
  end

end
