defmodule MtgFriendsWeb.Layouts do
  use MtgFriendsWeb, :html

  embed_templates "layouts/*"

  @spec app(any()) :: Phoenix.LiveView.Rendered.t()
  def app(assigns) do
    assigns = assign(assigns, :app_version, app_version())

    ~H"""
    <div class="flex min-h-screen flex-col">
      <nav class="z-20 border-b border-base-300/70 bg-base-200/95 px-4 py-4 backdrop-blur-md lg:px-6">
        <div class="mx-auto flex w-full max-w-[1800px] items-center justify-between">
          <.link
            navigate="/"
            class="flex items-center gap-3"
          >
            <div class="flex size-10 items-center justify-center rounded-xl bg-primary">
              <.icon name="hero-bolt-solid" class="size-5 text-primary-content" />
            </div>
            <span class="text-2xl font-black tracking-tight text-base-content">TIE BREAKER</span>
          </.link>

          <div class="flex items-center gap-3">
            <.link
              navigate={~p"/tournaments"}
              class="hidden text-xs font-bold uppercase tracking-widest text-base-content/80 transition-colors hover:text-base-content md:inline"
            >
              Tournaments
            </.link>

            <details class="relative">
              <summary class="flex size-10 list-none cursor-pointer items-center justify-center rounded-2xl border border-primary/40 bg-primary/10 text-primary transition-colors hover:bg-primary/20">
                <.icon name="hero-bars-3-solid" class="size-5" />
              </summary>

              <div class="absolute right-0 z-50 mt-2 w-48 rounded-xl border border-base-300 bg-base-200/95 p-2 shadow-xl">
                <.link
                  navigate={~p"/tournaments"}
                  class="block rounded-lg px-3 py-2 text-xs font-bold uppercase tracking-wider text-base-content/80 transition-colors hover:bg-base-200 hover:text-base-content"
                >
                  Tournaments
                </.link>

                <%= if @current_user do %>
                  <.link
                    navigate={~p"/users/settings"}
                    class="block rounded-lg px-3 py-2 text-xs font-bold uppercase tracking-wider text-base-content/80 transition-colors hover:bg-base-200 hover:text-base-content"
                  >
                    Settings
                  </.link>
                  <.link
                    href={~p"/users/log_out"}
                    method="delete"
                    class="block rounded-lg px-3 py-2 text-xs font-bold uppercase tracking-wider text-base-content/80 transition-colors hover:bg-base-200 hover:text-base-content"
                  >
                    Log out
                  </.link>
                <% else %>
                  <.link
                    navigate={~p"/users/log_in"}
                    class="block rounded-lg px-3 py-2 text-xs font-bold uppercase tracking-wider text-base-content/80 transition-colors hover:bg-base-200 hover:text-base-content"
                  >
                    Log in
                  </.link>
                  <.link
                    navigate={~p"/users/register"}
                    class="block rounded-lg px-3 py-2 text-xs font-bold uppercase tracking-wider text-base-content/80 transition-colors hover:bg-base-200 hover:text-base-content"
                  >
                    Register
                  </.link>
                <% end %>
              </div>
            </details>
          </div>
        </div>
      </nav>

      <main class="flex-1">
        {@inner_content}
      </main>

      <footer class="border-t border-base-300 bg-base-200/90 py-4">
        <div class="mx-auto flex w-full max-w-[1800px] flex-col items-center justify-between gap-4 px-4 text-xs font-bold tracking-[0.22em] text-base-content/60 md:flex-row lg:px-6">
          <p class="text-base-content/60 uppercase">
            Version: <span class="font-mono">{@app_version}</span>
          </p>
          <div class="inline-flex items-center gap-2 text-base-content/70 uppercase">
            <.icon name="hero-bolt-solid" class="size-3.5 text-primary" />
            Powered by the Tie Breaker Engine
          </div>
          <.theme_toggle />
        </div>
      </footer>

      <.flash_group flash={@flash} />
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-2xl">
      <div class="absolute w-[33%] h-full rounded-2xl border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-[33%] [[data-theme=dark]_&]:left-[66%] transition-[left]" />

      <button phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})} class="flex p-2">
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})} class="flex p-2">
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})} class="flex p-2">
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  defp app_version do
    case Application.spec(:mtg_friends, :vsn) do
      nil -> "unknown"
      version -> to_string(version)
    end
  end
end
