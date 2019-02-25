defmodule RumblWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  alias RumblWeb.Router.Helpers, as: Routes
  alias Rumbl.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      # This was added to make testing easier. We leave the connection intact;
      # No matter how the `:current_user` got in the assigns, we honor its presence
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)
      # This is the normal behavior (there's a valid user_id), so we set the `:current_user` assign
      user = user_id && Accounts.get_user(user_id) ->
        put_current_user(conn, user)

      # Otherwise (no user_id or invalid user_id)
      _otherwise = true ->
        assign(conn, :current_user, nil)
    end
  end


  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def login_by_email_and_pass(conn, email, given_pass) do
    case Accounts.authenticate_by_email_and_pass(email, given_pass) do
      {:ok, user} ->
        updated_conn = login(conn, user)
        {:ok, updated_conn}
      {:error, :unauthorized} ->
        {:error, :unauthorized, conn}
      {:error, :not_found} ->
        {:error, :not_found, conn}
    end
  end

  def login(conn, user) do
    conn
    |> put_current_user(user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  # Add into the assigns the entries for `:current_user` and `:user_token`
  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end
end
