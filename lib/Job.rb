require_relative 'Helper'
require_relative 'Task'

class Job
	def initialize name, config
		raise 'Job name not passed' unless name.is_a? String
		raise 'Job config not passed' unless config.is_a? Hash

		@name = name
		@config = config
	end

	def process
		log "Processing #{@name}"

		if @config.respond_to? :each
			@config.each { |name, config|
				Task.new(name, config).process
			}
		end
	end
end