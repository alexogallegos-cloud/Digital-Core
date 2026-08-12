CREATE PROCEDURE "informix".sp_obtienetpobloq()
RETURNING
	CHAR(6) 		AS cod_ret,
	VARCHAR(80) 	AS desc_mensaje,
	INTEGER			AS cve_bloqueo,
	CHAR(60) 		AS descripcion_bloq;

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		VARCHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cMensajeRet		VARCHAR(80);
	DEFINE iCveBloqueo		INTEGER;
	DEFINE cDescripcion		CHAR(60);
	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '000000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET iCveBloqueo			= 0;
	LET cDescripcion		= '';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, iCveBloqueo, cDescripcion;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/has/sp_ObtieneTpoBloq.out';
	--TRACE ON;

	FOREACH
		SELECT clave, descripcion 
		INTO iCveBloqueo, cDescripcion
		FROM bdicred:"informix".sd_bloqueoscuenta 
		WHERE clave <> '0' 
		ORDER BY clave			
		
		RETURN cCodRet, cMensajeRet, iCveBloqueo, cDescripcion WITH RESUME;
		
	END FOREACH
	IF dbinfo('sqlca.sqlerrd2') = 0 THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'NO HAY INFORMACION EN EL CATALOGO DE BLOQUEOS DE CREDITO';
		RETURN cCodRet, cMensajeRet, iCveBloqueo, cDescripcion;
	END IF	

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para realizar la consulta del catálogo de bloqueos de crédito', 
'AUTOR: Mohamed Carreón ',
'FECHA: Diciembre 2011',
'VERSION: 20111220.1222';

CREATE PROCEDURE "informix".sp_reporte_bloqueo_cuenta (pFechaIni CHAR(10), pFechaFin CHAR(10), pTipoRep INTEGER )

RETURNING CHAR(5) AS CODIGO,
		  CHAR(20) AS CREDITO,
		  CHAR(20)	AS CLIENTE,
		  CHAR(90) AS NOMBRECTE,
		  CHAR(4) AS SUCURSAL,
		  CHAR(10) AS MOVIMIENTO,
		  CHAR(2)	AS ESTATUS,
		  DATE AS FECHA,
		  CHAR(8) AS EMPLEADO,
		  CHAR(90) AS NOMBREEMP;

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cCodRet      CHAR(5);
DEFINE cNumCredito  CHAR(20);
DEFINE cNumCte		CHAR(20);
DEFINE cNombreCte   CHAR(90);
DEFINE cSucursal	CHAR(4);
DEFINE cEstatus		CHAR(2);
DEFINE dtFecha		DATE;
DEFINE cEmpleado	CHAR(8);
DEFINE cNombreEmp	CHAR(90);
DEFINE cTpoMovto	CHAR(1);
DEFINE cMovto		CHAR(10);

LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cNumCte		 	='';
LET cNombreCte      ='';
LET cSucursal		='';
LET cEstatus		='';
LET dtFecha			='';
LET cEmpleado		='';
LET cNombreEmp		='';
LET cCodRet         ='00000';
LET cNumCredito  	= '';
LET cMovto			= '';

