#!/bin/bash

eval_dir='/home/rajarshi/LSTM-KBC-New/eval'
# input dir which contains the list files for train/dev/test
data_dir='/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning/data/examples/data_small_output/hyponym'
predicate_name='hyponym'
# output dir.
dir_path='/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning/run_scripts/results/lse/2019-01-14-08-55-54'
# pooling method. max is 0, mean is 1, topk is 2, logsumexp is 3.
mean_model=3
# which gpu to use. -1 = use CPU
gpu_id=0
# epochs file is funny. Should get rid of it.
epochs_file='/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning/eval/test_models.txt'
log_dir=$7