defmodule Genex.Operators.Mutation do
  use Bitwise
  alias Genex.Chromosome
  @moduledoc """
  Mutation functions.
  """

  def bit_flip(chromosome) do
    genes =
      chromosome.genes
      |> Enum.map(fn x -> 1 ^^^ x end)
    %Chromosome{genes: genes}
  end

  def scramble(chromosome) do
    genes =
      chromosome.genes
      |> Enum.shuffle()
    %Chromosome{genes: genes}
  end

  def invert(chromosome) do
    genes =
      chromosome.genes
      |> Enum.reverse()
    %Chromosome{genes: genes}
  end

end
