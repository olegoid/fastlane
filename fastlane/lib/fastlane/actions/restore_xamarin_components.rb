module Fastlane
  module Actions
    class RestoreXamarinComponents < Action
      def self.run(options)
        components_exe = xamarin_components_exe
        UI.message("Login to Xamarin Components store")
        system("mono #{components_exe} login #{options[:username]} #{options[:password]}")

        FastlaneCore::UI.message("Restoring Xamarin Components")
        Open3.popen3("mono #{xamarin_components_exe} restore #{options[:solution_path]}") do |_, stdout, _, wait_thr|
          stdout.each do |line|
            print line if options[:verbose]
          end
        end
      end

      def self.description
        "Restores Xamarin Components"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :solution_path,
                                       env_name: "FL_XCOMPONENTS_SOLUTION_PATH",
                                       description: "Path to solution file where you would like to restore Nuget packages",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :solution_path,
                                       env_name: "FL_XCOMPONENTS_USERNAME",
                                       description: "Xamarin Components Store username",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :solution_path,
                                       env_name: "FL_XCOMPONENTS_PASSWORD",
                                       description: "Xamarin Components Store password",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_XCOMPONENTS_VERBOSE",
                                       description: "If set to true action will print out components restore log",
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
