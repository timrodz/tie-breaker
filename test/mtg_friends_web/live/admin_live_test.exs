defmodule MtgFriendsWeb.AdminLiveTest do
  use MtgFriendsWeb.ConnCase

  import Phoenix.LiveViewTest
  import MtgFriends.AccountsFixtures

  defp login_admin(%{conn: conn}) do
    admin_user = user_fixture(%{admin: true})
    %{conn: log_in_user(conn, admin_user), admin_user: admin_user}
  end

  describe "index" do
    setup :login_admin

    test "admin sees placeholder", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/admin")

      assert html =~ "Admin"
    end
  end

  test "non-admin is redirected", %{conn: conn} do
    non_admin_user = user_fixture()
    conn = log_in_user(conn, non_admin_user)

    assert {:error, {:redirect, %{to: "/users/log_in"}}} = live(conn, ~p"/admin")
  end
end
