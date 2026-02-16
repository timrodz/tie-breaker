defmodule MtgFriendsWeb.LandingHTML do
  use MtgFriendsWeb, :html

  alias MtgFriends.Tournaments

  def index(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-950 text-slate-50">
      <nav class="sticky top-0 z-50 w-full border-b border-slate-900 bg-slate-950/80 backdrop-blur-md">
        <div class="mx-auto flex w-full max-w-7xl items-center justify-between px-6 py-3.5">
          <div class="flex items-center gap-3">
            <div class="flex size-10 items-center justify-center rounded-lg bg-blue-500">
              <.icon name="hero-trophy-solid" class="size-5 text-white" />
            </div>
            <span class="text-2xl font-bold tracking-tight text-white">TIE BREAKER</span>
          </div>
          <.link
            navigate={~p"/tournaments/new"}
            class="rounded-xl bg-white px-7 py-2.5 text-sm font-bold text-slate-950 transition-colors hover:bg-slate-200"
          >
            START YOUR FIRST EVENT
          </.link>
        </div>
      </nav>

      <main class="relative overflow-hidden bg-[radial-gradient(circle_at_2px_2px,rgba(59,130,246,0.18)_1px,transparent_0)] [background-size:24px_24px] pb-28 pt-20">
        <div class="absolute left-1/2 top-0 -z-10 h-[600px] w-[1000px] -translate-x-1/2 rounded-2xl bg-blue-500/10 blur-[120px]">
        </div>

        <section class="mx-auto max-w-7xl px-6">
          <div class="max-w-4xl space-y-8">
            <h1 class="font-bold leading-[1.03] tracking-tight text-white text-6xl">
              PRO-LEVEL <br /> TOURNAMENT <br /> MANAGEMENT, <br />
              <span class="text-blue-500">COMPLETELY FREE</span>
            </h1>

            <p class="max-w-[46rem] text-2xl leading-relaxed text-slate-400">
              The most powerful pairing engine for Magic: The Gathering and other TCGs. Built specifically for complex 3-4 player pod logic, live standings, and seamless round management.
            </p>

            <div class="flex flex-col items-center gap-4 pt-2 sm:flex-row">
              <.link
                navigate={~p"/tournaments/new"}
                class="flex w-full items-center justify-center gap-2 rounded-xl bg-blue-500 px-10 py-4 text-xl font-bold text-white transition-colors hover:bg-blue-600 sm:w-auto"
              >
                Start Your First Event <.icon name="hero-arrow-right-solid" class="size-6" />
              </.link>
              <.link
                href="#features"
                class="w-full rounded-xl border border-slate-800 px-10 py-4 text-center text-xl font-bold text-slate-300 transition-colors hover:bg-slate-900 sm:w-auto"
              >
                Explore Features
              </.link>
            </div>
          </div>
        </section>

        <section class="mx-auto mt-24 max-w-7xl px-6">
          <div class="mb-6 flex items-end justify-between gap-4">
            <div>
              <h2 class="text-5xl font-bold text-white">Live Events</h2>
              <p class="mt-2 text-2xl text-slate-400">
                Watch the top tournaments unfold in real-time.
              </p>
            </div>
            <.link
              navigate={~p"/tournaments"}
              class="hidden items-center gap-1 text-sm font-bold uppercase tracking-wider text-blue-500 hover:text-blue-400 md:flex"
            >
              View All Live <.icon name="hero-arrow-top-right-on-square-solid" class="size-4" />
            </.link>
          </div>
          <.live_events />
        </section>

        <section id="features" class="mx-auto mt-28 max-w-7xl px-6">
          <div class="mb-16">
            <h2 class="mb-4 text-6xl font-bold text-white">Optimized for Competitive Play</h2>
            <p class="max-w-4xl text-2xl text-slate-400">
              Professional tools that scale from casual Friday nights to massive regional qualifiers, without the enterprise price tag.
            </p>
          </div>

          <div class="grid grid-cols-1 gap-6 md:grid-cols-3">
            <article class="rounded-xl border border-slate-800 bg-slate-900 p-8 transition-colors hover:border-blue-500/50">
              <div class="mb-6 flex size-12 items-center justify-center rounded-lg bg-blue-500/10">
                <.icon name="hero-users-solid" class="size-7 text-blue-500" />
              </div>
              <h3 class="mb-3 text-4xl font-bold text-white">Multi-Player Pods</h3>
              <p class="text-xl leading-relaxed text-slate-400">
                Advanced support for 3 and 4-player pods. Automatically handles odd player counts and ensures diverse matchups every round.
              </p>
              <div class="mt-6 flex items-center gap-2 border-t border-slate-800 pt-6 text-xs font-bold uppercase tracking-tighter text-slate-500">
                <.icon name="hero-adjustments-horizontal-solid" class="size-4" /> Custom Pairing Logic
              </div>
            </article>

            <article class="rounded-xl border border-slate-800 bg-slate-900 p-8 transition-colors hover:border-blue-500/50">
              <div class="mb-6 flex size-12 items-center justify-center rounded-lg bg-blue-500/10">
                <.icon name="hero-bolt-solid" class="size-7 text-blue-500" />
              </div>
              <h3 class="mb-3 text-4xl font-bold text-white">Instant Standings</h3>
              <p class="text-xl leading-relaxed text-slate-400">
                Lightning-fast results calculation. Players can check their rank and upcoming table assignments via a simple, static URL.
              </p>
              <div class="mt-6 flex items-center gap-2 border-t border-slate-800 pt-6 text-xs font-bold uppercase tracking-tighter text-slate-500">
                <.icon name="hero-qr-code-solid" class="size-4" /> QR Ready Layouts
              </div>
            </article>

            <article
              id="documentation"
              class="rounded-xl border border-slate-800 bg-slate-900 p-8 transition-colors hover:border-blue-500/50"
            >
              <div class="mb-6 flex size-12 items-center justify-center rounded-lg bg-blue-500/10">
                <.icon name="hero-command-line-solid" class="size-7 text-blue-500" />
              </div>
              <h3 class="mb-3 text-4xl font-bold text-white">Robust & Reliable</h3>
              <p class="text-xl leading-relaxed text-slate-400">
                Built for reliability. No heavy scripts or 3D assets to crash on mobile. Just clean, server-rendered tournament management.
              </p>
              <div class="mt-6 flex items-center gap-2 border-t border-slate-800 pt-6 text-xs font-bold uppercase tracking-tighter text-slate-500">
                <.icon name="hero-cloud-solid" class="size-4" /> 99.9% Uptime SLA
              </div>
            </article>
          </div>
        </section>
      </main>

      <footer class="border-t border-slate-900 bg-slate-950 py-12">
        <div class="mx-auto max-w-7xl px-6">
          <div class="flex flex-col items-center justify-between gap-8 md:flex-row">
            <div class="flex items-center gap-3">
              <div class="flex size-8 items-center justify-center rounded bg-slate-800">
                <.icon name="hero-trophy-solid" class="size-4 text-blue-500" />
              </div>
              <span class="font-bold tracking-tighter text-slate-300">TIE BREAKER</span>
            </div>
            <div class="flex gap-8 text-md font-bold uppercase tracking-widest text-slate-500">
              <.link
                href="https://github.com/timrodz/mtg-friends"
                target="_blank"
                class="hover:text-white"
              >
                Open Source
              </.link>
              <.link href="#" class="hover:text-white">Privacy</.link>
              <.link href="#" class="hover:text-white">Terms</.link>
              <.link href="mailto:juan@timrodz.dev" class="hover:text-white">Contact</.link>
            </div>
            <div class="flex items-center gap-4">
              <.link
                href="mailto:juan@timrodz.dev"
                class="flex size-10 items-center justify-center rounded-2xl border border-slate-800 text-slate-400 transition-colors hover:border-slate-600 hover:text-white"
              >
                <.icon name="hero-at-symbol-solid" class="size-5" />
              </.link>
              <.link
                href="https://github.com/timrodz/mtg-friends"
                target="_blank"
                class="flex size-10 items-center justify-center rounded-2xl border border-slate-800 text-slate-400 transition-colors hover:border-slate-600 hover:text-white"
              >
                <.icon name="hero-code-bracket-solid" class="size-5" />
              </.link>
            </div>
          </div>
          <div class="mt-8 text-center text-xs font-medium text-slate-600 md:text-left">
            © 2024 Tie Breaker Tournament Systems. Pro-level tools, free forever. Not affiliated with any specific TCG brand.
          </div>
        </div>
      </footer>
    </div>
    """
  end

  attr :tournaments, :list, default: nil

  defp live_events(assigns) do
    tournaments = assigns.tournaments || Tournaments.list_live_tournaments(4)
    assigns = assign(assigns, :tournaments, tournaments)

    ~H"""
    <div class="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
      <article
        :for={tournament <- @tournaments}
        class="rounded-xl border border-slate-800 bg-slate-900/90 p-4"
      >
        <div class="mb-3 flex items-center justify-between text-xs font-bold uppercase tracking-widest text-slate-500">
          <span class="inline-flex items-center gap-1 rounded-md bg-blue-500/10 px-2 py-1 text-blue-400">
            <span class="size-1.5 rounded-2xl bg-blue-500"></span> Live
          </span>
          <span>{round_progress_text(tournament)}</span>
        </div>
        <h3 class="line-clamp-2 text-3xl font-bold text-white">{tournament.name}</h3>
        <div class="mt-4 flex items-center justify-between border-t border-slate-800 pt-3 text-sm text-slate-400">
          <span class="inline-flex items-center gap-1">
            <.icon name="hero-users-solid" class="size-4" />
            {participant_count(tournament)} Players
          </span>
          <.link
            navigate={~p"/tournaments/#{tournament}"}
            class="text-xs font-bold uppercase tracking-wider text-white hover:text-blue-400"
          >
            Track Live
          </.link>
        </div>
      </article>

      <article
        :if={@tournaments == []}
        class="rounded-xl border border-slate-800 bg-slate-900/90 p-6 text-slate-400 md:col-span-2 xl:col-span-4"
      >
        No active tournaments right now.
      </article>
    </div>
    """
  end

  defp participant_count(%{participants: participants}) when is_list(participants),
    do: length(participants)

  defp round_progress_text(%{round_count: round_count, rounds: rounds}) when is_list(rounds) do
    total_rounds = max(round_count || 1, 1)

    current_round =
      case Enum.find(rounds, fn round -> round.status == :active end) do
        nil ->
          rounds
          |> Enum.count(fn round -> round.status == :finished end)
          |> Kernel.+(1)
          |> min(total_rounds)

        active_round ->
          min(active_round.number + 1, total_rounds)
      end

    "Round #{current_round} of #{total_rounds}"
  end
end
