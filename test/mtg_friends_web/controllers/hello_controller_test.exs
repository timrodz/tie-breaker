defmodule MtgFriendsWeb.HelloControllerTest do
  use MtgFriendsWeb.ConnCase

  test "GET /hello", %{conn: conn} do
    conn = get(conn, ~p"/hello")
    assert html_response(conn, 200) =~ "Hello World"
  end
end
