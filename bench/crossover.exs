alias Genex.Chromosome
alias Genex.Operators.Crossover

g_1000000 = fn -> for _ <- 0..1_000_000, do: Enum.random(0..1) end

{xxlarge1, xxlarge2} = {%Chromosome{genes: g_1000000.(), size: 1000000}, %Chromosome{genes: g_1000000.(), size: 1000000}}

Benchee.run(%{
  "single_point" => fn {p1, p2} -> Crossover.single_point(p1, p2) end,
  "two_point" => fn {p1, p2} -> Crossover.two_point(p1, p2) end,
  "uniform" => fn {p1, p2} -> Crossover.uniform(p1, p2, 0.5) end,
  "blend" => fn {p1, p2} -> Crossover.blend(p1, p2, 0.5) end,
  "simulated_binary" => fn {p1, p2} -> Crossover.simulated_binary(p1, p2, 0.5) end,
  "messy_single_point" => fn {p1, p2} -> Crossover.messy_single_point(p1, p2) end,
  "davis_order" => fn {p1, p2} -> Crossover.davis_order(p1, p2) end
},
  formatters: [
    Benchee.Formatters.Console
  ],
  inputs: %{
    "1_000_000 Genes" => {xxlarge1, xxlarge2}
  }
)