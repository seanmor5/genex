defmodule Genex.Types.Chromosome do
  alias __MODULE__, as: Chromosome

  @moduledoc """
  A collection of genes.

  A Chromosome represents one solution to the problem you are trying to solve. Solutions are encoded into an enumerable of genes. The Chromosome is then evaluated based on some criteria you define.
  """

  @type t :: %Chromosome{
          genes: Enum.t(),
          fitness: number() | Enum.t(),
          weights: number() | Enum.t(),
          f: (t -> number() | Enum.t()),
          size: integer(),
          age: integer()
        }

  @enforce_keys [:genes]
  defstruct [:genes, fitness: 0, weights: 1, f: nil, size: 0, age: 0]
end
