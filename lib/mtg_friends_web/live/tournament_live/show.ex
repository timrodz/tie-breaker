defmodule MtgFriendsWeb.TournamentLive.Show do
  use MtgFriendsWeb, :live_view

  alias MtgFriends.Participants
  alias MtgFriends.QR
  alias MtgFriends.Rounds
  alias MtgFriends.Tournaments
  alias MtgFriends.Utils.Date
  alias MtgFriendsWeb.UserAuth

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    tournament =
      Tournaments.get_tournament!(id)

    tournament_public_url = tournament_public_url(tournament.id)

    participant_score_lookup =
      Participants.get_participant_standings(tournament.participants)
      |> Map.new(fn %{id: id, total_score: total_score, win_rate: win_rate} ->
        {id,
         %{
           total_score: total_score,
           total_score_sort_by: total_score |> Decimal.round(3),
           win_rate: win_rate
         }}
      end)

    winner =
      case tournament.status == :finished do
        false ->
          nil

        true ->
          tournament.participants |> Enum.find(fn p -> p.is_tournament_winner == true end)
      end

    participant_forms =
      to_form(%{
        "participants" =>
          tournament.participants
          |> Enum.map(fn participant ->
            %{
              "id" => participant.id,
              "name" => participant.name,
              "decklist" => participant.decklist,
              "is_tournament_winner" => participant.is_tournament_winner,
              "is_dropped" => participant.is_dropped,
              "scores" => Map.get(participant_score_lookup, participant.id, nil)
            }
          end)
          # Sort players by winner & highest to lowest overall scores
          |> Enum.sort_by(
            &{&1["is_tournament_winner"],
             (&1["scores"] && &1["scores"].total_score_sort_by) || nil},
            :desc
          )
      })

    %{current_user: current_user, live_action: live_action} = socket.assigns

    rounds_desc = Enum.sort_by(tournament.rounds, & &1.number, :desc)
    active_round = Enum.find(tournament.rounds, fn round -> round.status == :active end)
    latest_round = List.first(rounds_desc)

    socket =
      socket
      |> UserAuth.assign_current_user_owner(current_user, tournament)
      |> UserAuth.assign_current_user_admin(socket.assigns.current_user)
      |> assign(:has_winner?, not is_nil(winner))
      |> assign(:page_title, page_title(live_action, tournament.name |> String.capitalize()))
      |> assign(:tournament, tournament)
      |> assign(:tournament_public_url, tournament_public_url)
      |> assign(:tournament_qr_svg, QR.svg(tournament_public_url))
      |> assign(:rounds, tournament.rounds)
      |> assign(:rounds_desc, rounds_desc)
      |> assign(:active_round, active_round)
      |> assign(:latest_round, latest_round)
      |> assign(:time_remaining, active_round_time_remaining(active_round, tournament))
      |> assign(
        :is_current_round_active?,
        with len <- length(tournament.rounds), true <- len > 0 do
          round = Enum.at(tournament.rounds, len - 1)
          status = Map.get(round, :status)
          status != :finished
        else
          _ -> false
        end
      )
      |> assign(
        :all_participants_have_names?,
        Enum.all?(tournament.participants, fn p -> not is_nil(p.name) end)
      )
      |> assign(
        :has_enough_participants?,
        Tournaments.has_enough_participants?(tournament)
      )
      |> assign(:participant_forms, participant_forms)

    socket =
      if live_action == :edit do
        case UserAuth.ensure_can_manage_tournament(
               socket,
               tournament,
               ~p"/tournaments/#{tournament.id}"
             ) do
          {:ok, socket} -> socket
          {:error, socket} -> socket
        end
      else
        socket
      end

    {:noreply, socket}
  end

  defp page_title(:show, tournament_name), do: "#{tournament_name}"
  defp page_title(:edit, tournament_name), do: "Edit #{tournament_name}"

  defp tournament_public_url(tournament_id) do
    MtgFriendsWeb.Endpoint.url() <> ~p"/tournaments/#{tournament_id}"
  end

  @impl true
  def handle_event("create-round", _, socket) do
    tournament = socket.assigns.tournament

    case UserAuth.ensure_can_manage_tournament(
           socket,
           tournament,
           ~p"/tournaments/#{tournament.id}"
         ) do
      {:ok, socket} ->
        case Rounds.start_round(tournament) do
          {:ok, round} ->
            {:noreply,
             socket
             |> put_flash(:success, "Round #{round.number + 1} created successfully")
             |> push_navigate(to: ~p"/tournaments/#{tournament.id}/rounds/#{round.number + 1}")}

          {:error, reason} ->
            {:noreply, put_flash(socket, :error, reason)}
        end

      {:error, socket} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("create-participant", _, socket) do
    tournament = socket.assigns.tournament
    tournament_id = tournament.id

    case UserAuth.ensure_can_manage_tournament(
           socket,
           tournament,
           ~p"/tournaments/#{tournament.id}"
         ) do
      {:ok, socket} ->
        case Participants.create_empty_participant(tournament_id) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:success, "Participant created successfully")
             |> reload_page()}

          {:error, %Ecto.Changeset{} = _} ->
            {:noreply,
             put_flash(socket, :error, "Something wrong happened when adding a participant")}
        end

      {:error, socket} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("update-participants", params, socket) do
    tournament = socket.assigns.tournament

    case UserAuth.ensure_can_manage_tournament(
           socket,
           tournament,
           ~p"/tournaments/#{tournament.id}"
         ) do
      {:ok, socket} ->
        case Participants.update_participants_for_tournament(
               tournament.id,
               tournament.participants,
               params
             ) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:success, "Tournament updated successfully")
             |> reload_page()}

          {:error, _, error, _} ->
            {:noreply, socket |> put_flash(:error, error)}

          {:error, :no_changes_detected} ->
            {:noreply, socket |> put_flash(:warning, "No changes detected")}
        end

      {:error, socket} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete-participant", %{"id" => id}, socket) do
    tournament = socket.assigns.tournament
    participant = Participants.get_participant!(id)

    if participant.tournament_id != tournament.id do
      {:noreply,
       socket
       |> put_flash(:error, "Participant does not belong to this tournament.")
       |> reload_page()}
    else
      case UserAuth.ensure_can_manage_tournament(
             socket,
             tournament,
             ~p"/tournaments/#{tournament.id}"
           ) do
        {:ok, socket} ->
          {:ok, _} = Participants.delete_participant(participant)
          {:noreply, reload_page(socket)}

        {:error, socket} ->
          {:noreply, socket}
      end
    end
  end

  @impl true
  def handle_event("drop-participant", %{"id" => id}, socket) do
    tournament = socket.assigns.tournament
    participant = Participants.get_participant!(id)

    if participant.tournament_id != tournament.id do
      {:noreply,
       socket
       |> put_flash(:error, "Participant does not belong to this tournament.")
       |> reload_page()}
    else
      case UserAuth.ensure_can_manage_tournament(
             socket,
             tournament,
             ~p"/tournaments/#{tournament.id}"
           ) do
        {:ok, socket} ->
          {:ok, _} = Participants.update_participant(participant, %{"is_dropped" => true})
          {:noreply, reload_page(socket)}

        {:error, socket} ->
          {:noreply, socket}
      end
    end
  end

  @impl true
  def handle_event("delete-round", %{"id" => id}, socket) do
    tournament = socket.assigns.tournament
    round = Rounds.get_round!(id)

    if round.tournament_id != tournament.id do
      {:noreply,
       socket
       |> put_flash(:error, "Round does not belong to this tournament.")
       |> reload_page()}
    else
      case UserAuth.ensure_can_manage_tournament(
             socket,
             tournament,
             ~p"/tournaments/#{tournament.id}"
           ) do
        {:ok, socket} ->
          {:ok, _} = Rounds.delete_round(round)
          {:noreply, reload_page(socket)}

        {:error, socket} ->
          {:noreply, socket}
      end
    end
  end

  @impl true
  def handle_event("finish-tournament", _, socket) do
    tournament = socket.assigns.tournament

    case UserAuth.ensure_can_manage_tournament(
           socket,
           tournament,
           ~p"/tournaments/#{tournament.id}"
         ) do
      {:ok, socket} ->
        {:ok, _} = Tournaments.update_tournament(tournament, %{"status" => :finished})
        {:noreply, socket |> put_flash(:success, "The tournament has ended") |> reload_page()}

      {:error, socket} ->
        {:noreply, socket}
    end
  end

  defp reload_page(socket) do
    socket |> push_navigate(to: ~p"/tournaments/#{socket.assigns.tournament.id}", replace: true)
  end

  defp active_round_time_remaining(nil, _tournament), do: "--:--"

  defp active_round_time_remaining(round, tournament) do
    case round.started_at do
      nil ->
        "--:--"

      started_at ->
        finish_time = NaiveDateTime.add(started_at, tournament.round_length_minutes, :minute)
        seconds_left = NaiveDateTime.diff(finish_time, NaiveDateTime.utc_now())

        if seconds_left > 0 do
          Date.to_hh_mm_ss(seconds_left)
        else
          "00:00"
        end
    end
  end
end
