#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'openinstall_flutter'
  s.version          = '1.0.0'
  s.summary          = 'OpenInstall Flutter Plugin'
  s.description      = <<-DESC
设备指纹匹配 + 延迟深度链接 Flutter 插件
                       DESC
  s.homepage         = 'https://github.com/yourusername/openinstall-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end


