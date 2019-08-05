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
  @spec invert(Chromosome.t()) :: Chromosome.t()
  def invert(chromosome) do
    genes =
      chromosome.genes
      |> Enum.reverse()
    %Chromosome{genes: genes}
  end

  @doc """
  Performs uniform integer mutation.

  This mutation generates a random number at random genes in the chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
    - `min`- lower bound
    - `max`- upper bound
  """
  @spec uniform_integer(Chromosome.t(), integer(), integer()) :: Chromosome.t()
  def uniform_integer(chromosome, min, max) do
    genes =
      chromosome.genes
      |> Enum.map(
          fn x ->
            if :rand.uniform() < 0.5 do
              Enum.random(min..max)
            else
              x
            end
          end
        )
    %Chromosome{genes: genes}
  end

  @doc """
  Performs a gaussian mutation.

  This mutation generates a random number at random genes in the chromosome. The random number is from a normal distribution produced from the mean and variance of the genes in the chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
  """
  @spec gaussian(Chromosome.t()) :: Chromosome.t()
  def gaussian(chromosome) do
    mu = Enum.sum(chromosome.genes) / length(chromosome.genes)
    sigma =
      chromosome.genes
      |> Enum.map(fn x -> (mu - x) * (mu - x) end)
      |> Enum.sum()
      |> Kernel./(length(chromosome.genes))
    genes =
      chromosome.genes
      |> Enum.map(
          fn x ->
            if :rand.uniform() < 0.5 do
              :rand.normal(mu, sigma)
            else
              x
            end
          end
        )
    %Chromosome{genes: genes}
  end

  @doc """
  Performs Polynomial Bounded mutation.

  See NSGA-II algorithm.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
    - `eta`
    - `low`
    - `high`
  """
  def polynomial_bounded(chromosome, eta, low, high) do
    chromosome_length = length(chromosome.genes)
    genes =
      chromosome.genes
      |> Enum.map(
          fn x ->
            delta_1 = (x - low) / (high - low)
            delta_2 = (high - x) / (high - low)
            rand = :rand.uniform()
            mut_pow = 1.0 / (eta + 1)

            {xy, val, delta_q} =
              if rand < 0.5 do
                a = 1.0 - delta_1
                b = 2.0 * rand + (1.0 - 2.0 * rand) * :math.pow(a, eta+1)
                c = :math.pow(b, mut_pow - 1)
                {a, b, c}
              else
                a = 1.0 - delta_2
                b = 2.0 * rand + (1.0 - 2.0 * rand) * :math.pow(a, eta+1)
                c = 1.0 - :math.pow(b, mut_pow)
                {a, b, c}
              end
            y = x + delta_q * (high - low)
            min(max(y, low), high)
          end
        )
    %Chromosome{genes: genes}
  end
end
