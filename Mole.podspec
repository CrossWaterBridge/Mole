Pod::Spec.new do |s|
  s.name                  = "Mole"
  s.version               = "2.0.0"
  s.summary               = "Xcode’s UI testing is black-box by design. This works around that."
  s.author                = 'Hilton Campbell'
  s.homepage              = "https://github.com/CrossWaterBridge/Mole"
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.source                = { :git => "https://github.com/CrossWaterBridge/Mole.git", :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files          = 'Mole/*.swift'
  s.requires_arc          = true
  
  s.dependency 'Swifter' #:git => 'https://github.com/httpswift/swifter.git', :branch => 'stable'
end
