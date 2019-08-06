defmodule OneMax do
  use Genex, parent_selection: :tournament, tournsize: 25, survivor_selection: :roulette

  def encoding do
    for _ <- 1..25, do: Enum.random(0..1)
  end

  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  def terminate?(population), do: population.max_fitness == 25
end

soln = OneMax.run()
Genex.Visualizers.Text.display_summary(soln)