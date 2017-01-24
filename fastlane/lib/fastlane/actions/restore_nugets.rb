module Fastlane
  module Actions
    class RestoreNugetsAction < Action
      def self.run(options)
        cmd = []

        unless options[:solution_path].nil?
          if options[:solution_path].end_with?('.sln')
            solution_folder = File.dirname(options[:solution_path])
          else
            solution_folder = options[:podfile]
          end
          cmd << ["cd '#{solution_folder}' &&"]
        end

        cmd << ['nuget restore']

        Fastlane::Action.sh(cmd.join(' '), print_command_output: options[:verbose])
      end

      def self.description
        "Runs `nuget restore` for the solution"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :solution_path,
                                       env_name: "FL_NUGET_SOLUTION_PATH",
                                       description: "Path to solution file where you would like to restore Nuget packages",
                                       optional: true,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find solution file") unless File.exist?(value) || Helper.test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_NUGET_VERBOSE",
                                       description: "If set to true action will print out Nuget log",
                                       is_string: false,
                                       default_value: true)
        ]
      end

      def self.category
        :xamarin
      end

      def self.author
        "olegoid"
      end

      def self.is_supported?(platform)
        [:xamarin].include?(platform)
      end

      def self.example_code
        [
          'restore_nugets,
           restore_nugets(
            solution_path: "../Solution.sln",
            verbose: false
          )'
        ]
      end
    end
  end
end
