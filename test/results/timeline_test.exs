defmodule Results.TimelineTest do
  use Results.DataCase

  alias Results.Timeline

  describe "results" do
    alias Results.Timeline.Result

    @valid_attrs %{name: "some name", phone_time: 42, controller_time: 42}
    @update_attrs %{name: "some updated name", phone_time: 43, controller_time: 43}
    @invalid_attrs %{name: nil, phone_time: nil, controller_time: nil}

    def result_fixture(attrs \\ %{}) do
      {:ok, result} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_result()

      result
    end

    test "list_results/0 returns all results" do
      result = result_fixture()
      assert Timeline.list_results() == [result]
    end

    test "get_result!/1 returns the result with given id" do
      result = result_fixture()
      assert Timeline.get_result!(result.id) == result
    end

    test "create_result/1 with valid data creates a result" do
      assert {:ok, %Result{} = result} = Timeline.create_result(@valid_attrs)
      assert result.name == "some name"
      assert result.phone_time == 42
    end

    test "create_result/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_result(@invalid_attrs)
    end

    test "update_result/2 with valid data updates the result" do
      result = result_fixture()
      assert {:ok, %Result{} = result} = Timeline.update_result(result, @update_attrs)
      assert result.name == "some updated name"
      assert result.phone_time == 43
    end

    test "update_result/2 with invalid data returns error changeset" do
      result = result_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_result(result, @invalid_attrs)
      assert result == Timeline.get_result!(result.id)
    end

    test "delete_result/1 deletes the result" do
      result = result_fixture()
      assert {:ok, %Result{}} = Timeline.delete_result(result)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_result!(result.id) end
    end

    test "change_result/1 returns a result changeset" do
      result = result_fixture()
      assert %Ecto.Changeset{} = Timeline.change_result(result)
    end
  end
end
