defmodule Streamer.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      %{id: Binance, start: {Streamer.Binance, :stream_tickers, []}},
      %{id: Kraken, start: {Streamer.Kraken, :stream_tickers, []}},
      {Phoenix.PubSub, name: Streamer.PubSub, adapter_name: Phoenix.PubSub.PG2}
    ]

    opts = [strategy: :one_for_one, name: Streamer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
