defmodule Genex.Tools.Benchmarks.SymbolicRegression do
  @moduledoc """
  Provides benchmark functions for Symbolic Regression programs with Genetic Programming.

  These functions haven't been tested. More documentation/testing is coming later.
  """

  @doc """
  Kotanchek benchmark.

  Returns ```math```.

  # Parameters

    - `x`: `number`.
    - `y`: `number`.
  """
  def kotanchek(x, y) do
    1 - x
    |> :math.pow(2)
    |> :math.exp()
    |> Kernel./(
        3.2
        |> Kernel.+(
            :math.pow(y - 2.5, 2)
          )
      )
  end

  @doc """
  Salustowicz 1-D benchmark function.

  Returns ```math```.

  # Parameters

    - `x`: `number`.
  """
  def salustowicz_1d(x) do
    -x
    |> :math.exp()
    |> Kernel.*(:math.pow(x, 3))
    |> Kernel.*(:math.cos(x))
    |> Kernel.*(:math.sin(x))
    |> Kernel.*(
        x
        |> :math.cos()
        |> Kernel.*(:math.pow(:math.sin(x), 2))
        |> Kernel.-(1)
      )
  end

  @doc """
  Salustowicz 2-D benchmark function.

  Returns ```math```.

  # Parameters

    - `x`: `number`.
    - `y`: `number`.
  """
  def salustowicz_2d(x, y) do
    -x
    |> :math.exp()
    |> Kernel.*(:math.pow(x, 3))
    |> Kernel.*(:math.cos(x))
    |> Kernel.*(:math.sin(x))
    |> Kernel.*(
        x
        |> :math.cos()
        |> Kernel.*(:math.pow(:math.sin(x), 2))
        |> Kernel.-(1)
      )
    |> Kernel.*(y - 5)
  end

  @doc """
  Unwrapped Ball benchmark function.

  Returns ```math```.

  # Parameters

    - `xs`: `Enum` of `number`.
  """
  def unwrapped_ball(xs) do
    10
    |> Kernel./(
        5
        |> Kernel.+(
            xs
            |> Enum.map(& (:math.pow(&1 - 3, 2)))
            |> Enum.sum()
          )
      )
  end

  @doc """
  Rational polynomial benchmark functon.

  Returns ```math```.

  # Parameters

    - `x`: `number`.
    - `y`: `number`.
    - `z`: `number`.
  """
  def rational_polynomial(x, y, z) do
    30
    |> Kernel.*(x - 1)
    |> Kernel.*(z - 1)
    |> Kernel./(
        y
        |> :math.pow(2)
        |> Kernel.*(x - 10)
      )
  end

  @doc """
  Rational polynomial in 2 dimensions benchmark function.

  Returns ```math```.

  # Parameters

    - `x`: `number`.
    - `y`: `number`.
  """
  def rational_polynomial2(x, y) do
    x - 3
    |> :math.pow(4)
    |> Kernel.+(:math.pow(y - 3), 3)
    |> Kernel.-(y - 3)
    |> Kernel./(
        y - 2
        |> :math.pow(4)
        |> Kernel.+(10)
      )
  end

  @doc """
  Sine-Cosine benchmark function.

  Returns ```math```.

  # Parameters

    - `x`: `number`.
    - `y`: `number`.
  """
  def sin_cos(x, y) do
    6
    |> Kernel.*(:math.sin(x))
    |> Kernel.*(:math.cos(y))
  end

  @doc """
  Ripple benchmark function.

  Returns ```math```.

  # Parameters

    - `x`: `number`
    - `y`: `number`
  """
  def ripple(x, y) do
    x - 3
    |> Kernel.*(y - 3)
    |> Kernel.+(
        2
        |> Kernel.*(
            x - 4
            |> Kernel.*(y - 4)
            |> :math.sin()
          )
      )
  end
end
