require 'money/bank/openexchangerates_bank'

MoneyRails.configure do |config|
  moxb = Money::Bank::OpenexchangeratesBank.new
  moxb.access_key = 'ee31c1e170454ae49ad3c149dde3d0de'
  moxb.update_rates

  config.default_bank = moxb
end

OpenExchangeRates.configure do |config|
  config.app_id = 'ee31c1e170454ae49ad3c149dde3d0de'
end
