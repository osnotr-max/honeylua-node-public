# Honeylua Support — bot de tickets para Discord

Versão **2.10.2** · Node.js 20+ · Docker Compose e painel Pterodactyl.

Bot de suporte com tickets, transcrições e ranking da equipe. Usa a API nativa `fetch` e um cliente WebSocket leve (`ws`), sem `discord.js`.

## Antes de subir

- Crie a aplicação/bot no [Discord Developer Portal](https://discord.com/developers/applications), convide-o para o servidor e tenha à mão o token e os IDs do servidor/categoria/canal de log.
- Os IDs de servidor, canais e cargos são configurados no `.env`; nenhum ID de servidor fica fixo no código.
- O perfil foi configurado para VPS pequena: heap V8 limitado a 128 MB e sem porta HTTP de entrada. Uma VPS de 256 MB pode ficar apertada por causa do sistema operacional e do Docker; acompanhe o uso de memória.
- O repositório é público; ainda assim, mantenha o token do bot somente no `.env` da VPS.

## Instalação na VPS (Docker Compose)

Na VPS, instale Git, Docker Engine e o plugin Docker Compose v2. Clone o repositório e configure:

```bash
git clone https://github.com/osnotr-max/honeylua-node-public.git
cd honeylua-node-public
cp .env.example .env
nano .env
chmod 600 .env
```

Edite `.env` e preencha:

```env
DISCORD_TOKEN=token_real_do_bot
GUILD_ID=id_do_servidor
TICKET_CATEGORY_ID=id_da_categoria_de_tickets
LOG_CHANNEL_ID=id_do_canal_de_logs
STAFF_ROLE_ID=id_do_cargo_da_equipe
STAFF_REPORT_ROLE_IDS=id_cargo_a,id_cargo_b
USER_REPORT_ROLE_ID=id_do_cargo_de_denuncia
SUPPORT_MENTION_ROLE_IDS=id_cargo_a,id_cargo_b
```

Preencha todos os IDs obrigatórios com IDs numéricos do seu servidor. As variáveis terminadas em `_IDS` aceitam vários IDs separados por vírgula. `TRANSCRIPT_CHANNEL_ID` é opcional e, se ficar vazio, usa `LOG_CHANNEL_ID`; limites e ajustes vêm com valores padrão em `.env.example`.

Suba o bot:

```bash
docker compose up -d --build
docker compose ps
docker compose logs -f --tail=100
```

O Compose mantém o ranking em um volume Docker (`honeylua-data`), reinicia o bot após reinicializações da VPS e limita a rotação dos logs. Não é necessário abrir porta no firewall: a conexão com o Discord é de saída.

## NexCloud Bot Hosting (Pterodactyl)

O repositório também pode ser executado pelo painel de hospedagem de bots, sem editar o `Startup Command`:

1. Use o **Git Deploy** com `https://github.com/osnotr-max/honeylua-node-public.git` e branch `main`. Como o repositório é público, deixe Git Username e Git Access Token vazios.
2. Em **Startup Settings**, deixe **User Uploaded Files** como `False` e **Auto Update** como `True`.
3. Em **Main File**, informe `src/index.js`. O comando gerado pelo painel usa esse campo para localizar o ponto de entrada.
4. No **File Manager**, crie `.env` na raiz do servidor e copie as variáveis de `.env.example`, preenchendo os valores reais. O `dotenv` carrega o arquivo ao iniciar; não publique o `.env` no GitHub.
5. Inicie o servidor e acompanhe o Console. O painel executa `npm install` a partir do `package.json`; não é necessário preencher Additional Node Packages.

O bot suporta a imagem Node.js 20 exibida no painel NexCloud. Não altere o Docker Image nem o Startup Command.

## Atualizar e operar

```bash
cd ~/honeylua-node-public
git pull --ff-only
docker compose up -d --build
docker compose logs -f --tail=100
```

Para parar sem apagar o ranking:

```bash
docker compose down
```

**Não use `docker compose down -v`** a menos que queira apagar também o volume persistente do ranking. Guarde `.env` e o volume `honeylua-data` em backup; o token nunca deve ser enviado ao GitHub.

## Rodar sem Docker (opcional)

Requer Node.js **20 ou superior** (recomendado: 24):

```bash
cp .env.example .env
# edite .env com os dados reais
npm run check
npm start
```

## Segurança e configuração

- `.env`, dados locais e logs estão no `.gitignore`; o arquivo versionado `.env.example` contém apenas valores de exemplo.
- O container roda como usuário não-root e o Docker Compose persiste o arquivo de ranking fora do container.
- O ZIP original não incluía credenciais reais nem licença de uso. Não publique como código aberto sem confirmar os direitos de distribuição.
