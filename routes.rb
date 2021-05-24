# class Main
#   class << self
#     def resources
#       %w[
#         app_usage_events
#         audit_events
#         builds
#         buildpacks
#         deployments
#         routes
#         service_brokers
#         service_instances
#         service_offerings
#         service_plans
#         stacks
#         apps/9485d178-eb93-49c6-9289-33597fbff59f/revisions
#         service_bindings
#         apps/e3a57066-096e-4b26-a085-8dee8cfa47db/sidecars
#       ]
#     end

#     def per_page
#       5
#     end

#     def filters
#       %w[guids]
#     end

#     def filters_map(filter)
#       {
#         'created_ats' => 'created_at',
#         'updated_ats' => 'updated_at',
#         'guids' => 'guid',
#       }[filter]
#     end

#     def main
#       resources.each do |resource|
#         filters.each do |filter|
#           puts "Testing #{filter} filter for #{resource}.\n\n"
#           field = filters_map(filter)
#           request = "/v3/#{resource}?per_page=#{per_page}"
#           parsed_response = make_request(request, field)
#           actual_resources = parsed_response.length
#           raise "Expected #{per_page} resources, got #{actual_resources}" unless actual_resources == per_page

#           guid1 = parsed_response[1]
#           guid2 = parsed_response[3]

#           request = "/v3/#{resource}?per_page=#{per_page}&guids=#{guid1},#{guid2}"
#           filtered_resources = make_request(request, field)

#           raise "Expected #{filtered_resources} to not be empty" unless filtered_resources.length
#           raise "Expected #{filtered_resources} to have length 2" unless filtered_resources.length == 2
#           raise "Expected #{filtered_resources} to include #{guid1} and #{guid2}" unless (filtered_resources == [guid1, guid2])
#         end
#       end
#     end

#     def make_request(request, field)
#       p request
#       response, status = Open3.capture2("cf curl '#{request}' | jq .resources[].#{field}")
#       raise response unless status == 0

#       parsed_response = response.split("\n").map { |string| string.tr('\"','') }
#       p parsed_response
#       puts "\n"

#       parsed_response
#     end
#   end
# end

# Main.main
require 'securerandom'

name_suffix = SecureRandom.alphanumeric
output = ARGV[0]

`cat "POST v3/routes\n" >> #{output}`
request = "
    \"host\": \"app-#{name_suffix}\",
    \"path\": \"some_path\",
    \"relationships\": {
      \"domain\": {
        \"data\": { \"guid\": \"40944397-e81b-4fa8-9691-6369ee57ea62\" }
      },
      \"space\": {
        \"data\": { \"guid\": \"0cfa44d0-17d4-4351-b545-3284026360a6\" }
      }
    }"
out = `cf cur -X POST v3/routes -d '{ #{request} }' | .[].guid'`

out = out.split("\n").gsub(\/W/, '')
`cat #{out} >> #{output}`


`cat "GET v3/routes\n" >> #{output}`


