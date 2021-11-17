defmodule Streamer.Kraken do
  use WebSockex

  require Logger

  @base_endpoint "wss://ws.kraken.com"

  ############################## Interface ##############################

  @spec stream_spread() :: {:ok, pid()} | {:error, term()}
  def stream_spread do
    @base_endpoint
    |> start_link()
    |> elem(1)
    |> subscribe_spread()
  end

  @spec start_link(url :: String.t()) :: {:ok, pid()} | {:error, term()}
  defp start_link(url), do: WebSockex.start_link(url, __MODULE__, nil)

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

  def handle_frame(msg, state) do
    IO.inspect(msg)
    {:ok, state}
  end

end
