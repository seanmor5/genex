defmodule Genex.Tools.Evaluation do
  def interactive(buffer, prompt, chromosome) do
    IO.inspect(chromosome)
    buffer.(prompt)
  end
end
