defmodule MtgFriends.Analytics do
  @moduledoc """
  Analytics event helpers and integrations for MtgFriends.
  """

  @spec capture_user_signed_up(term(), String.t()) :: :ok
  def capture_user_signed_up(user_id, login_type \\ "email") do
    capture("user_signed_up", %{distinct_id: user_id, login_type: login_type})
  end

  @spec capture_tournament_created(integer(), integer() | nil, atom() | nil, atom() | nil) :: :ok
  def capture_tournament_created(tournament_id, user_id, format, subformat) do
    capture("tournament_created", %{
      distinct_id: user_id || "system",
      tournament_id: tournament_id,
      format: format,
      subformat: subformat
    })
  end

  @spec capture_round_finished(integer(), integer(), integer()) :: :ok
  def capture_round_finished(tournament_id, round_id, round_number) do
    capture("round_finished", %{
      distinct_id: "tournament:#{tournament_id}",
      tournament_id: tournament_id,
      round_id: round_id,
      round_number: round_number
    })
  end

  @spec capture_tournament_deleted(integer(), integer() | nil, atom() | nil) :: :ok
  def capture_tournament_deleted(tournament_id, user_id, status) do
    capture("tournament_deleted", %{
      distinct_id: user_id || "system",
      tournament_id: tournament_id,
      status: status
    })
  end

  @spec capture(String.t(), map()) :: :ok
  def capture(event, properties) when is_binary(event) and is_map(properties) do
    if posthog_ready?() do
      PostHog.capture(event, properties)
    end

    :ok
  end

  defp posthog_ready? do
    Application.get_env(:posthog, :enable, false) and
      is_pid(Process.whereis(PostHog.Supervisor))
  end
end
