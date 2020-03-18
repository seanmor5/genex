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
    header = ["Generation", "Population", "Strongest"]

    rows = [
      [0000, 0000, "#Chromosome<age: 0, fitness: 0>"],
      [0000, 0000, "#Chromosome<age: 0, fitness: 0>"]
    ]

    IO.write(TableRex.quick_render!(rows, header, title))
  end

  @doc """
  Display a summary of the population.
  """
  def display(population) do
    title = "Genetic Algorithm"
    header = ["Generation", "Population", "Strongest"]

    rows = [
      [population.generation, population.size, population.strongest]
    ]

    IO.ANSI.cursor_up(7)
    |> Kernel.<>(TableRex.quick_render!(rows, header, title))
    |> IO.write()
  end

  @doc """
  Receive input.
  """
  def input(prompt), do: IO.gets(prompt)

  def success(), do: :ok
end
