defmodule ResultsWeb.ResultLiveTest do
  use ResultsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Results.Timeline

  @create_attrs %{name: "some name", phone_time: 42, controller_time: 42}

  defp fixture(:result) do
    {:ok, result} = Timeline.create_result(@create_attrs)
    result
  end

  defp create_result(_) do
    result = fixture(:result)
    %{result: result}
  end

  describe "Index" do
    setup [:create_result]

    test "lists all results", %{conn: conn, result: result} do
      {:ok, _index_live, html} = live(conn, Routes.result_index_path(conn, :index))

      assert html =~ "Listing Results"
      assert html =~ result.name
    end

    test "deletes result in listing", %{conn: conn, result: result} do
      {:ok, index_live, _html} = live(conn, Routes.result_index_path(conn, :index))

      assert index_live |> element("#result-#{result.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#result-#{result.id}")
    end
  end

  describe "Show" do
    setup [:create_result]

    test "displays result", %{conn: conn, result: result} do
      {:ok, _show_live, html} = live(conn, Routes.result_show_path(conn, :show, result))

      assert html =~ "Show Result"
      assert html =~ result.name
    end
  end
end
