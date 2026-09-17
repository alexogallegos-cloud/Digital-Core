CREATE PROCEDURE "informix".sp_actualiza_portabilidad(pEmpresa CHAR(3), 
													  pFolio CHAR(30), 
													  pClaveOrigen CHAR(1),
													  pEstatusPortabilidad CHAR(2), 
													  pSucursal CHAR(4), 
													  pUserInsert CHAR(8), 
													  pEstatus CHAR(2), 
													  pOrigenCancel CHAR(20), 
                                                      pFolioCancel CHAR(30) )
RETURNING CHAR(6);

--Declaracion de variables
DEFINE cCodRet 		CHAR(10);
DEFINE iTransaccion INTEGER;
DEFINE iSqlErr 		INTEGER;
DEFINE cFecha		DATE;
DEFINE cNumCte		CHAR(10);
DEFINE cNumCtaCbe	CHAR(18);
DEFINE cCuenta		CHAR(20);
DEFINE dFecha		CHAR(10);
DEFINE cCodRetSP    CHAR(5);
DEFINE cMenRetSp    CHAR(100);

--Asignacion de variables
LET cCodRet 	 = '000000';
LET iTransaccion = 0;
LET iSqlErr 	 = 0;
LET cFecha	 	 = DATE(1);
LET dFecha 		 = '01/01/1990';

LET cNumCte		 = '';
LET cNumCtaCbe	 = '';
LET cCuenta	 	 = '';
LET cCodRetSP 	 = '00000';
LET cMenRetSp    = '';

BEGIN

    ON EXCEPTION SET iSqlErr --Manejador de Errores	
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            IF iTransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;


            END IF;
			RETURN cCodRet;
        END IF;		
    END EXCEPTION;
	
    ON EXCEPTION IN (-535)
       LET iTransaccion = 1;
       COMMIT WORK;
       BEGIN WORK;
    END EXCEPTION WITH RESUME;
	


    BEGIN WORK;



        
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/sp_actualiza_portabilidad.out";
	--TRACE ON;

    IF NVL(pEmpresa, '') = '' OR  NVL(pFolio, '') = '' OR NVL(pClaveOrigen, '') = ''  OR  NVL(pEstatusPortabilidad, '') = '' OR NVL(pSucursal, '') = '' OR NVL(pUserInsert, '') = '' OR NVL(pEstatus, '') = '' OR NVL(pOrigenCancel, '') = '' THEN --Valida que  no sean nulo o espacio en blanco
		LET cCodRet = '001288';       
		RETURN cCodRet;
    END IF;

	SELECT fecha_hoy
	INTO cFecha

	FROM bdicheq:"informix".sc_fechas 
	WHERE empresa = pEmpresa;

	LET dFecha = TO_CHAR(cFecha, '%Y%m%d');
			
	SELECT num_cte, cta_ordenante
	INTO cNumCte, cNumCtaCbe
	FROM bdicheq:"informix".sc_portacec_solicitud 
	WHERE empresa = '001'
	AND folio_solicitud = pFolio;
	
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
		LET cCodRet = "001289";
		RETURN cCodRet;
	END IF;
	
	SELECT cuenta
	INTO cCuenta
	FROM bdicheq:"informix".sc_maechq
	WHERE empresa = pEmpresa
	AND cuenta_clabe = cNumCtaCbe;
	
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
		LET cCodRet = "001289";
		RETURN cCodRet;
	END IF;
	
	UPDATE bdicheq:"informix".sc_portacec_solicitud  
	SET clave_origen = '1', estatus_portabilidad = '4', clave_sentido = '0',
		fecha_estatus_portabilidad = dFecha, suc_cancela = pSucursal, 
		user_cancela = pUserInsert, fecha_solca_portabilidad = dFecha,
		folio_cancelacion= pFolioCancel
	WHERE  empresa = pEmpresa AND folio_solicitud = pFolio; 
	
/*
	UPDATE bdicheq:"informix".sc_portabilidadnomina  
	SET estatus = '02', user_cancel = pUserInsert, 
		fecha_cancel = dFecha, origen_cancel = 'OFI', 
		sucursal_cancel = pSucursal 
	WHERE empresa = pEmpresa 
	AND cliente = cNumCte
	AND cuenta_abono = cCuenta
	AND secuencia = (SELECT MAX(secuencia) 
							FROM bdicheq:"informix".sc_portabilidadnomina 
							WHERE empresa = pEmpresa 
							AND cuenta_abono = cCuenta);	
*/

    EXECUTE PROCEDURE bdicheq:sp_PortabCancela(cNumCte, cCuenta, 'OFI', pSucursal, pUserInsert)
    INTO cCodRetSP, cMenRetSp;

    IF cCodRetSP <> '00000' THEN
        LET cCodRet = '001280';
    END IF;

    IF  iTransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
       COMMIT WORK;
    END IF;

	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
