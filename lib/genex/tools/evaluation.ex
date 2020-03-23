defmodule Genex.Tools.Evaluation do
  def interactive(buffer, prompt), do: buffer.(prompt)
end
