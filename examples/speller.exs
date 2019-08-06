defmodule Speller do
  use Genex, crossover_type: :uniform, crossover_rate: 0.90, uniform_crossover_rate: 0.75

  def encoding do
    ?a..?z
    |> Enum.to_list
    |> Enum.take_random(7)
  end

  def fitness_function(chromosome) do
    genes = chromosome.genes
    String.jaro_distance(List.to_string(genes), "spell")
  end

  def terminate?(population), do: population.max_fitness == 1
end

soln = Speller.run()
Genex.Visualizers.Text.display_summary(soln)