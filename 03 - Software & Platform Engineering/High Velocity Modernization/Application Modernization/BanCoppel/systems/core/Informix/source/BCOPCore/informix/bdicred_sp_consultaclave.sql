CREATE PROCEDURE "informix".sp_consultaclave(pEmpresa CHAR(3), cClave INTEGER)
        returning  CHAR(6) AS CODIGO, 
                   CHAR(3) AS EMPRESA, 
                   CHAR(20) AS CUENTA, 
                   CHAR(9) AS CLIENTE, 
                   CHAR(50) AS NOMBRE, 
                   CHAR(4) AS SUCURSAL, 
                   CHAR(30) AS BLOQUEO, 
                   CHAR(50) AS CAUSA, 
                   CHAR(2) AS ESTATUS, 
                   DATE	 AS FECHA;

--definiendo variables
        DEFINE cCodret             CHAR(6);
        DEFINE vEmpresa            CHAR(3);
        DEFINE vCuenta             CHAR(20);
        DEFINE vNumcte             CHAR(9);
        DEFINE vNombre             CHAR(50);
        DEFINE vSucursal           CHAR(4);
        DEFINE vDescripcion        CHAR(30);
        DEFINE vStatus             CHAR(2);
        DEFINE vFecha              DATE ;
        DEFINE dHora DateTime      HOUR TO SECOND;
        DEFINE cSQL_ERR            INTEGER;
        DEFINE cCausa              CHAR(50);

--inicializando variables
        LET vEmpresa               = '';
        LET vCuenta                = '';
        LET vNumcte                = '';
        LET vNombre                = '';
        LET vSucursal              = '';
        LET vDescripcion           = '';
        LET vStatus                = '';
        LET vFecha                 = '' ;
        LET dHora                  = '' ;
        LET cSQL_ERR               = 100 ;
        LET cCodret                = '000000';
        LET cCausa                 = '';

--SET DEBUG FILE TO '/tmp/sp_consultaClave.out';
--TRACE ON;

BEGIN
                ON EXCEPTION SET cSQL_ERR
                    LET cCodret = cSQL_ERR;
                    RETURN cCodret, vEmpresa, vCuenta, 
                           vNumcte, vNombre, vSucursal, 
                           vDescripcion,cCausa, vStatus, vfecha;
                END EXCEPTION;
				
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
   
    FOREACH
            SELECT mae.empresa,
                   mae.num_credito,
                   mae.numcte,
                   TRIM(cte.nombre1) || ' ' ||TRIM(cte.nombre2)|| ' ' ||TRIM(cte.apell_paterno)|| ' ' ||TRIM(apell_materno),
                   mae.sucursal,
                   TRIM(blo.descripcion),
                   TRIM(ca.causa_bloq),
                   mae.status_cred,
                   btc.fecha
              INTO vEmpresa,
                   vCuenta,
                   vNumcte,
                   vNombre,
                   vSucursal,
                   vDescripcion,
                   cCausa,
                   vStatus,
                   vfecha
              FROM bdinteg:"informix".si_cliente cte  
             INNER JOIN "informix".sd_maecred mae ON (cte.numcte = mae.numcte AND mae.status_cred NOT IN ('CV'))
             INNER JOIN "informix".sd_bloqueoscuenta blo ON (NVL(mae.id_unidad_prod,0) = NVL(blo.clave,0))
             INNER JOIN "informix".sd_bitacorabloqueocta btc ON (mae.num_credito= btc.cuenta AND btc.id = (SELECT MAX(b.id) 
                                                                                                     FROM sd_bitacorabloqueocta b 
                                                                                                    WHERE b.cuenta=mae.num_credito
																									))
             INNER JOIN "informix".sd_causa_bloqueo ca on (ca.cod_causa =mae.cod_caract_2 AND mae.empresa=ca.empresa)
             WHERE mae.empresa = pEmpresa 
			 AND blo.clave= btc.cve_bloqueo
             AND btc.cve_bloqueo = cClave			 
			 AND tipo_bloqueo = 1
             ORDER BY btc.fecha            
            
            RETURN cCodret, vEmpresa, vCuenta, vNumcte, vNombre, vSucursal, vDescripcion,cCausa, vStatus, vfecha WITH resume;
    END FOREACH;

END;
END PROCEDURE
DOCUMENT
'Autor: Rodolfo Tortolero Varela',
'Fecha: 10/11/2008',
'Descripcion: Consulta cliente por tipo de bloqueo',
'Modificó; Paul Ivan Quintero Varela',
'Descripcion: Se modifica procedimiento para que lo siguiente: ',
			'No contemple los creditos con estatus "CV"(Créditos Vendidos) .',
