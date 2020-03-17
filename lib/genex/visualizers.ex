defmodule Genex.Visualizers do
  @moduledoc """
  Visualizer behaviour.
  """
  alias Genex.Types.Population

  @callback init :: any

  @callback display(Population.t()) :: any

  @callback success :: any

  @callback input(String.t()) :: any

  defmacro __using__(_) do
    quote do
      @behaviour Genex.Visualizers
      alias Genex.Types.Population
      alias Genex.Types.Chromosome
    end
  end
end
