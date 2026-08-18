defmodule MtgFriendsWeb.FaqControllerTest do
  use MtgFriendsWeb.ConnCase

  test "GET /faq", %{conn: conn} do
    conn = get(conn, ~p"/faq")
    assert html_response(conn, 200) =~ "Frequently Asked Questions"
  end
end
