defmodule GenexTest do
  use ExUnit.Case
  alias Genex.Chromosome
  alias Genex.Population

  describe "chromosome" do
    test "get_fitness/1" do
      c1 = %Chromosome{genes: [1, 2, 3], fitness: 6}
      assert Chromosome.get_fitness(c1) == 6
    end

    test "String.Chars impl" do
      c1 = %Chromosome{genes: [1, 2, 3]}
      assert "#{c1}" == "[1, 2, 3]"
    end
  end
end
