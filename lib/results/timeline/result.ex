defmodule Results.Timeline.Result do
  use Ecto.Schema

  import Ecto.Changeset

  @required ~w(name phone_time controller_time)a

  schema "results" do
    field :name, :string
    field :phone_time, :integer
    field :controller_time, :integer

    timestamps()
  end

  @doc false
  def changeset(result, attrs) do
    result
    |> cast(attrs, @required)
    |> validate_required(@required)
  end
end
