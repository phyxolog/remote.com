defmodule BeExercise.Salaries.Salary do
  @moduledoc false

  use BeExercise.Schema

  alias BeExercise.Accounts.User
  alias BeExercise.Salaries.Salary

  @permitted ~w(amount currency active last_active_at user_id)a

  schema "salaries" do
    field :amount, :decimal
    field :currency, :string
    field :active, :boolean

    field :last_active_at, :utc_datetime_usec

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Salary{} = salary, attrs) do
    salary
    |> cast(attrs, @permitted)
    |> validate_required(@permitted)
    |> validate_number(:amount, greater_than: 0)
    |> validate_length(:currency, is: 3)
    |> update_change(:currency, &String.upcase/1)
    |> update_change(:amount, &Decimal.normalize/1)
    |> prepare_changes(&populate_last_active_at/1)
  end

  defp populate_last_active_at(changeset) do
    if get_change(changeset, :active) do
      put_change(changeset, :last_active_at, DateTime.utc_now())
    else
      changeset
    end
  end
end
