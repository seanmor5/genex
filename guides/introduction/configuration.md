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
- `track_history?`: `false`

## `crossover_type`

- `:single_point`
- `:two_point`
- `:uniform` *(requires `:uniform_crossover_rate` parameter set)*
- `:blend` *(requires `:alpha` parameter set)*
- `:simulated_binary` *(requires `:eta` parameter set)*
- `:messy_single_point`
- `:davis_order`

## `parent_selection` and `survivor_selection`

- `:natural`
- `:random`
- `:worst`
- `:roulette`
- `:tournament` *(requires `:tournsize` parameter set)*
- `:stochastic`

## `mutation_type`

- `:bit_flip`
- `:invert`
- `:scramble`
- `:gaussian`
- `:uniform_integer` *(requires `upper_bound` and `lower_bound` parameters set)*
- `:polynomial_bounded` *(requires `upper_bound`, `lower_bound` and `eta` parameters set)*
- `:none`