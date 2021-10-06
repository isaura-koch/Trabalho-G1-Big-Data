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
-- ...


-- ======================================================


-- 4b
CREATE TABLE trabalho_g1.historico_reserva (
	cod_hist_reserva SERIAL PRIMARY KEY,
	cod_pedido INT NOT NULL,
	cod_espetaculo INT NOT NULL,
	cod_sessao INT NOT NULL,
	cadeira VARCHAR(10) NOT NULL
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

-- Exemplos para 4b
-- ...


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

	nova_quantidade_ingressos_disponiveis := quantidade_ingressos_disponiveis - 1

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

-- Exemplos para 4c
-- ...


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

	nova_quantidade_ingressos_disponiveis := quantidade_ingressos_disponiveis + 1

	UPDATE trabalho_g1.sessao
	SET ingressos_disponiveis = nova_quantidade_ingressos_disponiveis
	WHERE cod_sessao = OLD.cod_sessao;

	RETURN NEW;
END
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER trg_incrementa_ingressos_disponiveis
	AFTER DELETE ON trabalho_g1.reserva
	FOR EACH ROW
	EXECUTE PROCEDURE trabalho_g1.fn_incrementa_ingressos_disponiveis();

-- Exemplos para 4d
-- ...


-- ======================================================


-- 4e
CREATE OR REPLACE FUNCTION trabalho_g1.fn_inativar_pedido()
RETURNS TRIGGER AS
$BODY$
DECLARE

BEGIN
	RETURN NULL;
END
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inativar_pedido
	BEFORE DELETE ON trabalho_g1.pedido
	FOR EACH ROW
	EXECUTE PROCEDURE trabalho_g1.fn_inativar_pedido();

-- Exemplos para 4e
-- ...


-- ======================================================


-- 4f
CREATE OR REPLACE FUNCTION trabalho_g1.fn_impossibilita_exclusao_cliente()
RETURNS TRIGGER AS
$BODY$
DECLARE
	pedidos_ativos INT;
	msg_padrao VARCHAR;
	msg_pedidos_ativos VARCHAR := '';
BEGIN
	msg_padrao := 'Nao e possivel excluir um cliente, somente modificar seu status';
    
	SELECT count(status) INTO pedidos_ativos
	FROM trabalho_g1.pedido
	WHERE cod_cliente = OLD.cod_cliente AND status = 'A';

	IF (pedidos_ativos > 0) THEN
		RAISE EXCEPTION 'Nao modifique o status do cliente para inativo, pois o mesmo possui pedidos ativos';
    END IF;

	RAISE EXCEPTION CONCAT(msg_padrao, '. ', msg_pedidos_ativos);
END
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER trg_impossibilita_exclusao_cliente 
	BEFORE DELETE ON trabalho_g1.cliente
	FOR EACH ROW
	EXECUTE PROCEDURE trabalho_g1.fn_impossibilita_exclusao_cliente();

-- Exemplos para 4f
-- ...
