defmodule MtgFriendsWeb.HelloController do
  use MtgFriendsWeb, :controller

  def index(conn, _params) do
    text(conn, "Hello World")
  end
end
