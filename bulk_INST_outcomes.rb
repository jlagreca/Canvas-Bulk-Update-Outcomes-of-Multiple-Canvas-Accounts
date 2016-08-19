require 'csv'
require 'typhoeus'
require 'json'
#------------------Replace these values-----------------------------#

access_token = ''
#url = 'https://callaghan.instructure.com' #Enter the full URL to the domain you want to merge files.
csv_file = 'domains.csv' #needs one column with url as heading and the subdomain listed per row

#-------------------Do not edit below this line---------------------#
# First column is user account that will be merged into second column. #



	hydra = Typhoeus::Hydra.new(max_concurrency: 20)

	CSV.foreach(csv_file, {headers: true}) do |row|
		url = "https://#{row['url']}.instructure.com"

	
	for i in 1..22000 do

		#api_call_1 = "#{url}/api/v1/accounts/1/outcome_group_links?per_page=30&page=#{i}"

		api_call_1 = "#{url}/api/v1/outcomes/#{i}"

		first_api = Typhoeus::Request.new(api_call_1, headers: { "Authorization" => "Bearer #{access_token}" })

		first_api.on_complete do |first_reponder|

			if first_reponder.code == 200

			response = JSON.parse(first_reponder.body)


				guid = response['vendor_guid']
				outcome_id = response['id']
			
				
				if !guid.nil?
					
					puts guid

					api_call = "#{url}/api/v1/outcomes/#{outcome_id}?ratings[][description]=A&ratings[][points]=5&ratings[][description]=B&ratings[][points]=4&ratings[][description]=C&ratings[][points]=3&ratings[][description]=D&ratings[][points]=2&ratings[][description]=E&ratings[][points]=1"

								outcomes_api = Typhoeus::Request.new(api_call, 
																method: :put,  
																headers: { "Authorization" => "Bearer #{access_token}" })
								outcomes_api.on_complete do |new_response|
									

									if new_response.code == 200
											puts "Outcome #{outcome_id} in #{row['url']} has been fixed with custom scale" 
									else
											puts "Unable to update outcome #{outcome_id} in #{row['url']}. Check to verify this outcome exists with correct ID."
									end

								
									
								end
								
								hydra.queue(outcomes_api)
								hydra.run


			else

				

			end
		


end

end

			hydra.queue(first_api)
			hydra.run

end

end

puts 'Successfully updated all outcomes.'
