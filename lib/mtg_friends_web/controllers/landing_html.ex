defmodule MtgFriendsWeb.LandingHTML do
  use MtgFriendsWeb, :html

  alias MtgFriends.Tournaments

  def index(assigns) do
    ~H"""
    <div class="min-h-screen tb-page-bg">
      <nav class="sticky top-0 z-50 w-full border-b border-base-300 bg-base-300/80 backdrop-blur-md">
        <div class="mx-auto flex w-full max-w-7xl items-center justify-between px-6 py-3.5">
          <div class="flex items-center gap-3">
            <div class="flex size-10 items-center justify-center rounded-lg bg-primary">
              <.icon name="hero-bolt-solid" class="size-5 text-base-content" />
            </div>
            <span class="text-2xl font-bold tracking-tight text-base-content">TIE BREAKER</span>
          </div>
          <.link
            navigate={~p"/tournaments/new"}
            class="rounded-xl bg-primary px-7 py-2.5 text-sm font-bold text-primary-content transition-colors hover:bg-primary/85"
          >
            START YOUR FIRST EVENT
          </.link>
        </div>
      </nav>

      <main class="tb-page-bg relative overflow-hidden pb-28 pt-20">
        <div class="absolute left-1/2 top-0 -z-10 h-[600px] w-[1000px] -translate-x-1/2 rounded-2xl bg-primary/10 blur-[120px]">
        </div>

        <section class="mx-auto max-w-7xl px-6">
          <div class="max-w-4xl space-y-8">
            <h1 class="font-bold leading-[1.03] tracking-tight text-base-content text-6xl">
              PRO-LEVEL <br /> TOURNAMENT <br /> MANAGEMENT, <br />
              <span class="text-primary">COMPLETELY FREE</span>
            </h1>

            <p class="max-w-[46rem] text-2xl leading-relaxed text-base-content/70">
              The most powerful pairing engine for Magic: The Gathering and other TCGs. Built specifically for complex 3-4 player pod logic, live standings, and seamless round management.
            </p>

            <div class="flex flex-col items-center gap-4 pt-2 sm:flex-row">
              <.link
                navigate={~p"/tournaments/new"}
                class="flex w-full items-center justify-center gap-2 rounded-xl bg-primary px-10 py-4 text-xl font-bold text-primary-content transition-colors hover:bg-primary/85 sm:w-auto"
              >
                Start Your First Event <.icon name="hero-arrow-right-solid" class="size-6" />
              </.link>
              <.link
                href="#main-features"
                class="w-full rounded-xl border border-base-300 px-10 py-4 text-center text-xl font-bold text-base-content/80 transition-colors hover:bg-base-200 sm:w-auto"
              >
                Explore Features
              </.link>
            </div>
          </div>
        </section>

        <section class="mx-auto mt-24 max-w-7xl px-6">
          <div class="mb-6 flex items-end justify-between gap-4">
            <div>
              <h2 class="text-5xl font-bold text-base-content">Latest tournaments</h2>
              <p class="mt-2 text-2xl text-base-content/70">
                Watch the top tournaments unfold in real-time.
              </p>
            </div>
            <.link
              navigate={~p"/tournaments"}
              class="hidden items-center gap-1 text-sm font-bold uppercase tracking-wider text-primary hover:text-primary md:flex"
            >
              View All Tournaments
              <.icon name="hero-arrow-top-right-on-square-solid" class="size-4" />
            </.link>
          </div>
          <.live_tournaments />
        </section>

        <section id="main-features" class="mx-auto mt-28 max-w-7xl px-6">
          <div class="mb-16">
            <h2 class="mb-4 text-6xl font-bold text-base-content">Optimized for Competitive Play</h2>
            <p class="max-w-4xl text-2xl text-base-content/70">
              Professional tools that scale from casual Friday nights to massive regional qualifiers, without the enterprise price tag.
            </p>
          </div>

          <div class="grid grid-cols-1 gap-6 md:grid-cols-3">
            <article class="rounded-xl border border-base-300 bg-base-200 p-8 transition-colors hover:border-primary/50">
              <div class="mb-6 flex size-12 items-center justify-center rounded-lg bg-primary/10">
                <.icon name="hero-users-solid" class="size-7 text-primary" />
              </div>
              <h3 class="mb-3 text-4xl font-bold text-base-content">Multi-Player Pods</h3>
              <p class="text-xl leading-relaxed text-base-content/70">
                Advanced support for 3 and 4-player pods. Automatically handles odd player counts and ensures diverse matchups every round.
              </p>
              <div class="mt-6 flex items-center gap-2 border-t border-base-300 pt-6 text-xs font-bold uppercase tracking-tighter text-base-content/60">
                <.icon name="hero-adjustments-horizontal-solid" class="size-4" /> Custom Pairing Logic
              </div>
            </article>

            <article class="rounded-xl border border-base-300 bg-base-200 p-8 transition-colors hover:border-primary/50">
              <div class="mb-6 flex size-12 items-center justify-center rounded-lg bg-primary/10">
                <.icon name="hero-bolt-solid" class="size-7 text-primary" />
              </div>
              <h3 class="mb-3 text-4xl font-bold text-base-content">Instant Standings</h3>
              <p class="text-xl leading-relaxed text-base-content/70">
                Lightning-fast results calculation. Players can check their rank and upcoming table assignments via a simple, static URL.
              </p>
              <div class="mt-6 flex items-center gap-2 border-t border-base-300 pt-6 text-xs font-bold uppercase tracking-tighter text-base-content/60">
                <.icon name="hero-qr-code-solid" class="size-4" /> QR Ready Layouts
              </div>
            </article>

            <article
              id="documentation"
              class="rounded-xl border border-base-300 bg-base-200 p-8 transition-colors hover:border-primary/50"
            >
              <div class="mb-6 flex size-12 items-center justify-center rounded-lg bg-primary/10">
                <.icon name="hero-command-line-solid" class="size-7 text-primary" />
              </div>
              <h3 class="mb-3 text-4xl font-bold text-base-content">Robust & Reliable</h3>
              <p class="text-xl leading-relaxed text-base-content/70">
                Built for reliability. No heavy scripts or 3D assets to crash on mobile. Just clean, server-rendered tournament management.
              </p>
              <div class="mt-6 flex items-center gap-2 border-t border-base-300 pt-6 text-xs font-bold uppercase tracking-tighter text-base-content/60">
                <.icon name="hero-cloud-solid" class="size-4" /> 99.9% Uptime SLA
              </div>
            </article>
          </div>
        </section>
      </main>

      <footer class="border-t border-base-300 bg-base-300 py-12">
        <div class="mx-auto max-w-7xl px-6">
          <div class="flex flex-col items-center justify-between gap-8 md:flex-row">
            <div class="flex items-center gap-3">
              <div class="flex size-8 items-center justify-center rounded bg-base-200">
                <.icon name="hero-bolt-solid" class="size-4 text-primary" />
              </div>
              <span class="font-bold tracking-tighter text-base-content/80">TIE BREAKER</span>
            </div>
            <div class="flex gap-8 text-sm font-bold uppercase tracking-widest text-base-content/60">
              <.link
                href="https://github.com/timrodz/mtg-friends"
                target="_blank"
                class="hover:text-base-content"
              >
                Open Source
              </.link>
              <%!-- <.link href="#" class="hover:text-base-content">Privacy</.link> --%>

              <%!-- <.link href="#" class="hover:text-base-content">Terms</.link> --%>
              <.link href="mailto:juan@timrodz.dev" class="hover:text-base-content">Contact</.link>
            </div>
            <div class="flex items-center gap-4">
              <.link
                href="mailto:juan@timrodz.dev"
                class="flex size-10 items-center justify-center rounded-2xl border border-base-300 text-base-content/70 transition-colors hover:border-base-300 hover:text-base-content"
              >
                <.icon name="hero-at-symbol-solid" class="size-5" />
              </.link>
              <.link
                href="https://github.com/timrodz/mtg-friends"
                target="_blank"
                class="flex size-10 items-center justify-center rounded-2xl border border-base-300 text-base-content/70 transition-colors hover:border-base-300 hover:text-base-content"
              >
                <.icon name="hero-code-bracket-solid" class="size-5" />
              </.link>
            </div>
          </div>
          <div class="mt-8 text-center text-xs font-medium text-base-content/50 md:text-left">
            &copy; {DateTime.utc_now().year} Tie Breaker Tournament Systems. Pro-level tools, free forever. Not affiliated with any specific TCG brand.
          </div>
        </div>
      </footer>
    </div>
    """
  end

  attr :tournaments, :list, default: nil

  defp live_tournaments(assigns) do
    tournaments = assigns.tournaments || Tournaments.list_live_tournaments(4)
    assigns = assign(assigns, :tournaments, tournaments)

    ~H"""
    <div class="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
      <article
        :for={tournament <- @tournaments}
        class="rounded-xl border border-base-300 bg-base-200/90 p-4 space-y-2"
      >
        <div class="flex items-center justify-between text-xs font-bold uppercase tracking-widest text-base-content/60">
          <span>{round_progress_text(tournament)}</span>
        </div>
        <h3 class="line-clamp-2 text-2xl font-bold text-base-content capitalize">
          {tournament.name}
        </h3>
        <div class="flex items-center justify-between border-t border-base-300 pt-3 text-sm text-base-content/70">
          <span class="inline-flex items-center gap-1">
            <.icon name="hero-users-solid" class="size-4" />
            {participant_count(tournament)} Players
          </span>
          <.link
            navigate={~p"/tournaments/#{tournament}"}
            class="text-xs font-bold uppercase tracking-wider text-base-content hover:text-primary"
          >
            See more
          </.link>
        </div>
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
