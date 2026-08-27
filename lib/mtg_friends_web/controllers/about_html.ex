defmodule MtgFriendsWeb.AboutHTML do
  use MtgFriendsWeb, :html

  def index(assigns) do
    ~H"""
    <main class={["mx-auto max-w-3xl px-6 py-12"]}>
      <p>
        Tie Breaker is a tournament management app for Magic: The Gathering.
      </p>
    </main>
    """
  end
end
