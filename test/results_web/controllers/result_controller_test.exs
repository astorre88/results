defmodule ResultsWeb.ResultControllerTest do
  use ResultsWeb.ConnCase

  alias Results.Timeline
  alias Results.Timeline.Result

  @create_attrs %{
    name: "some name",
    phone_time: 42,
    controller_time: 42
  }
  @update_attrs %{
    name: "some updated name",
    phone_time: 43,
    controller_time: 43
  }
  @invalid_attrs %{name: nil, phone_time: nil, controller_time: nil}

  def fixture(:result) do
    {:ok, result} = Timeline.create_result(@create_attrs)
    result
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all results", %{conn: conn} do
      conn = get(conn, Routes.result_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create result" do
    test "renders result when data is valid", %{conn: conn} do
      conn = post(conn, Routes.result_path(conn, :create), result: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.result_path(conn, :show, id))

      assert %{
               "id" => _,
               "name" => "some name",
               "phone_time" => 42,
               "controller_time" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.result_path(conn, :create), result: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update result" do
    setup [:create_result]

    test "renders result when data is valid", %{conn: conn, result: %Result{id: id} = result} do
      conn = put(conn, Routes.result_path(conn, :update, result), result: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.result_path(conn, :show, id))

      assert %{
               "id" => _,
               "name" => "some updated name",
               "phone_time" => 43,
               "controller_time" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, result: result} do
      conn = put(conn, Routes.result_path(conn, :update, result), result: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete result" do
    setup [:create_result]

    test "deletes chosen result", %{conn: conn, result: result} do
      conn = delete(conn, Routes.result_path(conn, :delete, result))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.result_path(conn, :show, result))
      end
    end
  end

  defp create_result(_) do
    result = fixture(:result)
    %{result: result}
  end
end
