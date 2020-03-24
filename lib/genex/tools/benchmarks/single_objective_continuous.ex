defmodule Genex.Tools.Benchmarks.SingleObjectiveContinuous do
  @moduledoc """
  Provides benchmark functions for Single Objective Continuous optimization problems.

  These functions haven't been tested. More documentation/testing is coming later.
  """

  @doc """
  Cigar objective function.

  Returns ```math```.

  # Parameters

    - `xs`: `Enum`.
  """
  def cigar([x0 | xi]) do
    x0
    |> :math.pow(2)
    |> Kernel.*(
        1000000
        |> Kernel.*(
            xi
            |> Enum.map(& :math.pow(&1, 2))
            |> Enum.sum()
          )
      )
  end

  @doc """
  Plane objective function.

  Returns ```math```.

  # Parameters

    - `xs`: `Enum`.
  """
  def plane([x0 | _]), do: x0

  @doc """
  Sphere objective function.

  Returns ```math```.

  # Parameters

    - `xs`: `Enum`.
  """
  def sphere(xs) do
    xs
    |> Enum.map(& :math.pow(&1, 2))
  end

  @doc """
  Random objective function.

  Returns ```math```.

  # Parameters

    - `xs`: `Enum`.
  """
  def rand(_), do: :rand.uniform()

  @doc """
  Ackley objective function.

  Returns ```math```.

  # Parameters

    - `xs`: `Enum`.
  """
  def ackley(xs) do
    n = Enum.count(xs)
    g_x =
      -0.2
      |> Kernel.*(
          :math.sqrt(
            1
            |> Kernel./(n)
            |> Kernel.*(
                xs
                |> Enum.map(& :math.pow(&1, 2))
                |> Enum.sum()
              )
          )
        )
    h_x =
      1
      |> Kernel./(n)
      |> Kernel.*(
          xs
          |> Enum.map(& :math.cos(2*:math.pi()*&1))
          |> Enum.sum()
        )

    20
    |> Kernel.-(20 * :math.exp(g_x))
    |> Kernel.+(:math.exp(1))
    |> Kernel.-(:math.exp(h_x))
  end

  @doc """
  Bohachevsky objective function.

  Returns ```math```.

  # Paramters

    - `xs`: `Enum`.
  """
  def bohachevsky(xs) do
    [x0 | [x1 | xi]] = xs
    xs = [{x0, x1} | Enum.chunk_every(xi, 2, 1, [])]
    xs
    |> Enum.map(
        fn {xi, xiplus1} ->
          xi
          |> :math.pow(2)
          |> Kernel.+(2*:math.pow(xiplus1, 2))
          |> Kernel.-(0.3*:math.cos(3*:math.pi()*xi))
          |> Kernel.-(0.4*:math.cos(4*:math.pi()*xiplus1))
          |> Kernel.+(0.7)
        end
      )
    |> Enum.sum()
  end
  @doc """
  Griewank objective function.

  Returns ```math```.

  # Parameters

    - `xs`: `Enum`.
  """
  def griewank(xs) do
    sum = Enum.sum(Enum.map(xs, & :math.pow(&1, 2)))
    product =
      xs
      |> Enum.with_index()
      |> Enum.reduce(1,
          fn {i, xi}, acc ->
            xi
            |> Kernel./(:math.sqrt(i))
            |> :math.cos()
            |> Kernel.*(acc)
          end
        )
    1 / 4000
    |> Kernel.*(sum)
    |> Kernel.-(product)
    |> Kernel.+(1)
  end

  @doc """
  h1 objective function.

  Returns ```math```.

  # Parameters

    - `x`: `number`.
    - `y`: `number`.
  """
  def h1(x, y) do
    num =
      x
      |> Kernel.-(y / 8)
      |> :math.sin()
      |> :math.pow(2)
      |> Kernel.+(
          y
          |> Kernel.+(x / 8)
          |> :math.sin()
          |> :math.pow(2)
        )
    denom =
      x
      |> Kernel.-(8.6998)
      |> Kernel.+(
          y
          |> Kernel.-(6.7665)
          |> :math.pow(2)
        )
      |> :math.sqrt()
      |> Kernel.+(1)
    num / denom
  end

  @doc """
  Himmelblau objective function.

  Returns ```math```.

  # Paramters

    - `x`: `number`.
    - `y`: `number`.
  """
  def himmelblau(x, y) do
    x
    |> :math.pow(2)
    |> Kernel.+(y)
    |> Kernel.-(11)
    |> :math.pow(2)
    |> Kernel.+(
        x
        |> Kernel.+(:math.pow(y, 2))
        |> Kernel.-(7)
        |> :math.pow(2)
      )
  end

  @doc """
  Rastrigin objective function.

  Returns ```math```.

  # Parameters

    - `xs`: `Enum`.
  """
  def rastrigin(xs) do
    n = Enum.count(xs)
    10
    |> Kernel.*(n)
    |> Kernel.+(
        xs
        |> Enum.map(& :math.pow(&1, 2) - 10 * :math.cos(2*:math.pi()*&1))
        |> Enum.sum()
      )
  end

  @doc """
  Rosebrock objective function.

  Returns ```math```.

  # Parameters

    - `xs`: `Enum`.
  """
  def rosenbrock(xs) do
    [x0 | [x1 | xi]] = xs
    xs = [{x0, x1} | Enum.chunk_every(xi, 2, 1, [])]
    xs
    |> Enum.map(
        fn {xi, xiplus1} ->
          1 - xi
          |> :math.pow(2)
          |> Kernel.+(
              100
              |> Kernel.*(:math.pow(xiplus1 - :math.pow(xi, 2), 2))
            )
        end
      )
    |> Enum.sum()
  end

  def schaffer, do: :ok
  def schwefel, do: :ok
  def shekel, do: :ok
end
