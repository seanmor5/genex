defmodule Genex.Evolution.Simple do
  use Genex.Evolution

  @moduledoc """
  Models the most basic form of evolution.
  """

  @impl true
  def variation(population, opts \\ []) do
    with {:ok, population} <- crossover(population, opts),
         {:ok, population} <- mutation(population, opts) do
      {:ok, population}
    else
      err -> raise err
    end
  end
end
