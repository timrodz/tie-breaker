defmodule MtgFriendsWeb.FaqHTML do
  use MtgFriendsWeb, :html

  def index(assigns) do
    ~H"""
    <div class="min-h-screen tb-page-bg">
      <main class="mx-auto max-w-3xl px-6 py-20">
        <h1 class="text-5xl font-black text-base-content">Frequently Asked Questions</h1>
        <p class="mt-6 text-2xl leading-relaxed text-base-content/70">
          This page is under construction. Check back soon for answers to common questions.
        </p>
      </main>
    </div>
    """
  end
end
