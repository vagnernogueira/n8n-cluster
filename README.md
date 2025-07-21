# n8n-cluster: Instalação n8n com Escalabilidade

Este projeto configura um ambiente n8n robusto e escalável, em container, utilizando múltiplos workers e webhooks, com persistência de dados para PostgreSQL, Redis e o próprio n8n. A gestão do ambiente é simplificada através de um `Makefile` inteligente que se adapta ao seu sistema, funcionando com **Podman** ou **Docker**.

## Pré-requisitos

- **Runtime de Contêiner**: É necessário ter **Podman** ou **Docker** instalado e em execução no seu sistema. O `Makefile` dará preferência ao Podman, se ambos estiverem disponíveis.
- **GNU Make**: A ferramenta `make` precisa estar instalada para utilizar os comandos de automação.
- **Shell Compatível**: Um shell compatível (como Git Bash, WSL ou um shell padrão de Linux/macOS) é necessário para que os scripts no `Makefile` funcionem corretamente.

## Configuração

Antes de iniciar o ambiente, é preciso configurar as variáveis de ambiente.

**Edite o arquivo `.env`**:
    Abra o arquivo `.env` e ajuste as variáveis conforme necessário, especialmente as credenciais do banco de dados e as configurações específicas do n8n, ou utilize as configurações propostas no arquivo.

## Como Utilizar

O `Makefile` automatiza as operações mais comuns. Abaixo estão os comandos disponíveis:

| Comando | Descrição |
| :--- | :--- |
| `make` ou `make all` | **Comando padrão.** Inicia a VM do Podman (se aplicável) e sobe todos os serviços. |
| `make deploy` | Inicia e executa os contêineres em modo detached. |
| `make undeploy` | Para e remove todos os contêineres do projeto. |
| `make backup` | Executa o backup de todos os volumes de dados (PostgreSQL, Redis e n8n). |
| `make backup-postgres` | Faz o backup exclusivo do volume do PostgreSQL. |
| `make backup-redis` | Faz o backup exclusivo do volume do Redis. |
| `make backup-n8n` | Faz o backup exclusivo do volume de dados do n8n. |
| `make list-volumes` | Lista todos os volumes gerenciados pelo motor de contêiner. |
| `make start-vm` | **(Apenas Podman)** Inicia a máquina virtual do Podman. |

### Acesso

-   Acesse `http://localhost:5676/` no seu navegador para visualizar e configurar o n8n.
-   Acesse `http://localhost:15432/` no seu navegador para visualizar o pgAdmin. Veja o arquivo .env para configurar o acesso.
-   Acesse `http://localhost:16379/` no seu navegador para visualizar o Redis Insight.

## Arquitetura de Serviços

Este projeto utiliza `docker-compose.yml` para orquestrar os seguintes serviços:

-   `n8n-editor`: A interface principal do n8n para criação e edição de workflows.
-   `n8n-workers`: Instâncias de workers para processar as execuções dos workflows de forma escalável.
-   `n8n-webhooks`: Instâncias dedicadas para lidar com requisições de webhooks.
-   `postgres`: Banco de dados PostgreSQL para persistência dos dados dos workflows. A versão utilizada ankane/pgvector possibilita armazenamento de dados vetorias, isto é util para utilizar em projetos de IA com RAG.
-   `redis`: Servidor Redis utilizado para gerenciamento de fila e cache.
-   `pgadmin4`: Interface web para administração do PostgreSQL.
-   `redisinsight`: Interface web para visualização e gerenciamento de dados no Redis.

## Persistência e Backup

Os dados são persistidos em volumes para garantir que não sejam perdidos ao reiniciar os contêineres.

-   **Volumes**:
    -   `n8n-data`: Armazena as configurações e workflows do n8n.
    -   `postgres-data`: Armazena os dados do PostgreSQL.
    -   `redis-data`: Armazena os dados do Redis.
    -   `pgadmin4-data`: Armazena as configurações do pgAdmin.
    -   `redisinsight-data`: Armazena as configurações do Redis Insight.

-   **Backup**:
    Os backups são gerados como arquivos `.tar.gz` e salvos no diretório `volume-bkp/`. Utilize o comando `make backup` para garantir a segurança dos seus dados.