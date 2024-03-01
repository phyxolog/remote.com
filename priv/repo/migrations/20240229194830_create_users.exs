defmodule BeExercise.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, size: 255, null: false

      timestamps()
    end
  end
end
