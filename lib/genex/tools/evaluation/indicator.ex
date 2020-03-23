defmodule Genex.Tools.Evaluation.Indicator do
  def hypervolume, do: :ok
  def additive_epsilon, do: :ok
  def multiplicative_epsilon, do: :ok

  @doc """
  Determines if `c1` dominates `c2`.
  """
  def dominates?(c1, c2) do
    objectives =
      c1.genes
      |> Enum.zip(c2.genes)
      |> Enum.map(fn {g1, g2} -> g1 - g2 end)
    Enum.any?(objectives, &(&1 > 0)) and not Enum.any?(objectives, &(&1 < 0))
  end
end
