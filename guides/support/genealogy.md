# Genealogy

Genex tracks the complex Genealogy of your algorithm's populations using [libgraph](https://hex.pm/packages/libgraph).

The Genealogy tree is implemented as a directed graph with edges emanating from parents and incident on children.

The Genealogy tree is available in the `history` field of a `Population` struct. Take a look at libgraph's API for a number of useful functions for operating on graph structure.

## Exporting and Visualization

Genex offers the ability to export the Genealogy tree for analysis later on. So far, exports can only be done to DOT files. Here's how:

Assuming you have an implementation module defined, run your algorithm:
```
soln = MyGA.run()
```

Now, call `Genex.Support.Genealogy.export/1` to export your genealogy tree.
```
{:ok, binary} = Genex.Support.Genealogy.export(soln.history)
```

Pay close attention to the `export/1` signature. It returns `{:ok, binary}` where `binary` is the raw text of your generated file. You can then use Elixir's built-in File IO to create your DOT file.

You can use software like [Graphviz](https://www.graphviz.org/) to view your Genealogy tree.

Please note: If your algorithm went on for thousands of generations, this export is going to take some time. Be patient!