defmodule Genex.Types.Chromosome do
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
  Creates a binary encoded geneset.

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

  @doc """
  Creates an integer value encoded geneset.

  Returns `Enum.t()`.

  # Parameters

    - `opts`: Configuration options.

  # Options

    - `size`: Size of the chromosome. Defaults to 32.
    - `min`: Minimum number of distribution. Defaults to 0.
    - `max`: Maximum number of distribution. Defaults to 10.
  """
  def integer_value(opts \\ []) do
    size = Keyword.get(opts, :size, 32)
    low = Keyword.get(opts, :min, 0)
    high = Keyword.get(opts, :max, 0)
    for _ <- 0..(size - 1), do: Enum.random(low..high)
  end

  @doc """
  Creates a permutation encoded geneset.

  Returns `Enum.t()`.

  # Parameters

    - `opts`: Configuration options.

  # Options

    - `min`: Minimum number of distribution. Defaults to 1.
    - `max`: Maximum number of distribution. Defaults to 10.
  """
  def permutation(opts \\ []) do
    low = Keyword.get(opts, :min, 1)
    high = Keyword.get(opts, :max, 10)

    low..high
    |> Enum.shuffle()
  end

  @doc """
  Creates an alphabetically encoded geneset.

  Returns `Enum.t()`.

  # Parameters

    - `opts`: Configuration options.

  # Options

    - `size`: Size of the chromosome. Defaults to 10.
  """
  def alphabetic(opts \\ []) do
    size = Keyword.get(opts, :size, 10)

    ?a..?z
    |> Enum.to_list()
    |> Enum.shuffle()
    |> Enum.split(size)
    |> elem(0)
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(chromosome), do: "#{inspect(chromosome.genes)}"
  end
end
