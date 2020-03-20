defmodule Genex.Visualizer do
  @moduledoc """
  Visualizer behaviour.
  """
  alias Genex.Types.{Chromosome, Population}

  @type options :: any

  @callback init(opt :: options) :: {:error, String.t()} | :ok

  @callback display(population :: Population.t(), opt :: options) :: any

  defmacro __using__(_) do
    quote do
      @behaviour Genex.Visualizer
      alias Genex.Types.{Population, Chromosome}

      defimpl String.Chars, for: Chromosome do
        def to_string(chromosome) do
          age = Integer.to_string(chromosome.age)

          fitness =
            if is_integer(chromosome.fitness) do
              Integer.to_string(chromosome.fitness)
            else
              :erlang.float_to_binary(chromosome.fitness, decimals: 3)
            end

          "#Chromosome<age: #{age}, fitness: #{fitness}>"
        end
      end

      defimpl String.Chars, for: Population do
        def to_string(population) do
          "#Population<generation: #{population.generation}, size: #{population.size}, strongest: #{
            population.strongest
          }>"
        end
      end
    end
  end
end
