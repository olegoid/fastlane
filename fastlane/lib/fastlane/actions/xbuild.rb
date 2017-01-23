module Fastlane
  module Actions
    class Xbuild < Action
      def self.run(options)
        UI.message("Running xbuild")

        properties_string = nil
        if options[:properties]
          hash.each do |key, value|
            properties_string += "/p:#{key}=#{value} "
          end
        end

        target_string = nil
        if options[:target]
          target_string = "/t:#{options[:target]}"
        end

        Open3.popen3("xbuild #{target_string} #{properties_string} #{File.dirname(options[:project_path])}") do |_, stdout, _, wait_thr|
          stdout.each do |line|
            print line if options[:verbose]
          end
        end
      end

      def self.description
        "Runs xbuild with given parameters(target, properties, project)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project_path,
                                       env_name: "FL_XBUILD_PROJECT_PATH",
                                       description: "Path to a project",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :target,
                                       env_name: "FL_XBUILD_TARGET",
                                       description: "Xbuild target to run",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :properties,
                                       env_name: "FL_XBUILD_PROPERTIES",
                                       description: "Hash with xbuild properties",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_XBUILD_VERBOSE",
                                       description: "If set to true action will print out xbuild log",
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
        [:xamarin].include?(platform)
      end

      def self.example_code
        [
          'xbuild(
            project_path: "../Project.csproj",
            target: "Build",
            properties: { "BuildIpa": true },
            verbose: true
          )'
        ]
      end
    end
  end
end
