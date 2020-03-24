defmodule Genex.Tools.Evaluation do
  @moduledoc """
  Evaluation convenience functions.
  """

  @doc """
  Interactive fitness for interactive genetic algorithms.

  Requires an input buffer, a prompt, and a chromosome.

  Returns `Integer`.

  # Parameters

    - `buffer`: Input buffer.
    - `prompt`: Message prompt.
    - `Chromosome`: `%Chromosome{}`.
  """
  def interactive(buffer, prompt, chromosome) do
    IO.inspect(chromosome)
    buffer.(prompt)
  end
end
