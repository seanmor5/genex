defmodule Genex.Tools.Evaluation.Penalty do
  alias Genex.Types.Chromosome

  def delta(individual, feasibility, delta, distance \\ fn _ -> 0 end) do
    valid? = feasibility.(individual)

    if valid? do
      individual
    else
      f_penalty =
        individual.genes
        |> Enum.reduce(delta, fn x, acc -> acc - distance.(x) end)

      %Chromosome{individual | fitness: f_penalty}
    end
  end

  def closest_valid(individual, feasibility, feasible, alpha \\ 1, distance \\ fn _, _ -> 0 end) do
    valid? = feasibility.(individual)

    if valid? do
      individual
    else
      f_penalty =
        individual.genes
        |> Enum.reduce(feasible.().fitness, fn x, acc ->
          acc - alpha * distance.(feasible.(), x)
        end)

      %Chromosome{individual | fitness: f_penalty}
    end
  end
end
