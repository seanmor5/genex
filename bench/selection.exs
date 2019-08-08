alias Genex.Chromosome
alias Genex.Operators.Selection

g_1000 = fn -> for _ <- 0..1_000, do: Enum.random(0..1) end
chromosomes =
  for _ <- 0..10_000 do
    genes = g_1000.()
    fitness = Enum.sum(genes)
    %Chromosome{genes: genes, fitness: fitness, size: 1_000}
  end

chromosomes =
  chromosomes
  |> Enum.sort_by(&Chromosome.get_fitness/1)
  |> Enum.reverse()

Benchee.run(%{
    "natural" => fn {c, n} -> Selection.natural(c, n) end,
    "random" => fn {c, n} -> Selection.random(c, n) end,
    "worst" => fn {c, n} -> Selection.worst(c, n) end,
    "tournament" => fn {c, n} -> Selection.tournament(c, n, 100) end,
    "roulette" => fn {c, n} -> Selection.roulette(c, n) end,
    "stochastic universal sampling" => fn {c, n} -> Selection.stochastic_universal_sampling(c, n) end
  },
  formatters: [
    {Benchee.Formatters.Markdown, file: "selection.md"},
    Benchee.Formatters.Console
  ],
  inputs: %{
    "10_000 Chromosomes with 1_000 Genes" => {chromosomes, 5_000}
    }
)