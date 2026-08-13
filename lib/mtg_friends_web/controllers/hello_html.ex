defmodule MtgFriendsWeb.HelloHTML do
  use MtgFriendsWeb, :html

  def index(assigns) do
    ~H"""
    <div>Hello World</div>
    """
  end
end
