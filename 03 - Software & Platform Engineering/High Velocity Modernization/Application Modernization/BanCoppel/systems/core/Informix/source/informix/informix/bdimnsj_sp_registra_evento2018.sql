create procedure "informix".sp_registra_evento2018 (
					pTipoMsj char(1), pIdMsj char(10),pIdPlantilla char(12), pNumclt char(20),
					pNumcta char(20), pNumTarjeta char(16),pTipoproc char(1), pStr1 char(30), 
					pStr2 char(30), pStr3 char(30), pStr4 char (30), 
					pStr5 char(150), pStr6 char(100), pStr7 char(60), pStr8 char(60), 
					pStr9 char(15), pStr10 char(100), pcorreo_alterno char(100), pcelular_alterno char(10), 
					pImporte1 money (16,2), pImporte2 money (16,2),
					pImporte3 money (16,2), pImporte4 money (16,2), pImporte5 money (16,2), 
					pfecha1 datetime year to fraction(3), pfecha2 datetime year to fraction(3)
				    )

RETURNING CHAR(5) as cCodRet;  -- Codigo de Retorno.


    --*******************************************************************************************************
    -- Realizo   :Angel Rene de la Llave
    -- Proyecto : Latinia registro de eventos.
    -- Actividad : Se registran los eventos para el envÃ?Ã?Ã?Ã?Ã?Ã?Ã?ÃÂ­o de mnsjr y emails a un cliente
    --                  basados en las transacciones que haya efectuado.
    -- Fecha     : 26/03/2012
    -- Modificacion: Incluir campos string adicionales. JGP-19/09/2012
    -- Fecha:       19/09/2012
    -- ModificaciÃ?Ã?Ã?Ã?Ã?Ã?Ã?ÃÂ³n: Incluir registro de eventos pendientes de confirmar "PENDIENTE", hasta que sean 
    --               confirmados por Intercard. JGP-09/11/2012
    -- Fecha:       09/11/2012
	-- Realizo  : Manuel Osuna V.  
	-- ModificaciÃ?Ã?Ã?ÃÂ³n: Se agrega parametro pIdPlantilla,para que explotar la funcionalidad de que una alerta
	-- pueda manejar multiples plantillas.
    -- Fecha:       15/10/2013
	-- Realizo  : Cristo Lugo  
	-- ModificaciÃ?Ã?Ã?ÃÂ³n: Se agrega validaciÃ?Ã?Ã?ÃÂ³n pIdMsj,para que evitar enviar la misma alerta durante el dia.
    -- Fecha:       28/08/2014
    --*******************************************************************************************************
 
--DefiniciÃ?Ã?Ã?Ã?Ã?Ã?Ã?ÃÂ³n de Variables
DEFINE cCodRet CHAR(5);
DEFINE iexiste INTEGER;
DEFINE iexiste2 INTEGER;
DEFINE iexiste3 INTEGER;
DEFINE iexistec INTEGER;
DEFINE vnumcte CHAR(20);
DEFINE vsqlerr INTEGER;
DEFINE vtransaction_id CHAR(10);
DEFINE cDia CHAR (2);
DEFINE cAnio CHAR (4);
DEFINE cMes CHAR(2);
DEFINE cMes1 CHAR (10);
DEFINE cFechaH CHAR (10);


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

SET LOCK MODE TO WAIT 3 ;
SET ISOLATION TO DIRTY READ;


BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         return vsqlerr;
      END IF;
   END EXCEPTION;
	--SET DEBUG FILE TO "/informix/cristo/sp_registra_evento.out";
	--TRACE ON;

-- VERIFICA QUE LOS PARAMETROS DE ENTRADA NO ESTEN VACIOS O NULLS
	IF (pTipoMsj IS NULL OR pTipoMsj = '') OR
	   (pIdMsj IS NULL OR pIdMsj = '') OR
	   (pTipoproc IS NULL OR pTipoproc = '') OR
	   (pIdPlantilla IS NULL OR pIdPlantilla = '') THEN	   
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


