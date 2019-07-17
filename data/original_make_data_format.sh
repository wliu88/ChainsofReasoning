#!/bin/bash
host=`hostname`

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 data_dir out_dir" >&2
  exit 1
fi

mainDir='/home/weiyu/Research/Path_Baselines/CVSM/ChainsofReasoning'
data_dir=$1
out_dir=$2
preprocessingDir=${mainDir}/'data'
only_relation=0 #0 #1 means that the input paths have only relations.
qsub_log_dir=$preprocessingDir/qsub_log
max_path_length=8
num_entity_types=14 #10 for robot, #14 for wordnet, #7 for freebase
get_only_relations=0 #0 #usually 0, if 1 then get only relations

echo "max_path_length "$max_path_length
echo "num_entity_types "$num_entity_types
echo "get_only_relations" $get_only_relations

mkdir -p $out_dir
mkdir -p $qsub_log_dir
counter=0

# search file started with _
for r in `ls ${data_dir}`                #| grep ^_`
do
	counter=$((counter+1))
	relation_dir=$data_dir/$r
	out_dir_r=$out_dir/$r
	name=$r
	echo "Starting for "$relation_dir.
	cmd="/bin/bash $preprocessingDir/make_data_format_single_relation.sh $relation_dir $out_dir_r $r $only_relation $max_path_length $num_entity_types $get_only_relations"
	echo $cmd
	$cmd 2>$qsub_log_dir/$r.err
	cmd1="/bin/bash $preprocessingDir/insertClassLabelsPerRelation.sh $out_dir_r $counter $mainDir $qsub_log_dir"
	echo "Inserting classId's"
	echo $cmd1
	$cmd1 & 2>>$qsub_log_dir/log.err
done

echo "Done Done"
