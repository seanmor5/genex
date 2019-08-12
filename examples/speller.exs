defmodule Speller do
  use Genex

  def encoding, do: Chromosome.alphabetic(size: 5)

  def fitness_function(chromosome) do
    genes = chromosome.genes
    String.jaro_distance(List.to_string(genes), "riley")
  end

  def terminate?(population), do: population.max_fitness == 1
end

soln = Speller.run()
Genex.Visualizers.Text.display_summary(soln)