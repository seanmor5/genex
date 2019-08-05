defmodule MutationTest do
  use ExUnit.Case

  alias Genex.Chromosome
  alias Genex.Operators.Mutation

  setup do
    [
      c1: %Chromosome{genes: [0, 0, 1, 1, 1]}
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
    end
  end
end