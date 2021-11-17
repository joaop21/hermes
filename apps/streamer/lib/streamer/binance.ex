defmodule Streamer.Binance do
  use WebSockex

  require Logger

  alias Streamer.Binance.TradeEvent

  @base_endpoint "wss://stream.binance.com:9443/stream?streams="

  @spec start() :: :ok
  def start do
    get_symbols()
    |> separate_symbols()
    |> Enum.each(&start_link/1)
  end

  def handle_frame({_type, msg}, state) do
    case Jason.decode(msg) do
      {:ok, event} -> process_event(event)
      {:error, _} -> Logger.error("Unable to parse msg: #{msg}")
    end
    {:ok, state}
  end

  @spec start_link([String.t()]) :: {:ok, pid()} | {:error, term()}
  defp start_link(symbols) do
    symbols
    |> Enum.map(&String.downcase/1)
    |> Enum.map(&(Kernel.<>(&1, "@trade")))
    |> Enum.join("/")
    |> (&(@base_endpoint <> &1)).()
    |> WebSockex.start_link(__MODULE__, nil)
  end

  @spec get_symbols() :: [String.t()]
  defp get_symbols do
    Binance.get_exchange_info()
    |> elem(1)
    |> Map.get(:symbols)
    |> Enum.map(&(&1["symbol"]))
  end

  @spec separate_symbols([String.t()]) :: [String.t()]
  defp separate_symbols(symbols) do
    symbols
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {element, index}, acc ->
      position = div(index, 1024)
      Map.get(acc, position, [])
      |> Kernel.++([element])
      |> (&(Map.put(acc, position, &1))).()
    end)
    |> Map.values()
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
