defmodule Genex.Support.HallOfFame do
  @moduledoc """
  Keeps track of the strongest individual of a generation in an ETS table.
  """

  def init, do: :ets.new(:hall_of_fame, [:set, :public, :named_table])

  def add(population) do
    :ets.insert(:hall_of_fame, {population.generation, population.strongest})
  end

  def save(path \\ "") do
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
