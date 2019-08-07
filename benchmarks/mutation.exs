alias Genex.Chromosome
alias Genex.Operators.Mutation

g_100 = fn -> for _ <- 0..100, do: Enum.random(0..1) end
g_1000 = fn -> for _ <- 0..1_000, do: Enum.random(0..1) end
g_10000 = fn -> for _ <- 0..10_000, do: Enum.random(0..1) end
g_100000 = fn -> for _ <- 0..100_000, do: Enum.random(0..1) end
g_1000000 = fn -> for _ <- 0..1_000_000, do: Enum.random(0..1) end

small = %Chromosome{genes: g_100.(), size: 100}
med = %Chromosome{genes: g_1000.(), size: 1009}
large = %Chromosome{genes: g_10000.(), size: 10000}
xlarge = %Chromosome{genes: g_100000.(), size: 100000}
xxlarge = %Chromosome{genes: g_1000000.(), size: 1000000}

radiation = 0.5
Benchee.run(%{
  "bit_flip" => fn c -> Mutation.bit_flip(c, radiation) end,
  "scramble" => fn c -> Mutation.scramble(c, radiation) end,
  "invert" => fn c -> Mutation.invert(c, radiation) end,
  "gaussian" => fn c -> Mutation.gaussian(c, radiation) end,
  "uniform_integer" => fn c -> Mutation.uniform_integer(c, radiation, 1, 10) end
  # "polynomial_bounded" => fn c -> Mutation.polynomial_bounded(c, 0.5, 1, 10) end
  },
  formatters: [
    Benchee.Formatters.HTML,
    Benchee.Formatters.Console
  ],
  inputs: %{
    "100 Genes" => small,
    "1000 Genes" => med,
    "10000 Genes" => large,
    "100000 Genes" => xlarge,
    "1000000 Genes" => xxlarge
    }
  )