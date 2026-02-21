defmodule MtgFriendsWeb.TournamentLive.Round do
  use MtgFriendsWeb, :live_view

  alias MtgFriends.Rounds
  alias MtgFriends.Tournaments
  alias MtgFriends.Utils.Date
  alias MtgFriendsWeb.UserAuth

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{
         "tournament_id" => tournament_id,
         "round_number" => round_number
       }) do
    socket
    |> assign(:selected_pairing_id, nil)
    |> generate_socket(tournament_id, round_number, :index)
  end

  defp apply_action(socket, :edit, %{
         "tournament_id" => tournament_id,
         "round_number" => round_number,
         "pairing_number" => pairing_number_str
       }) do
    case UserAuth.ensure_can_manage_tournament_id(
           socket,
           tournament_id,
           ~p"/tournaments/#{tournament_id}/rounds/#{round_number}"
         ) do
      {:ok, socket} ->
        with {pairing_number, ""} when pairing_number > 0 <- Integer.parse(pairing_number_str),
             {:ok, pairing_id} <-
               get_pairing_id_from_number(tournament_id, round_number, pairing_number) do
          socket
          |> assign(:selected_pairing_id, pairing_id)
          |> generate_socket(tournament_id, round_number, :edit)
        else
          _ ->
            socket
            |> put_flash(:error, "Pairing not found")
            |> assign(:selected_pairing_id, nil)
            |> generate_socket(tournament_id, round_number, :index)
            |> push_patch(to: ~p"/tournaments/#{tournament_id}/rounds/#{round_number}")
        end

      {:error, socket} ->
        socket
        |> assign(:selected_pairing_id, nil)
        |> generate_socket(tournament_id, round_number, :index)
    end
  end

  defp generate_socket(socket, tournament_id, round_number, action) do
    round = Rounds.get_round_from_round_number_str!(tournament_id, round_number)

    forms =
      round.pairings
      |> Enum.map(fn pairing ->
        {pairing.id,
         to_form(%{
           "pairing_id" => pairing.id,
           "participants" =>
             Enum.map(
               Enum.sort_by(pairing.pairing_participants, fn pp -> pp.points end, :desc),
               fn pp ->
                 %{
                   id: pp.participant.id,
                   points: pp.points || 0,
                   name: pp.participant.name
                 }
               end
             )
         })}
      end)
      |> Map.new()

    round_finish_time =
      if not is_nil(round.started_at) and round.status != :finished do
        NaiveDateTime.add(round.started_at, round.tournament.round_length_minutes, :minute)
      else
        nil
      end

    with timer_reference <- Map.get(socket.assigns, :timer_reference),
         false <- is_nil(timer_reference) do
      {:ok, ref} = timer_reference
      :timer.cancel(ref)
    end

    tournament_name = round.tournament.name

    socket
    |> assign(
      timer_reference:
        if(round.status == :active and connected?(socket),
          do: :timer.send_interval(1000, self(), :tick),
          else: nil
        ),
      round_id: round.id,
      round_started_at: round.started_at,
      round_number: round.number,
      round_status: round.status,
      round_finish_time: round_finish_time,
      round_countdown_timer: get_countdown_timer(round_finish_time),
      tournament_id: round.tournament.id,
      tournament_name: tournament_name,
      tournament_rounds: round.tournament.rounds,
      tournament_status: round.tournament.status,
      rounds_remaining: Tournaments.rounds_remaining(round.tournament),
      can_start_new_round?: Tournaments.can_start_new_round?(round.tournament),
      participants: round.tournament.participants,
      pairings: round.pairings,
      page_title: page_title(action, tournament_name, round.number + 1),
      forms: forms
    )
    |> UserAuth.assign_current_user_owner(
      socket.assigns.current_user,
      round.tournament
    )
  end

  defp page_title(:index, tournament_name, round_number),
    do: "#{tournament_name} / Round #{round_number}"

  defp page_title(:edit, tournament_name, round_number),
    do: "#{tournament_name} / Round #{round_number} / Edit Pairing"

  @impl true
  def handle_info(:tick, socket) do
    {:noreply,
     assign(socket,
       round_countdown_timer: get_countdown_timer(socket.assigns.round_finish_time)
     )}
  end

  @impl true
  def handle_event("create-round", _, socket) do
    redirect_to =
      ~p"/tournaments/#{socket.assigns.tournament_id}/rounds/#{socket.assigns.round_number + 1}"

    case UserAuth.ensure_can_manage_tournament_id(
           socket,
           socket.assigns.tournament_id,
           redirect_to
         ) do
      {:ok, socket} ->
        tournament = Tournaments.get_tournament!(socket.assigns.tournament_id)
        handle_create_round(socket, tournament)

      {:error, socket} ->
        {:noreply, socket}
    end
  end

  defp handle_create_round(socket, tournament) do
    if Tournaments.can_start_new_round?(tournament) do
      start_round_and_navigate(socket, tournament)
    else
      {:noreply,
       put_flash(
         socket,
         :error,
         "Cannot start a new round yet. Finish all existing rounds first."
       )}
    end
  end

  defp start_round_and_navigate(socket, tournament) do
    case Rounds.start_round(tournament) do
      {:ok, round} ->
        {:noreply,
         socket
         |> put_flash(:success, "Round #{round.number + 1} created successfully")
         |> push_navigate(to: ~p"/tournaments/#{tournament.id}/rounds/#{round.number + 1}")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  defp get_countdown_timer(round_end_time) do
    case round_end_time do
      nil ->
        ""

      _ ->
        time_diff = NaiveDateTime.diff(round_end_time, NaiveDateTime.utc_now())

        if time_diff > 0 do
          {time_diff, Date.to_hh_mm_ss(time_diff)}
        else
          {0, "00:00"}
        end
    end
  end

  defp get_pairing_id_from_number(tournament_id, round_number, pairing_number) do
    round = Rounds.get_round_from_round_number_str!(tournament_id, round_number)

    case Enum.at(round.pairings, pairing_number - 1) do
      nil -> :error
      pairing -> {:ok, pairing.id}
    end
  end
end
