defmodule Genex.Operators.Mutation do
  use Bitwise
  alias Genex.Chromosome
  alias Genex.Population
  @moduledoc """
  Mutation functions.
  """

  def bit_flip(population, rate) do
    chromosomes = population.chromosomes
    new_chromosomes =
      chromosomes
      |> Enum.map(
          fn c ->
            if :rand.uniform() < rate do
              new_genes = Enum.map(c.genes, fn x -> 1 ^^^ x end)
              %Chromosome{genes: new_genes}
            else
              c
            end
          end
        )
    pop = %Population{population | chromosomes: new_chromosomes}
    {:ok, pop}
  end

  def uniform_integer(population, rate, min, max), do: {:ok, population}
  def gaussian(population, rate), do: {:ok, population}
  def scramble(population, rate), do: {:ok, population}

  def shuffle_index(population, rate) do
    chromosomes = population.chromosomes
    new_chromosomes =
      chromosomes
      |> Enum.map(
        fn c ->
          if :rand.uniform() < rate do
            new_genes = Enum.shuffle(c.genes)
            %Chromosome{genes: new_genes}
          else
            c
          end
        end
      )
    pop = %Population{population | chromosomes: new_chromosomes}
    {:ok, pop}
  end

  def invert(population, rate) do
    chromosomes = population.chromosomes
    new_chromosomes =
      chromosomes
      |> Enum.map(
        fn c ->
          if :rand.uniform() < rate do
            new_genes = Enum.reverse(c.genes)
            %Chromosome{genes: new_genes}
          else
            c
          end
        end
      )
    pop = %Population{population | chromosomes: new_chromosomes}
    {:ok, pop}
  end
end
