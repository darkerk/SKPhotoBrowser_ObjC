#
# Be sure to run `pod lib lint SKPhotoBrowser_ObjC.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SKPhotoBrowser_ObjC'
  s.version          = '1.0.0'
  s.summary          = 'SKPhotoBrowser written by Objective-c.'
  s.homepage         = 'https://github.com/darkerk/SKPhotoBrowser_ObjC'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'darkerk' => 'appwgh@gmail.com' }
  s.source           = { :git => 'https://github.com/darkerk/SKPhotoBrowser_ObjC.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'

  s.source_files = 'SKPhotoBrowser_ObjC/Classes/*.{h,m}'
  s.resource     = 'SKPhotoBrowser_ObjC/Assets/SKPhotoBrowser.bundle'

  s.public_header_files = 'SKPhotoBrowser_ObjC/Classes/*.h'
  s.frameworks = 'UIKit'
end
