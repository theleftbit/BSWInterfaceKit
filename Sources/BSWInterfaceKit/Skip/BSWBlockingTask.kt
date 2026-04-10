package bswinterface.kit

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

sealed interface AsyncBlockingTaskConfirmationStrategy {
    data object NotRequired : AsyncBlockingTaskConfirmationStrategy

    data class ConfirmWith(
        val title: String,
        val message: String,
        val confirmButtonTitle: String,
        val cancelButtonTitle: String,
        val isDestructiveAction: Boolean = false
    ) : AsyncBlockingTaskConfirmationStrategy
}

internal data class BlockingTaskRequest<Input>(
    val id: Long,
    val input: Input
)

@Stable
class BlockingTaskState<Input> internal constructor() {
    private var requestID by mutableLongStateOf(0L)

    internal var pendingRequest by mutableStateOf<BlockingTaskRequest<Input>?>(null)

    fun trigger(input: Input) {
        requestID += 1
        pendingRequest = BlockingTaskRequest(id = requestID, input = input)
    }
}

@Composable
fun <Input> rememberBlockingTaskState(): BlockingTaskState<Input> {
    return remember { BlockingTaskState() }
}

private val LocalBlockingTaskError =
    staticCompositionLocalOf<Throwable?> { null }

@Composable
fun currentBlockingTaskError(): Throwable? = LocalBlockingTaskError.current

private sealed interface BlockingTaskHudState {
    data object None : BlockingTaskHudState
    data class Loading(val title: String) : BlockingTaskHudState
    data class Success(val message: String?) : BlockingTaskHudState
    data class Error(val message: String) : BlockingTaskHudState
}

private enum class BlockingTaskHudKind {
    Loading,
    Success,
    Error
}

@Composable
fun <Input> PerformBlockingTask(
    state: BlockingTaskState<Input>,
    loadingTitle: String,
    successMessage: String? = null,
    successDisplayMillis: Long = 1000L,
    confirmationStrategy: AsyncBlockingTaskConfirmationStrategy = AsyncBlockingTaskConfirmationStrategy.NotRequired,
    errorMessage: (Throwable?) -> String = { throwable -> normalizeAsyncButtonErrorMessage(throwable) },
    errorDisplayMillis: Long = 1500L,
    scrimAlpha: Float = 0.35f,
    task: suspend (Input) -> Unit,
    content: @Composable () -> Unit
) {
    val lastError = rememberBlockingTaskPresenter(
        state = state,
        loadingTitle = loadingTitle,
        successMessage = successMessage,
        successDisplayMillis = successDisplayMillis,
        confirmationStrategy = confirmationStrategy,
        errorMessage = errorMessage,
        errorDisplayMillis = errorDisplayMillis,
        scrimAlpha = scrimAlpha,
        task = task
    )

    CompositionLocalProvider(LocalBlockingTaskError provides lastError) {
        content()
    }
}

