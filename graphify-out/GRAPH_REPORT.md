# Graph Report - BSWInterfaceKit  (2026-06-23)

## Corpus Check
- 144 files · ~142,312 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1557 nodes · 3575 edges · 101 communities (91 shown, 10 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 190 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `86654fdb`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]
- [[_COMMUNITY_Community 58|Community 58]]
- [[_COMMUNITY_Community 59|Community 59]]
- [[_COMMUNITY_Community 60|Community 60]]
- [[_COMMUNITY_Community 61|Community 61]]
- [[_COMMUNITY_Community 62|Community 62]]
- [[_COMMUNITY_Community 63|Community 63]]
- [[_COMMUNITY_Community 64|Community 64]]
- [[_COMMUNITY_Community 65|Community 65]]
- [[_COMMUNITY_Community 66|Community 66]]
- [[_COMMUNITY_Community 67|Community 67]]
- [[_COMMUNITY_Community 68|Community 68]]
- [[_COMMUNITY_Community 69|Community 69]]
- [[_COMMUNITY_Community 70|Community 70]]
- [[_COMMUNITY_Community 71|Community 71]]
- [[_COMMUNITY_Community 72|Community 72]]
- [[_COMMUNITY_Community 73|Community 73]]
- [[_COMMUNITY_Community 74|Community 74]]
- [[_COMMUNITY_Community 75|Community 75]]
- [[_COMMUNITY_Community 76|Community 76]]
- [[_COMMUNITY_Community 77|Community 77]]
- [[_COMMUNITY_Community 78|Community 78]]
- [[_COMMUNITY_Community 79|Community 79]]
- [[_COMMUNITY_Community 80|Community 80]]
- [[_COMMUNITY_Community 81|Community 81]]
- [[_COMMUNITY_Community 82|Community 82]]
- [[_COMMUNITY_Community 83|Community 83]]
- [[_COMMUNITY_Community 84|Community 84]]
- [[_COMMUNITY_Community 85|Community 85]]
- [[_COMMUNITY_Community 86|Community 86]]
- [[_COMMUNITY_Community 93|Community 93]]
- [[_COMMUNITY_Community 94|Community 94]]
- [[_COMMUNITY_Community 95|Community 95]]
- [[_COMMUNITY_Community 96|Community 96]]
- [[_COMMUNITY_Community 97|Community 97]]
- [[_COMMUNITY_Community 98|Community 98]]
- [[_COMMUNITY_Community 99|Community 99]]
- [[_COMMUNITY_Community 100|Community 100]]

## God Nodes (most connected - your core abstractions)
1. `UIKit` - 79 edges
2. `CGSize` - 38 edges
3. `UIColor` - 34 edges
4. `NSAttributedString` - 33 edges
5. `UICollectionView` - 31 edges
6. `BSWSnapshotTest` - 25 edges
7. `MediaPickerBehavior` - 24 edges
8. `UIButton` - 24 edges
9. `SwiftUI` - 24 edges
10. `CollectionViewDiffableDataSource` - 23 edges

## Surprising Connections (you probably didn't know these)
- `AsyncButton` --references--> `AsyncOperationTracer`  [EXTRACTED]
  Docs/features/swiftui-async.md → Sources/BSWInterfaceKit/SwiftUI/Tracking/AsyncOperationTracer.swift
- `AsyncButton` --references--> `HUDState`  [EXTRACTED]
  Docs/features/swiftui-async.md → Sources/BSWInterfaceKit/SwiftUI/ViewModifiers/HUDView.swift
- `AsyncButton` --references--> `HUDConfiguration`  [EXTRACTED]
  Docs/features/swiftui-async.md → Sources/BSWInterfaceKit/SwiftUI/ViewModifiers/HUDView.swift
- `AsyncView` --references--> `LoadingView`  [EXTRACTED]
  Docs/features/swiftui-async.md → Sources/BSWInterfaceKit/Views/LoadingView.swift
- `bottomViewController()` --calls--> `UIButton`  [INFERRED]
  Tests/BSWInterfaceKitTests/Suite/UIViewControllerTests.swift → Sources/BSWInterfaceKit/Extensions/UIButton+Utilities.swift

