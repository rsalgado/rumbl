defmodule RumblWeb.Channels.VideoChannelTest do
  use RumblWeb.ChannelCase
  import RumblWeb.TestHelpers

  setup do
    user = insert_user(name: "Gary")
    video = insert_video(user, title: "Testing")
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)
    {:ok, socket} = connect(RumblWeb.UserSocket, %{"token" => token})

    {:ok, socket: socket, user: user, video: video}
  end

  test "inserting new annotations", %{socket: socket, video: vid} do
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{vid.id}")
    ref = push(socket, "new_annotation", %{body: "the body", at: 0})
    assert_reply(ref, :ok, %{})
    assert_broadcast("new_annotation", %{})
  end

  test "new annotations starting with @info_sys trigger InfoSys", %{socket: socket, video: vid} do
    # Insert wolfram user
    insert_user(%{
      username: "wolfram",
      credential: %{
        email: "wolfie@example.com",
        password: "supersecret",
        password_confirmation: "supersecret"
      }
    })
    # Subscribe and join the channel for the setup video
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{vid.id}", %{})
    # Send annotation with message to @info_sys (use the mockup message of "1 + 1")
    ref = push(socket, "new_annotation", %{body: "@info_sys 1 + 1", at: 123})
    assert_reply(ref, :ok, %{})
    # Check that the annotation was broadcasted and check that info_sys answer
    # was broadcasted too
    assert_broadcast("new_annotation", %{body: "@info_sys 1 + 1", at: 123})
    assert_broadcast("new_annotation", %{body: "2", at: 123})
  end
end
