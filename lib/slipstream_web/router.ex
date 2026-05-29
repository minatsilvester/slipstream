defmodule SlipstreamWeb.Router do
  use SlipstreamWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SlipstreamWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SlipstreamWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/admin", SlipstreamWeb do
    pipe_through :browser

    live "/series", SeriesLive.Index, :index
    live "/series/new", SeriesLive.Form, :new
    live "/series/:id", SeriesLive.Show, :show
    live "/series/:id/edit", SeriesLive.Form, :edit
    live "/series/:series_id/seasons", SeriesSeasonLive.Index, :index
    live "/series/:series_id/seasons/new", SeriesSeasonLive.Form, :new
    live "/series/:series_id/seasons/:id", SeriesSeasonLive.Show, :show
    live "/series/:series_id/seasons/:id/edit", SeriesSeasonLive.Form, :edit
    live "/series/:series_id/seasons/:season_id/events", SeriesSeasonEventLive.Index, :index
    live "/series/:series_id/seasons/:season_id/events/new", SeriesSeasonEventLive.Form, :new
    live "/series/:series_id/seasons/:season_id/events/:id", SeriesSeasonEventLive.Show, :show

    live "/series/:series_id/seasons/:season_id/events/:id/edit",
         SeriesSeasonEventLive.Form,
         :edit

    live "/series/:series_id/sources", SeriesSourceLive.Index, :index
    live "/series/:series_id/sources/new", SeriesSourceLive.Form, :new
    live "/series/:series_id/sources/:id", SeriesSourceLive.Show, :show
    live "/series/:series_id/sources/:id/edit", SeriesSourceLive.Form, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", SlipstreamWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:slipstream, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SlipstreamWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
