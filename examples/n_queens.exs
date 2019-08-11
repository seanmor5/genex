defmodule NQueens do
  use Genex, minimize: true,
             crossover_type: :uniform,
             uniform_crossover_rate: 0.5,
             mutation_type: :uniform_integer,
             lower_bound: 0,
             upper_bound: 7

  # Encoded as a 1-D list where each block is row-index of queen
  def encoding, do: for _ <- 0..7, do: Enum.random(0..7)

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

soln = NQueens.run()
IO.inspect(soln.strongest.genes)