## Import Cycles
- None detected.

## Communities (101 total, 10 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.07
Nodes (29): HorizontalPagedCollectionViewLayout, ItemAlignment, centered, left, ItemSizing, hardcoded, usingAvailableWidth, usingLineSpacing (+21 more)

### Community 1 - "Community 1"
Cohesion: 0.06
Nodes (28): FetchResult, Item, PagingHandler, PagingHandlerPreviewViewModel, State, canLoadMore, loading, noMorePages (+20 more)

### Community 2 - "Community 2"
Cohesion: 0.07
Nodes (35): Equatable, UITextField, Kind, NSObject, AnimationProperties, CardDismissAnimationController, CardHeight, fixed (+27 more)

### Community 3 - "Community 3"
Cohesion: 0.07
Nodes (30): androidx.compose.foundation.layout.Box, androidx.compose.foundation.layout.Column, androidx.compose.foundation.layout.fillMaxSize, androidx.compose.foundation.layout.fillMaxWidth, androidx.compose.foundation.layout.imePadding, androidx.compose.foundation.layout.padding, androidx.compose.foundation.layout.WindowInsets, androidx.compose.material3.Divider (+22 more)

### Community 4 - "Community 4"
Cohesion: 0.10
Nodes (18): Cell, Configuration, SelectableTableViewDataSource, IndexPath, IndexSet, ReuseType, classReference, nib (+10 more)

### Community 5 - "Community 5"
Cohesion: 0.05
Nodes (26): BSWImageCompletionBlock, Cancellable, AssociatedKeys, isVisible(), Keyboard, KeyboardLayoutGuide, UIView, AssociatedBlockHost (+18 more)

### Community 6 - "Community 6"
Cohesion: 0.07
Nodes (14): InfiniteLoadingCollectionViewCell, ExpressibleByDictionaryLiteral, EdgeKey, bottom, left, right, top, UIEdgeInsets (+6 more)

### Community 7 - "Community 7"
Cohesion: 0.06
Nodes (34): Any, AVFoundation, Kind, photo, thumbnail, video, MediaPickerBehavior, Request (+26 more)

### Community 8 - "Community 8"
Cohesion: 0.21
Nodes (11): CALayer, CGContext, double, QuartzCore, Range, Configuration, RangeSlider, RangeSliderThumbLayer (+3 more)

### Community 9 - "Community 9"
Cohesion: 0.23
Nodes (11): ContentView, Item, Identifiable, PreviewProvider, AsyncItemListView, FooterView, InfiniteDataSource_Previews, Item (+3 more)

### Community 10 - "Community 10"
Cohesion: 0.18
Nodes (12): DataGenerator, ErrorViewGenerator, AsyncView, HostedViewGenerator, ID, LoadingViewGenerator, AsyncStatePlainErrorView, AsyncStatePlainLoadingView (+4 more)

### Community 11 - "Community 11"
Cohesion: 0.15
Nodes (10): +(), AttributedStringSpacing, simple, Collection, NSAttributedString, NSMutableAttributedString, String, UIFont (+2 more)

### Community 12 - "Community 12"
Cohesion: 0.19
Nodes (7): StackSpacingView, UIStackView, ScrollableStackView, ClassicProfileViewController, UIStatusBarStyle, UIView, LoadingView

### Community 13 - "Community 13"
Cohesion: 0.08
Nodes (14): UIButton, InAppNotifications, InAppNotificationType, InAppNotificationTypeDefinition, InAppNotificationView, UIControl, UIImage, UILayoutPriority (+6 more)

### Community 14 - "Community 14"
Cohesion: 0.21
Nodes (20): Float, Input, Long, AsyncBlockingTaskConfirmationStrategy, BlockingTaskHudDialog(), BlockingTaskHudKind, BlockingTaskHudState, BlockingTaskRequest (+12 more)

