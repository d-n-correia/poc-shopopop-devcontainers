#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  
source $SCRIPT_DIR/../../scripts/utils.sh

project_list=("mobiles-api" "authentication-api" "tracking-api" "service-kyc" "delivery-api")

for project in "${project_list[@]}"; do
    ensure_project_exist $project
done