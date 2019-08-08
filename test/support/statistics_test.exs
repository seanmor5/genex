defmodule StatisticsTest do
  use ExUnit.Case

  import Genex.Support.Statistics

  @list [0, 1, 1, 1]
  describe "statistics" do
    test "mean/1" do
      assert mean(@list) == 0.75
    end

    test "variance/1" do
      assert variance(@list) == 0.25
    end

    test "stdev/1" do
      assert stdev(@list) == 0.5
    end

    test "min/1" do
      assert min(@list) == 0
    end

    test "max/1" do
      assert max(@list) == 1
    end
  end
end