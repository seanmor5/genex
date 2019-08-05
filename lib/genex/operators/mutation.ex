defmodule Genex.Operators.Mutation do
  use Bitwise
  alias Genex.Chromosome
  @moduledoc """
  Implementation of several population mutation methods.

  Mutation takes place according to some rate. Mutation is useful for introducing novelty into the population. This ensures your solutions don't prematurely converge.

  Future versions of Genex will provide the ability to define the "aggressiveness" of mutations. As of this version of Genex, mutations effect the ENTIRE chromosome.
  """

  @doc """
  Perform a bit-flip mutation.

  This mutation performs a binary XOR on every gene in the Chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
  """
  @spec bit_flip(Chromosome.t()) :: Chromosome.t()
  def bit_flip(chromosome) do
    genes =
      chromosome.genes
      |> Enum.map(fn x -> 1 ^^^ x end)
    %Chromosome{genes: genes}
  end

  @doc """
  Perform a scramble mutation.

  This mutation shuffles the genes of the Chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
  """
  @spec scramble(Chromosome.t()) :: Chromosome.t()
  def scramble(chromosome) do
    genes =
      chromosome.genes
      |> Enum.shuffle()
    %Chromosome{genes: genes}
  end

  @doc """
  Perform inversion mutation.

  This mutation reverses (inverts) the genes of the Chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
  """
  def invert(chromosome) do
    genes =
      chromosome.genes
      |> Enum.reverse()
    %Chromosome{genes: genes}
  end

end
