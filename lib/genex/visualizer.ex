defmodule Genex.Visualizer do
  alias Genex.Types.{Chromosome, Population}

  @moduledoc """
  Behaviour for implementing visualizations.

  A visualizer provides robust visualization for your genetic algorithms. A complete visualizer behaviour implements two functions: `init/1` and `display/2`.

  The visualizer behaviour also implements `String.Chars` for both `Chromosome` and `Population`. You can override these defualt implementations in your visualizer module.

  The options passed to your visualizer is a `Keyword` list that is the same as the initial options passed to `run/1`. You can specify any required options in your own visualizer module.

  ## Example Implementation

  The following is a basic correct implementation of a Genex visualizer.

  ```
  defmodule MyVisualizer do
    use Genex.Visualizer

    def init(_) do
      IO.write("Beginning Algorithm...")
      :ok
    end

    def display(population), do: IO.inspect(population)
  end
  ```
  """

  @typedoc false
  @type options :: Keyword.t()

  @doc """
  Initializes the visualizer with `opts`.

  The purpose of this function is to do any initial setup of your visualizer. For example, in the Text visualizer, `init/1` is responsible for outputting the initial table layout. You can do anything you want in `init/1`, so long as it returns `:ok`.
  """
  @callback init(opt :: options) :: {:error, String.t()} | :ok

  @doc """
  Displays a summary of the `population`.

  This function takes a `%Population{}` and returns any value representing a visualization of the population. Typically, this is a summary of the population during the current generation. By default, `display/2` is called at the beginning of every new generation.
  """
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
