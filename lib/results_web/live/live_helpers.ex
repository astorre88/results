defmodule ResultsWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Results.Accounts
  alias Results.Accounts.User
  alias ResultsWeb.Router.Helpers, as: Routes

  @doc """
  Renders a component inside the `ResultsWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, ResultsWeb.ResultLive.FormComponent,
        id: @result.id || :new,
        action: @live_action,
        result: @result,
        return_to: Routes.result_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, ResultsWeb.ModalComponent, modal_opts)
  end

  def format_time(time),
    do:
      (time &&
         DateTime.from_unix!(time)
         |> DateTime.shift_zone!("Europe/Moscow")
         |> Timex.format!("{h24}:{m}:{s} {YYYY}-{0M}-{0D}")) || "no time"

  def assign_defaults(session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        find_current_user(session)
      end)

    case socket.assigns.current_user do
      %User{} ->
        socket

      _other ->
        socket
        |> put_flash(:error, "You must log in to access this page.")
        |> redirect(to: Routes.user_session_path(socket, :new))
    end
  end

  defp find_current_user(session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token),
         do: user
  end
end
