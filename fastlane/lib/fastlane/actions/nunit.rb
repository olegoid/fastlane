module Fastlane
  module Actions
    class NunitAction < Action
      def self.run(options)
        xbuild_cmd = []
        xbuild_cmd << 'xbuild /t:Build /p:Configuration=Debug'

        if options[:project_path]
          xbuild_cmd << options[:solution_path]
        else
          config = {}
          FastlaneCore::XamarinSolution.detect_solutions(config)
          xamarin_solution = FastlaneCore::XamarinSolutionParser.parse(config[:xamarin_solution])

          if xamarin_solution.unit_test_projects.length == 0
            UI.user_error!("Not unit test projects found.")
            return
          else
            xbuild_cmd << xamarin_solution.unit_test_projects.first
          end
        end

        Actions.sh(xbuild_cmd.join(' '), print_command_output: options[:verbose])

        test_dll_path = nil
        Find.find(File.dirname(nunit_project.path)) do |path|
          test_dll_path = path if File.basename(path).eql? "#{nunit_project.assembly_name}.dll"
          break unless test_dll_path.nil?
        end

        nunit_cmd = []
        nunit_cmd << 'nunit-console'

        nunit_cmd << '-xmlConsole' if options[:xmlConsole]
        nunit_cmd << '-labels' if options[:labels]
        nunit_cmd << '-noshadow' if options[:noshadow]
        nunit_cmd << '-nothread' if options[:nothread]
        nunit_cmd << '-wait' if options[:wait]
        nunit_cmd << '-nologo' if options[:nologo]
        nunit_cmd << '-nodots' if options[:nodots]

        nunit_cmd << "/fixture:#{options[:fixture]}" if options[:fixture]
        nunit_cmd << "/run:#{options[:run]}" if options[:run]
        nunit_cmd << "/config:#{options[:config]}" if options[:config]
        nunit_cmd << "/xml:#{options[:xml]}" if options[:xml]
        nunit_cmd << "/transform:#{options[:transform]}" if options[:transform]
        nunit_cmd << "/output:#{options[:output]}" if options[:output]
        nunit_cmd << "/err:#{options[:err]}" if options[:err]
        nunit_cmd << "/include:#{options[:include]}" if options[:include]
        nunit_cmd << "/exclude:#{options[:exclude]}" if options[:exclude]
        nunit_cmd << "/domain:#{options[:domain]}" if options[:domain]

        nunit_cmd << test_dll_path

        Actions.sh(nunit_cmd.join(' '), print_command_output: options[:verbose])
      end

      def self.description
        "Builds and runs Nunit tests"
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :project_path,
                                         env_name: "FL_NUNIT_PROJECT_PATH",
                                         description: "Path to an Nunit project",
                                         optional: true,
                                         verify_block: proc do |value|
                                           UI.user_error!("Could not find Xamarin project") unless File.exist?(value) || Helper.test?
                                         end),
            FastlaneCore::ConfigItem.new(key: :fixture,
                                         env_name: "FL_NUNIT_FIXTURE",
                                         description: "Test fixture to be loaded",
                                         optional: true,
                                         is_string: true),
            FastlaneCore::ConfigItem.new(key: :run,
                                         env_name: "FL_NUNIT_RUN",
                                         description: "Name of the test to run",
                                         optional: true,
                                         is_string: true),
            FastlaneCore::ConfigItem.new(key: :config,
                                         env_name: "FL_NUNIT_CONFIG",
                                         description: "Project configuration to load",
                                         optional: true,
                                         is_string: true),
            FastlaneCore::ConfigItem.new(key: :xml,
                                         env_name: "FL_NUNIT_XML",
                                         description: "Name of XML output file",
                                         optional: true,
                                         is_string: true),
            FastlaneCore::ConfigItem.new(key: :transform,
                                         env_name: "FL_NUNIT_TRANSFORM",
                                         description: "Name of transform file",
                                         optional: true,
                                         is_string: true),
            FastlaneCore::ConfigItem.new(key: :xmlConsole,
                                         env_name: "FL_NUNIT_XMLCONSOLE",
                                         description: "Display XML to the console",
                                         optional: true,
                                         is_string: false),
            FastlaneCore::ConfigItem.new(key: :output,
                                         env_name: "FL_NUNIT_OUTPUT",
                                         description: "File to receive test output",
                                         optional: true,
                                         is_string: true),
            FastlaneCore::ConfigItem.new(key: :err,
                                         env_name: "FL_NUNIT_ERR",
                                         description: "File to receive test error output",
                                         optional: true,
                                         is_string: true),
            FastlaneCore::ConfigItem.new(key: :labels,
                                         env_name: "FL_NUNIT_LABELS",
                                         description: "Label each test in stdOut",
                                         optional: true,
                                         is_string: false),
            FastlaneCore::ConfigItem.new(key: :include,
                                         env_name: "FL_NUNIT_INCLUDE",
                                         description: "List of categories to include",
                                         optional: true,
                                         is_string: true),
            FastlaneCore::ConfigItem.new(key: :exclude,
                                         env_name: "FL_NUNIT_EXCLUDE",
                                         description: "List of categories to exclude",
                                         optional: true,
                                         is_string: true),
            FastlaneCore::ConfigItem.new(key: :domain,
                                         env_name: "FL_NUNIT_DOMAIN",
                                         description: "AppDomain Usage for Tests",
                                         optional: true,
                                         is_string: true),
            FastlaneCore::ConfigItem.new(key: :noshadow,
                                         env_name: "FL_NUNIT_NOSHADOW",
                                         description: "Disable shadow copy when running in separate domain",
                                         optional: true,
                                         is_string: false),
            FastlaneCore::ConfigItem.new(key: :nothread,
                                         env_name: "FL_NUNIT_NOTHREAD",
                                         description: "Disable use of a separate thread for tests",
                                         optional: true,
                                         is_string: false),
            FastlaneCore::ConfigItem.new(key: :wait,
                                         env_name: "FL_NUNIT_WAIT",
                                         description: "Wait for input before closing console window",
                                         optional: true,
                                         is_string: false),
            FastlaneCore::ConfigItem.new(key: :nologo,
                                         env_name: "FL_NUNIT_NOLOGO",
                                         description: "Do not display the logo",
                                         optional: true,
                                         is_string: false),
            FastlaneCore::ConfigItem.new(key: :nodots,
                                         env_name: "FL_NUNIT_NODOTS",
                                         description: "Do not display progress",
                                         optional: true,
                                         is_string: false),
            FastlaneCore::ConfigItem.new(key: :verbose,
                                         env_name: "FL_NUNIT_VERBOSE",
                                         description: "If set to true action will print out Nunit log",
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
          'nunit,
           nunit(
            project_path: "../Tests.csproj",
            fixture: "NUnit.Tests.AssertionTests",
            labels: false,
            verbose: true
          )'
        ]
      end
    end
  end
end
