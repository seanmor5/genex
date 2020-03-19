defmodule Genex.Support.Genealogy do
  @moduledoc """
  Implementation of a genealogy tree.

  We use the Genealogy tree to model the history of the population from it's initialization to the end of the algorithm. The tree itself is an erlang digraph. An edge emanates from parent and is incident on child.
  """

  @doc """
  Initializes a new Genealogy Tree.

  Returns `Graph`.
  """
  def init, do: Graph.new(type: :directed)

  @doc """
  Updates a Genealogy Tree with just a vertex.

  Returns `Graph`.

  # Parameters
    - `genealogy` - Reference to a Genealogy Tree.
    - `chromosome` - Chromosome to add to Genealogy.
  """
  def update(genealogy, chromosomes) when is_list(chromosomes) do
    genealogy
    |> Graph.add_vertices(chromosomes)
  end

  def update(genealogy, chromosome) do
    genealogy
    |> Graph.add_vertex(chromosome)
  end

  @doc """
    Updates a Genealogy Tree with a vertex and it's parents.

    Returns `Graph`.

    # Parameters
      - `genealogy` - Reference to a Genealogy Tree.
      - `child` - Chromosome to add.
      - `parent` - Child's parent.
  """
  def update(genealogy, child, parent) do
    genealogy
    |> Graph.add_vertex(child)
    |> Graph.add_edge(parent, child)
  end

  @doc """
  Updates a Genealogy Tree with a vertex and it's parents.

  Returns `Graph`.

  # Parameters
    - `genealogy` - Reference to a Genealogy Tree.
    - `child` - Chromosome to add.
    - `parent_a` - Child's parent.
    - `parent_b` - Child's parent.
  """
  def update(genealogy, child, parent_a, parent_b) do
    genealogy
    |> Graph.add_vertex(child)
    |> Graph.add_edge(parent_a, child)
    |> Graph.add_edge(parent_b, child)
  end

  @doc """
  Exports the genealogy tree.
  """
  def export(genealogy) do
    genealogy
    |> Graph.Serializers.DOT.serialize()
  end
end
