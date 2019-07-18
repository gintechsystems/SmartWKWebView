#
# Be sure to run `pod lib lint SmartWKWebView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SmartWKWebView'
  s.version          = '0.1.1'
  s.summary          = 'A WKWebView modal. Written in Swift'
  s.description      = 'A WKWebView modal to show web pages.'
  s.homepage         = 'https://github.com/barisatamer/SmartWKWebView'
  s.screenshots      = 'https://github.com/barisatamer/SmartWKWebView/blob/master/imgs/demo.gif?raw=true'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'barisatamer' => 'brsatamer@gmail.com' }
  s.source           = { :git => 'https://github.com/barisatamer/SmartWKWebView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'SmartWKWebView/Classes/*.{h,m,swift}'

  s.resources = ['SmartWKWebView/Assets/*.{png}', 'SmartWKWebView/Classes/*.{xib}']

  s.swift_version = '5.0'
end
