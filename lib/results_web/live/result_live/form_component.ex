defmodule ResultsWeb.ResultLive.FormComponent do
  use ResultsWeb, :live_component

  alias Results.Timeline

  @impl true
  def update(%{result: result} = assigns, socket) do
    changeset = Timeline.change_result(result)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"result" => result_params}, socket) do
    changeset =
      socket.assigns.result
      |> Timeline.change_result(result_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"result" => result_params}, socket) do
    save_result(socket, socket.assigns.action, result_params)
  end

  defp save_result(socket, :edit, result_params) do
    case Timeline.update_result(socket.assigns.result, result_params) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Result updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_result(socket, :new, result_params) do
    case Timeline.create_result(result_params) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Result created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
