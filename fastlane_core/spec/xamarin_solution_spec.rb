require 'fileutils'

describe FastlaneCore do
  describe FastlaneCore::XamarinSolution do
    describe 'solution file detection' do
      def within_a_temp_dir
        Dir.mktmpdir do |dir|
          FileUtils.cd(dir) do
            yield dir if block_given?
          end
        end
      end

      it 'picks the only solution file present' do
        within_a_temp_dir do |dir|
          solution = "./Solution.sln"
          FileUtils.touch(solution)

          config = {}
          FastlaneCore::XamarinSolution.detect_solutions(config)

          expect(config[:xamarin_solution]).to eq(solution)
        end
      end

      it 'prompts to select among multiple solution files' do
        within_a_temp_dir do |dir|
          solutions = [ "./FirstSolution.sln", "./SecondSolution.sln" ]
          solutions.each { |solution| FileUtils.touch(solution) }

          expect(FastlaneCore::XamarinSolution).to receive(:choose).and_return(solutions.last)
          expect(FastlaneCore::XamarinSolution).not_to receive(:select_solution)

          config = {}
          FastlaneCore::XamarinSolution.detect_solutions(config)

          expect(config[:xamarin_solution]).to eq(solutions.last)
        end
      end

      it 'asks the user to specify a solution when none are found' do
        within_a_temp_dir do |dir|
          solution = "Solution.sln"
          path = 'subdir'

          FileUtils.mkdir_p(path)
          FileUtils.touch(File.join(dir, path, solution))

          expect(FastlaneCore::UI).to receive(:input).and_return(File.join(path, solution))

          config = {}
          FastlaneCore::XamarinSolution.detect_solutions(config)

          expect(config[:xamarin_solution]).to eq(File.join(path, solution))
        end
      end

      it 'explains when a provided path is not found' do
        within_a_temp_dir do |dir|
          solution = "Solution.sln"
          path = 'subdir'

          FileUtils.mkdir_p(path)
          FileUtils.touch(File.join(dir, path, solution))

          expect(FastlaneCore::UI).to receive(:input).and_return("something wrong")
          expect(FastlaneCore::UI).to receive(:error).with(/Couldn't find/)
          expect(FastlaneCore::UI).to receive(:input).and_return(File.join(path, solution))

          config = {}
          FastlaneCore::XamarinSolution.detect_solutions(config)

          expect(config[:xamarin_solution]).to eq(File.join(path, solution))
        end
      end

      it 'explains when a provided path is not valid' do
        within_a_temp_dir do |dir|
          solution = "Solution.sln"
          path = 'subdir'

          FileUtils.mkdir_p(path)
          FileUtils.touch(File.join(dir, path, solution))

          otherFile = "Something.xyz"
          FileUtils.touch(otherFile)

          expect(FastlaneCore::UI).to receive(:input).and_return(otherFile)
          expect(FastlaneCore::UI).to receive(:error).with(/Path must end with/)
          expect(FastlaneCore::UI).to receive(:input).and_return(File.join(path, solution))

          config = {}
          FastlaneCore::XamarinSolution.detect_solutions(config)

          expect(config[:xamarin_solution]).to eq(File.join(path, solution))
        end
      end
    end

    describe 'apple_projects' do
      it "returns only iOS, tvOS, Mac projects referenced to solution" do

      end
    end

    describe 'ios_projects' do
      it "returns only iOS projects referenced to solution" do

      end
    end

    describe 'mac_projects' do
      it "returns only Mac projects referenced to solution" do

      end
    end

    describe 'tvos_projects' do
      it "returns only tvOS projects referenced to solution" do

      end
    end

    describe 'android_projects' do
      it "returns only Android projects referenced to solution" do

      end
    end

    describe 'unit_test_projects' do
      it "returns only Nunit test library projects referenced to solution" do

      end
    end

    describe 'ui_test_projects' do
      it "returns only projects with refrenced Xamarin.UITest package" do

      end
    end
  end
end
