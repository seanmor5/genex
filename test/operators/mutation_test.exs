defmodule MutationTest do
  use ExUnit.Case

  alias Genex.Chromosome
  alias Genex.Operators.Mutation

  setup do
    [
      c1: %Chromosome{genes: [0, 0, 1, 1, 1]},
      c2: %Chromosome{genes: [5, 6, 7, 8, 9]}
    ]
  end

  describe "mutation operators" do
    test "bit_flip/1", context do
      new_c = Mutation.bit_flip(context.c1)
      assert new_c.genes == [1, 1, 0, 0, 0]
    end

    test "invert/1", context do
      new_c = Mutation.invert(context.c1)
      assert new_c.genes == [1, 1, 1, 0, 0]
    end

    test "scramble/1", context do
      new_c = Mutation.scramble(context.c1)
      refute new_c.genes == [0, 0, 1, 1, 1]
      assert length(new_c.genes) == 5
    end

    test "uniform_integer/3", context do
      new_c = Mutation.uniform_integer(context.c1, 0, 1)
      refute new_c.genes == [0, 0, 1, 1, 1]
      assert length(new_c.genes) == 5
    end

    test "gaussian/1", context do
      new_c = Mutation.gaussian(context.c1)
      refute new_c.genes == [0, 0, 1, 1, 1]
      assert length(new_c.genes) == 5
    end

    test "polynomial_bounded/4", context do
      new_c = Mutation.polynomial_bounded(context.c2, 0.5, 5, 9)
      refute new_c.genes == [5, 6, 7, 8, 9]
      assert length(new_c.genes) == 5
    end
  end
end