defmodule MtgFriendsWeb.HelloControllerTest do
  use MtgFriendsWeb.ConnCase

  test "GET /hello", %{conn: conn} do
    conn = get(conn, ~p"/hello")
    assert text_response(conn, 200) =~ "Hello World"
  end
end
