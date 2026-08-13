CREATE PROCEDURE "informix".sp_validarfechatarjetas_debcred_iccat(pNumTarjeta char(16), pFecha char(4))
RETURNING  	CHAR(9);	--CODIGO DE RETORNO
			

DEFINE cCodRet char(9);
DEFINE cNumTar char(16);
DEFINE isql_err integer;
DEFINE pFecha1 char(2);
DEFINE pFecha2 char(2);

LET cCodRet = '000000000';
LET cNumTar = '';
LET pFecha1 = '';
LET pFecha2 = '';

BEGIN

	ON EXCEPTION SET isql_err
		IF isql_err <> 0 THEN
			let cCodRet = isql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION DIRTY READ;

	--SET DEBUG FILE TO '/informix/tmp/sp_validarfechatarjetas_debcred_iccat.out';	
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;

	LET pFecha1 = SUBSTR(pFecha,1,2);
	LET pFecha2 = SUBSTR(pFecha,3,2);

	LET pFecha = '';
	LET pFecha = pFecha2||pFecha1;
	
	/*IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = pNumTarjeta) THEN -- ES CREDITO
		
		SELECT tr.numtarjeta
		INTO cNumTar
		FROM intercard:"informix".tarjeta tr 
		INNER JOIN intercard:"informix".hsmcard hs on hs.expirationdate = tr.fechaexp
		--INNER JOIN bdicred:"informix".sd_tarjeta sdtar on TO_CHAR(sdtar.expiracion, '%m%y') = hs.expirationdate
		INNER JOIN bdicred:"informix".sd_tarjeta sdtar on TO_CHAR(sdtar.expiracion, '%y%m') = hs.expirationdate
		WHERE hs.card_no = tr.numtarjeta 
		AND sdtar.num_tarjeta = tr.numtarjeta
		AND tr.numtarjeta = pNumTarjeta
		AND tr.fechaexp = pFecha;
		
	ELIF EXISTS (SELECT num_tarjeta FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = pNumTarjeta) THEN -- ES DEBITO
		
		SELECT tr.numtarjeta 
		INTO cNumTar
		FROM intercard:"informix".tarjeta tr 
		INNER JOIN intercard:"informix".hsmcard hs on hs.expirationdate = tr.fechaexp
		--INNER JOIN bdicheq:"informix".sc_tarjeta sctar on TO_CHAR(sctar.expiracion, '%m%y') = hs.expirationdate
		INNER JOIN bdicheq:"informix".sc_tarjeta sctar on TO_CHAR(sctar.expiracion, '%y%m') = hs.expirationdate
		WHERE hs.card_no = tr.numtarjeta 
		AND sctar.num_tarjeta = tr.numtarjeta
		AND tr.numtarjeta = pNumTarjeta
		AND tr.fechaexp = pFecha;
		
	END IF;
	
	IF (cNumTar IS NULL OR cNumTar = '') THEN
		LET cCodRet = '000000001'; -- FECHA NO COINCIDE
	END IF;*/
	
	RETURN cCodRet;

END 
END PROCEDURE
DOCUMENT
'OBJETIVO: 	Valida que cuadre la fecha de expiracion de la tarjeta en las tablas correspondientes',
'AUTOR:		Keevyn Adrian Gil Valenzuela',
'FECHA : 	13/06/2017',
'BD : 		intercard',
'OBJETIVO:  Se omite validación de fecha de caducidad de las tarjetas a petición del dueño del producto MKT',
'AUTOR:     José Luis Polanco Bustillo',
'FECHA:     12/02/2018';

CREATE PROCEDURE "informix".sp_registraintentos_acttarjetas_iccat(pNumcte CHAR(20), pNum_cta CHAR(20), pNum_tar CHAR(16), pNomcte CHAR(104), pEjecutivo CHAR(8), pTipotarj CHAR(1))
	RETURNING CHAR(9);
	
	DEFINE sql_err INTEGER ;
	DEFINE cCodRet CHAR(9);
	DEFINE iContador INTEGER;
	DEFINE isCredito CHAR(1);
	DEFINE cNumcte_adic CHAR(20);
	DEFINE cNumcte_tit CHAR(20);
	
	LET cCodRet  = '000000000';
	LET cNumcte_adic = '';
	LET cNumcte_tit = '';
	
	--SET DEBUG FILE TO "/informix/tmp/sp_registraintentos_acttarjetas_iccat.out";
	--TRACE ON;
  