'Modificó: Roque Enrique Solis Campaña',
'Descripcion: Se modifica para realizar la generación de los reportes ',
	'en base a la fecha de bloqueo y no a la fecha de apertura del credito',
'Version: 20120104.1116';

CREATE PROCEDURE "informix".sp_consultafecha
(
dfecini DATE,
dfecfin DATE
)
RETURNING  
	CHAR(6) as codigo, 
	CHAR(3) as empresa, 
	CHAR(20)	as cuenta, 
	CHAR(9)	as cliente, 
	CHAR(50)	as nombre, 
	CHAR(4)	 as sucursal, 
	CHAR(30) as bloqueo,
	CHAR(50) AS CAUSA,    
	CHAR(2)	as estatus, 
	DATE as fechabloq;

--definiendo variables
	DEFINE cCodret          CHAR(6);
	DEFINE vEmpresa         CHAR(3);
	DEFINE vCuenta          CHAR(20);
	DEFINE vNumcte          CHAR(9);
	DEFINE vNombre          CHAR(50);
	DEFINE vSucursal        CHAR(4);
	DEFINE vDescripcion     CHAR(30);
	DEFINE vStatus          CHAR(2);
	DEFINE vFecha           DATE;
	--DEFINE dHora DateTime   HOUR TO SECOND;
	DEFINE cSQL_ERR         INTEGER;
	DEFINE cCausa           CHAR(50);

--inicializando variables
	LET vEmpresa            = '';
	LET vCuenta             = '';
	LET vNumcte             = '';
	LET vNombre             = '';
	LET vSucursal           = '';
	LET vDescripcion        = '';
	LET vStatus             = '';
	LET vFecha              = '' ;
	--LET dHora               = '' ;
	LET cSQL_ERR            = 100 ;
	LET cCodret             = '000000';
	LET cCausa              = '';

--SET DEBUG FILE TO '/tmp/sp_consultafecha.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET cSQL_ERR
		LET cCodret = cSQL_ERR;
		RETURN cCodret, vEmpresa, vcuenta, 
			   vNumcte, vNombre, vSucursal, 
			   vDescripcion,cCausa, vStatus, vfecha;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;

	FOREACH
		SELECT mae.empresa,
			   mae.num_credito,
			   mae.numcte,
			   TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(apell_materno), 
			   mae.sucursal, 
			   TRIM(blo.descripcion),
			   NVL(TRIM(ca.causa_bloq),''),
			   mae.status_cred,
			   btc.fecha
		INTO vEmpresa,
			 vcuenta,
			 vNumcte,
			 vNombre,
			 vSucursal,
			 vDescripcion,
			 cCausa,
			 vStatus,
			 vfecha
		FROM bdinteg:"informix".si_cliente cte  
		INNER JOIN bdicred:"informix".sd_maecred mae ON (cte.numcte = mae.numcte AND mae.status_cred NOT IN ('CV'))
		INNER JOIN bdicred:"informix".sd_bloqueoscuenta blo ON (NVL(mae.id_unidad_prod, 0) = NVL(blo.clave,0))
		INNER JOIN bdicred:"informix".sd_bitacorabloqueocta btc ON (mae.num_credito= btc.cuenta 
			AND btc.id = (SELECT MAX(b.id) 
						FROM bdicred:"informix".sd_bitacorabloqueocta b 				
						WHERE b.cuenta=mae.num_credito)
						AND btc.cve_bloqueo IS NOT NULL AND btc.cve_bloqueo<>0)
		INNER JOIN bdicred:"informix".sd_causa_bloqueo ca ON (ca.cod_causa =mae.cod_caract_2 AND mae.empresa=ca.empresa)                                                            
		WHERE btc.fecha>=dfecini
		  AND btc.fecha<=dfecfin
		  AND btc.tipo_bloqueo = 1
		ORDER BY btc.fecha
		RETURN cCodret, vEmpresa, vcuenta, vNumcte, vNombre, vSucursal, vDescripcion,cCausa, vStatus, vfecha WITH resume;
	END FOREACH;
END;

END PROCEDURE
DOCUMENT
'Autor: Rodolfo Tortolero Varela',
'Fecha: 10/11/2008',
'Descripcion: Consulta cliente por rango de fecha',
'Modificó; Paul Ivan Quintero Varela',
'Descripcion:  Se modifica procedimiento para que lo siguiente: ',
	         '1.- Los parametros de entrada del procedimiento sean de tipo date.',
			 '2.- No contemple los creditos con estatus "CV" (Créditos Vendidos) .',
'Modificó: Roque Enrique Solis Campaña',
'Descripcion: Se modifica para realizar la generación de los reportes en base a la fecha de bloqueo y',
			' no a la fecha de apertura del credito',
