defmodule Genex.Visualizers.Text do
  use Genex.Visualizers

  @moduledoc """
  Text visualizations of the Algorithm.
  """

  @doc """
  Display Initial Algorithm Text.
  """
  def init do
    title = "Genetic Algorithm"
    header = ["Generation", "Size", "Max Fitness", "Strongest"]

    rows = [
      [0, 0, 0, ""],
      [0, 0, 0, ""]
    ]

    IO.write(TableRex.quick_render!(rows, header, title))
  end

  @doc """
  Display a summary of the population.
  """
  def display(population) do
    title = "Genetic Algorithm"
    header = ["Generation", "Size", "Max Fitness", "Strongest"]

    rows = [
      [population.generation, population.size, population.max_fitness, population.strongest]
    ]

    IO.ANSI.cursor_up(7)
    |> Kernel.<>(TableRex.quick_render!(rows, header, title))
    |> IO.write()
  end

  @doc """
  Receive input.
  """
  def input(prompt), do: IO.gets(prompt)
end