### Community 15 - "Community 15"
Cohesion: 0.16
Nodes (14): AsyncButtonLoadingConfiguration, EnvironmentKey, Sendable, AsyncButtonLoadingConfiguration.Style, AsyncButtonLoadingConfiguration.Style.BlockingConfiguration, AsyncButtonLoadingConfiguration.Style.BlockingSuccessMessage, AsyncButtonLoadingConfigurationKey, AsyncButtonOperationIdentifierKey (+6 more)

### Community 16 - "Community 16"
Cohesion: 0.20
Nodes (14): Alignment, ContentComposer, Loader, ViewModifier, AndroidHUD, AndroidHUDModifier, HUDState, loading (+6 more)

### Community 17 - "Community 17"
Cohesion: 0.27
Nodes (9): Binding, Host, Item, content, loading, IntrinsicHeightDetentView_ForBool, IntrinsicHeightDetentView_ForItems, View (+1 more)

### Community 18 - "Community 18"
Cohesion: 0.14
Nodes (15): Hashable, ButtonContainerView, Cell, CollectionView, Configuration, Constants, Item, cell (+7 more)

### Community 19 - "Community 19"
Cohesion: 0.13
Nodes (10): PhotoScrollView, UILabel, Set, LoginResponse, UIEvent, UIImageView, UIScrollViewDelegate, URLHandler (+2 more)

### Community 20 - "Community 20"
Cohesion: 0.18
Nodes (12): AnyPublisher, Combine, HorizontalAlignment, ItemViewBuilder, NextPageFetcher, Phase, PinnedScrollableViews, Direction (+4 more)

### Community 21 - "Community 21"
Cohesion: 0.17
Nodes (16): Boolean, D, Modifier, Nothing, AsyncOperation, AsyncPhase, BSWAsyncView(), BSWDefaultAsyncErrorView() (+8 more)

### Community 22 - "Community 22"
Cohesion: 0.16
Nodes (7): BSWFoundation, BSWInterfaceKit, BSWInterfaceKitObjC, Constants, UIColorTests, Testing, UIKit

### Community 23 - "Community 23"
Cohesion: 0.14
Nodes (10): Color, Hasher, Image, Image, Kind, empty, image, Photo (+2 more)

### Community 24 - "Community 24"
Cohesion: 0.20
Nodes (14): AsyncButtonBlockingHudDialog(), AsyncButtonController, AsyncButtonHudKind, AsyncButtonInlineLoadingView(), AsyncButtonState, Blocking, BSWAsyncButton(), BSWAsyncButtonLoadingConfiguration (+6 more)

### Community 25 - "Community 25"
Cohesion: 0.12
Nodes (15): BSWZoomImageTransition, -animateTransition, -finalRectForImageSizeconstrainedToContentRectcontentMode, -init, -initWithTypedurationdelegate, -transitionDuration, BSWZoomTransition, -animateTransition (+7 more)

### Community 26 - "Community 26"
Cohesion: 0.07
Nodes (18): AvatarTouchHandler, ClassicProfileViewModel, Photo, CollectionViewDiffableDataSourceTests, MockCollectionView, PolaroidCollectionViewCell, Section, defenders (+10 more)

### Community 27 - "Community 27"
Cohesion: 0.33
Nodes (7): InAppNotificationEvent, Kind, error, message, SampleView, ToastView, View

### Community 28 - "Community 28"
Cohesion: 0.19
Nodes (19): ContentView, generateData(), PlaceholderDataProvider, Sequence, decodeEscapedMessage(), errorChain(), extractAsyncButtonErrorMessage(), extractJsonObject() (+11 more)

### Community 29 - "Community 29"
Cohesion: 0.22
Nodes (10): Configuration, ContentViewTests, CustomCell, CustomHeader, Section, main, View, ViewController (+2 more)

### Community 30 - "Community 30"
Cohesion: 0.20
Nodes (7): UINavigationItem, Appereance, ContainerViewController, LayoutMode, pinToSafeArea, pinToSuperview, RootViewController

### Community 31 - "Community 31"
Cohesion: 0.31
Nodes (6): ASPresentationAnchor, ASWebAuthenticationPresentationContextProviding, ASWebAuthenticationSession, AuthenticationServices, SocialAuthenticationCredentials, SocialAuthenticationManager

