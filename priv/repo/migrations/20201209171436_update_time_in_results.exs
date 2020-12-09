defmodule Results.Repo.Migrations.UpdateTimeInResults do
  use Ecto.Migration

  def change do
    rename table(:results), :time, to: :phone_time
    alter table(:results) do
      add_if_not_exists(:controller_time, :bigint)
    end
  end
end
