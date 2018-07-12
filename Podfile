use_frameworks!
platform :ios, '10.0'
inhibit_all_warnings!

target 'BSWInterfaceKitDemo' do
    pod 'BSWInterfaceKit', :path => './BSWInterfaceKit.podspec'
    pod 'BSWFoundation', :git => 'git@github.com:theleftbit/BSWFoundation.git', :tag => '2.0.2'

    target 'BSWInterfaceKitDemoTests' do
        inherit! :search_paths
        pod 'iOSSnapshotTestCase'
    end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
end
