defmodule RumblWeb.TestHelpers do
  alias Rumbl.{Accounts, Multimedia}

  defp default_user() do
    %{
      name: "Some User",
      username: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}",
      credential: %{
        email: "eva@test",
        password: "supersecret"
      }
    }
  end

  defp default_video() do
    %{
      url: "video.example/url",
      description: "example video",
      body: "example body"
    }
  end

  def insert_user(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(default_user())
      |> Accounts.register_user()

    user
  end

  def insert_video(user, attrs \\ %{}) do
    video_fields = Enum.into(attrs, default_video())
    {:ok, video} = Multimedia.create_video(user, video_fields)

    video
  end

  def login(%{conn: conn, login_as: username}) do
    user = insert_user(%{username: username})
    updated_conn = Plug.Conn.assign(conn, :current_user, user)

    {updated_conn, user}
  end
  def login(%{conn: conn}), do:   {conn, :logged_out}
end
