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
  def plane([x0 | xi]) do: xi

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
    xs = [{x0, x1} | Enum.chunk_every()]
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
    sum = Enum.sum(Enum.map(& :math.pow(&1, 2)))
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

  def h1, do: :ok
  def himmelblau, do: :ok
  def rastrigin, do: :ok
  def rastrigin_scaled, do: :ok
  def rastrigin_skew, do: :ok
  def rosenbrock, do: :ok
  def schaffer, do: :ok
  def schwefel, do: :ok
  def shekel, do: :ok
end
