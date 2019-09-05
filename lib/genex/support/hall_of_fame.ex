defmodule Genex.Support.HallOfFame do
  @moduledoc """
  Keeps track of the strongest individual of a generation in an ETS table.
  """

  def init, do: :ets.new(:hall_of_fame, [:set, :public, :named_table])

  def add(population) do
    :ets.insert(:hall_of_fame, {population.generation, population.chromosome})
  end
end
