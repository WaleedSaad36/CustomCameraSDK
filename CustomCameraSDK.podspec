

Pod::Spec.new do |spec|

  spec.name         = "CustomCameraSDK"
  spec.version      = "1.0.0"
  spec.summary      = "Face Detection Framework"
  spec.description  = "Face Detection & face Recognation Framework"

  spec.homepage     = "https://github.com/WaleedSaad36/CustomCameraSDK"
  spec.license      = "MIT"

  spec.author       = { "Waleed Saad" => "Waleed_saad36@yahoo.com" }
  spec.platform     = :ios, "15.0"
  spec.source       = { :git => "https://github.com/WaleedSaad36/CustomCameraSDK.git", :tag => spec.version.to_s }

  spec.source_files  = "CustomCameraSDK/**/*.{swift}"
  spec.swift_versions = "5.0"
end