'Modifico:Roque Enrique Solis',
'Decripcion: Se agrego el campo para conocer la causa del bloque',
'Modifico: Mohamed Carreón',
'Descripcion: Se agrega la validacion para que se filtren los bloqueos en la bitacoras manuales',
			'tipo_bloqueo = 1. También se agrega el filtro de la liga de la clave del bloqueo de la bitácora con la clave del catálogo',
			' y se quita la validación donde filtraba solo los bloqueos (así contemplará tanto bloqueos como desbloqueos)',
'Version: 20120109.1637';

CREATE PROCEDURE "informix".sp_desbloqueocuenta (
																pEmpresa 	CHAR(3), 
																pNumCuenta 	CHAR(20), 
																pEjecutivo 	CHAR(8),
																pTipo		INTEGER
																)

RETURNING CHAR(6) AS CODIGO,
          CHAR(80) AS MENSAJECOD;

--Definicion de variables--
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(80);

DEFINE vFecha        DATE; 
DEFINE vCodSP        CHAR(6);
DEFINE vStatusCred   CHAR(2);
DEFINE iBloqueoAnt   INTEGER;
DEFINE cCausaAnt     CHAR(3);

DEFINE cCredBitacora CHAR(20);

--Set debug file to '/tmp/sp_desbloqueocuenta.out';
--trace on;

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
	  LET cCodRet= iSqlErr;
	  LET cMensajeRet= cErrorInfo;
	  RETURN 
		   cCodRet,
		   cMensajeRet;  
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
        
--Inicializar Variables--
LET iSqlErr        = 0;
LET iIsamErr       = 0;
LET cErrorInfo     = '';
LET cCodRet        = '000000';
LET cMensajeRet    = 'La cuenta se ha desbloqueado satisfactoriamente';

