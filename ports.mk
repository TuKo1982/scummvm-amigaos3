# This file contains port specific Makefile rules. It is automatically
# included by the default (main) Makefile.
#

#
# POSIX specific
#
install:
	$(INSTALL) -d "$(DESTDIR)$(bindir)"
	$(INSTALL) -c -m 755 "./$(EXECUTABLE)" "$(DESTDIR)$(bindir)/$(EXECUTABLE)"
	$(INSTALL) -d "$(DESTDIR)$(mandir)/man6/"
	$(INSTALL) -c -m 644 "$(srcdir)/dists/scummvm.6" "$(DESTDIR)$(mandir)/man6/scummvm.6"
	$(INSTALL) -d "$(DESTDIR)$(datarootdir)/pixmaps/"
	$(INSTALL) -c -m 644 "$(srcdir)/icons/scummvm.xpm" "$(DESTDIR)$(datarootdir)/pixmaps/scummvm.xpm"
	$(INSTALL) -d "$(DESTDIR)$(datarootdir)/icons/hicolor/scalable/apps/"
	$(INSTALL) -c -m 644 "$(srcdir)/icons/scummvm.svg" "$(DESTDIR)$(datarootdir)/icons/hicolor/scalable/apps/scummvm.svg"
	$(INSTALL) -d "$(DESTDIR)$(docdir)"
	$(INSTALL) -c -m 644 $(DIST_FILES_DOCS) "$(DESTDIR)$(docdir)"
	$(INSTALL) -d "$(DESTDIR)$(datadir)"
	$(INSTALL) -c -m 644 $(DIST_FILES_THEMES) $(DIST_FILES_ENGINEDATA) "$(DESTDIR)$(datadir)/"
ifdef DYNAMIC_MODULES
	$(INSTALL) -d "$(DESTDIR)$(libdir)/scummvm/"
	$(INSTALL) -c -m 644 $(PLUGINS) "$(DESTDIR)$(libdir)/scummvm/"
endif

install-strip:
	$(INSTALL) -d "$(DESTDIR)$(bindir)"
	$(INSTALL) -c -s -m 755 "./$(EXECUTABLE)" "$(DESTDIR)$(bindir)/$(EXECUTABLE)"
	$(INSTALL) -d "$(DESTDIR)$(mandir)/man6/"
	$(INSTALL) -c -m 644 "$(srcdir)/dists/scummvm.6" "$(DESTDIR)$(mandir)/man6/scummvm.6"
	$(INSTALL) -d "$(DESTDIR)$(datarootdir)/pixmaps/"
	$(INSTALL) -c -m 644 "$(srcdir)/icons/scummvm.xpm" "$(DESTDIR)$(datarootdir)/pixmaps/scummvm.xpm"
	$(INSTALL) -d "$(DESTDIR)$(datarootdir)/icons/hicolor/scalable/apps/"
	$(INSTALL) -c -m 644 "$(srcdir)/icons/scummvm.svg" "$(DESTDIR)$(datarootdir)/icons/hicolor/scalable/apps/scummvm.svg"
	$(INSTALL) -d "$(DESTDIR)$(docdir)"
	$(INSTALL) -c -m 644 $(DIST_FILES_DOCS) "$(DESTDIR)$(docdir)"
	$(INSTALL) -d "$(DESTDIR)$(datadir)"
	$(INSTALL) -c -m 644 $(DIST_FILES_THEMES) $(DIST_FILES_ENGINEDATA) "$(DESTDIR)$(datadir)/"
ifdef DYNAMIC_MODULES
	$(INSTALL) -d "$(DESTDIR)$(libdir)/scummvm/"
	$(INSTALL) -c -s -m 644 $(PLUGINS) "$(DESTDIR)$(libdir)/scummvm/"
endif

uninstall:
	rm -f "$(DESTDIR)$(bindir)/$(EXECUTABLE)"
	rm -f "$(DESTDIR)$(mandir)/man6/scummvm.6"
	rm -f "$(DESTDIR)$(datarootdir)/pixmaps/scummvm.xpm"
	rm -f "$(DESTDIR)$(datarootdir)/icons/hicolor/scalable/apps/scummvm.svg"
	rm -rf "$(DESTDIR)$(docdir)"
	rm -rf "$(DESTDIR)$(datadir)"
