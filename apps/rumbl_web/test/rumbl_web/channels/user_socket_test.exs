defmodule RumblWeb.Channels.UserSocketTest do
  use RumblWeb.ChannelCase, async: true
  alias RumblWeb.UserSocket

  test "socket authentication with valid token" do
    # Generate a valid token
    token = Phoenix.Token.sign(@endpoint, "user socket", "123")
    # Verify that simulating a socket connection succeeds and that the `user_id`
    # put into the socket's assigns
    assert {:ok, socket} = connect(UserSocket, %{"token" => token})
    assert socket.assigns.user_id == "123"
  end

  test "socket authentication with invalid token" do
    # Attempt to connect with an invalid token
    assert :error = connect(UserSocket, %{"token" => "some invalid token"})
    # Attempt to connect without a token at all
    assert :error = connect(UserSocket, %{})
  end
end
