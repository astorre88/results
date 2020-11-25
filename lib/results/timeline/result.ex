defmodule Results.Timeline.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "results" do
    field :name, :string
    field :time, :integer

    timestamps()
  end

  @doc false
  def changeset(result, attrs) do
    result
    |> cast(attrs, [:name, :time])
    |> validate_required([:name, :time])
  end
end
