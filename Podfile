use_frameworks!
platform :ios, '10.0'
inhibit_all_warnings!

abstract_target 'Common' do
  pod 'BSWInterfaceKit', :path => './BSWInterfaceKit.podspec'
  pod 'BSWFoundation', '1.4.0'

  target 'BSWInterfaceKitDemo' do
      target 'BSWInterfaceKitDemoTests' do
          inherit! :search_paths
          pod 'FBSnapshotTestCase'
      end
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
        end
    end
end

