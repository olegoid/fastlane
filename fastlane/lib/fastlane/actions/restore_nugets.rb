module Fastlane
  module Actions
    class RestoreNugets < Action
      def self.run(options)
        UI.message("Restoring Nuget packages")

        Open3.popen3("nuget restore #{File.dirname(options[:solution_path])}") do |_, stdout, _, wait_thr|
          stdout.each do |line|
            print line if options[:verbose]
          end
        end
      end

      def self.description
        "Restores Nuget packages"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :solution_path,
                                       env_name: "FL_NUGET_SOLUTION_PATH",
                                       description: "Path to solution file whe you would like to restore Nuget packages",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_NUGET_VERBOSE",
                                       description: "If set to true action will print out Nuget log",
                                       optional: true)
        ]
      end

      def self.category
        :xamarin
      end

      def self.author
        "olegoid"
      end

      def self.is_supported?(platform)
        [ :xamarin ].include?(platform)
      end

      def self.example_code
        [
            'restore_nugets(
              solution_path: "../Solution.sln",
              verbose: true
            )'
        ]
      end
    end
  end
end
