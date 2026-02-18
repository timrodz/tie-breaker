defmodule Mix.Tasks.Seed.TestTournaments do
  @moduledoc """
  Seeds randomized test tournaments and participants for local development.
  """

  alias MtgFriends.Seeds.TestTournaments

  def run(args) do
    ensure_app_started!()

    {opts, _rest, _invalid} =
      OptionParser.parse(args, strict: [count: :integer, user_email: :string])

    tournament_count = Keyword.get(opts, :count, 32)
    user_email = Keyword.get(opts, :user_email)

    if tournament_count < 1 do
      raise ArgumentError, "--count must be at least 1"
    end

    result = TestTournaments.run(count: tournament_count, user_email: user_email)
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
end
