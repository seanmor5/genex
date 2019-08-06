defmodule OneMax do
  use Genex, crossover_type: :davis_order

  def encoding do
    for _ <- 1..25, do: Enum.random(0..1)
  end

  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  def terminate?(population), do: population.max_fitness == 25
end

soln = OneMax.run()
