type SSEWriter = WritableStreamDefaultWriter<Uint8Array>

export const connections = new Map<string, SSEWriter>()

export function registerConnection(userId: string, writer: SSEWriter): void {
  connections.set(userId, writer)
}

export function removeConnection(userId: string): void {
  connections.delete(userId)
}

export async function sendEvent(
  userId: string,
  event: string,
  data: unknown
): Promise<void> {
  const writer = connections.get(userId)
  if (!writer) return

  const chunk = new TextEncoder().encode(
    `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`
  )

  await writer.write(chunk).catch(() => {
    // writer fechado — cliente desconectou entre o check e o write
    removeConnection(userId)
  })
}