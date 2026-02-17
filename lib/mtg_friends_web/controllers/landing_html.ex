defmodule MtgFriendsWeb.LandingHTML do
  use MtgFriendsWeb, :html

  alias MtgFriends.Tournaments

  def index(assigns) do
    assigns = Map.put(assigns, :features, get_features())

    ~H"""
    <div class="min-h-screen tb-page-bg">
      <nav class="sticky top-0 z-50 w-full border-b border-base-300 bg-base-300/80 backdrop-blur-md">
        <div class="mx-auto flex w-full max-w-7xl items-center justify-between px-6 py-3.5">
          <div class="flex items-center gap-3">
            <div class="flex size-10 items-center justify-center rounded-lg bg-primary">
              <.icon name="hero-bolt-solid" class="size-5 text-primary-content" />
            </div>
            <span class="text-2xl font-bold tracking-tight text-base-content">TIE BREAKER</span>
          </div>
          <.button
            navigate={~p"/tournaments/new"}
            class="uppercase"
          >
            GET STARTED
          </.button>
        </div>
      </nav>

      <main class="tb-page-bg relative overflow-hidden pb-28 pt-20">
        <div class="absolute left-1/2 top-0 -z-10 h-[600px] w-[1000px] -translate-x-1/2 rounded-2xl bg-primary/10 blur-[120px]">
        </div>

        <section class="mx-auto max-w-7xl px-6">
          <div class="max-w-4xl space-y-8">
            <h1 class="font-black leading-xl text-base-content text-5xl md:text-6xl">
              PRO-LEVEL <br /> TOURNAMENT <br /> MANAGEMENT
            </h1>

            <p class="max-w-[46rem] text-2xl leading-8.5 text-base-content/70 bg-base-300">
              The most powerful pairing engine for Magic: The Gathering. Built specifically for complex 3-4 player pod logic, live standings, and seamless round management.
            </p>

            <div class="flex flex-col items-center gap-4 pt-2 sm:flex-row">
              <.button
                navigate={~p"/tournaments/new"}
                variant="primary"
                class="text-xl font-bold uppercase tracking-wide"
              >
                START YOUR TOURNAMENT<.icon name="hero-arrow-right-solid" class="size-6" />
              </.button>
              <.button
                href="#main-features"
                variant="neutral"
                class="font-semibold text-xl capitalize"
              >
                Explore Features
              </.button>
            </div>
          </div>
        </section>

        <section class="mx-auto mt-24 max-w-7xl px-6">
          <div class="mb-6 flex items-end justify-between gap-4">
            <div>
              <h2 class="text-5xl font-bold text-base-content">Latest tournaments</h2>
              <p class="mt-2 text-2xl text-base-content/70 bg-base-300">
                Watch the top tournaments unfold in real-time.
              </p>
            </div>
          </div>
          <.live_tournaments />
          <div class="ml-2 mt-2">
            <.link
              navigate={~p"/tournaments"}
              class="inline-flex items-center gap-1 text-md bg-base-300 font-bold uppercase tracking-widest text-primary hover:text-primary"
            >
              View All Tournaments
              <.icon name="hero-arrow-top-right-on-square-solid" class="size-4" />
            </.link>
          </div>
        </section>

        <section id="main-features" class="mx-auto mt-28 max-w-7xl px-6">
          <div class="mb-16">
            <h2 class="mb-4 text-5xl font-bold text-base-content">Optimized for Competitive Play</h2>
            <p class="max-w-4xl text-2xl text-base-content/70 bg-base-300">
              Professional tools that scale from casual Friday nights to massive regional qualifiers, without the enterprise price tag.
            </p>
          </div>

          <div class="grid grid-cols-1 gap-6 md:grid-cols-3">
            <article
              :for={feature <- @features}
              class="rounded-xl border border-base-300 bg-base-200 p-8 transition-colors hover:border-primary/50"
            >
              <div class="mb-6 flex size-12 items-center justify-center rounded-lg bg-primary/10">
                <.icon name={feature.icon} class="size-7 text-primary" />
              </div>
              <h3 class="mb-3 text-4xl font-bold text-base-content">{feature.title}</h3>
              <p class="text-xl leading-relaxed text-base-content/70">
                {feature.description}
              </p>
              <div class="mt-6 border-t border-base-300 pt-6 text-xs font-bold uppercase tracking-tighter text-base-content/60">
                <p
                  :if={Map.has_key?(feature, :footer_text)}
                  class="flex items-center gap-2"
                >
                  {feature.footer_text}
                </p>
                <.link
                  :if={Map.has_key?(feature, :href)}
                  href={feature.href}
                  class="inline-flex items-center gap-1 text-xs font-bold uppercase tracking-widest text-primary hover:text-primary/80"
                >
                  Learn More <.icon name="hero-arrow-up-right-solid" class="size-4" />
                </.link>
              </div>
            </article>
          </div>
        </section>
      </main>

      <footer class="border-t border-base-300 bg-base-300 pt-6 pb-8">
        <div class="mx-auto max-w-7xl px-6">
          <div class="flex flex-col items-center justify-between gap-6 md:flex-row">
            <div class="flex justify-center items-center gap-3">
              <.icon name="hero-bolt-solid" class="size-4 text-primary" />
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
              <.link href="mailto:juan@timrodz.dev" class="hover:text-base-content">Contact</.link>
            </div>
            <div class="text-center text-xs font-medium text-base-content/50 md:text-left">
              &copy; {DateTime.utc_now().year} Tie Breaker Tournament Systems. Pro-level tools, free forever. Not affiliated with any specific TCG brand.
            </div>
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
      <.tournament_card
        :for={tournament <- @tournaments}
        class="bg-base-200/90"
        tournament={tournament}
        navigate_to={~p"/tournaments/#{tournament}"}
        cta_label="See more"
        progress_text={round_progress_text(tournament)}
        player_count={participant_count(tournament)}
      />
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

  defp get_features do
    [
      %{
        title: "Multi-player Pods",
        description:
          "Advanced support for 3 and 4-player pods. Automatically handles odd player counts and ensures diverse matchups every round.",
        icon: "hero-squares-2x2-solid",
        footer_text: "EDH 8 player tournaments welcome",
      },
      %{
        title: "Instant Standings",
        description:
          "Lightning-fast results calculation. Players can check their rank and upcoming table assignments via QR code.",
        icon: "hero-qr-code-solid",
        footer_text: "QR Ready Layouts",
      },
      %{
        title: "Diverse Algorithms",
        description:
          "Choose from Round Robin, Bubble Rounds, or Swiss for your pod match-ups. Change any-time even if your tournament is live.",
        icon: "hero-users-solid",
        footer_text: "Custom Pairing Logic",
      },
      # %{
      #   title: "Open Source",
      #   description: "Built for reliability. Open sourced, Tie Breaker gives to the community a product they can fully own, completely free.",
      #   icon: "hero-code-bracket-square-solid",
      #   href: "https://github.com/timrodz/mtg-friends"
      # }
    ]
  end
end
