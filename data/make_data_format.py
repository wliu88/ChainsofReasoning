import sys,os
import json
import re
import argparse
from collections import defaultdict
import random
import gzip

parser = argparse.ArgumentParser()
parser.add_argument('-i','--input_dir', required=True)
parser.add_argument('-d','--output_dir''', required=True)
parser.add_argument('-o','--only_relation', required=True, help="This option to be used when data does not have entities")
parser.add_argument('-g','--get_only_relation', required=True, help="This option to be used when data has entities but we only want to extract relations")
parser.add_argument('-e','--ec2_instance', required=True)
parser.add_argument('-m','--max_path_length', required=True)
parser.add_argument('-t','--max_num_types', required=True)

args = parser.parse_args()
input_dir = args.input_dir
out_dir = args.output_dir
isOnlyRelation = (args.only_relation == '1')
getOnlyRelation = (args.get_only_relation == '1')
isEc2_instance = (args.ec2_instance == '1')
MAX_POSSIBLE_LENGTH_PATH = int(args.max_path_length)
NUM_ENTITY_TYPES_SLOTS = int(args.max_num_types)

#gunzip the files in the vocab directory and plug it in; alternatively you can create your own vocab too.
entity_type_vocab_file = '../vocab/entity_type_vocab.txt'
relation_vocab_file = '../vocab/relation_vocab.txt'
entity_vocab_file = '../vocab/entity_vocab.txt'
entity_type_map_file = '../vocab/entity_to_list_type.json'
label_vocab_file= '../vocab/domain-label'

if not isOnlyRelation:
	print('reading entity type vocab')
	entity_type_vocab = {}	
	with open(entity_type_vocab_file,'r') as vocab:
		entity_type_vocab = json.load(vocab)
	print('Done reading entity type vocab')

	print('reading entity vocab')
	entity_vocab = {}
	with open(entity_vocab_file,'r') as vocab:
		entity_vocab = json.load(vocab)
	print('Done reading entity vocab')

	print('reading entity to type list')
	entity_type_map = {}
	with open(entity_type_map_file,'r') as f:
		entity_type_map = json.load(f)
	print(' Done reading entity to type list')

print("hello world")

print('reading relation vocab: ' + relation_vocab_file)
relation_vocab = {}
with open(relation_vocab_file,'r') as vocab:
	relation_vocab = json.load(vocab)
print('Done reading relation vocab')

#read label2int
print('Reading label vocab')
with open(label_vocab_file,'r') as label_vocab:
	label2int = json.load(label_vocab)
print('Done reading label vocab')

# this block of code gets the maximum length of paths
max_length = -1
train_files = ['/positive_matrix.tsv.translated','/negative_matrix.tsv.translated','/dev_matrix.tsv.translated','/test_matrix.tsv.translated'] ##dont change the ordering or remove entries. This is bad coding, I know.
for counter,input_file in enumerate(train_files):
	input_file = input_dir+input_file
	print('Processing '+input_file)
	with open(input_file) as f:
		for entity_count, line in enumerate(f): #each entity pair
			split = line.split('\t')
			e1 = split[0].strip()
			e2 = split[1].strip()
			paths = split[2].strip()
			split = paths.split('###')
			for path in split:
				path_len = len(path.split('-'))
				if  not isOnlyRelation:
					path_len = path_len/2 + 2
				if path_len > max_length:
					max_length = path_len
print(max_length)
max_length = min(MAX_POSSIBLE_LENGTH_PATH,max_length)
print('Max length is '+str(max_length))

# length is the maximum number of entity types for an entity
def get_entity_types_in_order(entity_types, length):
	assert(length <= len(entity_types))
	type_int_list = []
	for entity_type in entity_types:
		if entity_type in entity_type_vocab:
			type_int_list.append(entity_type_vocab[entity_type])
		else:
			type_int_list.append(entity_type_vocab['#UNK_ENTITY_TYPE'])
	# sort in ascending order
	type_int_list = sorted(type_int_list)
	type_int_list = type_int_list[:length] #slice of that length
	type_int_list = type_int_list[::-1] #reverse
	return ','.join(str(i) for i in type_int_list)

