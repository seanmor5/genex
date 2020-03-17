defmodule OneMax do
  use Genex

  def genotype, do: Genotypes.binary(size: 10)

  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  def terminate?(population), do: population.max_fitness == 10
end

OneMax.run()