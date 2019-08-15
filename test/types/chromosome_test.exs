defmodule ChromosomeTest do
  use ExUnit.Case
  alias Genex.Types.Chromosome

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
end
