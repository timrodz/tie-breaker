defmodule MtgFriendsWeb.Router do
  use MtgFriendsWeb, :router
  alias OpenApiSpex

  import MtgFriendsWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MtgFriendsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: MtgFriendsWeb.ApiSpec
    plug :rate_limit
  end

  pipeline :api_authenticated do
    plug MtgFriendsWeb.APIAuthPlug
  end

  pipeline :authorize_tournament_owner do
    plug MtgFriendsWeb.Plugs.AuthorizeTournamentOwner
  end

  scope "/", MtgFriendsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{MtgFriendsWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", MtgFriendsWeb do
    pipe_through :browser

    get "/", LandingController, :index

    live_session :tournaments_current_user,
      on_mount: [{MtgFriendsWeb.UserAuth, :mount_current_user}] do
      # Piping :require_authenticated_user in individual scopes
      # Makes the live views and components protected

      scope "/tournaments" do
        live "/", TournamentLive.Index, :index

        scope "/new" do
          pipe_through :require_authenticated_user

          live "/", TournamentLive.Index, :new
        end

        scope "/:id" do
          live "/", TournamentLive.Show, :show

          pipe_through :require_authenticated_user
          live "/edit", TournamentLive.Index, :edit
          live "/show/edit", TournamentLive.Show, :edit
        end

        scope "/:tournament_id/rounds/:round_number" do
          live "/", TournamentLive.Round, :index

          pipe_through :require_authenticated_user
          live "/pairing/:pairing_number/edit", TournamentLive.Round, :edit
        end
      end
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:mtg_friends, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MtgFriendsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", MtgFriendsWeb do
    pipe_through [:browser]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{MtgFriendsWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end

    delete "/users/log_out", UserSessionController, :delete
    post "/users/log_in", UserSessionController, :create
  end

  scope "/admin", MtgFriendsWeb do
    pipe_through [:browser, :require_admin_user]

    live_session :admin_current_user,
      on_mount: [{MtgFriendsWeb.UserAuth, :mount_current_user}] do
      live "/", AdminLive.Index

      live "/games", GameLive.Index, :index
      live "/games/new", GameLive.Index, :new
      live "/games/:id/edit", GameLive.Index, :edit

      live "/games/:id", GameLive.Show, :show
      live "/games/:id/show/edit", GameLive.Show, :edit
    end
  end

  defp rate_limit(conn, _opts) do
    if Application.get_env(:mtg_friends, :disable_rate_limit) do
      conn
    else
      ip_string = conn.remote_ip |> :inet.ntoa() |> to_string()

      case MtgFriendsWeb.RateLimit.hit("api:#{ip_string}", 60_000, 60) do
        {:allow, _count} ->
          conn

        {:deny, _limit} ->
          conn
          |> put_status(:too_many_requests)
          |> put_resp_content_type("application/json")
          |> send_resp(429, Jason.encode!(%{error: "Rate limit exceeded"}))
          |> halt()
      end
    end
  end
end