LET vCodSP         = '';
LET vStatusCred    = '';
LET vFecha         = DATE(1);
LET iBloqueoAnt    = 0;
LET cCausaAnt      = '';
LET cCredBitacora  = '';
        
        
	IF NVL(pEmpresa,'') = ''  OR NVL(pNumCuenta,'') = '' OR NVL(pEjecutivo,'') = '' OR 
	NVL(pTipo,'') = '' THEN
		LET cCodRet = '000001';    --Faltan Valores
		LET cMensajeRet = 'Faltan valores para ejecutar el procedimiento.'; 
	ELSE
		IF NOT EXISTS(SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'La empresa no válida';
		ELSE
			IF NOT EXISTS(SELECT ejecutivo FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pEjecutivo) THEN
				LET cCodRet = '000003';
				LET cMensajeRet = 'El ejecutivo no es valido';
			ELSE
				IF pTipo NOT IN (1,2) THEN
					LET cCodRet = '000004';
					LET cMensajeRet = 'El tipo de bloqueo no es válido';
				ELSE
					EXECUTE PROCEDURE bdicred:"informix".sp_validacredito (pEmpresa, pNumCuenta) 
					INTO vCodSP;
					IF vCodSP::INTEGER <> 0 THEN
						LET cCodRet = '000005';    --No existe el credito en la base de datos.
						LET cMensajeRet= 'La cuenta no existe';
					ELSE    
						SELECT id_unidad_prod, status_Cred, cod_caract_2
						  INTO iBloqueoAnt, vStatusCred, cCausaAnt
						  FROM bdicred:"informix".sd_maecred
						 WHERE empresa = pEmpresa 
						   AND num_credito = pNumCuenta;

						IF iBloqueoAnt IS NULL AND (cCausaAnt IS NULL  OR cCausaAnt IS NOT NULL) THEN
							LET cCodRet = '000006';    --La cuenta ya esta desbloqueada.
							LET cMensajeRet= 'La cuenta se encuentra desbloqueada';
						ELSE
							IF vStatusCred='FF' THEN
								LET cCodRet = '000011';                   
								LET cMensajeRet= 'La cuenta se encuentra saldada';   
							ELIF vStatusCred='CV' THEN
							   LET cCodRet = '000007';                   
							   LET cMensajeRet= 'La cuenta se encuentra en cartera vendida';
							ELSE
							   IF (iBloqueoAnt = 0 AND cCausaAnt IS NOT NULL) THEN --OR (iBloqueoAnt >0 AND cCausaAnt IS NULL) THEN
									LET cCodRet = '000008';
									LET cMensajeRet = 'Crédito bloqueado manualmente favor de verificar'; 
							   ELSE
									IF iBloqueoAnt > 0 THEN
										SELECT cuenta
										  INTO cCredBitacora
										  FROM bdicred:"informix".sd_bitacorabloqueocta
										 WHERE cuenta=pNumCuenta
										   AND cve_bloqueo=iBloqueoAnt
										   AND nvl(cve_causa,'')=nvl(cCausaAnt,'')
										   AND id=(SELECT max(id)
													 FROM bdicred:"informix".sd_bitacorabloqueocta
													WHERE cuenta=pNumCuenta
													  AND cve_bloqueo=iBloqueoAnt
													  AND nvl(cve_causa,'')=nvl(cCausaAnt,''));
													  
										IF cCredBitacora IS NULL THEN
											LET cCodRet = '000009';    --Cuenta bloqueada manualmente
											LET cMensajeRet= 'No es posible desbloquear, el crédito ha sido bloqueado manualmente';
										ELSE
											LET cMensajeRet= 'El crédito ha sido desbloqueado de forma automática';
											SELECT fecha_hoy
											INTO vFecha
											FROM bdicred:"informix".sd_fechas
											WHERE empresa = pEmpresa;
											
											INSERT INTO bdicred:"informix".sd_bitacorabloqueocta 
											(cuenta, cve_bloqueo, cve_causa, cve_bloqueAnterior,cve_causa_anterior,ejecutivo, fecha, tipo_bloqueo, tipo_movimiento)
											VALUES (pNumCuenta, NULL, NULL, iBloqueoAnt, cCausaAnt, pEjecutivo, vFecha, pTipo, 'D');
											
											UPDATE bdicred:"informix".sd_maecred
											SET id_unidad_prod = NULL, cod_caract_2 = NULL
											WHERE empresa = pEmpresa 
											AND num_credito = pNumCuenta;
										END IF;
									ELSE
										LET cCodRet = '000010';    
										LET cMensajeRet= 'El bloqueo actual no es valido favor de verificar';
									END IF;
								END IF;
							END IF;
						END IF;	
					END IF;
				END IF;                
			END IF;            
		END IF;        
	END IF;        		
		
	RETURN cCodRet, cMensajeRet;
        
    END;
END PROCEDURE

DOCUMENT
'Autor: Abraham Ayala Aguilar',
'Fecha: 30/10/2008',
'Descripcion: Desbloquea una cuenta e inserta un registro en la tabla sd_bitacorabloqueocta. Bloqueo Cuentas.',
'Cambio: Se cambió el valor 0 por  null en el campo id_unidad_prod ',
'Modifico: Roque Enrique Solis Campaña',
'Cambio: Se agrego que las cuentas desbloqueados pueden estar en null y en 0, Se agrgo el parametro del bloqueo anterior para insertarlo en la bitacora',
'Modifico: Roque Enrique Solis Campaña',
'Cambio: Se agrego el campo para conocer la causa del bloque',
'Modifico: Roque Enrique Solis Campaña',
'Cambio: Se agrega de tipo bloqueo (manual o masivo), tipo_bloqueo  1 = Manual, 2 = Masivo;',
'Modifico: Mohamed Carreon, Abigail Vasavilbazo Cañedo',
'Version: 20120106.0945';

CREATE PROCEDURE "informix".sp_obtienecausabloq()
RETURNING
	CHAR(6) 		AS cod_ret,
	VARCHAR(80) 	AS desc_mensaje,
	CHAR(2)			AS cve_causa,
	CHAR(60) 		AS descripcion_causa;

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE iIsamErr			INTEGER;
    DEFINE cErrorInfo		VARCHAR(80);
    DEFINE cCodRet			CHAR(6);
    DEFINE cMensajeRet		VARCHAR(80);
	DEFINE cCveCausa		CHAR(2);
	DEFINE cDescripcion		CHAR(50);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '000000';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET cCveCausa			= '';
	LET cDescripcion		= '';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			RETURN cCodRet, cMensajeRet, cCveCausa, cDescripcion;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/has/sp_ObtieneCausaBloq.out';
	--TRACE ON;
	
	FOREACH
		SELECT cod_causa, causa_bloq 
		INTO cCveCausa, cDescripcion
		FROM bdicred:"informix".sd_causa_bloqueo 
		WHERE empresa = '001'
		
		RETURN cCodRet, cMensajeRet, cCveCausa, cDescripcion WITH RESUME;
		
	END FOREACH
	IF dbinfo('sqlca.sqlerrd2') = 0 THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'NO HAY INFORMACION EN EL CATALOGO DE CAUSAS DE BLOQUEO DE CREDITO';
		RETURN cCodRet, cMensajeRet, cCveCausa, cDescripcion;
	END IF	

	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para consultar el catálogo de causas del bloqueo de cuentas de crédito', 
'AUTOR: Mohamed Carreón ',
'FECHA: Diciembre 2011',
'VERSION: 20111220.1231';

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