defmodule GenealogyTest do
  use ExUnit.Case

  import Genex.Support.Genealogy

  describe "Genealogy" do
    test "init/0" do
      assert %Graph{} = init()
    end

    test "update/2" do
      graph = init()
      assert %Graph{} = update(graph, :a)
    end

    test "export/1" do
      graph = init()
      graph = update(graph, :a)
      assert {:ok, str} = export(graph)
    end
  end
end
