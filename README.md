## ChainsofReasoning

This repo is forked from Rajarshi Das's [code](https://github.com/rajarshd/ChainsofReasoning). The original repo is no longer
maintained. Modifications have been made to ensure the code runs smoothly. Below is a brief description of the code from the original repo:

Code for paper [Chains of Reasoning over Entities, Relations, and Text using
Recurrent Neural Networks](https://arxiv.org/abs/1607.01426)

##Important Notes:
1. The original code interchanges class labels (1 and 0) of examples by adding one in `data/int2torch.lua` then multiplying -1
and adding 2 in `model/batcher/Batcher.lua`. When negative examples are more than positive examples, by flipping the the
class labels, the MAP calculated for positive examples will be higher. 

2. Training accuracy can be evaluated by changing input files in `eval/test_from_checkpoint.lua` around line 55. 

##Dependencies

- [torch](https://github.com/torch/torch7)
- [nn](https://github.com/torch/nn)
- [rnn](https://github.com/Element-Research/rnn)
- [optim](https://github.com/torch/optim)
- [cunn](https://github.com/torch/cunn)
- util

## Quick Start
1. Get the data from [here](http://iesl.cs.umass.edu/downloads/akbc16/).

2. The data need to be formatted as torch tensors to pass to the network. Running the following to prepare the data:
    ```shell
    cd data
    /bin/bash make_data_format.sh <path_to_input_data> <output_dir>
    ```
   For example you can run,
   ```shell
   cd data
   bash make_data_format.sh examples/data_small_input examples/data_small_output
   ```
   It's important to not put / after directory name.
   
3. Specify parameters in `run_scripts/config.sh`. This file has detailed descriptions for all parameters. For parameters
   in `2. Features` section, see `data/make_data_format.sh` to find out the dimension of input features. To set 
   paramters in `3. Vocabs` section, see files in `vocab` directory.

4. Start training:
   ```shell
   cd run_sripts
   bash train.sh config.sh
   ```

5. Use the trained model for evaluation. Specify paramters in `eval/config.sh`. Notice an epoch file is needed. It
   specifies the model from which iteration will be used. For example, this file can be simply created by running
   `echo "model-20" > test_models.txt`
   ```shell
   cd eval
   bash get_accuracy_and_trec.sh config.sh
   ```
   
6. After evaluation, the results can be found in the folder specified in `eval/config.sh`. There will be an `accuracy.txt`
   showing the percentage of correctly predicting whether the target relation exists between entity pairs. There will be
   another file showing the predicted score and the ground truth label for every entity pair. Each line has the format of
   `"[target_relation]\t[entity_pair_counter]\t[predicted_score]\t[ground_truth_label]\n"`. This file can be used to compute
   MAP and MRR for the relation. 


## Understand the Model
To help understand the network structure, `model/model_structure.txt` is provided. Most of the content is in standard
torch model format, a little bit is in pseudo-code as the original code uses a custom `MapReduce` class to change the 
dimension of the input and output for mini-batch training. `model/test_network.lua` is also there to help you test out
different components of the model and see the dimension of the data. 

