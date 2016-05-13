
Pod::Spec.new do |s|
  s.name         = "BSWInterfaceKit"
  s.version      = "0.0.1"
  s.summary      = "A short description of BSWInterfaceKit."
  s.homepage     = "https://github.com/BlurredSoftware/BSWInterfaceKit"
  s.license      = "MIT"
  s.author             = { "Pierluigi Cifani" => "pcifani@blurredsoftware.com" }
  s.social_media_url   = "http://twitter.com/piercifani"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.platform     = :ios, "9.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/BlurredSoftware/BSWInterfaceKit.git", :tag => "#{s.version}" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = "Source/**/*.{swift,m,h}"
  s.resources     = "Assets/**/*.{xcassets,storyboard}"

  # ――― Dependencies ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.dependency "BSWFoundation"
  s.dependency "PINRemoteImage"
  s.dependency "Cartography"
  s.dependency "DZNEmptyDataSet"

end
