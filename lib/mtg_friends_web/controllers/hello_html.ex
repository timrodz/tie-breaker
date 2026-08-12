defmodule MtgFriendsWeb.HelloHTML do
  use MtgFriendsWeb, :html

  def index(assigns) do
    ~H"""
    <div class="flex min-h-[60vh] items-center justify-center">
      <div class="flex flex-col items-center gap-6 text-center">
        <div class="flex size-14 items-center justify-center rounded-lg bg-primary">
          <.icon name="hero-hand-raised-solid" class="size-7 text-primary-content" />
        </div>
        <h1 class="text-5xl font-black tracking-tight text-base-content">
          Hello World
        </h1>
        <p class="max-w-md text-lg text-base-content/70">
          The Tie Breaker rendering pipeline is up and running.
        </p>
        <.button navigate={~p"/"} variant="primary" class="uppercase">
          Back to home<.icon name="hero-arrow-right-solid" class="size-5" />
        </.button>
      </div>
    </div>
    """
  end
end