--VALIDA QUE SI NO CONTIENE COMO PARAMETRO DE ENTRADA EL NUMERO DE CLIENTE, BÃ?Ã?Ã?Ã?Ã?Ã?Ã?ÃÂ¡SQUE POR TARJETA O CUENTA.

	IF SUBSTR(pIdMsj,1,3)<>"WEB" THEN	
		IF trim(pNumclt) <> ''  THEN
			IF (trim(pNumclt) <> '000000000') THEN
				SELECT {+index (bdinteg:si_cliente,  224_479)} nvl(count(numcte),0) INTO iexistec FROM bdinteg:"informix".si_cliente WHERE numcte = pNumclt;
				IF (iexistec = 0 or iexistec is null) then
					LET cCodRet = '00100';
					RETURN cCodRet;
				END IF;
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
	END IF;		
	if vnumcte = '' or vnumcte is null  then
		LET vnumcte  = pNumclt;
	END IF;

	-- Eventos que requieren confirmacion se registran como temporales. JGP-17/09/2012
	IF pIdMsj IN ('POS_DEBS','POS_CREDS','ATM_DEBS','ATM_CREDS','POS_DEBE','POS_CREDE','ATM_DEBE','ATM_CREDE') THEN -- Posible Migracion a Tabla
		LET vtransaction_id ='PENDIENTE';
	ELSE
		LET vtransaction_id = NULL;
	END IF;	

	IF pIdMsj IN ('SPEI_SMREC', 'SPEI_TRREC') THEN
		LET pTipoproc = '2';
	END IF;
	
	IF pTipoproc = '1' THEN
		IF pIdMsj = 'OFI_AVSMS' and pIdPlantilla <> 'OFI_CNCEL3' THEN
		
			----IF NOT EXISTS(SELECT  {+AVOID_FULL(bdimnsj:"informix".mnsjr_trx_batch)} cliente FROM bdimnsj:"informix".mnsjr_trx_batch WHERE cliente = vnumcte AND id_mensaje = pIdMsj AND id_plantilla <> 'OFI_CNCEL3' AND celular_alterno = pcelular_alterno AND fecha_hora_registro >= today) THEN
			IF NOT EXISTS(SELECT  cliente FROM bdimnsj:"informix".mnsjr_trx_batch WHERE cliente = vnumcte AND id_mensaje = pIdMsj AND id_plantilla <> 'OFI_CNCEL3' AND celular_alterno = pcelular_alterno AND fecha_hora_registro >= today) THEN
				INSERT INTO bdimnsj:"informix".mnsjr_trx_batch			
				(tipo_mensaje, id_mensaje,id_plantilla,cliente, cuenta, tarjeta, transaction_id, estatus, fecha_hora_registro, fecha_hora_recuperado, string1, string2, string3,		
				string4, string5, string6, string7, string8, string9, string10, correo_alterno, celular_alterno, 
				importe1, importe2, importe3, importe4, importe5, fecha1, fecha2)
				VALUES
				(pTipoMsj, pIdMsj,pIdPlantilla,vnumcte, pNumcta, pNumTarjeta, vtransaction_id, null, CURRENT, '', pStr1, pStr2, pStr3, pStr4, pStr5, pStr6, pStr7, pStr8, pStr9, pStr10,
				pcorreo_alterno, pcelular_alterno, pImporte1, pImporte2, pImporte3, pImporte4, pImporte5, pfecha1, pfecha2 );
			END IF;
		ELSE
			INSERT INTO bdimnsj:"informix".mnsjr_trx_batch
				(tipo_mensaje, id_mensaje,id_plantilla,cliente, cuenta, tarjeta, transaction_id, estatus, fecha_hora_registro, fecha_hora_recuperado, string1, string2, string3,		
				string4, string5, string6, string7, string8, string9, string10, correo_alterno, celular_alterno, 
				importe1, importe2, importe3, importe4, importe5, fecha1, fecha2)
				VALUES
				(pTipoMsj, pIdMsj,pIdPlantilla,vnumcte, pNumcta, pNumTarjeta, vtransaction_id, null, CURRENT, '', pStr1, pStr2, pStr3, pStr4, pStr5, pStr6, pStr7, pStr8, pStr9, pStr10,
				pcorreo_alterno, pcelular_alterno, pImporte1, pImporte2, pImporte3, pImporte4, pImporte5, pfecha1, pfecha2 );
		END IF;
	ELSE
		
		INSERT INTO bdimnsj:"informix".mnsjr_trx_batch
		(tipo_mensaje, id_mensaje,id_plantilla,cliente, cuenta, tarjeta, transaction_id, estatus, fecha_hora_registro, fecha_hora_recuperado, string1, string2, string3,	
		string4, string5, string6, string7, string8, string9, string10, correo_alterno, celular_alterno, 
		importe1, importe2, importe3, importe4, importe5, fecha1, fecha2)
		VALUES
		(pTipoMsj, pIdMsj,pIdPlantilla, vnumcte, pNumcta, pNumTarjeta, vtransaction_id, null, CURRENT, '', pStr1, pStr2, pStr3, pStr4, pStr5, pStr6, pStr7, pStr8, pStr9, pStr10,
		pcorreo_alterno, pcelular_alterno, pImporte1, pImporte2, pImporte3, pImporte4, pImporte5, pfecha1, pfecha2 );
	 
	END IF;
		
END;	
RETURN 	cCodRet;
END PROCEDURE;