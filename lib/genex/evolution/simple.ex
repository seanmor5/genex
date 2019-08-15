defmodule Genex.Evolution.Simple do
  use Genex.Evolution

  @moduledoc """
  Models the most basic form of evolution.
  """
  def evaluation(population, func, opts \\ []) do
    minimize = Keyword.get(opts, :minimize?, false)

    chromosomes =
      population.chromosomes
      |> Enum.map(fn c -> %Chromosome{c | fitness: func.(c)} end)

    pop = Population.sort(%Population{population | chromosomes: chromosomes}, minimize)
    {:ok, pop}
  end

  def selection(population, opts \\ []) do
    with {:ok, population} <- match_selection(population, opts) do
      {:ok, population}
    else
      err -> raise err
    end
  end

  def variation(population, opts \\ []) do
    with {:ok, population} <- match_crossover(population, opts),
         {:ok, population} <- match_mutation(population, opts) do
      {:ok, population}
    else
      err -> raise err
    end
  end

  def reinsertion(population, opts \\ []) do
    with {:ok, population} <- match_reinsertion(population, opts) do
      {:ok, population}
    else
      err -> raise err
    end
  end
end
