#!/bin/bash

mainDir='/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning'
data_dir=''
out_dir=''
only_relation=0 #0 #1 means that the input paths have only relations.
max_path_length=8
num_entity_types=14 #10 for robot, #14 for wordnet, #7 for freebase
get_only_relations=1 #0 #usually 0, if 1 then get only relations