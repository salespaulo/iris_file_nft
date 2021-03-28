#!/bin/bash

name=${name}
description=${description}
owner=${owner}
file=${file}
chain_id=${chain_id}
key_name=${key_name}

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

output_file=$(ipfs add $file)
file_hash=$(echo $output_file | grep -oE  "Qm[1-9A-HJ-NP-Za-km-z]{44}")
file_hash_lower=$(echo $file_hash | tr "[:upper:]" "[:lower:]")
echo "File IPFS Hash: " $file_hash
echo "NFT ID: " $file_hash_lower
echo "{\"name\":\"${name}\",\"description\":\"${description}\",\"image\":\"ipfs://${file_hash}\"}" > meta.json
output_meta=$(ipfs add meta.json)
meta_uri=ipfs://$(echo $output_meta | grep -oE  "Qm[1-9A-HJ-NP-Za-km-z]{44}")
echo "NFT Meta URI: "$meta_uri

meta=$(cat meta.json)
iris tx nft issue $file_hash_lower --from=$key_name --name=$file_hash_lower --schema=$meta --chain-id=$chain_id
iris tx nft mint $file_hash_lower $file_hash_lower --uri=$meta_uri --recipient=$owner --from=$key_name --chain-id=$chain_id
