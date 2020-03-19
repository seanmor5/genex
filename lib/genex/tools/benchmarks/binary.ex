defmodule Genex.Tools.Benchmarks.Binary do
  def chuang_f1, do: :ok
  def chuang_f2, do: :ok
  def chuang_f3, do: :ok

  def royal_road1(chromosome, order) do
    chromosome.genes
    |> Enum.chunk_every(order)
    |> Enum.map(& Enum.join(&1, ""))
    |> Enum.map(& String.to_integer(&1, 2))
    |> Enum.sum()
  end

  def royal_road2(chromosome, order), do: do_royal_road2(chromosome, order, floor(:math.pow(2, order)), 0)
  defp do_royal_road2(chromosome, norder, order, acc) do
    if norder >= order do
      acc
    else
      val = royal_road1(chromosome, norder)
      do_royal_road2(chromosome, order, norder*2, acc+val)
    end
  end
end
