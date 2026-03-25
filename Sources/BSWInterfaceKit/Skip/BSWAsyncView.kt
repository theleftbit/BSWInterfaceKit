package bswinterface.kit

import androidx.activity.compose.LocalOnBackPressedDispatcherOwner
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

private const val PHASE_CROSSFADE_DURATION_MS = 220

sealed interface AsyncPhase<out D : Any> {
    data object Idle : AsyncPhase<Nothing>
    data object Loading : AsyncPhase<Nothing>
    data class Loaded<D : Any>(val data: D) : AsyncPhase<D>
    data class Error(val throwable: Throwable) : AsyncPhase<Nothing>
}

data class AsyncOperation<ID, Data : Any>(
    var id: ID,
    var phase: AsyncPhase<Data>,
) {
    fun isLoaded(forId: ID): Boolean {
        if (this.id != forId) return false
        return phase is AsyncPhase.Loaded<*>
    }
}

/**
 * Plain Android async container for Compose screens.
 *
 * The defaults in this file are intentionally minimal so apps can wrap this API
 * with their own localized loading and error views without reimplementing the
 * Swift view-model retention and async state handling.
 */
@Composable
fun <Data : Any, ID : Any> BSWAsyncView(
    id: ID,
    showBackButton: Boolean = true,
    dataGenerator: suspend () -> Data,
    hostedView: @Composable (Data) -> Unit,
    errorView: @Composable (Throwable, onRetry: () -> Unit) -> Unit = { error, onRetry ->
        BSWDefaultAsyncErrorView(
            error = error,
            onRetry = onRetry,
            showBackButton = showBackButton
        )
    },
    loadingView: @Composable () -> Unit = { BSWDefaultAsyncLoadingView(showBackButton) },
    debounceMillis: Long? = null
) {
    val scope = rememberCoroutineScope()
    val composedKey = "BSWAsyncView:$id"

    var operation by swiftViewModel(
        key = composedKey,
    ) {
        mutableStateOf<AsyncOperation<ID, Data>>(
            AsyncOperation<ID, Data>(id = id, phase = AsyncPhase.Idle),
        )
    }

    val fetchData: () -> Unit = {
        scope.launch {
            if (operation.isLoaded(forId = id)) return@launch

            debounceMillis?.let { delay(it) }

            operation = operation.copy(id = id, phase = AsyncPhase.Loading)
            try {
                val result = dataGenerator()
                operation = operation.copy(phase = AsyncPhase.Loaded(result))
            } catch (_: CancellationException) {
                // ignore
            } catch (t: Throwable) {
                operation = operation.copy(phase = AsyncPhase.Error(t))
            }
        }
    }

    LaunchedEffect(id) {
        fetchData()
    }

    AnimatedContent(
        targetState = operation.phase,
        transitionSpec = {
            val shouldCrossfade =
                initialState is AsyncPhase.Loading &&
                    (targetState is AsyncPhase.Loaded<*> || targetState is AsyncPhase.Error)

            if (shouldCrossfade) {
                (
                    fadeIn(animationSpec = tween(durationMillis = PHASE_CROSSFADE_DURATION_MS)) togetherWith
                    fadeOut(animationSpec = tween(durationMillis = PHASE_CROSSFADE_DURATION_MS))
                    )
            } else {
                (
                    EnterTransition.None togetherWith ExitTransition.None
                    )
            }
        },
        label = "BSWAsyncViewPhase"
    ) { phase ->
        when (phase) {
            is AsyncPhase.Idle,
            is AsyncPhase.Loading -> loadingView()
            is AsyncPhase.Loaded<*> -> hostedView((phase as AsyncPhase.Loaded<Data>).data)
            is AsyncPhase.Error -> errorView(phase.throwable) { fetchData() }
        }
    }
}

/**
 * Fallback error UI used by [BSWAsyncView] when the consumer does not inject a
 * custom error view. Product apps are expected to override this with localized UI.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BSWDefaultAsyncErrorView(
    error: Throwable,
    onRetry: () -> Unit,
    showBackButton: Boolean = true,
) {
    val onBackPressedDispatcher = LocalOnBackPressedDispatcherOwner.current?.onBackPressedDispatcher
    val displayMessage = remember(error) { error.toDisplayMessage() }
    val onBackStack: () -> Unit = {
        onBackPressedDispatcher?.onBackPressed()
    }

    Scaffold(
        modifier = Modifier.fillMaxWidth(),
        contentWindowInsets = WindowInsets(0, 0, 0, 0),
        topBar = {
            if (showBackButton) {
                TopAppBar(
                    windowInsets = WindowInsets(0, 0, 0, 0),
                    title = {},
                    navigationIcon = {
                        BSWBackButton(
                            onClick = onBackStack,
                            tint = MaterialTheme.colorScheme.primary
                        )
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.surface
                    )
                )
            }
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .padding(paddingValues)
                .fillMaxSize()
                .windowInsetsPadding(WindowInsets.safeDrawing),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Text(
                text = displayMessage,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp),
                textAlign = TextAlign.Center
            )
            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Button(onClick = onRetry) { Text("Retry") }
            }
        }
    }
}

private fun Throwable.toDisplayMessage(): String {
    val preferred = localizedMessage ?: message
    val fallback = preferred ?: toString()

    val optionalRegex = Regex("""errorDescription:\s*Optional\("(.+)"\)""")
    optionalRegex.find(fallback)?.groupValues?.getOrNull(1)?.let { extracted ->
        if (extracted.isNotBlank()) return extracted
    }

    return fallback
}

/**
 * Fallback loading UI used by [BSWAsyncView] when the consumer does not inject a
 * custom loading view.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BSWDefaultAsyncLoadingView(
    showBackButton: Boolean = true
) {
    val onBackPressedDispatcher = LocalOnBackPressedDispatcherOwner.current?.onBackPressedDispatcher
    val onBackStack: () -> Unit = {
        onBackPressedDispatcher?.onBackPressed()
    }

    Scaffold(
        modifier = Modifier.fillMaxWidth(),
        contentWindowInsets = WindowInsets(0, 0, 0, 0),
        topBar = {
            if (showBackButton) {
                TopAppBar(
                    windowInsets = WindowInsets(0, 0, 0, 0),
                    title = {},
                    navigationIcon = {
                        BSWBackButton(
                            onClick = onBackStack,
                            tint = MaterialTheme.colorScheme.primary
                        )
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.surface
                    )
                )
            }
        }
    ) { paddingValues ->
        Box(
            modifier =
                Modifier
                    .padding(paddingValues)
                    .fillMaxSize()
                    .windowInsetsPadding(WindowInsets.safeDrawing),
            contentAlignment = Alignment.Center,
        ) {
            CircularProgressIndicator()
        }
    }
}
