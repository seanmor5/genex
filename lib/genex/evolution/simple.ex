defmodule Genex.Evolution.Simple do
  use Genex.Evolution

  @moduledoc """
  Models the most basic form of evolution.
  """
  @spec selection(Population.t(), Keyword.t()) :: {:ok, Population.t()} | {:error, any()}
  def selection(population, opts \\ []) do
    with {:ok, population} <- match_selection(population, opts) do
      {:ok, population}
    else
      err -> raise err
    end
  end

  @spec variation(Population.t(), Keyword.t()) :: {:ok, Population.t()} | {:error, any()}
  def variation(population, opts \\ []) do
    with {:ok, population} <- match_crossover(population, opts),
         {:ok, population} <- match_mutation(population, opts) do
      {:ok, population}
    else
      err -> raise err
    end
  end

  @spec reinsertion(Population.t(), Keyword.t()) :: {:ok, Population.t()} | {:error, any()}
  def reinsertion(population, opts \\ []) do
    with {:ok, population} <- match_reinsertion(population, opts) do
      {:ok, population}
    else
      err -> raise err
    end
  end
end
