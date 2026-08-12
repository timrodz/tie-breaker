defmodule MtgFriendsWeb.HelloController do
  use MtgFriendsWeb, :controller

  def index(conn, _params) do
    render(conn, :index, page_title: "Hello World")
  end
end
