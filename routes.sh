#!/usr/bin/env bash

nameSuffix=$(openssl rand -hex 2)

echo "blah-${nameSuffix}"

outfile=$1
touch ${outfile}
> ${outfile}

request=v3/routes
printf "\nPOST $request\n" >> ${outfile}

domain_guid=cfc3a7a3-61fb-40ab-bb26-d6a6fffe2b1a
guid=$(cf curl -X POST $request -d "{
    \"host\": \"app-${nameSuffix}\",
    \"path\": \"/some_path\",
    \"relationships\": {
      \"domain\": {
        \"data\": { \"guid\": \"$domain_guid\" }
      },
      \"space\": {
        \"data\": { \"guid\": \"8e40386c-4e86-41c1-a6b5-b173f40648d1\" }
      }
    }
 }" | jq .'guid')
echo $guid >> $outfile

# guid=$(cat ${outfile} | tr -d '"' | tr -d ' ')
guid=$(echo ${guid}| tr -d '"' | tr -d ' ')
# echo "GUID!   ${guid}"

printf "\nGET $request\n" >> ${outfile}
cf curl v3/routes | jq .resources[].guid  >> ${outfile}

printf "\nGET $request/$guid\n" >> ${outfile}
cf curl $request/$guid | jq .'guid' >> ${outfile}

request="/v3/domains/$domain_guid/route_reservations"
printf "\nGET $request\n" >> $outfile
cf curl $request >> $outfile

app_guid=86bb6af6-6e14-425a-97b7-d9cc4f3b4ea3
request="/v3/routes/$guid/destinations"
printf "\nPOST $request\n" >> $outfile
cf curl -X POST  $request -d "{
    \"destinations\": [
      {
        \"app\": {
          \"guid\": \"$app_guid\"
        }
      }
    ]
  }" -i | head -n 1 >> $outfile

printf "\nGET $request" >> $outfile
cf curl $request >> $outfile

request="/v3/apps/$app_guid/routes"
printf "\nGET $request with grep to check for newly created route\n" >> $outfile
cf curl $request | grep $guid -A 20 >> $outfile

request="/v3/routes/$guid/destinations"
printf "\nPATCH $request\n" >> $outfile
cf curl -X PATCH  $request -d "{
    \"destinations\": [
      {
        \"app\": {
          \"guid\": \"$app_guid\"
        },
        \"weight\": null
      },
      {
        \"app\": {
        \"guid\": \"$app_guid\",
            \"process\": {
                \"type\": \"web\"
          }
        },
        \"weight\": null,
        \"port\": 9000
      }
    ]
  }" -i | head -n 1 >> $outfile

printf "\nGET $request" >> $outfile
cf curl $request >> $outfile

printf "\nDELETE $request/:guid for all destinations\n" >> $outfile
# dests=$(cf curl $request | jq .destinations[] | jq .guid)
dests=$(cf curl $request |  jq .destinations[].guid)
echo "************************************** $dests"
for dest in $dests
do
  destination_guid=$(echo $dest | tr -d '"' | tr -d ' ')
  cf curl -X DELETE $request/$destination_guid -i | head -n 1 >> $outfile
done

request=v3/routes/$guid
printf "\nDELETE $request\n" >> ${outfile}
cf curl -X DELETE $request -i | head -n 1 >> ${outfile}

sleep 5
printf "\n GET $request\n" >> $outfile
cf curl ${request} -i | head -n 1 >> ${outfile}
