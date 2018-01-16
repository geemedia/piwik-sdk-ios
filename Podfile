source 'https://github.com/CocoaPods/Specs.git'

abstract_target :example do
  use_frameworks!
  inhibit_all_warnings!
  workspace 'PiwikTracker'

  target :ios do
    platform :ios, '9.1'
    project 'Example/ios/ios'
    pod 'PiwikTracker', path: './'
  end

  target :macos do
    platform :osx, '10.12'
    project 'Example/macos/macos'
    pod 'PiwikTracker', path: './'
  end

  target :tvos do
    platform :tvos, '10.2'
    project 'Example/tvos/tvos'
    pod 'PiwikTracker', path: './'
  end

end

target 'PiwikTrackerTests' do
  use_frameworks!
  platform :ios, '9.1'
  inhibit_all_warnings!
  workspace 'PiwikTracker'
  inherit! :search_paths
  
  pod 'Quick', '~> 1.1'
  pod 'Nimble', '~> 7.0'
end
