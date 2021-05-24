#!/usr/bin/env bash

cf curl -X POST v3/roles -d \
'{
  "type": "organization_user",
  "relationships": {
    "user": {
      "data": {
        "guid": "9b76a41c-b5f7-4bf4-ac64-0119ad92ab2e"
      }
    },
    "organization": {
      "data": {
        "guid": "7294265e-32f6-4d10-a0e5-b9e8a681fba2"
      }
    }
  }
}'

cf curl -X POST v3/roles -d \
'{
      "type": "space_application_supporter", 
      "relationships": { 
        "user": { 
          "data": { 
            "guid": "9b76a41c-b5f7-4bf4-ac64-0119ad92ab2e" 
          } 
        }, 
        "space": { 
          "data": { 
          "guid": "0cfa44d0-17d4-4351-b545-3284026360a6" 
          } 
        } 
      } 
    }'