### Community 32 - "Community 32"
Cohesion: 0.18
Nodes (11): PhotoCollectionViewCell, PhotoGalleryView, UICollectionViewDataSourcePrefetching, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewLayout, Item, photo (+3 more)

### Community 33 - "Community 33"
Cohesion: 0.15
Nodes (5): CheckboxButtonTests, ClassicProfileViewControllerTests, HorizontalPagedCollectionViewLayoutTests, RangeSliderTests, UIViewTests

### Community 34 - "Community 34"
Cohesion: 0.31
Nodes (4): Configuration, View, UIConfigurationState, UIContentConfiguration

### Community 35 - "Community 35"
Cohesion: 0.14
Nodes (10): State, loading, noMorePages, View, LibraryContentProvider, LibraryItem, Observation, SkipFuseUI (+2 more)

### Community 37 - "Community 37"
Cohesion: 0.19
Nodes (13): Class, BSWSwiftViewModelFactory, BSWSwiftViewModelHolder, BSWSwiftViewModelOwnerRetention(), BSWWithScopedSwiftViewModelOwner(), rememberBSWScopedViewModelStoreOwner(), swiftViewModel(), SwiftViewModelRetention (+5 more)

### Community 38 - "Community 38"
Cohesion: 0.16
Nodes (9): MailContents, MessageComposerBehavior, MessageComposeResult, MessageUI, MFMailComposeResult, MFMailComposeViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewController (+1 more)

### Community 39 - "Community 39"
Cohesion: 0.27
Nodes (9): ErrorViewFactory, AssociatedKeys, TaskWrapper, UIViewController, LoadingViewFactory, Never, SwiftConcurrencyCompletion, SwiftConcurrencyGenerator (+1 more)

### Community 40 - "Community 40"
Cohesion: 0.22
Nodes (9): AsyncBlockingTask, AsyncBlockingTaskWithValue, CheckedContinuation, V, AsyncBlockingTaskConfirmationStrategy, confirmWith, notRequired, PerformEquatableBlockingView (+1 more)

### Community 41 - "Community 41"
Cohesion: 0.24
Nodes (4): StateContainerAppereance, StateContainerView, StateContainerViewController, TransitionConfiguration

### Community 42 - "Community 42"
Cohesion: 0.25
Nodes (7): Snapshotting, UIScreen, WaitStrategy, closestBSWTask, milliseconds, SnapshotTesting, ViewImageConfig

### Community 43 - "Community 43"
Cohesion: 0.25
Nodes (4): CGFloat, CGPoint, NSMutableParagraphStyle, NSParagraphStyle

### Community 44 - "Community 44"
Cohesion: 0.22
Nodes (6): CustomDebugStringConvertible, OptionSet, FacebookCredentials, Scope, SocialAuthenticationManager, SocialAuthenticationManager.FacebookCredentials

### Community 45 - "Community 45"
Cohesion: 0.24
Nodes (5): CGSize, PreferenceKey, ContentVC, UIViewControllerTransitionCoordinator, CGSizeKey

### Community 46 - "Community 46"
Cohesion: 0.23
Nodes (7): Bool, UIScreen, StateViewLayout, pinToSuperview, pinToSuperviewLayoutMargins, setFrame, UIViewController

### Community 47 - "Community 47"
Cohesion: 0.15
Nodes (13): Action, CustomProgress, AsyncButton, Infinite Scrolling, Operation Tracing, SwiftUI Async Components, Label, LocalizedStringKey (+5 more)

### Community 48 - "Community 48"
Cohesion: 0.22
Nodes (7): BSWInterfaceKit Knowledge Base, Decisions, Quick Start, Systems, Components, Maintenance Rule, Objective-C Compatibility

### Community 49 - "Community 49"
Cohesion: 0.29
Nodes (6): Android Skip, Integrations, Module Map, Objective-C Compatibility, SwiftUI, UIKit

