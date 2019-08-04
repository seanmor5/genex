defmodule OneMax do
  use Genex

  def chromosome do
    for _ <- 1..20, do: Enum.random(0..1)
  end

  def fitness_function(genes), do: Enum.sum(genes)

  def goal_test(population), do: population.max_fitness == 20
end

OneMax.run()