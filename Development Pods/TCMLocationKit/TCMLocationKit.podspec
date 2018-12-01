#
# Be sure to run `pod lib lint TCMLocation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TCMLocationKit'
  s.version          = '0.1.2'
  s.summary          = 'Method library based on Baidu positioning and encapsulation.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description       = <<-DESC
                        Method library based on Baidu positioning and encapsulation.
                        DESC

  s.homepage         = 'https://github.com/T0421/TCMLocationKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dao' => 'cilike@sina.cn' }
  s.source           = { :git => 'https://github.com/T0421/TCMLocationKit.git', :tag => "v#{s.version.to_s}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  
  s.source_files = 'TCMLocationKit/*'

  # s.resource_bundles = {
  #   'TCMLocation' => ['TCMLocationKit/Assets/*.png']
  # }

#   s.public_header_files = 'TCMLocationKit/*.h'
   s.vendored_frameworks = "TCMLocationKit/Frameworks/*.framework"
   s.frameworks = "CoreLocation", "Foundation", "UIKit", "SystemConfiguration", "AdSupport", "Security", "CoreTelephony"
   s.libraries = "sqlite3.0","stdc++.6.0.9"
#  s.dependency 'BMKLocationKit', '~> 1.1.0'
#  s.dependency 'MJExtension', '~> 3.0.13'


end
