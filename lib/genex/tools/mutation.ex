defmodule Genex.Tools.Mutation do
  use Bitwise
  alias Genex.Types.Chromosome

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
    - `chromosome`: `Chromosome` to mutate.
  """
  @spec bit_flip(Chromosome.t()) :: Chromosome.t()
  def bit_flip(chromosome) do
    genes =
      chromosome.genes
      |> Enum.map(fn x ->
        1 ^^^ x
      end)

    %Chromosome{genes: genes, size: chromosome.size, weights: chromosome.weights, f: chromosome.f, collection: chromosome.collection}
  end

  @doc false
  def bit_flip, do: &bit_flip(&1)

  @doc """
  Perform a bit-flip mutation.

  This mutation performs a binary XOR on a gene with probability `p` in the Chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`: `Chromosome` to mutate.
    - `p`: Probability of bitflip.
  """
  @spec bit_flip(Chromosome.t(), float()) :: Chromosome.t()
  def bit_flip(chromosome, p) do
    genes =
      chromosome.genes
      |> Enum.map(fn x ->
        if :rand.uniform() < p do
          1 ^^^ x
        else
          x
        end
      end)

    %Chromosome{genes: genes, size: chromosome.size, weights: chromosome.weights, f: chromosome.f, collection: chromosome.collection}
  end

  @doc false
  def bit_flip(probability: probability), do: &bit_flip(&1, probability)

  @doc false
  def scramble(radiation: radiation), do: &scramble(&1, radiation)

  @doc """
  Perform a scramble mutation.

  This mutation scrambles the genes of the Chromosome.

  Returns `%Chromosome{}`.

  # Parameters
    - `chromosome`: `Chromosome` to mutate.
  """
  @spec scramble(Chromosome.t()) :: Chromosome.t()
  def scramble(chromosome) do
    genes =
      chromosome.genes
      |> Enum.shuffle()

    %Chromosome{genes: genes, size: chromosome.size, weights: chromosome.weights, f: chromosome.f, collection: chromosome.collection}
  end

  @doc false
  def scramble, do: &scramble(&1)

  @doc """
  Perform a scramble mutation on a random slice of size `n`.

  This mutation scrambles the genes of the Chromosome between two random points.

  Returns `%Chromosome{}`.

  # Parameters
    - `chromosome`: `Chromosome` to mutate.
  """
  @spec scramble(Chromosome.t(), integer()) :: Chromosome.t()
  def scramble(chromosome, _), do: :ok

  @doc """
  Performs creep mutation.

  This mutation generates a random number between `min` and `max` at every gene in the chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`: `Chromosome` to mutate.
    - `min`: lower bound
    - `max`: upper bound
  """
  @spec creep(Chromosome.t(), integer(), integer()) :: Chromosome.t()
  def creep(chromosome, min, max) do
    genes =
      chromosome.genes
      |> Enum.map(fn _ ->
        Enum.random(min..max)
      end)

    %Chromosome{genes: genes, size: chromosome.size, weights: chromosome.weights, f: chromosome.f, collection: chromosome.collection}
  end

  @doc """
  Performs creep mutation with at random genes.

  This mutation generates a random number between `min` and `max` at genes with probability `p` in the chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`: `Chromosome` to mutate.
    - `p`: Probability of mutation.
    - `min`: lower bound
    - `max`: upper bound
  """
  def creep(chromosome, p, min, max) do
    genes =
      chromosome.genes
      |> Enum.map(fn x ->
        if :rand.uniform() < p do
          Enum.random(min..max)
        else
          x
        end
      end)

    %Chromosome{genes: genes, size: length(genes), weights: chromosome.weights, f: chromosome.f, collection: chromosome.collection}
  end

  @doc false
  def creep(min: min, max: max), do: &creep(&1, min, max)
  def creep(min: min, max: max, radiation: radiation), do: &creep(&1, radiation, min, max)

  @doc """
  Performs a gaussian mutation.

  This mutation generates a random number at every gene in the chromosome. The random number is from a normal distribution produced from the mean and variance of the genes in the chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`: `Chromosome` to mutate.
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
      |> Enum.map(fn _ ->
        :rand.normal(mu, sigma)
      end)

    %Chromosome{genes: genes, size: chromosome.size, weights: chromosome.weights, f: chromosome.f, collection: chromosome.collection}
  end

  @doc false
  def gaussian, do: &gaussian(&1)

  @doc """
  Performs a gaussian mutation at random genes.

  This mutation generates a random number at random genes with probability `p` in the chromosome. The random number is from a normal distribution produced from the mean and variance of the genes in the chromosome.

  Returns `Chromosome`.

  # Parameters
    - `chromosome`: `Chromosome` to mutate.
    - `p`: Probability of mutation.
  """
  @spec gaussian(Chromosome.t(), float()) :: Chromosome.t()
  def gaussian(chromosome, p) do
    mu = Enum.sum(chromosome.genes) / length(chromosome.genes)

    sigma =
      chromosome.genes
      |> Enum.map(fn x -> (mu - x) * (mu - x) end)
      |> Enum.sum()
      |> Kernel./(length(chromosome.genes))

    genes =
      chromosome.genes
      |> Enum.map(fn x ->
        if :rand.uniform() < p do
          :rand.normal(mu, sigma)
        else
          x
        end
      end)

    %Chromosome{genes: genes, size: chromosome.size, weights: chromosome.weights, f: chromosome.f, collection: chromosome.collection}
  end

  @doc false
  def gaussian(radiation: radiation), do: &gaussian(&1, radiation)

  def polynomial_bounded, do: :ok
  def swap, do: :ok
  def invert, do: :ok
  def invert_center, do: :ok
end
