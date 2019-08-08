defmodule OneMax do
  use Genex, population_size: 10_000

  def encoding, do: for _ <- 1..100, do: Enum.random(0..1)

  def fitness_function(c), do: Enum.sum(c.genes)

  def terminate?(p), do: p.max_fitness == 100
end

OneMax.benchmark()