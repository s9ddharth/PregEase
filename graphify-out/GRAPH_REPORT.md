# Graph Report - ParentSupportApp  (2026-09-10)

## Corpus Check
- 129 files · ~108,720 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 738 nodes · 1199 edges · 51 communities (22 shown, 18 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 109 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Community Feed
- Community Feed 2
- Windows Platform
- Community Feed 3
- Community Feed 4
- Chat API
- Community Features
- Project Support
- Linux Platform
- Pregnancy Experience
- Wellness API
- Community Feed 5
- Windows Platform 2
- Pregnancy Assets
- Community Feed 6
- Web Platform
- macOS Platform
- iOS Platform
- AI Client
- iOS Platform 2
- iOS Platform 3
- Main App Shell
- macOS Platform 2
- Chat Services
- macOS Platform 3
- Configuration
- Android Platform
- Project Support 2
- Flutter Platform
- Typography Assets
- HTTP Utilities
- Launch Assets
- Project Support 3
- Project Support 4
- Pregnancy Profiles
- Shared Preferences
- Launch Assets 2
- User Accounts
- Wellness Check-ins
- Project Support 8

## God Nodes (most connected - your core abstractions)
1. `Community` - 29 edges
2. `Win32Window` - 24 edges
3. `PregEase Project` - 23 edges
4. `Base` - 19 edges
5. `post` - 17 edges
6. `CommunityPost` - 15 edges
7. `CommunityMember` - 13 edges
8. `MessageHandler` - 12 edges
9. `CommunityComment` - 11 edges
10. `assets/images` - 11 edges

## Surprising Connections (you probably didn't know these)
- `Flutter` --architecture_next--> `FastAPI`  [EXTRACTED]
  frontend/ios/Runner/SceneDelegate.swift → docs/PROJECT_MEMORY.md
- `Pregnancy Week 4 Asset` --ASSET_OF--> `PregEase Project`  [EXTRACTED]
  frontend/assets/images/pregnancy_week_04.png → docs/PROJECT_MEMORY.md
- `Pregnancy Week 8 Asset` --ASSET_OF--> `PregEase Project`  [EXTRACTED]
  frontend/assets/images/pregnancy_week_08.png → docs/PROJECT_MEMORY.md
- `Pregnancy Week 12 Asset` --ASSET_OF--> `PregEase Project`  [EXTRACTED]
  frontend/assets/images/pregnancy_week_12.png → docs/PROJECT_MEMORY.md
- `Pregnancy Week 16 Asset` --ASSET_OF--> `PregEase Project`  [EXTRACTED]
  frontend/assets/images/pregnancy_week_16.png → docs/PROJECT_MEMORY.md

## Import Cycles
- None detected.

## Communities (51 total, 18 thin omitted)

### Community 0 - "Community Feed"
Cohesion: 0.02
Nodes (109): community_feed_screen.dart, _allergyOptions, apiBaseUrl, authHeaders, _buildAllergyOption, _buildHistoryBody, _buildMessage, ChatSession (+101 more)

### Community 1 - "Community Feed 2"
Cohesion: 0.06
Nodes (91): field_validator, post, add_community_moderator(), create_community_comment(), create_community_endpoint(), create_community_post(), create_rule(), delete_community_comment() (+83 more)

### Community 2 - "Windows Platform"
Cohesion: 0.05
Nodes (57): RegisterPlugins(), DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow (+49 more)

### Community 3 - "Community Feed 3"
Cohesion: 0.04
Nodes (48): _author, background, build, _buildAboutTab, _buildCommunityHero, _buildEmptyState, _buildErrorState, _buildInfoSection (+40 more)

### Community 4 - "Community Feed 4"
Cohesion: 0.08
Nodes (25): DeclarativeBase, _date, create_access_token(), get_me(), get_secret_key(), login(), get, register() (+17 more)

### Community 5 - "Chat API"
Cohesion: 0.06
Nodes (40): FastAPI, HTTPAuthorizationCredentials, MySQL, Ollama, OpenAI, chat(), delete_chat_session(), get_chat_history() (+32 more)

### Community 6 - "Community Features"
Cohesion: 0.06
Nodes (38): AI Assistant, AI Chat, /auth/*, /chat/*, /community/*, /doctor/*, /emergency/*, /father/* (+30 more)

### Community 7 - "Project Support"
Cohesion: 0.06
Nodes (30): background, blue, blueBorder, border, lavender, lavenderBorder, lg, md (+22 more)

### Community 8 - "Linux Platform"
Cohesion: 0.09
Nodes (24): FlPluginRegistry, FlView, fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose() (+16 more)

### Community 9 - "Pregnancy Experience"
Cohesion: 0.07
Nodes (27): class, Color, dart:convert, apiBaseUrl, _babyDevelopmentAsset, build, color, createState (+19 more)

### Community 10 - "Wellness API"
Cohesion: 0.17
Nodes (22): Enum, get_latest_checkin(), get_wellness_checkin_pattern(), get_wellness_checkins(), get, Session, submit_wellness_checkin(), WellnessCheckin (+14 more)

### Community 11 - "Community Feed 5"
Cohesion: 0.12
Nodes (24): CommunityFeedScreen, _CommunityFeedScreenState, AppShell, _AppShellState, AuthGate, _AuthGateState, ChatHistoryScreen, _ChatHistoryScreenState (+16 more)

### Community 12 - "Windows Platform 2"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 13 - "Pregnancy Assets"
Cohesion: 0.18
Nodes (11): assets/images, Pregnancy Week 04, Pregnancy Week 08, Pregnancy Week 12, Pregnancy Week 16, Pregnancy Week 20, Pregnancy Week 24, Pregnancy Week 28 (+3 more)

### Community 14 - "Community Feed 6"
Cohesion: 0.18
Nodes (11): _GuidelineRow, _PostCard, _CommunityCard, _CommunityError, _DoctorCard, DoctorsScreen, _InfoCard, PregEaseApp (+3 more)

### Community 15 - "Web Platform"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 16 - "macOS Platform"
Cohesion: 0.20
Nodes (8): FlutterPluginRegistry, FlutterViewController, Foundation, RegisterGeneratedPlugins(), MainFlutterWindow, NSWindow, shared_preferences_foundation, url_launcher_macos

### Community 17 - "iOS Platform"
Cohesion: 0.25
Nodes (7): Flutter, flutter_lints, FlutterSceneDelegate, frontend, SceneDelegate, UIKit, Web

### Community 19 - "iOS Platform 2"
Cohesion: 0.25
Nodes (6): Any, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, UIApplication

### Community 20 - "iOS Platform 3"
Cohesion: 0.29
Nodes (4): RunnerTests, RunnerTests, XCTest, XCTestCase

### Community 21 - "Main App Shell"
Cohesion: 0.29
Nodes (7): build, _createNewChat, _openCommunity, _openPregnancyProfile, _openSession, _setupPregnancyProfile, MaterialPageRoute

### Community 22 - "macOS Platform 2"
Cohesion: 0.47
Nodes (4): FlutterAppDelegate, AppDelegate, Bool, NSApplication

## Knowledge Gaps
- **269 isolated node(s):** `Config`, `communityId`, `communityName`, `description`, `memberCount` (+264 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 367 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `post` connect `Community Feed 2` to `Wellness API`, `Community Feed 3`, `Community Feed 4`, `Chat API`?**
  _High betweenness centrality (0.339) - this node is a cross-community bridge._
- **Why does `FastAPI` connect `Chat API` to `iOS Platform`, `Wellness API`, `Community Feed 4`, `Community Feed 2`?**
  _High betweenness centrality (0.270) - this node is a cross-community bridge._
- **Why does `Flutter` connect `iOS Platform` to `iOS Platform 3`, `Chat API`?**
  _High betweenness centrality (0.250) - this node is a cross-community bridge._
- **Are the 25 inferred relationships involving `Community` (e.g. with `add_moderator()` and `create_comment()`) actually correct?**
  _`Community` has 25 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Config`, `communityId`, `communityName` to the rest of the system?**
  _269 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community Feed` be split into smaller, more focused modules?**
  _Cohesion score 0.01818181818181818 - nodes in this community are weakly interconnected._
- **Should `Community Feed 2` be split into smaller, more focused modules?**
  _Cohesion score 0.06421821305841924 - nodes in this community are weakly interconnected._