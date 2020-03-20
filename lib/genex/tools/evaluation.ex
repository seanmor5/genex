defmodule Genex.Tools.Evaluation do

  def interactive(buffer, prompt), do: &buffer.(prompt)

  def eval(c), do: c.fitness
end
