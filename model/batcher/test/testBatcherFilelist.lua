--testcases for BatcherFileList
package.path = package.path ..';../?.lua'
require 'BatcherFileList'

-- / after the last directory is needed
local fileList = '/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning/data/examples/test_output/_architecture_structure_address/train.list'
--'/iesl/local/rajarshi/data_full_max_length_8_small//combined_train_list/train.list'

batchSize = 1000
shuffle = true
useCuda = true
maxBatches = 10
local count = 0
local batcherFileList = BatcherFileList(fileList, batchSize, shuffle, maxBatches, useCuda)
local test_counter = 0
print("initialization successed")
-----see if getBatch() works--------------
local labels, data, size, classId = batcherFileList:getBatch()
count = count + 1
print("new batch")
print(labels:size())
print(data:size())
print(classId)
assert(labels ~= nil and data ~= nil and classId ~= nil)
print(string.format('test %d passed!',test_counter))
test_counter = test_counter + 1


-- ------call getBatch till it returns nil--------
visited_batches = {}
while(true)
do
	local  labels, data = batcherFileList:getBatch()
	if labels == nil then
		break
	end
	table.insert(visited_batches, data:size(2))
	--print("new batch")
	--print(labels:size())
	--print(data:size())
	--print(classId)
	-- print(labels:size())
	-- print(data:size())
	count = count + 1
	-- print(count)
end
print("visited batches of lengths", visited_batches)

batcherFileList:reset()
local count1 = 0
visited_batches = {}
while(true)
do
	local  labels, data = batcherFileList:getBatch()
	if labels == nil then
		break
	end
	table.insert(visited_batches, data:size(2))
	-- print(labels:size())
	-- print(data:size())
	count1 = count1 + 1
	xlua.progress(count1, count)
	-- print(count1)
end
assert(count == count1)
print("visited batches of lengths", visited_batches)
print(string.format('test %d passed!',test_counter))
test_counter = test_counter + 1


----- Now set shuffle to false and check the sequence of classId's it should be the same
shuffle = false
batcherFileList = BatcherFileList(fileList, batchSize, shuffle, maxBatches, useCuda)
local classIdTable1 = {}
while(true)
do
	local  labels, data,size, classId = batcherFileList:getBatch()
	table.insert(classIdTable1, classId)
	if labels == nil then
		break
	end
end
batcherFileList:reset()

local classIdTable2 = {}
while(true)
do
	local  labels, data,size, classId = batcherFileList:getBatch()
	table.insert(classIdTable2, classId)
	if labels == nil then
		break
	end
end

--check if the sizes are same
assert(#classIdTable1 == #classIdTable2)

for i=1, #classIdTable1 do
	assert(classIdTable1[i] == classIdTable2[i])
end
print(string.format('test %d passed!',test_counter))
test_counter = test_counter + 1

