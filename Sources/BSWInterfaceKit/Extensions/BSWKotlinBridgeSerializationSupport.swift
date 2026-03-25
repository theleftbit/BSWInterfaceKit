//
//  BSWKotlinBridgeSerializationSupport.swift
//

/* SKIP INSERT:
internal abstract class ByteArrayDelegatingBridgeSerializer<T>(
    serialName: String
) : kotlinx.serialization.KSerializer<T> {
    private val delegateSerializer = kotlinx.serialization.builtins.ByteArraySerializer()
    final override val descriptor: kotlinx.serialization.descriptors.SerialDescriptor =
        kotlinx.serialization.descriptors.SerialDescriptor(serialName, delegateSerializer.descriptor)

    protected abstract fun toByteArray(value: T): kotlin.ByteArray
    protected abstract fun fromByteArray(bytes: kotlin.ByteArray): T

    final override fun serialize(encoder: kotlinx.serialization.encoding.Encoder, value: T) {
        encoder.encodeSerializableValue(delegateSerializer, toByteArray(value))
    }

    final override fun deserialize(decoder: kotlinx.serialization.encoding.Decoder): T {
        val bytes: kotlin.ByteArray = decoder.decodeSerializableValue(delegateSerializer)
        return fromByteArray(bytes)
    }
}

internal fun encodeTagged(tag: Int, payload: kotlin.ByteArray = kotlin.byteArrayOf()): kotlin.ByteArray {
    require(tag in 0..255) { "Tag must fit in one byte: $tag" }
    return kotlin.byteArrayOf(tag.toByte()) + payload
}

internal inline fun <T> decodeTagged(
    bytes: kotlin.ByteArray,
    block: (tag: Int, payload: kotlin.ByteArray) -> T
): T {
    require(bytes.isNotEmpty()) { "Expected tagged payload but got empty byte array" }
    val tag = bytes[0].toInt() and 0xFF
    val payload = bytes.copyOfRange(1, bytes.size)
    return block(tag, payload)
}

internal fun intToByteArray(value: Int): kotlin.ByteArray =
    kotlin.byteArrayOf(
        ((value shr 24) and 0xFF).toByte(),
        ((value shr 16) and 0xFF).toByte(),
        ((value shr 8) and 0xFF).toByte(),
        (value and 0xFF).toByte()
    )

internal fun byteArrayToInt(bytes: kotlin.ByteArray): Int {
    require(bytes.size == 4) { "Expected exactly 4 bytes for Int, got ${'$'}{bytes.size}" }
    return ((bytes[0].toInt() and 0xFF) shl 24) or
        ((bytes[1].toInt() and 0xFF) shl 16) or
        ((bytes[2].toInt() and 0xFF) shl 8) or
        (bytes[3].toInt() and 0xFF)
}
*/
