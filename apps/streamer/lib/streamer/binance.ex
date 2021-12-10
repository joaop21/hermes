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
      {:ok, json} -> process_ticker(json)
      {:error, _} -> Logger.error("Unable to parse msg: #{msg}")
    end
    {:ok, state}
  end

  @spec process_ticker(json :: map()) :: Ticker.__struct__
  defp process_ticker(json) do
    json
    |> build()
    |> publish()
  end

  @spec build(json :: map()) :: Ticker.__struct__
  defp build(json) do
    %Ticker{
      :pair => json["s"],
      :bid_price => json["b"],
      :bid_quantity => json["B"],
      :ask_price => json["a"],
      :ask_quantity => json["A"],
      :exchanger => "Binance"
    }
  end

  @spec publish(ticker :: Ticker.__struct__) :: :ok | {:error, term()}
  defp publish(%Ticker{pair: pair} = ticker) do
    Phoenix.PubSub.broadcast(
      Streamer.PubSub,
      "Tickers:#{pair}",
      ticker
    )
  end

end
