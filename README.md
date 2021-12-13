# Hermes

Hermes is a bot for cryptocurrency arbitrage written in Elixir.

__Note: Hermes is the god of trade__ 😄

## System Context

Hermes is recent and evolving. This diagram only shows what the system looks like at this point and will evolve with new features.

![System Context](https://user-images.githubusercontent.com/36553777/145845150-d0387be9-0722-4b60-bdb0-7cedb863d5fc.png)

Hermes is an umbrella app that has some supervised apps.
- __Streamer:__ Contains Processes that communicate via Websockets with some exchanges and broadcast tickers information to a PubSub system.
- __Arbitrage:__ Contains Processes that receive events from the PubSub system and try to find arbitrage opportunities.

**PS: For more info about the supervised apps, navigate to its directory!**
