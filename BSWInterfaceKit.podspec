
Pod::Spec.new do |s|
  s.name         = "BSWInterfaceKit"
  s.version      = "1.0.0"
  s.summary      = "A short description of BSWInterfaceKit."
  s.homepage     = "https://github.com/TheLeftBit/BSWInterfaceKit"
  s.license      = "MIT"
  s.author             = { "Pierluigi Cifani" => "pcifani@theleftbit.com" }
  s.social_media_url   = "http://twitter.com/piercifani"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "9.0"
  s.swift_version = "4.1"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/TheLeftBit/BSWInterfaceKit.git", :tag => "#{s.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "Source/**/*.{swift,m,h}"
  s.resource_bundle = { "BSWInterfaceKit" => "Assets/**/*.{xcassets,storyboard,strings}" }

  # ――― Dependencies ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.dependency "BSWFoundation", "~> 2.0.2"
  s.dependency "SDWebImage", "~> 4.4.1"
end