BEGIN 

	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN  cCodRet, NVL(cNumCredito, ''),  NVL(cNumCte, ''), NVL(cNombreCte, ''), NVL(cSucursal, ''), NVL(cMovto, ''), NVL(cEstatus, ''),
			NVL(dtFecha, '01-01-1990'), NVL(cEmpleado, ''), NVL(cNombreEmp, '') WITH RESUME;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_reporte_bloqueo_cuenta.out"; 
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;
	
	IF pFechaIni IS NULL OR pFechaIni = '' OR pFechaFin IS NULL OR pFechaFin= '' OR pTipoRep IS NULL THEN
		LET cCodRet = '00001';
		RETURN  cCodRet, NVL(cNumCredito, ''),  NVL(cNumCte, ''), NVL(cNombreCte, ''), NVL(cSucursal, ''), NVL(cMovto, ''), NVL(cEstatus, ''),
		NVL(dtFecha, '01-01-1990'), NVL(cEmpleado, ''), NVL(cNombreEmp, '') WITH RESUME;
	END IF
	
	IF pTipoRep <> 1 	AND pTipoRep <>2 THEN
		LET cCodRet = '00002';
		RETURN  cCodRet, NVL(cNumCredito, ''),  NVL(cNumCte, ''), NVL(cNombreCte, ''), NVL(cSucursal, ''), NVL(cMovto, ''), NVL(cEstatus, ''),
		NVL(dtFecha, '01-01-1990'), NVL(cEmpleado, ''), NVL(cNombreEmp, '') WITH RESUME;
	END IF
	
	IF pTipoRep = 1 THEN
		LET cTpoMovto= 'B';
		LET cMovto = 'BLOQUEO';	
	
		FOREACH
		
			SELECT mae.num_credito,
				   mae.numcte,
				   TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(apell_materno), 
				   mae.sucursal, 			  
				   mae.status_cred,
				   btc.fecha,
				   btc.ejecutivo
			INTO cNumCredito,
				 cNumCte,
				 cNombreCte,
				 cSucursal,					
				 cEstatus,
				 dtFecha,
				 cEmpleado
			FROM bdinteg:"informix".si_cliente cte  
			INNER JOIN bdicred:"informix".sd_maecred mae ON (cte.numcte = mae.numcte AND mae.status_cred NOT IN ('CV'))
			INNER JOIN bdicred:"informix".sd_bloqueoscuenta blo ON (NVL(mae.id_unidad_prod, 0) = NVL(blo.clave,0))
			INNER JOIN bdicred:"informix".sd_bitacorabloqueocta btc ON (mae.num_credito= btc.cuenta) 
			INNER JOIN bdicred:"informix".sd_causa_bloqueo ca ON (ca.cod_causa =btc.cve_causa AND mae.empresa=ca.empresa)                                                            
			WHERE btc.fecha>=pFechaIni
			  AND btc.fecha<=pFechaFin
			  AND btc.tipo_bloqueo = 2
			  AND btc.tipo_movimiento = cTpoMovto
			ORDER BY btc.fecha
			
			SELECT nombre
			INTO cNombreEmp
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = cEmpleado;
			
			RETURN  cCodRet, NVL(cNumCredito, ''),  NVL(cNumCte, ''), NVL(cNombreCte, ''), NVL(cSucursal, ''), NVL(cMovto, ''), NVL(cEstatus, ''),
					NVL(dtFecha, '01-01-1990'), NVL(cEmpleado, ''), NVL(cNombreEmp, '') WITH RESUME;
			
		END FOREACH;	
		
	ELSE
		LET cTpoMovto= 'D';
		LET cMovto = 'DESBLOQUEO';
		
		FOREACH
	
			SELECT mae.num_credito,
				   mae.numcte,
				   TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(apell_materno), 
				   mae.sucursal, 			  
				   mae.status_cred,
				   btc.fecha,
				   btc.ejecutivo
			INTO cNumCredito,
				 cNumCte,
				 cNombreCte,
				 cSucursal,					
				 cEstatus,
				 dtFecha,
				 cEmpleado
			FROM bdinteg:"informix".si_cliente cte  
			INNER JOIN bdicred:"informix".sd_maecred mae ON (cte.numcte = mae.numcte AND mae.status_cred NOT IN ('CV'))			
			INNER JOIN bdicred:"informix".sd_bloqueoscuenta blo ON (NVL(mae.id_unidad_prod, 0) = NVL(blo.clave,0))
			INNER JOIN bdicred:"informix".sd_bitacorabloqueocta btc ON (mae.num_credito= btc.cuenta) 
			WHERE btc.fecha>=pFechaIni
			  AND btc.fecha<=pFechaFin
			  AND btc.tipo_bloqueo = 2
			  AND btc.tipo_movimiento = cTpoMovto
			ORDER BY btc.fecha
			
			SELECT nombre
			INTO cNombreEmp
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo = cEmpleado;
			
			RETURN  cCodRet, NVL(cNumCredito, ''),  NVL(cNumCte, ''), NVL(cNombreCte, ''), NVL(cSucursal, ''), NVL(cMovto, ''), NVL(cEstatus, ''),
					NVL(dtFecha, '01-01-1990'), NVL(cEmpleado, ''), NVL(cNombreEmp, '') WITH RESUME;
		
		END FOREACH;	
	END IF
	
	

