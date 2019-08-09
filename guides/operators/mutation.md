# Mutation

The purpose of this guide is to give an overview of the different type of mutation methods available in the Genex library.

Mutation is the process of altering some genes of a chromosome in order to introduce novelty into the population and ensure the algorithm doesn't converge too quickly. Mutation occurs according to some *mutation rate*. The "aggressiveness" of the mutation is controlled by a *radiation level*.

Genex's mutation algorithms accept a `Chromosome` and `Float` representing the *radiation level*. Genex reinserts the resulting mutated chromosomes back into the `chromosome` field of the Population struct.

*All algorithms tested on a 1,000,000-gene binary Chromosome with Benchee.*