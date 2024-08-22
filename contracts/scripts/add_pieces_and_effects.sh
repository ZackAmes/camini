#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

export RPC_URL="http://localhost:5050";

export WORLD_ADDRESS=$(cat ./manifests/dev/deployment/manifest.json | jq -r '.world.address')
export A_ADDRESS=$(cat ./manifests/dev/deployment/manifest.json | jq -r '.contracts[] | select(.tag == "ok-a" ).address')
export B_ADDRESS=$(cat ./manifests/dev/deployment/manifest.json | jq -r '.contracts[] | select(.tag == "ok-b" ).address')
export DAMAGE_ADDRESS=$(cat ./manifests/dev/deployment/manifest.json | jq -r '.contracts[] | select(.tag == "ok-damage" ).address')
export GOV_ADDRESS=$(cat ./manifests/dev/deployment/manifest.json | jq -r '.contracts[] | select(.tag == "ok-gov" ).address')


echo "---------------------------------------------------------------------------"
echo world : $WORLD_ADDRESS 
echo " "
echo a : $A_ADDRESS
echo b : $B_ADDRESS
echo damage : $DAMAGE_ADDRESS
echo "---------------------------------------------------------------------------"


# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
sozo execute --world $WORLD_ADDRESS $GOV_ADDRESS add_piece -c $A_ADDRESS --wait
sozo execute --world $WORLD_ADDRESS $GOV_ADDRESS add_piece -c $B_ADDRESS --wait
sozo execute --world $WORLD_ADDRESS $GOV_ADDRESS set_damage_contract -c $DAMAGE_ADDRESS --wait
