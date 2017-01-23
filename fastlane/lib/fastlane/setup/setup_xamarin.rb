module Fastlane
  class SetupXamarin < Setup
    # the tools that are already enabled
    attr_accessor :tools
    attr_accessor :xamarin_solution
    attr_accessor :xamarin_project
    attr_accessor :apple_id

    attr_accessor :portal_ref
    attr_accessor :itc_ref

    attr_accessor :dev_portal_team
    attr_accessor :itc_team

    attr_accessor :app_identifier
    attr_accessor :app_name

    def run
      show_infos

      FastlaneCore::FastlaneFolder.create_folder! unless Helper.is_test?
      is_manual_setup = false

      begin
        setup_project
        ask_for_apple_id
        detect_if_app_is_available
        print_config_table
        if UI.confirm("Please confirm the above values")
          default_setup
        else
          is_manual_setup = true
          manual_setup
        end
        UI.success('Successfully finished setting up fastlane')
      rescue => ex # this will also be caused by Ctrl + C
        if is_manual_setup
          handle_exception(exception: ex)
        else
          UI.error(ex.to_s)
          UI.error('An error occurred during the setup process. Falling back to manual setup!')
          try_manual_setup
        end
      end
    end

    def handle_exception(exception: nil)
      # Something went wrong with the setup, clear the folder again
      # and restore previous files
      UI.error('Error occurred with the setup program! Reverting changes now!')
      restore_previous_state
      raise exception
    end

    def try_manual_setup
      manual_setup
    rescue => ex
      handle_exception(exception: ex)
    end

    def print_config_table
      rows = []
      rows << ["Apple ID", self.apple_id]
      rows << ["App Name", self.app_name]
      rows << ["App Identifier", self.app_identifier]
      rows << [self.project.path]
      require 'terminal-table'
      puts ""
      puts Terminal::Table.new(rows: rows, title: "Detected Values")
      puts ""

      unless self.itc_ref
        UI.important "This app identifier doesn't exist on iTunes Connect yet, it will be created for you"
      end

      unless self.portal_ref
        UI.important "This app identifier doesn't exist on the Apple Developer Portal yet, it will be created for you"
      end
    end

    def show_infos
      UI.success('This setup will help you get up and running in no time.')
      UI.success("fastlane will check what tools you're already using and set up")
      UI.success('the tool automatically for you. Have fun! ')
    end

    def setup_project
      config = {}
      FastlaneCore::XamarinSolution.detect_solutions(config)
      self.xamarin_solution = FastlaneCore::XamarinSolution.new(config)

      if self.xamarin_solution.apple_projects.lenght > 1
        # User Selection
        loop do
          # Multiple apple projects(iOS, Mac, tvOS) found in solution, user has to select
          UI.important "Multiple projects found in your solution, please enter the number of the project you want to configure:"

          self.xamarin_solution.apple_projects.each_with_index do |project, i|
            puts "#{i + 1}) #{project.name}"
          end

          selected = ($stdin.gets || '').strip.to_i - 1
          self.xamarin_project = self.xamarin_solution.apple_projects[selected] if selected >= 0
          return if self.xamarin_project
        end
      end

      self.app_identifier = self.xamarin_project.default_app_identifier
      self.app_name = self.xamarin_project.default_app_name
    end

    def ask_for_apple_id
      self.apple_id ||= UI.input("Your Apple ID (e.g. fastlane@krausefx.com): ")
    end

    # Detect if the app was created on the Dev Portal & iTunes Connect
    def detect_if_app_is_available
      require 'spaceship'

      UI.important "Verifying if app is available on the Apple Developer Portal and iTunes Connect..."
      UI.message "Starting login with user '#{self.apple_id}'"
      Spaceship.login(self.apple_id, nil)
      self.dev_portal_team = Spaceship.select_team
      self.portal_ref = Spaceship::App.find(self.app_identifier)

      Spaceship::Tunes.login(@apple_id, nil)
      self.itc_team = Spaceship::Tunes.select_team
      self.itc_ref = Spaceship::Application.find(self.app_identifier)
    end

    def generate_appfile(manually: false)
      template = File.read("#{Fastlane::ROOT}/lib/assets/AppfileTemplate")
      if manually
        ask_for_app_identifier
        ask_for_apple_id
      end

      template.gsub!('[[DEV_PORTAL_TEAM_ID]]', self.dev_portal_team) if self.dev_portal_team

      itc_team = self.itc_team ? "itc_team_id \"#{self.itc_team}\" # iTunes Connect Team ID\n" : ""
      template.gsub!('[[ITC_TEAM]]', itc_team)

      template.gsub!('[[APP_IDENTIFIER]]', self.app_identifier)
      template.gsub!('[[APPLE_ID]]', self.apple_id)

      path = File.join(folder, 'Appfile')
      File.write(path, template)
      UI.success("Created new file '#{path}'. Edit it to manage your preferred app metadata information.")
    end

    def files_to_copy
      ['Deliverfile', 'deliver', 'screenshots', 'metadata']
    end

    def copy_existing_files
      files_to_copy.each do |current|
        current = File.join(File.expand_path('..', FastlaneCore::FastlaneFolder.path), current)
        next unless File.exist?(current)
        file_name = File.basename(current)
        to_path = File.join(folder, file_name)
        UI.success("Moving '#{current}' to '#{to_path}'")
        FileUtils.mv(current, to_path)
      end
    end

    def folder
      FastlaneCore::FastlaneFolder.path
    end

    def default_setup
      copy_existing_files # create backup of the project before doing any changes
      generate_appfile(manually: true)
      detect_installed_tools # after copying the existing files
      ask_to_enable_other_tools
      generate_fastfile(manually: true)
      # show_analytics
    end

    def manual_setup
    end

    def restore_previous_state
    end

    def detect_installed_tools
      self.tools = {}
      # TODO: add nuget, xamarin-packages, Xamarin.UITest actions here
    end

    def ask_to_enable_other_tools
      if self.itc_ref.nil? && self.portal_ref.nil?
        wants_to_create_app = agree('Would you like to create your app on iTunes Connect and the Developer Portal? (y/n)', true)
        if wants_to_create_app
          create_app_if_necessary
          detect_if_app_is_available # check if the app was, in fact, created.
        end
      end
      if self.itc_ref && self.portal_ref
        wants_to_setup_deliver = agree("Do you want to setup 'deliver', which is used to upload app screenshots, app metadata and app updates to the App Store? This requires the app to be in the App Store already. (y/n)".yellow, true)
        enable_deliver if wants_to_setup_deliver
      end
    end

    def create_app_if_necessary
      UI.important "Creating the app on iTunes Connect and the Apple Developer Portal"
      require 'produce'

      produce_options_hash = {
          app_name: self.xamarin_project.default_app_name,
          app_identifier: self.app_identifier
      }
      Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, produce_options_hash)
      begin
        ENV['PRODUCE_APPLE_ID'] = Produce::Manager.start_producing
      rescue => exception
        if exception.to_s.include?("The App Name you entered has already been used")
          UI.important("It looks like that #{project.app_name} has already been taken by someone else, please enter an alternative.")
          Produce.config[:app_name] = UI.input("App Name: ")
          Produce.config[:skip_devcenter] = true # since we failed on iTC
          ENV['PRODUCE_APPLE_ID'] = Produce::Manager.start_producing
        end
      end
    end

    def enable_deliver
      UI.message("Loading up 'deliver', this might take a few seconds")
      require 'deliver'
      require 'deliver/setup'
      options = FastlaneCore::Configuration.create(Deliver::Options.available_options, {})
      Deliver::Runner.new(options) # to login...
      Deliver::Setup.new.run(options)
    end

    def generate_fastfile(manually: false)
      build_configuration = self.xamarin_solution.configurations.first unless manually

      template = File.read("#{Fastlane::ROOT}/lib/assets/DefaultXamarinFastfileTemplate")
    end
  end
end
