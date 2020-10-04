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

    puts 'DEMO DATABASE HAS BEEN SEEDED'
  end
end
