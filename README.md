# tpt-bench

Simple benchmark suite for TPT, mainly centered around frame time measurement. Just run
```
run.sh
```
to get a messy log of all benchmarks run. To hide TPT's window, use
```
SDL_VIDEODRIVER=dummy run.sh
```
though this may affect benchmark results.

TODO:

- [ ] save results somewhere
- [ ] make sure `SDL_VIDEODRIVER=dummy` runs are annotated as such
