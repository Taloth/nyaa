#!/usr/bin/env bash

# create indicies named "nyaa" and "sukebei", these are hardcoded
curl -v -XPUT 'elastic:9200/nyaa?pretty' -H'Content-Type: application/yaml' --data-binary @es_mapping.yml
curl -v -XPUT 'elastic:9200/sukebei?pretty' -H'Content-Type: application/yaml' --data-binary @es_mapping.yml
