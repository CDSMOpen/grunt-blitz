require 'rubygems'
require 'blitz'
require 'pp'

# Contains a Sprint Result - essentially a PING of a Url and its Default response time
class SprintResult

	# All Sprints should have a duration less than this value to be considered a PASS
	DURATION_THRESHOLD = 1

	attr_accessor :url, :duration

	def initialize (url, duration)
		@url = url
		@duration = duration
	end

	def passed
		return duration < DURATION_THRESHOLD
	end

	def to_s
		url + " => Responded in " + duration.to_s + " :: Url Passed => " + passed.to_s
	end
end

# Contains a Rush Result - essentially a load test of a Url and its response over time
class RushResult

	# All Rush should have a average duration less than this value to be considered a PASS
	DURATION_THRESHOLD = 5
	ISSUE_THRESHOLD = 10

	attr_accessor :url, :duration, :errors, :timeouts, :volume, :hits

	def initialize (url, duration, errors, timeouts, volume, hits)
		@url = url
		@duration = duration
		@errors = errors
		@timeouts = timeouts
		@volume = volume
		@hits = hits
	end

	def avg_duration
		sum = 0
		duration.each { |a| sum+=a }
		return sum / duration.size.to_f
	end

	def avg_volume
		sum = 0
		volume.each { |a| sum+=a }
		return sum / volume.size.to_f
	end

	def passed
		return avg_duration < DURATION_THRESHOLD && (((errors + timeouts).to_f / hits.to_f) * 100) < ISSUE_THRESHOLD
	end

	def to_s
		return url + ", Average Response: " + avg_duration.to_s + ", Average Volumne: " + avg_volume.to_s + ", Total Errors: " + errors.to_s + ", Total Timeouts: " + timeouts.to_s + ", Total Hits: " + hits.to_s + ", Passed: "  + passed.to_s
	end


end

# Describes an application that uses Blitz gem to run Sprints and Rushes against a set of Urls
class App

	attr_accessor :sprintResults, :rushResults, :baseUrl, :targetUrls, :users, :time

	# Constructor method, initialise our internal properties to be default values
	def init ( baseUrl, targetUrls, users, time )
		@baseUrl = baseUrl
		@targetUrls = targetUrls
		@users = users
		@time = time
		@sprintResults = []
		@rushResults = []
	end

	# execute a sprint and rush, fail if there is a threshold breach
	def execute
		@targetUrls.each { |target| 
			
			# Execute the Sprint for this 
			sprint = execute_sprint target
			@sprintResults.push sprint

			# Optionally execute Rush if Sprint passes
			if sprint != nil && sprint.passed
				sleep 5.0
				rush = execute_rush target, @users, @time
				@rushResults.push rush
			end

			sleep 5.0
		}
	end

	def execute_sprint ( target )
		pp "##teamcity[testStarted name='sprint/" + target + "'] "

		url = @baseUrl + target

		sprint = Blitz::Curl.parse('-r ireland -H \'Accept-Encoding: gzip, deflate\' -u a.stark669:passw0rd ' + url)
		sResult = nil

		begin
			sResult = sprint.execute
		rescue Exception=>e
			pp "##teamcity[testFailed name='sprint/" + target + "' message='failed execution of sprint' details='"+ e.to_s + "']"	
		end

		if sResult != nil
			result = SprintResult.new url, sResult.duration

			if result.passed == false
				pp "##teamcity[testFailed name='sprint/" + target + "' message='failed sprint' details='"+ result.to_s + "']"	
			end

			pp "##teamcity[testFinished name='sprint/" + target + "' duration='" + result.duration.to_s + "'] "
			return result
		end

		pp "##teamcity[testFinished name='sprint/" + target + "' duration='unknown'] "

		return result
	end

	def execute_rush ( target, users, time )
		pp "##teamcity[testStarted name='rush/" + target + "'] "

		url = @baseUrl + target
		
		totalHits = 0;
		durations = []
		totalTimeouts = 0
		totalErrors = 0
		volumes = []
		failed = false

		rush = Blitz::Curl.parse('-r ireland -H \'Accept-Encoding: gzip, deflate\' -T 5000 -u a.stark669:passw0rd -p '+ users.to_s + '-' + users.to_s + ':' + time.to_s + ' ' + url)

		begin
			rush.execute do |partial|
				totalHits = totalHits + partial.timeline.last.hits
				durations.push partial.timeline.last.duration
				totalTimeouts = totalTimeouts + partial.timeline.last.timeouts
				totalErrors = totalErrors + partial.timeline.last.errors
				volumes.push partial.timeline.last.volume
			end
		rescue Exception=>e
			failed = true
			pp "##teamcity[testFailed name='rush/" + target + "' message='failed execution of rush' details='" + e.to_s + "']"	
		end

		if failed == false
			result = RushResult.new url, durations, totalErrors, totalTimeouts, volumes, totalHits

			if result.passed == false
				pp "##teamcity[testFailed name='rush/" + target + "' message='failed rush' details='" + result.to_s + "']"	
			end

			pp "##teamcity[testFinished name='rush/" + target + "' duration='" + result.avg_duration.to_s + "'] "
			return result
		end

		pp "##teamcity[testFinished name='rush/" + target + "' duration='unknown'] "

		return result
	end

	# prints out results of the sprints
	def print_sprint_results
		sprintResults.each { |result| 
			pp [ result ] 
		}
	end

	# prints out results of the rushes
	def print_rush_results
		rushResults.each { |result| 
			pp [ result ] 
		}
	end
end

# Set a list of Target APIs
targets = []
targets.push 'api/playlists'

# Create a new application, initialise to the default hosting location, run the sprints and rushes then print the output to the command line
app = App.new

# Parameters are, Base Url, list of relative urls to test, concurrent users to test, time to test
app.init 'https://staging.mylearningspace.org.uk/', targets, 100, 10
app.execute