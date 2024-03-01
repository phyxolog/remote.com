defmodule BeExercise.Accounts.User do
  @moduledoc false

  use BeExercise.Schema

  alias BeExercise.Accounts.User
  alias BeExercise.Salaries.Salary

  @permitted ~w(name)a

  schema "users" do
    field :name, :string

    has_one :salary, Salary, where: [active: true]

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, @permitted)
    |> validate_required(@permitted)
    |> validate_length(:name, min: 1, max: 255)
  end
end
