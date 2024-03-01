defmodule BeExercise.Repo do
  use Ecto.Repo, otp_app: :be_exercise, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 100
end
