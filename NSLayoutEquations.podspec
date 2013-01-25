#
# Be sure to run `pod spec lint NSLayoutEquations.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "NSLayoutEquations"
  s.version      = "0.1"
  s.summary      = "Make NSLayoutConstraint as easy as y = mx + b"
  s.description  = <<-DESC
                    Seriously: it's just y=mx+b. So why does the average NSLayoutConstraint take 200-odd characters to initialise?
                    
                    Adds two new methods:
                    * +[NSLayoutConstraint constraintWithFormula:LHS:RHS:]
                    * -[UIView constrain:to:]
                    
                    Make auto layout as simple as a sentence.
                   DESC
  s.homepage     = "https://github.com/gormster/NSLayoutEquations"

  # Specify the license type. CocoaPods detects automatically the license file if it is named
  # `LICEN{C,S}E*.*', however if the name is different, specify it.
  s.license      = 'MIT'

  # Specify the authors of the library, with email addresses. You can often find
  # the email addresses of the authors by using the SCM log. E.g. $ git log
  #
  s.author       = { "gormster" => "gormster@me.com" }

  # Specify the location from where the source should be retrieved.
  #
  s.source       = { :git => "https://github.com/gormster/NSLayoutEquations.git", :commit => "8bec99fb423e3681ff2a84b8c63c488e7fca1818" }

  # If this Pod runs only on iOS or OS X, then specify the platform and
  # the deployment target.
  #
  s.platform     = :ios, '6.0'

  # A list of file patterns which select the source files that should be
  # added to the Pods project. If the pattern is a directory then the
  # path will automatically have '*.{h,m,mm,c,cpp}' appended.
  #
  # Alternatively, you can use the FileList class for even more control
  # over the selected files.
  # (See http://rake.rubyforge.org/classes/Rake/FileList.html.)
  #
  s.source_files = 'NSLayoutConstraint+Equations.{h,m}'

  # A list of file patterns which select the header files that should be
  # made available to the application. If the pattern is a directory then the
  # path will automatically have '*.h' appended.
  #
  # Also allows the use of the FileList class like `source_files' does.
  #
  # If you do not explicitly set the list of public header files,
  # all headers of source_files will be made public.
  #
  s.public_header_files = 'NSLayoutConstraint+Equations.h'

  # If this Pod uses ARC, specify it like so.
  #
  s.requires_arc = true

end
