Pod::Spec.new do |s|
  s.name     = 'LCMosaicImageView'
  s.version  = '0.2.1'
  s.license  = 'MIT'
  s.summary  = 'An UIImageView enables you to add mosaic effect on image or get full mosaic image.'
  s.homepage = 'https://github.com/LazyClutch/LCMosaicImageView'
  s.author   = { 'Lazy Clutch' => 'lr_5146@163.com' }
  s.source   = { :git => 'https://github.com/LazyClutch/LCMosaicImageView.git', :tag => '0.2.1' }
  s.platform = :ios, '6.0'
  s.source_files = 'LCMosaicImageView/LCMosaicImageView.{h,m}'
  s.frameworks = 'UIKit', 'Foundation'
  s.requires_arc = true
end
