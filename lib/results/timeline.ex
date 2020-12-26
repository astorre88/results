defmodule Results.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Results.Repo

  alias Results.Timeline.Result

  @doc """
  Returns the list of results.

  ## Examples

      iex> list_results()
      [%Result{}, ...]

  """
  def list_results do
    Result
    |> order_by(desc: :id)
    |> Repo.all()
  end

  @doc """
  Gets a single result.

  Raises `Ecto.NoResultsError` if the Result does not exist.

  ## Examples

      iex> get_result!(123)
      %Result{}

      iex> get_result!(456)
      ** (Ecto.NoResultsError)

  """
  def get_result!(id), do: Repo.get!(Result, id)

  @doc """
  Creates a result.

  ## Examples

      iex> create_result(%{field: value})
      {:ok, %Result{}}

      iex> create_result(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_result(attrs \\ %{}) do
    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:result_created)
  end

  @doc """
  Updates a result.

  ## Examples

      iex> update_result(result, %{field: new_value})
      {:ok, %Result{}}

      iex> update_result(result, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_result(%Result{} = result, attrs) do
    result
    |> Result.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a result.

  ## Examples

      iex> delete_result(result)
      {:ok, %Result{}}

      iex> delete_result(result)
      {:error, %Ecto.Changeset{}}

  """
  def delete_result(%Result{} = result) do
    Repo.delete(result)
  end

  @doc """
  Deletes all results.

  ## Examples

      iex> delete_all_results()
      {1, nil}

      iex> delete_all_results()
      {0, nil}

  """
  def delete_all_results() do
    Repo.delete_all(Result)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking result changes.

  ## Examples

      iex> change_result(result)
      %Ecto.Changeset{data: %Result{}}

  """
  def change_result(%Result{} = result, attrs \\ %{}) do
    Result.changeset(result, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Results.PubSub, "results")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Results.PubSub, "results", {event, result})
    {:ok, result}
  end
end
