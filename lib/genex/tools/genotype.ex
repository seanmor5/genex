defmodule Genex.Tools.Genotype do
  alias Statistics.Distributions

  @doc """
  Creates a binary geneset.

  Returns `Enum.t()`.

  # Parameters

    - `size`: Size of the geneset.
  """
  def binary(size), do: for(_ <- 0..(size - 1), do: Enum.random(0..1))

  @doc """
  Creates a permutation genotype.

  Returns `Enum.t()`.

  # Parameters

    - `values`: Possible values in the permutation.
  """
  def permutation(values) when is_list(values), do: Enum.shuffle(values)
  def permutation(lo..hi), do: Enum.shuffle(lo..hi)
  def permutation(values), do: raise("Values must be enumerated.")

  @doc """
  Creates a bitstring geneset.

  Returns `Enum.t()`.

  # Parameters

    - `size`: Size of the geneset.
    - `alphabet`: Alphabet to use.
  """
  def bitstring(size, alphabet \\ :downcase) do
    alpha = "abcdefghijklmnopqrstuvwxyz"
    numeric = "1234567890"

    alphabets =
      cond do
        alphabet == :alpha -> alpha <> String.upcase(alpha)
        alphabet == :alphanumeric -> alpha <> numeric
        alphabet == :upcase -> String.upcase(alpha)
        alphabet == :downcase -> alpha
        alphabet == :all -> alpha <> numeric <> String.upcase(alpha)
      end
      |> String.split("", trim: true)

    1..size
    |> Enum.reduce([], fn _, acc -> [Enum.random(alphabets) | acc] end)
  end

  @doc """
  Creates a geneset from given distribution.

  Returns `Enum.t()`.

  # Parameters

    - `size`: Size of the geneset.
    - `name`: Distribution name.
    - `args`: Optional arguments to provide to distribution.
  """
  def distribution(size, name \\ :normal, args \\ []) do
    case name do
      :beta -> for _ <- 1..size, do: apply(Distributions, :beta, args)
      :binomial -> for _ <- 1..size, do: apply(Distributions, :binomial, args)
      :chisq -> for _ <- 1..size, do: apply(Distributions, :chisq, args)
      :exponential -> for _ <- 1..size, do: apply(Distributions, :exponential, args)
      :f -> for _ <- 1..size, do: apply(Distributions, :f, args)
      :hypergeometric -> for _ <- 1..size, do: apply(Distributions, :hypergeometric, args)
      :normal -> for _ <- 1..size, do: apply(Distributions, :normal, args)
      :poisson -> for _ <- 1..size, do: apply(Distributions, :poisson, args)
      :t -> for _ <- 1..size, do: apply(Distributions, :t, args)
    end
  end
end
