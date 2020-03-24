defmodule Genex.Support.Genealogy do
  alias Graph.Serializers.DOT
  @moduledoc """
  Implementation of a genealogy tree.

  We use the Genealogy tree to model the history of the population from it's initialization to the end of the algorithm. The tree itself is a directed `Graph` implemented using [libgraph](ttps://www.github.com/x/libgraph). Genealogy is tracked in a population struct, so you can access the genealogy anytime through the current population. Any function in the libgraph library will work on a genealogy

  An edge emanates from parent and is incident on child. Mutants are considered new chromosomes, so their lineage starts with a single parent.

  To produce visualizations of the Genealogy of an evolution, you'll have to export the tree to a DOT file and use a third-party visualization tool.
  """

  @doc """
  Creates a new Genealogy Tree.

  Returns `Graph`.
  """
  def new, do: Graph.new(type: :directed)

  @doc """
  Updates a Genealogy Tree with several vertices or one vertex.

  Returns `Graph`.

  # Parameters
    - `genealogy`: Reference to the Genealogy Tree.
    - `chromosomes`: `List` of `%Chromosome{}` or `%Chromosome{}`.
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
      - `genealogy`: Reference to a Genealogy Tree.
      - `child`: Child `%Chromosome{}`.
      - `parent`: Parent `%Chromosome{}`.
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
    - `genealogy`: Reference to a Genealogy Tree.
    - `child`: Child `%Chromosome{}`.
    - `parent_a`: Parent A `%Chromosome{}`.
    - `parent_b`: Parent B `%Chromosome{}`.
  """
  def update(genealogy, child, parent_a, parent_b) do
    genealogy
    |> Graph.add_vertex(child)
    |> Graph.add_edge(parent_a, child)
    |> Graph.add_edge(parent_b, child)
  end

  @doc """
  Exports the genealogy tree.

  Returns `{:ok, String}`.

  # Parameters

    - `genealogy`: Reference to a Genealogy Tree.
  """
  def export(genealogy) do
    genealogy
    |> DOT.serialize()
  end
end
