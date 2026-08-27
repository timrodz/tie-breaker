defmodule MtgFriendsWeb.AboutControllerTest do
  use MtgFriendsWeb.ConnCase

  test "GET /about", %{conn: conn} do
    conn = get(conn, ~p"/about")

    assert html_response(conn, 200) =~
             "Tie Breaker is a tournament management app for Magic: The Gathering."
  end
end
