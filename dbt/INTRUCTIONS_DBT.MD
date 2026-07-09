## Passo a passo de execução

### 1. Pré-requisitos

- Python 3.9+ instalado
- Postgres local, com a tabela `crimes_raw` carregada

### 2. Instalar dbt-core e o adaptador Postgres 

Recomenda-se um ambiente virtual isolado:

```bash
pip install dbt-core dbt-postgres
dbt --version                     # confirma a instalação
```

### 3. Configurar a conexão (profiles.yml)
```bash
dbt init
```
Insira as inflrmações para conecção com o postgres

### 4. Entrar na pasta do projeto e instalar dependências (dbt_utils)

```bash
cd dw_crimes_chicago
dbt deps
```

### 5. Testar a conexão com o banco

```bash
dbt debug
```

Deve mostrar `All checks passed!`. Se falhar, revise host/porta/usuário/senha
em `~/.dbt/profiles.yml`.

### 7. Rodar projeto

```bash
dbt build
```
As tabelas e vies vao aprarecer no Postgres

### 8. Gerar e visualizar a documentação/linhagem (lineage graph)

```bash
dbt docs generate
dbt docs serve
```

Abre em `http://localhost:8080` — mostra o grafo de dependências (staging →
dimensões → fatos) e a documentação de cada coluna, exatamente o que o
enunciado pede como "documentação e linhagem automáticas".

