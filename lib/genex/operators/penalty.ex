defmodule Genex.Operators.Penalty do
  @moduledoc """
  Implements many basic penalty functions for constraint-based optimization problems.
  """

  @doc """
  Delta Penalty function.

  Returns `number`.

  # Parameters

  	- `constraints`: A list of constraint functions to check.
  	- `chromosome`: Chromosome to check.
  	- `delta`:
  """
  @spec delta(Enum.t(), Chromosome.t(), number()) :: number()
  def delta(constraints, chromosome, delta), do: :ok
end
