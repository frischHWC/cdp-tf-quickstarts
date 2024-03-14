#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
#!/bin/bash
echo "Starting CDP TF Quickstarts" 

# Required
export ENV_NAME=""
export WHITELIST_IPS=""
export CLOUD_PROVIDER=""

## For Azure
export AZ_ARM_CLIENT_ID=""
export AZ_ARM_CLIENT_SECRET=""
export AZ_ARM_TENANT_ID=""
export AZ_ARM_SUBSCRIPTION_ID="" 
export SSH_USER_KEY=""

## For AWS
export AWS_AWS_ACCESS_KEY_ID=""
export AWS_AWS_SECRET_ACCESS_KEY=""
export AWS_KEY_PAIR=""

# Optional 
export ACTION="create"
export DEPLOYMENT_TYPE="public"

## For AWS
export AWS_REGION="eu-west-3"

## For Azure
export AZ_REGION="eastus"


function usage()
{
    echo "This script aims to create, start, stop or delete a Cloudera Public Cloud Cluster"
    echo ""
    echo "Usage is the following : "
    echo ""
    echo "./setup-cluster.sh"
    echo "  -h --help"
    echo "  --cluster-name=$CLUSTER_NAME Required as it will be the name of the cluster (Default) "
    echo "  --whitelist-ips=$WHITELIST_IPS Required to access the cluster (Default) "
    echo "  --cloud-provider=$CLOUD_PROVIDER Required to know on which cloud to deploy, either: aws, azure or gcp (Default) "
    echo ""
    echo " Required for Azure: "
    echo "  --arm-client-id=$AZ_ARM_CLIENT_ID Required to create machines (Default) "
    echo "  --arm-client-secret=$AZ_ARM_CLIENT_SECRET Required to create machines (Default) "
    echo "  --arm-tenant-id=$AZ_ARM_TENANT_ID Required to create machines (Default) "
    echo "  --arm-subscription-id=$AZ_ARM_SUBSCRIPTION_ID Required to create machines (Default) "
    echo "  --ssh-user-key=$SSH_USER_KEY Required to acces the cluster (Default) "
    echo ""
    echo " Required for AWS: "
    echo "  --aws-access-key-id=$AWS_AWS_ACCESS_KEY_ID Required to create machines (Default) "
    echo "  --aws-access-key-secret=$AWS_AWS_SECRET_ACCESS_KEY Required to create machines (Default) "
    echo "  --aws-key-pair=$AWS_KEY_PAIR Required to access the cluster (Default) "
    echo ""
    echo " Optional: "
    echo "  --action=$ACTION Required to know what to do, to choose between: create or delete (Default) create"
    echo "  --deployment-type=$DEPLOYMENT_TYPE Deployment type between: public, private or semi-private (Default) $DEPLOYMENT_TYPE "
    echo "  --aws-region=$AWS_REGION (Default) $AWS_REGION "
    echo "  --az-region=$AZ_REGION (Default) $AZ_REGION "
    echo ""
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --cluster-name)
            CLUSTER_NAME=$VALUE
            ;;    
        --whitelist-ips)
            WHITELIST_IPS=$VALUE
            ;;
        --cloud-provider)
            CLOUD_PROVIDER=$VALUE
            ;;
        --arm-client-id)
            AZ_ARM_CLIENT_ID=$VALUE
            ;; 
        --arm-client-secret)
            AZ_ARM_CLIENT_SECRET=$VALUE
            ;;
        --arm-tenant-id)
            AZ_ARM_TENANT_ID=$VALUE
            ;;
        --arm-subscription-id)
            AZ_ARM_SUBSCRIPTION_ID=$VALUE
            ;;
        --ssh-user-key)
            SSH_USER_KEY=$VALUE
            ;;
        --aws-access-key-id)
            AWS_AWS_ACCESS_KEY_ID=$VALUE
            ;;
        --aws-access-key-secret)
            AWS_AWS_SECRET_ACCESS_KEY=$VALUE
            ;;
        --aws-key-pair)
            AWS_KEY_PAIR=$VALUE
            ;;
        --action)
            ACTION=$VALUE
            ;;
        --deployment-type)
            DEPLOYMENT_TYPE=$VALUE
            ;;
        --aws-region)
            AWS_REGION=$VALUE
            ;;
        --az-region)
            AZ_REGION=$VALUE
            ;;
        --test)
            TEST=$VALUE
            ;;     
        *)
            ;;
    esac
    shift
done

./logger.sh

# TODO: Implement Checks on params passed


# Setup env files
WORK_DIR="work-dir-${CLUSTER_NAME}"
mkdir -p ${WORK_DIR}
case $CLOUD_PROVIDER in
    aws)
        cp -Rp aws/* ${WORK_DIR}/
        ;; 
    azure)
        cp -Rp azure/* ${WORK_DIR}/
        ;;
    gcp)
        cp -Rp gcp/* ${WORK_DIR}/
        ;;     
    *)
        ;;
esac
cd ${WORK_DIR}

# Split WHITELIST_IP
export WHIP_UNIQ=$( echo ${WHITELIST_IPS} | uniq )
export WHIP_ARRAY=( ${WHIP_UNIQ} )
export WHITELIST_IP=""
for ip in "${WHIP_ARRAY[@]}"; do
    WHITELIST_IP+="\"$ip/32\","
done
WHITELIST_IP=${WHITELIST_IP%,}

if [ "${ACTION}" == "create" ]
then
    logger info "Creating cluster"
    envsubst < terraform.tfvars.temp > terraform.tfvars
    terraform init
    terraform apply -auto-approve
fi

if [ "${ACTION}" == "delete" ]
then
    logger warn "Deleting cluster"
    terraform destroy -auto-approve
    logger info "To finish deletion, run manually: "
    logger info "      rm -rf $(pwd) "
fi

cd ../
logger success "Finished CDP TF Quickstarts" 