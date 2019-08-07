defmodule Genex.Support.Statistics do
  @moduledoc """
  Provides basic summary statistics for use in the Population struct.
  """

  def mean(list) do
    list
    |> Enum.sum()
    |> Kernel./(length(list))
  end

  def variance(list) do
    list_mean = mean(list)
    list |> Enum.map(fn x -> (list_mean - x) * (list_mean - x) end) |> mean
  end

  def stdev(list) do
    :math.sqrt(variance(list))
  end

  def min(list), do: Enum.min(list)

  def max(list), do: Enum.max(list)
end