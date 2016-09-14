# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Rails.env == "development"
  MarketPublication.delete_all

  mp = MarketPublication.new({
    declined_credit_card_batch_keys: {:batch_id=>"", :batch_date=>20000101, :account_number=>0},
    declined_credit_card_batch_size: 10,
    vindicia_batch_size:             10,
    batch_date:                      10.years.ago,
    pub_code:                        "GN",
    gci_unit:                        "9999"
  })

  mp.save
end
