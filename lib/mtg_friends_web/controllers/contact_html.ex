defmodule MtgFriendsWeb.ContactHTML do
  use MtgFriendsWeb, :html

  def index(assigns) do
    ~H"""
    <div class="min-h-screen tb-page-bg">
      <main class="flex min-h-screen items-center justify-center px-6">
        <div class="max-w-xl space-y-6 text-center">
          <h1 class="text-5xl font-black text-base-content">Get in touch</h1>
          <p class="text-2xl leading-8.5 text-base-content/70">
            Questions about Tie Breaker? Reach the team at the email below.
          </p>
          <.link
            href="mailto:contact@tiebreaker.app"
            class="inline-block text-xl font-bold text-primary hover:text-primary/80"
          >
            contact@tiebreaker.app
          </.link>
        </div>
      </main>
    </div>
    """
  end
end
