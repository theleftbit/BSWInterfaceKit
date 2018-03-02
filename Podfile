use_frameworks!
platform :ios, '10.0'
inhibit_all_warnings!

abstract_target 'Common' do
  pod 'BSWInterfaceKit', :path => './BSWInterfaceKit.podspec'

  target 'BSWInterfaceKitPlayground'
  target 'BSWInterfaceKitDemo'
  target 'BSWInterfaceKitDemoTests' do
      inherit! :search_paths
      pod 'FBSnapshotTestCase'
  end
end

