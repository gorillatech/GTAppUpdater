#
# Be sure to run `pod lib lint GTAppUpdater.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "GTAppUpdater"
  s.version          = "1.0.5"
  s.summary          = "GTAppUpdater monitors App Versions, Prompts and Forces Updates."


  s.description      = <<-DESC

This library notifies you if a new version of the app is available on the App Store.

DESC

  s.homepage         = "https://github.com/gorillatech/GTAppUpdater"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Gorilla Technologies" => "dev@gorillatech.io" }
  s.source           = { :git => "https://github.com/gorillatech/GTAppUpdater.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'GTAppUpdater' => ['Pod/Assets/*.lproj']
  }

end
