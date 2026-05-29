defmodule Slipstream.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SlipstreamWeb.Telemetry,
      Slipstream.Repo,
      {DNSCluster, query: Application.get_env(:slipstream, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Slipstream.PubSub},
      {Registry, keys: :unique, name: Slipstream.Ingestion.Registry},
      {DynamicSupervisor, name: Slipstream.Ingestion.Supervisor, strategy: :one_for_one},
      # Start a worker by calling: Slipstream.Worker.start_link(arg)
      # {Slipstream.Worker, arg},
      # Start to serve requests, typically the last entry
      SlipstreamWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Slipstream.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SlipstreamWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
