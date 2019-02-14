alias Rumbl.{Accounts, Multimedia}

defmodule RumblWeb.VideoChannel do
  use RumblWeb, :channel

  def join("videos:" <> video_id, _params, socket) do
    {:ok, assign(socket, :video_id, String.to_integer(video_id))}
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
        broadcast!(socket, "new_annotation", %{
          id: annotation.id,
          user: RumblWeb.UserView.render("user.json", %{user: user}),
          body: annotation.body,
          at: annotation.at
        })
        # Reply with OK (and keep socket's state)
        {:reply, :ok, socket}

      # When there are errors creating the annotation
      {:error, changeset} ->
        # Reply with the changeset's errors (and keep socket's state)
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
