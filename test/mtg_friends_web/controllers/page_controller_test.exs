defmodule MtgFriendsWeb.LandingControllerTest do
  use MtgFriendsWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Hello World"
  end
end
