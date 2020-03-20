alias Genex.Tools.Genotype
alias Genex.Tools.Crossover
alias Genex.Types.Chromosome
c = for _ <- 1..1000, do: %Chromosome{genes: Genotype.binary(100), size: 100}

normal =
  fn parents ->
    parents
    |> Enum.chunk_every(2, 2, :discard)
    |> Enum.map(fn f -> List.to_tuple(f) end)
    |> Enum.reduce(
        [],
        fn {p1, p2}, chd ->
          {c1, c2} = Crossover.single_point(p1, p2)
          [c1 | [c2 | chd]]
        end
      )
  end

flow =
  fn parents ->
    parents
    |> Stream.chunk_every(2)
    |> Flow.from_enumerable()
    |> Flow.partition()
    |> Flow.map(& List.to_tuple(&1))
    |> Flow.reduce(
        fn -> [] end,
        fn {p1, p2}, chd ->
          {c1, c2} = Crossover.single_point(p1, p2)
          [c1 | [c2 | chd]]
        end
      )
  end

Benchee.run(%{
  "flow" => fn -> flow.(c) end,
  "normal" => fn -> normal.(c) end
})