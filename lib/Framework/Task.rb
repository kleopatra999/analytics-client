class Task
	@@known_modules = %w(
		Flurry
		GTMetrix
		GoogleAnalytics
	)

	def initialize(name, config)
		@name = name
		@config = config
		@data = false

		@format = @config['format'] ? @config['format'].capitalize : 'Csv'
		@output_class = @format + 'Output'

		@output = @config['output'] ? @config['output'] : @name
	end

	def process
		type = @config['type']
		$log.info "\tCurrent Task: #{@name}"
		$log.debug "\tData source: #{type}"

		#Dynamically load needed files for fetchers
		begin
			require_relative "../#{type}/#{type}"
		rescue LoadError => details
			$log.fatal "\tFetcher file not found - #{details.message}"
			return 0
		end

		#Dynamically load needed files for Output classes
		begin
			require_relative "../Output/#{@output_class}"
		rescue LoadError => details
			$log.fatal "\tOutput class not found - #{details.message}"
			return 0
		end

		begin
			output = Object.const_get( @output_class ).new( @output )

			Object.const_get( type ).new( @config['config'] ).fetch( lambda {|data, prefix = ''|
				if data
					output.save data, prefix
				else
					$log.error "\t\t No data fetched"
				end
			})
		rescue => detail
			$log.error "\t\t'#{type}' fetcher encountered a problem or does not exist"
			$log.error "\t\t\t#{detail}"
			$log.debug detail.backtrace.join("\r\n")
			return 0
		end


	end
end