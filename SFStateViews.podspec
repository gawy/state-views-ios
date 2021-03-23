Pod::Spec.new do |s|

  s.name         = "SFStateViews"
  s.version      = "0.0.2"
  s.summary      = "State Views."

  s.homepage     = "http://dev.stanfy.com"
  s.license      = 'MIT'

  s.author       = { "Paul Taykalo" => "ptaykalo@stanfy.com.ua" }

  s.source       = { :git => "ssh://git@dev.stanfy.com:8822/state-views-ios.git" }

  s.platform     = :ios, '5.0'

  s.source_files = '*.{h,m}', 'Categories/*{h,m}'
  s.requires_arc = true

end