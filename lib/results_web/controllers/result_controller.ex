defmodule ResultsWeb.ResultController do
  use ResultsWeb, :controller

  alias Results.Timeline
  alias Results.Timeline.Result

  action_fallback ResultsWeb.FallbackController

  def index(conn, _params) do
    results = Timeline.list_results()
    render(conn, "index.json", results: results)
  end

  def create(conn, %{"result" => result_params}) do
    with {:ok, %Result{} = result} <- Timeline.create_result(result_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.result_path(conn, :show, result))
      |> render("show.json", result: result)
    end
  end

  def create(conn, %{"photo" => %Plug.Upload{} = photo} = params) do
    data = File.read!(photo.path)

    detection =
      Results.Worker
      |> Results.Worker.request_detection(data)
      |> Results.Worker.await()
      |> IO.inspect(label: "Detection")

    with {:ok, %Result{} = result} <- Timeline.create_result(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.result_path(conn, :show, result))
      |> render("show.json", result: result)
    end
  end

  def show(conn, %{"id" => id}) do
    result = Timeline.get_result!(id)
    render(conn, "show.json", result: result)
  end

  def update(conn, %{"id" => id, "result" => result_params}) do
    result = Timeline.get_result!(id)

    with {:ok, %Result{} = result} <- Timeline.update_result(result, result_params) do
      render(conn, "show.json", result: result)
    end
  end

  def delete(conn, %{"id" => id}) do
    result = Timeline.get_result!(id)

    with {:ok, %Result{}} <- Timeline.delete_result(result) do
      send_resp(conn, :no_content, "")
    end
  end
end
