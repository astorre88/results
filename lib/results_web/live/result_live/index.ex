defmodule ResultsWeb.ResultLive.Index do
  use ResultsWeb, :live_view

  alias Results.Timeline

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    if connected?(socket), do: Timeline.subscribe()

    {:ok, assign(socket, :results, list_results())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Result")
    |> assign(:result, Timeline.get_result!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Results")
    |> assign(:result, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    result = Timeline.get_result!(id)
    {:ok, _} = Timeline.delete_result(result)

    {:noreply, assign(socket, :results, list_results())}
  end

  @impl true
  def handle_event("clean", _params, socket) do
    {:ok, _} = Timeline.delete_all_results()

    {:noreply, assign(socket, :results, list_results())}
  end

  @impl true
  def handle_info({:result_created, result}, socket) do
    {:noreply, update(socket, :results, fn results -> [result | results] end)}
  end

  defp list_results do
    Timeline.list_results()
  end
end