"Descripcion: Se crea procedimiento para que actualice la informacion cuando se realice una cancelacion de portabilidad de nomina.",
"Codigos de Error: ",
"",
"			cCodRet = 001288 Parametros de Entrada vacios, verifique.",
"			cCodRet = 001289 No existe informacion. Favor de verificar",
"",			
"Autor  : Jairo Valdez Gonzalez",
"Solicito: Ivan Castillo Montalvo",
"Folio: 1748",
"Sustento: RQM 10 610 Cambios en el Servicio de Portabilidad",
"Fecha  : 27/08/2015",
"BD     : bdicheq";

CREATE PROCEDURE "informix".sp_actualiza_portabilidad_pba(pEmpresa CHAR(3), 
													  pFolio CHAR(30), 
													  pClaveOrigen CHAR(1),
													  pEstatusPortabilidad CHAR(2), 
													  pSucursal CHAR(4), 
													  pUserInsert CHAR(8), 
													  pEstatus CHAR(2), 
													  pOrigenCancel CHAR(20), 
                                                      pFolioCancel CHAR(30) )
RETURNING CHAR(6);

--Declaracion de variables
DEFINE cCodRet 		CHAR(10);
DEFINE iTransaccion INTEGER;
DEFINE iSqlErr 		INTEGER;
DEFINE cFecha		DATE;
DEFINE cNumCte		CHAR(10);
DEFINE cNumCtaCbe	CHAR(18);
DEFINE cCuenta		CHAR(20);
DEFINE dFecha		CHAR(10);
DEFINE cCodRetSP    CHAR(5);
DEFINE cMenRetSp    CHAR(100);

--Asignacion de variables
LET cCodRet 	 = '000000';
LET iTransaccion = 0;
LET iSqlErr 	 = 0;
LET cFecha	 	 = DATE(1);
LET dFecha 		 = '01/01/1990';

LET cNumCte		 = '';
LET cNumCtaCbe	 = '';
LET cCuenta	 	 = '';
LET cCodRetSP 	 = '00000';
LET cMenRetSp    = '';

BEGIN

    ON EXCEPTION SET iSqlErr --Manejador de Errores	
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            IF iTransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;


            END IF;
			RETURN cCodRet;
        END IF;		
    END EXCEPTION;
	
    ON EXCEPTION IN (-535)
       LET iTransaccion = 1;
       COMMIT WORK;
       BEGIN WORK;
    END EXCEPTION WITH RESUME;
	


    BEGIN WORK;



        
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/sp_actualiza_portabilidad.out";
	--TRACE ON;

    IF NVL(pEmpresa, '') = '' OR  NVL(pFolio, '') = '' OR NVL(pClaveOrigen, '') = ''  OR  NVL(pEstatusPortabilidad, '') = '' OR NVL(pSucursal, '') = '' OR NVL(pUserInsert, '') = '' OR NVL(pEstatus, '') = '' OR NVL(pOrigenCancel, '') = '' THEN --Valida que  no sean nulo o espacio en blanco
		LET cCodRet = '001288';       
		RETURN cCodRet;
    END IF;

	SELECT fecha_hoy
	INTO cFecha

	FROM bdicheq:"informix".sc_fechas 
	WHERE empresa = pEmpresa;

	LET dFecha = TO_CHAR(cFecha, '%Y%m%d');
			
	SELECT num_cte, cta_ordenante
	INTO cNumCte, cNumCtaCbe
	FROM bdicheq:"informix".sc_portacec_solicitud 
	WHERE empresa = '001'
	AND folio_solicitud = pFolio;
	
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
		LET cCodRet = "001289";
		RETURN cCodRet;
	END IF;
	
	SELECT cuenta
	INTO cCuenta
	FROM bdicheq:"informix".sc_maechq
	WHERE empresa = pEmpresa
	AND cuenta_clabe = cNumCtaCbe;
	
	IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
		LET cCodRet = "001289";
		RETURN cCodRet;
	END IF;
	
	UPDATE bdicheq:"informix".sc_portacec_solicitud  
	SET clave_origen = '1', estatus_portabilidad = '4', clave_sentido = '0',
		fecha_estatus_portabilidad = dFecha, suc_cancela = pSucursal, 
		user_cancela = pUserInsert, fecha_solca_portabilidad = dFecha,
		folio_cancelacion= pFolioCancel
	WHERE  empresa = pEmpresa AND folio_solicitud = pFolio; 
	
