# Caçada ao Tesouro Docker

> **Missão:** colocar no ar uma aplicação web de dois serviços, escrevendo você mesmo o **Dockerfile** e o **docker-compose.yml**.
> O primeiro time que conseguir e mostrar ao instrutor **ganha o bis**.

---

## 1. O que é esta aplicação?

É uma aplicação web pequena, dividida em **duas partes**, cada uma rodando em seu próprio container:

| Serviço | O que faz | Imagem |
|---|---|---|
| **`site`** | Servidor web (nginx) que entrega a página para o navegador. É a única parte acessível de fora. | **Você constrói** (Dockerfile) |
| **`api`** | Servidor que guarda a mensagem de vitória. Só o `site` conversa com ela. | **Pronta**, baixada do Docker Hub |

Como as peças se conectam:

```
 navegador                    seu PC (Docker)
┌──────────┐          ┌──────────────────────────────────┐
│          │  :8080   │  ┌────────┐         ┌────────┐   │
│  Chrome  │ ───────► │  │  site  │ ──────► │  api   │   │
│          │          │  │ (nginx)│  /api/  │ (nginx)│   │
└──────────┘          │  └────────┘         └───┬────┘   │
                      │                         │        │
                      │                  pasta api/ do   │
                      │                   seu computador │
                      └──────────────────────────────────┘
```

1. O navegador acessa o `site` pela porta **8080** do seu PC.
2. A página, ao abrir, pede a mensagem de vitória para o endereço `/api/mensagem.txt`.
3. O `site` repassa esse pedido ao serviço `api`.
4. A `api` responde com o conteúdo do arquivo `mensagem.txt`.

Se tudo estiver certo, a mensagem aparece na tela. Se a `api` não for encontrada, a página fica em **"Aguardando a API..."**.

---

## 2. O que você recebe

```
desafio/
├── ENUNCIADO.md              
├── api/
│   └── mensagem.txt (a API serve este arquivo)
└── site/
    ├── index.html (a página)
    ├── estilo.css (o visual)
    └── nginx.conf (configuração do nginx)
```

Todos esses arquivos **já estão prontos. Não é preciso editá-los.**

## 3. O que você precisa criar

```
desafio/
├── docker-compose.yml
└── site/
    └── Dockerfile
```

---

## 4. Requisitos

### 4.1. Dockerfile do `site` (`site/Dockerfile`)

A imagem do site deve:

- [ ] Partir da imagem **`nginx`**, na versão leve baseada em **Alpine** (tag `alpine`). Confira no [Docker Hub](https://hub.docker.com/_/nginx) como ela se chama.
- [ ] Ter o `index.html` e o `estilo.css` dentro da pasta **`/usr/share/nginx/html`** (é onde o nginx procura o site dentro dessa imagem).
- [ ] Ter o `nginx.conf` em **`/etc/nginx/conf.d/default.conf`**.
- [ ] Criar, **durante a construção da imagem**, o arquivo `build.txt` com a hora do build. O comando que faz isso é:
  ```
  echo "Imagem construída em $(date)" > /usr/share/nginx/html/build.txt
  ```
  *(Descubra qual instrução do Dockerfile executa um comando durante o build.)*
- [ ] Ao iniciar o container, o **nginx deve ficar rodando em primeiro plano**. Se o container encerrar sozinho, algo está errado.

O nginx do `site` escuta na **porta 80** dentro do container.

### 4.2. Compose (`docker-compose.yml`)

O arquivo deve descrever **dois serviços**:

**Serviço `site`**
- [ ] É **construído** a partir da pasta `./site` (onde está o seu Dockerfile).
- [ ] Publica a porta **8080 do seu PC** na **porta 80 do container**.
- [ ] Só deve iniciar **depois** da `api`.

**Serviço `api`**
- [ ] O nome do serviço deve ser exatamente **`api`**. O `nginx.conf` do site usa esse nome para encontrá-la. Qualquer outro nome quebra a comunicação.
- [ ] Usa a imagem pronta **`nginx:alpine`**, sem construir nada.
- [ ] Mostra a pasta **`./api`** do seu computador dentro do container, em **`/usr/share/nginx/html`**, como **somente leitura**.
- [ ] **Não** publica nenhuma porta no seu PC. Só o `site` deve ser acessível de fora.

---

## 5. Como saber que você venceu

Rode, na pasta `desafio/`:

```bash
docker compose up --build
```

Você venceu quando **todos** os itens abaixo forem verdadeiros:

1. [ ] `docker compose ps` mostra os **dois** containers (`site` e `api`) em execução.
2. [ ] **http://localhost:8080** mostra o troféu 🏆 e a mensagem de vitória.
3. [ ] Na parte de baixo da página aparece **"Imagem construída em ..."** com a data e a hora **de agora**.
4. [ ] **http://localhost:8080/api/mensagem.txt** devolve o texto da mensagem.
5. [ ] A `api` **não** aparece com porta publicada no `docker compose ps`.

Quando conseguir, **chame o instrutor**. Ele confere os 5 itens na sua tela e faz **uma pergunta** sobre o que você construiu.

---

## 6. Regras

- Times de **2 a 3 pessoas**.
- Escreva o **Dockerfile** e o **Compose** com as próprias mãos. Pode usar a colinha, os slides, a documentação e a internet, mas **não vale copiar a solução pronta** de outro time.
- Cada time pode pedir **uma dica** ao instrutor.
- Os arquivos fornecidos (`index.html`, `estilo.css`, `nginx.conf`, `mensagem.txt`) **não precisam de alteração**.

---

## 7. Vocabulário que vai ajudar

### Dockerfile

| Instrução | Para que serve |
|---|---|
| `FROM` | Define a imagem de onde tudo começa |
| `COPY` | Copia arquivos do seu computador para dentro da imagem |
| `RUN` | Executa um comando **durante a construção** da imagem |
| `CMD` | Define o comando executado **quando o container inicia** |

Formato: `COPY ORIGEM DESTINO`. A origem é relativa à pasta onde o Dockerfile está (o *contexto* do build).

### docker-compose.yml

| Campo | Para que serve | Equivale a |
|---|---|---|
| `services` | Lista os containers da aplicação | cada `docker run` |
| `build` | Constrói a imagem a partir de uma pasta com Dockerfile | `docker build` |
| `image` | Usa uma imagem pronta do registry | o nome da imagem no `docker run` |
| `ports` | Publica uma porta do container no seu PC | `-p` |
| `volumes` | Mostra uma pasta do seu PC dentro do container | `-v` |
| `depends_on` | Define a ordem de inicialização | (sem equivalente) |

---

## 8. Se travar

- **`docker compose ps -a`** e **`docker compose logs`** costumam dizer o que houve.
- Mudou o Dockerfile? Rode de novo com **`--build`**, senão o Docker reaproveita a imagem antiga.
- Um problema às vezes **esconde** o seguinte. Corrija um de cada vez.
- Alguns defeitos **não geram mensagem de erro**: a página só não funciona. Aí é hora de investigar entrando no container.
- Dúvida sobre uma imagem? A página dela no [Docker Hub](https://hub.docker.com) explica o que ela espera.

Boa sorte!