### Community 50 - "Community 50"
Cohesion: 0.12
Nodes (17): Configuration, ContentMode, CoreImage, CoreImage.CIFilterBuiltins, NukeUI, Configuration, Image, PhotoView (+9 more)

### Community 51 - "Community 51"
Cohesion: 0.24
Nodes (4): Error, ErrorAwareView, SwiftUI.View, View

### Community 52 - "Community 52"
Cohesion: 0.33
Nodes (5): BSWCollectionViewLeftAlignedLayout, -evaluatedMinimumInteritemSpacingForSectionAtIndex, -evaluatedSectionInsetForItemAtIndex, -layoutAttributesForElementsInRect, -layoutAttributesForItemAtIndexPath

### Community 53 - "Community 53"
Cohesion: 0.33
Nodes (5): 001 - Shared UI Foundation Package, Consequences, Context, Decision, Status

### Community 54 - "Community 54"
Cohesion: 0.29
Nodes (3): TextStyler, TextStylerTests, UIFontDescriptor

### Community 55 - "Community 55"
Cohesion: 0.21
Nodes (4): bottomViewController(), bottomViewControllerContainer(), TestViewController, UIViewControllerTests

### Community 56 - "Community 56"
Cohesion: 0.48
Nodes (5): Font, HUDConfiguration, BlockingConfiguration, BlockingSuccessMessage, blocking

### Community 57 - "Community 57"
Cohesion: 0.12
Nodes (10): CAGradientLayer, CellFactory, CGRect, UICollectionViewLayoutAttributes, -leftAlignFrameWithSectionInset, UIImage, HeaderFooterFactory, ColumnFlowLayout (+2 more)

### Community 58 - "Community 58"
Cohesion: 0.21
Nodes (8): GlobalActor, OperationFailedHandler, OperationHandler, AsyncOperationTracer, AsyncOperationTracerStorageActor, Kind, buttonAction, viewLoading

### Community 59 - "Community 59"
Cohesion: 0.05
Nodes (31): ScrollingDirection, horizontal, vertical, UpdatePageControlOnScrollBehavior, BottomContainerViewController, SomeError, isiOSAppOnMac(), LocalizationService (+23 more)

### Community 60 - "Community 60"
Cohesion: 0.24
Nodes (5): IntrinsicSizeCalculable, UINavigationController, IntrinsicSizeCalculableTests, SomeView, SomeViewThatOverridesIntrinsicSize

### Community 62 - "Community 62"
Cohesion: 0.33
Nodes (5): 002 - Plain Android Compose Primitives, Consequences, Context, Decision, Status

### Community 63 - "Community 63"
Cohesion: 0.33
Nodes (5): CollectionViewDiffableDataSource, Data Sources And Layouts, Layouts, Paging Collection Data Source, Selectable Table View Data Source

### Community 64 - "Community 64"
Cohesion: 0.33
Nodes (5): In-App Notifications, Mail And Message Composer, Media Picker, Media, Social And In-App Integrations, Social Authentication

### Community 65 - "Community 65"
Cohesion: 0.33
Nodes (5): Blocking Tasks, HUD, Other Modifiers, State Ownership, SwiftUI Modifiers And State Surfaces

### Community 67 - "Community 67"
Cohesion: 0.42
Nodes (5): Data, Async, JSONTreeView, MockData, Node

### Community 68 - "Community 68"
Cohesion: 0.22
Nodes (8): -bsw_firstLayoutPassed, -bsw_viewDidLayoutSubviews, -bsw_viewWillTransitionToSizewithTransitionCoordinator, -load, -setBSWFirstLayoutPassed, -swizzlewithCustom, -viewInitialLayoutDidComplete, UIViewController

### Community 69 - "Community 69"
Cohesion: 0.43
Nodes (5): Composable, Dp, SheetState, BSWSheet, Unit

### Community 70 - "Community 70"
Cohesion: 0.25
Nodes (7): BSWShadowInformation, -bsw_layoutSubviews, -bsw_shadowInfo, -load, -setBsw_shadowInfo, -swizzlewithCustom, UIView

