defmodule MtgFriendsWeb.ContactControllerTest do
  use MtgFriendsWeb.ConnCase

  test "GET /contact", %{conn: conn} do
    conn = get(conn, ~p"/contact")
    assert html_response(conn, 200) =~ "contact@tiebreaker.app"
  end
end
