require 'eu_central_bank'

namespace :eu_central_bank do
  desc 'Cache all available historical exchange rates from ECB'
  task cache_all_rates: :environment do
    eu_bank = EuCentralBank.new
    cache_file = Rails.root.join('tmp', 'eu_central_bank_rates.xml')

    puts 'Fetching all available historical rates...'
    eu_bank.update_historical_rates(nil, true) # Use the all=true option to fetch all historical data

    puts 'Saving rates to cache file...'
    eu_bank.save_rates(cache_file)

    puts "Done caching rates to #{cache_file}"
  end
end
