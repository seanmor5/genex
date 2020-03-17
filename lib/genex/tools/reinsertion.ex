defmodule Genex.Tools.Reinsertion do
  @doc """
  Elitist reinsertion.

  The best `n` survive. Assumes `chromosomes` is sorted by fitness.

  Returns `Enum.t()`.

  # Parameters

  	- `chromosomes`: `Enum` of `%Chromosomes{}`.
  	- `n`: Number to take.
  """
  def elitist(chromosomes, n) do
    chromosomes
    |> Enum.take(n)
  end

  def uniform(chromosomes, n), do: :ok
end
