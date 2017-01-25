module Fastlane
  module Actions
    class RestoreXamarinComponentsAction < Action
      def self.run(options)
        components_exe = xamarin_components_exe

        delete_xamarin_cookiejar

        login_cmd = []
        login_cmd << ["mono #{components_exe} login"]

        login_cmd << (options[:username]).to_s if options[:username]
        login_cmd << "-password=#{options[:password]}" if options[:password]
        login_cmd << "-production"

        # User can prompted to enter password.
        Actions.sh(login_cmd.join(' '))

        restore_components_cmd = []
        restore_components_cmd << ["mono #{components_exe} restore"]

        if options[:solution_path]
          restore_components_cmd << (options[:solution_path]).to_s
        else
          config = {}
          FastlaneCore::XamarinSolution.detect_solutions(config)
          restore_components_cmd << (config[:xamarin_solution]).to_s
        end

        Fastlane::Action.sh(restore_components_cmd.join(' '), print_command_output: options[:verbose])
      end

      def self.description
        "Restores Xamarin Components"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :solution_path,
                                       env_name: "FL_XCOMPONENTS_SOLUTION_PATH",
                                       description: "Path to solution file where you would like to restore Xamarin Components",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find Xamarin solution") unless File.exist?(value) || Helper.test?
                                       end),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_XCOMPONENTS_USERNAME",
                                       description: "Xamarin Components Store username",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_XCOMPONENTS_PASSWORD",
                                       description: "Xamarin Components Store password",
                                       optional: false,
                                       sensitive: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_XCOMPONENTS_VERBOSE",
                                       description: "If set to true action will print out components restore log",
                                       is_string: false,
                                       default_value: true)
        ]
      end

      # delete .xamarin-credentials file if exist
      def self.delete_xamarin_cookiejar
        xamarin_credentials = File.join(ENV["HOME"], ".xamarin-credentials")
        File.delete(xamarin_credentials) if File.exist?(xamarin_credentials)
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
          'restore_xamarin_components(
            solution_path: "../Solution.sln",
            username: "xamarin.user@gmail.com",
            password: "1234"
            verbose: true
          )'
        ]
      end

      def self.xamarin_components_exe
        # Download xpkg
        x_components_zip_path = File.join(Dir.tmpdir, 'xpkg.zip')
        x_components_zip_url = "https://components.xamarin.com/submit/xpkg"

        File.open(x_components_zip_path, 'wb') do |saved_file|
          open(x_components_zip_url, 'rb') do |read_file|
            saved_file.write(read_file.read)
          end
        end

        extract_path = Dir.tmpdir
        extract_zip(x_components_zip_path, extract_path)

        return File.join(extract_path, 'xamarin-component.exe')
      end

      def self.extract_zip(file, destination)
        FileUtils.mkdir_p(destination)

        Zip::File.open(file) do |zip_file|
          zip_file.each do |f|
            fpath = File.join(destination, f.name)
            zip_file.extract(f, fpath) unless File.exist?(fpath)
          end
        end
      end
    end
  end
end
