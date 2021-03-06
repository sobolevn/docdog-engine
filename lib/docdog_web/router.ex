defmodule DocdogWeb.Router do
  use DocdogWeb, :router

  pipeline :browser do
    plug(:accepts, ["html", "md"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(DocdogWeb.CurrentUserPlug)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(DocdogWeb.CurrentUserPlug)
  end

  pipeline :workplace_layout do
    plug(:put_layout, {DocdogWeb.LayoutView, :workplace})
  end

  # TODO: Uncomment after adding simple page
  # pipeline :simple_layout do
  #   plug(:put_layout, {DocdogWeb.LayoutView, :simple})
  # end

  scope "/", DocdogWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/workplace", DocdogWeb do
    pipe_through([:browser, :workplace_layout])

    resources("/popular", PopularController, only: [:index])

    resources "/projects", ProjectController, except: [:show] do
      resources("/documents", DocumentController, except: [:update])
    end

    scope "/projects" do
      get("/invites/:invite_code", ProjectInviteController, :show)
      post("/invites", ProjectInviteController, :create)
    end
  end

  scope "/api/v1", DocdogWeb do
    pipe_through(:api)

    resources "/documents", DocumentController, only: [] do
      resources("/lines", LineController, only: [:index])
    end

    resources("/lines", LineController, only: [:update])
  end

  scope "/auth", DocdogWeb do
    pipe_through(:browser)

    get("/sign_in", AuthController, :new)
    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
    post("/:provider/callback", AuthController, :callback)
    delete("/logout", AuthController, :delete)
  end
end
