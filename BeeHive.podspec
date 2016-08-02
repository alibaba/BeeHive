
Pod::Spec.new do |s|

  s.name         = "BeeHive"
  s.version      = "1.0.0"
  s.summary      = "BeeHive is a kind of modular programming method"

  s.description  = <<Developer can use BeeHive make iOS programming easier

  s.homepage     = "https://github.com/alibaba/BeeHive/"

  s.license      = "GPL"

  s.author       = { "soxeon" => "dpsopower@gmail.com" }

  s.source       = { :git => "https://github.com/alibaba/BeeHive.git", :tag => "#{s.version}" }

  s.source_files = 'BeeHive/*.{h,m}'
  s.resource = 'BeeHive/*.bundle'

end
