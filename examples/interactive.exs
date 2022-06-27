defmodule Interactive do
  use Genex

  def genotype, do: Genotype.binary(10)

  def fitness_function(chromosome), do: Evaluation.interactive(&read/1, "\nRate this\n", chromosome)

  def terminate?(population), do: population.max_fitness >= 10

  defp read(prompt) do
    prompt
    |> IO.gets()
    |> String.trim_trailing()
    |> String.to_integer()
  end
end

solution = Interactive.run(
  population_size: 5
)

IO.inspect(solution.strongest.genes)
