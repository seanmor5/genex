defmodule Genex.Support.Genealogy do
  @moduledoc """
  Implementation of a genealogy tree.

  We use the Genealogy tree to model the history of the population from it's initialization to the end of the algorithm. The tree itself is an erlang digraph. An edge emanates from parent and is incident on child.
  """

  @doc """
  Initializes a new Genealogy Tree.

  Returns `Graph`.
  """
  def init, do: :digraph.new()

  @doc """
  Updates a Genealogy Tree with just a vertex.

  Returns `Graph`.

  # Parameters
    - `genealogy` - Reference to a Genealogy Tree.
    - `chromosome` - Chromosome to add to Genealogy.
  """
  def update(genealogy, chromosome) do
    v = :digraph.add_vertex(genealogy, chromosome)
    genealogy
  end

  @doc """
  Updates a Genealogy Tree with a vertex and it's corresponding parents.

  Returns `Graph`.

  # Parameters
    - `genealogy` - Reference to a Genealogy Tree.
    - `chromosome` - Chromosome to add to genealogy.
    - `parent_a` - Parent Chromosome.
    - `parent_b` - Parent Chromosome.
  """
  def update(genealogy, chromosome, parent_a, parent_b) do
    v = :digraph.add_vertex(genealogy, chromosome)
    e1 = :digraph.add_edge(genealogy, parent_a, chromosome)
    e2 = :digraph.add_edge(genealogy, parent_b, chromosome)
    genealogy
  end
end