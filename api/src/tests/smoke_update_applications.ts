import http from "http";
import https from "https";

// Configurações — ajuste se necessário
const API_BASE_URL = process.env.API_BASE_URL || "http://localhost:3030/api";
const REPRESENTATIVE_EMAIL =
  process.env.REPRESENTATIVE_EMAIL || "rep@repfinder.com";
const REPRESENTATIVE_PASSWORD =
  process.env.REPRESENTATIVE_PASSWORD || "senha123";

// Helper para fazer requisições usando o módulo nativo do Node.js
function request(
  url: string,
  method: string,
  body?: any,
  token?: string,
): Promise<any> {
  return new Promise((resolve, reject) => {
    const lib = url.startsWith("https") ? https : http;
    const options = {
      method,
      headers: {
        "Content-Type": "application/json",
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
    };

    const req = lib.request(url, options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        try {
          const json = data ? JSON.parse(data) : {};
          if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
            resolve(json);
          } else {
            reject({ status: res.statusCode, data: json });
          }
        } catch (e) {
          reject({ status: res.statusCode, message: "Falha ao parsear JSON" });
        }
      });
    });

    req.on("error", (err) => reject(err));
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function loginAsRepresentative(): Promise<string> {
  console.log("--- Iniciando login como representante ---");
  try {
    const res = await request(`${API_BASE_URL}/users/login`, "POST", {
      email: REPRESENTATIVE_EMAIL,
      password: REPRESENTATIVE_PASSWORD,
    });
    console.log("Representante logado com sucesso.");
    return res.token;
  } catch (error: any) {
    console.log("Falha no login. Tentando registrar novo representante...");
    try {
      await request(`${API_BASE_URL}/users/register`, "POST", {
        name: "Smoke Representative",
        email: REPRESENTATIVE_EMAIL,
        password: REPRESENTATIVE_PASSWORD,
        role: "representative",
      });
      console.log("Representante registrado com sucesso. Fazendo login...");
      const res = await request(`${API_BASE_URL}/users/login`, "POST", {
        email: REPRESENTATIVE_EMAIL,
        password: REPRESENTATIVE_PASSWORD,
      });
      return res.token;
    } catch (registerError: any) {
      console.error(
        "Erro ao registrar/logar:",
        registerError.data || registerError.message,
      );
      throw new Error("Não foi possível autenticar o representante.");
    }
  }
}

async function runSmokeTest() {
  console.log("🚀 Iniciando Smoke Test de Notificações (Nativo)...");
  try {
    const token = await loginAsRepresentative();

    // 1. Buscar vagas do representante
    console.log("Buscando suas vagas...");
    const vacancies = await request(
      `${API_BASE_URL}/vacancies/mine`,
      "GET",
      null,
      token,
    );
    console.log(`Encontradas ${vacancies.length} vagas.`);

    if (vacancies.length === 0) {
      console.log("Nenhuma vaga encontrada. Crie uma vaga antes de testar.");
      return;
    }

    let totalUpdated = 0;

    for (const vacancy of vacancies) {
      // 2. Buscar candidaturas para cada vaga
      console.log(`Buscando candidaturas para: "${vacancy.title}"`);
      const applications = await request(
        `${API_BASE_URL}/applications/vacancies/${vacancy.id}`,
        "GET",
        null,
        token,
      );

      const pending = applications.filter(
        (app: any) => app.status === "pending",
      );
      if (pending.length === 0) continue;

      console.log(`Processando ${pending.length} candidaturas pendentes...`);

      for (const app of pending) {
        // 3. Atualizar status
        const newStatus = Math.random() > 0.5 ? "accepted" : "rejected";
        await request(
          `${API_BASE_URL}/applications/${app.id}/status`,
          "PATCH",
          { status: newStatus },
          token,
        );
        console.log(`  [OK] Candidatura ${app.id} -> ${newStatus}`);
        totalUpdated++;
        await new Promise((r) => setTimeout(r, 300));
      }
    }

    console.log(`\n✅ Teste concluído! Total atualizado: ${totalUpdated}`);
  } catch (error: any) {
    console.error("\n❌ Erro no teste:", error.message || error);
  }
}

runSmokeTest();
