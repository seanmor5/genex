defmodule Genex.Operators.Reinsertion do
  @doc """
  Elitist reinsertion.

  The best `n` survive. Assumes `chromosomes` is sorted by fitness.
  """
  def elitist(chromosomes, n) do
    chromosomes
    |> Enum.take(n)
  end
end
