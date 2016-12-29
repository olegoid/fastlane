module FastlaneCore
  # Represents a Xamarin solution
  class XamarinSolution
    # Project discovery
    class << self
      def detect_projects(config)
        return if config[:xamarin_solution].to_s.length > 0

        if config[:xamarin_solution].to_s.length == 0
          solutions = Dir["./*.sln"]
          if solutions.count > 1
            puts "Select solution: "
            config[:xamarin_solution] = choose(*solutions)
          elsif !solutions.first.nil?
            config[:xamarin_solution] = solutions.first
          end
        end

        return if config[:xamarin_solution].to_s.length > 0

        if config[:xamarin_solution].nil?
          select_project(config)
        end
      end

      def select_project(config)
        loop do
          path = UI.input("Couldn't automatically detect the solution file, please provide a path: ")
          if File.directory? path
            if path.end_with? ".sln"
              config[:xamarin_solution] = path
              break
            else
              UI.error("Path must end with *.sln")
            end
          else
            UI.error("Couldn't find Xamarin solution at path '#{File.expand_path(path)}'")
          end
        end
      end
    end

    REGEX_SOLUTION_PROJECTS = /Project(.*)\nEndProject/
    REGEX_SOLUTION_CONFIGURATION = /GlobalSection\(SolutionConfigurationPlatforms\) = preSolution([\w\s\|\=]*)EndGlobalSection/

    # The config object
    attr_accessor :options

    # Path to the solution
    attr_accessor :path

    # Projects contained by solution
    attr_accessor :projects

    # Build configurations
    attr_accessor :configurations

    def initialize(options)
      self.path = File.expand_path(options[:xamarin_solution])

      if !path or !File.directory?(path)
        UI.user_error!("Could not find solution at path '#{path}'")
      end

      solution_content = File.read(path)
      solution_items = solution_content.scan(REGEX_SOLUTION_PROJECTS)

      if !solution_items or solution_items.captures != nil
        UI.user_error!("Could not find projects referenced in solution at path '#{path}'")
      end

      self.projects = []
      self.configurations = []

      # check what projects are included to the solution
      solution_path = File.dirname(path)
      solution_items.to_a.each {|item|
        ref_info = item.split(',')
        project_path = ref_info[1].strip.delete('\"').gsub('\\') { '/' }
        project_full_path = File.join(solution_path, project_path)

        # skip files that are directories
        accepted_project_types = [".csproj", ".fsproj", "*.shproj"]
        if accepted_project_types.include? File.extname(project_full_path)
          self.projects << XamarinProject.new(project_full_path)
        end
      }

      # parse build configurations
      solution_conf = solution_content.match(REGEX_SOLUTION_CONFIGURATION)
      if solution_conf != nil or solution_conf.captures != nil
        raw_configs = solution_conf.captures.first.split("\r\n\t\t")
        raw_configs.each {|conf_string|
          next if !conf_string or conf_string.to_s.lenght == 0

          conf_string.gsub!(/[\n\t\r]/, '')
          conf_string.delete!(' ')
          conf_parts = item.split('=')
          conf_and_platform = conf_parts.first.split('|')
          self.configurations << { configuration: conf_and_platform[0], platform: conf_and_platform[1] }
        }
      end
    end

    def apple_projects
      l = lambda { |p| p.ios? or p.mac? or p.tvos? }
      self.projects.select &l
    end

    def android_projects
      l = lambda { |p| p.android? }
      self.projects.select &l
    end
  end
end