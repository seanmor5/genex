# Statistics

Genex offers the ability to track statistics about a population. It comes with a basic, default statistics package; however, you have the ability to extend it with your own 3rd party functions.

## Defaults

By default Genex will collect the following information on a population during each generation:

- mean via `Statistics.mean/1`
- variance via `Statistics.variance/1`
- max via `Statistics.max/1`
- min via `Statistics.min/1`
- stdev via `Statistics.stdev/1`

## Customization

You can customize the statistics collected on the population with your own methods by overriding the `statistics/0` function in your implementation module. Your function must return a `Keyword` list where the key represents the statistic and the value is a reference to the function you want to run.

As of this version of Genex, your functions MUST accept a `List` of numbers.

```
def MyGA do
    use Genex
    ...
    def statistics do
        [
            mean: &MyPackage.my_mean/1,
            stdev: &Statistics.stdev/1
        ]
    end
end
```

## Logging and Exporting

The ability to log and export statistics across generations is coming in future versions of Genex. Stay tuned!