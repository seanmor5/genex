defmodule Genex.Tools.Crossover do
  alias Genex.Types.Chromosome

  @moduledoc """
  Implementation of several popular crossover methods.

  Crossover is analagous to reproduction or biological crossover. Genex utilizes pairs of chromosomes to create offspring from the genetic material of parent chromosomes. Crossover happens with some probability `P(c)`. Typically this is a high probability.

  The probability of crossover or `crossover_rate` as it is called in our case, determines the number of parents selected to breed for the next generation. See more on this in the `Selection` documentation.

  Crossover operators are generic. As with any optimization problem, no single method will be perfect. Genex offers a variety of crossover operators to experiment with; however, you may find that you need to write your own to fit your specific use case. You can do this by writing your own method and referencing it in the `:crossover_type` option.

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

    {%Chromosome{genes: c1, size: length(c1), weights: p1.weights, f: p1.f, collection: p1.collection},
     %Chromosome{genes: c2, size: length(c2), weights: p2.weights, f: p2.f, collection: p2.collection}}
  end

  @doc false
  def single_point, do: &single_point(&1, &2)

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

    {%Chromosome{genes: c1, size: length(c1), weights: p1.weights, f: p1.f, collection: p1.collection},
     %Chromosome{genes: c2, size: length(c2), weights: p2.weights, f: p2.f, collection: p2.collection}}
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
    - `probability`: `Float` between 0 and 1 representing rates to swap genes.
  """
  @spec uniform(Chromosome.t(), Chromosome.t(), float()) :: {Chromosome.t(), Chromosome.t()}
  def uniform(p1, p2, probability) do
    {c1, c2} =
      p1.genes
      |> Enum.zip(p2.genes)
      |> Enum.map(fn {x, y} ->
        if :rand.uniform() < probability do
          {x, y}
        else
          {y, x}
        end
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: p1.size, weights: p1.weights, f: p1.f, collection: p1.collection},
     %Chromosome{genes: c2, size: p1.size, weights: p2.weights, f: p2.f, collection: p2.collection}}
  end

  @doc false
  def uniform(probability: probability) when not is_float(probability),
    do:
      raise(
        "Invalid arguments provided to uniform crossover. `probability` must be type `float`."
      )

  def uniform(probability: probability), do: &uniform(&1, &2, probability)

  def uniform(args),
    do:
      raise("Invalid arguments provided to uniform crossover. Expected `rate: rate` got #{args}.")

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

    {%Chromosome{genes: c1, size: p1.size, weights: p1.weights, f: p1.f, collection: p1.collection},
     %Chromosome{genes: c2, size: p1.size, weights: p2.weights, f: p2.f, collection: p2.collection}}
  end

  @doc false
  def blend(alpha: alpha) when not is_float(alpha),
    do: raise("Invalid arguments provided to blend crossover. `alpha` must be type `float`.")

  def blend(alpha: alpha), do: &blend(&1, &2, alpha)

  def blend(args),
    do:
      raise("Invalid arguments provided to blend crossover. Expected `alpha: alpha` got #{args}.")

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

    {%Chromosome{genes: c1, size: p1.size, weights: p1.weights, f: p1.f, collection: p1.collection},
     %Chromosome{genes: c2, size: p1.size, weights: p2.weights, f: p2.f, collection: p2.collection}}
  end

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

    {%Chromosome{genes: c1, size: length(c1), weights: p1.weights, f: p1.f, collection: p1.collection},
     %Chromosome{genes: c2, size: length(c2), weights: p2.weights, f: p2.f, collection: p2.collection}}
  end

  @doc false
  def messy_single_point, do: &messy_single_point(&1, &2)

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

    {%Chromosome{genes: c1, size: p1.size, weights: p1.weights, f: p1.f, collection: p1.collection},
     %Chromosome{genes: c2, size: p2.size, weights: p2.weights, f: p2.f, collection: p2.collection}}
  end

  @doc false
  def order_one, do: &order_one(&1, &2)

  @doc """
  Performs multi-point crossover of `p1` and `p2`.

  Returns `{%Chromosome{}, %Chromosome{}}`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
    - `n`: Number of crossover points.
  """
  @spec multi_point(Chromosome.t(), Chromosome.t(), non_neg_integer()) ::
          {Chromosome.t(), Chromosome.t()}
  def multi_point(p1, p2, 0), do: {p1, p2}
  def multi_point(p1, p2, 1), do: single_point(p1, p2)
  def multi_point(p1, p2, 2), do: two_point(p1, p2)

  def multi_point(p1, p2, n) do
    lim = Enum.count(p1.genes)
    cx_points = for _ <- 1..n, do: :rand.uniform(lim - 1)
    # no duplicates and sort
    cx_points = MapSet.to_list(MapSet.new(cx_points))

    {_, c1, c2} =
      [0 | cx_points]
      |> Enum.chunk_every(2, 1, [lim])
      |> Enum.map(&List.to_tuple(&1))
      |> Enum.map(fn {lo, hi} ->
        {
          Enum.slice(p1.genes, lo, hi - lo),
          Enum.slice(p2.genes, lo, hi - lo)
        }
      end)
      |> Enum.reduce(
        {1, [], []},
        fn {h1, h2}, {n, c1, c2} ->
          if rem(n, 2) == 0 do
            {n + 1, c1 ++ h2, c2 ++ h1}
          else
            {n + 1, c1 ++ h1, c2 ++ h2}
          end
        end
      )

    {
      %Chromosome{genes: c1, size: Enum.count(c1), weights: p1.weights, f: p1.f, collection: p1.collection},
      %Chromosome{genes: c2, size: Enum.count(c2), weights: p2.weights, f: p2.f, collection: p2.collection}
    }
  end

  @doc false
  def multi_point(cx_points: cx_points), do: &multi_point(&1, &2, cx_points)
  def multi_point(_), do: raise("Invalid arguments provided to multi point crossover.")

  @doc """
  Performs a partialy matched crossover of `p1` and `p2`.

  Returns `{%Chromosome{}, %Chromosome{}}`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
  """
  @spec partialy_matched(Chromosome.t(), Chromosome.t()) :: {Chromosome.t(), Chromosome.t()}
  def partialy_matched(p1, p2) do
    ind1 = Enum.to_list(p1.genes)
    ind2 = Enum.to_list(p2.genes)

    lim = p1.size - 1

    c1 = for i <- 0..lim, do: Enum.find_index(ind1, fn x -> x == i end)
    c2 = for i <- 0..lim, do: Enum.find_index(ind2, fn x -> x == i end)

    cxpoint1 = :rand.uniform(lim)
    cxpoint2 = :rand.uniform(lim - 1)

    {cxpoint1, cxpoint2} =
      if cxpoint2 >= cxpoint1, do: {cxpoint1, cxpoint1 + 1}, else: {cxpoint2, cxpoint1}

    {ind1, ind2, _, _} =
      cxpoint1..cxpoint2
      |> Enum.reduce(
        {ind1, ind2, c1, c2},
        fn i, {acc1, acc2, acc3, acc4} ->
          temp1 = Enum.at(acc1, i)
          temp2 = Enum.at(acc2, i)

          acc1 =
            acc1
            |> List.update_at(i, fn _ -> temp2 end)
            |> List.update_at(Enum.at(acc3, temp2), fn _ -> temp1 end)

          acc2 =
            acc2
            |> List.update_at(i, fn _ -> temp1 end)
            |> List.update_at(Enum.at(acc4, temp1), fn _ -> temp2 end)

          acc3 =
            acc3
            |> List.update_at(temp1, fn _ -> Enum.at(acc3, temp2) end)
            |> List.update_at(temp2, fn _ -> Enum.at(acc3, temp1) end)

          acc4 =
            acc4
            |> List.update_at(temp1, fn _ -> Enum.at(acc4, temp2) end)
            |> List.update_at(temp2, fn _ -> Enum.at(acc4, temp1) end)

          {acc1, acc2, acc3, acc4}
        end
      )

    {%Chromosome{genes: ind1, size: Enum.count(ind1), weights: p1.weights, f: p1.f, collection: p1.collection},
     %Chromosome{genes: ind2, size: Enum.count(ind2), weights: p2.weights, f: p2.f, collection: p2.collection}}
  end

  @doc false
  def partialy_matched, do: &partialy_matched(&1, &2)

  @doc """
  Performs a uniform partialy matched crossover of `p1` and `p2`.

  Returns `{%Chromosome{}, %Chromosome{}}`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
    - `probability`: Probability of swap during PMX.
  """
  @spec uniform_partialy_matched(Chromosome.t(), Chromosome.t(), float()) ::
          {Chromosome.t(), Chromosome.t()}
  def uniform_partialy_matched(p1, p2, probability) do
    ind1 = Enum.to_list(p1.genes)
    ind2 = Enum.to_list(p2.genes)

    lim = p1.size - 1

    c1 = for i <- 0..lim, do: Enum.find_index(ind1, fn x -> x == i end)
    c2 = for i <- 0..lim, do: Enum.find_index(ind2, fn x -> x == i end)

    cxpoint1 = :rand.uniform(lim)
    cxpoint2 = :rand.uniform(lim - 1)

    {cxpoint1, cxpoint2} =
      if cxpoint2 >= cxpoint1, do: {cxpoint1, cxpoint1 + 1}, else: {cxpoint2, cxpoint1}

    {ind1, ind2, _, _} =
      cxpoint1..cxpoint2
      |> Enum.reduce(
        {ind1, ind2, c1, c2},
        fn i, {acc1, acc2, acc3, acc4} ->
          if :rand.uniform() < probability do
            temp1 = Enum.at(acc1, i)
            temp2 = Enum.at(acc2, i)

            acc1 =
              acc1
              |> List.update_at(i, fn _ -> temp2 end)
              |> List.update_at(Enum.at(acc3, temp2), fn _ -> temp1 end)

            acc2 =
              acc2
              |> List.update_at(i, fn _ -> temp1 end)
              |> List.update_at(Enum.at(acc4, temp1), fn _ -> temp2 end)

            acc3 =
              acc3
              |> List.update_at(temp1, fn _ -> Enum.at(acc3, temp2) end)
              |> List.update_at(temp2, fn _ -> Enum.at(acc3, temp1) end)

            acc4 =
              acc4
              |> List.update_at(temp1, fn _ -> Enum.at(acc4, temp2) end)
              |> List.update_at(temp2, fn _ -> Enum.at(acc4, temp1) end)

            {acc1, acc2, acc3, acc4}
          else
            {acc1, acc2, acc3, acc4}
          end
        end
      )

    {%Chromosome{genes: ind1, size: Enum.count(ind1), weights: p1.weights, f: p1.f, collection: p1.collection},
     %Chromosome{genes: ind2, size: Enum.count(ind2), weights: p2.weights, f: p2.f, collection: p2.collection}}
  end

  @doc false
  def uniform_partialy_matched, do: &uniform_partialy_matched(&1, &2, 0.75)

  @doc false
  def uniform_partialy_matched(probability: probability),
    do: &uniform_partialy_matched(&1, &2, probability)

  @doc """
  Performs modified crossover of `p1` and `p2`.

  Returns `{%Chromosome{}, %Chromosome{}}`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
    - `repair`: `Function` specifying how to repair chromosome.
  """
  @spec modified(Chromosome.t(), Chromosome.t(), (Chromosome.t() -> Chromosome.t())) ::
          {Chromosome.t(), Chromosome.t()}
  def modified(p1, p2, repair) do
    lim = p1.size
    point = :rand.uniform(lim)
    {g1, g2} = Enum.split(p1.genes, point)
    {g3, g4} = Enum.split(p2.genes, point)
    {c1, c2} = {g1 ++ g4, g3 ++ g2}
    {c1, c2} = {repair.(c1), repair.(c2)}

    {%Chromosome{genes: c1, size: lim, weights: p1.weights, f: p1.f, collection: p1.collection},
     %Chromosome{genes: c2, size: lim, weights: p2.weights, f: p2.f, collection: p2.collection}}
  end

  @doc false
  def modified(repair: repair), do: &modified(&1, &2, repair)

  @doc """
  Performs cut-on-worst crossover of `p1` and `p2`.

  Returns `{%Chromosome{}, %Chromosome{}}`.

  # Parameters
    - `p1`: Parent one.
    - `p2`: Parent two.
    - `heuristic`: `Function` with arity 2 to measure "badness" of a gene.
    - `repair`: `Function` specifying how to repair chromosome.
  """
  @spec cut_on_worst(
          Chromosome.t(),
          Chromosome.t(),
          (Chromosome.t(), any() -> number()),
          (Chromosome.t() -> Chromosome.t())
        ) :: {Chromosome.t(), Chromosome.t()}
  def cut_on_worst(p1, p2, heuristic, repair) do
    {p1_i, p1_worst} =
      p1.genes
      |> Enum.with_index()
      |> Enum.sort_by(fn g -> heuristic.(p1, g) end, &>=/2)
      |> Kernel.hd()

    {p2_i, p2_worst} =
      p2.genes
      |> Enum.with_index()
      |> Enum.sort_by(fn g -> heuristic.(p2, g) end, &>=/2)
      |> Kernel.hd()

    p1_val = heuristic.(p1, p1_worst)
    p2_val = heuristic.(p2, p2_worst)

    cut = if p1_val > p2_val, do: p1_i, else: p2_i
    {g1, g2} = Enum.split(p1.genes, cut)
    {g3, g4} = Enum.split(p2.genes, cut)
    {c1, c2} = {g1 ++ g4, g3 ++ g2}
    {c1, c2} = {repair.(c1), repair.(c2)}

    {%Chromosome{genes: c1, size: Enum.count(c1), weights: p1.weights, f: p1.f, collection: p1.collection},
     %Chromosome{genes: c2, size: Enum.count(c2), weights: p2.weights, f: p2.f, collection: p2.collection}}
  end

  @doc false
  def cut_on_worst(heuristic: heuristic, repair: repair),
    do: &cut_on_worst(&1, &2, heuristic, repair)

  @doc false
  def simulated_binary_bounded, do: :ok

  @doc false
  def cycle, do: :ok

  @doc false
  def order_multi, do: :ok

  @doc false
  def collision, do: :ok
end
