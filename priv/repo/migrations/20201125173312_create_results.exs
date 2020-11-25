defmodule Results.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :name, :string
      add :time, :bigint

      timestamps()
    end

  end
end
