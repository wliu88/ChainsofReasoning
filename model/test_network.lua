package.path = package.path ..';../model/batcher/?.lua'
package.path = package.path ..';../model/net/?.lua'
package.path = package.path ..';../model/model/?.lua'
package.path = package.path ..';../model/module/?.lua'
package.path = package.path ..';../model/optimizer/?.lua'
package.path = package.path ..';../model/criterion/?.lua'
require 'torch'
require 'nn'
require 'optim'
require 'rnn'
--Dependencies from this package
require 'MyOptimizer'
require 'OptimizerCallback'
require 'BatcherFileList'
require 'FeatureEmbedding'
require 'MapReduce'
require 'TopK'
require 'Print'
require 'LogSumExp'
require "ConcatTableNoGrad"

-- Test 1. embedding layers
local embed1 = nn.Sequential()
local lookup1 = nn.LookupTable(2, 250)
embed1:add(nn.SelectTable(1)):add(lookup1)

local embed2 = nn.Sequential()
local lookup2 = nn.LookupTable(2, 50)
embed2:add(nn.SelectTable(2)):add(lookup2)

local cat = nn.ConcatTableNoGrad()
cat:add(embed1):add(embed2)
local embeddingLayer = nn.Sequential():add(cat):add(nn.JoinTable(3))

local predictor_net = nn.Sequential()
predictor_net:add(nn.SplitTable(3)):add(embeddingLayer)

print(predictor_net)
-- the original input dimension is #entity pairs x #paths x #steps in a path x #features for each step
-- after MapReduce. The input dimension is reshaped to (#entity pairs * #paths) x #steps in a path x #features for each step
local x = torch.Tensor(4,8,9):fill(1)
print("x", x:size())

local y = predictor_net:forward(x)
print("y", y:size())