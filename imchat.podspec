#
#  Be sure to run `pod spec lint imchat.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "imchat"
  spec.version      = "0.0.1"
  spec.summary      = "test"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
 # spec.description  = <<-DESC
  #                 DESC

  spec.homepage     = "https://github.com/liloutest"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  spec.license      = { type: 'MIT', file: 'LICENSE' }
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = { "Lilou" => "" }
  # Or just: spec.author    = "Lilou"
  # spec.authors            = { "Lilou" => "" }
  # spec.social_media_url   = "https://twitter.com/Lilou"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # spec.platform     = :ios
  spec.platform     = :ios, "12.0"
  spec.ios.deployment_target = '12.0'
  spec.framework = 'UIKit'
  spec.requires_arc = true
  
  spec.pod_target_xcconfig = {'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64', 'VALID_ARCHS[sdk=iphoneos*]' => 'arm64','EXCLUDED_ARCHS[sdk=iphoneos*]' => 'x86_64', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64','BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES','OTHER_LDFLAGS' => '-ObjC','HEADER_SEARCH_PATHS' => ['$(inherited)','$(PODS_ROOT)/Headers/Public','$(SRCROOT)/imchat/**'].join(' ') ,'GCC_PRECOMPILE_PREFIX_HEADER' => 'YES','GCC_PREFIX_HEADER' => '$(PODS_TARGET_SRCROOT)/imchat/Classes/**/*.h','CLANG_ENABLE_MODULES' => 'YES' ,'ONLY_ACTIVE_ARCH' => 'NO'}
  #spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  #spec.user_target_xcconfig = { 'VALID_ARCHS' => 'arm64 x86_64','ARCHS' => '$(ARCHS_STANDARD_64_BIT)'}
    spec.user_target_xcconfig = {
  'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
  'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
}

  #spec.prefix_header_file = "imchat/Classes/Common/Header.h"
  #spec.prefix_header_file = "imchat/Classes/Pages/Chat/ViewController/ZMChatViewController.h"
  spec.prefix_header_contents = <<-EOS
    #import <Foundation/Foundation.h>
    #import <UIKit/UIKit.h>
    #import "Header.h"

  EOS

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"
  # spec.visionos.deployment_target = "1.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source       = { :git => "https://github.com/liloutest/imchat_sdk_native_ios.git" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  #spec.static_framework = true
  #spec.exclude_files = "Classes/Exclude"
  #spec.source_files = 'imchat/Classes/Proto/Msggateway.pbobjc.m'
  #spec.compiler_flags = '-fno-objc-arc'
  
  non_arc_files = 'imchat/Classes/Proto/Msggateway.pbobjc.m'
  spec.exclude_files = non_arc_files
  spec.subspec 'Proto' do | sp |
    sp.source_files = non_arc_files
    sp.requires_arc = false
    sp.dependency 'Protobuf'
  end

  spec.source_files  = ["imchat/Classes/**/*.{m,h}","imchat/Classes/**/**/*.{m,h}","imchat/Classes/Pages/Chat/ViewController/ZMChatViewController.m"]

  #spec.public_header_files = "imchat/*.h"
  #spec.public_header_files = "imchat/Classes/Common/**/*.h"
  spec.public_header_files = [
    'imchat/Classes/**/**/*.h'
  ]

  #spec.dependency 'SocketRocket'
  #spec.dependency 'AFNetworking','4.0.1'
  #spec.dependency 'SocketRocket'
  #spec.dependency 'Protobuf', '~> 3.19'
  
  spec.dependency 'AFNetworking','4.0.1'
  spec.dependency 'SocketRocket'
  spec.dependency 'Protobuf', '~> 3.19'
  spec.dependency 'SDWebImage'
  spec.dependency 'FMDB/SQLCipher'
  spec.dependency 'LKDBHelper'
  spec.dependency 'YYModel'
  spec.dependency 'TTTAttributedLabel'
  spec.dependency 'Masonry'
  spec.dependency 'IQKeyboardManager'
  spec.dependency 'MJRefresh'
  spec.dependency 'TZImagePickerController/Basic'
  spec.dependency 'SVProgressHUD'

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  #spec.resource              = "imchat/**/*.{png,bundle,xib,pdf,json,xcassets,mp3,json,storyboard}"
  #spec.resources = 'imchat/Resource/**/*'
  
  # 资源文件配置
  spec.resource_bundles = {
    'imchat' => [

      # 其他资源
      'imchat/Resource/**/*',
    ]
  }

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
