defmodule RumblWeb.AuthTest do
  use RumblWeb.ConnCase
  alias RumblWeb.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(RumblWeb.Router, [:browser])
      |> get("/")
    # The returned connection passes through the router and :browser pipeline, which means Auth plug is `call`ed,
    # and assigns[:current_user] is set (to `nil`)
    {:ok, conn: conn}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user continues when the current_user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Rumbl.Accounts.User{})
      |> Auth.authenticate_user([])
    # As we manually set assigns[:current_user] to a user (instead of `nil`), it doesn't halt
    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    # By calling Auth.login, the session[:user_id] is set and gets sent by the client (browser)
    # in subsequent requests. Note that `send_resp` doesn't halt the plug pipeline.
    login_conn =
      conn
      |> Auth.login(%Rumbl.Accounts.User{id: 123})
      |> send_resp(:ok, "")
    # Check that session[:user_id] has the user's `id`
    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    # Initialize the `conn` as `Auth.login` would do, putting the session[:user_id].
    # Then perform the logout (with `Auth.logout`)
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
    # Check that session[:user_id] no longer exists because the session was dropped
    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call places the user from session into assigns", %{conn: conn} do
    user = user_fixture()
    # Although the `Auth` plug was already called in the setup as part of the :browser pipeline, we're going to ignore
    # that and update the session[:user_id] before calling the plug Auth again, this time manually, to test its behavior.
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Auth.init([]))

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    # Even if that's commented and we pass the context's `conn` directly, the test will pass.
    # That's because the `Auth` plug was already when creating the connection in the setop
    conn = Auth.call(conn, Auth.init([]))
    assert conn.assigns.current_user == nil
  end

  test "login with a valid username and pass", %{conn: conn} do
    user = user_fixture(username: "me", email: "me@test", password: "secret")

    {:ok, conn} = Auth.login_by_email_and_pass(conn, "me@test", "secret")
    assert conn.assigns.current_user.id == user.id
  end

  test "login with a not found user", %{conn: conn} do
    assert {:error, :not_found, _conn} =
      Auth.login_by_email_and_pass(conn, "me@test", "secret")
  end

  test "login with password mismatch", %{conn: conn} do
    _user = user_fixture(username: "me", email: "me@test", password: "secret")
    assert {:error, :unauthorized, _conn} = Auth.login_by_email_and_pass(conn, "me@test", "wrongpass")
  end
end
