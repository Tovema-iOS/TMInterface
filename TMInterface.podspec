#
# Be sure to run `pod lib lint TMInterface.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TMInterface'
  s.version          = '1.0'
  s.summary          = '接口库'
  s.description      = '接口库，用于管理接口请求'

  s.homepage         = 'https://github.com/Tovema-iOS/TMInterface'
  s.license          = 'MIT'
  s.author           = { 'CodingPub' => 'lxb_0605@qq.com' }
  s.source           = { :git => 'https://github.com/Tovema-iOS/TMInterface.git', :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.dependency 'AFNetworking', '~> 3.1'
  s.dependency 'TMLogger', '~> 1.0'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Pod/Classes/Core/**/*'
  end

  s.subspec 'NetwrokType' do |ss|
    ss.source_files = 'Pod/Classes/NetwrokType/**/*'
    ss.dependency 'AFNetworking/Reachability', '~> 3.1'
  end

end
