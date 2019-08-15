defmodule Genex.Operators.Mutation do
  use Bitwise
  alias Genex.Types.Chromosome
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
      |> Enum.map(fn x ->
        if :rand.uniform() > radiation do
          1 ^^^ x
        else
          x
        end
      end)

    %Chromosome{chromosome | genes: genes}
  end

  def bit_flip(_, _), do: raise(ArgumentError, message: "Invalid radiation level!")

  @doc """
  Perform a scramble mutation.

  This mutation shuffles the genes of the Chromosome between 2 random points.

  Returns `%Chromosome{}`.

  # Parameters
    - `chromosome`: `Chromosome` to mutate.
    - `radiation`: Aggressiveness of the mutation.
  """
  @spec scramble(Chromosome.t(), float()) :: Chromosome.t()
  def scramble(chromosome, radiation) when valid_rate?(radiation) do
    chromosome_length = chromosome.size
    num_to_scramble = floor(radiation * chromosome_length)
    point = if chromosome_length == 0, do: 0, else: :rand.uniform(chromosome_length)
    scramble(chromosome, point, point + num_to_scramble)
  end

  def scramble(_, _), do: raise(ArgumentError, message: "Invalid radiation level!")

  @doc """
  Performs a scramble mutation of a known slice.

  This mutation shuffles the genes of a Chromosome between 2 known points.

  # Parameters
    - `chromosome`: `Chromosome` to mutate.
    - `start`: First scramble point.
    - `finish`: Second scramble point.

  # Examples

      iex> c1 = %#{Chromosome}{genes: [1, 2, 3, 4, 5], size: 5}
      iex> scramble(c1, 10, 4)
      %#{Chromosome}{genes: [1, 2, 3, 4, 5], size: 5}
  """
  @spec scramble(Chromosome.t(), integer(), integer()) :: Chromosome.t()
  def scramble(chromosome, start, finish) do
    {head, slice} = Enum.split(chromosome.genes, start)
    {slice, tail} = Enum.split(slice, finish - start)
    genes = head ++ Enum.shuffle(slice) ++ tail
    %Chromosome{chromosome | genes: genes}
  end

  @doc """
  Perform inversion mutation on a random slice.

  This mutation reverses (inverts) a random slice of genes of the Chromosome.

  Returns `%Chromosome{}`.

  # Parameters
    - `chromosome`- `Chromosome` to mutate.
    - `radiation`- Aggressiveness of mutation
  """
  @spec invert(Chromosome.t(), float()) :: Chromosome.t()
  def invert(chromosome, radiation) when valid_rate?(radiation) do
    chromosome_length = chromosome.size
    point = if chromosome_length == 0, do: 0, else: :rand.uniform(chromosome_length)
    num_to_invert = floor(radiation * chromosome_length)
    invert(chromosome, point, point + num_to_invert)
  end

  def invert(_, _), do: raise(ArgumentError, message: "Invalid radiation level!")

  @doc """
  Perform inversion mutation on a known slice.

  This mutation reverses (inverts) a known slice of genes of the Chromosome.

  Returns `%Chromosome{}`.

  # Parameters
    - `chromosome`: `Chromosome` to mutate.
    - `start`: Start of slice.
    - `finish`: End of slice.

  # Examples

      iex> c1 = %#{Chromosome}{genes: [1, 2, 3, 4, 5], size: 5}
      iex> invert(c1, 2, 4)
      %#{Chromosome}{genes: [1, 2, 4, 3, 5], size: 5}

      iex> c1 = %#{Chromosome}{genes: [1, 2, 3, 4, 5], size: 5}
      iex> invert(c1, 10, 3)
      %#{Chromosome}{genes: [1, 2, 3, 4, 5], size: 5}

      iex> c1 = %#{Chromosome}{genes: [1, 2, 3, 4, 5], size: 5}
      iex> invert(c1, 0, 10)
      %#{Chromosome}{genes: [5, 4, 3, 2, 1], size: 5}
  """
  @spec invert(Chromosome.t(), integer(), integer()) :: Chromosome.t()
  def invert(chromosome, start, finish) do
    {head, slice} = Enum.split(chromosome.genes, start)
    {slice, tail} = Enum.split(slice, finish - start)
    genes = head ++ Enum.reverse(slice) ++ tail
    %Chromosome{chromosome | genes: genes}
  end

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
      |> Enum.map(fn x ->
        if :rand.uniform() < radiation do
          Enum.random(min..max)
        else
          x
        end
      end)

    %Chromosome{chromosome | genes: genes}
  end

  def uniform_integer(_, _, _, _), do: raise(ArgumentError, message: "Invalid radiation level!")

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
      |> Enum.map(fn x ->
        if :rand.uniform() < radiation do
          :rand.normal(mu, sigma)
        else
          x
        end
      end)

    %Chromosome{chromosome | genes: genes}
  end

  def gaussian(_, _), do: raise(ArgumentError, "Invalid radiation level!")

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
      |> Enum.map(fn x ->
        delta_1 = (x - low) / (high - low)
        delta_2 = (high - x) / (high - low)
        rand = :rand.uniform()
        mut_pow = 1.0 / (eta + 1)

        delta_q =
          if rand < radiation do
            a = 1.0 - delta_1
            b = 2.0 * rand + (1.0 - 2.0 * rand) * :math.pow(a, eta + 1)
            c = :math.pow(b, mut_pow - 1)
            c
          else
            a = 1.0 - delta_2
            b = 2.0 * rand + (1.0 - 2.0 * rand) * :math.pow(a, eta + 1)
            c = 1.0 - :math.pow(b, mut_pow)
            c
          end

        y = x + delta_q * (high - low)
        min(max(y, low), high)
      end)

    %Chromosome{chromosome | genes: genes}
  end

  def polynomial_bounded(_, _, _, _, _),
    do: raise(ArgumentError, message: "Invalid radiation level!")
end
