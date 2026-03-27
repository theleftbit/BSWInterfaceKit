package bswinterface.kit

import android.os.SystemClock
import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

enum class AsyncButtonHudKind { Loading, Success, Error }

enum class AsyncButtonState { Idle, Loading }

/**
 * Describes how [BSWAsyncButton] exposes loading state on Android.
 *
 * This is the plain shared configuration that app-level wrappers can reuse while
 * still drawing their own branded button UI.
 */
@Stable
data class BSWAsyncButtonLoadingConfiguration(
    val message: String? = null,
    val style: Style = Style.Inline(tint = null)
) {
    sealed interface Style {
        data class Inline(
            val tint: Color? = null,
            val errorMessageMillis: Long = 1500L
        ) : Style

        data class Blocking(
            val dimsBackground: Boolean = true,
            val scrimAlpha: Float = 0.35f,
            val horizontalMargin: Dp = 32.dp,
            val successMessage: String? = null,
            val successMessageMillis: Long = 1200L,
            val errorMessageMillis: Long = 1500L
        ) : Style
    }

    val isBlocking: Boolean get() = style is Style.Blocking
}

val LocalAsyncButtonLoadingConfiguration =
    staticCompositionLocalOf { BSWAsyncButtonLoadingConfiguration() }

val LocalAsyncButtonOperationKey =
    staticCompositionLocalOf<String?> { null }

/**
 * Provides the loading configuration consumed by [BSWAsyncButton] and
 * [rememberAsyncButtonController].
 */
@Composable
fun ProvideAsyncButtonLoadingConfiguration(
    message: String? = null,
    style: BSWAsyncButtonLoadingConfiguration.Style = BSWAsyncButtonLoadingConfiguration.Style.Inline(),
    content: @Composable () -> Unit
) {
    CompositionLocalProvider(
        LocalAsyncButtonLoadingConfiguration provides BSWAsyncButtonLoadingConfiguration(message, style),
        content = content
    )
}

/**
 * Adds an identifier used only for debug tracing of async button operations.
 */
@Composable
fun ProvideAsyncButtonOperationIdentifierKey(
    key: String?,
    content: @Composable () -> Unit
) {
    CompositionLocalProvider(
        LocalAsyncButtonOperationKey provides key,
        content = content
    )
}

/**
 * Shared async state holder used by Android button wrappers.
 *
 * The idea is that product-specific buttons can reuse the async behavior from BSW
 * without having to duplicate loading, error and blocking HUD orchestration.
 */
@Stable
class AsyncButtonController internal constructor(
    loadingConfiguration: BSWAsyncButtonLoadingConfiguration,
    private var onClickImpl: () -> Unit
) {
    var loadingConfiguration by mutableStateOf(loadingConfiguration)
        internal set

    var state by mutableStateOf(AsyncButtonState.Idle)
        internal set

    var hudKind by mutableStateOf<AsyncButtonHudKind?>(null)
        internal set

    var hudText by mutableStateOf<String?>(null)
        internal set

    val isLoading: Boolean get() = state == AsyncButtonState.Loading

    fun onClick() {
        onClickImpl()
    }

    internal fun updateOnClick(onClick: () -> Unit) {
        onClickImpl = onClick
    }
}

/**
 * Creates the controller used by [BSWAsyncButton] and by custom app-level wrappers.
 */
@Composable
fun rememberAsyncButtonController(
    action: suspend () -> Unit,
    errorMessageResolver: (Throwable?) -> String = { throwable ->
        normalizeAsyncButtonErrorMessage(throwable)
    }
): AsyncButtonController {
    val loadingConfig = LocalAsyncButtonLoadingConfiguration.current
    val operationKey = LocalAsyncButtonOperationKey.current
    val scope = rememberCoroutineScope()
    val latestAction by rememberUpdatedState(action)
    val latestErrorMessageResolver by rememberUpdatedState(errorMessageResolver)

    val controller = remember {
        AsyncButtonController(
            loadingConfiguration = loadingConfig,
            onClickImpl = {}
        )
    }

    controller.loadingConfiguration = loadingConfig
    controller.updateOnClick {
        if (controller.state == AsyncButtonState.Loading) return@updateOnClick

        controller.state = AsyncButtonState.Loading
        scope.launch {
            val styleLocal = controller.loadingConfiguration.style
            val startNanos = SystemClock.elapsedRealtimeNanos()

            if (styleLocal is BSWAsyncButtonLoadingConfiguration.Style.Blocking) {
                controller.hudKind = AsyncButtonHudKind.Loading
                controller.hudText = controller.loadingConfiguration.message
            }

            val result = runCatching { latestAction() }

            operationKey?.takeIf { it.isNotBlank() }?.let { key ->
                val endNanos = SystemClock.elapsedRealtimeNanos()
                val seconds = (endNanos - startNanos) / 1_000_000_000.0
                Log.d("AsyncOpTracer", "Loading async-button-$key took $seconds seconds")
            }

            if (result.isFailure) {
                val throwable = result.exceptionOrNull()
                if (throwable is CancellationException) {
                    controller.hudKind = null
                    controller.hudText = null
                    controller.state = AsyncButtonState.Idle
                    return@launch
                }

                val errorMillis = when (styleLocal) {
                    is BSWAsyncButtonLoadingConfiguration.Style.Blocking -> styleLocal.errorMessageMillis
                    is BSWAsyncButtonLoadingConfiguration.Style.Inline -> styleLocal.errorMessageMillis
                }

                controller.hudKind = AsyncButtonHudKind.Error
                controller.hudText = latestErrorMessageResolver(throwable)
                delay(errorMillis)
                controller.hudKind = null
                controller.hudText = null
            } else if (styleLocal is BSWAsyncButtonLoadingConfiguration.Style.Blocking) {
                val successMessage = styleLocal.successMessage
                if (!successMessage.isNullOrBlank()) {
                    controller.hudKind = AsyncButtonHudKind.Success
                    controller.hudText = successMessage
                    delay(styleLocal.successMessageMillis)
                }
                controller.hudKind = null
                controller.hudText = null
            }

            controller.state = AsyncButtonState.Idle
        }
    }

    return controller
}

