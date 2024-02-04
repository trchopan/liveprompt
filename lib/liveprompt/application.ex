defmodule Liveprompt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LivepromptWeb.Telemetry,
      Liveprompt.Repo,
      {DNSCluster, query: Application.get_env(:liveprompt, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Liveprompt.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Liveprompt.Finch},
      # Start a worker by calling: Liveprompt.Worker.start_link(arg)
      # {Liveprompt.Worker, arg},
      # Start to serve requests, typically the last entry
      LivepromptWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Liveprompt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LivepromptWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
