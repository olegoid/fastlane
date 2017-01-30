describe FastlaneCore do
  describe FastlaneCore::XamarinProject do
    describe 'initialize' do
      it 'init type, type_guids, nugets as empty arrays' do
        project = FastlaneCore::XamarinProject.new

        expect(project.type).to eq([])
        expect(project.type_guids).to eq([])
        expect(project.nugets).to eq([])
      end
    end

    describe 'ios?' do
      it 'return true for iOS project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/iOS/iOS.csproj")
        expect(project.ios?).to eq(true)
      end

      it 'return false for !iOS project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/Mac/Mac.csproj")
        expect(project.ios?).to eq(false)
      end
    end

    describe 'tvos?' do
      it 'return true for tvOS project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/tvOS/tvOS.csproj")
        expect(project.tvos?).to eq(true)
      end

      it 'return false for !tvOS project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/Mac/Mac.csproj")
        expect(project.tvos?).to eq(false)
      end
    end

    describe 'mac?' do
      it 'return true for Mac project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/Mac/Mac.csproj")
        expect(project.mac?).to eq(true)
      end

      it 'return false for !Mac project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/tvOS/tvOS.csproj")
        expect(project.mac?).to eq(false)
      end
    end

    describe 'android?' do
      it 'return true for Android project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/Android/Android.csproj")
        expect(project.android?).to eq(true)
      end

      it 'return false for !Android project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/tvOS/tvOS.csproj")
        expect(project.android?).to eq(false)
      end
    end

    describe 'test?' do
      it 'return true for Nunit test library project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/Test/Test.csproj")
        expect(project.test?).to eq(true)
      end

      it 'return false for !Nunit test library project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/tvOS/tvOS.csproj")
        expect(project.test?).to eq(false)
      end
    end

    describe 'ui_test?' do
      it 'return true for Nunit test library project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/Test/Test.csproj")
        expect(project.ui_test?).to eq(true)
      end

      it 'return false for !Nunit test library project' do
        project = FastlaneCore::XamarinProjectParser.parse("./fastlane_core/spec/fixtures/projects/Xamarin/tvOS/tvOS.csproj")
        expect(project.ui_test?).to eq(false)
      end
    end
  end
end
