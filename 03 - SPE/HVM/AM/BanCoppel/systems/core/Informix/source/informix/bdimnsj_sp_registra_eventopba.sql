create procedure "informix".sp_registra_eventopba (
					pTipoMsj char(1), pIdMsj char(10), pNumclt char(20),
					pNumcta char(20), pNumTarjeta char(16),pTipoproc char(1), pStr1 char(30), 
					pStr2 char(30), pStr3 char(30), pStr4 char (30), 
					pStr5 char(150), pImporte1 money (16,2), pImporte2 money (16,2),
					pImporte3 money (16,2), pImporte4 money (16,2), pImporte5 money (16,2), 
					pfecha1 datetime year to fraction(3), pfecha2 datetime year to fraction(3)
				    )

RETURNING CHAR(5) as cCodRet;  -- Codigo de Retorno.


    --*******************************************************************************************************
    -- Realizo   :Angel Rene de la Llave
    -- Proyecto : Latinia registro de eventos.
    -- Actividad : Se registran los eventos para el envío de mnsjr y emails a un cliente
    --                  basados en las transacciones que haya efectuado.
    -- Fecha     : 26/03/2012
    --*******************************************************************************************************
 
--Definición de Variables
DEFINE cCodRet CHAR(5);
DEFINE iexiste INTEGER;
DEFINE iexiste2 INTEGER;
DEFINE iexiste3 INTEGER;
DEFINE iexistec INTEGER;
DEFINE vnumcte CHAR(20);
DEFINE vsqlerr INTEGER;

--Inicializa Variables
LET cCodRet = '00000';
LET iexiste = 0;
LET iexiste2 = 0;
LET iexiste3 = 0;
LET iexistec = 0;
LET vsqlerr = 0;
LET vnumcte = '';

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         return vsqlerr;
      END IF;
   END EXCEPTION;
--	SET DEBUG FILE TO "/tmp/MNSJR/sp_registra_evento.out";
--	TRACE ON;

-- VERIFICA QUE LOS PARAMETROS DE ENTRADA NO ESTEN VACIOS O NULLS
	IF (pTipoMsj IS NULL OR pTipoMsj = '') OR
	   (pIdMsj IS NULL OR pIdMsj = '') OR
	   (pTipoproc IS NULL OR pTipoproc = '') THEN
	   LET cCodRet = '00005';
	   RETURN cCodRet;
	END IF;
	
--VERIFICA SI SE TRATA DE UN PROCESO VALIDO
	IF pTipoproc > '2' OR pTipoproc = '0'THEN
	   LET cCodRet = '00020';
	   RETURN cCodRet;
	END IF;
	
-- VERIFICA QUE SE UN TIPO DE MENSAJE VALIDO
	IF pTipoMsj > '3' OR pTipoMsj = '0' THEN
		LET cCodRet = '00103';
	    RETURN cCodRet;
	END IF;
--VARIFICA QUE UNO DE ESTOS TRES DATOS OBLIGATORIOS DEL CLIENTE VENGA INFORMACION	
	IF (pNumclt IS NULL OR pNumclt = '') AND (pNumcta IS NULL OR pNumcta ='') AND (pNumTarjeta IS NULL OR pNumTarjeta = '') THEN
	   LET cCodRet = '00110';
	   RETURN cCodRet;
	END IF;

--VALIDA QUE SI NO CONTIENE COMO PARAMETRO DE ENTRADA EL NUMERO DE CLIENTE, BÚSQUE POR TARJETA O CUENTA.
	IF trim(pNumclt) <> '' THEN
		SELECT {+index (bdinteg:si_cliente,  224_479)} nvl(count(numcte),0) INTO iexistec FROM bdinteg:"informix".si_cliente WHERE numcte = pNumclt;
		IF (iexistec = 0 or iexistec is null) then
			LET cCodRet = '00100';
			RETURN cCodRet;
		END IF;
	ELSE -- SE BUSCA EL CLIENTE
		IF TRIM(pNumcta) <> '' THEN
    		SELECT {+index (bdicheq:sc_maechq, 174_183)} NVL(COUNT(CUENTA),0),NVL(num_cte, 0) INTO iexiste, vnumcte FROM bdicheq:"informix".sc_maechq WHERE CUENTA = pNumcta group by num_cte;
		    IF (iexiste = 0 or iexiste is null) THEN
				SELECT {+index (bdicred:sd_maecred, idx_idx_maecredb)} NVL(COUNT(num_credito),0), NVL(numcte,0) INTO iexiste2, vnumcte FROM bdicred:"informix".sd_maecred WHERE num_credito = pNumcta group by numcte;
				IF (iexiste2 = 0 or iexiste2 is null) THEN
				    IF TRIM(pNumTarjeta) <> '' THEN
						select {+index (intercard:tarjeta, 144_89)} nvl(count(numtarjeta),0), nvl(numcliente,0) into iexiste3, vnumcte from intercard:tarjeta where numtarjeta = pNumTarjeta group by numcliente;
						IF (iexiste3 = 0 or iexiste3 is null) then
							LET cCodRet = '00115';
							RETURN cCodRet;
						END IF;
					ELSE
						LET cCodRet = '00100';
						RETURN cCodRet;
					END IF;	
				END IF;
			END IF;
		ELIF TRIM(pNumTarjeta) <> '' THEN
			select {+index (intercard:tarjeta, 144_89)} nvl(count(numtarjeta),0), nvl(numcliente,0) into iexiste3, vnumcte from intercard:tarjeta where numtarjeta = pNumTarjeta group by numcliente;
			IF (iexiste3 = 0 or iexiste3 is null) then
				LET cCodRet = '00115';
				RETURN cCodRet;
			END IF;
		END IF;
		IF (iexiste = 0 or iexiste is null) and (iexiste2 = 0 or iexiste2 is null) and (iexiste3 = 0 or iexiste3 is null) THEN
			LET cCodRet = '00112';
			RETURN cCodRet;
		END IF;		
	END IF;
	
	if vnumcte = '' or vnumcte is null then
		LET vnumcte  = pNumclt;
	END IF;
	

	IF pTipoproc = '1' THEN
	
	INSERT INTO bdimnsj:"informix".mnsjr_trx_online
	(tipo_mensaje, id_mensaje, cliente, cuenta, tarjeta, estatus, fecha_hora_registro, fecha_hora_recuperado, string1, string2, string3,	
	string4, string5, importe1, importe2, importe3, importe4, importe5, fecha1, fecha2)
	VALUES
	(pTipoMsj, pIdMsj, vnumcte, pNumcta, pNumTarjeta, null, CURRENT, '', pStr1, pStr2, pStr3, pStr4, pStr5, pImporte1, pImporte2, pImporte3,	
	 pImporte4, pImporte5, pfecha1, pfecha2 );
	 
	ELSE
		
	INSERT INTO bdimnsj:"informix".mnsjr_trx_batch
	(tipo_mensaje, id_mensaje, cliente, cuenta, tarjeta, estatus, fecha_hora_registro, fecha_hora_recuperado, string1, string2, string3,	
	string4, string5, importe1, importe2, importe3, importe4, importe5, fecha1, fecha2)
	VALUES
	(pTipoMsj, pIdMsj, vnumcte, pNumcta, pNumTarjeta, null, CURRENT, '', pStr1, pStr2, pStr3, pStr4, pStr5, pImporte1, pImporte2, pImporte3,	
	 pImporte4, pImporte5, pfecha1, pfecha2 );
	 
	END IF;
		
END;	
RETURN 	cCodRet;
END PROCEDURE;