# Overview

Genex is a framework for writing Genetic Algorithms in Elixir. It provides methods and implementations for each step in a Genetic Algorithm.

## Genetic Algorithms

A Genetic Algorithm is a search-based optimization technique based on the principles of Natural Selection and Evolution. Solutions are encoded as Chromosomes or Individuals with individual characteristics known as "genes."

A Genetic Algorithm typically starts with some initial population. This initial population represents a set of solutions or "guesses" to the problem. It then repeatedly applies a cycle of evolutionary operators on the population - producing newer generations of the population until some termination criteria is met.

The basic outline is:
- Initialize Population
- Evaluate Population
- Apply Evolutionary Operators
- Repeat Until Termination Criteria

Genex follows the same basic outline and exposes several helpful methods and configuration options to make writing Genetic Algorithms trivial.

## Configuration

For information on how to configure Genex, please see the [configuration](https://hexdocs.pm/genex/introduction-configuration.html) guide.

## Customization

For information on how to customize Genex, please see the [customization](https://hexdocs.com/genex/introduction-customization.html) guide.

## Tutorials

- [Getting Started](https://hexdocs.pm/genex/tutorials-getting-started.html)

## Guides

To contribute a guide, please submit a pull request to the [genex](https://www.github.com/seanmor5/genex) project on GitHub.
