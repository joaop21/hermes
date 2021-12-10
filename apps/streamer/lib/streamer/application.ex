defmodule Streamer.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      %{id: Binance, start: {Streamer.Binance, :stream_tickers, []}},
      %{id: Kraken, start: {Streamer.Kraken, :stream_tickers, []}}
    ]

    opts = [strategy: :one_for_one, name: Streamer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
