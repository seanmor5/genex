defmodule Genex.Tools.Crossover do
  alias Genex.Types.Chromosome

  @moduledoc """
  Implementation of several popular crossover methods.

  Crossover is analagous to reproduction or biological crossover. Genex utilizes pairs of chromosomes to create offspring from the genetic material of parent chromosomes. Crossover happens with some probability `P(c)`. Typically this is a high probability.

  The probability of crossover or `crossover_rate` as it is called in our case, determines the number of parents selected to breed for the next generation. See more on this in the `Selection` documentation.

  Crossover operators are generic. As with any optimization problem, no single method will be perfect. Genex offers a variety of crossover operators to experiment with; however, you may find that you need to write your own to fit your specific use case. You can do this by overriding the `crossover` method.

  Each time a crossover takes place, 2 new children are created. These children then populate the `children` field of the `Population` struct before they are merged into the new population.
  """

  @doc """
  Performs single point crossover at a random point.

  This will swap a random slice of genes from each chromosome, producing 2 new chromosomes.

  Returns `{%Chromosome{}, %Chromosome{}}`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
  """
  @spec single_point(Chromosome.t(), Chromosome.t()) :: {Chromosome.t(), Chromosome.t()}
  def single_point(p1, p2) do
    chromosome_length = p1.size
    point = :rand.uniform(chromosome_length)
    {g1, g2} = Enum.split(p1.genes, point)
    {g3, g4} = Enum.split(p2.genes, point)
    {c1, c2} = {g1 ++ g4, g3 ++ g2}
    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  @doc """
  Performs two-point crossover at a random point.

  This will swap two random slices of genes from each chromosome, producing 2 new chromosomes.

  Returns `%Chromosome{}`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
  """
  @spec two_point(Chromosome.t(), Chromosome.t()) :: {Chromosome.t(), Chromosome.t()}
  def two_point(p1, p2) do
    chromosome_length = p1.size
    a = :rand.uniform(chromosome_length - 1)
    b = :rand.uniform(chromosome_length - 2)

    first =
      if b >= a do
        a
      else
        b
      end

    second =
      if b >= a do
        b + 1
      else
        a
      end

    {slice1, rem1} = Enum.split(p1.genes, first)
    {slice2, rem2} = Enum.split(p2.genes, first)
    {slice3, rem3} = Enum.split(rem1, second - first)
    {slice4, rem4} = Enum.split(rem2, second - first)

    {c1, c2} = {
      slice1 ++ slice4 ++ rem3,
      slice2 ++ slice3 ++ rem4
    }

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  @doc false
  def two_point, do: &two_point(&1, &2)

  @doc """
  Performs uniform crossover.

  This will swap random genes from each chromosome according to some specified rate, producing 2 new chrmosomes.

  Returns `Chromosome`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
    - `rate`: `Float` between 0 and 1 representing rates to swap genes.
  """
  @spec uniform(Chromosome.t(), Chromosome.t(), float()) :: {Chromosome.t(), Chromosome.t()}
  def uniform(p1, p2, rate) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        if :rand.uniform() < rate do
          {x, y}
        else
          {y, x}
        end
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: p1.size}, %Chromosome{genes: c2, size: p1.size}}
  end

  @doc """
  Performs a blend crossover.

  This will blend genes according to some alpha between 0 and 1.

  Returns `{%Chromosome{}, %Chromosome{}}`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
    - `alpha`: `Float` between 0 and 1 representing percentage of each parent to blend into children.
  """
  @spec blend(Chromosome.t(), Chromosome.t(), float()) :: {Chromosome.t(), Chromosome.t()}
  def blend(p1, p2, alpha) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        gamma = (1 + 2 * alpha) * :rand.uniform() - alpha

        {
          (1 - gamma) * x + gamma * y,
          gamma * x + (1 - gamma) * y
        }
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: p1.size}, %Chromosome{genes: c2, size: p1.size}}
  end

  @doc false

  @doc """
  Performs a simulated binary crossover.

  Returns `{%Chromosome{}, %Chromosome{}}`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
    - `eta`: `Float`
  """
  @spec simulated_binary(Chromosome.t(), Chromosome.t(), number()) ::
          {Chromosome.t(), Chromosome.t()}
  def simulated_binary(p1, p2, eta) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        rand = :rand.uniform()

        beta =
          if rand <= 0.5 do
            2 * rand
          else
            1 / (2 * (1 - rand))
          end

        beta = :math.pow(beta, 1 / eta + 1)

        {
          0.5 * ((1 + beta) * x + (1 - beta) * y),
          0.5 * ((1 - beta) * x + (1 + beta) * y)
        }
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: p1.size}, %Chromosome{genes: c2, size: p1.size}}
  end

  @doc """
  Performs a messy single point crossover at random points.

  This crossover disregards the length of the chromosome and will often arbitrarily increase or decrease it's size.

  Returns `{%Chromosome{}, %Chromosome{}}`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
  """
  @spec messy_single_point(Chromosome.t(), Chromosome.t()) :: {Chromosome.t(), Chromosome.t()}
  def messy_single_point(p1, p2) do
    chromosome_length = length(p1.genes)
    point1 = if chromosome_length == 0, do: 0, else: :rand.uniform(chromosome_length)
    point2 = if chromosome_length == 0, do: 0, else: :rand.uniform(chromosome_length)
    {g1, g2} = Enum.split(p1.genes, point1)
    {g3, g4} = Enum.split(p2.genes, point2)
    {c1, c2} = {g1 ++ g4, g3 ++ g2}
    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end

  @doc """
  Performs Order One (Davis Order) crossover of a random slice.

  **Note**: This algorithm only works if your encoding is a permutation.

  Returns `{%Chromosome{}, %Chromosome{}}`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
  """
  @spec order_one(Chromosome.t(), Chromosome.t()) :: {Chromosome.t(), Chromosome.t()}
  def order_one(p1, p2) do
    lim = Enum.count(p1.genes) - 1
    # Get random range
    {i1, i2} =
      [:rand.uniform(lim), :rand.uniform(lim)]
      |> Enum.sort()
      |> List.to_tuple()

    # p2 contribution
    slice1 = Enum.slice(p1.genes, i1..i2)
    slice1_set = MapSet.new(slice1)
    p2_contrib = Enum.reject(p2.genes, &MapSet.member?(slice1_set, &1))
    {head1, tail1} = Enum.split(p2_contrib, i1)

    # p1 contribution
    slice2 = Enum.slice(p2.genes, i1..i2)
    slice2_set = MapSet.new(slice2)
    p1_contrib = Enum.reject(p1.genes, &MapSet.member?(slice2_set, &1))
    {head2, tail2} = Enum.split(p1_contrib, i1)

    # Make and return
    {c1, c2} = {head1 ++ slice1 ++ tail1, head2 ++ slice2 ++ tail2}
    {%Chromosome{genes: c1, size: p1.size}, %Chromosome{genes: c2, size: p2.size}}
  end

  def multi_point, do: :ok
  def partialy_matched, do: :ok
  def uniform_partialy_matched, do: :ok
  def simulted_binary_bounded, do: :ok
  def cycle, do: :ok
  def order_multi, do: :ok
  def collision, do: :ok
  def cut_on_worst, do: :ok

  ################ CLOSURES #################
  @doc false
  def single_point, do: &single_point(&1, &2)

  @doc false
  def two_point, do: &two_point(&1, &2)

  @doc false
  def uniform(rate: rate) when not is_float(rate),
    do: raise("Invalid arguments provided to uniform crossover. `rate` must be type `float`.")

  def uniform(rate: rate), do: &uniform(&1, &2, rate)

  def uniform(args),
    do:
      raise("Invalid arguments provided to uniform crossover. Expected `rate: rate` got #{args}.")

  @doc false
  def blend(alpha: alpha) when not is_float(alpha),
    do: raise("Invalid arguments provided to blend crossover. `alpha` must be type `float`.")

  def blend(alpha: alpha), do: &blend(&1, &2, alpha)

  def blend(args),
    do:
      raise("Invalid arguments provided to blend crossover. Expected `alpha: alpha` got #{args}.")

  @doc false
  def simulated_binary(eta: eta) when not is_float(eta),
    do:
      raise(
        "Invalid arguments provided to simulated binary crossover. `eta` must be type `float`."
      )

  def simulated_binary(eta: eta), do: &simulated_binary(&1, &2, eta)

  def simulated_binary(args),
    do:
      raise(
        "Invalid arguments provided to simulated binary crossover. Expected `alpha: alpha` got #{
          args
        }."
      )

  @doc false
  def messy_single_point, do: &messy_single_point(&1, &2)

  @doc false
  def order_one, do: &order_one(&1, &2)
end
