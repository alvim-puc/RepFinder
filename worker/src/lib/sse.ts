type SSEWriter = WritableStreamDefaultWriter<Uint8Array>

export const connections = new Map<string, SSEWriter>()

export async function notify(userId: string, event: string, data: unknown) {
  const writer = connections.get(userId)
  if (!writer) return  // usuário offline — evento foi perdido

  const chunk = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`
  await writer.write(new TextEncoder().encode(chunk))
}