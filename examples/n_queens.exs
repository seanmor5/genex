defmodule NQueens do
  use Genex

  # Encoded as a 1-D permutation.
  def genotype, do: Genotypes.permutation(0..7)

  # Since we only have 1 queen per column, clashes only happen on diagonals and rows.
  def fitness_function(c) do
    row_clashes = Enum.count(c.genes) - Enum.count(Enum.uniq(c.genes))
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
end

[minimize?: true, crossover_type: :davis_order]
|> NQueens.run()