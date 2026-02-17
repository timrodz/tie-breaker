defmodule MtgFriendsWeb.TournamentComponents do
  use Phoenix.Component
  @moduledoc false

  alias MtgFriends.TournamentRenderer
  import MtgFriendsWeb.CoreComponents
  import MtgFriendsWeb.ExtendedCoreComponents

  attr :status, :atom, required: true
  attr :class, :string, default: nil

  def tournament_status_badge(assigns) do
    ~H"""
    <span class={[
      "rounded-2xl px-2.5 py-1 text-xs font-bold uppercase tracking-[0.14em]",
      status_classes(@status),
      @class
    ]}>
      {TournamentRenderer.render_status(@status)}
    </span>
    """
  end

  attr :format, :atom, default: nil
  attr :class, :string, default: nil

  def tournament_format(assigns) do
    ~H"""
    <span class={@class}>
      {TournamentRenderer.render_format(@format)}
    </span>
    """
  end

  attr :subformat, :atom, default: nil
  attr :class, :string, default: nil

  def tournament_subformat(assigns) do
    ~H"""
    <span class={@class}>
      {TournamentRenderer.render_subformat(@subformat)}
    </span>
    """
  end

  attr :tournament, :map, required: true
  attr :id, :string, default: nil
  attr :navigate_to, :string, required: true
  attr :cta_label, :string, default: "View tournament"
  attr :progress_text, :string, default: nil
  attr :player_count, :integer, default: nil
  attr :show_status, :boolean, default: true
  attr :show_format, :boolean, default: false
  attr :show_edit, :boolean, default: false
  attr :edit_patch, :string, default: nil
  attr :class, :string, default: nil

  def tournament_card(assigns) do
    assigns = assign(assigns, :game_name, tournament_game_name(assigns.tournament))

    ~H"""
    <article
      id={@id}
      class={[
        "group rounded-2xl border border-base-300/70 bg-base-200/75 p-5 transition-colors hover:border-primary/50",
        @class
      ]}
    >
      <div class="mb-5 flex items-center justify-between border-b border-base-300/60 pb-4">
        <p class="line-clamp-1 text-xl font-bold tracking-tight text-base-content capitalize">
          {@tournament.name}
        </p>
        <.tournament_status_badge :if={@show_status} status={@tournament.status} />
      </div>

      <div
        :if={@progress_text}
        class="mb-2 text-xs font-bold uppercase tracking-[0.14em] text-base-content/60"
      >
        {@progress_text}
      </div>

      <div class="space-y-2 text-sm text-base-content/80">
        <p class="inline-flex items-center gap-2">
          <.icon name="hero-map-pin-solid" class="size-4 text-base-content/60" /> {@tournament.location}
        </p>
        <p class="inline-flex items-center gap-2">
          <.date dt={@tournament.date} />
        </p>
        <p :if={@game_name} class="inline-flex items-center gap-2">
          <.icon name="hero-puzzle-piece" class="size-4 text-base-content/60" />
          {@game_name}
        </p>
        <p :if={Map.get(@tournament, :round_count)} class="inline-flex items-center gap-2">
          <.icon name="hero-clock" class="size-4 text-base-content/60" />
          {@tournament.round_count} Rounds
        </p>
        <p :if={@show_format} class="inline-flex items-center gap-2">
          <.icon name="hero-squares-2x2-solid" class="size-4 text-base-content/60" />
          <.tournament_format format={@tournament.format} />
        </p>
        <p :if={@player_count} class="inline-flex items-center gap-2">
          <.icon name="hero-users-solid" class="size-4 text-base-content/60" />
          {@player_count} Players
        </p>
      </div>

      <div class="mt-5 flex items-center justify-between border-t border-base-300/60 pt-4">
        <.link
          navigate={@navigate_to}
          class="inline-flex items-center gap-1 text-xs font-bold uppercase tracking-wider text-primary"
        >
          {@cta_label} <.icon name="hero-arrow-right-solid" class="size-4" />
        </.link>

        <.link
          :if={@show_edit && @edit_patch}
          patch={@edit_patch}
          class="inline-flex items-center gap-1 text-xs font-bold uppercase tracking-wider text-base-content/80 hover:text-base-content"
        >
          <.icon name="hero-pencil-square-solid" class="size-4" /> Edit
        </.link>
      </div>
    </article>
    """
  end

  defp status_classes(status) do
    case status do
      :active -> "border border-success/40 bg-success/20 text-success"
      :inactive -> "border border-primary/40 bg-primary/20 text-primary"
      :finished -> "border border-base-300/40 bg-base-200/40 text-base-content/80"
      _ -> "border border-base-300/40 bg-base-200/40 text-base-content/80"
    end
  end

  defp tournament_game_name(%{game: %Ecto.Association.NotLoaded{}}), do: nil
  defp tournament_game_name(%{game: %{name: name}}) when is_binary(name), do: name
  defp tournament_game_name(_), do: nil
end
