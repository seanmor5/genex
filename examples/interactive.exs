defmodule Interactive do
  use Genex

  def encoding, do: Chromosome.binary(size: 10)

  def fitness_function(chromosome), do: interactive(chromosome)

  def terminate?(population), do: population.max_fitness >= 10
end

import Genex.Config

[population_size: 5]
|> Interactive.run()