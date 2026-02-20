defmodule MtgFriendsWeb.TournamentLiveTest do
  use MtgFriendsWeb.ConnCase

  import Phoenix.LiveViewTest
  import MtgFriends.TournamentsFixtures
  import MtgFriends.AccountsFixtures
  import MtgFriends.ParticipantsFixtures

  alias MtgFriends.Rounds
  alias MtgFriends.Tournaments

  # @create_attrs %{
  #   name: "Test Tournament Name",
  #   location: "Test Location Here",
  #   date: ~N[2023-11-02 00:00:00],
  #   description_raw: "This is a test tournament description for testing purposes",
  #   initial_participants: "Player 1\nPlayer 2\nPlayer 3\nPlayer 4"
  # }
  @update_attrs %{
    name: "Updated Tournament Name",
    location: "Updated Location Here",
    date: ~N[2023-11-03 00:00:00],
    description_raw: "This is an updated test tournament description"
  }
  @invalid_attrs %{name: nil, location: nil, date: nil, description_raw: nil}

  defp create_tournament(_) do
    tournament = tournament_fixture()
    %{tournament: tournament}
  end

  describe "Index" do
    setup [:create_tournament]

    test "lists all tournaments", %{conn: conn, tournament: tournament} do
      {:ok, _index_live, html} = live(conn, ~p"/tournaments")

      assert html =~ "Discover your new battleground"
      assert html =~ tournament.location
    end

    test "saves new tournament" do
      user = user_fixture()
      conn = log_in_user(build_conn(), user)

      {:ok, index_live, _html} = live(conn, ~p"/tournaments")

      index_live |> element("a", "Create Tournament") |> render_click()

      assert_patch(index_live, ~p"/tournaments/new")
    end

    test "updates tournament through modal" do
      user = user_fixture()
      tournament = tournament_fixture(%{user: user})
      conn = log_in_user(build_conn(), user)

      {:ok, _index_live, _html} = live(conn, ~p"/tournaments")

      # Navigate to the edit modal
      {:ok, edit_live, _html} = live(conn, ~p"/tournaments/#{tournament}/edit")

      assert edit_live
             |> form("#tournament-form", tournament: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert edit_live
             |> form("#tournament-form", tournament: @update_attrs)
             |> render_submit()

      assert_redirect(edit_live, ~p"/tournaments/#{tournament.id}")
    end

    test "non-owner cannot access edit route" do
      owner = user_fixture()
      other_user = user_fixture()
      tournament = tournament_fixture(%{user: owner})
      conn = log_in_user(build_conn(), other_user)

      assert {:error, {:live_redirect, %{to: "/tournaments"}}} =
               live(conn, ~p"/tournaments/#{tournament}/edit")
    end

    test "admin can access edit route for any tournament and sees edit action on list" do
      owner = user_fixture()
      admin = user_fixture(%{admin: true})
      tournament = tournament_fixture(%{user: owner})
      conn = log_in_user(build_conn(), admin)

      {:ok, index_live, _html} = live(conn, ~p"/tournaments")
      assert has_element?(index_live, "a[href='/tournaments/#{tournament.id}/edit']")

      {:ok, edit_live, _html} = live(conn, ~p"/tournaments/#{tournament}/edit")
      assert has_element?(edit_live, "#tournament-form")
    end
  end

  describe "Show" do
    setup [:create_tournament]

    test "displays tournament", %{conn: conn, tournament: tournament} do
      {:ok, show_live, html} = live(conn, ~p"/tournaments/#{tournament}")

      assert html =~ tournament.name
      assert html =~ tournament.location
      assert has_element?(show_live, "#tournament-qr-code svg")
    end

    test "updates tournament within modal" do
      user = user_fixture()
      tournament = tournament_fixture(%{user: user})
      conn = log_in_user(build_conn(), user)

      {:ok, show_live, _html} = live(conn, ~p"/tournaments/#{tournament}")

      show_live |> element("a", "Edit") |> render_click()

      assert_patch(show_live, ~p"/tournaments/#{tournament}/show/edit")
    end

    test "non-owner cannot access show edit route" do
      owner = user_fixture()
      other_user = user_fixture()
      tournament = tournament_fixture(%{user: owner})
      conn = log_in_user(build_conn(), other_user)

      assert {:error, {:live_redirect, %{to: to}}} =
               live(conn, ~p"/tournaments/#{tournament}/show/edit")

      assert to == "/tournaments/#{tournament.id}"
    end

    test "non-owner cannot trigger write events from show route" do
      owner = user_fixture()
      other_user = user_fixture()
      tournament = tournament_fixture(%{user: owner})
      conn = log_in_user(build_conn(), other_user)

      {:ok, show_live, _html} = live(conn, ~p"/tournaments/#{tournament}")

      participants_before =
        tournament.id
        |> Tournaments.get_tournament!()
        |> Map.get(:participants)
        |> length()

      show_live
      |> render_click("create-participant")

      assert_redirect(show_live, ~p"/tournaments/#{tournament.id}")

      participants_after =
        tournament.id
        |> Tournaments.get_tournament!()
        |> Map.get(:participants)
        |> length()

      assert participants_before == participants_after
    end
  end

  describe "Round" do
    test "shows start new round button when all rounds are finished and rounds remain" do
      user = user_fixture()
      tournament = tournament_fixture(%{user: user, round_count: 2})

      for idx <- 1..4 do
        participant_fixture(%{tournament: tournament, name: "Player #{idx}"})
      end

      tournament = Tournaments.get_tournament!(tournament.id)
      {:ok, first_round} = Rounds.start_round(tournament)
      {:ok, _} = Rounds.update_round(first_round, %{status: :finished})

      conn = log_in_user(build_conn(), user)
      {:ok, view, _html} = live(conn, ~p"/tournaments/#{tournament.id}/rounds/1")

      assert has_element?(view, "#start-new-round-button")
      refute has_element?(view, "#start-new-round-button[disabled]")
    end

    test "creates next round from round page" do
      user = user_fixture()
      tournament = tournament_fixture(%{user: user, round_count: 2})

      for idx <- 1..4 do
        participant_fixture(%{tournament: tournament, name: "Player #{idx}"})
      end

      tournament = Tournaments.get_tournament!(tournament.id)
      {:ok, first_round} = Rounds.start_round(tournament)
      {:ok, _} = Rounds.update_round(first_round, %{status: :finished})
      conn = log_in_user(build_conn(), user)
      {:ok, view, _html} = live(conn, ~p"/tournaments/#{tournament.id}/rounds/1")

      view
      |> element("#start-new-round-button")
      |> render_click()

      assert_redirect(view, ~p"/tournaments/#{tournament.id}/rounds/2")

      rounds = Rounds.list_rounds(tournament.id)
      assert length(rounds) == 2
      assert Enum.any?(rounds, fn round -> round.number == 1 and round.status == :active end)
    end

    test "non-owner cannot access round edit pairing route" do
      owner = user_fixture()
      other_user = user_fixture()
      tournament = tournament_fixture(%{user: owner, round_count: 2})

      for idx <- 1..4 do
        participant_fixture(%{tournament: tournament, name: "Player #{idx}"})
      end

      tournament = Tournaments.get_tournament!(tournament.id)
      {:ok, _round} = Rounds.start_round(tournament)
      conn = log_in_user(build_conn(), other_user)

      assert {:error, {:live_redirect, %{to: to}}} =
               live(conn, ~p"/tournaments/#{tournament.id}/rounds/1/pairing/1/edit")

      assert to == "/tournaments/#{tournament.id}/rounds/1"
    end
  end
end
