# ChainsofReasoning

Code for paper [Chains of Reasoning over Entities, Relations, and Text using
Recurrent Neural Networks](https://arxiv.org/abs/1607.01426)

##Dependencies

- [torch](https://github.com/torch/torch7)
- [nn](https://github.com/torch/nn)
- [rnn](https://github.com/Element-Research/rnn)
- [optim](https://github.com/torch/optim)
- [cunn](https://github.com/torch/cunn) (optional: required if you train on GPU)


## Instructions for running the code

### Data
Get the data from [here](http://iesl.cs.umass.edu/downloads/akbc16/). ~~(Note: This might change soon, as I will release an updated version of the dataset)~~

To get the correct format to run the models, 
```shell
cd data
/bin/bash make_data_format.sh <path_to_input_data> <output_dir>
```
For example you can run,
```shell
cd data
/bin/bash make_data_format.sh examples/data_small_input examples/data_small_output
```
It's important to not put / after directory name.

### Model
To start training, first checkout [run_scripts/config.sh](run_scripts/config.sh). This defines all the hyperparams and other inputs to the network. After specifying model parameters, to start training run,

```shell
cd run_sripts
/bin/bash train.sh ./config.sh
```

### Path Query Experiment on WordNet (Sec 5.5 of the paper)
Checkout the instructions of the readme page in [wordnet_experiment/README.md](wordnet_experiment/README.md).

### GPU/CPU settings
Set gpu_id=0 in run_scripts/config.sh to enable GPU training using CUDA.
Set gpu_id=-1 in run_scripts/config.sh to disable GPU training.

### Changelog
- Aug 7 2017: Released the dataset used for the EACL paper. I apologize for the delay.
- Mar 29 2017: added test scripts.

### Contact:
Feel free to email me with any questions you have at rajarshi@cs.umass.edu


