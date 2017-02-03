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

      it 'raises error if solution file was not found' do

      end

      it 'picks the only solution file present' do

      end

      it 'prompts to select among multiple solution files' do

      end

      it 'asks the user to specify a solution when none are found' do

      end

      it 'explains when a provided path is not found' do

      end

      it 'explains when a provided path is not valid' do

      end

      it "raises an exception if path was not found" do

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
