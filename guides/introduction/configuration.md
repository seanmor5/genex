# Configuration

Genex offers a number of configuration options. This is a comprehensive list.

To adjust radiation, crossover, and mutation rates, please see the [Customization]() guide.

Configuration options are provided after the `use Genex` line in your module.

```
defmodule MyGeneticAlgorithm do
    use Genex, crossover_type: :two_point, mutation_type: :invert
    ...
end
```

## Defaults
- `:population_size`: `100`
- `:crossover_type`: `:single_point`
- `:parent_selection`: `:natural`
- `:survivor_selection`: `:natural`
- `:mutation_type`: `:scramble`
- `:minimize`: `false`

## `crossover_type`

This option determines what kind of Crossover to use. For a detailed explanation of each Crossover method, see the [Crossover]() guide.

- `:single_point`
- `:two_point`
- `:uniform` *(requires `:uniform_crossover_rate` parameter set)*
- `:blend` *(requires `:alpha` parameter set)*
- `:simulated_binary` *(requires `:eta` parameter set)*
- `:messy_single_point`
- `:davis_order`

## `parent_selection` and `survivor_selection`

This option determines what kind of Selection to use. For a detailed explanation of each Selection method, see the [Selection]() guide.

- `:natural`
- `:random`
- `:worst`
- `:roulette`
- `:tournament` *(requires `:tournsize` parameter set)*
- `:stochastic`

## `mutation_type`

This option determines what kind of mutation to use. For a detailed explanation of each Mutation method, see the [Mutation]() guide.

- `:bit_flip`
- `:invert`
- `:scramble`
- `:gaussian`
- `:uniform_integer` *(requires `upper_bound` and `lower_bound` parameters set)*
- `:polynomial_bounded` *(requires `upper_bound`, `lower_bound` and `eta` parameters set)*
- `:none`

## `minimize`

This option tells Genex if you want to minimize or maximize fitness. When set to true, Genex will sort population fitness in ascending order. The "strongest" chromosome will be the one with the lowest fitness.