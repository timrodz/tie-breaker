defmodule MtgFriendsWeb.UserSettingsLive do
  use MtgFriendsWeb, :live_view

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Settings
    </.header>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