### Community 72 - "Community 72"
Cohesion: 0.15
Nodes (12): Error, diskWriteFailed, jpegCompressionFailed, unknown, SocialAuthenticationError, emailNotProvided, ongoingLogin, unknownResponse (+4 more)

### Community 73 - "Community 73"
Cohesion: 0.33
Nodes (5): Consequences, Context, Decision, NNN - Title, Status

### Community 74 - "Community 74"
Cohesion: 0.40
Nodes (3): ActionValidator, UITextContentType, TextFieldAlertController

### Community 75 - "Community 75"
Cohesion: 0.60
Nodes (5): backup_package_swift(), build_framework(), modify_package_swift(), restore_package_swift(), build.sh script

### Community 76 - "Community 76"
Cohesion: 0.33
Nodes (5): Android Support, BSWInterfaceKit, Documentation, Integration guidance, Naming convention

### Community 77 - "Community 77"
Cohesion: 0.16
Nodes (10): BSWSnapshotTest, CardPresentationViewControllerTests, FooVC, SampleVC, SelectableTableViewDataSourceTests, ShadowTests, ViewController, UIViewController (+2 more)

### Community 78 - "Community 78"
Cohesion: 0.50
Nodes (3): AnyClass, RoundLayerTests, RoundView

### Community 80 - "Community 80"
Cohesion: 0.40
Nodes (4): GitHub PR Conventions, Graphify, Project Context Docs, Repository Instructions

### Community 81 - "Community 81"
Cohesion: 0.40
Nodes (4): Android Via Skip, Apple Platforms, Compatibility Rule, Platform Support

### Community 82 - "Community 82"
Cohesion: 0.40
Nodes (4): Dependencies, Documentation Responsibilities, Package Shape, Project Overview

### Community 83 - "Community 83"
Cohesion: 0.50
Nodes (4): Phase, idle, noMorePages, paging

### Community 93 - "Community 93"
Cohesion: 0.40
Nodes (4): Android Skip Components, Design Rule, Naming Rule, Public Components

### Community 94 - "Community 94"
Cohesion: 0.40
Nodes (4): Models And Protocols, Styling, Styling And Extensions, UIKit Extensions

### Community 95 - "Community 95"
Cohesion: 0.40
Nodes (4): Controllers, State Views, UIKit Views And Controllers, Views

### Community 96 - "Community 96"
Cohesion: 0.40
Nodes (5): Phase, error, idle, loaded, loading

### Community 97 - "Community 97"
Cohesion: 0.50
Nodes (3): Maintenance Triggers, Open Items, Technical Pending

### Community 100 - "Community 100"
Cohesion: 0.67
Nodes (3): ClassicProfileEditKind, editable, nonEditable

## Knowledge Gaps
- **219 isolated node(s):** `GenerateScreenshots.sh script`, `PackageDescription`, `MessageUI`, `MobileCoreServices`, `ImageIO` (+214 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `UIKit` connect `Community 22` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 6`, `Community 7`, `Community 8`, `Community 11`, `Community 12`, `Community 13`, `Community 18`, `Community 19`, `Community 26`, `Community 29`, `Community 30`, `Community 31`, `Community 32`, `Community 34`, `Community 38`, `Community 39`, `Community 41`, `Community 42`, `Community 44`, `Community 46`, `Community 51`, `Community 57`, `Community 59`, `Community 60`, `Community 61`, `Community 74`, `Community 85`, `Community 99`?**
  _High betweenness centrality (0.126) - this node is a cross-community bridge._
- **Why does `SwiftUI Async Components` connect `Community 47` to `Community 10`?**
  _High betweenness centrality (0.100) - this node is a cross-community bridge._
- **Why does `AsyncView` connect `Community 10` to `Community 9`, `Community 12`, `Community 46`, `Community 47`?**
  _High betweenness centrality (0.076) - this node is a cross-community bridge._
- **What connects `GenerateScreenshots.sh script`, `PackageDescription`, `MessageUI` to the rest of the system?**
  _219 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.06715063520871144 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.05721153846153846 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.06533575317604355 - nodes in this community are weakly interconnected._