@Composable
fun DefaultAsyncButtonProgressView(
    style: BSWAsyncButtonLoadingConfiguration.Style
) {
    val (tint, size) = when (style) {
        is BSWAsyncButtonLoadingConfiguration.Style.Inline -> {
            (style.tint ?: MaterialTheme.colorScheme.onPrimary) to 16.dp
        }
        is BSWAsyncButtonLoadingConfiguration.Style.Blocking -> {
            MaterialTheme.colorScheme.primary to 32.dp
        }
    }

    CircularProgressIndicator(
        modifier = Modifier.size(size),
        color = tint
    )
}

/**
 * Plain Compose async button.
 *
 * Consumers can use it directly or build custom buttons on top of
 * [rememberAsyncButtonController] when they need a branded layout.
 */
@Composable
fun BSWAsyncButton(
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    bgColor: Color? = null,
    disabledColor: Color? = null,
    txtColor: Color? = null,
    disableTextColor: Color? = null,
    action: suspend () -> Unit,
    errorMessageResolver: (Throwable?) -> String = { throwable ->
        normalizeAsyncButtonErrorMessage(throwable)
    },
    progressView: @Composable (BSWAsyncButtonLoadingConfiguration.Style) -> Unit = { style ->
        DefaultAsyncButtonProgressView(style = style)
    },
    label: @Composable RowScope.() -> Unit
) {
    val controller = rememberAsyncButtonController(
        action = action,
        errorMessageResolver = errorMessageResolver
    )

    val backgroundColor = if (enabled) {
        bgColor ?: MaterialTheme.colorScheme.primary
    } else {
        disabledColor ?: MaterialTheme.colorScheme.tertiary
    }

    val contentColor = if (enabled) {
        txtColor ?: MaterialTheme.colorScheme.onPrimary
    } else {
        disableTextColor ?: MaterialTheme.colorScheme.onTertiary
    }

    val blockingStyle =
        controller.loadingConfiguration.style as? BSWAsyncButtonLoadingConfiguration.Style.Blocking

    AsyncButtonBlockingHudDialog(
        visible = controller.hudKind != null,
        text = controller.hudText,
        kind = controller.hudKind ?: AsyncButtonHudKind.Loading,
        scrimAlpha = if (blockingStyle?.dimsBackground != false) {
            blockingStyle?.scrimAlpha ?: 0.35f
        } else {
            0f
        },
        horizontalMargin = blockingStyle?.horizontalMargin ?: 32.dp,
        loadingView = {
            progressView(controller.loadingConfiguration.style)
        }
    )

    Button(
        modifier = modifier,
        onClick = controller::onClick,
        enabled = enabled && !controller.isLoading,
        colors = ButtonDefaults.buttonColors(
            containerColor = backgroundColor,
            contentColor = contentColor,
            disabledContainerColor = backgroundColor,
            disabledContentColor = contentColor
        ),
        shape = RoundedCornerShape(8.dp)
    ) {
        if (!controller.loadingConfiguration.isBlocking && controller.isLoading) {
            AsyncButtonInlineLoadingView(
                message = controller.loadingConfiguration.message,
                style = controller.loadingConfiguration.style,
                progressView = progressView
            )
        } else {
            label()
        }
    }
}

@Composable
private fun AsyncButtonInlineLoadingView(
    message: String?,
    style: BSWAsyncButtonLoadingConfiguration.Style,
    progressView: @Composable (BSWAsyncButtonLoadingConfiguration.Style) -> Unit
) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        progressView(style)
        if (!message.isNullOrBlank()) {
            Spacer(Modifier.size(8.dp))
            Text(message, style = MaterialTheme.typography.bodySmall)
        }
    }
}

@Composable
private fun AsyncButtonBlockingHudDialog(
    visible: Boolean,
    text: String?,
    kind: AsyncButtonHudKind,
    scrimAlpha: Float,
    horizontalMargin: Dp,
    loadingView: @Composable () -> Unit
) {
    if (!visible) return

    Dialog(
        onDismissRequest = {},
        properties = DialogProperties(
            dismissOnBackPress = false,
            dismissOnClickOutside = false,
            usePlatformDefaultWidth = false
        )
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = scrimAlpha))
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null
                ) {}
        ) {
            Surface(
                shape = RoundedCornerShape(16.dp),
                tonalElevation = 8.dp,
                shadowElevation = 8.dp,
                modifier = Modifier
                    .align(Alignment.Center)
                    .padding(horizontal = horizontalMargin)
            ) {
                Column(
                    modifier = Modifier.padding(horizontal = 24.dp, vertical = 20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    when (kind) {
                        AsyncButtonHudKind.Loading -> loadingView()
                        AsyncButtonHudKind.Success -> Icon(
                            imageVector = Icons.Filled.Check,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.size(32.dp)
                        )
                        AsyncButtonHudKind.Error -> Icon(
                            imageVector = Icons.Filled.Close,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.error,
                            modifier = Modifier.size(32.dp)
                        )
                    }

                    text?.takeIf { it.isNotBlank() }?.let {
                        Text(
                            text = it,
                            textAlign = TextAlign.Center,
                            style = MaterialTheme.typography.bodyMedium
                        )
                    }
                }
            }
        }
    }
}
