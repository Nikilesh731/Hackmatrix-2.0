ambient_ai_scribe/
├── backend/
│   ├── prisma/
│   │   └── schema.prisma
│   ├── src/
│   │   ├── config/
│   │   │   ├── database.ts
│   │   │   └── prisma.service.ts
│   │   ├── modules/
│   │   │   ├── auth/
│   │   │   │   ├── dto/
│   │   │   │   │   └── login.dto.ts
│   │   │   │   ├── auth.controller.ts
│   │   │   │   ├── auth.module.ts
│   │   │   │   └── auth.service.ts
│   │   │   ├── consultations/
│   │   │   │   ├── dto/
│   │   │   │   │   ├── create_consultation.dto.ts
│   │   │   │   │   └── update_consultation.dto.ts
│   │   │   │   ├── consultations.controller.ts
│   │   │   │   ├── consultations.module.ts
│   │   │   │   └── consultations.service.ts
│   │   │   ├── fhir/
│   │   │   │   └── fhir.module.ts
│   │   │   ├── health/
│   │   │   │   ├── health.controller.ts
│   │   │   │   └── health.module.ts
│   │   │   ├── prescriptions/
│   │   │   │   └── prescriptions.module.ts
│   │   │   ├── referrals/
│   │   │   │   └── referrals.module.ts
│   │   │   ├── soap/
│   │   │   │   └── soap.module.ts
│   │   │   └── transcription/
│   │   │       ├── sarvam.service.ts
│   │   │       └── transcription.module.ts
│   │   ├── websocket/
│   │   │   ├── consultation.gateway.ts
│   │   │   └── websocket.module.ts
│   │   ├── app.module.ts
│   │   └── main.ts
│   ├── .env
│   ├── package-lock.json
│   ├── package.json
│   └── tsconfig.json
├── mobile_app/
│   ├── .idea/
│   │   ├── libraries/
│   │   │   ├── Dart_SDK.xml
│   │   │   └── KotlinJavaRuntime.xml
│   │   ├── runConfigurations/
│   │   │   └── main_dart.xml
│   │   ├── modules.xml
│   │   └── workspace.xml
│   ├── android/
│   │   ├── app/
│   │   │   ├── src/
│   │   │   │   ├── debug/
│   │   │   │   │   └── AndroidManifest.xml
│   │   │   │   ├── main/
│   │   │   │   │   ├── java/
│   │   │   │   │   │   └── io/
│   │   │   │   │   │       └── flutter/
│   │   │   │   │   │           └── plugins/
│   │   │   │   │   │               └── GeneratedPluginRegistrant.java
│   │   │   │   │   ├── kotlin/
│   │   │   │   │   │   └── com/
│   │   │   │   │   │       └── example/
│   │   │   │   │   │           └── mobile_app/
│   │   │   │   │   │               └── MainActivity.kt
│   │   │   │   │   ├── res/
│   │   │   │   │   │   ├── drawable/
│   │   │   │   │   │   │   └── launch_background.xml
│   │   │   │   │   │   ├── drawable-v21/
│   │   │   │   │   │   │   └── launch_background.xml
│   │   │   │   │   │   ├── mipmap-hdpi/
│   │   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   │   ├── mipmap-mdpi/
│   │   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   │   ├── mipmap-xhdpi/
│   │   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   │   ├── mipmap-xxhdpi/
│   │   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   │   ├── mipmap-xxxhdpi/
│   │   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   │   ├── values/
│   │   │   │   │   │   │   └── styles.xml
│   │   │   │   │   │   └── values-night/
│   │   │   │   │   │       └── styles.xml
│   │   │   │   │   └── AndroidManifest.xml
│   │   │   │   └── profile/
│   │   │   │       └── AndroidManifest.xml
│   │   │   └── build.gradle.kts
│   │   ├── gradle/
│   │   │   └── wrapper/
│   │   │       ├── gradle-wrapper.jar
│   │   │       └── gradle-wrapper.properties
│   │   ├── .gitignore
│   │   ├── build.gradle.kts
│   │   ├── gradle.properties
│   │   ├── gradlew
│   │   ├── gradlew.bat
│   │   ├── local.properties
│   │   ├── mobile_app_android.iml
│   │   └── settings.gradle.kts
│   ├── ios/
│   │   ├── Flutter/
│   │   │   ├── ephemeral/
│   │   │   │   ├── flutter_lldb_helper.py
│   │   │   │   └── flutter_lldbinit
│   │   │   ├── AppFrameworkInfo.plist
│   │   │   ├── Debug.xcconfig
│   │   │   ├── flutter_export_environment.sh
│   │   │   ├── Generated.xcconfig
│   │   │   └── Release.xcconfig
│   │   ├── Runner/
│   │   │   ├── Assets.xcassets/
│   │   │   │   ├── AppIcon.appiconset/
│   │   │   │   │   ├── Contents.json
│   │   │   │   │   ├── Icon-App-1024x1024@1x.png
│   │   │   │   │   ├── Icon-App-20x20@1x.png
│   │   │   │   │   ├── Icon-App-20x20@2x.png
│   │   │   │   │   ├── Icon-App-20x20@3x.png
│   │   │   │   │   ├── Icon-App-29x29@1x.png
│   │   │   │   │   ├── Icon-App-29x29@2x.png
│   │   │   │   │   ├── Icon-App-29x29@3x.png
│   │   │   │   │   ├── Icon-App-40x40@1x.png
│   │   │   │   │   ├── Icon-App-40x40@2x.png
│   │   │   │   │   ├── Icon-App-40x40@3x.png
│   │   │   │   │   ├── Icon-App-60x60@2x.png
│   │   │   │   │   ├── Icon-App-60x60@3x.png
│   │   │   │   │   ├── Icon-App-76x76@1x.png
│   │   │   │   │   ├── Icon-App-76x76@2x.png
│   │   │   │   │   └── Icon-App-83.5x83.5@2x.png
│   │   │   │   └── LaunchImage.imageset/
│   │   │   │       ├── Contents.json
│   │   │   │       ├── LaunchImage.png
│   │   │   │       ├── LaunchImage@2x.png
│   │   │   │       ├── LaunchImage@3x.png
│   │   │   │       └── README.md
│   │   │   ├── Base.lproj/
│   │   │   │   ├── LaunchScreen.storyboard
│   │   │   │   └── Main.storyboard
│   │   │   ├── AppDelegate.swift
│   │   │   ├── GeneratedPluginRegistrant.h
│   │   │   ├── GeneratedPluginRegistrant.m
│   │   │   ├── Info.plist
│   │   │   ├── Runner-Bridging-Header.h
│   │   │   └── SceneDelegate.swift
│   │   ├── Runner.xcodeproj/
│   │   │   ├── project.xcworkspace/
│   │   │   │   ├── xcshareddata/
│   │   │   │   │   ├── IDEWorkspaceChecks.plist
│   │   │   │   │   └── WorkspaceSettings.xcsettings
│   │   │   │   └── contents.xcworkspacedata
│   │   │   ├── xcshareddata/
│   │   │   │   └── xcschemes/
│   │   │   │       └── Runner.xcscheme
│   │   │   └── project.pbxproj
│   │   ├── Runner.xcworkspace/
│   │   │   ├── xcshareddata/
│   │   │   │   ├── IDEWorkspaceChecks.plist
│   │   │   │   └── WorkspaceSettings.xcsettings
│   │   │   └── contents.xcworkspacedata
│   │   ├── RunnerTests/
│   │   │   └── RunnerTests.swift
│   │   └── .gitignore
│   ├── lib/
│   │   ├── app/
│   │   │   ├── app.dart
│   │   │   ├── routes.dart
│   │   │   └── theme.dart
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   │   └── app_constants.dart
│   │   │   ├── models/
│   │   │   │   ├── consultation_model.dart
│   │   │   │   ├── prescription_model.dart
│   │   │   │   ├── referral_model.dart
│   │   │   │   ├── soap_note_model.dart
│   │   │   │   └── transcript_turn_model.dart
│   │   │   ├── services/
│   │   │   │   ├── api_service.dart
│   │   │   │   ├── audio_service.dart
│   │   │   │   └── websocket_service.dart
│   │   │   └── widgets/
│   │   │       ├── app_scaffold.dart
│   │   │       └── loading_view.dart
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   │   └── screens/
│   │   │   │       └── login_screen.dart
│   │   │   ├── consultation/
│   │   │   │   ├── controllers/
│   │   │   │   │   └── consultation_controller.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── consultation_repository.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── consultation_screen.dart
│   │   │   │   │   ├── live_notes_screen.dart
│   │   │   │   │   └── live_transcript_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── soap_preview_card.dart
│   │   │   │       └── transcript_panel.dart
│   │   │   ├── dashboard/
│   │   │   │   └── screens/
│   │   │   │       └── dashboard_screen.dart
│   │   │   ├── patients/
│   │   │   │   └── screens/
│   │   │   │       └── patient_list_screen.dart
│   │   │   └── post_consultation/
│   │   │       ├── controllers/
│   │   │       │   └── review_controller.dart
│   │   │       └── screens/
│   │   │           ├── fhir_preview_screen.dart
│   │   │           ├── prescription_screen.dart
│   │   │           ├── referral_screen.dart
│   │   │           └── review_screen.dart
│   │   ├── shared/
│   │   │   ├── enums/
│   │   │   │   └── consultation_status.dart
│   │   │   └── helpers/
│   │   │       └── formatters.dart
│   │   └── main.dart
│   ├── linux/
│   │   ├── flutter/
│   │   │   ├── ephemeral/
│   │   │   │   └── .plugin_symlinks/
│   │   │   │       ├── flutter_secure_storage_linux/
│   │   │   │       ├── path_provider_linux/
│   │   │   │       └── record_linux/
│   │   │   ├── CMakeLists.txt
│   │   │   ├── generated_plugin_registrant.cc
│   │   │   ├── generated_plugin_registrant.h
│   │   │   └── generated_plugins.cmake
│   │   ├── runner/
│   │   │   ├── CMakeLists.txt
│   │   │   ├── main.cc
│   │   │   ├── my_application.cc
│   │   │   └── my_application.h
│   │   ├── .gitignore
│   │   └── CMakeLists.txt
│   ├── macos/
│   │   ├── Flutter/
│   │   │   ├── ephemeral/
│   │   │   │   ├── flutter_export_environment.sh
│   │   │   │   └── Flutter-Generated.xcconfig
│   │   │   ├── Flutter-Debug.xcconfig
│   │   │   ├── Flutter-Release.xcconfig
│   │   │   └── GeneratedPluginRegistrant.swift
│   │   ├── Runner/
│   │   │   ├── Assets.xcassets/
│   │   │   │   └── AppIcon.appiconset/
│   │   │   │       ├── app_icon_1024.png
│   │   │   │       ├── app_icon_128.png
│   │   │   │       ├── app_icon_16.png
│   │   │   │       ├── app_icon_256.png
│   │   │   │       ├── app_icon_32.png
│   │   │   │       ├── app_icon_512.png
│   │   │   │       ├── app_icon_64.png
│   │   │   │       └── Contents.json
│   │   │   ├── Base.lproj/
│   │   │   │   └── MainMenu.xib
│   │   │   ├── Configs/
│   │   │   │   ├── AppInfo.xcconfig
│   │   │   │   ├── Debug.xcconfig
│   │   │   │   ├── Release.xcconfig
│   │   │   │   └── Warnings.xcconfig
│   │   │   ├── AppDelegate.swift
│   │   │   ├── DebugProfile.entitlements
│   │   │   ├── Info.plist
│   │   │   ├── MainFlutterWindow.swift
│   │   │   └── Release.entitlements
│   │   ├── Runner.xcodeproj/
│   │   │   ├── project.xcworkspace/
│   │   │   │   └── xcshareddata/
│   │   │   │       └── IDEWorkspaceChecks.plist
│   │   │   ├── xcshareddata/
│   │   │   │   └── xcschemes/
│   │   │   │       └── Runner.xcscheme
│   │   │   └── project.pbxproj
│   │   ├── Runner.xcworkspace/
│   │   │   ├── xcshareddata/
│   │   │   │   └── IDEWorkspaceChecks.plist
│   │   │   └── contents.xcworkspacedata
│   │   ├── RunnerTests/
│   │   │   └── RunnerTests.swift
│   │   └── .gitignore
│   ├── test/
│   │   └── widget_test.dart
│   ├── web/
│   │   ├── icons/
│   │   │   ├── Icon-192.png
│   │   │   ├── Icon-512.png
│   │   │   ├── Icon-maskable-192.png
│   │   │   └── Icon-maskable-512.png
│   │   ├── favicon.png
│   │   ├── index.html
│   │   └── manifest.json
│   ├── windows/
│   │   ├── flutter/
│   │   │   ├── ephemeral/
│   │   │   │   └── .plugin_symlinks/
│   │   │   │       ├── flutter_secure_storage_windows/
│   │   │   │       ├── path_provider_windows/
│   │   │   │       ├── permission_handler_windows/
│   │   │   │       └── record_windows/
│   │   │   ├── CMakeLists.txt
│   │   │   ├── generated_plugin_registrant.cc
│   │   │   ├── generated_plugin_registrant.h
│   │   │   └── generated_plugins.cmake
│   │   ├── runner/
│   │   │   ├── resources/
│   │   │   │   └── app_icon.ico
│   │   │   ├── CMakeLists.txt
│   │   │   ├── flutter_window.cpp
│   │   │   ├── flutter_window.h
│   │   │   ├── main.cpp
│   │   │   ├── resource.h
│   │   │   ├── runner.exe.manifest
│   │   │   ├── Runner.rc
│   │   │   ├── utils.cpp
│   │   │   ├── utils.h
│   │   │   ├── win32_window.cpp
│   │   │   └── win32_window.h
│   │   ├── .gitignore
│   │   └── CMakeLists.txt
│   ├── .flutter-plugins-dependencies
│   ├── .gitignore
│   ├── .metadata
│   ├── analysis_options.yaml
│   ├── devtools_options.yaml
│   ├── mobile_app.iml
│   ├── pubspec.lock
│   ├── pubspec.yaml
│   └── README.md
├── shared_contracts/
│   ├── consultation/
│   │   └── consultation_state.schema.json
│   ├── fhir/
│   │   └── fhir_bundle.schema.json
│   ├── prescription/
│   │   └── prescription.schema.json
│   ├── referral/
│   │   └── referral.schema.json
│   ├── soap/
│   │   └── soap_note.schema.json
│   └── transcript/
│       └── transcript_turn.schema.json
├── docs/
│   ├── api_overview.md
│   ├── architecture.md
│   └── setup.md
└── scripts/
    ├── dev_start.ps1
    ├── dev_start.sh
    └── generate-repo-map.js
