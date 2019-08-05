defmodule Genex.Operators.Crossover do
  alias Genex.Chromosome
  alias Genex.Population
  alias Genex.Support.Genealogy
  @moduledoc """
  Implementation of several popular crossover methods.

  Crossover is analagous to reproduction or biological crossover. Genex utilizes pairs of chromosomes to create offspring from the genetic material of parent chromosomes. Crossover happens with some probability `P(c)`. Typically this is a high probability.

  The probability of crossover or `crossover_rate` as it is called in our case, determines the number of parents selected to breed for the next generation. See more on this in the `Selection` documentation.

  Crossover operators are generic. As with any optimization problem, no single method will be perfect. Genex offers a variety of crossover operators to experiment with; however, you may find that you need to write your own to fit your specific use case. You can do this by overriding the `crossover` method.

  Each time a crossover takes place, 2 new children are created. These children then populate the `children` field of the `Population` struct before they are merged into the new population.
  """

  @doc """
  Performs single point crossover.

  This will swap a slice of genes from each chromosome, producing 2 new chromosomes.

  Returns `{:ok, Population}`.

  # Parameters
    - `population`: `Population` struct.
  """
  @spec single_point(Population.t()) :: {:ok, Population.t()}
  def single_point(population) do
    parents = population.parents
    chromosome_length = length(hd(population.chromosomes).genes)
    children =
      parents
      |> Enum.map(
          fn {p1, p2} ->
            point = :rand.uniform(chromosome_length)
            new_genes = Enum.slice(p1.genes, 0..point) ++ Enum.slice(p2.genes, point+1..chromosome_length-1)
            c = %Chromosome{genes: new_genes}
            Genealogy.update(population.history, c, p1, p2)
            c
          end
        )
    pop = %Population{population | children: children}
    {:ok, pop}
  end

  @doc """
  Performs two-point crossover.

  This will swap multiple slices of genes from each chromosome, producing 2 new chromosomes.

  Returns `{:ok, Population}`.

  # Parameters
    - `population`: `Population` struct.
    - `n`: `Integer` representing number of crossover points.
  """
  @spec two_point(Population.t()) :: {:ok, Population.t()}
  def two_point(population) do
    parents = population.parents
    chromosome_length = length(hd(population.chromosomes).genes)
    a = :rand.uniform(chromosome_length-1)
    b = :rand.uniform(chromosome_length-2)
    point1 = if b >= a do a else b end
    point2 = if b >= a do b+1 else a end
    children =
      parents
      |> Enum.map(
          fn {p1, p2} ->
            slice1 = Enum.slice(p1.genes, 0..point1)
            slice2 = Enum.slice(p2.genes, point1+1..point2)
            slice3 = Enum.slice(p1.genes, point2+1..chromosome_length-1)
            c = %Chromosome{genes: slice1 ++ slice2 ++ slice3}
            Genealogy.update(population.history, c, p1, p2)
            c
          end
        )
    pop = %Population{population | children: children}
    {:ok, pop}
  end

  @doc """
  Performs uniform crossover.

  This will swap random genes from each chromosome according to some specified rate, producing 2 new chrmosomes.

  Returns `{:ok, Population}`.

  # Parameters
    - `population`: `Population` struct.
    - `rate`: `Float` between 0 and 1 representing rates to swap genes.
  """
  @spec uniform(Population.t(), float()) :: {:ok, Population.t()}
  def uniform(population, rate) do
    parents = population.parents
    chromosome_length = length(hd(population.chromosomes).genes)
    children =
      parents
      |> Enum.map(
          fn {p1, p2} ->
            new_genes =
              p1.genes
              |> Enum.zip(p2.genes)
              |> Enum.map(fn {x, y} -> if :rand.uniform < rate do x else y end end)
            c = %Chromosome{genes: new_genes}
            Genealogy.update(population.history, c, p1, p2)
            c
          end
        )
    pop = %Population{population | children: children}
    {:ok, pop}
  end

  def davis_order(population, rate), do: {:ok, population}

  @doc """
  Performs whole arithemtic crossover.

  This will blend genes according to some alpha between 0 and 1. If alpha=.5, the resulting chromosomes will be identical to one another.

  Returns `{:ok, Population}`.

  # Parameters
    - `population`: `Population` struct.
    - `alpha`: `Float` between 0 and 1 representing percentage of each parent to blend into children.
  """
  def whole_arithmetic(population, alpha) do
    parents = population.parents
    children =
      parents
      |> Enum.map(
          fn {p1, p2} ->
            new_genes =
              p1.genes
              |> Enum.zip(p2.genes)
              |> Enum.map(fn {x, y} -> alpha*x + (1-alpha)*y end)
            c = %Chromosome{genes: new_genes}
            Genealogy.update(population.history, c, p1, p2)
            c
          end
        )
      pop = %Population{population | children: children}
      {:ok, pop}
  end
end
