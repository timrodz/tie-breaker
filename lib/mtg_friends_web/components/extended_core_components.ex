defmodule MtgFriendsWeb.ExtendedCoreComponents do
  @moduledoc """
  Import this module inside the MtgFriendsWeb module's `html_helpers` function
  """
  use Phoenix.Component

  alias MtgFriendsWeb.CoreComponents
  alias MtgFriends.Utils.Date

  attr(:dt, :string, required: true)
  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:no_icon, :boolean, default: false)

  def datetime(assigns) do
    ~H"""
    <p id="date-time" class={["icon-text", @class]}>
      <CoreComponents.icon :if={not @no_icon} name="hero-clock-solid" />
      {@label}
      <span>{@dt |> Date.render_naive_datetime_full()}</span>
    </p>
    """
  end

  attr(:dt, :string, required: true)
  attr(:label, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:no_icon, :boolean, default: false)

  def date(assigns) do
    ~H"""
    <p class={["icon-text", @class]}>
      <CoreComponents.icon :if={not @no_icon} name="hero-calendar-solid" />
      {@label}
      <span>{@dt |> Date.render_naive_datetime_date()}</span>
    </p>
    """
  end
end
