package bswinterface.kit

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import kotlinx.coroutines.CancellationException
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
    internal var isRunning by mutableStateOf(false)
    internal var errorText by mutableStateOf<String?>(null)

    fun trigger(input: Input) {
        requestID += 1
        pendingRequest = BlockingTaskRequest(id = requestID, input = input)
    }

    fun dismissError() {
        errorText = null
    }
}

@Composable
fun <Input> rememberBlockingTaskState(): BlockingTaskState<Input> {
    return remember { BlockingTaskState() }
}

@Composable
fun <Input> PerformBlockingTask(
    state: BlockingTaskState<Input>,
    loadingTitle: String,
    confirmationStrategy: AsyncBlockingTaskConfirmationStrategy = AsyncBlockingTaskConfirmationStrategy.NotRequired,
    errorMessage: (Throwable?) -> String = { throwable -> normalizeAsyncButtonErrorMessage(throwable) },
    task: suspend (Input) -> Unit,
    content: @Composable () -> Unit
) {
    PerformBlockingTaskHost(
        state = state,
        loadingTitle = loadingTitle,
        confirmationStrategy = confirmationStrategy,
        errorMessage = errorMessage,
        task = task
    )
    content()
}

@Composable
fun <Input> PerformBlockingTaskHost(
    state: BlockingTaskState<Input>,
    loadingTitle: String,
    confirmationStrategy: AsyncBlockingTaskConfirmationStrategy = AsyncBlockingTaskConfirmationStrategy.NotRequired,
    errorMessage: (Throwable?) -> String = { throwable -> normalizeAsyncButtonErrorMessage(throwable) },
    task: suspend (Input) -> Unit
) {
    val scope = rememberCoroutineScope()
    var confirmationRequest by remember(state) { mutableStateOf<BlockingTaskRequest<Input>?>(null) }

    fun launchTask(request: BlockingTaskRequest<Input>) {
        state.isRunning = true
        state.errorText = null
        scope.launch {
            try {
                task(request.input)
            } catch (cancellationException: CancellationException) {
                throw cancellationException
            } catch (throwable: Throwable) {
                state.errorText = errorMessage(throwable)
            } finally {
                state.isRunning = false
            }
        }
    }

    LaunchedEffect(state.pendingRequest?.id, state.isRunning, confirmationStrategy) {
        val request = state.pendingRequest ?: return@LaunchedEffect
        if (state.isRunning) return@LaunchedEffect

        state.pendingRequest = null
        when (confirmationStrategy) {
            AsyncBlockingTaskConfirmationStrategy.NotRequired -> launchTask(request)
            is AsyncBlockingTaskConfirmationStrategy.ConfirmWith -> confirmationRequest = request
        }
    }

    if (state.isRunning) {
        Dialog(
            onDismissRequest = {},
            properties = DialogProperties(
                dismissOnBackPress = false,
                dismissOnClickOutside = false
            )
        ) {
            Surface(
                shape = RoundedCornerShape(20.dp),
                color = MaterialTheme.colorScheme.surface
            ) {
                Column(
                    modifier = Modifier.padding(horizontal = 28.dp, vertical = 24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    CircularProgressIndicator()
                    Text(
                        text = loadingTitle,
                        style = MaterialTheme.typography.bodyMedium,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }

    if (state.errorText != null) {
        AlertDialog(
            onDismissRequest = { state.dismissError() },
            confirmButton = {
                TextButton(onClick = { state.dismissError() }) {
                    Text("OK")
                }
            },
            text = {
                Text(
                    text = state.errorText.orEmpty(),
                    textAlign = TextAlign.Center
                )
            }
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
}
