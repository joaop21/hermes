defmodule Streamer.Kraken do
  use WebSockex

  require Logger

  alias Streamer.Ticker

  @base_endpoint "wss://ws.kraken.com"

  ############################## Interface ##############################

  @spec stream_tickers() :: {:ok, pid()} | {:error, term()}
  def stream_tickers do
    @base_endpoint
    |> start_link()
    |> (&(
      case &1 do
        {:ok, pid} ->
          subscribe_spread(pid)
          {:ok, pid}

        rest -> rest
      end
    )).()
  end

  @spec start_link(url :: String.t()) :: {:ok, pid()} | {:error, term()}
  defp start_link(url), do: WebSockex.start_link(url, __MODULE__, nil, name: :"#{__MODULE__}")

  @spec subscribe_spread(pid()) :: :ok | {:error, String.t()} | node()
  defp subscribe_spread(pid) do
    create_subscription()
    |> Jason.encode()
    |> (&(
      case &1 do
        {:ok, jason} -> WebSockex.send_frame(pid, {:text, jason})
        {:error, _error} -> Logger.error("Unable to parse subscription: #{&1}")
      end
    )).()
  end

  @spec create_subscription() :: map()
  defp create_subscription do
    %{
      :event => "subscribe",
      :pair => fetch_pairs(),
      :subscription => %{:name => "spread"}
    }
  end

  @spec fetch_pairs() :: [String.t()]
  defp fetch_pairs do
    Krakex.asset_pairs()
    |> elem(1)
    |> Enum.map(fn {_key, value} -> value["wsname"] end)
  end

  ############################## WebSockex callback implementation ##############################

  def handle_frame({_type, msg}, state) do
    case Jason.decode(msg) do
      {:ok, [_channel_id | _tail] = json} -> process_ticker(json)
      {:ok, %{"connectionID" => _conn}} -> Logger.info("Kraken - Connection established!")
      {:error, _} -> Logger.error("Unable to parse msg: #{msg}")
      _ -> :ok
    end
    {:ok, state}
  end

  @spec process_ticker([String.t()]) :: Ticker.__struct__
  defp process_ticker(json) do
    json
    |> build()
    |> publish()
  end

  @spec build([String.t()]) :: Ticker.__struct__
  defp build(json) do
    %Ticker{
      :pair => json |> Enum.at(3),
      :bid_price => json |> Enum.at(1) |> Enum.at(0),
      :bid_quantity => json |> Enum.at(1) |> Enum.at(3),
      :ask_price => json |> Enum.at(1) |> Enum.at(1),
      :ask_quantity => json |> Enum.at(1) |> Enum.at(4),
      :exchanger => "Kraken"
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
