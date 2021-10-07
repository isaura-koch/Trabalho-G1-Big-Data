------Procedure A
--Procedure que cria uma sessão, usando os parametros necesários da tabela sessao

CREATE OR REPLACE PROCEDURE criar_sessoes(IN in_cod_espet INT, IN in_inicio TIMESTAMP WITHOUT TIME ZONE, IN in_cod_periodicidade INT, IN in_durac INT, in_preco IN NUMERIC)
LANGUAGE plpgsql AS $$
	BEGIN

		INSERT INTO sessao (cod_espetaculo, data_hora_inicio, duracao, preco, cod_periodicidade) 
		VALUES (in_cod_espet, in_inicio, in_durac, in_preco, in_cod_periodicidade);

	END
	$$;
	
--Ex:
	-- DO
	-- $$
	-- DECLARE	
	
	-- 	cod_espet INT := 2114;
	-- 	dt_inicio TIMESTAMP WITHOUT TIME ZONE := CURRENT_DATE;
	-- 	cod_periodicidade INT := 4;
	-- 	duracao INT := 120;
	-- 	preco NUMERIC := 27.52;
	-- 	cod_novo INT;
		
	-- BEGIN 
	
	-- 	CALL criar_sessoes(cod_espet, dt_inicio, cod_periodicidade, duracao, preco);
	-- 	cod_novo := (SELECT MAX(cod_sessao) FROM sessao);
	-- 	RAISE NOTICE 'Cód. Criado: %', cod_novo;
	-- END;
	-- $$

-----Procedure B
--Define a quantidade de ingressos que determinada sessão terá em sua totalidade

CREATE OR REPLACE PROCEDURE define_total_ingressos(IN in_cod_sec INT, IN in_total_ing INT)
LANGUAGE plpgsql AS $$
	BEGIN

		UPDATE sessao SET total_ingressos = in_total_ing 
		WHERE cod_sessao = in_cod_sec;

	END;
	$$;
	
--Ex:
	-- DO
	-- $$
	-- DECLARE
	
	-- 	cod_ses INT := 1360;
	-- 	tot_ingressos INT := 250;
		
	-- BEGIN 
	
	-- 	CALL define_total_ingressos(cod_ses, tot_ingressos);
		
	-- END;
	-- $$

-- SELECT cod_sessao, total_ingressos FROM sessao where cod_sessao = 1360

----Procedure C
--Cria um pedido com as informações nos parametros e retorna o código do pedido criado

CREATE OR REPLACE PROCEDURE criar_pedido(IN in_data_pedido TIMESTAMP WITHOUT TIME ZONE, IN in_cod_cliente INT, INOUT out_cod_ped INT)
LANGUAGE plpgsql AS $$
	BEGIN
		
		--O pedido só será criado se o cliente estiver ativo
		IF (SELECT status FROM cliente WHERE cod_cliente = in_cod_cliente) != 'I' THEN
			
			INSERT INTO pedido(cod_cliente, data_pedido, status)
			VALUES(in_cod_cliente, in_data_pedido, 'A') RETURNING cod_pedido INTO out_cod_ped;
		ELSE
			RAISE EXCEPTION 'O cliente de cód. % está inativo!', in_cod_cliente
			USING HINT = 'Selecione um cliente Ativo';
		END IF;
	END;
	$$;

--Ex:

-- DO
-- 	$$
-- 	DECLARE
	
-- 		dt_pedido TIMESTAMP WITHOUT TIME ZONE := CURRENT_DATE;
-- 		cod_cliente_ativo INT := 115;
-- 		cod_cliente_inativo INT := 114;
-- 		cod_pedido_criado INT;
		
-- 	BEGIN 
-- 		--Cliente Ativo
-- 		CALL criar_pedido(dt_pedido, cod_cliente_ativo, cod_pedido_criado);
-- 		RAISE NOTICE 'Pedido Criado: %', cod_pedido_criado;
-- 		--Cliente Inativo
-- 		CALL criar_pedido(dt_pedido, cod_cliente_inativo, cod_pedido_criado);
		
		
-- 	END;
-- 	$$

----Procedure D
--Cria uma reserva com os dados inseridos nos parametros

