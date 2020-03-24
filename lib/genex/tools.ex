defmodule Genex.Tools do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      alias Genex.Tools.{Crossover, Migration, Mutation, Selection}
    end
  end
end
