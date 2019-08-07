# Customization

Genex offers a number of operators and strategies for crafting Genetic Algorithms; however, there is often a need to have full control over the process.

This guide is an attempt to illustrate the flexibility and power offered by Genex.

## Configuration

Genex offers basic customization through a number of configuration options. Please see the [Configuration](https://hexdocs.pm/genex/introduction-configuration.html) guide for more information.

## Rates

In some cases, you will need to customize rates based on some population characteristics. Genex uses 3 rates throughout the GA life cycle: `crossover_rate`, `mutation_rate`, `radiation`.

### Crossover Rate

The crossover rate dictates the number of parents to breed during the crossover phase. This number `n` equals `Floor(Crossover Rate * Population Size)`.

The default crossover rate is `0.75`. This number means *75 percent* of the chromosomes in the population are selected for crossover during each generation.

The crossover rate can be changed by overriding the `crossover_rate/1` function in your implementation module. The function accepts a population struct and returns a float between 0 and 1.

```
defmodule MyGA do
    use Genex
    ...
    def crossover_rate(population), do: 0.60
end
```

### Mutation Rate

The mutation rate dictates the number of chromosomes mutated during each generation. This number `n` equals `Floor(Mutation Rate * Population Size)`.

The default mutation rate is `0.05`. This number means *5 percent* of the chromosomes in the population are mutated during each generation.

The mutation rate can be changed by overriding the `mutation_rate/1` function in your implementation module. The function accepts a population struct and returns a float between 0 and 1.

```
defmodule MyGA do
    use Genex
    ...
    def mutation_rate(population), do: 0.10
end
```

### Radiation

The radiation level dictates the "aggressiveness" of mutation. It is used to determine the number of genes in the chromosome that are altered when a chromosome is selected for mutation.

The default radiation level is `0.5`. This number means *50 percent* of the chromosome on average will be changed during mutation.

The radiation level can be changed by overriding the `radiation/1` function in your implementation module. The function accepts a population struct and returns a float between 0 and 1.

```
defmodule MyGA do
    use Genex
    ...
    def radiation(population), do: 0.25
end
```

## Seeding the Population

Constructing an initial population is the first step in the Genex life cycle. By default, Genex constructs a list of `n` chromosomes where `n` is equal to the `population_size` parameter. These chromosomes are constructed using the `encoding/0` function to generate a random set of genes for each.

Sometimes it's better to start with a known, pre-constructed population. This is entirely possible thanks to Genex's flexibility. This ability is especially useful when you have a population stored in a file or database.

You can start with a pre-constructed population by overriding the `seed/0` function in your implementation module. The function MUST return `{:ok, %Population{}}`. Please not that you also must initialize the `history` field of the population struct using `Genealogy.init()` as well as the `size` field of the population.

```
defmodule MyGA do
    use Genex
    ...
    def seed do
        history = Genex.Genealogy.init()
        chromosomes = read_from_somewhere()
        pop = %Population{chromosomes: chromosomes, history: history, size: length(chromosomes)}
        {:ok, pop}
    end
end
```

## Evaluating the Population

While most Genetic Algorithms evaluate chromosomes individually based on some predefined fitness function, you may find yourself needing to adjust the evaluation strategy of your algorithm.

To do so, override the `evaluation/1` function in your implementation module. For best results, ensure your function assigns: fitness to each of the chromosomes, a strongest chromosome, and the max fitness for the population. The function MUST return `{:ok, %Population{...}}`.

*Please also note that in order to avoid changing other fields in the population struct inadvertently, you must use Elixir's `Map` update syntax.*

```
defmodule MyGA do
    use Genex
    ...
    def evaluate(population) do
        chromosomes =
            population.chromosomes
            |> Enum.map(fn c -> some_custom_evaluation_technique(c) end)
        strongest = Enum.max_by(chromosomes, &Chromosome.get_fitness/1)
        pop = %Population{population | chromosomes: chromosomes, strongest: strongest, max_fitness: strongest.fitness}
        {:ok, pop}
    end
end
```

## Parent Selection

Genex comes with a number of prepackaged selection operators. However, there are some limitations to what the library provides. Genex offers the ability to implement a customized parent selection phase.

As of this version of Genex, there is no ability to grow or shrink the population by default. Customizing this function offers a way around this shortcoming.

In order to customize parent selection, override the `select_parents/1` function in your implementation module. Please note that your function MUST assign a `List` of `Tuple` of Chromosomes to the `parents` field of the returned population struct. The tuples MUST be 2-tuples and your function MUST return `{:ok, %Population{}}`.

*Please also note that in order to avoid changing other fields in the population struct inadvertently, you must use Elixir's `Map` update syntax.*

```
defmodule MyGA do
    use Genex
    ...
    def select_parents(population) do
        chromosomes = population.chromosomes
        n = floor(crossover_rate(population) * length(chromosomes))
        parents =
            chromosomes
            |> some_selection_method(n)
            |> Enum.chunk_every(2, 2, :discard)
            |> Enum.map(fn f -> List.to_tuple(f) end)
        pop = %Population{population | parents: parents}
        {:ok, pop}
    end
end
```

## Crossover

Genex comes with a number of prepackaged crossover operators. However, there are some limitations to what the library provides. Genex offers the ability to customize the crossover phase.

In order to customize crossover, override the `crossover/1` function in your implementation module. You can access the parents selected for crossover in the `parents` field of the population struct. Please note your function MUST assign a `List` of chromosomes to the `children` field of the population struct. The function MUST return `{:ok, %Population{}}`. Additionally, you may want to update the `history` by making calls to `Genealogy.update/4` after each new child is created.

*Please also note that in order to avoid changing other fields in the population struct inadvertently, you must use Elixir's `Map` update syntax.*

```
defmodule MyGA do
    use Genex
    ...
    def crossover(population) do
        children =
            population.parents
            |> Enum.map(
                fn {p1, p2} ->
                    {c1, c2} = some_crossover(p1, p2) end)
                    Genealogy.update(population.history, c1, p1, p2)
                    Genealogy.update(population.history, c2, p1, p2)
                    [c1, c2]
                end
            |> List.flatten()
        pop = %Population{population | children: children}
        {:ok, pop}
    end
end
```

## Mutation

Genex comes with a number of mutation oeprators. However, there are some limitations to what the library provides. Genex offers the ability to customize the mutation phase.

In order to customize mutation, override the `mutate/1` function in your implementation module. You should access and modify the `chromosomes` field of the population struct. The function accepts a population struct. Your function MUST return `{:ok, %Population{}}`.

*Please also note that in order to avoid changing other fields in the population struct inadvertently, you must use Elixir's `Map` update syntax.

```
defmodule MyGA do
    use Genex
    ...
    def mutate(population) do
        chromosomes =
            population.chromosomes
            |> Enum.map(some_mutation_function(mutation_rate()))
        pop = %Population{population | chromosomes: chromosomes}
        {:ok, pop}
    end
end
```

## Survivor Selection

Genex supports customization of the "reinsertion" phase of Genetic algorithms using it's `select_survivors/1` method. Later versions of Genex will support defining "kill criteria" and other constraints; however, this method will allow you to customize how populations grow and decay over time.

In order to customize survivor selection, override the `select_survivors/1` method in your implementation module. This function accepts a population struct. To ensure smooth running of the rest of the algorithm, this function should populate the `survivors` field of the population struct it returns. This function MUST return `{:ok, %Population{}}`.

```
defmodule MyGA do
    use Genex
    ...
    def select_survivors(population) do
        survivors =
            population.chromosomes
            |> Enum.filter(fn c -> c.age < 5 end)
        pop = %Population{population | survivors: survivors}
        {:ok, pop}
    end
end
```
