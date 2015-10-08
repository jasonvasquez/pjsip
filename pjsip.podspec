Pod::Spec.new do |s|
  s.name         = "pjsip"
  s.version      = "2.4.5.0"
  s.summary      = "Open Source SIP, Media and NAT Traversal Library."
  s.homepage     = "http://www.pjsip.org"
  s.author       = 'www.pjsip.org'
  s.source       = { :git => "https://github.com/chebur/pjsip.git", :tag => "#{s.version}" }
  s.platform     = :ios, '7.0'
  s.description  = <<-DESC
PJSIP is a free and open source multimedia communication library written in C language implementing standard based protocols such as SIP, SDP, RTP, STUN, TURN, and ICE. It combines signaling protocol (SIP) with rich multimedia framework and NAT traversal functionality into high level API that is portable and suitable for almost any type of systems ranging from desktops, embedded systems, to mobile handsets.

PJSIP is both compact and feature rich. It supports audio, video, presence, and instant messaging, and has extensive documentation. PJSIP is very portable. On mobile devices, it abstracts system dependent features and in many cases is able to utilize the native multimedia capabilities of the device.

PJSIP has been developed by a small team working exclusively for the project since 2005, with participation of hundreds of developers from around the world, and is routinely tested at SIP Interoperability Event (SIPit ) since 2007.
                    DESC
  s.license      = {
     :type => 'Dual-License',
     :text => <<-LICENSE
PJSIP source code ("The Software") is licensed under both General Public License (GPL) version 2 or later and a proprietary license that can be arranged with us. In practical sense, this means:

if you are developing Open Source Software (OSS) based on PJSIP, chances are you will be able to use PJSIP freely under GPL. But please double check here  for OSS license compatibility with GPL.
Alternatively, if you are unable to release your application as Open Source Software, you may arrange alternative licensing with us. Just send your inquiry to licensing@teluu.com to discuss this option.
PJSIP may include third party software in its source code distribution. Third Party Software does not comprise part of "The Software". Please make sure that you comply with the licensing term of each software.
LICENSE
   }

  s.source_files        = 'dist/include/**/*.{h,hpp}'

  s.public_header_files = 'dist/include/**/*.{h,hpp}'

  s.vendored_libraries  = 'dist/lib/*.a'

  s.preserve_paths      = 'dist/**'

  # header_search_paths   = ['"$(PODS_ROOT)/dist/include"']

  s.xcconfig            = {'GCC_PREPROCESSOR_DEFINITIONS' => 'PJ_AUTOCONF=1'}

  s.dependency            'OpenSSL-Universal', '1.0.1.l'
  s.dependency            'CocoaFFmpeg', '2.2.0'
  s.frameworks          = 'CFNetwork', 'AudioToolbox', 'AVFoundation', 'CoreMedia'
  s.libraries           = 'stdc++'
  s.header_mappings_dir = 'dist/include'
  s.requires_arc        = false
end
