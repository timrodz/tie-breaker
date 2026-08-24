defmodule MtgFriendsWeb.HelloHTML do
  use MtgFriendsWeb, :html

  def index(assigns) do
    ~H"""
    <div>
      <h1>Hello, World!</h1>
    </div>
    """
  end
end
