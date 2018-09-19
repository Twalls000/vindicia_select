class AppConfig < ActiveRecord::Base
	validates :key, uniqueness: true, presence: true

	def self.get_config(key, default_value=nil)
		config = where(key: key)[0]
		config.nil? ? default_value.to_s : config.value.to_s
	end
end
