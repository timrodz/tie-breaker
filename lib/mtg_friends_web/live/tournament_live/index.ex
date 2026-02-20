defmodule MtgFriendsWeb.TournamentLive.Index do
  use MtgFriendsWeb, :live_view

  alias MtgFriends.Tournaments
  alias MtgFriends.Tournaments.Tournament
  alias MtgFriendsWeb.UserAuth

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
       has_next_page?: has_next_page?(page, count),
       has_previous_page?: has_previous_page?(page),
       total_pages: total_pages(count),
       pagination_items: pagination_items(page, total_pages(count)),
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
    tournament = Tournaments.get_tournament!(id)

    case UserAuth.ensure_can_manage_tournament(socket, tournament, ~p"/tournaments") do
      {:ok, socket} ->
        socket
        |> assign(:page_title, "Edit")
        |> assign(:tournament, tournament)

      {:error, socket} ->
        socket
        |> assign(:page_title, "All Tournaments")
        |> assign(:tournament, nil)
    end
  end

  defp apply_action(socket, :new, _params) do
    if socket.assigns.current_user do
      socket
      |> assign(:page_title, "New Tournament")
      |> assign(:tournament, %Tournament{})
    else
      socket
      |> put_flash(:error, "You must log in to create a tournament.")
      |> redirect(to: ~p"/users/log_in")
    end
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

    with {:ok, socket} <-
           UserAuth.ensure_can_manage_tournament(socket, tournament, ~p"/tournaments"),
         {:ok, _} <- Tournaments.delete_tournament(tournament) do
      {:noreply, stream_delete(socket, :tournaments, tournament)}
    else
      _ ->
        {:noreply, socket}
    end
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
       has_next_page?: has_next_page?(1, count),
       has_previous_page?: false,
       total_pages: total_pages(count),
       pagination_items: pagination_items(1, total_pages(count)),
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

  defp has_next_page?(page, count), do: page < total_pages(count)
  defp has_previous_page?(page), do: page > 1

  defp total_pages(count) do
    div(count + @limit - 1, @limit)
    |> max(1)
  end

  defp pagination_items(page, total_pages) do
    pages =
      [1, page - 1, page, page + 1, total_pages]
      |> Enum.filter(&(&1 >= 1 and &1 <= total_pages))
      |> Enum.uniq()
      |> Enum.sort()

    pages
    |> Enum.reduce({[], nil}, fn current_page, {items, previous_page} ->
      items =
        if previous_page && current_page - previous_page > 1 do
          items ++ [%{type: :ellipsis}]
        else
          items
        end

      {[%{type: :page, page: current_page} | items], current_page}
    end)
    |> elem(0)
  end

  defp maybe_put(map, _key, ""), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