#will be called on data with just relations
def get_feature_vector_only_relation(relation):
	feature_vector=''
	#Now add the id for the relation
	if relation in relation_vocab:
		feature_vector = feature_vector + str(relation_vocab[relation])
	else:
		feature_vector = feature_vector + str(relation_vocab['#UNK_RELATION'])
	assert(len(feature_vector.split(' ')) == 1)
	return feature_vector

def get_feature_vector(prev_entity, relation):
	type_feature_vector=''
	#get the entity types of the vector
	if prev_entity in entity_type_map:
		entity_types = entity_type_map[prev_entity]
		# if len(entity_types) <= NUM_ENTITY_TYPES_SLOTS:
		#create the feature vector
		length = min(NUM_ENTITY_TYPES_SLOTS, len(entity_types))
		extra_padding_length = NUM_ENTITY_TYPES_SLOTS - len(entity_types)
		for i in xrange(extra_padding_length):
			type_feature_vector = type_feature_vector + str(entity_type_vocab['#PAD_TOKEN']) +','
		type_feature_vector = type_feature_vector + get_entity_types_in_order(entity_types, length) + ','
	else:
		for i in xrange(NUM_ENTITY_TYPES_SLOTS):#we dont have type for this entity the feature vector would be all UNKNOWN TYPE token
			type_feature_vector = type_feature_vector + str(entity_type_vocab['#UNK_ENTITY_TYPE']) +','
	#NEW: add the id for the entity
	if prev_entity in entity_vocab:
		type_feature_vector = type_feature_vector + str(entity_vocab[prev_entity])+','
	else:
		type_feature_vector = type_feature_vector + str(entity_vocab['#UNK_ENTITY'])+','
	#Now add the id for the relation
	if relation in relation_vocab:
		type_feature_vector = type_feature_vector + str(relation_vocab[relation])
	else:
		type_feature_vector = type_feature_vector + str(relation_vocab['#UNK_RELATION'])
	assert(len(type_feature_vector.split(','))==NUM_ENTITY_TYPES_SLOTS+2) #+2 - because of entity and entity_type
	return type_feature_vector

#form the feature for PAD token for a path using PAD token of entity, relation, entity type.
# pad_feature = relation_pad_token (if only using relation
# pad_feature = type_pad_token, type_pad_token, entity_pad_token, relation_pad_token (if not only using relation and
# max number of entity type is 2.
pad_feature=''

if isOnlyRelation or getOnlyRelation:
	pad_feature = str(relation_vocab['#PAD_TOKEN'])
else:
	for i in xrange(NUM_ENTITY_TYPES_SLOTS):
		if i==0:
			pad_feature = pad_feature + str(entity_type_vocab['#PAD_TOKEN'])
		else:	
			pad_feature = pad_feature + ',' + str(entity_type_vocab['#PAD_TOKEN'])
	pad_feature = pad_feature + ',' + str(entity_vocab['#PAD_TOKEN'])
	pad_feature = pad_feature + ',' + str(relation_vocab['#PAD_TOKEN'])

def get_padding(num_pad_features):
	path_feature_vector=''
	for i in range(num_pad_features):
		if path_feature_vector=='':
			path_feature_vector = pad_feature
		else:
			path_feature_vector = path_feature_vector + ' ' + pad_feature
	return path_feature_vector

missed_entity_count = 0 #entity pair might be missed when we are putting constraints on the max length of the path.
input_files = ['/positive_matrix.tsv.translated','/negative_matrix.tsv.translated','/dev_matrix.tsv.translated','/test_matrix.tsv.translated']
#clean the directory
dirs = ['train','dev','test']
for directory in dirs:
	output_dir = out_dir+'/'+directory
	if not os.path.exists(output_dir):
	    os.makedirs(output_dir)
	for f in os.listdir(output_dir):	
		if os.path.exists(output_dir+'/'+f):
			os.remove(output_dir+'/'+f)

