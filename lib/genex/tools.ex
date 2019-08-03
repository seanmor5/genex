defmodule Genex.Tools do
  
  defmacro __using__(opts \\ []) do
    quote do
      alias Genex.Tools.Crossover
      alias Genex.Tools.Mutation
      alias Genex.Tools.Selection
    end
  end
end