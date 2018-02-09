use_frameworks!
platform :ios, '10.0'
inhibit_all_warnings!

abstract_target 'Common' do
  pod 'BSWInterfaceKit', :path => './BSWInterfaceKit.podspec'

  pod 'BSWFoundation', :git => 'https://github.com/BlurredSoftware/BSWFoundation.git', :branch => 'swift-4.1'

  target 'BSWInterfaceKitDemo' do
      target 'BSWInterfaceKitDemoTests' do
          inherit! :search_paths
          pod 'FBSnapshotTestCase'
      end
  end
end
