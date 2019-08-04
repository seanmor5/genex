defmodule Genex.Chromosome do
  alias __MODULE__, as: Chromosome
  @moduledoc """
  Chromosome.
  """

  @type t :: %Chromosome{
    genes: Enum.t,
    fitness: number(),
    size: integer(),
    age: integer()
  }

  @enforce_keys [:genes]
  defstruct [:genes, fitness: 0, size: 0, age: 0]

  @doc """
  Return the fitness of chromosome.
  """
  def get_fitness(chromosome), do: chromosome.fitness

  defimpl String.Chars, for: __MODULE__ do
    def to_string(chromosome), do: "#{inspect(chromosome.genes)}"
  end
end
