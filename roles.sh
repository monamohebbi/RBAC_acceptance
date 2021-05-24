#!/usr/bin/env bash

nameSuffix=$(openssl rand -hex 2)

echo "blah-${nameSuffix}"

outfile=$1
touch ${outfile}
> ${outfile}

printf "\nPOST v3/routes\n" >> ${outfile}

domain_guid=40944397-e81b-4fa8-9691-6369ee57ea62
guid=$(cf curl -X POST v3/routes -d "{
    \"host\": \"app-${nameSuffix}\",
    \"path\": \"/some_path\",
    \"relationships\": {
      \"domain\": {
        \"data\": { \"guid\": \"$domain_guid\" }
      },
      \"space\": {
        \"data\": { \"guid\": \"0cfa44d0-17d4-4351-b545-3284026360a6\" }
      }
    }
 }" | jq .'guid')
echo $guid >> $outfile

# guid=$(cat ${outfile} | tr -d '"' | tr -d ' ')
guid=$(echo ${guid}| tr -d '"' | tr -d ' ')
# echo "GUID!   ${guid}"

printf "\nGET v3/routes\n" >> ${outfile}
cf curl v3/routes | jq .resources[].guid  >> ${outfile}

printf "\nGET v3/routes/${guid}\n" >> ${outfile}
request="v3/routes/${guid}"
cf curl ${request} | jq .'guid' >> ${outfile}

request="/v3/domains/${domain_guid}/route_reservations"
printf "\nGET $request\n" >> $outfile
cf curl ${request} >> $outfile

app_guid=57a88e91-3ffd-4724-8250-54425ae46b21
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
        \"weight\": 61
      },
      {
        \"app\": {
        \"guid\": \"$app_guid\",
            \"process\": {
                \"type\": \"web\"
          }
        },
        \"weight\": 39,
        \"port\": 9000
      }
    ]
  }" -i | head -n 1 >> $outfile

printf "\nGET $request" >> $outfile
cf curl $request >> $outfile

printf "\nDELETE $request/:guid for all destinations\n"
dests=$(cf curl $request | jq .destinations[] | jq . 'guid')
for dest in $dests
do
  dest=$($dest | tr -d '"' | tr -d ' ')
  cf curl -X DELETE $request/$dest -i | head -n 1 >> $outfile
done

request=v3/routes/$guid
printf "\nDELETE $request\n" >> ${outfile}
# request="v3/routes/${guid}"
cf curl -X DELETE $request -i | head -n 1 >> ${outfile}

# sleep 5
# printf "\n GET $request\n" >> $outfile
# cf curl ${request} -i | head -n 1 >> ${outfile}
