def run(command)
  system(command) or raise "RAKE TASK FAILED: #{command}"
end

namespace "build" do
  desc "Updates the build version to show current git version"
  task :update_version do |t|
    version = `git describe --always`.strip
    run "/usr/libexec/PlistBuddy -c 'Set CFBundleShortVersionString #{version}' Apartment/Info.plist"
    run "/usr/libexec/PlistBuddy -c 'Set CFBundleShortVersionString #{version}' WatchApp\\ Extension/Info.plist"
    puts "bumped to version #{version}"
  end
end

namespace "test" do
  desc "Run all the tests"
  task :all do |t|
    run "set -o pipefail && xcodebuild -project Apartment.xcodeproj -scheme Apartment -destination 'platform=iOS Simulator,name=iPhone 6s' clean test | xcpretty -c"
  end
end

task :test => ["test:all"]

task default: ["test"]
