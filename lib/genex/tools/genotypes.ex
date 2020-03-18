defmodule Genex.Tools.Genotypes do
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
  def bitstring(size, alphabet) do
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

    alphabets
    |> Enum.shuffle()
    |> Enum.split(size)
    |> elem(0)
  end

  def from_file(path, delimiter), do: :ok

  def distribution(size, name, args \\ []), do: :ok
end
