defmodule ConfigTest do
  use ExUnit.Case
  import Genex.Config

  describe "config module" do
    test "use_crossover/3" do
      opts = use_crossover([], :blend, alpha: 0.5)
      assert Keyword.get(opts, :crossover_type) == :blend
      assert Keyword.get(opts, :blend_alpha) == 0.5

      assert_raise RuntimeError, "You must specify :rate when using uniform crossover!", fn ->
        use_crossover([], :uniform)
      end

      assert_raise RuntimeError, "You must specify :alpha when using blend crossover!", fn ->
        use_crossover([], :blend)
      end

      assert_raise RuntimeError,
                   "You must specify :eta when using simulated binary crossover!",
                   fn -> use_crossover([], :simulated_binary) end
    end

    test "use_mutation/3" do
      opts = use_mutation([], :uniform_integer, min: 0, max: 10)
      assert Keyword.get(opts, :mutation_type) == :uniform_integer
      assert Keyword.get(opts, :uniform_integer_min) == 0
      assert Keyword.get(opts, :uniform_integer_max) == 10

      assert_raise RuntimeError,
                   "You must specify :min when using uniform integer mutation!",
                   fn -> use_mutation([], :uniform_integer) end

      assert_raise RuntimeError,
                   "You must specify :max when using uniform integer mutation!",
                   fn -> use_mutation([], :uniform_integer, min: 0) end

      assert_raise RuntimeError,
                   "You must specify :min when using polynomial bounded mutation!",
                   fn -> use_mutation([], :polynomial_bounded) end

      assert_raise RuntimeError,
                   "You must specify :max when using polynomial bounded mutation!",
                   fn -> use_mutation([], :polynomial_bounded, min: 0) end

      assert_raise RuntimeError,
                   "You must specify :eta when using polynomial bounded mutation!",
                   fn -> use_mutation([], :polynomial_bounded, min: 0, max: 10) end
    end

    test "use_selection/3" do
      opts = use_selection([], :tournament, tournsize: 20)
      assert Keyword.get(opts, :selection_type) == :tournament
      assert Keyword.get(opts, :tournsize) == 20

      assert_raise RuntimeError,
                   "You must specify :tournsize when using tournament selection!",
                   fn -> use_selection([], :tournament) end
    end

    test "with_crossover_rate/2" do
      opts = with_crossover_rate([], 0.5)
      assert Keyword.get(opts, :crossover_rate) == 0.5
    end

    test "with_mutation_rate/2" do
      opts = with_mutation_rate([], 0.05)
      assert Keyword.get(opts, :mutation_rate) == 0.05
    end

    test "with_radiation/2" do
      opts = with_radiation([], 0.05)
      assert Keyword.get(opts, :radiation) == 0.05
    end

    test "with_population/2" do
      opts = with_population([], size: 50)
      assert Keyword.get(opts, :population_size) == 50
    end
  end
end
