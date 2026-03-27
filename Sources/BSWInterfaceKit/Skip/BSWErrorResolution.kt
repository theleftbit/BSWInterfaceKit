package bswinterface.kit

import org.json.JSONObject
import skip.foundation.LocalizedError
import skip.foundation.NSError
import skip.lib.aserror

fun normalizeAsyncButtonErrorMessage(raw: String?): String {
    return extractAsyncButtonErrorMessage(raw) ?: "Something went wrong"
}

fun normalizeAsyncButtonErrorMessage(throwable: Throwable?): String {
    return extractAsyncButtonErrorMessage(throwable) ?: "Something went wrong"
}

fun extractAsyncButtonErrorMessage(throwable: Throwable?): String? {
    if (throwable == null) return null

    return throwable.errorChain()
        .flatMap { current -> current.messageCandidates().asSequence() }
        .mapNotNull(::extractAsyncButtonErrorMessage)
        .firstOrNull()
}

private fun parseAsyncButtonErrorMessage(raw: String): String? {
    parseAsyncButtonJsonMessage(raw)?.let { return it }

    val patterns = listOf(
        Regex("errorDescription:\\s*Optional\\(\"(.+?)\"\\)"),
        Regex("errorDescription:\\s*\"(.+?)\""),
        Regex("\\\\\"message\\\\\"\\s*:\\s*\\\\\"(.+?)\\\\\""),
        Regex("\"message\"\\s*:\\s*\"(.+?)\""),
        Regex("Optional\\(\"(.+?)\"\\)"),
        Regex("Optional\\((.+?)\\)")
    )

    return patterns
        .firstNotNullOfOrNull { pattern ->
            pattern.find(raw)?.groupValues?.getOrNull(1)?.trim()?.trim('"')
        }
        ?.let(::decodeEscapedMessage)
        ?.takeIf { it.isNotBlank() }
}

private fun parseAsyncButtonJsonMessage(raw: String): String? {
    val candidates = buildList {
        add(raw)
        extractJsonObject(raw)?.let(::add)
        unescapeJsonContainer(raw)?.let { unescaped ->
            add(unescaped)
            extractJsonObject(unescaped)?.let(::add)
        }
    }

    return candidates.firstNotNullOfOrNull { candidate ->
        runCatching {
            val jsonObject = JSONObject(candidate)
            jsonObject.optString("message").takeIf { it.isNotBlank() }
                ?: jsonObject.optJSONObject("error")?.optString("message")?.takeIf { it.isNotBlank() }
        }.getOrNull()
    }?.let(::decodeEscapedMessage)
}

private fun extractJsonObject(raw: String): String? {
    val startIndex = raw.indexOf('{')
    val endIndex = raw.lastIndexOf('}')
    if (startIndex == -1 || endIndex <= startIndex) return null
    return raw.substring(startIndex, endIndex + 1)
}

private fun unescapeJsonContainer(raw: String): String? {
    if (!raw.contains("\\\"") && !raw.contains("\\u") && !raw.contains("\\n")) return null

    return raw
        .replace("\\\"", "\"")
        .replace("\\n", "\n")
        .replace("\\r", "\r")
        .replace("\\t", "\t")
}

private fun decodeEscapedMessage(raw: String): String {
    var decoded = raw
        .replace("\\\"", "\"")
        .replace("\\n", "\n")
        .replace("\\r", "\r")
        .replace("\\t", "\t")
        .replace("\\/", "/")

    Regex("""\\u([0-9a-fA-F]{4})""").findAll(decoded).forEach { match ->
        val replacement = match.groupValues[1].toInt(16).toChar().toString()
        decoded = decoded.replace(match.value, replacement)
    }

    return decoded
}

private fun Throwable.errorChain(): Sequence<Throwable> = sequence {
    val visited = LinkedHashSet<Throwable>()
    var current: Throwable? = this@errorChain

    while (current != null && visited.add(current)) {
        yield(current)
        current = current.cause
    }
}

private fun Throwable.messageCandidates(): List<String?> = buildList {
    if (this@messageCandidates is LocalizedError) {
        add(errorDescription)
        add(failureReason)
        add(recoverySuggestion)
    }

    if (this@messageCandidates is NSError) {
        add(localizedDescription)
        add(localizedFailureReason)
        add(localizedRecoverySuggestion)
    }

    if (this@messageCandidates is skip.lib.Error) {
        add(localizedDescription)
    }

    add(aserror().localizedDescription)
    add(localizedMessage)
    add(message)
    add(reflectiveString("errorDescription"))
    add(reflectiveString("localizedDescription"))
    add(reflectiveString("message"))
    add(toString())
}

private fun Throwable.reflectiveString(propertyName: String): String? {
    val getterName = buildString {
        append("get")
        append(propertyName.replaceFirstChar { char -> char.uppercase() })
    }

    return runCatching {
        javaClass.methods
            .firstOrNull { method ->
                method.parameterCount == 0 &&
                    (method.name == getterName || method.name == propertyName) &&
                    method.returnType == String::class.java
            }
            ?.invoke(this) as? String
    }.getOrNull()
}

fun extractAsyncButtonErrorMessage(raw: String?): String? {
    if (raw.isNullOrBlank()) return null
    val trimmed = raw.trim()
    val parsed = parseAsyncButtonErrorMessage(trimmed) ?: trimmed

    if (parsed.isBlank()) return null
    if (parsed.isTechnicalPayload()) return null
    if (parsed.isGenericSystemMessage()) return null

    return parsed
}

private fun String.isTechnicalPayload(): Boolean {
    val normalized = trim()
    if (normalized.matches(Regex("""^\d+\s+bytes\)?$""", RegexOption.IGNORE_CASE))) return true
    if (normalized.contains("failureStatusCode(", ignoreCase = true)) return true
    if (normalized.matches(Regex("""Optional\(\d+\s+bytes\)""", RegexOption.IGNORE_CASE))) return true
    if (normalized.startsWith("Error Domain=", ignoreCase = true)) return true
    return false
}

private fun String.isGenericSystemMessage(): Boolean {
    val normalized = trim()
    return normalized.contains("operation could", ignoreCase = true) &&
        normalized.contains("be completed", ignoreCase = true)
}
