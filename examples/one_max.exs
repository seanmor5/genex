defmodule OneMax do
  use Genex

  def encoding, do: Chromosome.binary(size: 20)

  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  def terminate?(population), do: population.max_fitness == 20
end

OneMax.run()