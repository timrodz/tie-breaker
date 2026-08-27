defmodule MtgFriendsWeb.AdminLive.Index do
  use MtgFriendsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Admin")}
  end
end
