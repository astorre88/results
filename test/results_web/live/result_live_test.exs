defmodule ResultsWeb.ResultLiveTest do
  use ResultsWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Results.Timeline

  @create_attrs %{name: "some name", time: 42}
  @update_attrs %{name: "some updated name", time: 43}
  @invalid_attrs %{name: nil, time: nil}

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

    test "saves new result", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.result_index_path(conn, :index))

      assert index_live |> element("a", "New Result") |> render_click() =~
               "New Result"

      assert_patch(index_live, Routes.result_index_path(conn, :new))

      assert index_live
             |> form("#result-form", result: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#result-form", result: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.result_index_path(conn, :index))

      assert html =~ "Result created successfully"
      assert html =~ "some name"
    end

    test "updates result in listing", %{conn: conn, result: result} do
      {:ok, index_live, _html} = live(conn, Routes.result_index_path(conn, :index))

      assert index_live |> element("#result-#{result.id} a", "Edit") |> render_click() =~
               "Edit Result"

      assert_patch(index_live, Routes.result_index_path(conn, :edit, result))

      assert index_live
             |> form("#result-form", result: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#result-form", result: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.result_index_path(conn, :index))

      assert html =~ "Result updated successfully"
      assert html =~ "some updated name"
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

    test "updates result within modal", %{conn: conn, result: result} do
      {:ok, show_live, _html} = live(conn, Routes.result_show_path(conn, :show, result))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Result"

      assert_patch(show_live, Routes.result_show_path(conn, :edit, result))

      assert show_live
             |> form("#result-form", result: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#result-form", result: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.result_show_path(conn, :show, result))

      assert html =~ "Result updated successfully"
      assert html =~ "some updated name"
    end
  end
end
