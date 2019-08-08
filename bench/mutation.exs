alias Genex.Chromosome
alias Genex.Operators.Mutation

g_1000000 = fn -> for _ <- 0..1_000_000, do: Enum.random(0..1) end

xxlarge = %Chromosome{genes: g_1000000.(), size: 1000000}

radiation = 0.5
Benchee.run(%{
  "bit_flip" => fn c -> Mutation.bit_flip(c, radiation) end,
  "scramble" => fn c -> Mutation.scramble(c, radiation) end,
  "invert" => fn c -> Mutation.invert(c, radiation) end,
  "gaussian" => fn c -> Mutation.gaussian(c, radiation) end,
  "uniform_integer" => fn c -> Mutation.uniform_integer(c, radiation, 1, 10) end
  },
  formatters: [
    Benchee.Formatters.Console
  ],
  inputs: %{
    "1_000_000 Genes" => xxlarge
    }
  )