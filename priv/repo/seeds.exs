# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BeExercise.Repo.insert!(%BeExercise.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

salaries = 10_000..95_000
names = BEChallengex.list_names()
currencies = ["USD", "EUR", "GBP", "JPY", "CNY"]

raw_users =
  Enum.map(1..20_000, fn _ ->
    name = Enum.random(names)
    %{name: name, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()}
  end)

BeExercise.Repo.transaction(fn ->
  {_, users} =
    BeExercise.Repo.insert_all(BeExercise.Accounts.User, raw_users, returning: true, log: false)

  raw_salaries =
    Enum.flat_map(users, fn user ->
      [salary1, salary2] =
        Enum.map(1..2, fn _ ->
          active = Enum.random([true, false])
          last_active_at = if active, do: DateTime.utc_now(), else: nil

          %{
            active: active,
            user_id: user.id,
            last_active_at: last_active_at,
            amount: Enum.random(salaries),
            currency: Enum.random(currencies),
            inserted_at: DateTime.utc_now(),
            updated_at: DateTime.utc_now()
          }
        end)

      if salary1.active and salary2.active do
        [salary1, %{salary2 | active: false, last_active_at: nil}]
      else
        [salary1, salary2]
      end
    end)

  for chunk <- Enum.chunk_every(raw_salaries, 5_000) do
    BeExercise.Repo.insert_all(BeExercise.Salaries.Salary, chunk, log: false)
  end
end)
