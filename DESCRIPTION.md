# PIConGPU

PIConGPU is a fully-relativistic, manycore, 3D3V and 2D3V particle-in-cell
code. It describes the dynamics of a plasma by computing the motion of
electrons and ions in the plasma based on the Vlasov-Maxwell system of equations.
The source code for the software can be found on
[GitHub](https://github.com/ComputationalRadiationPhysics/picongpu) while the
code itself is described 
[in a paper](http://doi.acm.org/10.1145/2503210.2504564).

The code is written in C++, and uses various libraries and technologies like
[alpaka](https://github.com/alpaka-group/alpaka),
[cupla](https://github.com/alpaka-group/cupla), MPI, OpenMP and CUDA to achieve
the desired level of scalability. The software has been shown to scale
successfully to 27600 GPUs as described
[here](https://indico.desy.de/event/28053/contributions/97845/attachments/63888/78225/2021-02-03%20MT%20meeting%20DMA%20Exascale%20simulations%20with%20PIConGPU.pdf).

The specific benchmark setup in this repository is the `KHI_growthrate` benchmark, which is based on the Kelvin Helmholtz instability. The performance of the benchmark is measured in terms of the runtime of the simulation. The runtime of the simulation is supposed to scale linearly with the number of GPUs.

## Source

Archive Name: `picongpu-bench.tar.gz`

The file holds instructions to run the benchmark, according to the JUBE scripts, and
configuration files to run PIConGPU. Sources for PIConGPU are distributed in the `src` directory, based on [its GitHub repository](https://github.com/ComputationalRadiationPhysics/picongpu.git).

The source code of PIConGPU used is identified by hash `49a9e226`.

## Building

_While we recommend using JUBE especially for the sophisticated benchmark setup of PIConGPU, we also give instructions to conduct the benchmark without JUBE._

The PIConGPU benchmark has the following dependencies:

1. GCC Compiler
2. CUDA
3. CUDA-Aware MPI Implementation
4. CMake (>3.20)
5. Python
6. Boost

PIConGPU provides a build script which uses CMake to compile the library. The KHI test-case of the benchmark needs to be given to the build script.

```
cd ~/workspace/
picongpu/bin/pic-create picongpu/share/picongpu/tests/KHI_growthRate khi_test
cd khi_test
../picongpu/bin/pic-build
```

### JUBE

In case JUBE is used, PIConGPU and the KHI benchmark case are built automatically in the process -- see below.

## Execution

### Variants

The PIConGPU benchmark is to be executed in two variants.

1. **TCO Baseline**: This variant is the benchmark for the TCO evaluation. The benchmark takes about 466 s.
2. **High-Scaling**: This variant uses a larger grid size to explore scalability between a 50 PFLOP/s sub-partition of JUWELS Booster and a 1000 PFLOP/s sub-partition of the Exascale system (with 20x the performance). Three sub-variants are prepared, each utilizing different amounts of A100 GPU memory: _large_ (100% memory / 40 GB, minus a margin), _medium_ (75% / 30 GB, minus margin), and _small_ (50% / 20 GB, minus margin).

### Overview

The executable of PIConGPU is called `picongpu` and is located in the `bin` directory. Various parameters are to be given to configure the execution for the KHI benchmark.

In a PIC code, the simulation box is divided into cartesian grids. This 3D grid is further decomposed into small domains where each domain is handled by a single GPU. The important parameters determining the 3D grid configuration and the domain decomposition are the following:

* `-g`, a triplet of integers determining the number of grid points along x, y, and z directions of the simulation box. The values are fixed in this benchmark for the respective sub-benchmark cases (TCO Baseline, High-Scaling). If further, weak-scaling executions are needed for internal evaluation, this parameter can be changed accordingly.
* `-d`, a triplet of integers determining the number of simulation **domains** along x, y, and z directions. The product should be equal to the number of GPUs involved in the execution.

A general example of an execution looks like the following:

```
bin/picongpu -d 2 2 2 -g 512 512 512 --periodic 1 1 1 -s 1500 --fields_energy.period 20
```

Beyond `-g` and `-d`, a few further flags are given. They are explained in following for completeness, but are not to be changed for the benchmark:

* `--periodic`: The Kelvin-Helmholtz instability simulations require periodic boundary conditions along all the three directions, `1 1 1`
* `-s`: The number of simulated time steps, here `1500`
* `--fields_energy`: The field energy diagnostic is dumped at regular intervals (`period 20`), i.e. every `1500/20 = 75` timesteps

### Parameters, Command Line

#### TCO Baseline

To execute the baseline benchmark, a grid size of `-g 1024 1024 512` is to be used. The distribution of nodes can be changed to achieve the best runtime.

For the baseline configuration, PIConGPU is to be executed with the following command line (utilizing the reference 8 JUWELS Booster nodes):

```
bin/picongpu -d 4 4 2 -g 1024 1024 512 --periodic 1 1 1 -s 1500 --fields_energy.period 20
```

#### High-Scaling

To execute runs on a 50 PFLOP/s peak sub-partition of JUWELS Booster (640 nodes or 2560 GPUs), we offer three sets of grid size configurations, depending on the memory utilization: `low`, `medium`, `high`. For exascale simulations, the size of the simulation box needs to be changed accordingly.

Following are the grid parameters used for the high scaling benchmarks with low, medium, and high memory usage and a corresponding grid size larger approximately by a factor of 20 to fit on an exascale system.

|Grid-size on JUWELS Booster |Memory usage | Grid-size on exascale machine|
|----------------------------|-------------|------------------------------|
|`-g 4096 2048 1024`         |Low          |`-g 11264 5632 2816`          |
|`-g 4096 2048 2048`         |Medium       |`-g 11264 5632 5632`          |
|`-g 4096 4096 2560`         |Large        |`-g 11264 11264 7040`         |

With the large memory configuration as an example, a command line for the high-scaling benchmark case looks the following (spreading the domain over 640 JUWELS Booster nodes):

```
bin/picongpu -d 16 16 10 -g 4096 4096 2560 --periodic 1 1 1 -s 1500 --fields_energy.period 20
```

Replace the `-g` parameter as needed per definitions in the table above.

### JUBE

To submit a self-contained benchmark run to the batch system, call `jube run
benchmark/jube/benchmark.xml`. JUBE will generate the necessary configuration and files, and
submit the benchmark to the batch engine.

Beyond other system-specific parameters, the JUBE script contains `node_conf` to give the node configurations `-d` for a given number of nodes. The variable is prefilled with valid configurations for various numbers of nodes to pass on to the PIConGPU command line application, like `-d 4 4 4` (making sure that the product of the three integers given is equal to the amount of GPUs used). The aforementioned `-g` parameter is represented as `grid_size` -- also this value is prefilled in JUBE.

#### TCO Baseline

A simple `jube run benchmark/jube/benchmark.xml` will perform the baseline run for the KHI test case with grid size `-g 1024 1024 512` on 8 JUWELS booster nodes.

#### High-Scaling

The three high-scaling variants are available as JUBE tags (`--tag`);

- `high_large`: High-Scaling Variant with **high** memory utilization (`-g 4096 4096 2560`) 
- `high_medium`: High-Scaling Variant with **medium** memory utilization (` -g 4096 2048 2048`)
- `high_small`: High-Scaling Variant with **low** memory utilization (`-g 4096 2048 1024`)

#### Further Tags

In addition, further tags are given for testing and evaluation purposes

- `strong_scaling`: performs strong scaling runs for the Kelvin Helmholtz Instability test case with grid size -g 1024 1024 1024 on 4, 8, 16, 32, 64, 128 JUWELS booster nodes.
- `weak_scaling`: performs the weak scaling runs for the Kelvin Helmholtz Instability test case with grid sizes `-g 1024 1024 1024`, `-g 2048 1024 1024`, `-g 2048 2048 1024`, and `-g 2048 2048 2048` on `16, 32, 64, 128` JUWELS booster nodes respectively.
- `large strong_scaling`: performs the strong scaling large-scale runs with grid size `-g 4096 2048 2048` on `256, 384, 512, 640` JUWELS booster nodes.
- `large weak_scaling`: performs the weak scaling large-scale runs with grid sizes `-g 4096 2048 2048`, `-g 4096 3072 2048`, `-g 4096 4096 2048`, and `-g 4096 4096 2560` on `256, 384, 512, 640` JUWELS booster nodes respectively.


## Verification

The application should run through successfully without any exceptions or error
codes generated. An overview of the job output indicating successful operation is generated,
similar to the following:

```
   The grid has 0.0206789 cells per average Debye length
initialization time: 44sec 207msec = 44.207 sec
  0 % =        0 | time elapsed:                   20msec | avg time per step:   0msec
  5 % =       75 | time elapsed:            18sec 496msec | avg time per step: 246msec
......
......
100 % =     1500 | time elapsed:       7min 46sec 151msec | avg time per step: 320msec
calculation  simulation time:  7min 46sec 155msec = 466.155 sec
full simulation time:  8min 30sec 887msec = 510.887 sec
```

## Results

The application produces a line in the output which indicates the calculation time of the simulation which is the time spent in the solver:

```
calculation  simulation time:  <#>min <#>sec <#>msec = <#> sec
```

The _calculation simulation time_ is the metric of choice for the benchmark; it is 466.155 sec in the listing above.

### JUBE

Using `jube analyse` and a subsequent `jube result` prints an overview table
with the number of nodes, node configuration, simulation grid configuration, and runtime.

## Commitment

### TCO Baseline

The baseline configuration must be chosen such that the runtime metric is below 470s. This value is achieved with 8 nodes using 4 GPUs per node on the JUWELS Booster system at JSC. Using JUBE, the following output is retrieved.


|version    |system       |nnodes|nconfig   |gridconfig        |calcsimtime|
|-----------|-------------|------|----------|------------------|-----------|
|26cbd45b2c9|juwelsbooster|8     |`-d 4 4 2`|`-g 1024 1024 512`|466.155    |

### High-Scaling

Large scale runs probe JUWELS Booster at 640 nodes with a workload which fills the GPU memory of an A100 to low, medium, or high levels. The resulting calculation simulation times are:

| memory configuration | nodes | calcsimtime |
|----------------------|-------|-------------|
| low                  | 640   | 110.537     |
| medium               | 640   | 196.854     |
| high                 | 640   | 466.785     |
