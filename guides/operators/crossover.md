# Crossover

The purpose of this guide is to give an overview of the different type of crossover methods available in the Genex library.

Crossover or Recombination is the process of creating new solutions from selected old solutions. The idea is to eliminate weak solutions in favor of stronger ones in order to converge on an optimal value.

Genex's crossover algorithms accept `List` of `Tuple` where each element in the `Tuple` is a parent. Genex stores the resulting children (2 per pair of parents) in the `children` field of the Population struct.

*All algorithms tested on 2 1,000,000-gene binary Chromosomes with Benchee.*

## Single Point

- **Additional Options**:
- **Run Time**: 85.10 ms
- **Memory Usage**: 31.36 MB

Single Point Crossover is the simplest crossover algorithm and the default algorithm used by Genex. Genex uses Erlang's `:rand` package to generate a uniform random number between 0 and n-1, where n is the size of the chromosome. This number is the *crossover point*.

Genex then splits each parent Chromosome at the *crossover point* and swaps the slices to create 2 new Chromosomes.

The pseudocode below illustrates this process with an assumed crossover point of 3.

```
parent a := [1, 2, 3, 4, 5]
parent b := [6, 7, 8, 9, 10]

crossover point := uniform random number between 0 and 4.

child a := parent b[..3] + parent a[3..]
child b := parent a[..3] + parent b[3..]

Results:
child a := [1, 2, 3, 9, 10]
child b := [6, 7, 8, 4, 5]
```

For most practical applications of Genetic Algorithms, Single Point Crossover is effectively useless. You should only use this for testing and learning purposes.

## Two Point

- **Additional Options**:
- **Run Time**: 111.76 ms
- **Memory Usage**: 52.89 MB

Two Point Crossover is very similar to Single Point Crossover. The name implies exactly what it does - executes a crossover with two points. Genex uses Erlang's `:rand` package to generate 2 random numbers between 0 and n-1 where n is the size of the chromosome. These 2 numbers are the *crossover points*.

Genex then splits each parent chromosome into 3 slices: a head, a middle, and a tail. The middle slices are then swapped between the 2 chromosomes, creating 2 child chromosomes.

The difference between Two Point and Single Point Crossover is that Two Point Crossover can crossover slices in the MIDDLE of the chromosome.

The pseudocode below illustrates this process with assumed crossover points of 2 and 4.

```
parent a := [1, 2, 3, 4, 5]
parent b := [6, 7, 8, 9, 10]

point 1 := uniform random number between 0 and 4
point 2 := uniform random number between 0 and 4

child a := parent a[..2] + parent b[2..4] + parent a[4..]
child b := parent b[..2] + parent a[2..4] + parent b[4..]

Results:
child a := [1, 2, 8, 9, 5]
child b := [6, 7, 3, 4, 10]
```

Two Point Crossover, while slightly more useful than Single Point Crossover, likely will not be very effective in practical applications.

## Uniform Crossover

- **Additional Options**: `:uniform_crossover_rate`
- **Run Time**: 914.47 ms
- **Memory Usage**: 247.95 MB

Uniform Crossover is slightly more complex than our two previous crossover algorithms. It offers more flexibility and control over the crossover process and allows for the creation of more diverse chromosomes than Single and Two Point Crossover.

In Uniform Crossover, the parent genes are zipped into pairs. We iterate through these pairs 1-by-1. Starting from the first pair, Genex generates random uniform numbers between 0 and 1 using Erlang's `:rand` package. If the number is less than the `:uniform_crossover_rate`, the genes are swapped. If not, the genes stay in place.

Uniform Crossover creates 2 new Chromosomes with genes swapped in random places from the parent Chromosomes. A higher `:uniform_crossover_rate` will lead to more genes being swapped. The opposite is true for a lower rate.

The pseudocode below illustrates this process with a `:uniform_crossover_rate` of 0.5.

```
parent a := [1, 2, 3, 4, 5]
parent b := [6, 7, 8, 9, 10]

gene pairs := zip(parent a, parent b)

for {x, y} in gene pairs:
    if(uniform random number < 0.5):
        swap(x, y)

{child a, child b} := unzip(gene pairs)

Results:
child a := [1, 7, 3, 9, 5]
child b := [6, 2, 8, 4, 10]
```

Uniform Crossover offers much more flexibility than Single and Two Point Crossover. This is likely the preferred method when dealing with Binary Chromosomes.

## Blend

- **Additional Options**: `:alpha`
- **Run Time**: 1578.04 ms
- **Memory Usage**: 259.40 MB

Blend crossover blends the genes of two parent chromosomes according to the formula:

```
C1 := ((1 - γ) * x) + (γ * y)
C2 := (γ * x) + ((1 - γ) * y)
γ := ((1 + (2 * α)) * μ) - α
α := between 0 and 1
μ := uniform random number between 0 and 1
x := Parent A gene
y := Parent B gene
```

Blend Crossover uses alpha as well as some random numbers to dictate the amount of each of the respective parent's genes to blend into the offspring. Blend crossover is considerably slower than any of the aforementioned crossover strategies; however, it can be very effective with certain genotypes.

## Davis Order

- **Additional Options**:
- **Run Time**: 252.50 ms
- **Memory Usage**: 18.09 MB

Davis Order Crossover or Order 1 Crossover deals with permutations. That is, when solutions are encoded as permutation where order determines the fitness of the chromosome, Davis Order Crossover is extremely useful.

The algorithm is as follows:

    1) Pick a random slice of genes from Parent A
    2) Drop the slice in the same spot in Child 1 and mark out corresponding genes in Parent B.
    3) Starting from the RIGHT after the corresponding genes in Parent B, insert remaining genes from Parent B into Child 1, wrapping around the chromosome if need be.
    4) Repeat for Child 2 starting with Parent B.

Davis Order is an exceptionally fast crossover method and is useful when solutions are encoded as permutations.

## Messy Single Point Crossover

- **Additional Options**:
- **Run Time**: 95.24 ms
- **Memory Usage**: 18.09 MB

Messy Single Point Crossover is essentially the same algorithm as Single Point Crossover; however, it disregards the size of the chromosome and selects TWO crossover points - one for each parent.

Messy Single Point Crossover will arbitrarily grow or shrink chromosomes. Crossover Points are selected at random for each parent. The chromosomes are then split at their respective crossover points and recombined to make two offspring.

The pseudocode below shows this process:

```
parent a := [1, 2, 3, 4, 5]
parent b := [6, 7, 8, 9, 10]

point 1 := uniform random number between 0 and 4
point 2 := uniform random number between 0 and 4

child a := parent b[..point2] + parent a[point1..]
child b := parent a[..point1] + parent b[..point2]

Results:
child a := [6, 7, 8, 2, 3, 4, 5]
child b := [1, 9, 10]
```

Messy Single Point Crossover is extremely simple and can be useful in cases when you don't care about the length of your chromosomes. Beware that it is easy to end up with chromosomes of 0 length in this algorithm.

## Simulated Binary

- **Additional Options**: `:eta`
- **Run Time**: 1601.81 ms
- **Memory Usage**: 389.11 MB

Simulated Binary Crossover combines the genes of two parents according to the following formula:

```
C1 := 0.5 * ((1 + β) * x + (1 - β) * y)
C2 := 0.5 * ((1 - β) * x + (1 + β) * y)
β := (2 * p)^(1 / (η + 1)) OR
β := (1 / (2 * (1 - p)))^(1 / (η + 1))
p := uniform random number
η := between 0 and 1
```

It is used in the NSGA-II algorithm.