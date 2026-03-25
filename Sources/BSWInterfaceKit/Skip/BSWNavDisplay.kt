package bswinterface.kit

import androidx.compose.animation.AnimatedContentTransitionScope
import androidx.compose.animation.ContentTransform
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import androidx.lifecycle.viewmodel.compose.LocalViewModelStoreOwner
import androidx.navigation3.runtime.NavEntry
import androidx.navigation3.runtime.NavEntryDecorator
import androidx.navigation3.runtime.rememberSaveableStateHolderNavEntryDecorator
import androidx.navigation3.ui.NavDisplay
import androidx.navigationevent.NavigationEvent

private const val BSW_BACK_ANIMATION_DURATION_MS = 450

private fun bswBackTransform(
    scope: AnimatedContentTransitionScope<*>,
    towards: AnimatedContentTransitionScope.SlideDirection,
): ContentTransform =
    with(scope) {
        slideIntoContainer(
            towards = towards,
            animationSpec = tween(durationMillis = BSW_BACK_ANIMATION_DURATION_MS),
            initialOffset = { it / 3 },
        ) + fadeIn(animationSpec = tween(durationMillis = BSW_BACK_ANIMATION_DURATION_MS)) togetherWith
            slideOutOfContainer(
                towards = towards,
                animationSpec = tween(durationMillis = BSW_BACK_ANIMATION_DURATION_MS),
            ) + fadeOut(animationSpec = tween(durationMillis = BSW_BACK_ANIMATION_DURATION_MS))
    }

/**
 * Default entry decorators used by [BSWNavDisplay].
 *
 * This combines saveable state with a per-entry [ViewModelStoreOwner] so screens
 * using `swiftViewModel(...)` keep the expected lifecycle on Android.
 */
@Composable
fun <T : Any> rememberBSWNavEntryDecorators(): List<NavEntryDecorator<T>> =
    listOf(
        rememberSaveableStateHolderNavEntryDecorator(),
        rememberBSWScopedViewModelStoreNavEntryDecorator(),
    )

@Composable
private fun <T : Any> rememberBSWScopedViewModelStoreNavEntryDecorator(): NavEntryDecorator<T> {
    val viewModelStores = remember { mutableStateMapOf<Any, ViewModelStore>() }

    DisposableEffect(Unit) {
        onDispose {
            viewModelStores.values.forEach(ViewModelStore::clear)
            viewModelStores.clear()
        }
    }

    return remember {
        NavEntryDecorator(
            onPop = { contentKey ->
                viewModelStores.remove(contentKey)?.clear()
            },
        ) { entry ->
            val store = viewModelStores.getOrPut(entry.contentKey) { ViewModelStore() }
            val owner =
                object : ViewModelStoreOwner {
                    override val viewModelStore: ViewModelStore = store
                }

            CompositionLocalProvider(LocalViewModelStoreOwner provides owner) {
                BSWSwiftViewModelOwnerRetention {
                    entry.Content()
                }
            }
        }
    }
}

/**
 * Shared Navigation 3 display with the default BSW push/pop behavior for Android.
 *
 * Apps are expected to supply only their back stack and entry provider unless they
 * need a custom list of entry decorators.
 */
@Composable
fun <T : Any> BSWNavDisplay(
    backStack: List<T>,
    modifier: Modifier = Modifier,
    contentAlignment: Alignment = Alignment.TopStart,
    onBack: () -> Unit = {
        if (backStack is MutableList<T>) {
            backStack.removeLastOrNull()
        }
    },
    entryDecorators: List<NavEntryDecorator<T>>? = null,
    entryProvider: (key: T) -> NavEntry<T>,
) {
    val resolvedEntryDecorators = entryDecorators ?: rememberBSWNavEntryDecorators()

    NavDisplay(
        backStack = backStack,
        modifier = modifier,
        contentAlignment = contentAlignment,
        onBack = onBack,
        entryDecorators = resolvedEntryDecorators,
        transitionSpec = {
            slideIntoContainer(
                towards = AnimatedContentTransitionScope.SlideDirection.Left,
                animationSpec = spring(),
            ) togetherWith ExitTransition.None
        },
        popTransitionSpec = {
            bswBackTransform(
                scope = this,
                towards = AnimatedContentTransitionScope.SlideDirection.Right,
            )
        },
        predictivePopTransitionSpec = { swipeEdge ->
            val towards =
                if (swipeEdge == NavigationEvent.EDGE_RIGHT) {
                    AnimatedContentTransitionScope.SlideDirection.Left
                } else {
                    AnimatedContentTransitionScope.SlideDirection.Right
                }

            bswBackTransform(scope = this, towards = towards)
        },
        entryProvider = entryProvider,
    )
}