CREATE OR REPLACE PROCEDURE criar_reserva(IN in_cod_espet INT, IN in_cod_sec INT, IN in_cod_ped INT, IN in_cadeira VARCHAR(10))
LANGUAGE plpgsql AS $$
	BEGIN
		--Validação se a sessão informada existe
		IF EXISTS (SELECT cod_sessao FROM sessao WHERE cod_sessao = in_cod_sec) THEN
			--Validação se o espetaculo informado existe
			IF EXISTS (SELECT cod_espetaculo FROM espetaculo WHERE cod_espetaculo = in_cod_espet) THEN
				
				INSERT INTO reserva(cod_pedido, cod_espetaculo, cod_sessao, cadeira)
				VALUES(in_cod_ped, in_cod_espet, in_cod_sec, in_cadeira);
			ELSE
				RAISE EXCEPTION 'Não existe espetaculo com o Cód. %', in_cod_espet
				USING HINT = 'Selecione um Cód. válido.';
			END IF;
			
		ELSE
			RAISE EXCEPTION 'Não existe sessão com o Cód. %', in_cod_sec
			USING HINT = 'Selecione um Cód. válido.';
		END IF;			
		
	END;
	$$;
	
--Ex:

	-- DO
	-- $$
	-- DECLARE
	
	-- 	cod_espetaculo_existente INT := 2116;
	-- 	cod_sessao_existente INT := 1309;
	-- 	cod_pedido_existente INT := 5414;
		
	-- 	cod_espetaculo_inexistente INT := 50;
	-- 	cod_sessao_inexistente INT := 1293;
	-- 	cod_pedido_inexistente INT := 12;
		
	-- 	cadeira VARCHAR(10) = md5((RANDOM()::TEXT))::varchar(10);
		
	-- 	reserva_criada INT;
		
	-- BEGIN 
	-- 	--Sessao e Espetaculo Existentes
	-- 	CALL criar_reserva(cod_espetaculo_existente, cod_sessao_existente, cod_pedido_existente, cadeira);
	-- 	reserva_criada := (SELECT MAX(cod_reserva) FROM reserva);
	-- 	RAISE NOTICE 'Cód. Criado: %', reserva_criada;
		
	-- 	--Sessao Inexistentes
	-- 	CALL criar_reserva(cod_espetaculo_existente, cod_sessao_inexistente, cod_pedido_existente, cadeira);
		
	-- 	--Espetaculo Inexistentes
	-- 	CALL criar_reserva(cod_espetaculo_inexistente, cod_sessao_existente, cod_pedido_existente, cadeira);
		
		
	-- END;
	-- $$
	

----Procedure E
--Criará um novo registro na tabela historico, informando o valor total de cada pedido feito pelo cliente selecionado num período de 30 dias

-- Reserva → Sessao
--   |→ Pedido
 
CREATE OR REPLACE PROCEDURE registra_notificacao(IN in_cod_cliente INT)
LANGUAGE plpgsql AS $$
	
	DECLARE
		--Declaração do cursor
		cod_pedido_existente INT;
	
	BEGIN
		
		--Preenchimento do cursor, usando o código do cliente fornecido
		FOR cod_pedido_existente IN
			SELECT p.cod_pedido FROM pedido p 
			WHERE cod_cliente = in_cod_cliente AND 
			data_pedido BETWEEN current_date - 30 AND current_date
			
		LOOP 
			--Insersão dos valores na tabela, caso os pedidos retornados ainda não estejam na tabela notificacao
			IF NOT EXISTS(SELECT cod_pedido FROM notificacao where cod_pedido = cod_pedido_existente) THEN
				INSERT INTO notificacao (data_notificacao, cod_pedido, mensagem)
					SELECT current_date,
					cod_pedido_existente,
					'Total dos gastos: ' || 
						--Soma do valor das sessões, usando o cód. do pedido como base
						(SELECT SUM(preco) FROM sessao s
						JOIN reserva r ON s.cod_sessao = r.cod_sessao
						WHERE r.cod_pedido = cod_pedido_existente);
			END IF;
		END LOOP;

	END;

--Ex:

	-- DO
	-- $$
	-- DECLARE
	-- 	cod_cliente INT := 203;	
	-- BEGIN 
	-- 	CALL registra_notificacao(203);
	-- END;
	-- $$

	-- select * from notificacao

--insert into reserva (cod_pedido, cod_espetaculo, cod_sessao, cadeira) values (5418, 2123,1302, 'aaaabb')
--insert into reserva (cod_pedido, cod_espetaculo, cod_sessao, cadeira) values (5434, 2125,1307, 'aaaabb')
--insert into reserva (cod_pedido, cod_espetaculo, cod_sessao, cadeira) values (5495, 2155,1357, 'aaaabb')