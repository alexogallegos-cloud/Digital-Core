CREATE PROCEDURE "informix".sp_idetraspasomovtoshistorico_esp(dtFecha DATE)
RETURNING CHAR(6)  AS codigo_retorno,
		  CHAR(80) AS Mensaje_retorno;

-- DEFINICION DE VARIABLES

DEFINE cCodRet      	CHAR(6);
DEFINE cMensajeRet      	CHAR(80);
DEFINE iSqlErr     		INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE cUser			CHAR(10);
--DEFINE dtFecha		DATE;
DEFINE dtFechaUltDiaMes		DATE;
DEFINE cAniomes		 CHAR(6);
DEFINE cNum_cte		 CHAR(20);
DEFINE iNum_serial	 INTEGER;
DEFINE cRfc	 		 CHAR(13);
DEFINE cRef_ret	 	 CHAR(13);
DEFINE cTipo_cta	 CHAR(1);
DEFINE cSucursal	 CHAR(4);
DEFINE cNum_cta	 	 CHAR(20);
DEFINE dtFecha_mov	 DATE;
DEFINE ctran_central CHAR(4);
DEFINE mImp_tot_dep	 MONEY(16,2);
DEFINE mImp_ide	 	 MONEY(16,2);
DEFINE cUser_insert	 CHAR(8);
DEFINE dtFecha_insert	 DATE;
DEFINE iCont		 INTEGER;
DEFINE iBandera		 INTEGER;
DEFINE cCommit		 CHAR(1);
DEFINE cStatus		 CHAR(1);

--INICIALIZACION DE VARIABLES--

LET cCodRet  			= "000000";
LET cMensajeRet  		= "PROCESO EXITOSO";
LET iSqlErr 			= 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cUser	 			= USER;
--LET dtFecha	 		= DATE(1);
LET dtFechaUltDiaMes	= DATE(1);
LET cAniomes		 = "";
LET cNum_cte		 = "";
LET iNum_serial	 	 = 0;
LET cRfc	 		 = "";
LET cRef_ret	 	 = "";
LET cTipo_cta	 	 = "";
LET cSucursal	 	 = "";
LET cNum_cta	 	 = "";
LET dtFecha_mov	     = DATE(1);
LET mImp_tot_dep	 = 0;
LET mImp_ide	 	 = 0;
LET cUser_insert	 = "";
LET dtFecha_insert	 = DATE(1);
LET iCont			 = 0;
LET iBandera		 = 0;
LET cCommit			 = "N";
LET cStatus			 = "";

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		LET cCodRet= iSqlErr;
		LET cMensajeRet = cErrorInfo;
		IF  cCommit = "S" THEN
			ROLLBACK WORK;
		END IF;
		RETURN cCodRet,cMensajeRet;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/home/sysifx/jesusm/costos/sp_idetraspasomovtoshistorico.out';
	--TRACE ON;
	
	SELECT ult_dia_mes
	INTO dtFechaUltDiaMes
	FROM bdinteg:"informix".si_fechas
	WHERE empresa = '001';
	
	LET dtFechaUltDiaMes = '06302013';
	
	--se valida que el proceso mensual ya se haya ejecutado
	IF NOT EXISTS( SELECT status FROM bdilide:"informix".sl_procesos	WHERE proceso = "conmensual" AND fech_proceso =dtFecha AND status = '1') THEN
		LET cCodRet = "000002";
		LET cMensajeRet = 'No se ha ejecutado el proceso conmensual'; 
		RETURN cCodRet,cMensajeRet;
	END IF;
	
	--se valida que el proceso de migracion de datos no se haya ejecutado	
	SELECT status INTO cStatus FROM bdilide:"informix".sl_procesos	WHERE proceso = "movefechis" AND fech_proceso =dtFecha;	
	 
	IF NVL(cStatus,"") = "" THEN
		-- se registra el inicio del proceso de traspaso de información de la tabla bdilide:sl_movefec  a la tabla bdilide:sl_movefec_his
		INSERT INTO bdilide:"informix".sl_procesos(proceso, fech_proceso,status,user_insert,fecha_insert)
        VALUES("movefechis",dtFecha,'0',cUser, current hour to fraction(3));
	ELIF cStatus ='1'THEN
		LET cCodRet = "000003";
		LET cMensajeRet = 'Ya se realizo el traspaso'; 
		RETURN cCodRet,cMensajeRet; 	 
	END IF;

	BEGIN WORK;
	LET cCommit="S";		
	
	--se realiza el pase de movimientos del mes a la tabla historica.
	
	FOREACH movefechis WITH HOLD FOR 
		SELECT  aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,
				tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert
		INTO 	cAniomes,cNum_cte,iNum_serial,cRfc,cRef_ret,cTipo_cta,cSucursal,cNum_cta,dtFecha_mov,
				ctran_central,mImp_tot_dep,mImp_ide,cUser_insert,dtFecha_insert	
		FROM bdilide:"informix".sl_movefec
		WHERE YEAR(fecha_mov) <= YEAR(dtFecha)
		AND MONTH(fecha_mov) <= MONTH(dtFecha)		
			
		--se agrea la informacion a la tabla historica.
		INSERT INTO bdilide:"informix".sl_movefec_his (aniomes,num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,tran_central,imp_tot_dep,imp_ide,user_insert,fecha_insert)	
		VALUES (cAniomes,cNum_cte,iNum_serial,cRfc,cRef_ret,cTipo_cta,cSucursal,cNum_cta,dtFecha_mov,ctran_central,mImp_tot_dep,mImp_ide,cUser_insert,dtFecha_insert);
		
		--se borra el registro que se inserto en la historica
		DELETE FROM bdilide:"informix".sl_movefec WHERE CURRENT OF movefechis;	
		
		LET iCont= iCont +1;
		LET iBandera = 1;
		
		IF iCont = 500 AND cCommit = "S" THEN
			COMMIT WORK;				
			BEGIN WORK;
			LET cCommit="S";
			LET iCont= 0;
		END IF;	
		
		END FOREACH;
		
		IF cCommit = "S" THEN
			COMMIT WORK;	
		END IF;				
		
		-- SE ACTUALIZA EL PROCESO DE TRASPASO PARA INDICAR QUE SE EJECUTÓ CORRECTAMENTE.
		UPDATE bdilide:"informix".sl_procesos
			SET	status = '1'
		WHERE proceso = "movefechis" 
		AND fech_proceso =dtFecha 
		AND status = '0';
		
		IF iBandera = 0 THEN
			LET cCodRet = '000004'; 
			LET cMensajeRet = 'No existe informacion para realizar el traspaso'; 
		END IF;
		
	RETURN cCodRet,cMensajeRet;
END;
END PROCEDURE
