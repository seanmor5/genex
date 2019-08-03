defmodule GenexTest do
  use ExUnit.Case
  alias Genex.Population
  alias Genex.Chromosome
  

  defmodule Impl do
    use Genex

    def init do
      chromosomes =
        for _ <- 1..100 do
          genes = for _ <- 1..32, do: Enum.random(0..1)
          %Chromosome{genes: genes}
        end
      {:ok, %Population{chromosomes: chromosomes}}
    end

    def fitness_function(genes), do: Enum.sum(genes)

    def goal_test(population), do: population.max_fitness == 32
  end

  test "Implementation works" do
    Impl.run()
    flunk()
  end
end