END
END PROCEDURE
DOCUMENT
'Descripcion: Obtiene informacion para el reporte por fechas de bloqueos/desbloqueos masivos',
'AUTOR : Abigail Vasavilbazo Cañedo',
'FECHA : 29/12/2010',
'MODIFICACION: Se modifica para qu regrese el detalle de los bloqueos y desbloques de cuentas ya que se regresaba solo el ultimo movimiento',
'				es decir el ultimo cambio realizado a la cuenta.',
'AUTOR MODIFICACION: Héctor Manuel Bojorquez Ruelas.',
'FECHA MODIFICACION: 01/03/2012.',
'BD    : BDICRED',
'Version: 20120301.1120';

CREATE PROCEDURE "informix".sp_calif_maecred(pEmpresa CHAR(3))

RETURNING 
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje;
          
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(6); 
DEFINE cMensajeRet       CHAR(80);

DEFINE cBegin            CHAR(1);
DEFINE vcontador_insert  INTEGER;
DEFINE dtFechaCorte  DATE;
DEFINE dtFechaUltMes DATE;

DEFINE cNumCredito 	 CHAR(20);
DEFINE cGradoRiesgo                  CHAR(2);

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          ROLLBACK WORK;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "sp_calculo_reserva_corte.out";
    --TRACE ON;

    LET iSqlErr=0;
    LET iIsamErr=0;
    LET cErrorInfo="";
    LET cCodRet= '000000';
    LET cMensajeRet= 'El proceso de CORRECCION DE LA CALIFICACION se realizó correctamente';
    LET cBegin= 'F';
    LET vcontador_insert= 0;
    LET dtFechaCorte = date(1);
    LET dtFechaUltMes = date(1);
    let cGradoRiesgo = '';
    LET cNumCredito 		= 	'';

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


    FOREACH WITH HOLD
       SELECT num_credito, grado_riesgo
         INTO cNumCredito, cGradoRiesgo
         from bdicred:sd_hist_reserva
          where empresa = '001'
          and fecha_CIERRE = mdy('03','31','2012')

          begin work;
            update bdicred:sd_maecred SET calificacion_riesgo = cGradoRiesgo where empresa = '001' AND num_credito = cNumCredito;
          commit work;
    END FOREACH;


    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'AUTOR : ',
'FECHA : ',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_corrige_calificacion(pEmpresa CHAR(3))

RETURNING 
          CHAR(6) AS resultado,
          CHAR(80) AS mensaje;
          
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE cCodRet           CHAR(6); 
DEFINE cMensajeRet       CHAR(80);

DEFINE cBegin            CHAR(1);
DEFINE vcontador_insert  INTEGER;
DEFINE dtFechaCorte  DATE;
DEFINE dtFechaUltMes DATE;

