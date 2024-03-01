defmodule BeExercise.AccountsTest do
  use BeExercise.DataCase
  use Oban.Testing, repo: BeExercise.Repo

  alias BeExercise.Repo

  describe "invite_users/0" do
    test "creates a job worker for inviting users" do
      assert {:ok, _} = BeExercise.Accounts.invite_users()

      assert_enqueued(worker: BeExercise.Workers.InviteUsers)
    end
  end

  describe "list_users/1" do
    test "returns a list of users with active salary" do
      user = Repo.insert!(%BeExercise.Accounts.User{name: "John Doe"})

      Repo.insert!(%BeExercise.Salaries.Salary{
        user_id: user.id,
        amount: 1001,
        currency: "EUR",
        active: false,
        last_active_at: nil
      })

      salary =
        Repo.insert!(%BeExercise.Salaries.Salary{
          user_id: user.id,
          amount: 1000,
          currency: "USD",
          active: true,
          last_active_at: DateTime.utc_now()
        })

      assert %Scrivener.Page{entries: users} = BeExercise.Accounts.list_users()

      assert [%BeExercise.Accounts.User{salary: %{amount: amount}}] = users

      assert Decimal.equal?(amount, salary.amount)
    end

    test "returns no salary if there is no active salary and no recent active salary" do
      user = Repo.insert!(%BeExercise.Accounts.User{name: "John Doe"})

      Repo.insert!(%BeExercise.Salaries.Salary{
        user_id: user.id,
        amount: 1001,
        currency: "EUR",
        active: false,
        last_active_at: nil
      })

      Repo.insert!(%BeExercise.Salaries.Salary{
        user_id: user.id,
        amount: 1000,
        currency: "USD",
        active: false,
        last_active_at: nil
      })

      assert %Scrivener.Page{entries: users} = BeExercise.Accounts.list_users()

      assert [%BeExercise.Accounts.User{salary: nil}] = users
    end

    test "returns a list of users with populated salary with last_active_salary if there is no active salary" do
      user = Repo.insert!(%BeExercise.Accounts.User{name: "John Doe"})

      Repo.insert!(%BeExercise.Salaries.Salary{
        user_id: user.id,
        amount: 1001,
        currency: "EUR",
        active: false,
        last_active_at: nil
      })

      salary =
        Repo.insert!(%BeExercise.Salaries.Salary{
          user_id: user.id,
          amount: 1000,
          currency: "USD",
          active: false,
          last_active_at: DateTime.utc_now()
        })

      assert %Scrivener.Page{entries: users} = BeExercise.Accounts.list_users()

      assert [%BeExercise.Accounts.User{salary: %{amount: amount}}] = users

      assert Decimal.equal?(amount, salary.amount)
    end

    test "return a most recent last active salary" do
      user = Repo.insert!(%BeExercise.Accounts.User{name: "John Doe"})

      salary =
        Repo.insert!(%BeExercise.Salaries.Salary{
          user_id: user.id,
          amount: 1001,
          currency: "EUR",
          active: false,
          last_active_at: DateTime.utc_now()
        })

      Repo.insert!(%BeExercise.Salaries.Salary{
        user_id: user.id,
        amount: 1000,
        currency: "USD",
        active: false,
        last_active_at: DateTime.add(DateTime.utc_now(), -1, :day)
      })

      assert %Scrivener.Page{entries: users} = BeExercise.Accounts.list_users()

      assert [%BeExercise.Accounts.User{salary: %{amount: amount}}] = users

      assert Decimal.equal?(amount, salary.amount)
    end
  end
end
