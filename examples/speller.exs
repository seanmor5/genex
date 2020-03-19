defmodule Speller do
  use Genex

  def genotype, do: Genotype.bitstring(5)

  def fitness_function(chromosome) do
    genes = chromosome.genes
    String.jaro_distance(List.to_string(genes), "riley")
  end

  def terminate?(population), do: population.max_fitness == 1
end

use Genex.Tools

soln = Speller.run(title: "Speller",
                   mutation_type: Mutation.scramble(),
                   mutation_rate: 0.1,
                   crossover_type: Crossover.uniform(rate: 0.5),
                   selection_type: Selection.roulette())

IO.inspect(List.to_string(soln.strongest.genes))