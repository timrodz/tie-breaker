defmodule MtgFriendsWeb.LandingHTML do
  use MtgFriendsWeb, :html

  def index(assigns) do
    ~H"""
    <div class={["min-h-screen", "flex", "items-center", "justify-center"]}>
      <h1 class="text-center text-4xl font-bold text-base-content">
        Hello World
        <span class="block mt-2 text-2xl font-semibold text-base-content/70">
          Tie Breaker
        </span>
      </h1>
    </div>
    """
  end
end
