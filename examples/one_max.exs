defmodule OneMax do
  use Genex, 
      crossover_rate: 0.90, 
      crossover_type: :uniform, 
      uniform_crossover_rate: 0.5, 
      mutation_type: :shuffle_index

  def chromosome do
    genes = for _ <- 1..20, do: Enum.random(0..1)
    %Chromosome{genes: genes}
  end

  def fitness_function(genes), do: Enum.sum(genes)

  def goal_test(population), do: population.max_fitness == 20
end

OneMax.run()