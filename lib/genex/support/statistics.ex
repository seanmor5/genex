defmodule Genex.Support.Statistics do
  @moduledoc """
  Provides basic summary statistics for use in the Population struct.
  """

  @doc """
  Takes the mean of `list`.

  Returns `Number`.

  # Parameters
    - `list`: List of values.
  """
  def mean(list) do
    list
    |> Enum.sum()
    |> Kernel./(length(list))
  end

  @doc """
  Takes the variance of `list`.

  Returns `Number`.

  # Parameters
    - `list`: List of values.
  """
  def variance(list) do
    avg = mean(list)
    size = length(list)

    list
    |> Enum.reduce(
      0,
      fn x, total ->
        total + :math.pow(x - avg, 2)
      end
    )
    |> Kernel./(size - 1)
  end

  @doc """
  Takes the standard deviation of `list`.

  Returns `Number`.

  # Parameters
    - `list`: List of values.
  """
  def stdev(list) do
    :math.sqrt(variance(list))
  end

  @doc """
  Takes the min of `list`.

  Returns `Number`.

  # Parameters
    - `list`: List of values.
  """
  def min(list), do: Enum.min(list)

  @doc """
  Takes the max of `list`.

  Returns `Number`.

  # Parameters
    - `list`: List of values.
  """
  def max(list), do: Enum.max(list)
end
