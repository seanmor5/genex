defmodule Genex.Tools.Evaluation.Penalty do
  alias Genex.Types.Chromosome
  @moduledoc """
  Penalty functions for use with constraint satisfaction problems.

  Returns the chromosome so you can easily cascade constraints.

  ## Example

  ```
  def fitness_function(c) do
    c
    |> Penalty.delta(...)
    |> Penalty.delta(...)
    |> eval()
  end
  ```

  `eval/1` is a convenience function for returning fitness from a chromosome.
  """

  @doc """
  Delta penalty function.

  Returns `%Chromosome{}`.

  ## Parameters

    - `individual`: `%Chromosome{}`.
    - `feasibiliy`: `Function`.
    - `delta`: penalty.
    - `distance`: `Function`.
  """
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

  @doc """
  Closest-Valid penalty function.

  Returns `%Chromosome{}`.

  ## Parameters

    - `individual`: `%Chromosome{}`.
    - `feasibiliy`: `Function`.
    - `feasible`: feasible chromosome.
    - `alpha`: number
    - `distance`: `Function`.
  """
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
