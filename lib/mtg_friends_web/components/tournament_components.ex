defmodule MtgFriendsWeb.TournamentComponents do
  @moduledoc """
  components tailored to tournaments
  """
  use Phoenix.Component

  import MtgFriendsWeb.CoreComponents
  import MtgFriendsWeb.ExtendedCoreComponents

  attr :status, :atom, required: true
  attr :class, :string, default: nil

  def tournament_status_badge(assigns) do
    ~H"""
    <span class={[
      "rounded-2xl px-2.5 py-1 text-xs font-bold uppercase",
      status_classes(@status),
      @class
    ]}>
      {render_status(@status)}
    </span>
    """
  end

  attr :format, :atom, default: nil
  attr :class, :string, default: nil

  def tournament_format(assigns) do
    ~H"""
    <span class={@class}>
      {render_format(@format)}
    </span>
    """
  end

  attr :subformat, :atom, default: nil
  attr :class, :string, default: nil

  def tournament_subformat(assigns) do
    ~H"""
    <span class={@class}>
      {render_subformat(@subformat)}
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
        "tb-panel-strong group rounded-2xl p-5 transition-colors",
        @class
      ]}
    >
      <div class="mb-4 border-b border-base-300/60 pb-4">
        <p class="line-clamp-1 text-xl font-bold tracking-tight text-base-content capitalize">
          {@tournament.name}
        </p>
      </div>

      <div :if={@progress_text || @show_status} class="mb-3 flex items-center justify-between gap-3">
        <p
          :if={@progress_text}
          class="text-xs font-bold uppercase tracking-wider text-base-content/60"
        >
          {@progress_text}
        </p>
        <.tournament_status_badge :if={@show_status} status={@tournament.status} />
      </div>

      <div class="space-y-2 text-sm text-base-content/80">
        <p class="inline-flex items-center gap-1 capitalize">
          <.icon name="hero-map-pin-solid" class="size-4" />{@tournament.location}
        </p>
        <p class="inline-flex items-center gap-1">
          <.date dt={@tournament.date} />
        </p>
        <p :if={@game_name} class="inline-flex items-center gap-1">
          <.icon name="hero-puzzle-piece" class="size-4" />
          {@game_name}
        </p>
        <p :if={Map.get(@tournament, :round_count)} class="inline-flex items-center gap-1">
          <.icon name="hero-clock" class="size-4" />
          {@tournament.round_count} Rounds
        </p>
        <p :if={@show_format} class="inline-flex items-center gap-1">
          <.icon name="hero-squares-2x2-solid" class="size-4" />
          <.tournament_format format={@tournament.format} />
        </p>
        <p :if={@player_count} class="inline-flex items-center gap-1">
          <.icon name="hero-users-solid" class="size-4" />
          {@player_count} Players
        </p>
      </div>

      <div class="mt-5 flex items-center justify-between border-t border-base-300/60 pt-4">
        <.button
          navigate={@navigate_to}
          variant="soft"
          class="btn-sm inline-flex items-center gap-1 text-xs font-bold uppercase tracking-wider"
        >
          {@cta_label} <.icon name="hero-arrow-right-solid" class="size-4" />
        </.button>

        <.button
          :if={@show_edit && @edit_patch}
          patch={@edit_patch}
          variant="neutral"
          class="btn-sm inline-flex items-center gap-1 text-xs font-bold uppercase tracking-wider"
        >
          <.icon name="hero-pencil-square-solid" class="size-4" /> Edit
        </.button>
      </div>
    </article>
    """
  end

  defp status_classes(:active), do: "border border-success/40 bg-success/20 text-success"
  defp status_classes(:inactive), do: "border border-primary/40 bg-primary/20 text-primary"
  defp status_classes(:finished), do: "border border-error/40 bg-error/20 text-error"
  defp status_classes(_), do: "border border-base-300/40 bg-base-200/40 text-base-content"

  defp tournament_game_name(%{game: %Ecto.Association.NotLoaded{}}), do: nil
  defp tournament_game_name(%{game: %{name: name}}) when is_binary(name), do: name
  defp tournament_game_name(_), do: nil

  @spec render_status(atom()) :: String.t()
  def render_status(:inactive), do: "Open"
  def render_status(:active), do: "In progress"
  def render_status(:finished), do: "Finished"
  def render_status(status), do: status

  @spec render_round_status(atom()) :: String.t()
  def render_round_status(:inactive), do: "Pairing players"
  def render_round_status(:active), do: "In progress"
  def render_round_status(:finished), do: "Finished"
  def render_round_status(status), do: status

  @doc """
  Renders tournament format as display text.
  """
  @spec render_format(atom() | nil) :: String.t()
  def render_format(:edh), do: "Commander (EDH)"
  def render_format(:standard), do: "Standard"
  def render_format(format), do: format

  @doc """
  Renders tournament subformat as display text.
  """
  @spec render_subformat(atom() | nil) :: String.t()
  def render_subformat(:bubble_rounds), do: "Bubble Rounds"
  def render_subformat(:swiss), do: "Swiss Rounds"
  def render_subformat(:round_robin), do: "Round Robin"
  def render_subformat(format), do: format
end
