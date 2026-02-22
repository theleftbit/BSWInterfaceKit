#if os(Android)
import SkipFuseUI
#else
import SwiftUI
#endif

#if os(Android)
#if SKIP
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Divider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
#endif
#endif

#if canImport(Darwin)

#Preview("Top Button") {
    NavigationStack {
        let fruits = [
            "Apple", "Banana", "Cherry", "Date", "Elderberry",
            "Fig", "Grape", "Honeydew", "Kiwi", "Lemon",
            "Mango", "Nectarine", "Orange", "Papaya", "Quince",
            "Raspberry", "Strawberry", "Tangerine", "Ugli Fruit", "Watermelon"
        ]
        List(fruits, id: \.self, rowContent: Text.init)
            .topActionBar {
                AsyncButton(
                    action: { try await Task.sleep(for: .seconds(1)) },
                    label: {
                        HStack { Spacer(); Text("Hello"); Spacer() }
                    }
                )
            }
    }
}

#Preview("Bottom Button") {
    NavigationStack {
        let fruits = [
            "Apple", "Banana", "Cherry", "Date", "Elderberry",
            "Fig", "Grape", "Honeydew", "Kiwi", "Lemon",
            "Mango", "Nectarine", "Orange", "Papaya", "Quince",
            "Raspberry", "Strawberry", "Tangerine", "Ugli Fruit", "Watermelon"
        ]
        List(fruits, id: \.self, rowContent: Text.init)
            .bottomActionBar {
                AsyncButton(
                    action: { try await Task.sleep(for: .seconds(1)) },
                    label: {
                        HStack { Spacer(); Text("Hello"); Spacer() }
                    }
                )
            }
    }
}
#endif

public extension View {
    
    @ViewBuilder
    func bottomActionBar<T: View>(
        @ViewBuilder button: () -> T
    ) -> some View {
        let actionButton = button()

        #if os(Android)
        ComposeView {
            AndroidActionBarScaffold(
                content: self,
                actionBar: actionButton,
                isTopBar: false
            )
        }
        #else
        self.bottomActionBarInset(actionButton)
        #endif
    }

    @ViewBuilder
    func topActionBar<T: View>(
        @ViewBuilder topBar: () -> T
    ) -> some View {
        let actionTopBar = topBar()

        #if os(Android)
        ComposeView {
            AndroidActionBarScaffold(
                content: self,
                actionBar: actionTopBar,
                isTopBar: true
            )
        }
        #else
        self.topActionBarInset(actionTopBar)
        #endif
    }
}

#if os(iOS)
private extension View {

    @ViewBuilder
    func bottomActionBarInset<T: View>(_ actionButton: T) -> some View {
        self.actionBarInset(
            actionButton,
            edge: .bottom,
            dividerAlignment: .top
        )
    }

    @ViewBuilder
    func topActionBarInset<T: View>(_ actionTopBar: T) -> some View {
        self.actionBarInset(
            actionTopBar,
            edge: .top,
            dividerAlignment: .bottom
        )
    }

    @ViewBuilder
    func actionBarInset<T: View>(
        _ actionBar: T,
        edge: VerticalEdge,
        dividerAlignment: Alignment
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.safeAreaBar(edge: edge) {
                actionBar
            }
        } else {
            self.safeAreaInset(edge: edge) {
                actionBar
                    .background(.regularMaterial)
                    .overlay(alignment: dividerAlignment) {
                        Divider()
                    }
            }
        }
    }
}
#endif

#if os(Android)
#if SKIP

struct AndroidActionBarScaffold: ContentComposer {
    typealias BridgedView = any View
    let content: BridgedView
    let actionBar: BridgedView
    let isTopBar: Bool

    @Composable
    func Compose(context: ComposeContext) {
        ComposeContainer(modifier: context.modifier, fillWidth: true, fillHeight: true) { modifier in
            Scaffold(
                modifier: modifier.fillMaxSize(),
                contentWindowInsets: WindowInsets(0),
                topBar: {
                    if isTopBar {
                        Surface(color: MaterialTheme.colorScheme.surface) {
                            Column(
                                modifier: Modifier
                                    .fillMaxWidth()
                            ) {
                                actionBar.Compose(
                                    context: context.content(
                                        modifier: Modifier.fillMaxWidth()
                                    )
                                )
                                Divider()
                            }
                        }
                    }
                },
                bottomBar: {
                    if !isTopBar {
                        Surface(color: MaterialTheme.colorScheme.surface) {
                            Box(
                                modifier: Modifier
                                    .fillMaxWidth()
                                    .imePadding()
                            ) {
                                Divider()
                                Box(
                                    modifier: Modifier
                                        .fillMaxWidth()
                                ) {
                                    actionBar.Compose(
                                        context: context.content(
                                            modifier: Modifier.fillMaxWidth()
                                        )
                                    )
                                }
                            }
                        }
                    }
                },
                content: { innerPadding in
                    Box(
                        modifier: Modifier
                            .fillMaxSize()
                            .padding(innerPadding)
                    ) {
                        content.Compose(
                            context: context.content(
                                modifier: Modifier.fillMaxSize()
                            )
                        )
                    }
                }
            )
        }
    }
}

#endif
#endif
