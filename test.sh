#!/usr/bin/env bash

cf curl -X POST v3/apps -d '{
  "name": "c",
  "relationships": {
    "space": {
      "data": {
        "guid": "0cfa44d0-17d4-4351-b545-3284026360a6"
      }
    }
  }
}' | tee  jq . "guid"
