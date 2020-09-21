class Seeds::FillBaseType
  def self.perform_for(klass, codes:)
    codes.each do |code|
      next if klass.where(code: code).exists?

      puts "#{klass.name}: #{code}"
      klass.create! code: code
    end
  end
end
