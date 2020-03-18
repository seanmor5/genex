defmodule Genex.Config do
  @moduledoc """
  Provides functions to make algorithm configuration more "Elixir-y".

  The purpose of this module is to provide functions that are easily piped and make configuring algorithms more consistent with typical Elixir code.
  """

  @type mutation ::
          :scramble
          | :invert
          | :uniform_integer
          | :bit_flip
          | :gaussian
          | :polynomial_bounded
          | :none
  @type crossover ::
          :single_point
          | :two_point
          | :uniform
          | :messy_single_point
          | :davis_order
          | :simulated_binary
          | :none
  @type selection ::
          :natural
          | :worst
          | :random
          | :roulette
          | :tournament
          | :stochastic
  @type rate :: float() | (Genex.Population.t() -> float())

  @doc """
  Specify the type of crossover to use.

  Returns `Keyword.t`.

  # Parameters

    - `opts`: Keyword list of options. Defaults to an empty list.
    - `crossover_type`: `:single_point` | `:two_point` | `:uniform` | `:messy_single_point` | `:davis_order` | `:blend` | `:simulated_binary`
    - `additional_opts`: Keyword list of options for certain algorithms.
  """
  @spec use_crossover(Keyword.t(), crossover(), Keyword.t()) :: Keyword.t()
  def use_crossover(opts \\ [], crossover_type, additional_opts \\ []) do
    new_opts = [crossover_type: crossover_type] ++ opts

    case crossover_type do
      :uniform ->
        uniform_crossover_rate = Keyword.get(additional_opts, :rate, nil)

        case uniform_crossover_rate do
          nil -> raise "You must specify :rate when using uniform crossover!"
          _ -> [uniform_crossover_rate: uniform_crossover_rate] ++ new_opts
        end

      :simulated_binary ->
        simulated_binary_eta = Keyword.get(additional_opts, :eta, nil)

        case simulated_binary_eta do
          nil -> raise "You must specify :eta when using simulated binary crossover!"
          _ -> [simulated_binary_eta: simulated_binary_eta] ++ new_opts
        end

      :blend ->
        blend_alpha = Keyword.get(additional_opts, :alpha, nil)

        case blend_alpha do
          nil -> raise "You must specify :alpha when using blend crossover!"
          _ -> [blend_alpha: blend_alpha] ++ new_opts
        end

      _ ->
        new_opts
    end
  end

  @doc """
  Specify the type of mutation to use.

  Returns `Keyword.t`.

  # Parameters

    - `opts`: Keyword list of options. Defaults to an empty list.
    - `mutation_type`: `:scramble` | `:invert` | `:uniform_integer` | `:bit_flip` | `:gaussian` | `:polynomial_bounded`
    - `additional_opts`: Keyword list of options for certain algorithms.
  """
  @spec use_mutation(Keyword.t(), mutation(), Keyword.t()) :: Keyword.t()
  def use_mutation(opts \\ [], mutation_type, additional_opts \\ []) do
    new_opts = [mutation_type: mutation_type] ++ opts

    case mutation_type do
      :uniform_integer ->
        uniform_integer_min = Keyword.get(additional_opts, :min, nil)
        uniform_integer_max = Keyword.get(additional_opts, :max, nil)

        case uniform_integer_min do
          nil ->
            raise "You must specify :min when using uniform integer mutation!"

          _ ->
            case uniform_integer_max do
              nil ->
                raise "You must specify :max when using uniform integer mutation!"

              _ ->
                [uniform_integer_min: uniform_integer_min] ++
                  [uniform_integer_max: uniform_integer_max] ++
                  new_opts
            end
        end

      :polynomial_bounded ->
        polynomial_bounded_min = Keyword.get(additional_opts, :min, nil)
        polynomial_bounded_max = Keyword.get(additional_opts, :max, nil)
        polynomial_bounded_eta = Keyword.get(additional_opts, :eta, nil)

        case polynomial_bounded_min do
          nil ->
            raise "You must specify :min when using polynomial bounded mutation!"

          _ ->
            case polynomial_bounded_max do
              nil ->
                raise "You must specify :max when using polynomial bounded mutation!"

              _ ->
                case polynomial_bounded_eta do
                  nil ->
                    raise "You must specify :eta when using polynomial bounded mutation!"

                  _ ->
                    [polynomial_bounded_max: polynomial_bounded_max] ++
                      [polynomial_bounded_min: polynomial_bounded_min] ++
                      [polynomial_bounded_eta: polynomial_bounded_eta] ++
                      new_opts
                end
            end
        end

      _ ->
        new_opts
    end
  end

  @doc """
  Specify the type of selection to use.

  Returns `Keyword.t`.

  # Parameters

    - `opts`: Keyword list of options. Defaults ot an empty list.
    - `selection_type`: `:natural` | `:worst` | `:random` | `:roulette` | `:stochastic` | `:tournament`
    - `additional_opts`: Keyword list of options for certain algorithms.
  """
  @spec use_selection(Keyword.t(), mutation(), Keyword.t()) :: Keyword.t()
  def use_selection(opts \\ [], selection_type, additional_opts \\ []) do
    new_opts = [selection_type: selection_type] ++ opts

    case selection_type do
      :tournament ->
        tournsize = Keyword.get(additional_opts, :tournsize, nil)

        case tournsize do
          nil -> raise "You must specify :tournsize when using tournament selection!"
          _ -> [tournsize: tournsize] ++ new_opts
        end

      _ ->
        new_opts
    end
  end

  @doc """
  Specify the crossover rate to use.

  Returns `Keyword.t`.

  # Parameters

    - `opts`: Keyword list of options. Defaults ot an empty list.
    - `crossover_rate`: `Float` or `Function` that returns a float between 0 and 1.
  """
  @spec with_crossover_rate(Keyword.t(), rate()) :: Keyword.t()
  def with_crossover_rate(opts \\ [], crossover_rate) do
    [crossover_rate: crossover_rate] ++ opts
  end

  @doc """
  Specify the mutation rate to use.

  Returns `Keyword.t`.

  # Parameters

    - `opts`: Keyword list of options. Defaults ot an empty list.
    - `mutation_rate`: `Float` or `Function` that returns a float between 0 and 1.
  """
  @spec with_mutation_rate(Keyword.t(), rate()) :: Keyword.t()
  def with_mutation_rate(opts \\ [], mutation_rate) do
    [mutation_rate: mutation_rate] ++ opts
  end

  @doc """
  Specify the radiation level to use.

  Returns `Keyword.t`.

  # Parameters

    - `opts`: Keyword list of options. Defaults ot an empty list.
    - `radiation`: `Float` or `Function` that returns a float between 0 and 1.
  """
  @spec with_radiation(Keyword.t(), rate()) :: Keyword.t()
  def with_radiation(opts \\ [], radiation) do
    [radiation: radiation] ++ opts
  end

  @doc """
  Specify the population characteristics to use.

  Returns `Keyword.t`.

  # Parameters

    - `opts`: Keyword list of options. Defaults to an empty list.
    - `population_opts`: Keyword list of options.

  # Options

    - `size`: Size of the population.
  """
  @spec with_population(Keyword.t(), Keyword.t()) :: Keyword.t()
  def with_population(opts \\ [], population_opts) do
    size = Keyword.get(population_opts, :size, 100)
    [population_size: size] ++ opts
  end

  @doc """
  Make the algorithm a minimization algorithm.
  """
  @spec minimize(Keyword.t()) :: Keyword.t()
  def minimize(opts \\ []) do
    [minimize?: true] ++ opts
  end

  @doc """
  Define a hall of fame to use.
  """
  def hall_of_fame(opts \\ [], ref) do
    [hall_of_fame: ref] ++ opts
  end
end
