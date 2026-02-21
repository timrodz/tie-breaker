defmodule MtgFriends.Analytics do
  @moduledoc """
  Analytics event helpers and integrations for MtgFriends.
  """

  @doc """
  Captures a `user_signed_up` event when a new user registers or signs in.
  """
  @spec capture_user_signed_up(term(), String.t()) :: :ok
  def capture_user_signed_up(user_id, login_type \\ "email") do
    capture("user_signed_up", %{distinct_id: user_id, login_type: login_type})
  end

  @doc """
  Captures a `tournament_created` event when a new tournament is created.
  """
  @spec capture_tournament_created(integer(), integer() | nil, atom() | nil, atom() | nil) :: :ok
  def capture_tournament_created(tournament_id, user_id, format, subformat) do
    capture("tournament_created", %{
      distinct_id: user_id || "system",
      tournament_id: tournament_id,
      format: format,
      subformat: subformat
    })
  end

  @doc """
  Captures a `round_finished` event when a given round in a tournament successfully concludes.
  """
  @spec capture_round_finished(integer(), integer(), integer()) :: :ok
  def capture_round_finished(tournament_id, round_id, round_number) do
    capture("round_finished", %{
      distinct_id: "tournament:#{tournament_id}",
      tournament_id: tournament_id,
      round_id: round_id,
      round_number: round_number
    })
  end

  @doc """
  Captures a `tournament_deleted` event when a tournament is deleted by a user or the system.
  """
  @spec capture_tournament_deleted(integer(), integer() | nil, atom() | nil) :: :ok
  def capture_tournament_deleted(tournament_id, user_id, status) do
    capture("tournament_deleted", %{
      distinct_id: user_id || "system",
      tournament_id: tournament_id,
      status: status
    })
  end

  @doc """
  Captures an analytics event with the given properties if the analytics provider is ready.
  """
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
