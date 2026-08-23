defmodule MtgFriendsWeb.HelloHTML do
  use MtgFriendsWeb, :html

  def index(assigns) do
    ~H"""
    <div class="min-h-screen tb-page-bg">
      <h1>Hello World</h1>
    </div>
    """
  end
end
