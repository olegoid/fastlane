module Fastlane
  module Actions
    class XbuildAction < Action
      def self.run(options)
        cmd = []
        cmd << 'xbuild'

        properties_string = ''
        if options[:properties]
          options[:properties].each do |key, value|
            properties_string += "/p:#{key}=#{value} "
          end
        end

        cmd << properties_string if options[:properties]

        target_string = ''
        if options[:target]
          target_string = "/t:#{options[:target]}"
        end

        cmd << target_string if options[:target]
        cmd << options[:project_path] if options[:project_path]

        Fastlane::Action.sh(cmd.join(' '), print_command_output: options[:verbose])
      end

      def self.description
        "Runs xbuild"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project_path,
                                       env_name: "FL_XBUILD_PROJECT_PATH",
                                       description: "Path to a project",
                                       optional: true,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find Xamarin project") unless File.exist?(value) || Helper.test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :target,
                                       env_name: "FL_XBUILD_TARGET",
                                       description: "Xbuild target to run",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :properties,
                                       env_name: "FL_XBUILD_PROPERTIES",
                                       description: "Hash with xbuild properties",
                                       is_string: false, # properties should be provided in Hash format
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_XBUILD_VERBOSE",
                                       description: "If set to true action will print out xbuild log",
                                       is_string: false,
                                       default_value: true)
        ]
      end

      def self.details
        "Multipurpose build engine for .NET projects. If you're going to use it to build *.ipa files don't forget to pass { \"BuildIpa\": true }"
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
          'xbuild,
           xbuild(
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
