alias Genex.Chromosome
alias Genex.Operators.Crossover

g_100 = fn -> for _ <- 0..100, do: Enum.random(0..1) end
g_1000 = fn -> for _ <- 0..1_000, do: Enum.random(0..1) end
g_10000 = fn -> for _ <- 0..10_000, do: Enum.random(0..1) end
g_100000 = fn -> for _ <- 0..100_000, do: Enum.random(0..1) end
g_1000000 = fn -> for _ <- 0..1_000_000, do: Enum.random(0..1) end

{small1, small2} = {%Chromosome{genes: g_100.(), size: 100}, %Chromosome{genes: g_100.(), size: 100}}
{med1, med2} = {%Chromosome{genes: g_1000.(), size: 1000}, %Chromosome{genes: g_1000.(), size: 1000}}
{large1, large2} = {%Chromosome{genes: g_10000.(), size: 10000}, %Chromosome{genes: g_10000.(), size: 10000}}
{xlarge1, xlarge2} = {%Chromosome{genes: g_100000.(), size: 100000}, %Chromosome{genes: g_100000.(), size: 100000}}
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
    Benchee.Formatters.HTML,
    Benchee.Formatters.Console
  ],
  inputs: %{
    "100 Genes" => {small1, small2},
    "1000 Genes" => {med1, med2},
    "10000 Genes" => {large1, large2},
    "100000 Genes" => {xlarge1, xlarge2},
    "1000000 Genes" => {xxlarge1, xxlarge2}
  }
)