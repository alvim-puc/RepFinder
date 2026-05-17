export interface Service {
  name: string
  start(): Promise<void>
  stop?(): Promise<void>
}

const registry: Service[] = []

export function register(service: Service): void {
  registry.push(service)
}

export async function startAll(): Promise<void> {
  for (const service of registry) {
    await service.start()
    console.log(`[${service.name}] iniciado`)
  }
}

export async function stopAll(): Promise<void> {
  for (const service of [...registry].reverse()) {
    await service.stop?.()
    console.log(`[${service.name}] encerrado`)
  }
}