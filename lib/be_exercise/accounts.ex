defmodule BeExercise.Accounts do
  @moduledoc false

  import Ecto.Query

  alias BeExercise.Repo
  alias BeExercise.Accounts.User
  alias BeExercise.Salaries.Salary

  @doc """
  Creates a new job that sends an email to all users that have active salary.
  """
  @spec invite_users() :: {:ok, Oban.Job.t()} | {:error, Oban.Job.changeset() | term()}
  def invite_users do
    %{}
    |> BeExercise.Workers.InviteUsers.new()
    |> Oban.insert()
  end

  @doc """
  Lists all users. Populates the last active salary for users that have no active salary.

  Returns a paginated list of users.
  """
  @spec list_users(map()) :: Scrivener.Page.t()
  def list_users(params \\ %{}) do
    filter_clauses = list_users_filter(params)
    order_by_clauses = list_users_order_by(params, asc: :name)

    User
    |> where(^filter_clauses)
    |> order_by(^order_by_clauses)
    |> preload([:salary])
    |> Repo.paginate(params)
    |> Map.update!(:entries, &populate_last_active_salary/1)
  end

  defp populate_last_active_salary(users) do
    inactive_salary_users_ids =
      users
      |> Stream.filter(&is_nil(&1.salary))
      |> Stream.map(& &1.id)
      |> Enum.to_list()

    last_active_salary_query =
      Salary
      |> where([s], parent_as(:user).id == s.user_id)
      |> where([s], not is_nil(s.last_active_at))
      |> order_by(desc: :last_active_at)
      |> limit(1)

    last_active_salaries =
      User
      |> from(as: :user)
      |> join(:inner_lateral, [u], s in subquery(last_active_salary_query), on: true)
      |> where([u], u.id in ^inactive_salary_users_ids)
      |> select([u, s], %{user_id: u.id, amount: s.amount, currency: s.currency})
      |> Repo.all()
      |> Map.new(&{&1.user_id, &1})

    Enum.map(users, fn %User{} = user ->
      case Map.fetch(last_active_salaries, user.id) do
        {:ok, last_active_salary} ->
          %User{user | salary: last_active_salary}

        :error ->
          user
      end
    end)
  end

  defp list_users_order_by(%{"order_by" => order_by}, _default) do
    Enum.reduce(order_by, [], fn
      "name." <> direction, acc ->
        [{get_order_direction(direction), :name} | acc]

      _, acc ->
        acc
    end)
  end

  defp list_users_order_by(_params, default), do: default

  defp list_users_filter(params) do
    Enum.reduce(params, dynamic(true), fn
      {_, ""}, acc ->
        acc

      {"name", name}, acc ->
        dynamic([u], ^acc and ilike(u.name, ^"#{name}%"))

      {_, _}, acc ->
        acc
    end)
  end

  defp get_order_direction("asc"), do: :asc
  defp get_order_direction("desc"), do: :desc
  defp get_order_direction(_), do: :asc
end
