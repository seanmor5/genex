defmodule Genex.Chromosome do
  alias __MODULE__, as: Chromosome
  @moduledoc """
  Chromosome.
  """

  @type t :: %Chromosome{
    genes: Enum.t,
    fitness: number()
  }

  @enforce_keys [:genes]
  defstruct [:genes, fitness: 0]

  @doc """
  Return the fitness of chromosome.
  """
  def get_fitness(chromosome), do: chromosome.fitness
end
