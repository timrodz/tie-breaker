defmodule Mix.Tasks.Seed.TestTournaments do
  @moduledoc """
  Seeds randomized test tournaments and participants for local development.
  """
  use Mix.Task

  alias MtgFriends.Accounts
  alias MtgFriends.Games
  alias MtgFriends.Participants
  alias MtgFriends.Tournaments

  @impl Mix.Task
  def run(args) do
    ensure_app_started!()

    {opts, _rest, _invalid} =
      OptionParser.parse(args, strict: [count: :integer, user_email: :string])

    tournament_count = Keyword.get(opts, :count, 32)
    user_email = Keyword.get(opts, :user_email)

    if tournament_count < 1 do
      raise ArgumentError, "--count must be at least 1"
    end

    result = run_task(count: tournament_count, user_email: user_email)
    seeded_count = length(result.tournaments)
    top_cut_count = Enum.count(result.tournaments, & &1.is_top_cut_4)

    IO.puts("Seeded #{seeded_count} tournaments for user_id=#{result.owner_id}.")

    IO.puts(
      "Top-cut enabled: #{top_cut_count}; top-cut disabled: #{seeded_count - top_cut_count}."
    )

    IO.puts(
      "Use `mix seed.test_tournaments --count N --user-email owner@example.com` to customize."
    )
  end

  defp ensure_app_started! do
    case Application.ensure_all_started(:mtg_friends) do
      {:ok, _started} -> :ok
      {:error, reason} -> raise "failed to start app: #{inspect(reason)}"
    end
  end

  @default_tournament_count 32
  @player_counts [8, 12, 16, 20, 24, 28, 32]

  @spec run_task(keyword()) :: %{
          owner_id: integer(),
          tournaments: [%{id: integer(), is_top_cut_4: boolean(), player_count: integer()}]
        }
  def run_task(opts \\ []) do
    tournament_count = Keyword.get(opts, :count, @default_tournament_count)
    owner = get_owner!(Keyword.get(opts, :user_email))
    game = get_or_create_mtg_game!()

    tournaments =
      1..tournament_count
      |> Enum.map(fn _ ->
        player_count = Enum.random(@player_counts)
        is_top_cut_4 = :rand.uniform(2) == 1

        tournament =
          %{
            "user_id" => owner.id,
            "game_id" => game.id,
            "name" => "Test Tournament",
            "location" => "Test Location",
            "date" => NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            "description_raw" => "Test tournament",
            "round_count" => 4,
            "format" => :edh,
            "subformat" => :swiss,
            "is_top_cut_4" => is_top_cut_4
          }
          |> Tournaments.create_tournament()
          |> expect_ok!("failed to seed tournament")

        create_participants!(tournament.id, player_count)

        %{id: tournament.id, player_count: player_count, is_top_cut_4: is_top_cut_4}
      end)

    %{owner_id: owner.id, tournaments: tournaments}
  end

  defp create_seed_owner! do
    email = "seed-user-#{System.unique_integer([:positive])}@example.com"

    %{
      email: email,
      password: "seeduserpassword!"
    }
    |> Accounts.register_user()
    |> expect_ok!("failed to seed owner user")
  end

  defp get_owner!(nil), do: create_seed_owner!()

  defp get_owner!(""), do: create_seed_owner!()

  defp get_owner!(email) when is_binary(email) do
    case Accounts.get_user_by_email(email) do
      nil -> raise "user not found for --user-email=#{email}"
      user -> user
    end
  end

  defp get_owner!(email), do: raise("invalid --user-email value: #{inspect(email)}")

  defp get_or_create_mtg_game! do
    case Enum.find(Games.list_games(), fn game -> game.code == :mtg end) do
      nil ->
        game =
          %{
            name: "Magic: The Gathering",
            code: :mtg,
            url: "https://magic.wizards.com"
          }
          |> Games.create_game()
          |> expect_ok!("failed to seed mtg game")

        game

      game ->
        game
    end
  end

  defp create_participants!(tournament_id, player_count) do
    participants =
      1..player_count
      |> Enum.map(&"Player #{&1}")

    case Participants.create_x_participants(tournament_id, participants) do
      {:ok, _result} ->
        :ok

      {:error, reason} ->
        raise "failed to seed participants: #{inspect(reason)}"

      {:error, _operation, reason, _changes} ->
        raise "failed to seed participants: #{inspect(reason)}"
    end
  end

  defp expect_ok!({:ok, value}, _context), do: value

  defp expect_ok!({:error, reason}, context) do
    raise "#{context}: #{inspect(reason)}"
  end
end
