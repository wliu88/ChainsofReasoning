#!/bin/bash

# 1. IO
host=`hostname`
createExptDir=1 #make it 0 if you dont want to create a directory and only print stuff
experiment_dir="/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning"
output_dir='/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning/run_scripts/results/2019-07-16T16:25'
predicate_name='verb_group'
experiment_file=$experiment_dir/0.txt
data_dir='/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning/data/examples/auto_generated_data_output/verb_group/train.list'
# which gpu to use. -1 = use cpu. must use gpu
gpu_id=0

# 2. Features
includeEntityTypes=1
numEntityTypes=14
includeEntityTypes=1
includeEntity=0
numEpoch=50
# the number of features should be 1 + 1 (if include entity) + number of entity types (if include entity types)
numFeatureTemplates=16

# 3. Vocabs
relationVocabSize=24
entityVocabSize=29996
entityTypeVocabSize=8093

# 4. Batch Training
# this sets the number of entity pairs in a batch
# entity pairs with the same number of paths are grouped together in a batch
batchSize=32

# 5. Network Structure
rnnType='rnn' #rnn or lstm as of now
numLayers=1
useReLU=1
useDropout=0
dropout=0.3

rnnHidSize=250
relationEmbeddingDim=250
entityTypeEmbeddingDim=50
entityEmbeddingDim=50

# the name of this parameter is confusing. This sets the pooling method. 0 is max; 1 is top K , 2 is LogSumExp
topK=2
# the number of K if using top K as pooling method. Not used if using other pooling methods.
K=5

# 6. Initialization
rnnInitialization=1
paramInit=0.1

# 7. Optimization
useAdam=1
learningRate=1e-3
learningRateDecay=0.0167 #(1/60)
l2=1e-3
epsilon=1e-8 #epsilon for adam
regularize=0
useGradClip=1 # 0 == L2 regularization
gradClipNorm=5
# package_path='/home/rajarshi/ChainsofReasoning/model/?.lua'

# 8. Training updates
gradientStepCounter=100000 #to print loss after gradient updates
saveFrequency=1
evaluationFrequency=5
