# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create(email: 'k@gmail.com', password: 'k12345678')

%W(Mansons Farsham Panafrica Crown Panafrica\ Logistics Midland\ Hauliers Blue\ Jay).each do |transporter|
  Vendor.create!(name: transporter)
end
