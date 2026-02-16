defmodule MtgFriendsWeb.Layouts do
  use MtgFriendsWeb, :html

  embed_templates "layouts/*"

  @spec app(any()) :: Phoenix.LiveView.Rendered.t()
  def app(assigns) do
    ~H"""
    <nav class="sticky top-0 z-50 border-b border-slate-800/70 bg-[#101822]/95 px-4 py-4 backdrop-blur-md lg:px-6">
      <div class="mx-auto flex w-full max-w-[1800px] items-center justify-between">
        <.link
          navigate={if(is_nil(@current_user), do: ~p"/", else: ~p"/tournaments")}
          class="flex items-center gap-3"
        >
          <div class="flex size-10 items-center justify-center rounded-xl bg-blue-500">
            <.icon name="hero-bolt-solid" class="size-5 text-white" />
          </div>
          <span class="text-2xl font-black tracking-tight text-white">TIE BREAKER</span>
        </.link>

        <div class="flex items-center gap-3">
          <.link
            navigate={~p"/tournaments"}
            class="hidden text-xs font-bold uppercase tracking-[0.2em] text-slate-300 transition-colors hover:text-white md:inline"
          >
            Tournaments
          </.link>

          <details class="relative">
            <summary class="flex size-10 list-none cursor-pointer items-center justify-center rounded-full border border-blue-500/40 bg-blue-500/10 text-blue-300 transition-colors hover:bg-blue-500/20">
              <.icon name="hero-bars-3-solid" class="size-5" />
            </summary>

            <div class="absolute right-0 z-50 mt-2 w-48 rounded-xl border border-slate-700 bg-slate-900/95 p-2 shadow-xl">
              <.link
                navigate={~p"/tournaments"}
                class="block rounded-lg px-3 py-2 text-xs font-bold uppercase tracking-[0.15em] text-slate-300 transition-colors hover:bg-slate-800 hover:text-white"
              >
                Tournaments
              </.link>

              <%= if @current_user do %>
                <.link
                  navigate={~p"/users/settings"}
                  class="block rounded-lg px-3 py-2 text-xs font-bold uppercase tracking-[0.15em] text-slate-300 transition-colors hover:bg-slate-800 hover:text-white"
                >
                  Settings
                </.link>
                <.link
                  href={~p"/users/log_out"}
                  method="delete"
                  class="block rounded-lg px-3 py-2 text-xs font-bold uppercase tracking-[0.15em] text-slate-300 transition-colors hover:bg-slate-800 hover:text-white"
                >
                  Log out
                </.link>
              <% else %>
                <.link
                  navigate={~p"/users/log_in"}
                  class="block rounded-lg px-3 py-2 text-xs font-bold uppercase tracking-[0.15em] text-slate-300 transition-colors hover:bg-slate-800 hover:text-white"
                >
                  Log in
                </.link>
                <.link
                  navigate={~p"/users/register"}
                  class="block rounded-lg px-3 py-2 text-xs font-bold uppercase tracking-[0.15em] text-slate-300 transition-colors hover:bg-slate-800 hover:text-white"
                >
                  Register
                </.link>
              <% end %>
            </div>
          </details>
        </div>
      </div>
    </nav>

    <main>
      {@inner_content}
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-[33%] h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-[33%] [[data-theme=dark]_&]:left-[66%] transition-[left]" />

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
end
