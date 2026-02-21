defmodule MtgFriends.Analytics do
  @moduledoc """
  Analytics event helpers and integrations for MtgFriends.
  """

  @spec capture_user_signed_up(term(), String.t()) :: :ok
  def capture_user_signed_up(user_id, login_type \\ "email") do
    capture("user_signed_up", %{distinct_id: user_id, login_type: login_type})
  end

  @spec capture(String.t(), map()) :: :ok
  def capture(event, properties) when is_binary(event) and is_map(properties) do
    if posthog_ready?() do
      PostHog.capture(event, properties)
    end

    :ok
  end

  defp posthog_ready? do
    Application.get_env(:posthog, :enabled, false) and not is_nil(Process.whereis(PostHog.Registry))
  end
end
