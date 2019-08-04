defmodule Genex.Visualizers.Text do
  @moduledoc """
  Contains functions for IO visualization of algorithm.
  """

  @doc """
  Shows a summary of the population.
  """
  def summary(population) do
    title = "Algorithm Running"
    header = ["Generation", "Size", "Max Fitness"]
    rows = [[population.generation, population.size, population.max_fitness]]

    IO.ANSI.cursor_up(7)
    |> Kernel.<>(TableRex.quick_render!(rows, header, title))
    |> IO.write()
  end

  def initialize do
    title = "Algorithm Running"
    header = ["Generation", "Size", "Max Fitness"]
    rows = [[0, 0, 0]]
    IO.write(TableRex.quick_render!(rows, header, title))
  end

  def solution(population) do
    title = "Solution Found!"
    header = ["Generation", "Individual"]
    rows = [[population.generation, population.strongest]]

    IO.puts(TableRex.quick_render!(rows, header, title))
  end
end