BEGIN	
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	IF (NVL(pNumcte,'') = '' OR NVL(pNum_cta,'') = '' OR NVL(pNomcte,'') = '' OR NVL(pEjecutivo,'') = '' OR NVL(pTipotarj,'') = '' OR NVL(pNum_tar,'') = '') THEN
		LET cCodRet  = '000000002'; --PARAMETROS VACIOS
		RETURN cCodRet;
	END IF;  

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;   
	
		--OBTENEMOS EL VALOR DE ISCREDITO  DÉBITO = 0 , CRÉDITO = 1
	/*SELECT COUNT(*) 
	INTO isCredito
	FROM bdicred:"informix".sd_tarjeta
	WHERE num_credito = pNum_cta;
		--SI ES MAYOR QUE CERO ES TARJETA DE CRÉDITO
	IF (isCredito > 0) THEN
		SELECT numcte
		INTO cNumcte_tit
		FROM bdicred:"informix".sd_tarjeta
		WHERE num_credito = pNum_cta AND secuencia = 1;
	
		IF (cNumcte_tit != pNumcte) THEN
			SELECT FIRST 1 numcte
			INTO cNumcte_adic
			FROM bdicred:"informix".sd_tarjeta
			WHERE num_credito = pNum_cta AND tipo_tarjeta = 'A' AND prodtarjeta IN (6001,7000,8100);
		END IF;
		
	ELSE 
		SELECT numcte 
		INTO cNumcte_tit
		FROM bdicheq:"informix".sc_tarjeta 
		WHERE cuenta = pNum_cta AND secuencia = 1;
		
		
		IF (cNumcte_tit != pNumcte) THEN
			SELECT FIRST 1 numcte 
			INTO cNumcte_adic
			FROM bdicheq:"informix".sc_tarjeta 
			WHERE cuenta = pNum_cta AND tipo_tarjeta = 'A' AND prodtarjeta = '2400';
		END IF;		
	END IF;
	
	SELECT num_int_fallidos
	INTO iContador
	FROM intercard:"informix".stmp_tarjeta_clte_bloqueada_iccat 
	WHERE numtarjeta = pNum_tar;
	
	IF (iContador IS NULL) THEN 
		LET iContador = 0;
	END IF;
	
	IF (iContador = 0) THEN 
		INSERT INTO intercard:"informix".stmp_tarjeta_clte_bloqueada_iccat (empresa,numcte_tit,numcuenta,numtarjeta,nombre,num_int_fallidos,fecha_utl_mod,ejecutivo,status_tar,tipo_tarjeta,numcte_adic,user_insert,fecha_insert)
		VALUES ('001',cNumcte_tit,pNum_cta,pNum_tar,pNomcte,1,CURRENT,pEjecutivo,'I',pTipotarj,cNumcte_adic,pEjecutivo,CURRENT);
	ELIF (iContador = 1) THEN
		UPDATE intercard:"informix".stmp_tarjeta_clte_bloqueada_iccat SET num_int_fallidos = '2', fecha_utl_mod = CURRENT 
		WHERE numcte_tit = cNumcte_tit AND numtarjeta = pNum_tar;
	ELIF (iContador = 2) THEN
		UPDATE intercard:"informix".stmp_tarjeta_clte_bloqueada_iccat SET num_int_fallidos = '3', status_tar = 'B', fecha_utl_mod = CURRENT 
		WHERE numcte_tit = cNumcte_tit AND numtarjeta = pNum_tar;
		LET cCodRet  = '000000001';
	END IF;*/
	
	RETURN cCodRet;
END
END PROCEDURE  
DOCUMENT
'OBJETIVO: 	REGISTRAR NÚMERO DE INTENTOS FALLIDOS AL ACTIVAR LA TARJETA DESDE EL ICCAT',
'AUTOR:		FELIPE MONZÓN MENDOZA',
'FECHA : 	05/06/2017',
'BD : 		INTERCARD',
'OBJETIVO:  Se omite bloqueo por intentos fallidos de activación a petición del dueño del producto MKT',
'AUTOR:     José Luis Polanco Bustillo',
'FECHA:     12/02/2018';

CREATE PROCEDURE "informix".sp_arqcvalidoshistorico()
RETURNING VARCHAR(6) as Cod_ret, VARCHAR(80) as Men_ret;

	--  Variables de Errores y datos de SP
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
	
	
   	--  Variables para control de contadores
	define  vsflagentransaccion 	char(1);
	define 	vicontadorregistros 	integer;
	define  vicontadorregistros2 	integer;
    
	--  Variables para datos de primary key
	define  vmaxnumregistros integer;
	define  vperiododepuracion integer;
	define  vsecuencia  varchar (7);
	define  vsecuenciaextendida  varchar (16);
	define  vfechalocaltransaccion  varchar (4);
	define  vhoralocaltransaccion  varchar (6);
		


BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

	let		vsecuenciaextendida='';
	let		vperiododepuracion=0;
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let		vicontadorregistros2 = 0;
	let		p_cod_ret = '00000';
	let		p_mensaje = 'Proceso Exitoso.';
	let            vmaxnumregistros = 0;
	--set debug file to '/tmp/sp_arqcvalidoshistorico.out';
	--trace on;
		select 	maxnumregistros into  vmaxnumregistros
			from intercard:"informix".parametros;
		select periododepuracion into vperiododepuracion
			from intercard:"informix".parametros;
					
	set isolation to dirty read;
		foreach cusor1 with hold
				for    
				select {+INDEX (movimiento  idx_fechahorainauth)} m.secuenciaextendida
					into vsecuenciaextendida
				from intercard:"informix".movimiento m 
					inner join intercard:"informix".arqcvalidos a on 
						m.metodocaptura = '05' 
						and fechahorainauth < (CURRENT - (vperiododepuracion units day))  
						and m.secuenciaextendida = a.secuenciaextendida
			
                if(vsflagentransaccion = 'F') then
			begin work;
	                let vsflagentransaccion = 'V';
		end if;
			
		--  Inserta datos en la tabla historica
		
		
		insert into arqcvalidoshistorico 
		select secuenciaextendida, arqccalculado 
		from intercard:"informix".arqcvalidos 
		where secuenciaextendida = vsecuenciaextendida;
		
		--  Borra registro de la Tabla de arqcvalidos	
		delete from intercard:"informix".arqcvalidos 
		where secuenciaextendida = vsecuenciaextendida;
		let vicontadorregistros = vicontadorregistros + 1;


			if (vicontadorregistros = vmaxnumregistros) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
		end foreach;
		
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				let vsflagentransaccion = 'F';
		end if;

	RETURN 	P_COD_RET,P_MENSAJE;
END;

END PROCEDURE;