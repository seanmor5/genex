# Genealogy

Genex tracks the complex Genealogy of your algorithm's populations using [libgraph](https://hex.pm/packages/libgraph).

Genex implements the Genealogy tree as a directed graph with edges emanating from parents and incident on children.

The genealogy tree is available in the `history` field of a `Population` struct.

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

Please note: If your algorithm went on for thousands of generations, this export is going to take some time. Be patient!