defmodule PopulationTest do
  use ExUnit.Case
  alias Genex.Chromosome
  alias Genex.Population

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
      }
    ]
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
      sorted_reverse = Population.sort(context.pop, true)
      refute context.pop.chromosomes == sorted_chromosomes
      assert sorted_reverse.chromosomes == sorted_chromosomes |> Enum.reverse()
      assert sorted.chromosomes == sorted_chromosomes
    end
  end
end
