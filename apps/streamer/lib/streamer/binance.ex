defmodule Streamer.Binance do
  use WebSockex

  require Logger

  alias Streamer.Ticker

  @base_endpoint "wss://stream.binance.com:9443"

  ############################## Interface ##############################

  @spec stream_tickers() :: {:ok, pid()} | {:error, term()}
  def stream_tickers, do: @base_endpoint <> "/ws/!bookTicker" |> start_link()

  @spec start_link(url :: String.t()) :: {:ok, pid()} | {:error, term()}
  defp start_link(url), do: WebSockex.start_link(url, __MODULE__, nil, name: :"#{__MODULE__}")

  ############################## WebSockex callback implementation ##############################

  def handle_frame({_type, msg}, state) do
    case Jason.decode(msg) do
      {:ok, ticker} -> process_ticker(ticker)
      {:error, _} -> Logger.error("Unable to parse msg: #{msg}")
    end
    {:ok, state}
  end

  @spec process_ticker(ticker :: map()) :: Ticker.ticker()
  defp process_ticker(ticker) do
    %Ticker{
      :pair => ticker["s"],
      :bid_price => ticker["b"],
      :bid_quantity => ticker["B"],
      :ask_price => ticker["a"],
      :ask_quantity => ticker["A"]
    }
  end

end
