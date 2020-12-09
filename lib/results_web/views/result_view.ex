defmodule ResultsWeb.ResultView do
  use ResultsWeb, :view
  alias ResultsWeb.ResultView

  def render("index.json", %{results: results}) do
    %{data: render_many(results, ResultView, "result.json")}
  end

  def render("show.json", %{result: result}) do
    %{data: render_one(result, ResultView, "result.json")}
  end

  def render("result.json", %{result: result}) do
    %{
      id: result.id,
      name: result.name,
      phone_time: result.phone_time,
      controller_time: result.controller_time
    }
  end
end