ifdef DYNAMIC_MODULES
	rm -rf "$(DESTDIR)$(libdir)/scummvm/"
endif

# Special target to create a application wrapper for Mac OS X

ifdef USE_DOCKTILEPLUGIN

# The NsDockTilePlugIn needs to be compiled in both 32 and 64 bits irrespective of how ScummVM itself is compiled.
# Therefore do not use $(CXXFLAGS) and $(LDFLAGS).

ScummVMDockTilePlugin32.o:
	$(CXX) -mmacosx-version-min=10.6 -arch i386 -O2 -c $(srcdir)/backends/taskbar/macosx/dockplugin/dockplugin.m -o ScummVMDockTilePlugin32.o

ScummVMDockTilePlugin32: ScummVMDockTilePlugin32.o
	$(CXX) -mmacosx-version-min=10.6 -arch i386 -bundle -framework Foundation -framework AppKit -fobjc-link-runtime ScummVMDockTilePlugin32.o -o ScummVMDockTilePlugin32

ScummVMDockTilePlugin64.o:
	$(CXX) -mmacosx-version-min=10.6 -arch x86_64 -O2 -c $(srcdir)/backends/taskbar/macosx/dockplugin/dockplugin.m -o ScummVMDockTilePlugin64.o
	
ScummVMDockTilePlugin64: ScummVMDockTilePlugin64.o
	$(CXX) -mmacosx-version-min=10.6 -arch x86_64 -bundle -framework Foundation -framework AppKit -fobjc-link-runtime ScummVMDockTilePlugin64.o -o ScummVMDockTilePlugin64
	
ScummVMDockTilePlugin: ScummVMDockTilePlugin32 ScummVMDockTilePlugin64
	lipo -create ScummVMDockTilePlugin32 ScummVMDockTilePlugin64 -output ScummVMDockTilePlugin

scummvm.docktileplugin: ScummVMDockTilePlugin
	mkdir -p scummvm.docktileplugin/Contents
	cp $(srcdir)/dists/macosx/dockplugin/Info.plist scummvm.docktileplugin/Contents
	mkdir -p scummvm.docktileplugin/Contents/MacOS
	cp ScummVMDockTilePlugIn scummvm.docktileplugin/Contents/MacOS/
	chmod 644 scummvm.docktileplugin/Contents/MacOS/ScummVMDockTilePlugIn
	
endif

bundle_name = ScummVM.app

ifdef USE_DOCKTILEPLUGIN
bundle: scummvm-static scummvm.docktileplugin
else
bundle: scummvm-static
endif
	mkdir -p $(bundle_name)/Contents/MacOS
	mkdir -p $(bundle_name)/Contents/Resources
	echo "APPL????" > $(bundle_name)/Contents/PkgInfo
	sed -e 's/$$(PRODUCT_BUNDLE_IDENTIFIER)/org.scummvm.scummvm/' $(srcdir)/dists/macosx/Info.plist >$(bundle_name)/Contents/Info.plist
ifdef USE_SPARKLE
	mkdir -p $(bundle_name)/Contents/Frameworks
	cp $(srcdir)/dists/macosx/dsa_pub.pem $(bundle_name)/Contents/Resources/
	rm -rf $(bundle_name)/Contents/Frameworks/Sparkle.framework
	cp -R $(SPARKLEPATH)/Sparkle.framework $(bundle_name)/Contents/Frameworks/
endif
	cp $(srcdir)/icons/scummvm.icns $(bundle_name)/Contents/Resources/
	cp $(DIST_FILES_DOCS) $(bundle_name)/
	cp $(DIST_FILES_THEMES) $(bundle_name)/Contents/Resources/
ifdef DIST_FILES_ENGINEDATA
	cp $(DIST_FILES_ENGINEDATA) $(bundle_name)/Contents/Resources/
