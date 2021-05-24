#!/usr/bin/env bash

cf create-user mona abc

cf curl -X POST v3/roles -d \
'{
  "type": "organization_user",
  "relationships": {
    "user": {
      "data": {
        "guid": "d8685663-a98a-4c4d-86b0-4523dd45a8b1"
      }
    },
    "organization": {
      "data": {
        "guid": "ace97227-820c-4d87-b84a-560e8ef2ee91"
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
            "guid": "d8685663-a98a-4c4d-86b0-4523dd45a8b1" 
          }
        },
        "space": {
          "data": {
          "guid": "8e40386c-4e86-41c1-a6b5-b173f40648d1" 
          }
        }
      }
    }'
