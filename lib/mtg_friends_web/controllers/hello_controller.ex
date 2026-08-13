defmodule MtgFriendsWeb.HelloController do
  use MtgFriendsWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
