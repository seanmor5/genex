defmodule Genex.Types.Community do
  alias Genex.Types.{Chromosome, Population}
  @moduledoc false
  @type t :: %__MODULE__{
          populations: Enum.t(Population.t()),
          generation: integer(),
          size: integer(),
          max_fitness: number(),
          strongest: Chromosome.t(),
          history: :digraph.graph(),
          statistics: Keyword.t()
        }

  @enforce_keys :populations
  defstruct [
    :populations,
    generation: 0,
    size: 0,
    max_fitness: 0,
    strongest: nil,
    history: nil,
    statistics: nil
  ]
end
