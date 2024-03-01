defmodule BeExercise.Repo.Migrations.CreateSalaries do
  use Ecto.Migration

  def change do
    create table(:salaries) do
      add :amount, :decimal, null: false
      add :currency, :string, size: 3, null: false
      add :active, :boolean, null: false, default: false
      add :last_active_at, :utc_datetime_usec, null: true
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:salaries, [:user_id])
    create index(:salaries, [:active])

    create unique_index(:salaries, [:user_id],
             where: "active = TRUE",
             name: "salaries_active_user_id_unique_idx"
           )
  end
end
