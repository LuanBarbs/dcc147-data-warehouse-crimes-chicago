# Passo 1: Carga dos dados no PostgreSQL

## 1. Criar o banco de dados

Para o comando abaixo funcionar, o diretório bin do PostgreSQL deve estar na variável de ambiente PATH.

```bash
psql --version
> psql (PostgreSQL) 18.4

psql -U postgres -p PORT

exemplo: psql -U postgres -p 5433

CREATE DATABASE chicago_crimes;
```

## 2. Instalar as dependências Python

Na pasta do projeto:

```bash
pip install -r requirements.txt
```

## 3. Criar um arquivo .env

Na raiz do projeto, crie um arquivo chamado .env seguindo o exemplo de `.env.example`.

## 4. Executar o script

```bash
python src/load_data.py
```

Pode demorar

## 5. Verificar a carga

```bash
psql -U postgres -p PORT -d chicago_crimes
SELECT COUNT(*) FROM crimes_raw;
SELECT * FROM crimes_raw LIMIT 5;
```

---