endif
	$(srcdir)/devtools/credits.pl --rtf > $(bundle_name)/Contents/Resources/Credits.rtf
	chmod 644 $(bundle_name)/Contents/Resources/*
	cp scummvm-static $(bundle_name)/Contents/MacOS/scummvm
	chmod 755 $(bundle_name)/Contents/MacOS/scummvm
	$(STRIP) $(bundle_name)/Contents/MacOS/scummvm
ifdef USE_DOCKTILEPLUGIN
	mkdir -p $(bundle_name)/Contents/PlugIns
	cp -r scummvm.docktileplugin $(bundle_name)/Contents/PlugIns/
endif

iphonebundle: iphone
	mkdir -p $(bundle_name)
	cp $(srcdir)/dists/iphone/Info.plist $(bundle_name)/
	cp $(DIST_FILES_DOCS) $(bundle_name)/
	cp $(DIST_FILES_THEMES) $(bundle_name)/
ifdef DIST_FILES_ENGINEDATA
	cp $(DIST_FILES_ENGINEDATA) $(bundle_name)/
endif
	$(STRIP) scummvm
	ldid -S scummvm
	chmod 755 scummvm
	cp scummvm $(bundle_name)/ScummVM
	cp $(srcdir)/dists/iphone/icon.png $(bundle_name)/
	cp $(srcdir)/dists/iphone/icon-72.png $(bundle_name)/
	cp $(srcdir)/dists/iphone/Default.png $(bundle_name)/

ios7bundle: iphone
	mkdir -p $(bundle_name)
	awk 'BEGIN {s=0}\
		/<key>CFBundleIcons<\/key>/ {\
			print $$0;\
			print "\t<dict>";\
			print "\t\t<key>CFBundlePrimaryIcon</key>";\
			print "\t\t<dict>";\
			print "\t\t\t<key>CFBundleIconFiles</key>";\
			print "\t\t\t<array>";\
			print "\t\t\t\t<string>AppIcon29x29</string>";\
			print "\t\t\t\t<string>AppIcon40x40</string>";\
			print "\t\t\t\t<string>AppIcon60x60</string>";\
			print "\t\t\t</array>";\
			print "\t\t</dict>";\
			print "\t</dict>";\
			s=2}\
		/<key>CFBundleIcons~ipad<\/key>/ {\
			print $$0;\
			print "\t<dict>";\
			print "\t\t<key>CFBundlePrimaryIcon</key>";\
			print "\t\t<dict>";\
			print "\t\t\t<key>CFBundleIconFiles</key>";\
			print "\t\t\t<array>";\
			print "\t\t\t\t<string>AppIcon29x29</string>";\
			print "\t\t\t\t<string>AppIcon40x40</string>";\
			print "\t\t\t\t<string>AppIcon60x60</string>";\
			print "\t\t\t\t<string>AppIcon76x76</string>";\
			print "\t\t\t\t<string>AppIcon83.5x83.5</string>";\
			print "\t\t\t</array>";\
			print "\t\t</dict>";\
			print "\t</dict>";\
			s=2}\
		/<key>UILaunchImages<\/key>/ {\
			print $$0;\
			print "\t<array>";\
			print "\t\t<dict>";\
			print "\t\t\t<key>UILaunchImageMinimumOSVersion</key>";\
			print "\t\t\t<string>8.0</string>";\
			print "\t\t\t<key>UILaunchImageName</key>";\
			print "\t\t\t<string>LaunchImage-800-Portrait-736h</string>";\
			print "\t\t\t<key>UILaunchImageOrientation</key>";\
			print "\t\t\t<string>Portrait</string>";\
			print "\t\t\t<key>UILaunchImageSize</key>";\
			print "\t\t\t<string>{414, 736}</string>";\
			print "\t\t\t<key>UILaunchImageMinimumOSVersion</key>";\
			print "\t\t\t<string>8.0</string>";\
			print "\t\t\t<key>UILaunchImageName</key>";\
			print "\t\t\t<string>LaunchImage-800-Landscape-736h</string>";\
			print "\t\t\t<key>UILaunchImageOrientation</key>";\
			print "\t\t\t<string>Landscape</string>";\
			print "\t\t\t<key>UILaunchImageSize</key>";\
			print "\t\t\t<string>{414, 736}</string>";\
			print "\t\t\t<key>UILaunchImageMinimumOSVersion</key>";\
			print "\t\t\t<string>8.0</string>";\
			print "\t\t\t<key>UILaunchImageName</key>";\
			print "\t\t\t<string>LaunchImage-800-667h</string>";\
			print "\t\t\t<key>UILaunchImageOrientation</key>";\
			print "\t\t\t<string>Portrait</string>";\
			print "\t\t\t<key>UILaunchImageSize</key>";\
			print "\t\t\t<string>{375, 667}</string>";\
			print "\t\t\t<key>UILaunchImageMinimumOSVersion</key>";\
			print "\t\t\t<string>7.0</string>";\
			print "\t\t\t<key>UILaunchImageName</key>";\
			print "\t\t\t<string>LaunchImage-700-568h</string>";\
			print "\t\t\t<key>UILaunchImageOrientation</key>";\
			print "\t\t\t<string>Portrait</string>";\
			print "\t\t\t<key>UILaunchImageSize</key>";\
			print "\t\t\t<string>{320, 568}</string>";\
			print "\t\t</dict>";\
			print "\t\t<dict>";\
			print "\t\t\t<key>UILaunchImageMinimumOSVersion</key>";\
			print "\t\t\t<string>7.0</string>";\
			print "\t\t\t<key>UILaunchImageName</key>";\
			print "\t\t\t<string>LaunchImage-700-Portrait</string>";\
			print "\t\t\t<key>UILaunchImageOrientation</key>";\
			print "\t\t\t<string>Portrait</string>";\
			print "\t\t\t<key>UILaunchImageSize</key>";\
			print "\t\t\t<string>{768, 1024}</string>";\
			print "\t\t</dict>";\
			print "\t\t<dict>";\
			print "\t\t\t<key>UILaunchImageMinimumOSVersion</key>";\
			print "\t\t\t<string>7.0</string>";\
			print "\t\t\t<key>UILaunchImageName</key>";\
			print "\t\t\t<string>LaunchImage-700-Landscape</string>";\
			print "\t\t\t<key>UILaunchImageOrientation</key>";\
			print "\t\t\t<string>Landscape</string>";\
			print "\t\t\t<key>UILaunchImageSize</key>";\
			print "\t\t\t<string>{768, 1024}</string>";\
			print "\t\t</dict>";\
			print "\t</array>";\
			s=2}\
		s==0 {print $$0}\
		s > 0 { s-- }' $(srcdir)/dists/ios7/Info.plist >$(bundle_name)/Info.plist
	sed -i'' -e 's/$$(PRODUCT_BUNDLE_IDENTIFIER)/org.scummvm.scummvm/' $(bundle_name)/Info.plist
	cp $(DIST_FILES_DOCS) $(bundle_name)/
	cp $(DIST_FILES_THEMES) $(bundle_name)/
ifdef DIST_FILES_ENGINEDATA
	cp $(DIST_FILES_ENGINEDATA) $(bundle_name)/
endif
	$(STRIP) scummvm
	ldid -S scummvm
	chmod 755 scummvm
	cp scummvm $(bundle_name)/ScummVM
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-29@2x.png $(bundle_name)/AppIcon29x29@2x.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-29@2x.png $(bundle_name)/AppIcon29x29@2x~ipad.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-29@3x.png $(bundle_name)/AppIcon29x29@3x.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-29.png $(bundle_name)/AppIcon29x29~ipad.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-40@2x.png $(bundle_name)/AppIcon40x40@2x.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-40@2x.png $(bundle_name)/AppIcon40x40@2x~ipad.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-40@3x.png $(bundle_name)/AppIcon40x40@3x.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-40.png $(bundle_name)/AppIcon40x40~ipad.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-60@2x.png $(bundle_name)/AppIcon60x60@2x.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-60@3x.png $(bundle_name)/AppIcon60x60@3x.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-76@2x.png $(bundle_name)/AppIcon76x76@2x~ipad.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-76.png $(bundle_name)/AppIcon76x76~ipad.png
	cp $(srcdir)/dists/ios7/Images.xcassets/AppIcon.appiconset/icon4-83.5@2x.png $(bundle_name)/AppIcon83.5x83.5@2x~ipad.png
	cp $(srcdir)/dists/ios7/Images.xcassets/LaunchImage.launchimage/ScummVM-splash-640x1136-1.png $(bundle_name)/LaunchImage-700-568h@2x.png
	cp $(srcdir)/dists/ios7/Images.xcassets/LaunchImage.launchimage/ScummVM-splash-2048x1536.png $(bundle_name)/LaunchImage-700-Landscape@2x~ipad.png
	cp $(srcdir)/dists/ios7/Images.xcassets/LaunchImage.launchimage/ScummVM-splash-1024x768.png $(bundle_name)/LaunchImage-700-Landscape~ipad.png
	cp $(srcdir)/dists/ios7/Images.xcassets/LaunchImage.launchimage/ScummVM-splash-1536x2048.png $(bundle_name)/LaunchImage-700-Portrait@2x~ipad.png
	cp $(srcdir)/dists/ios7/Images.xcassets/LaunchImage.launchimage/ScummVM-splash-768x1024.png $(bundle_name)/LaunchImage-700-Portrait~ipad.png
	cp $(srcdir)/dists/ios7/Images.xcassets/LaunchImage.launchimage/ScummVM-splash-1242x2208.png $(bundle_name)/LaunchImage-800-Portrait-736h@3x.png
	cp $(srcdir)/dists/ios7/Images.xcassets/LaunchImage.launchimage/ScummVM-splash-2208x1242.png $(bundle_name)/LaunchImage-800-Landscape-736h@3x.png
	cp $(srcdir)/dists/ios7/Images.xcassets/LaunchImage.launchimage/ScummVM-splash-750x1334.png $(bundle_name)/LaunchImage-800-667h@2x.png

# Location of static libs for the iPhone
ifneq ($(BACKEND), iphone)
ifneq ($(BACKEND), ios7)
# Static libaries, used for the scummvm-static and iphone targets
OSX_STATIC_LIBS := `$(SDLCONFIG) --static-libs`
endif
endif

ifdef USE_FREETYPE2
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libfreetype.a $(STATICLIBPATH)/lib/libbz2.a
endif

ifdef USE_VORBIS
OSX_STATIC_LIBS += \
		$(STATICLIBPATH)/lib/libvorbisfile.a \
		$(STATICLIBPATH)/lib/libvorbis.a \
		$(STATICLIBPATH)/lib/libogg.a
endif

ifdef USE_TREMOR
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libvorbisidec.a
endif

ifdef USE_FLAC
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libFLAC.a
endif

ifdef USE_FLUIDSYNTH
OSX_STATIC_LIBS += \
                -liconv -framework CoreMIDI -framework CoreAudio\
                $(STATICLIBPATH)/lib/libfluidsynth.a \
                $(STATICLIBPATH)/lib/libglib-2.0.a \
                $(STATICLIBPATH)/lib/libintl.a

ifneq ($(BACKEND), iphone)
ifneq ($(BACKEND), ios7)
OSX_STATIC_LIBS += -lreadline
endif
endif
endif

ifdef USE_MAD
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libmad.a
endif

ifdef USE_PNG
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libpng.a
endif

ifdef USE_THEORADEC
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libtheoradec.a
endif

ifdef USE_FAAD
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libfaad.a
endif

ifdef USE_MPEG2
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libmpeg2.a
endif

ifdef USE_JPEG
OSX_STATIC_LIBS += $(STATICLIBPATH)/lib/libjpeg.a
endif

ifdef USE_ZLIB
OSX_ZLIB ?= $(STATICLIBPATH)/lib/libz.a
endif

ifdef USE_SPARKLE
ifneq ($(SPARKLEPATH),)
OSX_STATIC_LIBS += -F$(SPARKLEPATH)
endif
OSX_STATIC_LIBS += -framework Sparkle -Wl,-rpath,@loader_path/../Frameworks
endif

# Special target to create a static linked binary for Mac OS X.
# We use -force_cpusubtype_ALL to ensure the binary runs on every
# PowerPC machine.
scummvm-static: $(OBJS)
	$(CXX) $(LDFLAGS) -force_cpusubtype_ALL -o scummvm-static $(OBJS) \
		-framework CoreMIDI \
		$(OSX_STATIC_LIBS) \
		$(OSX_ZLIB)

# Special target to create a static linked binary for the iPhone (legacy, and iOS 7+)
iphone: $(OBJS)
	$(CXX) $(LDFLAGS) -o scummvm $(OBJS) \
		$(OSX_STATIC_LIBS) \
		-framework UIKit -framework CoreGraphics -framework OpenGLES \
		-framework CoreFoundation -framework QuartzCore -framework Foundation \
		-framework AudioToolbox -framework CoreAudio -lobjc -lz

# Special target to create a snapshot disk image for Mac OS X
# TODO: Replace AUTHORS by Credits.rtf
osxsnap: bundle
	mkdir ScummVM-snapshot
	$(srcdir)/devtools/credits.pl --text > $(srcdir)/AUTHORS
	cp $(srcdir)/AUTHORS ./ScummVM-snapshot/Authors
	cp $(srcdir)/COPYING ./ScummVM-snapshot/License\ \(GPL\)
	cp $(srcdir)/COPYING.BSD ./ScummVM-snapshot/License\ \(BSD\)
	cp $(srcdir)/COPYING.LGPL ./ScummVM-snapshot/License\ \(LGPL\)
	cp $(srcdir)/COPYING.FREEFONT ./ScummVM-snapshot/License\ \(FREEFONT\)
	cp $(srcdir)/COPYRIGHT ./ScummVM-snapshot/Copyright\ Holders
	cp $(srcdir)/NEWS ./ScummVM-snapshot/News
	cp $(srcdir)/README ./ScummVM-snapshot/ScummVM\ ReadMe
	mkdir ScummVM-snapshot/doc
	cp $(srcdir)/doc/QuickStart ./ScummVM-snapshot/doc/QuickStart
	mkdir ScummVM-snapshot/doc/cz
	cp $(srcdir)/doc/cz/PrectiMe ./ScummVM-snapshot/doc/cz/PrectiMe
	mkdir ScummVM-snapshot/doc/da
	cp $(srcdir)/doc/da/HurtigStart ./ScummVM-snapshot/doc/da/HurtigStart
	mkdir ScummVM-snapshot/doc/de
	cp $(srcdir)/doc/de/Liesmich ./ScummVM-snapshot/doc/de/Liesmich
	cp $(srcdir)/doc/de/Schnellstart ./ScummVM-snapshot/doc/de/Schnellstart
	mkdir ScummVM-snapshot/doc/es
	cp $(srcdir)/doc/es/InicioRapido ./ScummVM-snapshot/doc/es
	mkdir ScummVM-snapshot/doc/fr
	cp $(srcdir)/doc/fr/DemarrageRapide ./ScummVM-snapshot/doc/fr/DemarrageRapide
	mkdir ScummVM-snapshot/doc/it
	cp $(srcdir)/doc/it/GuidaRapida ./ScummVM-snapshot/doc/it/GuidaRapida
	mkdir ScummVM-snapshot/doc/no-nb
	cp $(srcdir)/doc/no-nb/HurtigStart ./ScummVM-snapshot/doc/no-nb/HurtigStart
	mkdir ScummVM-snapshot/doc/se
	cp $(srcdir)/doc/se/LasMig ./ScummVM-snapshot/doc/se/LasMig
	cp $(srcdir)/doc/se/Snabbstart ./ScummVM-snapshot/doc/se/Snabbstart
	$(XCODETOOLSPATH)/SetFile -t ttro -c ttxt ./ScummVM-snapshot/*
	xattr -w "com.apple.TextEncoding" "utf-8;134217984" ./ScummVM-snapshot/doc/cz/*
	xattr -w "com.apple.TextEncoding" "utf-8;134217984" ./ScummVM-snapshot/doc/da/*
	xattr -w "com.apple.TextEncoding" "utf-8;134217984" ./ScummVM-snapshot/doc/de/*
	xattr -w "com.apple.TextEncoding" "utf-8;134217984" ./ScummVM-snapshot/doc/es/*
	xattr -w "com.apple.TextEncoding" "utf-8;134217984" ./ScummVM-snapshot/doc/fr/*
	xattr -w "com.apple.TextEncoding" "utf-8;134217984" ./ScummVM-snapshot/doc/it/*
	xattr -w "com.apple.TextEncoding" "utf-8;134217984" ./ScummVM-snapshot/doc/no-nb/*
	xattr -w "com.apple.TextEncoding" "utf-8;134217984" ./ScummVM-snapshot/doc/se/*
	$(XCODETOOLSPATH)/CpMac -r $(bundle_name) ./ScummVM-snapshot/
	cp $(srcdir)/dists/macosx/DS_Store ./ScummVM-snapshot/.DS_Store
	cp $(srcdir)/dists/macosx/background.jpg ./ScummVM-snapshot/background.jpg
	$(XCODETOOLSPATH)/SetFile -a V ./ScummVM-snapshot/.DS_Store
	$(XCODETOOLSPATH)/SetFile -a V ./ScummVM-snapshot/background.jpg
	hdiutil create -ov -format UDZO -imagekey zlib-level=9 -fs HFS+ \
					-srcfolder ScummVM-snapshot \
					-volname "ScummVM" \
					ScummVM-snapshot.dmg
	rm -rf ScummVM-snapshot

publish-appcast:
	scp dists/macosx/scummvm_appcast.xml www.scummvm.org:/var/www/html/

#
# Windows specific
#

scummvmwinres.o: $(srcdir)/icons/scummvm.ico $(DIST_FILES_THEMES) $(DIST_FILES_ENGINEDATA) $(srcdir)/dists/scummvm.rc
	$(QUIET_WINDRES)$(WINDRES) -DHAVE_CONFIG_H $(WINDRESFLAGS) $(DEFINES) -I. -I$(srcdir) $(srcdir)/dists/scummvm.rc scummvmwinres.o

# Special target to create a win32 snapshot binary (for Inno Setup)
win32dist: $(EXECUTABLE)
	mkdir -p $(WIN32PATH)
	mkdir -p $(WIN32PATH)/graphics
	mkdir -p $(WIN32PATH)/doc
	mkdir -p $(WIN32PATH)/doc/cz
	mkdir -p $(WIN32PATH)/doc/da
	mkdir -p $(WIN32PATH)/doc/de
	mkdir -p $(WIN32PATH)/doc/es
	mkdir -p $(WIN32PATH)/doc/fr
	mkdir -p $(WIN32PATH)/doc/it
	mkdir -p $(WIN32PATH)/doc/no-nb
	mkdir -p $(WIN32PATH)/doc/se
	$(STRIP) $(EXECUTABLE) -o $(WIN32PATH)/$(EXECUTABLE)
	cp $(srcdir)/AUTHORS $(WIN32PATH)/AUTHORS.txt
	cp $(srcdir)/COPYING $(WIN32PATH)/COPYING.txt
	cp $(srcdir)/COPYING.BSD $(WIN32PATH)/COPYING.BSD.txt
	cp $(srcdir)/COPYING.LGPL $(WIN32PATH)/COPYING.LGPL.txt
	cp $(srcdir)/COPYING.FREEFONT $(WIN32PATH)/COPYING.FREEFONT.txt
	cp $(srcdir)/COPYRIGHT $(WIN32PATH)/COPYRIGHT.txt
	cp $(srcdir)/NEWS $(WIN32PATH)/NEWS.txt
	cp $(srcdir)/doc/cz/PrectiMe $(WIN32PATH)/doc/cz/PrectiMe.txt
	cp $(srcdir)/doc/de/Neues $(WIN32PATH)/doc/de/Neues.txt
	cp $(srcdir)/doc/QuickStart $(WIN32PATH)/doc/QuickStart.txt
	cp $(srcdir)/doc/es/InicioRapido $(WIN32PATH)/doc/es/InicioRapido.txt
	cp $(srcdir)/doc/fr/DemarrageRapide $(WIN32PATH)/doc/fr/DemarrageRapide.txt
	cp $(srcdir)/doc/it/GuidaRapida $(WIN32PATH)/doc/it/GuidaRapida.txt
	cp $(srcdir)/doc/no-nb/HurtigStart $(WIN32PATH)/doc/no-nb/HurtigStart.txt
	cp $(srcdir)/doc/da/HurtigStart $(WIN32PATH)/doc/da/HurtigStart.txt
	cp $(srcdir)/doc/de/Schnellstart $(WIN32PATH)/doc/de/Schnellstart.txt
	cp $(srcdir)/doc/se/Snabbstart $(WIN32PATH)/doc/se/Snabbstart.txt
	cp $(srcdir)/README $(WIN32PATH)/README.txt
	cp $(srcdir)/doc/de/Liesmich $(WIN32PATH)/doc/de/Liesmich.txt
	cp $(srcdir)/doc/se/LasMig $(WIN32PATH)/doc/se/LasMig.txt
	cp /usr/local/README-SDL.txt $(WIN32PATH)
	cp /usr/local/bin/SDL.dll $(WIN32PATH)
	cp $(srcdir)/dists/win32/graphics/left.bmp $(WIN32PATH)/graphics
	cp $(srcdir)/dists/win32/graphics/scummvm-install.ico $(WIN32PATH)/graphics
	cp $(srcdir)/dists/win32/migration.bat $(WIN32PATH)
	cp $(srcdir)/dists/win32/migration.txt $(WIN32PATH)
	cp $(srcdir)/dists/win32/ScummVM.iss $(WIN32PATH)
	unix2dos $(WIN32PATH)/*.txt
	unix2dos $(WIN32PATH)/doc/*.txt
	unix2dos $(WIN32PATH)/doc/cz/*.txt
	unix2dos $(WIN32PATH)/doc/da/*.txt
	unix2dos $(WIN32PATH)/doc/de/*.txt
	unix2dos $(WIN32PATH)/doc/es/*.txt
	unix2dos $(WIN32PATH)/doc/fr/*.txt
	unix2dos $(WIN32PATH)/doc/it/*.txt
	unix2dos $(WIN32PATH)/doc/no-nb/*.txt
	unix2dos $(WIN32PATH)/doc/se/*.txt

# Special target to create a win32 NSIS installer
win32setup: $(EXECUTABLE)
	mkdir -p $(srcdir)/$(STAGINGPATH)
	$(STRIP) $(EXECUTABLE) -o $(srcdir)/$(STAGINGPATH)/$(EXECUTABLE)
	cp /usr/local/bin/SDL.dll $(srcdir)/$(STAGINGPATH)
	makensis -V2 -Dtop_srcdir="../.." -Dstaging_dir="../../$(STAGINGPATH)" -Darch=$(ARCH) $(srcdir)/dists/win32/scummvm.nsi


#
# Special target to generate project files for various IDEs
# Mainly Win32-specific
#

# The release branch is in form 'heads/branch-1-4-1', for this case
# $CUR_BRANCH will be equal to '1', for the rest cases it will be empty
CUR_BRANCH := $(shell cd $(srcdir); git describe --all |cut -d '-' -f 4-)

ideprojects: devtools/create_project
ifeq ($(VER_DIRTY), -dirty)
	$(error You have uncommitted changes) 
endif 
ifeq "$(CUR_BRANCH)" "heads/master"
	$(error You cannot do it on master) 
else ifeq "$(CUR_BRANCH)" ""
	$(error You must be on a release branch) 
endif
	@echo Creating Code::Blocks project files...
	@cd $(srcdir)/dists/codeblocks && ../../devtools/create_project/create_project ../.. --codeblocks >/dev/null && git add -f engines/plugins_table.h *.workspace *.cbp
	@echo Creating MSVC9 project files...
	@cd $(srcdir)/dists/msvc9 && ../../devtools/create_project/create_project ../.. --msvc --msvc-version 9 >/dev/null && git add -f engines/plugins_table.h *.sln *.vcproj *.vsprops
	@echo Creating MSVC10 project files...
	@cd $(srcdir)/dists/msvc10 && ../../devtools/create_project/create_project ../.. --msvc --msvc-version 10 >/dev/null && git add -f engines/plugins_table.h *.sln *.vcxproj *.vcxproj.filters *.props
	@echo Creating MSVC11 project files...
	@cd $(srcdir)/dists/msvc11 && ../../devtools/create_project/create_project ../.. --msvc --msvc-version 11 >/dev/null && git add -f engines/plugins_table.h *.sln *.vcxproj *.vcxproj.filters *.props
	@echo Creating MSVC12 project files...
	@cd $(srcdir)/dists/msvc12 && ../../devtools/create_project/create_project ../.. --msvc --msvc-version 12 >/dev/null && git add -f engines/plugins_table.h *.sln *.vcxproj *.vcxproj.filters *.props
	@echo
	@echo All is done.
	@echo Now run
	@echo "\tgit commit -m 'DISTS: Generated Code::Blocks and MSVC project files'"

# Target to create Raspberry Pi zip containig binary and specific README
raspberrypi_dist:
	mkdir -p $(srcdir)/scummvm-rpi
	cp $(srcdir)/backends/platform/sdl/raspberrypi/README.RASPBERRYPI $(srcdir)/scummvm-rpi/README
	cp $(srcdir)/scummvm $(srcdir)/scummvm-rpi
	zip -r scummvm-rpi.zip scummvm-rpi
	rm -f -R scummvm-rpi

# Mark special targets as phony
.PHONY: deb bundle osxsnap win32dist install uninstall
