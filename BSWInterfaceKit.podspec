
Pod::Spec.new do |s|
  s.name         = "BSWInterfaceKit"
  s.version      = "0.4.0"
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
  s.resources     = "Assets/**/*.{xcassets,storyboard,strings}"

  # ――― Dependencies ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.dependency "BSWFoundation", "~> 1.3.0"
  s.dependency "SDWebImage", "~> 4.3.2"
end
