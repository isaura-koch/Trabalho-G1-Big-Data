-- 4a
CREATE OR REPLACE FUNCTION trabalho_g1.fn_reserva_ingressos_se_disponiveis()
RETURNS TRIGGER AS
$BODY$
DECLARE
    quantidade_ingressos_disponiveis INT;
BEGIN
    SELECT ingressos_disponiveis INTO quantidade_ingressos_disponiveis
	FROM trabalho_g1.sessao
	WHERE cod_sessao = NEW.cod_sessao;

	IF (quantidade_ingressos_disponiveis = 0) THEN
		RAISE EXCEPTION 'Nao é possivel fazer a reserva, pois nao ha ingressos disponiveis';
    END IF;

	RETURN NEW;
END
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reserva_ingressos_se_disponiveis
	BEFORE INSERT ON trabalho_g1.reserva
	FOR EACH ROW
	EXECUTE PROCEDURE trabalho_g1.fn_reserva_ingressos_se_disponiveis();

-- Exemplos para 4a
-- SELECT * FROM trabalho_g1.sessao WHERE ingressos_disponiveis != 0 LIMIT 1;
-- SELECT * FROM trabalho_g1.reserva ORDER BY cod_reserva DESC;
-- UPDATE trabalho_g1.sessao SET ingressos_disponiveis = 0 WHERE cod_sessao in (SELECT cod_sessao FROM trabalho_g1.sessao WHERE ingressos_disponiveis > 0 LIMIT 1);

-- Erro (4a)
-- INSERT INTO trabalho_g1.reserva(cod_pedido, cod_espetaculo, cod_sessao, cadeira)
-- VALUES (
-- 	(SELECT cod_pedido FROM trabalho_g1.pedido LIMIT 1),
-- 	(SELECT cod_espetaculo FROM trabalho_g1.espetaculo LIMIT 1),
-- 	(SELECT cod_sessao FROM trabalho_g1.sessao WHERE ingressos_disponiveis = 0 LIMIT 1),
-- 	'B-6'
-- );

-- Sucesso (4a, 4c)
-- INSERT INTO trabalho_g1.reserva(cod_pedido, cod_espetaculo, cod_sessao, cadeira)
-- VALUES (
-- 	(SELECT cod_pedido FROM trabalho_g1.pedido LIMIT 1),
-- 	(SELECT cod_espetaculo FROM trabalho_g1.espetaculo LIMIT 1),
-- 	(SELECT cod_sessao FROM trabalho_g1.sessao WHERE ingressos_disponiveis != 0 LIMIT 1),
-- 	'B-6'
-- );
-- SELECT * FROM trabalho_g1.reserva ORDER BY cod_reserva DESC;
-- SELECT * FROM trabalho_g1.sessao WHERE cod_sessao = (
-- 	SELECT cod_sessao FROM trabalho_g1.reserva ORDER BY cod_reserva DESC LIMIT 1
-- );


-- ======================================================


-- 4b
CREATE TABLE trabalho_g1.historico_reserva (
	cod_hist_reserva SERIAL PRIMARY KEY,
	cod_pedido INT NOT NULL,
	cod_espetaculo INT NOT NULL,
	cod_sessao INT NOT NULL,
	cadeira VARCHAR(10) NOT NULL,
	data_exclusao_reserva DATE DEFAULT CURRENT_DATE
);

CREATE OR REPLACE FUNCTION trabalho_g1.fn_mantem_hist_reserva()
RETURNS TRIGGER AS
$BODY$
BEGIN
	INSERT INTO trabalho_g1.historico_reserva(cod_pedido, cod_espetaculo, cod_sessao, cadeira)
	VALUES (OLD.cod_pedido, OLD.cod_espetaculo, OLD.cod_sessao, OLD.cadeira);

	RETURN OLD;
END
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mantem_hist_reserva
	BEFORE DELETE ON trabalho_g1.reserva
	FOR EACH ROW
	EXECUTE PROCEDURE trabalho_g1.fn_mantem_hist_reserva();

-- Exemplos para 4b e 4d
-- SELECT * FROM trabalho_g1.historico_reserva;
-- DELETE FROM trabalho_g1.reserva
-- WHERE cod_reserva = (
-- 	SELECT cod_reserva FROM trabalho_g1.reserva ORDER BY cod_reserva DESC LIMIT 1
-- );
-- SELECT * FROM trabalho_g1.reserva ORDER BY cod_reserva DESC;
-- SELECT * FROM trabalho_g1.historico_reserva;
-- SELECT * FROM trabalho_g1.sessao WHERE cod_sessao = (
-- 	SELECT cod_sessao FROM trabalho_g1.historico_reserva ORDER BY cod_hist_reserva DESC LIMIT 1
-- );


-- ======================================================


-- 4c
CREATE OR REPLACE FUNCTION trabalho_g1.fn_decrementa_ingressos_disponiveis()
RETURNS TRIGGER AS
$BODY$
DECLARE
	quantidade_ingressos_disponiveis INT;
	nova_quantidade_ingressos_disponiveis INT;
