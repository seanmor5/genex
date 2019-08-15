defmodule MutationTest do
  use ExUnit.Case
  doctest Genex.Operators.Mutation, import: true
  alias Genex.Types.Chromosome
  alias Genex.Operators.Mutation

  setup do
    [
      c1: %Chromosome{genes: [0, 0, 1, 1, 1]},
      c2: %Chromosome{genes: [5, 6, 7, 8, 9]}
    ]
  end

  @radiation 0.5

  describe "mutation operators" do
    test "bit_flip/2", context do
      new_c = Mutation.bit_flip(context.c1, @radiation)
      assert length(new_c.genes) == 5
      assert_raise ArgumentError, fn -> Mutation.bit_flip(context.c1, -5) end
    end

    test "invert/2", context do
      new_c = Mutation.invert(context.c1, @radiation)
      assert new_c.genes == [0, 0, 1, 1, 1]
      assert_raise ArgumentError, fn -> Mutation.invert(context.c1, -5) end
    end

    test "scramble/2", context do
      new_c = Mutation.scramble(context.c1, @radiation)
      assert length(new_c.genes) == 5
      assert_raise ArgumentError, fn -> Mutation.scramble(context.c1, -5) end
    end

    test "uniform_integer/4", context do
      new_c = Mutation.uniform_integer(context.c1, @radiation, 0, 1)
      assert length(new_c.genes) == 5
      assert_raise ArgumentError, fn -> Mutation.uniform_integer(context.c1, -5, 0, 1) end
    end

    test "gaussian/2", context do
      new_c = Mutation.gaussian(context.c1, @radiation)
      refute new_c.genes == [0, 0, 1, 1, 1]
      assert length(new_c.genes) == 5
      assert_raise ArgumentError, fn -> Mutation.gaussian(context.c1, -5) end
    end

    test "polynomial_bounded/4", context do
      new_c = Mutation.polynomial_bounded(context.c2, @radiation, 0.5, 5, 9)
      refute new_c.genes == [5, 6, 7, 8, 9]
      assert length(new_c.genes) == 5
      assert_raise ArgumentError, fn -> Mutation.polynomial_bounded(context.c2, -5, 0.5, 5, 9) end
    end
  end
end
