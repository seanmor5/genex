# Benchmarking

Genex offers the ability to benchmark your application through the use of `benchmark/0`. This function will use [Benchee](https://hex.pm/packages/benchee) to benchmark the runtime of each of the functions in your Genetic algorithm.

The current benchmark function simply runs each function using `Benchee.run/0` with default settings. The output will display in your console.

## Customization

There are many reasons you'd want to customize the benchmarking features of Genex. Perhaps you prefer another benchmarking tool or you want to only benchmark one function. Regardless, Genex makes this all possible.

You can customize the benchmarking features by overriding the `benchmark/0` function in your implementation module. You can then utilize your own benchmarking module or package, or change the settings of passed to Benchee.

```
defmodule MyGA do
    use Genex
    ...
    def benchmark do
        Benchee.run(%{
            "seed/0" => fn -> seed() end
        })
    end
end
```
