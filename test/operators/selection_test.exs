defmodule SelectionTest do
  use ExUnit.Case
  alias Genex.Operators.Selection
  alias Genex.Chromosome

  setup do
    [
      pop: [
        %Chromosome{genes: [1, 1, 1, 1, 1], fitness: 5},
        %Chromosome{genes: [1, 1, 1, 0, 1], fitness: 4},
        %Chromosome{genes: [1, 0, 1, 0, 1], fitness: 3},
        %Chromosome{genes: [0, 0, 1, 0, 1], fitness: 2},
        %Chromosome{genes: [0, 0, 0, 0, 1], fitness: 1}
      ]
    ]
  end

  describe "selection" do
    test "natural/2", context do
      selected = Selection.natural(context.pop, 2)
      assert length(selected) == 2
      assert hd(selected).fitness == 5
      assert %Chromosome{} = hd(selected)
    end

    test "random/2", context do
      selected = Selection.random(context.pop, 2)
      assert length(selected) == 2
      assert %Chromosome{} = hd(selected)
    end

    test "worst/2", context do
      selected = Selection.worst(context.pop, 2)
      assert length(selected) == 2
      assert hd(selected).fitness == 1
    end

    test "roulette/2", context do
      selected = Selection.roulette(context.pop, 2)
      assert length(selected) == 2
      assert %Chromosome{} = hd(selected)
    end

    test "tournament/3", context do
      selected = Selection.tournament(context.pop, 2, 4)
      assert length(selected) == 2
      assert %Chromosome{} = hd(selected)
    end

    test "stochastic_universal_sampling/3", context do
      selected = Selection.stochastic_universal_sampling(context.pop, 2)
      assert length(selected) == 2
      assert %Chromosome{} = hd(selected)
    end
  end
end
