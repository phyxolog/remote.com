defmodule BeExerciseWeb.UserJSON do
  def index(%{users: %Scrivener.Page{} = page}) do
    %{
      data: %{
        users: Enum.map(page.entries, &render_user/1),
        page_number: page.page_number,
        page_size: page.page_size,
        total_pages: page.total_pages,
        total_entries: page.total_entries
      }
    }
  end

  def invite(%{message: message}) do
    %{data: %{message: message}}
  end

  defp render_user(user) do
    %{
      id: user.id,
      name: user.name,
      salary: render_salary(user.salary)
    }
  end

  defp render_salary(nil), do: nil

  defp render_salary(salary) do
    %{
      amount: salary.amount,
      currency: salary.currency
    }
  end
end
