puts 'SEEDING STARTED'

puts 'Roles'
Seeds::FillRoles.perform_for %w[admin customer]

puts 'Currencies'
Seeds::FillCurrencies.perform_for [{ code: 'GBP', symbol: '£' }]

puts 'Languages'
Seeds::FillBaseType.perform_for Language, codes: %w[en]

puts 'Order States'
Seeds::FillBaseType.perform_for OrderState, codes: %w[new finalised on_way delivered]

puts 'Tag types'
Seeds::FillBaseType.perform_for TagType, codes: %w[category goes_well attribute ingredient other]

puts 'Tag categories'
Seeds::FillTags.perform_for ['Sourdough', 'Brioche', 'Rye', 'Baguette', 'Ciabatta', 'Whole Wheat',
                             'Multigrain', 'Vegan', 'Gluten Free', 'Keto'],
                            tag_type: TagType.the_category

puts 'Tag others'
Seeds::FillTags.perform_for ['Featured'], tag_type: TagType.the_other

puts 'Address types'
Seeds::FillBaseType.perform_for AddressType, codes: %w[personal friends_home]

puts 'Subscription Plans'
Seeds::FillSubscriptionPlans.perform_for [{ price: 29.99, currency: 'GBP' , number_of_deliveries: 1 },
                                          { price: 61.99, currency: 'GBP', number_of_deliveries: 2 },
                                          { price: 114.99, currency: 'GBP', number_of_deliveries: 4 }]

puts 'Users'
Seeds::FillUsers.perform_for [{ first_name: 'Martin', last_name: 'Tomas', email: 'martintomas.it@gmail.com', roles: %w[admin], password: 'Br$dd2ě2@12pass' }]

puts 'SEEDING ENDED'
