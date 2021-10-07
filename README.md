# Projeto PLpgSQL | G1

Projeto da disciplina  _Big Data / Banco de Dados Avançado_ do curso de _Ciência da Computação_ da faculdade [IMED](https://www.imed.edu.br/).

Este projeto tem como objetivo demonstrar o uso dos recursos da linguagem plpgSQL (PostgreSQL) para manipulação de dados e garantia da consistência destes em um banco de dados.

---
<!-- TECNOLOGIAS -->
## Tecnologias utilizadas
- [Docker](https://docs.docker.com/compose/)
- [PostgreSQL](https://www.postgresql.org)

<!-- REQUERIMENTOS-EXECUCAO -->
## Requerimentos e execução

- Ter o docker/docker-compose instalado e rodando.

- Para a execução local, utilize o comando abaixo para _subir_ o container com o banco de dados:
  ```sh
  make container-start
  ```

- Para _parar_ a execução, utilize o comando:
  ```sh
  make container-stop
  ```

- Para obter os _status_ do container, utilize o comando:
  ```sh
  make container-status
  ```

- Todos os comandos completos podem ser encontrados no arquivo `Makefile` na raiz do projeto.

<!-- CONECTANDO-BANCO -->
## Conectando-se ao banco de dados

- Para fazer a conexão utilize a ferramenta [Adminer](https://www.adminer.org), disponibilizada pelo próprio container na porta _8080_ (http://localhost:8080), ou a que preferir (como [pgAdmin](https://www.pgadmin.org), [DataGrip](https://www.jetbrains.com/pt-br/datagrip/), entre outras).

- Dentro da ferramenta use as seguintes credenciais para fazer a conexão com o banco:
  | Chave     | Valor          |
  |-----------|----------------|
  | DB        | postgres       |
  | USER      | BDAFahadG1     |
  | PASSWORD  | edlindo123     |
  | PORT      | 5432           |
