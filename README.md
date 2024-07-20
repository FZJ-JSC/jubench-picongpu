# JUPITER Benchmark Suite: PIConGPU

[![DOI](https://zenodo.org/badge/831436727.svg)](https://zenodo.org/badge/latestdoi/831436727) [![Static Badge](https://img.shields.io/badge/DOI%20(Suite)-10.5281%2Fzenodo.12737073-blue)](https://zenodo.org/badge/latestdoi/764615316)

This benchmark is part of the [JUPITER Benchmark Suite](https://github.com/FZJ-JSC/jubench). See the repository of the suite for some general remarks.

This repository contains the PIConGPU benchmark. [`DESCRIPTION.md`](DESCRIPTION.md) contains details for compilation, execution, and evaluation.

The source code of PIConGPU is included in the `./src/` subdirectory as a submodule from the upstream PIConGPU repository at [github.com/ComputationalRadiationPhysics/picongpu](https://github.com/ComputationalRadiationPhysics/picongpu).

## Quickstart

```
# Obtain the benchmark if not present
git clone --recursive $REPO
# Run the benchmark using JUBE
jube run benchmark/jube/benchmark.xml -t {baseline,high_large,high_medium,high_small}

```
This will obtain the required sources from GitHub, perform a full build and run the benchmark.
After the benchmark runs are complete, one can analyse the benchmark runs and generate a results table by executing the following,

```
jube analyse benchmark/jube/run --id XYZ
jube result benchmark/jube/run --id XYZ

```

### Results

Example results are given in the following

#### Baseline

The baseline test uses 8 nodes on the JUWELS booster with 4 GPUs per node and uses a grid size `-g 1024 1024 512`. Following is the example output on the JUWELS booster using "jube run benchmark.xml -t baseline"

|version      |system       |nnodes  |nconfig         |gridconfig      |simtime|
|-------------|-------------|--------|----------------|----------------|-------|
|26cbd45b2c9  |juwelsbooster|8       |-d 4 4 2        |-g 1024 1024 512|466.155|

#### Large Scale

This is the second mode of the benchmark, designed to run at a scale of around
1000 PFLOP/s. Below is the example out sourced from JUWELS Booster and its
validation data.

|version    |system       |nnodes|nconfig    |gridconfig       |simtime|
|-----------|-------------|------|-----------|-----------------|-------|
|26cbd45b2c9|juwelsbooster|256   |-d 16 8 8  |-g 4096 2048 2048|466.567|
|26cbd45b2c9|juwelsbooster|384   |-d 16 16 6 |-g 4096 3072 2048|470.815|
|26cbd45b2c9|juwelsbooster|512   |-d 16 16 8 |-g 4096 4096 2048|466.618|
|26cbd45b2c9|juwelsbooster|640   |-d 16 16 10|-g 4096 4096 2560|466.785|



