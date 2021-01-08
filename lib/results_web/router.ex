defmodule ResultsWeb.Router do
  use ResultsWeb, :router

  import ResultsWeb.UserAuth
  import Phoenix.LiveDashboard.Router

  alias ResultsWeb.EnsureRolePlug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ResultsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :user do
    plug EnsureRolePlug, [:admin, :user]
  end

  pipeline :admin do
    plug EnsureRolePlug, :admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ResultsWeb do
    pipe_through :api

    scope "/v1" do
      scope "/results" do
        resources("/", ResultController)
      end
    end
  end

  ## Authentication routes

  scope "/", ResultsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", ResultsWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    live "/", ResultLive.Index, :index
    live "/results/:id/edit", ResultLive.Index, :edit

    live "/results/:id", ResultLive.Show, :show
    live "/results/:id/show/edit", ResultLive.Show, :edit
  end

  scope "/", ResultsWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end

  scope "/", ResultsWeb do
    pipe_through [:browser, :require_authenticated_user, :admin]

    live_dashboard "/dashboard", metrics: ResultsWeb.Telemetry, ecto_repos: [Results.Repo]
  end
end
