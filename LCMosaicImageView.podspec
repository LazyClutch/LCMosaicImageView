Pod::Spec.new do |s|
  s.name     = 'LCMosaicImageView'
  s.version  = '1.0'
  s.license  = 'MIT'
  s.summary  = 'Sources of LCMosaicImageView and Demo app to show mosaic UIImageView.'
  s.homepage = 'https://github.com/LazyClutch/LCMosaicImageView'
  s.author   = { 'Lazy Clutch' => 'lr_5146@163.com' }
  s.source   = { :git => 'https://github.com/LazyClutch/LCMosaicImageView.git', :tag => '1.0' }
  s.platform = :ios, '6.0'
  s.source_files = 'LCMosaicImageView/LCMosaicImageView.{h,m}'
  s.frameworks = 'UIKit', 'CoreGraphics', 'Foundation'
  s.requires_arc = true
end