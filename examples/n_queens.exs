defmodule NQueens do
  use Genex

  # Encoded as a 1-D list where each block is row-index of queen
  # We also get a lot more novelty using "integer_value" encoding.
  def encoding, do: Chromosome.permutation(size: 8, min: 0, max: 7)

  # Since we only have 1 queen per column, clashes only happen on diagonals and rows.
  def fitness_function(c) do
    row_clashes = length(c.genes) - length(Enum.uniq(c.genes))
    diag_clashes =
      for i <- 0..7, j <- 0..7 do
        if i != j do
          dx = abs(i-j)
          dy = abs(Enum.at(c.genes, i) - Enum.at(c.genes, j))
          if dx == dy do
            1
          else
            0
          end
        else
          0
        end
      end
    row_clashes + Enum.sum(diag_clashes)
  end

  # Terminate when there are no clashes
  def terminate?(p), do: p.max_fitness == 0

  def mutation_rate(_), do: 0.15
end

import Genex.Config

# Run with two point crossover and scramble mutation
[minimize?: true]
|> use_crossover(:davis_order)
|> with_crossover_rate(0.9)
|> with_mutation_rate(0.1)
|> NQueens.run()