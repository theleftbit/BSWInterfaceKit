use_frameworks!

abstract_target 'Common' do
  pod 'BSWInterfaceKit', :path => './BSWInterfaceKit.podspec'

  target 'BSWInterfaceKitPlayground'
  target 'BSWInterfaceKitDemo'
  target 'BSWInterfaceKitDemoTests' do
      inherit! :search_paths
      pod 'FBSnapshotTestCase'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
      config.build_settings['SWIFT_VERSION'] = "3.1"
      if target.name == 'BNRDeferred'
          config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = "$(inherited) DEBUG"
      end
    end
  end
end
