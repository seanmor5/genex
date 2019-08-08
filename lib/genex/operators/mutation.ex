defmodule Genex.Operators.Mutation do
  use Bitwise
  alias Genex.Chromosome
  import Genex, only: [valid_rate?: 1]
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
  @spec bit_flip(Chromosome.t(), float()) :: Chromosome.t()
  def bit_flip(chromosome, radiation) when valid_rate?(radiation) do
    genes =
      chromosome.genes
      |> Enum.map(
        fn x ->
          if :rand.uniform > radiation do
            1 ^^^ x
          else
            x
          end
        end
      )
    %Chromosome{chromosome | genes: genes}
  end
  def bit_flip(_, _), do: raise ArgumentError, message: "Invalid radiation level!"

  @doc """
  Perform a scramble mutation.

  This mutation shuffles the genes of the Chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
  """
  @spec scramble(Chromosome.t(), float()) :: Chromosome.t()
  def scramble(chromosome, radiation) when valid_rate?(radiation) do
    p = floor(chromosome.size * radiation)
    genes =
      if p == chromosome.size-1 do
        chromosome.genes
        |> Enum.shuffle()
      else
        {head, tail} =
          chromosome.genes
          |> Enum.split(p)
        head
        |> Enum.shuffle()
        |> Kernel.++(tail)
      end
    %Chromosome{chromosome | genes: genes}
  end
  def scramble(_, _), do: raise ArgumentError, message: "Invalid radiation level!"

  @doc """
  Perform inversion mutation.

  This mutation reverses (inverts) the genes of the Chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
    - `radiation`- Aggressiveness of mutation
  """
  @spec invert(Chromosome.t(), float()) :: Chromosome.t()
  def invert(chromosome, radiation) when valid_rate?(radiation) do
    p = floor(chromosome.size * radiation)
    genes =
      if p == chromosome.size-1 do
        chromosome.genes
        |> Enum.reverse()
      else
        {head, tail} =
          chromosome.genes
          |> Enum.split(p)
        head
        |> Enum.reverse()
        |> Kernel.++(tail)
      end
    %Chromosome{chromosome | genes: genes}
  end
  def invert(_, _), do: raise ArgumentError, message: "Invalid radiation level!"

  @doc """
  Performs uniform integer mutation.

  This mutation generates a random number at random genes in the chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
    - `radiation`- Aggressiveness of mutation.
    - `min`- lower bound
    - `max`- upper bound
  """
  @spec uniform_integer(Chromosome.t(), float(), integer(), integer()) :: Chromosome.t()
  def uniform_integer(chromosome, radiation, min, max) when valid_rate?(radiation) do
    genes =
      chromosome.genes
      |> Enum.map(
          fn x ->
            if :rand.uniform() < radiation do
              Enum.random(min..max)
            else
              x
            end
          end
        )
    %Chromosome{chromosome | genes: genes}
  end
  def uniform_integer(_, _, _, _), do: raise ArgumentError, message: "Invalid radiation level!"

  @doc """
  Performs a gaussian mutation.

  This mutation generates a random number at random genes in the chromosome. The random number is from a normal distribution produced from the mean and variance of the genes in the chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
    - `radiation`- Aggressiveness of mutation.
  """
  @spec gaussian(Chromosome.t(), float()) :: Chromosome.t()
  def gaussian(chromosome, radiation) when valid_rate?(radiation) do
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
            if :rand.uniform() < radiation do
              :rand.normal(mu, sigma)
            else
              x
            end
          end
        )
    %Chromosome{chromosome | genes: genes}
  end
  def gaussian(_, _), do: raise ArgumentError, "Invalid radiation level!"

  @doc """
  Performs Polynomial Bounded mutation.

  See NSGA-II algorithm.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
    - `radiation`
    - `eta`
    - `low`
    - `high`
  """
  def polynomial_bounded(chromosome, radiation, eta, low, high) when valid_rate?(radiation) do
    genes =
      chromosome.genes
      |> Enum.map(
          fn x ->
            delta_1 = (x - low) / (high - low)
            delta_2 = (high - x) / (high - low)
            rand = :rand.uniform()
            mut_pow = 1.0 / (eta + 1)

            delta_q =
              if rand < radiation do
                a = 1.0 - delta_1
                b = 2.0 * rand + (1.0 - 2.0 * rand) * :math.pow(a, eta+1)
                c = :math.pow(b, mut_pow - 1)
                c
              else
                a = 1.0 - delta_2
                b = 2.0 * rand + (1.0 - 2.0 * rand) * :math.pow(a, eta+1)
                c = 1.0 - :math.pow(b, mut_pow)
                c
              end
            y = x + delta_q * (high - low)
            min(max(y, low), high)
          end
        )
    %Chromosome{chromosome | genes: genes}
  end
  def polynomial_bounded(_, _, _, _, _), do: raise ArgumentError, message: "Invalid radiation level!"
end
