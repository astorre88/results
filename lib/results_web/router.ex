defmodule ResultsWeb.Router do
  use ResultsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ResultsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ResultsWeb do
    pipe_through :browser

    live "/", PageLive, :index

    live "/results", ResultLive.Index, :index
    live "/results/new", ResultLive.Index, :new
    live "/results/:id/edit", ResultLive.Index, :edit

    live "/results/:id", ResultLive.Show, :show
    live "/results/:id/show/edit", ResultLive.Show, :edit
  end

  scope "/api", ResultsWeb do
    pipe_through :api

    scope "/v1" do
      scope "/results" do
        resources("/", ResultController)
      end
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ResultsWeb.Telemetry
    end
  end
end