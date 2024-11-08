defmodule BeExercise.Schema do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
