defmodule TSP do
  use Genex

  def genotype, do: Genotype.permutation(0..14)

  def fitness_function(chromosome) do
    start = Enum.at(locations(), 0)
    chromosome.genes
    |> Enum.map(& Enum.at(locations(), &1))
    |> Enum.chunk_every(2, 1, [start])
    |> Enum.map(& List.to_tuple(&1))
    |> Enum.map(fn {p1, p2} -> distance(p1, p2) end)
    |> Enum.sum()
    |> Kernel.*(-1)
  end

  defp distance({x1, y1}, {x2, y2}) do
    x = :math.pow(x2 - x1, 2)
    y = :math.pow(y2 - y1, 2)
    :math.sqrt(x + y)
  end

  defp locations, do:
    [{0, 0}, {1, 2}, {3, 2}, {4, 5}, {1, 4}, {2, 2}, {6, 8}, {3, 5},
    {10, 5}, {13, 6}, {9, 7}, {7, 2}, {13, 1}, {4, 4}, {8, 7}]

  def terminate?(population), do: population.generation == 1000
end

use Genex.Tools

soln = TSP.run([title: "Traveling Salesman Problem",
                population_size: 50,
                crossover_type: Crossover.partialy_matched(),
                crossover_rate: 0.9])

IO.inspect soln.strongest.genes