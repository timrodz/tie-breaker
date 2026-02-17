defmodule MtgFriendsWeb.TournamentLive.Index do
  use MtgFriendsWeb, :live_view

  alias MtgFriends.Tournaments
  alias MtgFriends.Tournaments.Tournament

  on_mount {MtgFriendsWeb.UserAuth, :mount_current_user}

  @limit 6

  @impl true
  def mount(params, _session, socket) do
    page = parse_page(params)
    filters = build_filters(params, page)

    count = Tournaments.count_tournaments_filtered(filters)
    tournaments = Tournaments.list_tournaments_filtered(filters)

    {:ok,
     socket
     |> stream(:tournaments, tournaments)
     |> assign(
       page: page,
       has_next_page?: count > @limit * page,
       has_previous_page?: page > 1,
       search: Map.get(params, "search", ""),
       filter_format: Map.get(params, "format", ""),
       filter_status: Map.get(params, "status", "")
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit")
    |> assign(:tournament, Tournaments.get_tournament!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tournament")
    |> assign(:tournament, %Tournament{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "All Tournaments")
    |> assign(:tournament, nil)
  end

  @impl true
  def handle_info(
        {MtgFriendsWeb.TournamentLive.TournamentEditFormComponent, {:saved, tournament}},
        socket
      ) do
    # Preload the game association to avoid template errors
    tournament_with_game = Tournaments.get_tournament!(tournament.id)
    {:noreply, stream_insert(socket, :tournaments, tournament_with_game)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tournament = Tournaments.get_tournament!(id)
    {:ok, _} = Tournaments.delete_tournament(tournament)

    {:noreply, stream_delete(socket, :tournaments, tournament)}
  end

  def handle_event("filter", params, socket) do
    search = Map.get(params, "search", "")
    format = Map.get(params, "format", "")
    status = Map.get(params, "status", "")

    filters = build_filters(%{"search" => search, "format" => format, "status" => status}, 1)
    count = Tournaments.count_tournaments_filtered(filters)
    tournaments = Tournaments.list_tournaments_filtered(filters)

    {:noreply,
     socket
     |> stream(:tournaments, tournaments, reset: true)
     |> assign(
       page: 1,
       has_next_page?: count > @limit,
       has_previous_page?: false,
       search: search,
       filter_format: format,
       filter_status: status
     )}
  end

  defp parse_page(params) do
    case Integer.parse(Map.get(params, "page", "1")) do
      {page, ""} when page > 0 -> page
      _ -> 1
    end
  end

  defp build_filters(params, page) do
    %{"limit" => @limit, "page" => page}
    |> maybe_put("search", Map.get(params, "search", ""))
    |> maybe_put("format", Map.get(params, "format", ""))
    |> maybe_put("status", Map.get(params, "status", ""))
  end

  defp maybe_put(map, _key, ""), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
