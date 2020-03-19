defmodule OneMax do
  use Genex

  def genotype, do: Genotype.binary(100)

  def fitness_function(chromosome), do: Enum.sum(chromosome.genes)

  def terminate?(population), do: population.max_fitness == 100
end

use Genex.Tools

soln = OneMax.run(title: "One Max",
                  mutation_type: Mutation.scramble())

IO.inspect(soln.strongest.genes)