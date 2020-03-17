defmodule Genex.Evolution.Simple do
  use Genex.Evolution

  @moduledoc """
  Models the most basic form of evolution.
  """

  @spec variation(Population.t(), Keyword.t()) :: {:ok, Population.t()} | {:error, any()}
  def variation(population, opts \\ []) do
    with {:ok, population} <- crossover(population, opts),
         {:ok, population} <- mutation(population, opts) do
      {:ok, population}
    else
      err -> raise err
    end
  end
end
