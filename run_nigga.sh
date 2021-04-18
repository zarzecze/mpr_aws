# How to run:
# nohup run_nigga.sh

sudo yum install git -y

cd /mnt1/

rm -rf mpr_aws

git clone https://github.com/zarzecze/mpr_aws

cluster_id=`aws emr list-clusters --active | jq -r '.Clusters[0].Id'`
instance_type=`aws emr describe-cluster --cluster-id ${cluster_id} | jq -r ".Cluster.InstanceGroups[0].InstanceType"`
num_instances=$((`aws emr describe-cluster --cluster-id ${cluster_id} | jq -r ".Cluster.InstanceGroups[0].RunningInstanceCount"` + 1))
instance_id=`aws emr describe-cluster --cluster-id ${cluster_id} | jq -r ".Cluster.InstanceGroups[0].Id"`


cd mpr_aws
chmod +x run.sh


instances_to_request=(2 4 7)

for i_sizes in "${instances_to_request[@]}"; do

        aws emr modify-instance-groups --cluster-id ${cluster_id} --instance-groups '[{"InstanceGroupId": "'${instance_id}'", "InstanceCount": '${i_sizes}'}]'

        requested_instances=$((`aws emr describe-cluster --cluster-id ${cluster_id} | jq -r ".Cluster.InstanceGroups[0].RequestedInstanceCount"` + 1))


        echo "Resizing instances from: '${num_instances}' to '${requested_instances}'"

        while [ $num_instances -ne $requested_instances ]
        do
                sleep 1
                num_instances=$((`aws emr describe-cluster --cluster-id ${cluster_id} | jq -r ".Cluster.InstanceGroups[0].RunningInstanceCount"` + 1))
                requested_instances=$((`aws emr describe-cluster --cluster-id ${cluster_id} | jq -r ".Cluster.InstanceGroups[0].RequestedInstanceCount"` + 1))
        done


        echo "DONE resizing"

        ./run.sh $instance_type $num_instances

done

aws s3api create-bucket --bucket $cluster_id

aws s3 cp measurements_seq.txt s3://${cluster_id}/measurements_seq.txt
aws s3 cp measurements_par.txt s3://${cluster_id}/measurements_par.txt