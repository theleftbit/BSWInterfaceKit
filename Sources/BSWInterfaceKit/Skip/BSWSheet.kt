package bswinterface.kit

import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.material3.BottomSheetDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.ModalBottomSheetProperties
import androidx.compose.material3.SheetState
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp

/**
 * Shared modal bottom sheet helpers for Android.
 *
 * The sheet content is wrapped in a scoped Swift view-model owner so Swift-backed
 * state behaves the same way in sheet presentations as it does in pushed screens.
 */
@OptIn(ExperimentalMaterial3Api::class)
object BSWSheet {
    @Composable
    fun Default(
        visible: Boolean,
        interactiveDismissDisabled: Boolean = false,
        sheetState: SheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        sheetGesturesEnabled: Boolean = true,
        sheetMaxWidth: Dp = BottomSheetDefaults.SheetMaxWidth,
        containerColor: Color = Color.White,
        contentWindowInsets: @Composable () -> WindowInsets = { BottomSheetDefaults.windowInsets },
        dragHandle: @Composable (() -> Unit)? = { BottomSheetDefaults.DragHandle() },
        onDismiss: () -> Unit,
        content: @Composable () -> Unit,
    ) {
        BaseSheet(
            initialItem = Unit.takeIf { visible },
            sheetState = sheetState,
            interactiveDismissDisabled = interactiveDismissDisabled,
            sheetGesturesEnabled = sheetGesturesEnabled,
            sheetMaxWidth = sheetMaxWidth,
            containerColor = containerColor,
            contentWindowInsets = contentWindowInsets,
            dragHandle = dragHandle,
            onDismiss = onDismiss,
            content = { content() },
        )
    }

    @Composable
    fun <Item : Any> Default(
        item: Item?,
        interactiveDismissDisabled: Boolean = false,
        sheetState: SheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        sheetGesturesEnabled: Boolean = true,
        sheetMaxWidth: Dp = BottomSheetDefaults.SheetMaxWidth,
        containerColor: Color = Color.White,
        contentWindowInsets: @Composable () -> WindowInsets = { BottomSheetDefaults.windowInsets },
        dragHandle: @Composable (() -> Unit)? = { BottomSheetDefaults.DragHandle() },
        contentScopeKey: (Item) -> Any = { it },
        onDismiss: () -> Unit,
        content: @Composable (Item) -> Unit,
    ) {
        BaseSheet(
            initialItem = item,
            contentIdentity = item?.let(contentScopeKey),
            sheetState = sheetState,
            interactiveDismissDisabled = interactiveDismissDisabled,
            sheetGesturesEnabled = sheetGesturesEnabled,
            sheetMaxWidth = sheetMaxWidth,
            containerColor = containerColor,
            contentWindowInsets = contentWindowInsets,
            dragHandle = dragHandle,
            onDismiss = onDismiss,
            content = content,
        )
    }

    @Composable
    private fun <Item : Any> BaseSheet(
        initialItem: Item?,
        contentIdentity: Any? = initialItem,
        sheetState: SheetState,
        interactiveDismissDisabled: Boolean,
        sheetGesturesEnabled: Boolean,
        sheetMaxWidth: Dp,
        containerColor: Color,
        contentWindowInsets: @Composable () -> WindowInsets,
        dragHandle: @Composable (() -> Unit)?,
        onDismiss: () -> Unit,
        content: @Composable (Item) -> Unit,
    ) {
        var isSheetOpen by remember { mutableStateOf(initialItem != null) }
        var presentationId by remember { mutableLongStateOf(if (initialItem != null) 1L else 0L) }
        var activeItem by remember { mutableStateOf(initialItem) }
        var activeIdentity by remember { mutableStateOf(contentIdentity) }

        LaunchedEffect(initialItem, contentIdentity) {
            if (initialItem != null) {
                if (!isSheetOpen || activeIdentity != contentIdentity) {
                    presentationId += 1
                }
                activeItem = initialItem
                activeIdentity = contentIdentity
                isSheetOpen = true
            } else if (isSheetOpen) {
                try {
                    sheetState.hide()
                } catch (_: Exception) {
                } finally {
                    isSheetOpen = false
                    activeItem = null
                    activeIdentity = null
                }
            }
        }

        val item = activeItem
        if (isSheetOpen && item != null) {
            ModalBottomSheet(
                properties = ModalBottomSheetProperties(
                    shouldDismissOnBackPress = !interactiveDismissDisabled,
                ),
                onDismissRequest = {
                    if (!interactiveDismissDisabled) {
                        onDismiss()
                    }
                },
                sheetState = sheetState,
                sheetGesturesEnabled = sheetGesturesEnabled && !interactiveDismissDisabled,
                sheetMaxWidth = sheetMaxWidth,
                containerColor = containerColor,
                contentWindowInsets = contentWindowInsets,
                dragHandle = dragHandle,
            ) {
                key(presentationId) {
                    BSWWithScopedSwiftViewModelOwner(scopeKey = presentationId) {
                        content(item)
                    }
                }
            }
        }
    }
}