label=''
for input_file_counter, input_file_name in enumerate(input_files):
	if input_file_counter == 0 or input_file_counter == 1:
		output_dir = out_dir+'/train'
		output_file = output_dir+'/'+'train.txt'
		if not os.path.exists(output_dir):
			os.makedirs(output_dir)
		if input_file_counter == 0:
			label = '1'
		if input_file_counter == 1:
			label = '-1'
	if input_file_counter == 2:
		output_dir = out_dir+'/dev'
		output_file = output_dir+'/'+'dev.txt'
		if not os.path.exists(output_dir):
			os.makedirs(output_dir)
	if input_file_counter == 3:
		output_dir = out_dir+'/test'
		output_file = output_dir+'/'+'test.txt'
		if not os.path.exists(output_dir):
			os.makedirs(output_dir)
	print('Output dir changed to '+output_dir)
	input_file = input_dir+input_file_name
	with open(input_file) as f:
		print(input_file)
		for entity_count, line in enumerate(f): #each entity pair
			output_line=''
			split = line.split('\t')
			if len(split) == 4:
				assert(input_file_counter == 2 or input_file_counter == 3)
				label = str(split[3].strip()) 
			e1 = split[0].strip()
			e2 = split[1].strip()
			prev_entity = e1
			split = split[2].split('###')
			flag = 0
			for path_counter, each_path in enumerate(split):
				prev_entity = e1
				each_path = each_path.strip()
				relation_types = each_path.split('-')
				path_len = len(relation_types)
				if  not isOnlyRelation:
					path_len = path_len/2 + 2 #so 3 months after writing the code, I was wondering why the + 2 - the answer is even if for a one hop path e1 r1 e2 we consider (e1, r1)->(e2, UNK_RELATION); hence path length is atleast 2
				if path_len > max_length:
					continue
				num_pad_features = max_length - path_len
				if getOnlyRelation and not isOnlyRelation: 
					num_pad_features = num_pad_features + 1 #because we dont have entity2,#end_relation term and hence the assert statement at the end assert(len(path_feature_vector.split(' ')) == max_length) fails
				path_feature_vector = get_padding(num_pad_features) #all type_feat_vector separated by space
				for token_counter, token in enumerate(relation_types): #every node in the path
					if  not isOnlyRelation:
						if token_counter%2 == 0: #relation
							#form the feature vector of entity type
							relation = token
							if getOnlyRelation:
								type_feature_vector = get_feature_vector_only_relation(relation)		
							else:
								type_feature_vector = get_feature_vector(prev_entity, relation)
							if token_counter == 0 and path_feature_vector == '':
								path_feature_vector = path_feature_vector + type_feature_vector
							else:
								path_feature_vector = path_feature_vector + ' ' + type_feature_vector
							
						else: #this is an entity
							prev_entity = token
					else:
						relation = token
						type_feature_vector = get_feature_vector_only_relation(relation)
						if token_counter == 0 and path_feature_vector == '':
							path_feature_vector = path_feature_vector + type_feature_vector
						else:
							path_feature_vector = path_feature_vector + ' ' + type_feature_vector
				if  not isOnlyRelation and not getOnlyRelation:			
					#take care of e2 now
					type_feature_vector = get_feature_vector(e2, '#END_RELATION')
					#add to the path_feature_vector
					path_feature_vector = path_feature_vector + ' ' + type_feature_vector
				try:
					assert(len(path_feature_vector.split(' ')) == max_length)
				except AssertionError:
					print(len(path_feature_vector.split(' ')))
					print(max_length)
					print(path_feature_vector)
					print('===============')
					# sys.stderr.write("line:\t"+line)
					# sys.stderr.write("path:\t"+each_path)
					continue

				if path_counter == 0 or flag == 0: # i put the flag check because the first path might be eliminated because it is greater than max_length but path_counter wont be 0
					flag = 1
					output_line = output_line + path_feature_vector
				else:
					output_line = output_line +';'+ path_feature_vector
			path_counter = len(output_line.split(';'))
			int_label=''
			int_label = str(label2int['domain'][label.strip()])
			output_line = output_line.strip()
			if len(output_line) == 0: #this might happen when an entity pair has no paths lesser than length k (eg 3)
				missed_entity_count = missed_entity_count + 1
				continue
			output_line = int_label+'\t'+output_line
			output_line = output_line.strip()
			if path_counter!=0:
				output_file_with_pathlen = output_file+'.'+str(path_counter)+'.int'
				# with write option a, all entity pairs with same length of paths will be write to the same file.
				with open(output_file_with_pathlen,'a') as out:
					out.write(output_line+'\n')
			if entity_count % 100 == 0:
				print('Processed '+str(entity_count)+' entity pairs')
print("Missed entity pair count "+str(missed_entity_count))
