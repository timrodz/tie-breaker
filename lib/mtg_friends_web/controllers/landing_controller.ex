defmodule MtgFriendsWeb.LandingController do
  use MtgFriendsWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout(false)
    |> render(:index, page_title: "Home")
  end
end
