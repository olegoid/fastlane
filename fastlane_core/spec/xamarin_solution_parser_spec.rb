describe FastlaneCore do
  describe FastlaneCore::XamarinSolutionParser do
    describe 'parse' do
      def within_a_temp_dir
        Dir.mktmpdir do |dir|
          FileUtils.cd(dir) do
            yield dir if block_given?
          end
        end
      end

      it 'raises error if solution file was not found' do
        expect do
          FastlaneCore::XamarinSolutionParser.parse("/tmp/notHere123")
        end.to raise_error "Could not find solution at path '/tmp/notHere123'"
      end

      it 'raises error if solution has no referenced projects' do
        within_a_temp_dir do |dir|
          solution = "Solution.sln"
          FileUtils.touch(solution)

          FastlaneCore::XamarinSolutionParser.parse(File.join(dir, solution))
        end
      end

      it 'parses solution configurations' do

      end

      it 'parses projects referenced in solution' do

      end
    end
  end
end