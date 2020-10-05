puts 'SEEDING STARTED'

puts 'Roles'
Seeds::FillRoles.perform_for %w[admin customer]

puts 'Currencies'
Seeds::FillCurrencies.perform_for [{ code: 'GBP', symbol: '£' }]

puts 'Languages'
Seeds::FillBaseType.perform_for Language, codes: %w[en]

puts 'Tag types'
Seeds::FillBaseType.perform_for TagType, codes: %w[category goes_well attribute ingredient]

puts 'Tag categories'
Seeds::FillTags.perform_for ['Sourdough', 'Whole Wheat', 'Brioche', 'Multigrain', 'Rye', 'Vegan', 'Baguette', 'Gluten Free', 'Ciabatta', 'Keto'],
                            tag_type: TagType.the_category

puts 'Subscription Plans'
Seeds::FillSubscriptionPlans.perform_for [{ price: 29.99, currency: 'GBP' , number_of_items: 10 , number_of_deliveries: 1 },
                                          { price: 61.99, currency: 'GBP' , number_of_items: 10 , number_of_deliveries: 2 },
                                          { price: 114.99, currency: 'GBP' , number_of_items: 10 , number_of_deliveries: 4 }]

puts 'Users'
Seeds::FillUsers.perform_for [{ first_name: 'Martin', last_name: 'Tomas', email: 'martintomas.it@gmail.com', roles: %w[admin], password: 'Br$dd2ě2@12pass' }]

puts 'SEEDING ENDED'
