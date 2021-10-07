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

- Para a execução local, utilize o comando abaixo para subir o container com o banco de dados:
  ```sh
  make container-start
  ```

- Para parar a execução, utilize o comando:
  ```sh
  make container-stop
  ```

- Para obter os status do container, utilize o comando:
  ```sh
  make container-status
  ```

- Todos os comandos completos podem ser encontrados no arquivo `Makefile` na raiz do projeto.

<!-- CONECTANDO-BANCO -->
## Conectando-se ao banco de dados

- Para conectar-se ao banco de dados utilize a ferramente [Adminer](https://www.adminer.org) disponibilizada pelo próprio container, ou a que preferir (como [pgAdmin](https://www.pgadmin.org), [DataGrip](https://www.jetbrains.com/pt-br/datagrip/), ...).

- Dentro da ferramente utilize os seguintes dados para fazer a conexão:
  | Chave     | Valor          |
  |-----------|----------------|
  | DB        | postgres       |
  | USER      | BDAFahadG1     |
  | PASSWORD  | edlindo123     |
  | PORT      | 5432           |
