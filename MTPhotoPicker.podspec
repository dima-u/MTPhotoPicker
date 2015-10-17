#
# Be sure to run `pod lib lint MTPhotoPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MTPhotoPicker"
  s.version          = "0.1.1"
  s.summary          = "iMessage style photopicker with visual effects."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
PhotoPicker allows you to integrate imessage style photo selection view in a several lines of code
                       DESC

  s.homepage         = "https://github.com/dima-u/MTPhotoPicker"
  s.screenshots     = "https://raw.githubusercontent.com/dima-u/MTPhotoPicker/master/Screenshots/example.gif"
  s.license          = 'MIT'
  s.author           = { "Ulyanov Dmitry" => "dima-u@inbox.ru" }
  s.source           = { :git => "https://github.com/dima-u/MTPhotoPicker.git", :tag =>'0.1.1'}  #:commit => "2df51c0dc20ca88a7716978312533dd8098c3f3f" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = ['Pod/Classes/**/*']
  s.resources = ['Pod/Assets/**/*']
#  s.resource_bundles = {
#    'MTPhotoPicker' => ['Pod/Assets/*.png']#,'Pod/Assets/*.xib']
#  }

end
