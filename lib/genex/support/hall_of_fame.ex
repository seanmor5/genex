defmodule Genex.Support.HallOfFame do
  @moduledoc """
  Keeps track of the strongest individual of a generation in an ETS table.

  The hall of fame makes it easy to track the strongest individual between generations. It's a simple ETS table with the Key-Value pair of {Generation, Chromosome}.

  The hall of fame can be accessed at anytime as an ETS named table with name `:hall_of_fame`.
  """

  @doc """
  Create a new Hall of Fame.

  This will create an ETS named table called, `:hall_of_fame`.

  Returns `:ok`.
  """
  def new, do: :ets.new(:hall_of_fame, [:set, :public, :named_table])

  @doc """
  Add a generation to Hall of Fame.

  This will add the current generation and strongest chromosome for a generation.

  Returns `:ok`.

  # Parameters

    - `population`: `%Population{}` to add.
  """
  def add(population) do
    :ets.insert(:hall_of_fame, {population.generation, population.strongest})
  end

  @doc """
  Exports the named table to a file.

  This function is kind of broken.

  Returns `{:ok, fname}`.

  # Parameters

    - `path`: Path to save to. Defaults to current directory.
  """
  def export(path \\ "") do
    {:ok, dtg} = DateTime.now("Etc/UTC")

    name =
      dtg
      |> DateTime.to_string()
      |> String.replace(" ", "_")
      |> Kernel.<>(".hall_of_fame")
      |> String.to_charlist()

    :ok = :ets.tab2file(:hall_of_fame, name)
    {:ok, name}
  end
end
