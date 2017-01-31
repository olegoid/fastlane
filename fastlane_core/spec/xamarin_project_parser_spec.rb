describe FastlaneCore do
  describe FastlaneCore::XamarinProjectParser do
    describe 'parse' do
      def within_a_temp_dir
        Dir.mktmpdir do |dir|
          FileUtils.cd(dir) do
            yield dir if block_given?
          end
        end
      end

      it 'raises error if project file was not found' do
        within_a_temp_dir do |dir|
          expect do
            FastlaneCore::XamarinProjectParser.parse('XYZ.csproj')
          end.to raise_error "Could not find project at path 'XYZ.csproj'"
        end
      end

      it 'parses name of *.csproj(C#) files correctly' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/iOS/iOS.csproj")
        expect(project.name).to eq("iOS")
      end

      it 'parses name of *.fsproj(F#) files correctly' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/iOS_FSharp/iOS_FSharp.fsproj")
        expect(project.name).to eq("iOS_FSharp")
      end

      it 'parses name of *.shproj(shared) projects correctly' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/Shared/Shared.shproj")
        expect(project.name).to eq("Shared")
      end

      it 'shows user error if project file is malformed' do
        expect do
          FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/Malformed/Malformed.csproj")
        end.to raise_error 'Project at path "./fastlane_core/spec/fixtures/projects/Xamarin/Malformed/Malformed.csproj" is malformed'
      end

      it 'parses project type guids correctly' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/iOS/iOS.csproj")
        expect(project.type_guids).to eq([ "FEACFBD2-3405-455C-9665-78FE426C6842", "FAE04EC0-301F-11D3-BF4B-00C04F79EFBC" ])
      end

      it 'parses project output type correctly' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/iOS/iOS.csproj")
        expect(project.output_type).to eq("Exe")
      end

      it 'parses project assembly name correctly' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/iOS/iOS.csproj")
        expect(project.assembly_name).to eq("iOS")
      end

      it 'parses NuGet packages list correctly' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/iOS/iOS.csproj")
        expect(project.nugets).to eq(["Newtonsoft.Json"])
      end
    end
  end
end