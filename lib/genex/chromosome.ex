defmodule Genex.Chromosome do
  alias __MODULE__, as: Chromosome

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

  @doc """
  Creates a binary geneset.

  Returns `Enum.t()`.

  # Parameters

    - `opts`: Configuration options.

  # Options
    - `size`: Size of the chromosomes. Defaults to 32.
  """
  def binary(opts \\ []) do
    size = Keyword.get(opts, :size, 32)
    for _ <- 0..(size - 1), do: Enum.random(0..1)
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(chromosome), do: "#{inspect(chromosome.genes)}"
  end
end