BEGIN
    SELECT ingressos_disponiveis INTO quantidade_ingressos_disponiveis
	FROM trabalho_g1.sessao
	WHERE cod_sessao = NEW.cod_sessao;

	nova_quantidade_ingressos_disponiveis := quantidade_ingressos_disponiveis - 1;

	UPDATE trabalho_g1.sessao
	SET ingressos_disponiveis = nova_quantidade_ingressos_disponiveis
	WHERE cod_sessao = NEW.cod_sessao;

	RETURN NEW;
END
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER trg_decrementa_ingressos_disponiveis
	AFTER INSERT ON trabalho_g1.reserva
	FOR EACH ROW
	EXECUTE PROCEDURE trabalho_g1.fn_decrementa_ingressos_disponiveis();


-- ======================================================


-- 4d
CREATE OR REPLACE FUNCTION trabalho_g1.fn_incrementa_ingressos_disponiveis()
RETURNS TRIGGER AS
$BODY$
DECLARE
	quantidade_ingressos_disponiveis INT;
	nova_quantidade_ingressos_disponiveis INT;
BEGIN
    SELECT ingressos_disponiveis INTO quantidade_ingressos_disponiveis
	FROM trabalho_g1.sessao
	WHERE cod_sessao = OLD.cod_sessao;

	nova_quantidade_ingressos_disponiveis := quantidade_ingressos_disponiveis + 1;

	UPDATE trabalho_g1.sessao
	SET ingressos_disponiveis = nova_quantidade_ingressos_disponiveis
	WHERE cod_sessao = OLD.cod_sessao;

	RETURN OLD;
END
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER trg_incrementa_ingressos_disponiveis
	AFTER DELETE ON trabalho_g1.reserva
	FOR EACH ROW
	EXECUTE PROCEDURE trabalho_g1.fn_incrementa_ingressos_disponiveis();


-- ======================================================


-- 4e
CREATE OR REPLACE FUNCTION trabalho_g1.fn_inativar_pedido()
RETURNS TRIGGER AS
$BODY$
BEGIN
	DELETE FROM trabalho_g1.reserva
	WHERE cod_pedido = OLD.cod_pedido;

	UPDATE trabalho_g1.pedido
	SET status = 'I', data_cancelamento = CURRENT_DATE
	WHERE cod_pedido = OLD.cod_pedido;

	RETURN NULL;
END
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inativar_pedido
	BEFORE DELETE ON trabalho_g1.pedido
	FOR EACH ROW
	EXECUTE PROCEDURE trabalho_g1.fn_inativar_pedido();

-- Exemplos para 4e
-- SELECT * 
-- FROM trabalho_g1.pedido
-- WHERE cod_pedido IN (SELECT cod_pedido FROM trabalho_g1.reserva)
-- ORDER BY cod_pedido;

-- SELECT * FROM trabalho_g1.reserva WHERE cod_pedido = (
-- 	SELECT cod_pedido 
-- 	FROM trabalho_g1.pedido
-- 	WHERE cod_pedido IN (SELECT cod_pedido FROM trabalho_g1.reserva)
-- 	ORDER BY cod_pedido
-- 	LIMIT 1
-- );

-- DELETE FROM trabalho_g1.pedido WHERE cod_pedido = 33;
-- SELECT * FROM trabalho_g1.pedido ORDER BY cod_pedido;
-- SELECT * FROM trabalho_g1.reserva WHERE cod_pedido = 33;


-- ======================================================


-- 4f
CREATE OR REPLACE FUNCTION trabalho_g1.fn_impossibilita_exclusao_cliente()
RETURNS TRIGGER AS
$BODY$
DECLARE
	pedidos_ativos INT;
	msg_padrao VARCHAR;
	msg_pedidos_ativos VARCHAR;
	msg_exception VARCHAR;
BEGIN
	msg_padrao := 'Nao e possivel excluir um cliente, somente modificar seu status.';
	msg_pedidos_ativos := 'Nao modifique o status do cliente para inativo, pois o mesmo possui pedidos ativos.';
    
	SELECT count(status) INTO pedidos_ativos
	FROM trabalho_g1.pedido
	WHERE cod_cliente = OLD.cod_cliente AND status = 'A';

	IF (pedidos_ativos > 0) THEN
		msg_exception := CONCAT(msg_padrao, ' ', msg_pedidos_ativos);
	ELSE
		msg_exception := msg_padrao;
    END IF;

	RAISE EXCEPTION '%', msg_exception;
END
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER trg_impossibilita_exclusao_cliente 
	BEFORE DELETE ON trabalho_g1.cliente
	FOR EACH ROW
	EXECUTE PROCEDURE trabalho_g1.fn_impossibilita_exclusao_cliente();

-- Exemplos para 4f
-- SELECT * FROM trabalho_g1.cliente;
-- SELECT * FROM trabalho_g1.cliente WHERE cod_cliente IN (
-- 	SELECT cod_cliente FROM trabalho_g1.pedido WHERE status = 'A'
-- );

-- SELECT *
-- FROM trabalho_g1.pedido
-- WHERE cod_cliente = 94;

-- UPDATE trabalho_g1.pedido SET status = 'I' WHERE cod_cliente = 95;
-- UPDATE trabalho_g1.pedido SET status = 'A' WHERE cod_cliente = 94;

-- DELETE FROM trabalho_g1.cliente WHERE cod_cliente = 95;
-- DELETE FROM trabalho_g1.cliente WHERE cod_cliente = 94;
