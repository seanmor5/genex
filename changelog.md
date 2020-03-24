# v0.1.2
- Bug fixes
- Added population statistics
- Crossover rate and mutation rate implemented as functions

# v0.1.4
- Bug fixes
- 3.51x Performance Improvement in single_point crossover
- 2.35x Performance Improvement in two_point crossover
- Addition of `benchmark/0` function to benchmark your algorithm

# v0.2.0
- Changed to `libgraph` for Genealogy tree.
- Added ability to export graph as DOT file.
- Removed `track_history?` flag.
- Added 17 Tests, Plus Doctests
- Fixed Variance bug
- Added methods WITHOUT random variables to verify validity of operator algorithms.

# v0.2.1
- Fixed Population Sorting Bug
- Added `minimize` flag for minimiIng fitness

# v1.0
- Restructuring from `Operators` to `Tools`.
- Addition of `cut_on_worst` crossover.
- Addition of `modified` crossover.
- Addition of `partialy_matched` crossover.
- Addition of `uniform_partialy_matched` crossover.
- Reworking of Configuration Process.
- Change `encode/0` to `genotype/0`.
- Addition of `collection/0` to `Chromosome`.
- Addition of `f` to `Chromosome`.
- Addition of `Genex.Evolution` for customizable evolutions.
- Creation of `Visualizer` behaviour for customizable visualizations.
- Addition of `interactive/3` for interactive GAs.
- Addition of penalty functions in Evaluation helper.
- Addition of indicators in Evaluation helper.
- Addition of GP benchmark functions.
- Addition of SOC benchmark functions.
- Addition of Hall of Fame for best tracking.
- Addition of Checkpointing to save and load evolutions.