DEFINE cNumCredito 	 CHAR(20);

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet= iSqlErr;
          ROLLBACK WORK;
          RETURN cCodRet, cMensajeRet;
       END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "sp_calculo_reserva_corte.out";
    --TRACE ON;

    LET iSqlErr=0;
    LET iIsamErr=0;
    LET cErrorInfo="";
    LET cCodRet= '000000';
    LET cMensajeRet= 'El proceso de CORRECCION DE LA CALIFICACION se realizó correctamente';
    LET cBegin= 'F';
    LET vcontador_insert= 0;
    LET dtFechaCorte = date(1);
    LET dtFechaUltMes = date(1);

    LET 	cNumCredito 		= 	'';

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    FOREACH WITH HOLD
       SELECT num_credito
         INTO cNumCredito
         from bdicred:sd_maesdoscont
          where empresa = '001'
          and fecha = mdy('03','31','2012')
          and sdo_cap_insoluto <> sdo_capital + monto_vencido + mto_venc_trasp + cap_tras_no_venci

          begin work;
            delete from bdicred:sd_hist_reserva where empresa = '001' AND num_credito = cNumCredito AND fecha_CIERRE = mdy('03','31','2012');
            delete from bdicred:sd_maesdoscont  where empresa = '001' AND num_credito = cNumCredito AND fecha = mdy('03','31','2012');
          commit work;
    END FOREACH;


    FOREACH WITH HOLD
       SELECT num_credito
         INTO cNumCredito
         from bdicred:sd_hist_reserva
          where empresa = '001'
          and fecha_CIERRE = mdy('03','31','2012')
          AND antecedente_buro IN ('X','0') 
          AND reserva_buro > 0

          begin work;
            update bdicred:sd_hist_reserva SET reserva_buro = 0, reserva_buro_gradual = 0 where empresa = '001' AND num_credito = cNumCredito AND fecha_CIERRE = mdy('03','31','2012');
          commit work;
    END FOREACH;

    UPDATE statistics medium FOR TABLE bdicred:sd_hist_reserva;
    UPDATE statistics medium FOR TABLE bdicred:sd_maesdoscont;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'AUTOR : ',
'FECHA : ',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_obtenercuentascolocacion(p_sEmpresa CHAR(3), p_sNumCliente CHAR(20))

	RETURNING 	CHAR(6) AS retorno, CHAR(3) AS empresa, CHAR(20) AS numcredito, CHAR(20) AS numcliente,
				CHAR(1) AS identificador;

	--VARIABLES DE ERROR DEL SP
    DEFINE cVarDataErr			VARCHAR(255);
    DEFINE iSqlErr				INTEGER;
    DEFINE iSamErr				INTEGER;

	--DECLARACIÓN DE VARIABLES DE USO DEL SP
	DEFINE v_sValRetorno		CHAR(6);
	DEFINE v_sEmpresa			CHAR(3);
	DEFINE v_sNumcredito		CHAR(20);
	DEFINE v_sNumCliente		CHAR(20);
	DEFINE v_sIdentificador		CHAR(1);

	-----------------------------------------------------------------------
	--Creado por: Vladimir Félix Gálvez
	--Fecha de Creación: 07-Agosto-2009
	--Caso de uso asociado: 
	--Obtiene las cuentas de credito de los clientes.
	--Debug del Procedure
	--SET DEBUG FILE TO "/tmp/vladi/sp_obtenercuentascolocacion.out";
	--TRACE ON;
	-----------------------------------------------------------------------

	LET v_sValRetorno 		= '000001';
	LET v_sEmpresa			= '';
	LET v_sNumcredito		= '';
	LET v_sNumCliente		= '';
	LET v_sIdentificador	= '';

	BEGIN

		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
			IF iSqlErr <> 0 THEN
				LET v_sValRetorno = iSqlErr;
				RETURN v_sValRetorno,'','','','';
			END IF;
		END EXCEPTION;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumCliente, '') = '' THEN
			RETURN v_sValRetorno,'','','','';
		END IF;

		LET p_sNumCliente = LPAD(TRIM(p_sNumCliente),9,'0');
		--Consultar la información del catalogo de nomina de las empresas.
		FOREACH
			SELECT empresa, num_credito, numcte, 'C'
			INTO v_sEmpresa, v_sNumcredito, v_sNumCliente, v_sIdentificador
			FROM bdicred:sd_maecred 
			WHERE empresa = p_sEmpresa
			AND numcte = p_sNumCliente
			

			LET v_sValRetorno = '000000';
			RETURN  v_sValRetorno, v_sEmpresa, v_sNumcredito, v_sNumCliente, v_sIdentificador WITH RESUME;

		END FOREACH;
	END;
END PROCEDURE;