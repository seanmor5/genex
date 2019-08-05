defmodule Genex.Visualizers.Text do
  @moduledoc """
  Text visualizations of the Algorithm.
  """

  @doc """
  Display Initial Algorithm Text.
  """
  def init do
    title = "Genetic Algorithm"
    header = ["Generation", "Size", "Max Fitness", "Strongest"]
    rows = [[0, 0, 0, ""]]
    IO.write(TableRex.quick_render!(rows, header, title))
  end

  @doc """
  Display a summary of the population.
  """
  def display_summary(population) do
    title = "Genetic Algorithm"
    header = ["Generation", "Size", "Max Fitness", "Strongest"]
    rows = [[population.generation, population.size, population.max_fitness, population.strongest]]

    IO.ANSI.cursor_up(7)
    |> Kernel.<>(TableRex.quick_render!(rows, header, title))
    |> IO.write()
  end
end
