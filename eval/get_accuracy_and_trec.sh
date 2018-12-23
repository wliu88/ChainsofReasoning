#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 config_file"
	exit 1
fi

config_file=$1
source $config_file
echo "data_dir "$data_dir
echo "predicate_name "$predicate_name
echo "dir_path "$dir_path
echo "mean_model "$mean_model
echo "gpu_id "$gpu_id
echo "epochs_file "$epochs_file
echo "log_dir "$log_dir

eval_dir='/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning/eval'

##sample run script
#if [ "$#" -ne 6 ]; then
#  echo "Usage: $0 data_dir predicate_name mean_model gpu_id input_dir epochs_file" >&2
#  exit 1
#fi
#host=`hostname`
#if [[ $host == ip* ]]; then
#	eval_dir='/home/ubuntu/LSTM-KBC-New/eval'
#else
#	eval_dir='/home/rajarshi/LSTM-KBC-New/eval'
#fi
#data_dir=$1
#predicate_name=$2
#dir_path=$5
#mean_model=$3
#gpu_id=$4
#epochs_file=$6
#log_dir=$7

CUDA_VISIBLE_DEVICES=gpu_id

#remove previous logs
log_dir=$dir_path/eval_log
mkdir -p $log_dir

#this will output score file
echo "Executing ${eval_dir}/test_from_checkpoint.lua"
cmd="th ${eval_dir}/test_from_checkpoint.lua -input_dir $data_dir -output_scores 1 -out_dir $dir_path -predicate_name $predicate_name -meanModel $mean_model -gpuid $gpu_id -epochs_file $epochs_file"
echo $cmd
CUDA_VISIBLE_DEVICES=$gpu_id  $cmd | tee $log

#CUDA_VISIBLE_DEVICES=$gpu_id th $eval_dir/test_from_checkpoint.lua -input_dir $data_dir -output_scores 1 -out_dir $dir_path -predicate_name $predicate_name -meanModel $mean_model -gpuid $gpu_id -epochs_file $epochs_file 2>$log_dir/$predicate_name.err | tee $log_dir/$predicate_name.log #-model_path ${model_path} -model_name ${model_name}

#this will make trec eval format files
#echo "Executing ${eval_dir}/make_trec_format.py"
#python ${eval_dir}/make_trec_format.py -i $dir_path/$predicate_name -e $epochs_file 2>>$log_dir/$predicate_name.err | tee -a $log_dir/$predicate_name.log #-m ${model_name}