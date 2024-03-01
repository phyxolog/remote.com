defmodule BeExerciseWeb.UserController do
  use BeExerciseWeb, :controller

  alias BeExercise.Accounts

  def index(conn, params) do
    users = Accounts.list_users(params)
    render(conn, :index, users: users)
  end

  def invite(conn, _params) do
    case Accounts.invite_users() do
      {:ok, _job} ->
        render(conn, :invite,
          message:
            "Invitations sent. It may take a few minutes for the invitations to be delivered."
        )

      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:invite,
          message: "Failed to send invitations. Please try again."
        )
    end
  end
end
