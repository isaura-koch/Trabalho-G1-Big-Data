--RODAR CADA INSERT UNICAMENTE
--SE DER ERRO, RODA DE NOVO

set search_path to trabalho_g1;

INSERT INTO cidade(nome, uf) VALUES ('Passo Fundo', 'rs'), ('Florianópolis', 'sc');

INSERT INTO cliente(nome, sobrenome, cpf, endereco_entrega, cod_cidade, status)
SELECT md5((RANDOM()::TEXT))::varchar(11),
	md5((RANDOM()::TEXT))::varchar(11),
	md5((RANDOM()::TEXT))::varchar(11),
	md5(RANDOM()::TEXT),
	(select cod_cidade from cidade order by random() limit 1), 
	CASE WHEN RANDOM() < 0.5 THEN 'A' ELSE 'I' END
	FROM generate_series(1, 100);
		
INSERT INTO periodicidade(descricao)
	VALUES('MENSAL'),('SEMANAL'),('DIÁRIA');
	
INSERT INTO tipo_espetaculo(descricao)
	select md5((RANDOM()::TEXT))::varchar(11)
	FROM generate_series(1,100);
	
INSERT INTO estabelecimento(nome, endereco, tem_estacionamento, cod_tipo_espetaculo, cod_cidade)
	select md5((RANDOM()::TEXT))::varchar(11),
	md5((RANDOM()::TEXT))::varchar(11),
	CASE WHEN RANDOM() < 0.7 THEN TRUE
	ELSE FALSE END,
	(select cod_tipo_espetaculo from tipo_espetaculo order by random() limit 1),
	(select cod_cidade from cidade order by random() limit 1)
	FROM generate_series(1,100);
	
INSERT INTO espetaculo(nome, descricao, cod_estabelecimento)
	SELECT md5((RANDOM()::TEXT))::varchar(11),
	md5((RANDOM()::TEXT))::varchar(11),
	(select cod_estabelecimento from estabelecimento order by random() limit 1)
	FROM generate_series(1,100);
	
	
INSERT INTO sessao(cod_espetaculo, data_hora_inicio, duracao, total_ingressos, ingressos_disponiveis, preco, cod_periodicidade)
	SELECT (select cod_espetaculo from espetaculo order by random() limit 1),
	now(),
	(random() * 10 + 20),
	(random() * 47 + 100::INT),
	(random() * 47 + 10::INT),
	(random() * 10 + 20),
	(select cod_periodicidade from periodicidade order by random() limit 1)
	FROM generate_series(1,100);


INSERT INTO pedido(cod_cliente, data_pedido, status)
	SELECT (RANDOM() + (select cod_cliente from cliente order by random() limit 1)),
	now(),
	CASE WHEN RANDOM() < 0.2 THEN 'I'
	ELSE 'A' END	
	FROM generate_series(1,100);
	
	
INSERT INTO reserva(cod_pedido, cod_espetaculo, cod_sessao, cadeira)
	SELECT (RANDOM() + (select cod_pedido from pedido order by random() limit 1)),
	(select cod_espetaculo from espetaculo order by random() limit 1),
	(select cod_sessao from sessao order by random() limit 1),
	md5((RANDOM()::TEXT))::varchar(4)
	FROM generate_series(1,100);
