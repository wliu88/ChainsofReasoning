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

-- embedding
--local embed1 = nn.Sequential()
--embed1:add(nn.SelectTable(-1))
--local embed2 = nn.Sequential()
--embed2:add(nn.SelectTable(-2))
--local cat = nn.ConcatTableNoGrad()
--cat:add(embed1):add(embed2)
--local embeddingLayer = nn.Sequential():add(embed1) --:add(nn.JoinTable(3))
--
--local predictor_net = nn.Sequential()
--predictor_net:add(nn.SplitTable(3)) --:add(embeddingLayer)
--
--print(predictor_net)
--
--local x = torch.randn(2,2,4,10)
--print("x", x)
--
--local y = predictor_net:forward(x)
--print("y", y)
--print("y[1]", y[1])
--print("y[2]", y[2])

-- test select
local net = nn.Sequential()
net:add(nn.SelectTable(-1))
local x = {torch.randn(2, 2, 10), torch.randn(2,1,10)}
print("x", x)
local y = net:forward(x)
print("y", y)
