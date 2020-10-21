# frozen_string_literal: true

namespace :db do
  desc 'Seeding database with demo data'
  task :demo_seed, [] => :environment do
    raise ActiveRecord::ProtectedEnvironmentError, Rails.env if Rails.env.production? && !ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK']

    puts 'SEEDING DEMO DATABASE'

    puts 'Tag attributes'
    Seeds::FillTags.perform_for ['Vegan', 'Gluten free'], tag_type: TagType.the_attribute

    puts 'Tag goes well'
    Seeds::FillTags.perform_for ['Jams', 'Spreads', 'Cured Meat', 'Butter', 'Olive Oil'],
                                tag_type: TagType.the_goes_well

    puts 'Tag ingredients'
    Seeds::FillTags.perform_for ['White Flour', 'Eggs', 'Butter', 'Honey', '7 Grain Cereal', 'Seeds (Poppy, Flax, Sesame)',
                                 'Rye & Bread Flour', 'Sourdough', 'Rolled Oats', 'Maple Syrup'],
                                tag_type: TagType.the_ingredient

    puts 'Producers'
    Seeds::FillProducers.perform_for [{ name: 'The Slice', description: 'Specialize in Sourdough Bread, Nordic Baking, Babka, Brioche Loaf, Gluten-free Bread, Banana Bread, Jams, Spreads.' },
                                      { name: 'Bread & Butter', description: 'Specialize in Sourdough Bread, Nordic Baking, Babka, Brioche Loaf, Gluten-free Bread, Banana Bread, Jams, Spreads.' },
                                      { name: 'Crust & Flake', description: 'Specialize in Sourdough Bread, Nordic Baking, Babka, Brioche Loaf, Gluten-free Bread, Banana Bread, Jams, Spreads.' },
                                      { name: 'Thorough Bread', description: 'Specialize in Sourdough Bread, Nordic Baking, Babka, Brioche Loaf, Gluten-free Bread, Banana Bread, Jams, Spreads.' },
                                      { name: 'Upper Crust Bakery', description: 'Specialize in Sourdough Bread, Nordic Baking, Babka, Brioche Loaf, Gluten-free Bread, Banana Bread, Jams, Spreads.' },
                                      { name: 'Bake Away', description: 'Specialize in Sourdough Bread, Nordic Baking, Babka, Brioche Loaf, Gluten-free Bread, Banana Bread, Jams, Spreads.' },
                                      { name: 'Ron Swanson', description: 'Specialize in Sourdough Bread, Nordic Baking, Babka, Brioche Loaf, Gluten-free Bread, Banana Bread, Jams, Spreads.' },
                                      { name: 'Ted Danson', description: 'Specialize in Sourdough Bread, Nordic Baking, Babka, Brioche Loaf, Gluten-free Bread, Banana Bread, Jams, Spreads.' },
                                      { name: 'Bread Loung', description: 'Specialize in Sourdough Bread, Nordic Baking, Babka, Brioche Loaf, Gluten-free Bread, Banana Bread, Jams, Spreads.' }]

    puts 'Foods'
    Seeds::FillFoods.perform_for [{ name: 'Flaky Honey Brioche', description: 'Put description here', image_detail: 'product-1.png', image_description: 'description-1.png', producer: 'The Slice',
                                    tags: [{ name: 'Brioche', tag_type: TagType.the_category },
                                           { name: 'Vegan', tag_type: TagType.the_attribute },
                                           { name: 'Gluten free', tag_type: TagType.the_attribute },
                                           { name: 'White Flour', tag_type: TagType.the_ingredient },
                                           { name: 'Eggs', tag_type: TagType.the_ingredient },
                                           { name: 'Butter', tag_type: TagType.the_ingredient },
                                           { name: 'Honey', tag_type: TagType.the_ingredient }]},
                                  { name: 'Multigrain Seeded Bread', description: 'Put description here', image_detail: 'product-2.png', image_description: 'description-2.png', producer: 'The Slice',
                                    tags: [{ name: 'Multigrain', tag_type: TagType.the_category },
                                           { name: '7 Grain Cereal', tag_type: TagType.the_ingredient },
                                           { name: 'Seeds (Poppy, Flax, Sesame)', tag_type: TagType.the_ingredient }]},
                                  { name: 'Galician Bread', description: 'Put description here', image_detail: 'product-3.png', image_description: 'description-3.png', producer: 'The Slice',
                                    tags: [{ name: 'Sourdough', tag_type: TagType.the_category },
                                           { name: 'Rye & Bread Flour', tag_type: TagType.the_ingredient },
                                           { name: 'Sourdough', tag_type: TagType.the_ingredient }]},
                                  { name: 'Overnight Rye Bread', description: 'Put description here', image_detail: 'product-4.png', image_description: 'description-4.png', producer: 'Bread & Butter',
                                    tags: [{ name: 'Rye', tag_type: TagType.the_category },
                                           { name: 'Rye & Bread Flour', tag_type: TagType.the_ingredient },
                                           { name: 'Eggs', tag_type: TagType.the_ingredient },
                                           { name: 'Honey', tag_type: TagType.the_ingredient }]},
                                  { name: 'Oatmeal Maple Bread', description: 'Put description here', image_detail: 'product-5.png', image_description: 'description-5.png', producer: 'Bread & Butter',
                                    tags: [{ name: 'Brioche', tag_type: TagType.the_category },
                                           { name: 'Rolled Oats', tag_type: TagType.the_ingredient },
                                           { name: 'White Flour', tag_type: TagType.the_ingredient },
                                           { name: 'Maple Syrup', tag_type: TagType.the_ingredient },
                                           { name: 'Honey', tag_type: TagType.the_ingredient }]}]

    puts 'Producer Applications'
    Seeds::FillProducerApplications.perform_for [{ first_name: 'Super', last_name: 'Baker', email: 'super.baker@gmail.com', phone_number: '123456789',
                                                   tags: [{ name: 'Sourdough', tag_type: TagType.the_category },
                                                          { name: 'Brioche', tag_type: TagType.the_category }]},
                                                 { first_name: 'Poor', last_name: 'Cook', email: 'poor.cook@gmail.com', phone_number: '123456789',
                                                   tags: [{ name: 'Rye', tag_type: TagType.the_category },
                                                          { name: 'Baguette', tag_type: TagType.the_category }]}]

    puts 'Demo Customers'
    Seeds::FillUsers.perform_for [{ first_name: 'Test', last_name: 'Test', email: 'test1@test.test', roles: %w[customer], password: 'testtest' },
                                  { first_name: 'Test2', last_name: 'Test2', email: 'test2@test.test', roles: %w[customer], password: 'testtest' }]

    puts 'Subscriptions'
    Seeds::FillSubscriptions.perform_for [{ subscription_plan: { price: 29.99, currency: 'GBP' }, user: 'test1@test.test', active: true,
                                            periods: [{ started_at: Time.utc(2020, 10, 15), ended_at: Time.utc(2020, 11, 15) }],
                                            payments: [{ currency: 'GBP', price: 29.99 },
                                                       { currency: 'GBP', price: 29.99}]},
                                          { subscription_plan: { price: 61.99, currency: 'GBP' }, user: 'test2@test.test', active: true,
                                            periods: [{ started_at: Time.utc(2020, 10, 15), ended_at: Time.utc(2020, 11, 15) }],
                                            payments: [{ currency: 'GBP', price: 61.99 }]},
                                          { subscription_plan: { price: 114.99, currency: 'GBP' }, user: 'test2@test.test', active: false,
                                            periods: [{ started_at: Time.utc(2020, 10, 15), ended_at: Time.utc(2020, 11, 15) }],
                                            payments: [{ currency: 'GBP', price: 114.99 }]}]

    puts 'Orders'
    Seeds::FillOrders.perform_for [{ user: 'test1@test.test', delivery_date: Time.utc(2020, 10, 17),
                                     states: %i[on_way],
                                     address: { address_type: AddressType.the_personal, address_line: 'Address Line', street: 'Street', city: 'London', postal_code: '1234560', state: 'GB' },
                                     foods: [{ name: 'Flaky Honey Brioche', amount: 5 },
                                             { name: 'Multigrain Seeded Bread', amount: 3 },
                                             { name: 'Oatmeal Maple Bread', amount: 2 }]},
                                   { user: 'test1@test.test', delivery_date: Time.utc(2020, 10, 15),
                                     address: { address_type: AddressType.the_personal, address_line: 'Address Line', street: 'Street', city: 'London', postal_code: '1234560', state: 'GB' },
                                     states: %i[on_way delivered],
                                     foods: [{ name: 'Overnight Rye Bread', amount: 5 },
                                             { name: 'Galician Bread', amount: 5 }]},
                                   { user: 'test2@test.test', delivery_date: Time.utc(2020, 10, 15),
                                     address: { address_type: AddressType.the_personal, address_line: 'Address Line', street: 'Street', city: 'London', postal_code: '1234560', state: 'GB' },
                                     states: %i[on_way delivered],
                                     foods: [{ name: 'Flaky Honey Brioche', amount: 2 },
                                             { name: 'Galician Bread', amount: 5 },
                                             { name: 'Oatmeal Maple Bread', amount: 2 },
                                             { name: 'Multigrain Seeded Bread', amount: 1 }]},
                                   { user: 'test2@test.test', delivery_date: Time.utc(2020, 10, 18),
                                     address: { address_type: AddressType.the_personal, address_line: 'Address Line', street: 'Street', city: 'London', postal_code: '1234560', state: 'GB' },
                                     states: %i[],
                                     surprises: [{ tag: { name: 'Sourdough', tag_type: TagType.the_category }, amount: nil },
                                                 { tag: { name: 'Gluten free', tag_type: TagType.the_attribute }, amount: 2 }],
                                     foods: [{ name: 'Overnight Rye Bread', amount: 3 },
                                             { name: 'Oatmeal Maple Bread', amount: 7 }]}]

    puts 'DEMO DATABASE HAS BEEN SEEDED'
  end
end
