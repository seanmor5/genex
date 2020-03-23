defmodule Genex.Visualizer.Text do
  use Genex.Visualizer

  @moduledoc """
  Text visualizations of the Algorithm.
  """

  @doc """
  Display Initial Algorithm Text.
  """
  def init(opts) do
    title = Keyword.get(opts, :title, "Genetic Algorithm")
    header = Keyword.get(opts, :columns, ["Generation", "Population", "Strongest"])

    rows = [
      [0, 0, "#Chromosome<age: 0, fitness: 0>"],
      [0, 0, "#Chromosome<age: 0, fitness: 0>"]
    ]

    IO.write(TableRex.quick_render!(rows, header, title))
  end

  @doc """
  Display a summary of the population.
  """
  def display(population, opts) do
    title = Keyword.get(opts, :title, "Genetic Algorithm")
    header = Keyword.get(opts, :columns, ["Generation", "Population", "Strongest"])

    generation = Integer.to_string(population.generation) |> String.pad_leading(5, "0")
    size = Integer.to_string(population.size)

    rows = [
      [generation, size, population.strongest]
    ]

    IO.ANSI.cursor_up(7)
    |> Kernel.<>(TableRex.quick_render!(rows, header, title))
    |> IO.write()
  end
end
