package bswinterface.kit

import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.currentCompositeKeyHashCode
import androidx.compose.runtime.remember
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import androidx.lifecycle.viewmodel.compose.LocalViewModelStoreOwner
import androidx.lifecycle.viewmodel.compose.viewModel

class BSWSwiftViewModelHolder<SW : Any>(val swiftViewModel: SW) : ViewModel()

class BSWSwiftViewModelFactory<SW : Any>(
    private val creator: () -> SW,
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <VM : ViewModel> create(modelClass: Class<VM>): VM = BSWSwiftViewModelHolder(creator()) as VM
}

@PublishedApi
internal enum class SwiftViewModelRetention {
    Composition,
    Owner,
}

@PublishedApi
internal val LocalSwiftViewModelRetention =
    staticCompositionLocalOf { SwiftViewModelRetention.Owner }

@Composable
fun BSWSwiftViewModelOwnerRetention(content: @Composable () -> Unit) {
    CompositionLocalProvider(
        LocalSwiftViewModelRetention provides SwiftViewModelRetention.Owner,
    ) {
        content()
    }
}

@Composable
fun BSWWithScopedSwiftViewModelOwner(
    scopeKey: Any?,
    content: @Composable () -> Unit,
) {
    val owner = rememberBSWScopedViewModelStoreOwner(scopeKey)

    CompositionLocalProvider(LocalViewModelStoreOwner provides owner) {
        BSWSwiftViewModelOwnerRetention {
            content()
        }
    }
}

@Composable
fun rememberBSWScopedViewModelStoreOwner(scopeKey: Any?): ViewModelStoreOwner {
    val viewModelStore = remember(scopeKey) { ViewModelStore() }

    DisposableEffect(viewModelStore) {
        onDispose {
            viewModelStore.clear()
        }
    }

    return remember(viewModelStore) {
        object : ViewModelStoreOwner {
            override val viewModelStore: ViewModelStore = viewModelStore
        }
    }
}

@Composable
inline fun <reified SW : Any> swiftViewModel(
    key: String = SW::class.java.name,
    crossinline factory: () -> SW,
): SW {
    val owner = when (LocalSwiftViewModelRetention.current) {
        SwiftViewModelRetention.Composition -> {
            rememberBSWScopedViewModelStoreOwner(scopeKey = currentCompositeKeyHashCode)
        }
        SwiftViewModelRetention.Owner -> {
            checkNotNull(LocalViewModelStoreOwner.current) {
                "No ViewModelStoreOwner was provided via LocalViewModelStoreOwner"
            }
        }
    }
    val holder: BSWSwiftViewModelHolder<SW> =
        viewModel(
            viewModelStoreOwner = owner,
            key = key,
            factory = BSWSwiftViewModelFactory { factory() },
        )
    return holder.swiftViewModel
}
