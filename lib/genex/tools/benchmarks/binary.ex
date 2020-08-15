defmodule Genex.Tools.Benchmarks.Binary do
  @moduledoc """
  Benchmark objective functions for binary genetic algorithms.
  """

  @doc """
  Binary deceptive function.

  Returns ```math```.

  # Parameters

    - `chromosome`: `%Chromosome{}`
  """
  def chuang_f1(chromosome) do
    last = Enum.at(chromosome.genes, -1)
    n = Enum.count(chromosome.genes)
    if last == 0 do
      chromosome.genes
      |> Enum.take(n - 1)
      |> Enum.chunk_every(4)
      |> Enum.reduce(0, fn x, acc -> acc + inv_trap(x) end)
    else
      chromosome.genes
      |> Enum.take(n - 1)
      |> Enum.chunk_every(4)
      |> Enum.reduce(0, fn x, acc -> acc + trap(x) end)
    end
  end

  @doc """
  Binary deceptive function.

  Returns ```math```.

  # Parameters

    - `chromosome`: `%Chromosome{}`
  """
  def chuang_f2(chromosome) do
    last = Enum.at(chromosome.genes, -1)
    second_to_last = Enum.at(chromosome.genes, -2)

    cond do
      second_to_last == 0 and last == 0 ->
        chromosome.genes
        |> Enum.chunk_every(8)
        |> Enum.reduce(0,
            fn x, acc ->
              {y, z} = Enum.split(x, 4)
              acc + inv_trap(y) + inv_trap(z)
            end
          )
      second_to_last == 0 and last == 1 ->
        chromosome.genes
        |> Enum.chunk_every(8)
        |> Enum.reduce(0,
            fn x, acc ->
              {y, z} = Enum.split(x, 4)
              acc + inv_trap(y) + trap(z)
            end
          )
      second_to_last == 1 and last == 0 ->
        chromosome.genes
        |> Enum.chunk_every(8)
        |> Enum.reduce(0,
            fn x, acc ->
              {y, z} = Enum.split(x, 4)
              acc + trap(y) + inv_trap(z)
            end
          )
      second_to_last == 1 and last == 1 ->
        chromosome.genes
        |> Enum.chunk_every(8)
        |> Enum.reduce(0,
            fn x, acc ->
              {y, z} = Enum.split(x, 4)
              acc + trap(y) + trap(z)
            end
          )
    end
  end

  @doc """
  Binary deceptive function.

  Returns ```math```.

  # Parameters

    - `chromosome`: `%Chromosome{}`
  """
  def chuang_f3(chromosome) do
    last = Enum.at(chromosome.genes, -1)
    n = Enum.count(chromosome.genes)
    if last == 0 do
      chromosome.genes
      |> Enum.take(n - 1)
      |> Enum.chunk_every(4)
      |> Enum.reduce(0, fn x, acc -> acc + inv_trap(x) end)
    else
      {head, middle} = Enum.split(chromosome.genes, 3)
      {middle, tail} = Enum.split(middle, n - 3)

      y =
        middle
        |> Enum.chunk_every(4)
        |> Enum.reduce(0, fn x, acc -> acc + inv_trap(x) end)
      z = trap(Enum.concat(head, tail))
      y + z
    end
  end

  defp trap(genes) do
    u = Enum.sum(chromosome.genes)
    k = Enum.count(chromosome.genes)
    if u == k, do: k, else: k - 1 - u
  end

  defp inv_trap(genes) do
    u = Enum.sum(genes)
    k = Enum.count(genes)
    if u == 0, do: k, else: u - 1
  end

  @doc """
  Royal Road objective function.

  Returns ```math```.

  # Parameters

    - `chromosome`: `%Chromosome{}`.
    - `order`: `Integer`.
  """
  def royal_road1(chromosome, order) do
    chromosome.genes
    |> Enum.chunk_every(order)
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.map(&String.to_integer(&1, 2))
    |> Enum.sum()
  end

  @doc """
  Royal Road 2 objective function.

  Returns ```math```.

  # Parameters

    - `chromosome`: `%Chromosome{}`.
    - `order`: `Integer`.
  """
  def royal_road2(chromosome, order),
    do: do_royal_road2(chromosome, order, floor(:math.pow(2, order)), 0)

  defp do_royal_road2(chromosome, norder, order, acc) do
    if norder >= order do
      acc
    else
      val = royal_road1(chromosome, norder)
      do_royal_road2(chromosome, order, norder * 2, acc + val)
    end
  end
end
