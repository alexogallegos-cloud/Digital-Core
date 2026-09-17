create procedure "informix".sp_registra_evento_prod(
					pTipoMsj char(1), pIdMsj char(10),pIdPlantilla char(12),pNumclt char(20),
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
    -- Realizo   :Manuel Osuna Valencia
    -- Proyecto : Latinia registro de eventos.
    -- Actividad : Se registran los eventos Productivos para el envío de mensajes a grupo de usuarios
    --*******************************************************************************************************

--Definición de Variables
DEFINE cCodRet CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE vfecha1 datetime year to fraction(3);
DEFINE sUsuario CHAR(20);
DEFINE sCelular	CHAR(10);
DEFINE sCorreo	CHAR(100);
DEFINE sUserGen	CHAR(10);

--Inicializa Variables
LET cCodRet = '00000';
LET vsqlerr = 0;
LET sUserGen = "";

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         return vsqlerr;
      END IF;
   END EXCEPTION;
--SET DEBUG FILE TO "/tmp/MNSJR/sp_registra_evento_prod.out";
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

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;
	
	--VERIFICANDO SI EXISTE UN MENSAJE IGUAL
	SELECT MAX(fecha_hora_registro) +  INTERVAL(60) MINUTE TO MINUTE
	INTO vfecha1
	FROM bdimnsj:"informix".mnsjr_trx_online WHERE id_mensaje = 'PRO_ALERS'
	AND string1 = pStr1 AND string2 = pStr2 AND string3 = pStr3 
	AND string4 = pStr4;
	
	
	IF (vfecha1 is not null AND vfecha1 >= CURRENT) THEN --NO PASA EL TIEMPO LIMITE DE REENVIO DE UN MENSAJE REPETIDO
	  LET cCodRet = '00005';
	  RETURN 	cCodRet;
	END IF;
		
	IF SUBSTR(pNumclt,1,5) = 'GRUPO' THEN
		FOREACH
			SELECT usuario, celular, correo INTO sUsuario, sCelular, sCorreo FROM bdimnsj:"informix".mnsj_grupos_usuarios WHERE id_grupo = pNumclt		    
			IF (sUsuario IS NOT NULL OR sUsuario <> '') THEN
				LET sUserGen = '000000000'; -- Usuario BanCoppel Genérico para recibir alertas.				
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(pTipoMsj, pIdMsj, pIdPlantilla,sUserGen, pNumcta, pNumTarjeta, 
				pTipoproc, pStr1,pStr2, pStr3, pStr4, pStr5, pStr6, pStr7, pStr8, pStr9, pStr10 , sCorreo,
				sCelular,pImporte1, pImporte2, pImporte3, pImporte4, pImporte5, pfecha1, pfecha2) INTO cCodRet;	
			ELSE			
				LET cCodRet = '00007';			END IF;
	    END FOREACH;
	ELSE
	  LET cCodRet = '00006';	END IF;

						
END;
RETURN 	cCodRet;
END PROCEDURE;