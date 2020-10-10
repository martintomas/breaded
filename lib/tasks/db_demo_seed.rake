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

    puts 'DEMO DATABASE HAS BEEN SEEDED'
  end
end
