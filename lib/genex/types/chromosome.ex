defmodule Genex.Types.Chromosome do
  alias __MODULE__, as: Chromosome
  alias Statistics.Distributions

  @moduledoc """
  A collection of genes.

  A Chromosome represents one solution to the problem you are trying to solve. Solutions are encoded into an enumerable of genes. The Chromosome is then evaluated based on some criteria you define.
  """

  @type t :: %Chromosome{
          genes: Enum.t(),
          fitness: number(),
          size: integer(),
          age: integer()
        }

  @enforce_keys [:genes]
  defstruct [:genes, fitness: 0, size: 0, age: 0]

  defimpl String.Chars, for: __MODULE__ do
    def to_string(chromosome) do
      "#Chromosome<age: #{chromosome.age}, fitness: #{chromosome.fitness}>"
    end
  end
end
