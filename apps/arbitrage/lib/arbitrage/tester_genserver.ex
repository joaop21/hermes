defmodule Arbitrage.TesterGenServer do
  use GenServer

  require Logger

  alias Streamer.Ticker

  def start_link(state), do: GenServer.start_link(__MODULE__, state)

  def init(state) do
    Logger.info("Initializing new Tester for symbol(#{state})")

    Phoenix.PubSub.subscribe(Streamer.PubSub, "Tickers:#{state}")

    {:ok, state}
  end

  def handle_info(%Ticker{} = ticker, state) do
    IO.inspect(ticker)
    {:noreply, state}
  end

end