/*
	UPDATE bdicheq:"informix".sc_portabilidadnomina  
	SET estatus = '02', user_cancel = pUserInsert, 
		fecha_cancel = dFecha, origen_cancel = 'OFI', 
		sucursal_cancel = pSucursal 
	WHERE empresa = pEmpresa 
	AND cliente = cNumCte
	AND cuenta_abono = cCuenta
	AND secuencia = (SELECT MAX(secuencia) 
							FROM bdicheq:"informix".sc_portabilidadnomina 
							WHERE empresa = pEmpresa 
							AND cuenta_abono = cCuenta);	
*/

    EXECUTE PROCEDURE bdicheq:sp_PortabCancela(cNumCte, cCuenta, 'OFI', pSucursal, pUserInsert)
    INTO cCodRetSP, cMenRetSp;

    IF cCodRetSP <> '00000' THEN
        LET cCodRet = '001280';
    END IF;

    IF  iTransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
       COMMIT WORK;
    END IF;

	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
"Descripcion: Se crea procedimiento para que actualice la informacion cuando se realice una cancelacion de portabilidad de nomina.",
"Codigos de Error: ",
"",
"			cCodRet = 001288 Parametros de Entrada vacios, verifique.",
"			cCodRet = 001289 No existe informacion. Favor de verificar",
"",			
"Autor  : Jairo Valdez Gonzalez",
"Solicito: Ivan Castillo Montalvo",
"Folio: 1748",
"Sustento: RQM 10 610 Cambios en el Servicio de Portabilidad",
"Fecha  : 27/08/2015",
"BD     : bdicheq";

CREATE PROCEDURE "informix".sp_consulta_com_disp(pNumCta char(20), pNumCliente char(20))
	returning char(5), money, money, money, money;

	--****************************************************************************************************
	-- DESCRIPCION:  Obtiene la comision para dispLinea, Disp OB, Disp MB, SPEI
	-- AUTOR : Jesus Ferruzca Luna - SOLSER
	-- FECHA : 02/Diciembre/2015
	-- BD: bdicheq
	-- SOLICITADO POR: Alejandro Vazquez - Coordinación Internet - GM3  - BanCoppel
	-- Liberado a produccion: 28/Enero/2016
	--****************************************************************************************************

	--Definicion de Variables
	DEFINE vCodRet char(5);
    DEFINE sql_err integer;
	DEFINE mDisp_cta_bcoppel money;
   	DEFINE mDisp_cta_otrobco money;
    DEFINE mDisp_linea money;
    DEFINE mServ_tran_spei money;
    DEFINE iCont integer;
	
	--asigacion de valores a variables
	LET vCodRet='00000';
	LET mDisp_cta_bcoppel=0;
	LET mDisp_cta_otrobco=0;
	LET mDisp_linea=0;
	LET mServ_tran_spei=0;
    LET iCont = 0;
	
	
  BEGIN


   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet, mDisp_linea, mDisp_cta_bcoppel, mDisp_cta_otrobco,  mServ_tran_spei;
      END IF ;
   END EXCEPTION ;
	
	SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;
	
	
	---Buscar comisiones de acuerdo al numCte y a la Cuenta -------------
	
	FOREACH
        SELECT disp_linea, disp_cta_bcoppel, disp_cta_otrobco, serv_tran_spei
        INTO   mDisp_linea, mDisp_cta_bcoppel, mDisp_cta_otrobco,  mServ_tran_spei
        FROM   bdicheq:"informix".sc_maecomtasserv_pm
        WHERE  num_cte = pNumCliente
        AND    cuenta = pNumCta
			
		LET iCont=1;
		
		RETURN vCodRet,  NVL(mDisp_linea,-1), NVL(mDisp_cta_bcoppel,-1), NVL(mDisp_cta_otrobco,-1), NVL(mServ_tran_spei,-1) WITH RESUME;
	END FOREACH;
	
	IF(iCont = 0) THEN
		LET vCodRet='00001';
		RETURN vCodRet, mDisp_linea, mDisp_cta_bcoppel, mDisp_cta_otrobco,  mServ_tran_spei;
	END IF;
	END;
END PROCEDURE
;