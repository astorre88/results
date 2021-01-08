defmodule Results.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Results.Repo,
      # Start the Telemetry supervisor
      ResultsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Results.PubSub},
      # Start the Endpoint (http/https)
      ResultsWeb.Endpoint
    ]

    children =
      if Application.get_env(:results, :start_worker),
        do: children ++ [{Results.Worker, [name: Results.Worker]}],
        else: children

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Results.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ResultsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
