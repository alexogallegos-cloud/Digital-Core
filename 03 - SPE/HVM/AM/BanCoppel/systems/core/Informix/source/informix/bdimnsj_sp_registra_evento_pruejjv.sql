create procedure "informix".sp_registra_evento_pruejjv (
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
    -- Actividad : Se registran los eventos para el envÃ­o de mnsjr y emails a un cliente
    --                  basados en las transacciones que haya efectuado.
    -- Fecha     : 26/03/2012
    --*******************************************************************************************************
 
--DefiniciÃ³n de Variables
DEFINE cCodRet CHAR(5);
DEFINE iexiste INTEGER;
DEFINE iexiste2 INTEGER;
DEFINE iexiste3 INTEGER;
DEFINE iexistec INTEGER;
DEFINE vnumcte CHAR(20);
DEFINE vsqlerr INTEGER;
DEFINE cDia CHAR (2);
DEFINE cAnio CHAR (4);
DEFINE cMes CHAR(2);
DEFINE cMes1 CHAR (10);
DEFINE cFechaH CHAR (10);
DEFINE bandera CHAR(100);
DEFINE iprioridad INTEGER;

--SYNDEIN
DEFINE vTablaNotif  varchar (50);
DEFINE vInsStmt lvarchar (2000);
DEFINE vEstatus nvarchar(20);
DEFINE pfecha1Aux varchar(100);
DEFINE pfecha2Aux varchar(100);
DEFINE pNumTarjetaAux varchar(18);
DEFINE pNumctaAux varchar(22);
DEFINE vPermiteInsertar varchar(1);

--SYNDEIN

--Inicializa Variables
LET cCodRet = '00000';
LET iexiste = 0;
LET iexiste2 = 0;
LET iexiste3 = 0;
LET iexistec = 0;
LET vsqlerr = 0;
LET vnumcte = '';
LET cDia ='';
LET cAnio  ='';
LET cMes  ='';
LET cMes1 ='';
LET cFechaH ='';
LET vPermiteInsertar = '';
LET bandera='';
LET iprioridad =0;


SET LOCK MODE TO WAIT 3 ;
SET ISOLATION TO DIRTY READ;

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         return vsqlerr;
      END IF;
   END EXCEPTION;
--	SET DEBUG FILE TO "/informix/ragomez/registra_evento/sp_registra_evento1.out";
--	TRACE ON;

	SELECT valor INTO bandera  FROM mnsj_param WHERE cod_param='5';
	
	IF TRIM(bandera) = '0' THEN
		RETURN cCodRet;
	END IF;
	
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
	
	
--VALIDACION DE FECHA FORMATO DE MES NOMBRE COMPLETO
        
IF pIdMsj = 'POS_CREDE' OR pIdMsj = 'ATM_CREDE'THEN

	select DAY(fecha_hoy),MONTH(fecha_hoy),YEAR(fecha_hoy) into cDia,cMes,cAnio 
    from bdinteg:"informix".si_fechas where empresa ='001';

	IF (cMes ='1') THEN LET cMes1 = 'ENERO';  
		ELIF (cMes ='2') THEN LET cMes1 = 'FEBRERO';
		ELIF (cMes ='3') THEN LET cMes1 = 'MARZO';
		ELIF (cMes ='4') THEN LET cMes1 = 'ABRIL';
		ELIF (cMes ='5') THEN LET cMes1 = 'MAYO';
		ELIF (cMes ='6') THEN LET cMes1 = 'JUNIO';
		ELIF (cMes ='7') THEN LET cMes1 = 'JULIO';
		ELIF (cMes ='8') THEN LET cMes1 = 'AGOSTO';
		ELIF (cMes ='9') THEN LET cMes1 = 'SEPTIEMBRE';
		ELIF (cMes ='10') THEN LET cMes1 = 'OCTUBRE';
		ELIF (cMes ='11') THEN LET cMes1 = 'NOVIEMBRE';
		ELIF (cMes ='12') THEN LET cMes1 = 'DICIEMBRE';
	END IF;
		
		LET pStr5 = trim(cDia)||'-'||trim(cMes1)||'-'||trim(cAnio);
END IF;	
	

--VALIDA QUE SI NO CONTIENE COMO PARAMETRO DE ENTRADA EL NUMERO DE CLIENTE, BÃSQUE POR TARJETA O CUENTA.
	IF trim(pNumclt) <> '' THEN
		SELECT nvl(count(numcte),0) INTO iexistec FROM bdinteg:"informix".si_cliente WHERE numcte = pNumclt;
		IF (iexistec = 0 or iexistec is null) then
			LET cCodRet = '00100';
			RETURN cCodRet;
		END IF;
	ELSE -- SE BUSCA EL CLIENTE
		IF TRIM(pNumcta) <> '' THEN
    		SELECT  NVL(COUNT(CUENTA),0),NVL(num_cte, 0) INTO iexiste, vnumcte FROM bdicheq:"informix".sc_maechq WHERE CUENTA = pNumcta group by num_cte;
		    IF (iexiste = 0 or iexiste is null) THEN
				SELECT {+index (bdicred:sd_maecred, idx_idx_maecredb)} NVL(COUNT(num_credito),0), NVL(numcte,0) INTO iexiste2, vnumcte FROM bdicred:"informix".sd_maecred WHERE num_credito = pNumcta group by numcte;
				IF (iexiste2 = 0 or iexiste2 is null) THEN
				    IF TRIM(pNumTarjeta) <> '' THEN
						select nvl(count(numtarjeta),0), nvl(numcliente,0) into iexiste3, vnumcte from intercard:tarjeta where numtarjeta = pNumTarjeta group by numcliente;
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
			select  nvl(count(numtarjeta),0), nvl(numcliente,0) into iexiste3, vnumcte from intercard:tarjeta where numtarjeta = pNumTarjeta group by numcliente;
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
	
	---SE ASIGNA PRIORIDAD DE LECTURA A LA ALERTA
	
		SELECT {+AVOID_FULL("informix".mnsjr_cat_prioridades)}prioridad INTO iprioridad FROM "informix".mnsjr_cat_prioridades WHERE id_mensaje = pIdMsj;
		
			IF (iprioridad IS NULL OR iprioridad ='') THEN
					LET iprioridad = 9;
			END IF;
	
		--SYNDEIN
	        SELECT nombre_tabla
                INTO vTablaNotif
                FROM notif_cfg
                WHERE id_mensaje = pIdMsj
                AND tipo_mensaje = pTipoMsj
                AND tipo_proceso = pTipoproc;

        IF (vTablaNotif IS NULL OR vTablaNotif = '') THEN
                SELECT nombre_tabla
                INTO vTablaNotif
                FROM notif_cfg
                WHERE id_mensaje = 'DEFAULT'
                AND tipo_mensaje = pTipoMsj
                AND tipo_proceso = pTipoproc;
                --IF (pTipoproc = '1') THEN
                --        LET vTablaNotif = 'intercard:notif_online_default'; 
                --ELSE
                --        LET vTablaNotif = 'intercard:notif_batch_default'; 
                --END IF;
        END IF;
		SELECT first 1 Permite_Insertar
                INTO vPermiteInsertar
                FROM notif_cfg
                WHERE nombre_tabla = vTablaNotif;
		
		IF (vPermiteInsertar = 'F') THEN
			LET cCodRet = '00201';
			RETURN cCodRet;
		END IF;
		
		/*
        IF (pEstatus IS NULL) THEN
                LET vEstatus = 'NULL';
        ELSE
                LET vEstatus = CAST (pEstatus AS CHARACTER);
        END IF;
		*/
		IF (pImporte1 IS NULL or pImporte1 = '') THEN
                LET pImporte1 = 0.00;
        END IF;
		IF (pImporte2 IS NULL or pImporte2 = '') THEN
                LET pImporte2 = 0.00;
        END IF;
		IF (pImporte3 IS NULL or pImporte3 = '') THEN
                LET pImporte3 = 0.00;
        END IF;
		IF (pImporte4 IS NULL or pImporte4 = '') THEN
                LET pImporte4 = 0.00;
        END IF;
		IF (pImporte5 IS NULL or pImporte5 = '') THEN
                LET pImporte5 = 0.00;
        END IF;
		IF (pfecha1 IS NULL or pfecha1 = '') THEN
                LET pfecha1Aux = 'null';
		ELSE
                LET pfecha1Aux =  "'" || pfecha1 || "'::datetime year to fraction(3)";
        END IF;
		IF (pfecha2 IS NULL or pfecha2 = '') THEN
                LET pfecha2Aux = 'null';
		ELSE
                LET pfecha2Aux =  "'" || pfecha2 || "'::datetime year to fraction(3)";
        END IF;
		IF (pNumcta IS NULL) THEN
                LET pNumctaAux = 'NULL';
        ELSE
                LET pNumctaAux =  "'" || TRIM(pNumcta) || "'";
        END IF;
		IF (pNumTarjeta IS NULL) THEN
                LET pNumTarjetaAux = 'NULL';
        ELSE
                LET pNumTarjetaAux =  "'" || TRIM(pNumTarjeta) || "'";
        END IF;
		IF (pStr1 IS NULL) THEN
                LET pStr1 = '';
        END IF;
		IF (pStr2 IS NULL) THEN
                LET pStr2 = '';
        END IF;
		IF (pStr3 IS NULL) THEN
                LET pStr3 = '';
        END IF;
		IF (pStr4 IS NULL) THEN
                LET pStr4 = '';
        END IF;
		IF (pStr5 IS NULL) THEN
                LET pStr5 = '';
        END IF;
		IF (vnumcte IS NULL) THEN
                LET vnumcte = '';
        END IF;
		IF (pNumTarjeta IS NULL) THEN
                LET pNumTarjeta = '';
        END IF;
		IF(iprioridad IS NULL or iprioridad = '') THEN
				LET iprioridad = 9;
		END IF;
		LET vInsStmt = "INSERT INTO " || vTablaNotif || "(tipo_mensaje, id_mensaje,cliente, cuenta, tarjeta," ||
		"estatus, fecha_hora_registro, fecha_hora_recuperado, " ||
		"string1, string2, string3, string4, string5," || 
		" importe1, importe2, importe3, importe4, importe5, fecha1, fecha2, prioridad) "  ||
		"VALUES ('" || pTipoMsj || "','" || pIdMsj || "','" || vnumcte || "'," || pNumctaAux || "," || pNumTarjetaAux || " ,null, CURRENT ,'','" || 
		pStr1 || "','" || pStr2 || "','" || pStr3 || "','" || pStr4 || "','" || pStr5 || "','" ||
		pImporte1 || "','" || pImporte2 || "','" || pImporte3 || "','" || pImporte4 || "','" || pImporte5 || "'," || pfecha1Aux || "," || pfecha2Aux || "," || iprioridad || ")";
			EXECUTE IMMEDIATE vInsStmt;
		
	--/SYNDEIN
/*
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
*/
END;	
RETURN 	cCodRet;
END PROCEDURE;