@Composable
private fun <Input> rememberBlockingTaskPresenter(
    state: BlockingTaskState<Input>,
    loadingTitle: String,
    successMessage: String?,
    successDisplayMillis: Long,
    confirmationStrategy: AsyncBlockingTaskConfirmationStrategy,
    errorMessage: (Throwable?) -> String,
    errorDisplayMillis: Long,
    scrimAlpha: Float,
    task: suspend (Input) -> Unit
): Throwable? {
    val scope = rememberCoroutineScope()
    var hudState by remember(state) { mutableStateOf<BlockingTaskHudState>(BlockingTaskHudState.None) }
    var confirmationRequest by remember(state) { mutableStateOf<BlockingTaskRequest<Input>?>(null) }
    var isRunning by remember(state) { mutableStateOf(false) }
    var lastError by remember(state) { mutableStateOf<Throwable?>(null) }

    fun launchTask(request: BlockingTaskRequest<Input>) {
        isRunning = true
        lastError = null
        hudState = BlockingTaskHudState.Loading(loadingTitle)

        scope.launch {
            try {
                task(request.input)

                if (!successMessage.isNullOrBlank()) {
                    hudState = BlockingTaskHudState.Success(successMessage)
                    delay(successDisplayMillis)
                }
            } catch (cancellationException: CancellationException) {
                hudState = BlockingTaskHudState.None
                throw cancellationException
            } catch (throwable: Throwable) {
                lastError = throwable
                val resolvedMessage = errorMessage(throwable)
                    .takeUnless { it.isNullOrBlank() }
                    ?: normalizeAsyncButtonErrorMessage(throwable)

                hudState = BlockingTaskHudState.Error(resolvedMessage)
                delay(errorDisplayMillis)
                lastError = null
            } finally {
                hudState = BlockingTaskHudState.None
                isRunning = false
            }
        }
    }

    LaunchedEffect(state.pendingRequest?.id, isRunning, confirmationStrategy) {
        val request = state.pendingRequest ?: return@LaunchedEffect
        if (isRunning) return@LaunchedEffect

        state.pendingRequest = null
        when (confirmationStrategy) {
            AsyncBlockingTaskConfirmationStrategy.NotRequired -> launchTask(request)
            is AsyncBlockingTaskConfirmationStrategy.ConfirmWith -> confirmationRequest = request
        }
    }

    when (val currentHudState = hudState) {
        BlockingTaskHudState.None -> Unit
        is BlockingTaskHudState.Loading -> BlockingTaskHudDialog(
            visible = true,
            text = currentHudState.title,
            kind = BlockingTaskHudKind.Loading,
            scrimAlpha = scrimAlpha
        )

        is BlockingTaskHudState.Success -> BlockingTaskHudDialog(
            visible = true,
            text = currentHudState.message,
            kind = BlockingTaskHudKind.Success,
            scrimAlpha = scrimAlpha
        )

        is BlockingTaskHudState.Error -> BlockingTaskHudDialog(
            visible = true,
            text = currentHudState.message,
            kind = BlockingTaskHudKind.Error,
            scrimAlpha = scrimAlpha
        )
    }

    val confirmation = confirmationRequest
    if (confirmation != null && confirmationStrategy is AsyncBlockingTaskConfirmationStrategy.ConfirmWith) {
        AlertDialog(
            onDismissRequest = { confirmationRequest = null },
            title = { Text(confirmationStrategy.title) },
            text = { Text(confirmationStrategy.message) },
            confirmButton = {
                TextButton(
                    onClick = {
                        confirmationRequest = null
                        launchTask(confirmation)
                    }
                ) {
                    Text(
                        text = confirmationStrategy.confirmButtonTitle,
                        color = if (confirmationStrategy.isDestructiveAction) {
                            MaterialTheme.colorScheme.error
                        } else {
                            MaterialTheme.colorScheme.primary
                        }
                    )
                }
            },
            dismissButton = {
                TextButton(onClick = { confirmationRequest = null }) {
                    Text(confirmationStrategy.cancelButtonTitle)
                }
            }
        )
    }

    return lastError
}

@Composable
private fun BlockingTaskHudDialog(
    visible: Boolean,
    text: String?,
    kind: BlockingTaskHudKind,
    scrimAlpha: Float
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
                color = MaterialTheme.colorScheme.surface,
                modifier = Modifier
                    .align(Alignment.Center)
                    .padding(horizontal = 32.dp)
            ) {
                Column(
                    modifier = Modifier.padding(horizontal = 24.dp, vertical = 20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    when (kind) {
                        BlockingTaskHudKind.Loading -> CircularProgressIndicator(modifier = Modifier.size(32.dp))
                        BlockingTaskHudKind.Success -> Icon(
                            imageVector = Icons.Filled.Check,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.size(32.dp)
                        )

                        BlockingTaskHudKind.Error -> Icon(
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
                            style = MaterialTheme.typography.bodyMedium.copy(
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        )
                    }
                }
            }
        }
    }
}
