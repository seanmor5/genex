defmodule Genex.Support.Statistics do
  @moduledoc """
  Provides basic summary statistics for use in the Population struct.
  """

  @doc """
  Takes the mean of `list`.

  Returns `Number`.

  # Parameters
    - `list`: List of values.

  # Examples

      iex> list = [1, 2, 3, 4, 5]
      iex> mean(list)
      3.0

      iex> list = []
      iex> mean(list)
      0
  """
  def mean([]), do: 0

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

  # Examples

      iex> list = [0, 1, 1, 1]
      iex> variance(list)
      0.25

      iex> list = []
      iex> variance(list)
      0
  """
  def variance([]), do: 0

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

  # Examples

      iex> list = [0, 1, 1, 1]
      iex> stdev(list)
      0.5

      iex> list = []
      iex> stdev(list)
      0
  """
  def stdev([]), do: 0

  def stdev(list) do
    :math.sqrt(variance(list))
  end

  @doc """
  Takes the min of `list`.

  Returns `Number`.

  # Parameters
    - `list`: List of values.

  # Examples

      iex> list = [1, 2, 3, 4, 5]
      iex> min(list)
      1

      iex> list = []
      iex> min(list)
      nil
  """
  def min([]), do: nil
  def min(list), do: Enum.min(list)

  @doc """
  Takes the max of `list`.

  Returns `Number`.

  # Parameters
    - `list`: List of values.

  # Examples

      iex> list = [1, 2, 3, 4, 5]
      iex> max(list)
      5

      iex> list = []
      iex> max(list)
      nil
  """
  def max([]), do: nil
  def max(list), do: Enum.max(list)
end
