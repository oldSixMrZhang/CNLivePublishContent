

Pod::Spec.new do |s|
  s.name             = 'CNLivePublishContent'
  s.version          = '0.1.4'
  s.summary          = '发布二级页面组件化'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://bj.gitlab.cnlive.com/ios-team/CNLivePublishContent'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '殷巧娟' => '1427945373@qq.com' }
  s.source           = { :git => 'http://bj.gitlab.cnlive.com/ios-team/CNLivePublishContent.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  #s.source_files = 'CNLivePublishContent/Classes/**/*'
  
  s.resource_bundles = {
    'CNLivePublishContent' => ['CNLivePublishContent/Assets/CNLivePublishContent.bundle']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.subspec 'View' do |view|
       view.dependency 'CNLiveTripartiteManagement/QMUIKit'
       view.dependency 'CNLiveTripartiteManagement/Masonry'
       view.dependency 'CNLiveTripartiteManagement/SDWebImage'
       view.dependency 'CNLiveBaseKit'
       view.dependency 'CNLivePublishContent/Model'
       view.dependency 'CNLiveCustomUI/CNLiveBasicsUI'
       view.dependency 'CNLiveCommonCategory'
       view.dependency 'CNLiveTripartiteManagement/YYKit'
       view.dependency 'CNLiveImagePickerController'
       view.dependency 'CNLivePublishContent/Common'
       view.source_files = 'CNLivePublishContent/Classes/View/*.{h,m}'
   end
   s.subspec 'Model' do |model|
       model.dependency 'CNLiveTripartiteManagement/MJExtension'
       model.source_files = 'CNLivePublishContent/Classes/Model/*.{h,m}'
    end
   s.subspec 'Controller' do |controller|
       controller.dependency 'CNLiveImagePickerController'
       controller.dependency 'CNLiveSDKs', '~> 0.3.0.1'
       controller.dependency 'CNLivePublishContent/Model'
       controller.dependency 'CNLivePublishContent/View'
       controller.dependency 'CNLiveCommonClass'
       controller.dependency 'CNLiveCommonCategory'
       controller.dependency 'CNLiveBaseKit'
       controller.dependency 'CNLiveTripartiteManagement/QMUIKit'
       controller.dependency 'CNLiveTripartiteManagement/Masonry'
       controller.dependency 'CNLiveTripartiteManagement/YYKit'
       controller.dependency 'CNLiveImagePickerController'
       controller.dependency 'CNLiveBaseTools'
       controller.dependency 'CNLivePublishContent/Common'
       controller.dependency 'CNLiveAVCamera'
       controller.dependency 'CNLiveImagePickerController'
       controller.dependency 'CNLiveRequestBastKit'
       controller.dependency 'CNLivePublishContent/CNLiveQQEmotionManager'
       controller.dependency 'CNLiveEnvironmentConfiguration'
       #controller.dependency 'CNLiveUploadManager'
       controller.source_files = 'CNLivePublishContent/Classes/Controller/*.{h,m}'
    end
   s.subspec 'Common' do |common|
       common.dependency 'CNLiveBaseKit'
       common.dependency 'CNLiveTripartiteManagement/YYKit'
       common.dependency 'CNLiveUserManagement'
       common.source_files = 'CNLivePublishContent/Classes/Common/*.{h,m}'
   end
   s.subspec 'CNLiveQQEmotionManager' do |emotion|
      emotion.dependency 'CNLiveTripartiteManagement/QMUIKit'
      emotion.source_files  = 'CNLivePublishContent/Classes/CNLiveQQEmotionManager/*.{h,m}'
   end
   s.frameworks = 'UIKit', 'Foundation'
end
