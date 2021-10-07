

--------- RETORNA A QUANTIDADE DE PEDIDOS DE UM DETERMINADO CLIENTE
CREATE OR REPLACE FUNCTION trabalho_g1.cliente_pedido(
	numeric)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	codigo_cliente ALIAS FOR $1;
	num_pedidos integer;
	
BEGIN
	num_pedidos = (SELECT COUNT(cod_pedido) FROM pedido WHERE cod_cliente = codigo_cliente );
	IF(num_pedidos != 0) THEN
		RETURN num_pedidos;
	ELSE
		RAISE EXCEPTION 'O numero % do cliente não existe', codigo_cliente
		USING HINT = 'Verifique o codigo do cliente';
	END IF;
	
END
$BODY$;

-- SELECT cliente_pedido(203);


--------- RETORNA A QUANTIA DE ESPETACULOS NA CIDADE DO CLIENTE
CREATE OR REPLACE FUNCTION trabalho_g1.esp_cid_cli(
	numeric)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	num_cleinte ALIAS FOR $1;
	city integer;
	place integer;
	espetaculo INTEGER;
	estabelecimentos integer;

BEGIN
			
	espetaculo = (SELECT COUNT(esp.cod_espetaculo) 
				  FROM espetaculo esp 
				  JOIN estabelecimento est ON esp.cod_estabelecimento = est.cod_estabelecimento 
				  WHERE est.cod_cidade = (SELECT cod_cidade FROM cliente WHERE cod_cliente = num_cleinte));
	
	IF(espetaculo) != 0 THEN
			RETURN espetaculo;
	ELSE 
		RAISE EXCEPTION 'Não há espetaculo na cidade do cliente %', num_cleinte
		USING HINT = 'Verifique o codigo do cliente';
	END IF;
END;
$BODY$;

-- SELECT esp_cid_cli(107);


--------- RETORNA O QUANTIA DE ESPETÁCULO REFERENTE AO CODIGO DO PEDIDO
CREATE OR REPLACE FUNCTION trabalho_g1.espetaculos_reservas(
	numeric)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	num_pedido ALIAS FOR $1;
	espetaculo integer;

BEGIN
	espetaculo = (SELECT COUNT(cod_espetaculo) FROM reserva WHERE cod_pedido = num_pedido);
	IF(espetaculo) != 0 THEN
		RETURN espetaculo;
	ELSE 
		RAISE EXCEPTION 'O codigo do pedido % está não existe!', num_pedido
		USING HINT = 'Verifique o codigo do pedido';
	END IF;
END;
$BODY$;

-- SELECT espetaculos_reservas(1104);


------- RETORNA A CADEIRA RESERVADA PELO COD_RESERVA
CREATE OR REPLACE FUNCTION trabalho_g1.reserva_assentos(
	numeric)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	reserva_cod ALIAS FOR $1;
	cadeira_reservada character varying;
	
BEGIN
	cadeira_reservada = (SELECT cadeira FROM reserva WHERE cod_reserva = reserva_cod);
	IF (cadeira_reservada IS NOT null) THEN
		RETURN cadeira_reservada;
	ELSE
		RAISE EXCEPTION 'A reserva % não tem cadeira !', reserva_cod
		USING HINT = 'Verifique o codigo da reserva';
		
	END IF; 
END
$BODY$;

-- SELECT reserva_assentos(1204)


-------- RETORNA OS INGRESSOS DISPONIVEIS DA SESSÃO ESCOLHIDA
CREATE OR REPLACE FUNCTION trabalho_g1.sessao_ingresso(
	numeric)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	sessao_line ALIAS FOR $1;
	count_ingress1 integer;
	count_ingress2 integer;
BEGIN
	count_ingress1 = (SELECT total_ingressos FROM sessao WHERE cod_sessao = sessao_line );
	count_ingress2 = (SELECT ingressos_disponiveis FROM sessao WHERE cod_sessao = sessao_line );
	
	IF(count_ingress1 IS NOT null OR count_ingress2 IS NOT null) THEN
		RAISE NOTICE 'Ingressos totais: % | Ingressos disponiveis: %', count_ingress1, count_ingress2;
		RETURN count_ingress2;
		
	ELSE
		RAISE EXCEPTION 'O codigo da sessao % está não existe!', sessao_line
		USING HINT = 'Verifique o codigo da sessao';
	
	END IF;
	
END
$BODY$;

-- SELECT sessao_ingresso(1303)
