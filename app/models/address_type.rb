class AddressType < BaseType
  has_many :addresses, dependent: :destroy
end
