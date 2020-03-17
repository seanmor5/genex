defmodule ChromosomeTest do
  use ExUnit.Case
  alias Genex.Types.Chromosome

  setup do
    [
      c1: %Chromosome{genes: [1, 2, 3]},
      c2: %Chromosome{genes: [1, 2, 3, 4, 5]}
    ]
  end

  describe "chromosome" do
    test "String.Chars impl", context do
      assert "#{context.c1}" == "[1, 2, 3]"
    end
  end
end
