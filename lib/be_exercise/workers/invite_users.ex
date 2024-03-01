defmodule BeExercise.Workers.InviteUsers do
  @moduledoc """
  This worker sends an email to all users that have an active salary.

  If the email fails to send, it will create a new job to retry for each user.
  """

  use Oban.Worker, max_attempts: 1

  import Ecto.Query, only: [join: 4]

  alias BeExercise.Accounts.User
  alias BeExercise.Repo

  require Logger

  @batch_size 1_000

  @doc false
  @impl Oban.Worker
  def perform(%Job{args: %{"user_id" => user_id}}) do
    case Repo.get_by(User, id: user_id) do
      %User{} = user -> ensure_send_email(user)
      nil -> :ok
    end
  end

  def perform(_job) do
    {:ok, streams} =
      Repo.transaction(fn ->
        User
        |> join(:inner, [u], s in assoc(u, :salary))
        |> Repo.stream(max_rows: @batch_size)
        |> Stream.chunk_every(@batch_size)
        |> Enum.map(fn batch ->
          Task.async_stream(batch, &ensure_send_email/1)
        end)
      end)

    Enum.each(streams, &Stream.run/1)
  end

  defp ensure_send_email(user) do
    with {:error, _reason} <- BEChallengex.send_email(%{name: user.name}) do
      Logger.error("Failed to send an email to user##{user.id}, retrying...")

      # in this case I assume that send_email will fail really rarely
      # so it will create a new job to retry for each user
      # in case of a real world scenario we should collect failed users and create only one job

      request = new(%{user_id: user.id}, max_attempts: 20)
      {indicator, _} = Oban.insert(request)
      indicator
    end
  end
end
