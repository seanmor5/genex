defmodule OneMax do
  use Genex, mutation_type: :invert

  def individual do
    for _ <- 1..20, do: Enum.random(0..1)
  end

  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  def terminate?(population), do: population.max_fitness == 20
end

OneMax.run()