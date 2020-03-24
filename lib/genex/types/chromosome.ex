defmodule Genex.Types.Chromosome do
  alias __MODULE__, as: Chromosome

  @moduledoc """
  Genex representation of a single solution.

  A Chromosome represents one solution to the problem you are trying to solve. Solutions are encoded into a collection of genes. The Chromosome is then evaluated based on some criteria you define.

  Chromosomes in Genex can be defined as very "self-aware." That is to say: they contain all of the information necessary to repair and evaluate themselves. This fact can be used for some interesting applications.
  """

  @typedoc """
  Chromosome type.

  Chromosomes are represented as a `%Chromosome{}`. At a minimum a chromosome needs `:genes`, `:f`, and `:collection`.

  # Fields

    - `:genes`: `Enum` containing genotype representation.
    - `:size`: `non_neg_integer` representing size of chromosome.
    - `:age`: `non_neg_integer` representing age of chromosome.
    - `:fitness`: `number` or `Enum` representing fitness(es) of chromosome.
    - `:weights`: `number` or `Enum` representing weights of each objective.
    - `:f`: `Function` used to evaluate chromosome.
    - `:collection`: `Function` used to store chromosome.
  """
  @type t :: %Chromosome{
          genes: Enum.t(),
          size: non_neg_integer(),
          age: non_neg_integer(),
          fitness: number() | Enum.t(),
          weights: number() | Enum.t(),
          f: (t -> number() | Enum.t()),
          collection: (Enum.t() -> Enum.t())
        }

  @enforce_keys [:genes, :f, :collection]
  defstruct [:genes, :f, :collection, fitness: 0, weights: 1, size: 0, age: 0]
end
