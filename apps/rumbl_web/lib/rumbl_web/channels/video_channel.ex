alias Rumbl.{Accounts, Multimedia}
alias RumblWeb.AnnotationView
require Logger

defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  def join("videos:" <> video_id, params, socket) do
    last_seen_id = params["last_seen_id"]
    video_id = String.to_integer(video_id)
    video = Multimedia.get_video!(video_id)

    annotations =
      video
      |> Multimedia.list_annotations(last_seen_id)
      |> Phoenix.View.render_many(AnnotationView, "annotation.json")

    {:ok, %{annotations: annotations}, assign(socket, :video_id, video_id)}
  end

  def handle_in(event, params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_annotation", params, user, socket) do
    case Multimedia.annotate_video(user, socket.assigns.video_id, params) do
      # When the annotation was created successfully
      {:ok, annotation} ->
        # Broadcast event to channel
        broadcast_annotation(socket, user, annotation)
        # Compute additional info asynchronously if message follows "@info_sys ..." pattern
        process_infosys_annotation(annotation.body, annotation, socket)
        # Reply with OK (and keep socket's state)
        {:reply, :ok, socket}

      # When there are errors creating the annotation
      {:error, changeset} ->
        # Reply with the changeset's errors (and keep socket's state)
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp process_infosys_annotation("@info_sys "<> message, annotation, socket) do
    # Keep just the message part and update annotation struct directly with it
    modified_ann = %{ annotation | body: message }
    # Launch async task
    Task.start_link(fn -> compute_additional_info(modified_ann, socket) end)
  end

  defp process_infosys_annotation(_body, _annotation, _socket), do: :ignore

  defp broadcast_annotation(socket, user, annotation) do
    broadcast!(socket, "new_annotation", %{
      id: annotation.id,
      user: RumblWeb.UserView.render("user.json", %{user: user}),
      body: annotation.body,
      at: annotation.at
    })
  end

  defp compute_additional_info(annotation, socket) do
    Logger.debug "Computing additional info from channel"
    results = Rumbl.InfoSys.compute(annotation.body, limit: 1, timeout: 10_000)
    Logger.debug "Found #{length(results)} results for query: #{annotation.body}"

    for result <- results do
      backend_user = Accounts.get_user_by(username: result.backend.name())
      attrs = %{url: result.url, body: result.text, at: annotation.at}

      case Multimedia.annotate_video(backend_user, annotation.video_id, attrs) do
        {:ok, info_ann} ->  broadcast_annotation(socket, backend_user, info_ann)
        {:error, _changeset} -> :ignore
      end
    end
  end
end
