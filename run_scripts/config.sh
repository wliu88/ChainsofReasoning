#!/bin/bash

# 1. IO
host=`hostname`
createExptDir=1 #make it 0 if you dont want to create a directory and only print stuff
experiment_dir="/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning"
output_dir="results"
experiment_file=$experiment_dir/0.txt
output_dir=$output_dir/lse
# it's important to put / after the last directory.
data_dir='/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning/data/examples/data_small_output/_music_artist_genre/'
gpu_id=0

# 2. Features
numEntityTypes=7
includeEntityTypes=1
includeEntity=1
numEpoch=20
# the number of features should be 1 + 1 (if include entity) + number of entity types (if include entity types)
numFeatureTemplates=9

# 3. Vocabs
relationVocabSize=51390
entityVocabSize=1542690
entityTypeVocabSize=2218

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
entityTypeEmbeddingDim=100
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
