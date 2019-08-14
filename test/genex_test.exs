defmodule GenexTest do
  use ExUnit.Case
  alias Genex.Chromosome
  alias Genex.Population

  defmodule Impl do
    use Genex
    def encoding, do: for(_ <- 1..15, do: Enum.random(0..1))
    def fitness_function(c), do: Enum.sum(c.genes)
    def terminate?(p), do: p.max_fitness == 15
    def statistics, do: [mean: &Statistics.mean/1]
  end

  setup do
    [
      pop: %Population{
        chromosomes: [
          %Chromosome{genes: [1, 1, 1, 1, 1], fitness: 5, size: 5},
          %Chromosome{genes: [0, 0, 0, 0, 1], fitness: 1, size: 5},
          %Chromosome{genes: [1, 1, 1, 0, 1], fitness: 4, size: 5},
          %Chromosome{genes: [1, 0, 1, 0, 1], fitness: 3, size: 5},
          %Chromosome{genes: [0, 0, 1, 0, 1], fitness: 2, size: 5}
        ]
      },
      impl: Impl
    ]
  end

  describe "chromosome" do
    test "String.Chars impl" do
      c1 = %Chromosome{genes: [1, 2, 3]}
      assert "#{c1}" == "[1, 2, 3]"
    end

    test "binary/1" do
      g1 = Chromosome.binary()
      g2 = Chromosome.binary(size: 64)
      assert length(g1) == 32
      assert length(g2) == 64
      assert length(Enum.filter(g1, fn x -> x != 0 and x != 1 end)) == 0
      assert length(Enum.filter(g2, fn x -> x != 0 and x != 1 end)) == 0
    end

    test "integer_value/1" do
      g1 = Chromosome.integer_value(size: 10, min: 0, max: 10)
      assert length(g1) == 10
      assert length(Enum.filter(g1, fn x -> x >= 0 and x <= 10 end)) == 10
    end

    test "permutation/1" do
      g1 = Chromosome.permutation()
      assert length(g1) == 10
      assert length(Enum.uniq(g1)) == 10
    end

    test "alphabetic/1" do
      g1 = Chromosome.alphabetic()
      assert length(g1) == 10
    end
  end

  describe "population" do
    test "sort/2", context do
      sorted_chromosomes = [
        %Chromosome{genes: [1, 1, 1, 1, 1], fitness: 5, size: 5},
        %Chromosome{genes: [1, 1, 1, 0, 1], fitness: 4, size: 5},
        %Chromosome{genes: [1, 0, 1, 0, 1], fitness: 3, size: 5},
        %Chromosome{genes: [0, 0, 1, 0, 1], fitness: 2, size: 5},
        %Chromosome{genes: [0, 0, 0, 0, 1], fitness: 1, size: 5}
      ]

      sorted = Population.sort(context.pop, false)
      refute context.pop.chromosomes == sorted_chromosomes
      assert sorted.chromosomes == sorted_chromosomes
    end
  end

  describe "genex" do
    test "seed/1", context do
      assert {:ok, %Population{} = pop} = context.impl.seed()
      assert pop.size == 100
    end

    test "evaluate/2", context do
      assert {:ok, %Population{} = pop} = context.impl.evaluate(context.pop)
      refute hd(pop.chromosomes).fitness == 0
    end

    test "parent_selection/2", context do
      assert {:ok, %Population{} = pop} = context.impl.select_parents(context.pop)
      refute length(pop.parents) == 0
    end

    test "crossover/2", context do
      {:ok, pop} = context.impl.seed()
      {:ok, pop} = context.impl.evaluate(pop)
      {:ok, pop} = context.impl.select_parents(pop)
      assert {:ok, %Population{} = pop} = context.impl.crossover(pop)
      refute length(pop.children) == 0
    end

    test "mutation/2", context do
      {:ok, pop} = context.impl.seed()
      {:ok, pop} = context.impl.evaluate(pop)
      {:ok, pop} = context.impl.select_parents(pop)
      {:ok, pop} = context.impl.crossover(pop)
      assert {:ok, %Population{} = pop} = context.impl.mutate(pop)
      refute length(pop.chromosomes) == 0
    end

    test "select_survivors/2", context do
      {:ok, pop} = context.impl.seed()
      {:ok, pop} = context.impl.evaluate(pop)
      {:ok, pop} = context.impl.select_parents(pop)
      {:ok, pop} = context.impl.crossover(pop)
      {:ok, pop} = context.impl.mutate(pop)
      assert {:ok, %Population{} = pop} = context.impl.select_survivors(pop)
      refute length(pop.survivors) == 0
    end

    test "advance/2", context do
      {:ok, pop} = context.impl.seed()
      {:ok, pop} = context.impl.evaluate(pop)
      {:ok, pop} = context.impl.select_parents(pop)
      {:ok, pop} = context.impl.crossover(pop)
      {:ok, pop} = context.impl.mutate(pop)
      {:ok, pop} = context.impl.select_survivors(pop)
      assert {:ok, %Population{} = pop} = context.impl.advance(pop)
      assert pop.generation == 1
      assert pop.survivors == nil
      assert pop.parents == nil
      assert pop.children == nil
    end

    test "statistics/0", context do
      assert [mean: fun] = context.impl.statistics()
    end
  end
end
