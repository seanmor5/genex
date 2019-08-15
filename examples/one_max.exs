defmodule OneMax do
  use Genex

  def encoding, do: Chromosome.binary()

  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  def terminate?(population), do: population.max_fitness == 32
end

import Genex.Config

OneMax.benchmark()