defmodule MtgFriendsWeb.LandingHTML do
  use MtgFriendsWeb, :html

  def index(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center">
      <h1 class="text-4xl font-bold">Hello World</h1>
    </div>
    """
  end
end
