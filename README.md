# Clyvo - Sistema de Gestão Veterinária

> API REST desenvolvida com Java Spring Boot para gestão de clínicas veterinárias, veterinários, animais, consultas e vacinação.

---

## Índice

- [Descrição do Projeto](#-descrição-do-projeto)
- [Benefícios para o Negócio](#-benefícios-para-o-negócio)
- [Arquitetura Macro](#️-arquitetura-macro)
- [Rotas da API](#-rotas-da-api)
- [Instalação (How To)](#-instalação-how-to)
- [Dockerfile](#-dockerfile)
- [Docker Compose](#-docker-compose)
- [Script Azure CLI](#-script-azure-cli)
- [Equipe](#-equipe)

---

## Descrição do Projeto

O **Clyvo** é um Sistema Integrado desenvolvido para transformar a gestão de clínicas veterinárias e a saúde preventiva dos animais através de uma solução centralizada e integrada com **Inteligência Artificial** e **IoT** (ESP32 e sensores).

A plataforma centraliza o controle de:

- **Clínicas veterinárias** e seus endereços
- **Veterinários** vinculados às clínicas
- **Animais** com ficha cadastral completa (RG, microchip, espécie, raça, peso)
- **Carteira vacinal** dos animais
- **Consultas** com histórico e status (AGENDADA, REALIZADA, CANCELADA)
- **Prescrições e medicamentos** emitidos em consultas
- **Logs** de operações do sistema

A API segue os padrões REST, possui documentação automática via **Swagger/OpenAPI**, paginação de resultados e cache de consultas frequentes.

---

## Benefícios para o Negócio

| Benefício | Descrição |
|-----------|-----------|
| **Centralização de dados** | Elimina o uso de planilhas e papéis, centralizando todas as informações em um único sistema |
| **Agilidade no atendimento** | Veterinários acessam o histórico completo do animal em segundos |
| **Controle vacinal** | Alertas de vacinas pendentes e atrasadas evitam riscos à saúde dos animais |
| **Histórico de consultas** | Registro completo de cada atendimento com prescrições e medicamentos |
| **Rastreabilidade** | Log de todas as operações para auditoria |
| **Disponibilidade em nuvem** | Sistema acessível de qualquer lugar via API REST |

---

## Arquitetura Macro



---

## Rotas da API

### Veterinários — `/vets`

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/vets` | Lista todos os veterinários |
| `GET` | `/vets/{id}` | Busca veterinário por ID |
| `POST` | `/vets` | Cadastra novo veterinário |
| `PUT` | `/vets/{id}` | Atualiza dados cadastrais do veterinário |
| `DELETE` | `/vets/{id}` | Remove um veterinário |

### Consultas — `/consultas`

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/consultas?page=0&size=10` | Lista consultas paginadas |
| `GET` | `/consultas/{id}` | Busca consulta por ID |
| `GET` | `/consultas/vet/{id}` | Lista todas as consultas de um veterinário |
| `GET` | `/consultas/vet/{id}/hoje` | Consultas do dia de um veterinário |
| `GET` | `/consultas/vet/{id}/filtrar?status=AGENDADA` | Filtra consultas por status |
| `POST` | `/consultas` | Cadastra nova consulta |
| `DELETE` | `/consultas/{id}` | Remove uma consulta |

> Documentação completa disponível em: `http://<IP>:8080/swagger-ui.html`

---

## Instalação (How To)

### Pré-requisitos
- Docker e Docker Compose instalados
- Git instalado

### Passo a passo

**1. Clone os repositórios**
```bash
git clone https://github.com/Eduardo-Locaspi/Clyvo-JavaAdvanced.git
git clone https://github.com/Eduardo-Locaspi/Clyvo_Cloud.git
```

**2. Entre na pasta DevOps**
```bash
cd Clyvo_Cloud
```

**3. Crie o arquivo `.env`**
```bash
touch .env
nano .env
```

Cole o conteúdo abaixo no arquivo `.env`:
```env
ORACLE_PASSWORD=Oracle123
ORACLE_USER=clyvo_user
ORACLE_USER_PASSWORD=Clyvo123
SPRING_DATASOURCE_URL=jdbc:oracle:thin:@//oracle-clyvo:1521/XEPDB1
```

**4. Suba os containers**
```bash
docker compose up -d --build
```

> O Oracle XE demora alguns minutos para iniciar. Aguarde antes de testar a API.

**5. Verifique se está rodando**
```bash
docker compose ps
docker compose logs api-clyvo
```

**6. Acesse a API**
- API: `http://localhost:8080`
- Swagger: `http://localhost:8080/swagger-ui.html`

---

### Testando o CRUD

**Listar veterinários (GET)**
```bash
curl -X GET http://localhost:8080/vets
```

**Criar veterinário (POST)**
```bash
curl -X POST http://localhost:8080/vets \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Liana Teste",
    "cpf": "37925356880",
    "crmv": "CRMV-SP11111",
    "email": "liana.teste@email.com",
    "senha": "senha123"
  }'
```

**Atualizar veterinário (PUT) — substituir {id} pelo ID retornado no POST**
```bash
curl -X PUT http://localhost:8080/vets/{id} \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Liana Teste ALTERADO",
    "cpf": "37925356880",
    "crmv": "CRMV-SP22222",
    "email": "liana.alterado@email.com",
    "senha": "senha123"
  }'
```

**Deletar veterinário (DELETE) — substituir {id} pelo ID retornado no POST**
```bash
curl -X DELETE http://localhost:8080/vets/{id}
```

**Parar a aplicação**
```bash
docker compose down
```

---

## Dockerfile

O arquivo `Dockerfile.api` está disponível no repositório [`Clyvo-JavaAdvanced`](https://github.com/Eduardo-Locaspi/Clyvo-JavaAdvanced).

```dockerfile
# Estágio 1: Build da aplicação com Maven e aproveitamento de cache
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests
# Estágio 2: Imagem enxuta para execução
FROM eclipse-temurin:21-jre-alpine
RUN addgroup -S clyvoappuser && adduser -S -G clyvoappuser clyvoappuser
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
RUN chown clyvoappuser:clyvoappuser app.jar
USER clyvoappuser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

## Docker Compose

```yaml
services:
  oracle-clyvo:
    container_name: oracle-clyvo
    image: gvenzl/oracle-xe:21-slim-faststart
    ports:
      - "1521:1521"
    networks:
      - clyvo-network
    volumes:
      - oracle-clyvo-data:/opt/oracle/oradata
    restart: unless-stopped
    env_file:
      - .env
    environment:
      ORACLE_PASSWORD: ${ORACLE_PASSWORD}
      APP_USER: ${ORACLE_USER}
      APP_USER_PASSWORD: ${ORACLE_USER_PASSWORD}
    healthcheck:
      test: ["CMD", "healthcheck.sh"]
      interval: 10s
      timeout: 20s
      retries: 10
      start_period: 120s

  api-clyvo:
    container_name: api-clyvo
    build:
      context: ../Clyvo-JavaAdvanced
      dockerfile: Dockerfile.api
    ports:
      - "8080:8080"
    networks:
      - clyvo-network
    env_file:
      - .env
    environment:
      SPRING_DATASOURCE_URL: ${SPRING_DATASOURCE_URL}
      SPRING_DATASOURCE_USERNAME: ${ORACLE_USER}
      SPRING_DATASOURCE_PASSWORD: ${ORACLE_USER_PASSWORD}
      SPRING_JPA_HIBERNATE_DDL_AUTO: create
      SPRING_SQL_INIT_MODE: always
      SPRING_JPA_DATABASE_PLATFORM: org.hibernate.dialect.OracleDialect
    depends_on:
      oracle-clyvo:
        condition: service_healthy
    restart: unless-stopped

networks:
  clyvo-network:

volumes:
  oracle-clyvo-data:
```

---

## Script Azure CLI

O script completo está disponível em [`azure-cli.sh`](./azure-cli.sh).

**Resumo do que o script faz:**
1. Cria um Resource Group no Azure (região: canadacentral)
2. Provisiona uma VM Linux Ubuntu 24.04 (tamanho: Standard_B2als_v2)
3. Abre as portas 8080 (API) e 1521 (Oracle)
4. Instala Git, Nano e demais ferramentas
5. Instala e configura o Docker

**Para deletar os recursos após a avaliação:**
```bash
az group delete --name rg-clyvoliana --yes --no-wait
```

---

## Equipe

Turma: 2TDSPI

| RM | Nome |
|----|------|
| RM561713 | Eduardo Batista Locaspi |
| RM565799 | Leticia Santiago e Silva |
| RM565698 | Liana Lyumi Morisita Fujisima |
| RM561833 | Victor Alves Lopes |
