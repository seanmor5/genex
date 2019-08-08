# Benchmarking

Genex offers benchmarking capabilities to benchmark your algorithm. You can benchmark each step of your algorithm by calling the `benchmark/0` function after you have defined an implementation module.

Please note, this option will NOT work if `track_history?` is set to `true`. This has something to do with the fact that Erlang's `digraph` can only be written to by the process that owns it and `Benchee` runs in it's own process. Please bear with us as we attempt to fix this issue.