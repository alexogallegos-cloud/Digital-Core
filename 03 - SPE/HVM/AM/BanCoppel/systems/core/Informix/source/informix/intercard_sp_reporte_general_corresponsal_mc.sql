CREATE PROCEDURE "informix".sp_reporte_general_corresponsal_mc(
            pFechaInicio DATETIME YEAR TO FRACTION(5),
            pFechaFin DATETIME YEAR TO FRACTION(5),
            pTopMotivos SMALLINT
    )
    RETURNING CHAR(2) as vCategoriaPadre, VARCHAR(100) as vNombreCategoria, INTEGER as vTotalTransacciones;


    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO CHAR(40);
	DEFINE RUTA_ORIGEN VARCHAR(50); 
    DEFINE RUTA_UNLOAD VARCHAR(15); 
    DEFINE PREFIJO_SCRIPTS CHAR(11);
    DEFINE NOMBRE_REPORTE VARCHAR(27);
	DEFINE NOMBRE_ARCH_UNL VARCHAR(18);
	DEFINE vExecuteSQL LVARCHAR(4000);
    DEFINE vFechaInicio DATETIME YEAR TO FRACTION(5);
    DEFINE vFechaFinal DATETIME YEAR TO FRACTION(5);
    
    DEFINE vCategoriaPadre CHAR(2);
    DEFINE vNombreCategoria VARCHAR(100);
    DEFINE vTotalTransacciones INTEGER;
    
    LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_ORIGEN = '/resplogifx/mon_transacc_mastercard/';
    LET RUTA_UNLOAD = '/RESPALDOSNEW/';
    LET PREFIJO_SCRIPTS = 'script_mon_';
    LET NOMBRE_ARCH_UNL = 'trxs_mastercard';
    LET NOMBRE_REPORTE = 'reporte_trxs_mastercard';
    LET vExecuteSQL = '';
    LET vFechaInicio = pFechaInicio;
    LET vFechaFinal = pFechaFin;
    
    LET vCategoriaPadre = '';
    LET vNombreCategoria = '';
    LET vTotalTransacciones  = 0;
    
    BEGIN 

        
        --SET DEBUG FILE TO RUTA_ORIGEN || "ejecucion_sp_reporte_general_corresponsal_mc.out";
        --TRACE ON;        
        
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;        
        
        FOREACH
                    SELECT
            CASE
                WHEN mov.codigoiso IN ('12', '14', '82', '96') THEN '01'
                WHEN mov.codigoiso IN ('04', '57', '59', '62', '75') THEN '02'
                WHEN mov.codigoiso IN ('05', '13', '57') THEN '03'
                WHEN mov.codigoiso IN ('51', '54', '55') THEN '04'
                WHEN mov.codigoiso IN ('00') THEN '05'
            END cod_categoria,
            CASE
                WHEN mov.codigoiso IN ('12', '14', '82', '96') THEN 'Errores Tecnicos'
                WHEN mov.codigoiso IN ('04', '59', '62', '75') THEN 'Errores Operativos'
                WHEN mov.codigoiso IN ('05', '13', '57') THEN 'Normativos'
                WHEN mov.codigoiso IN ('51', '54', '55') THEN 'Cliente'
                WHEN mov.codigoiso IN ('00') THEN 'Aprobadas'
            END nombre_categoria,
		COUNT(*) as trxs_por_categoria
            INTO vCategoriaPadre, vNombreCategoria, vTotalTransacciones
            FROM intercard:movimiento mov
        WHERE fechahorainauth BETWEEN vFechaInicio AND vFechaFinal
                AND transaccionorigen = '2345'
                    AND codtran = '28'
                AND movreversado = 'F'                
            GROUP BY 1,2
                ORDER BY 1
            
            RETURN vCategoriaPadre, vNombreCategoria,vTotalTransacciones WITH RESUME;
            
        END FOREACH
        
        
    END
    
END PROCEDURE

--Descripcion: Reporte de transaccionalidad.
--Base de datos: intercard
--Fecha de creacion: 11 de noviembre del 2019 10:00am
;

CREATE PROCEDURE "informix".sp_puntoscompro_generaarchivo(pUsuario CHAR(8), pIdFuncion CHAR(10),psProdInd VARCHAR(2), psIdPOSATM VARCHAR(19), 
psGiro VARCHAR(4), psTarjetas CHAR(570), psModoCaptura VARCHAR(2), psCodigoIso VARCHAR(2),   pdtFechaIni DATE, pdtFechaFin DATE,pRuta CHAR(100),pTipoReporte SMALLINT)
        RETURNING CHAR(5) AS codret,
			  CHAR(80) AS ruta_archivo,
			  CHAR(30) AS nombre_archivo;

	DEFINE cCodRet CHAR(5);
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRetSp CHAR(6);
    DEFINE iCodRetSp INTEGER;
	DEFINE cRutaArchivo CHAR(100);
	DEFINE cNombreArchivo CHAR(30);
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET cCodRetSp = '000000';
    LET iCodRetSp = 0;
	LET cRutaArchivo = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	
	BEGIN
	 
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			
			UPDATE bdicnweb:"informix".statusconsultareportepuntoscompromiso
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
			WHERE usuario_insert = TRIM(pUsuario);
			
			RETURN cCodRet, cRutaArchivo, cNombreArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		-- SE LIMPIA TABLA POR USUARIO Y PROCESO
		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdicnweb:"informix".statusconsultareportepuntoscompromiso
		WHERE usuario_insert = TRIM(pUsuario);
		
		-- SE INSERTA A TABLA PARA EL MONITOREO DEL STATUS
		SET LOCK MODE TO WAIT 3; 
		INSERT INTO bdicnweb:"informix".statusconsultareportepuntoscompromiso(usuario_insert,status,ruta_archivo,nombre_archivo,error_proceso,error)
			VALUES(pUsuario,'I','','','','');
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_puntoscompro_generaarchivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR psProdInd ='' OR pdtFechaIni IS NULL OR pdtFechaFin IS NULL OR pRuta = '' OR pTipoReporte IS NULL THEN
			LET cCodRet = '00003';
			UPDATE bdicnweb:"informix".statusconsultareportepuntoscompromiso
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
			WHERE usuario_insert = TRIM(pUsuario);
			
			RETURN cCodRet, cRutaArchivo, cNombreArchivo;
		END IF;
        
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			UPDATE bdicnweb:"informix".statusconsultareportepuntoscompromiso
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
			WHERE usuario_insert = TRIM(pUsuario);
			RETURN cCodRet, cRutaArchivo, cNombreArchivo;
		END IF;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		--SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE intercard:"informix".sp_puntoscompromiso3(psProdInd , psIdPOSATM , 
									psGiro , psTarjetas , psModoCaptura , psCodigoIso ,   pdtFechaIni , pdtFechaFin ,pUsuario,pRuta,pTipoReporte)  
        INTO cCodRetSp, cRutaArchivo, cNombreArchivo;
	
		--IF bInTransaction = 't' THEN
		--	BEGIN WORK;
		--END IF;

		IF cCodRet::INT > 0 THEN
			IF bInTransaction THEN
				BEGIN WORK;
			END IF;
		END IF;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
	
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP intercard:'informix'.sp_puntoscompromiso3";
		END IF;
		
		
		IF cCodRet = '00000' THEN
			-- SE ACTUALIZA CON EXITO LA CONSULTA
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".statusconsultareportepuntoscompromiso
			SET  status = 'T', ruta_archivo = cRutaArchivo ,nombre_archivo = cNombreArchivo, error_proceso = 'N' 
			WHERE usuario_insert = TRIM(pUsuario);
		ELSE
			-- SE ACTUALIZA EN CASO DE ERROR
			SET LOCK MODE TO WAIT 3;
			UPDATE bdicnweb:"informix".statusconsultareportepuntoscompromiso
			SET  status = 'E', error_proceso = 'S', error = TRIM(cCodRet) 
			WHERE usuario_insert = TRIM(pUsuario);
		END IF;

		RETURN cCodRet, cRutaArchivo, cNombreArchivo;
    
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 13/02/2016',
'MODULO: CONSULTAS > APOYO',
'FUNCIONALIDAD: CONSULTAS DE PUNTOS COMPROMISOS',
'DESCRIPCION:SPL Intermedio que genera archivo',
'BD: intercard',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 23/09/2019',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTAS DE PUNTOS COMPROMISOS',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: intercard';

CREATE PROCEDURE "informix".sp_puntoscompromiso(psProdInd VARCHAR(2), psIdPOSATM VARCHAR(19), psGiro VARCHAR(4), psTarjetas CHAR(570), psModoCaptura VARCHAR(2), psCodigoIso VARCHAR(2), pUsuario CHAR(10),  pdtFechaIni DATE, pdtFechaFin DATE)
RETURNING
INTEGER AS Contador,
VARCHAR(3) AS Status,
VARCHAR(13) AS NumCliente,
VARCHAR(5) AS Sucursal,
VARCHAR(16) AS NumTarjeta,
VARCHAR(40) AS InfReceptor,
DATETIME YEAR TO FRACTION AS FechaHoraInAuth,
MONEY (19,4) AS Monto,
VARCHAR(16) AS IdTerminal,
VARCHAR(4) AS IdReceptor,
VARCHAR(2) AS MetodoCaptura,
VARCHAR(2) AS CodigoIso,
VARCHAR(70) AS Motivo,
INTEGER AS LoteTarjeta,
VARCHAR(7) AS Secuencia,
VARCHAR(12) AS Referencia,

VARCHAR(13) AS NumCuenta,
VARCHAR(50) AS CiudadComercio,
VARCHAR(4) AS GiroComercio,
VARCHAR(19) AS IdRetailer,
DATE AS FechaOperacion,
DATETIME HOUR TO FRACTION(3) As HoraOperacion


--****************************************************************************************************
-- DESCRIPCION:  REPORTES DE PUNTOS DE COMPROMISO POS Y ATM
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 26/11/2010
-- BD: INTERCARD
-- SISTEMA : FRAUDES
-- MODIFICADO :
---- NOMBRE                        FECHA                    DESCRIPCION
--   Juan Daniel Lazalde        03-10-2013      Se agrego consulta en las tablas tarjeta y lote y se cambio el orden de las variables retorno
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE viContador INTEGER;
DEFINE vsSecuencia VARCHAR(7);
DEFINE vsCodigoIso VARCHAR(2);
DEFINE vsNumTarjeta VARCHAR(16);
DEFINE vsReferencia VARCHAR(12);
DEFINE vmMonto MONEY (19,4);
DEFINE vsInfReceptor VARCHAR(40);
DEFINE vsIdReceptor VARCHAR(4);
DEFINE vsIdTerminal VARCHAR(16);
DEFINE vsMetodoCaptura VARCHAR(2);
DEFINE vsMotivo VARCHAR(70);
DEFINE vdtFechaHoraInAuth DATETIME YEAR TO FRACTION(5);
DEFINE vsSecuenciaExtendida VARCHAR(16);
DEFINE vsNumCuenta VARCHAR(13);
DEFINE vsCiudadComercio VARCHAR(50);
DEFINE vsGiroComercio VARCHAR(4);
DEFINE vsIdRetailer VARCHAR(19);
DEFINE dtFechaOperacion DATE;
DEFINE dtHoraOperacion DATETIME HOUR TO FRACTION(5);

DEFINE vdtFechaIni DATETIME YEAR TO FRACTION(5);
DEFINE vdtFechaFin DATETIME YEAR TO FRACTION(5);

DEFINE viSqlErr INTEGER;
DEFINE viSamErr INTEGER;

DEFINE vdtFechaAux DATETIME YEAR TO FRACTION(5);
--
DEFINE vsStatusTarjeta VARCHAR(3);
DEFINE vsNumCliente VARCHAR(13);
DEFINE vsSucursal VARCHAR(5);
DEFINE viNumeroLote INTEGER;
DEFINE viPaso INTEGER;
DEFINE vLongitud INTEGER;
DEFINE vAprobadaRechazada CHAR(1); --T:Todas, A:Aprobadas, R:Rechazadas
DEFINE vTarjetas CHAR(1); --T:Todas, A:Una o más
DEFINE vGiro CHAR(1); --T:Todas, A:Solo un giro
DEFINE vModoCaptura CHAR(1); --T:Todas, A:Solo un método de entrada
DEFINE vTerminalRetailer CHAR(1); --T:IDTerminal de ATM, R:IDRetailer de POS
DEFINE vIDTerminalRetailer CHAR(1); --T:Todos, A:Solo un ID

/* INICIALIZACION DE VARIABLES */
LET viContador = 0;
LET vsSecuencia = '';
LET vsCodigoIso = '';
LET vsNumTarjeta = '';
LET vsReferencia = '';
LET vmMonto = 0.0;
LET vsInfReceptor = '';
LET vsIdReceptor = '';
LET vsIdTerminal = '';
LET vsMetodoCaptura = '';
LET vsMotivo = '';
LET vdtFechaHoraInAuth = CURRENT;
LET vsSecuenciaExtendida = '';

LET vdtFechaIni = CURRENT;
LET vdtFechaFin = CURRENT;

LET viSqlErr = 0;
LET viSamErr = 0;

LET vsStatusTarjeta = '';
LET vsNumCliente = '';
LET vsSucursal = '';
LET viNumeroLote = 0;

LET vsNumCuenta = '';
LET vsCiudadComercio = '';
LET vsGiroComercio = '';
LET vsIdRetailer = '';
LET dtFechaOperacion = TODAY;
LET dtHoraOperacion = TODAY;

LET viPaso = 0;
LET vLongitud = 0;
LET vAprobadaRechazada = '';
LET vTarjetas = '';
LET vGiro = '';
LET vModoCaptura = '';
LET vTerminalRetailer = '';
LET vIDTerminalRetailer = '';

BEGIN
	ON EXCEPTION

		SET viSqlErr, viSamErr

		RETURN 0,NULL,NULL,NULL,viSqlErr,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,viSqlErr,NULL,NULL,NULL,NULL,NULL,NULL,NULL;

	END EXCEPTION;

	/*SET DEBUG FILE TO "/informix/sp_PuntosCompromiso.txt";
	TRACE ON;*/

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	create temp table tempTarjetas(
		   tt_numtarjeta CHAR(16)) with no log;
			   
	LET psProdInd = trim(psProdInd);
	LET psIdPOSATM = trim(psIdPOSATM);
    LET psGiro = trim(psGiro);
	LET psTarjetas = trim(psTarjetas);
	LET psModoCaptura = trim(psModoCaptura);
 	LET psCodigoIso = trim(psCodigoIso);
	
	 IF(psProdInd = '01') THEN	    
		LET vTerminalRetailer = 'T'; --ATM
	 ELSE
        LET vTerminalRetailer = 'R'; --POS
     END IF;
	 
	 IF(psIdPOSATM = '') THEN	    
		LET vIDTerminalRetailer = 'T'; --ATM
	 ELSE
        LET vIDTerminalRetailer = 'A'; --POS
     END IF;
	
	 IF(psGiro = '') THEN
		LET vGiro = 'T';
	 ELSE
        LET vGiro = 'A';
     END IF;
	 
	 IF(psModoCaptura = '') THEN
		LET vModoCaptura = 'T';
	 ELSE
	 	LET vModoCaptura = 'A';
     END IF;
	 
	 IF(psCodigoIso = '') THEN
			 LET vAprobadaRechazada = 'T'; --Todas
		 ELIF(psCodigoIso = '99') THEN		     
		     LET vAprobadaRechazada = 'R'; --Solo Rechazadas
		 ELIF(psCodigoIso = '00') THEN 
		     LET vAprobadaRechazada = 'A'; --Solo Aprobadas
     END IF;
	 
	 IF(psTarjetas = '') THEN
		LET vTarjetas = 'T';
	 ELSE	      
		  LET vTarjetas = 'A';
	      LET viPaso = 1;		  	      
		  LET vLongitud = length(psTarjetas);
		  WHILE viPaso < vLongitud
		       insert into tempTarjetas (tt_numtarjeta) values(substring(psTarjetas from viPaso for (viPaso + 16)));
			   LET viPaso = viPaso + 17;
		  END WHILE;		  
     END IF;
	
	IF (NVL(psProdInd,'00') <> '01') AND (NVL(psProdInd,'00') <> '02') THEN --ERROR
		
		RETURN 0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'00001',NULL,NULL,NULL,NULL,NULL,NULL,NULL;

		--ATM 01   POS 02
	ELIF (((psProdInd = '01') AND (LENGTH(NVL(psIdPOSATM, '')) > 16) AND (NVL(psIdPOSATM, '') <> ''))
		OR ((psProdInd = '02') AND (LENGTH(NVL(psIdPOSATM, '')) > 19) AND (NVL(psIdPOSATM, '') <> ''))) THEN

		
		RETURN 0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'00002',NULL,NULL,NULL,NULL,NULL,NULL,NULL;

	ELIF (pdtFechaIni IS NULL) OR  (pdtFechaFin IS NULL) THEN --ERROR

		
		RETURN 0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'00003',NULL,NULL,NULL,NULL,NULL,NULL,NULL;

	ELSE
	
		FOREACH 
			SELECT contador, status, numcliente, sucursal, numtarjeta, infreceptor, fechahorainauth, monto, idterminal, idreceptor, metodocaptura, codigoiso, motivo, lotetarjeta, secuencia, referencia, numcuenta, ciudadcomercio, girocomercio, idretailer, fechaoperacion, horaoperacion
			INTO viContador, vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia,
				vsNumCuenta,vsCiudadComercio,vsGiroComercio,vsIdRetailer,dtFechaOperacion,dtHoraOperacion
			FROM bdicnweb:"informix".sw_consultapuntoscompromiso
			WHERE usuario = pUsuario					
				
				RETURN viContador, vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia,
                        vsNumCuenta,vsCiudadComercio,vsGiroComercio,vsIdRetailer,dtFechaOperacion,dtHoraOperacion WITH RESUME;
						
		END FOREACH;

--		LET vdtFechaIni = pdtFechaIni;
--		LET vdtFechaIni = SUBSTRING(vdtFechaIni FROM 1 FOR 10) || ' 00:00:00';
--
--		LET vdtFechaFin = pdtFechaFin;
--		LET vdtFechaFin = SUBSTRING(vdtFechaFin FROM 1 FOR 10) || ' 23:59:59';
--
--		LET vdtFechaAux = CURRENT;
--
--		--OBTIENE LA FECHA MINIMA DE LA TABLA DE MOVIMIENTOS
--		SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_fechahorainauth)} MIN(FechaHoraInAuth)
--		INTO vdtFechaAux
--		FROM intercard:"informix".movimiento;			
--
--				IF ((pdtFechaIni BETWEEN vdtFechaAux::DATE AND CURRENT::DATE) 
--				OR  (pdtFechaFin BETWEEN vdtFechaAux::DATE AND CURRENT::DATE) )THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOS
--				    LET viPaso = 1;
--					FOREACH SELECT {+INDEX(intercard:"informix".movimiento "informix".idx_movimientonew4a)}
--						t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia,
--						r.numcuenta, '', m.codgironeg, m.idretailer, m.fechahorainauth::date, substr(m.fechahorainauth,12,8) 	
--						INTO vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia,
--						     vsNumCuenta,vsCiudadComercio,vsGiroComercio,vsIdRetailer,dtFechaOperacion,dtHoraOperacion
--						FROM intercard:"informix".movimiento m
--						LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta 
--						LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
--						LEFT JOIN intercard:"informix".tarjetacuenta r on r.numtarjeta = m.Numtarjeta
--						WHERE m.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
--						AND m.ProdInd = psProdInd
--						AND((vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'A' AND m.IdTerminal = psIdPOSATM) OR
--						    (vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'T' AND 1=1) OR
--						    (vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'A' AND m.IdRetailer = psIdPOSATM) OR
--							(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'T' AND 1=1))
--						AND((vModoCaptura = 'A' AND m.metodocaptura = psModoCaptura) OR
--						    (vModoCaptura = 'T' AND 1 = 1))
--						AND((vGiro = 'A' AND m.codgironeg = psGiro) OR
--						    (vGiro = 'T' AND 1 = 1))
--						AND ((vTarjetas = 'A' AND m.numtarjeta in(select tt_numtarjeta from tempTarjetas)) OR
--						     (vTarjetas = 'T' AND 1=1 ))
--						AND((vAprobadaRechazada = 'T' AND 1=1) OR
--						    (vAprobadaRechazada = 'A' AND m.codigoiso = '00') OR
--							(vAprobadaRechazada = 'R' AND m.codigoiso <> '00'))
--						ORDER BY m.FechaHoraInAuth DESC
--						
--						LET viContador = viContador + 1;						
--						RETURN viContador, vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia,
--                               vsNumCuenta,vsCiudadComercio,vsGiroComercio,vsIdRetailer,dtFechaOperacion,dtHoraOperacion WITH RESUME;
--
--					END FOREACH;
--				END IF;
--
--				IF ((pdtFechaIni BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))
--				OR  (pdtFechaFin BETWEEN '01/01/1900' AND (vdtFechaAux::DATE + 1))) THEN --VALIDA SI EL RANGO DE BUSQUEDA ESTA DENTRO DE LA TABLA DE MOVIMIENTOHISTORICO
--				    LET viPaso = 2;
--					FOREACH SELECT 
--						t.codstatustarjeta, t.numcliente, l.clave_sucursal, m.NumTarjeta, m.InfReceptor, m.FechaHoraInAuth, m.Monto, m.IdTerminal, m.IdReceptor, m.MetodoCaptura, m.CodigoIso, m.Motivo, t.numerolote, m.Secuencia, m.Referencia, SecuenciaExtendida,
--						r.numcuenta, '', m.codgironeg, m.idretailer, m.fechahorainauth::date, substr(m.fechahorainauth,12,8) 	
--						INTO vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia, vsSecuenciaExtendida,
--						vsNumCuenta,vsCiudadComercio,vsGiroComercio,vsIdRetailer,dtFechaOperacion,dtHoraOperacion
--						FROM intercard:"informix".movimientohistorico m
--						LEFT JOIN intercard:"informix".tarjeta t on t.numtarjeta = m.NumTarjeta 
--						LEFT JOIN intercard:"informix".lote l on l.numerolote = t.numerolote
--						LEFT JOIN intercard:"informix".tarjetacuenta r on r.numtarjeta = m.Numtarjeta
--						WHERE m.FechaHoraInAuth BETWEEN vdtFechaIni AND vdtFechaFin
--						AND m.ProdInd = psProdInd
--  					    AND((vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'A' AND m.IdTerminal = psIdPOSATM) OR
--						    (vTerminalRetailer = 'T' AND vIDTerminalRetailer = 'T' AND 1=1) OR
--						    (vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'A' AND m.IdRetailer = psIdPOSATM) OR
--							(vTerminalRetailer = 'R' AND vIDTerminalRetailer = 'T' AND 1=1))
--						AND((vModoCaptura = 'A' AND m.metodocaptura = psModoCaptura) OR
--						    (vModoCaptura = 'T' AND 1 = 1))
--						AND((vGiro = 'A' AND m.codgironeg = psGiro) OR
--						    (vGiro = 'T' AND 1 = 1))
--						AND ((vTarjetas = 'A' AND m.numtarjeta in(select tt_numtarjeta from tempTarjetas)) OR
--						     (vTarjetas = 'T' AND 1=1 ))
--						AND((vAprobadaRechazada = 'T' AND 1=1) OR
--						    (vAprobadaRechazada = 'A' AND m.codigoiso = '00') OR
--							(vAprobadaRechazada = 'R' AND m.codigoiso <> '00'))
--						ORDER BY m.FechaHoraInAuth DESC
--						
--						LET viContador = viContador + 1;
--						RETURN viContador, vsStatusTarjeta, vsNumCliente, vsSucursal, vsNumTarjeta, vsInfReceptor, vdtFechaHoraInAuth, vmMonto, vsIdTerminal, vsIdReceptor, vsMetodoCaptura, vsCodigoIso, vsMotivo, viNumeroLote, vsSecuencia, vsReferencia,
--                               vsNumCuenta,vsCiudadComercio,vsGiroComercio,vsIdRetailer,dtFechaOperacion,dtHoraOperacion WITH RESUME;
--					END FOREACH;
--				END IF;					   
	END IF;	
END;
END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: FRAUDES',
'Solicito: Luis Antonio Gómez Santiago',
'Descripcion: GENERA REPORTE DE PUNTOS DE COMPROMISO.',
'Fecha: 2010/11/26',
'Version: 20101126.1600',
'BD: INTERCARD',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 23/09/2019',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTAS DE PUNTOS COMPROMISOS',
'DESCRIPCION: Se modifica procedimiento por control de volumen en consulta',
'BD: INTERCARD';

CREATE PROCEDURE "informix".sp_tarj_det_vcas_mc()
RETURNING VARCHAR(10), VARCHAR(255)

DEFINE vfecha DATETIME YEAR TO FRACTION(5);
DEFINE vfechaTime DATETIME YEAR TO FRACTION(5);


DEFINE vstatus_proc 	CHAR(1);
DEFINE vcod_ret         VARCHAR(10);
DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(40);

DEFINE v_dia         	CHAR(2);
DEFINE v_mes         	CHAR(2);
DEFINE v_ano         	CHAR(4);
DEFINE v_hora 			DATETIME HOUR TO SECOND;
DEFINE v_hora2 			CHAR(8);
DEFINE v_sql         	CHAR(250);
DEFINE cEncabezado   	CHAR(250);

DEFINE cRuta 			CHAR(250);
DEFINE cRuta2 			CHAR(250);
DEFINE cNombreArchivo 	CHAR(250);
DEFINE cNombreArchivo1 	CHAR(250);
DEFINE cNombreArchivo2 	CHAR(250);

DEFINE var_action 		CHAR(6);
DEFINE var_numtarjeta   VARCHAR(16);
DEFINE var_telefono     CHAR(13);
DEFINE var_correo_elec 	CHAR(100);
DEFINE var_fecha        DATETIME YEAR to SECOND;

DEFINE iContador_pay    SMALLINT;
DEFINE vreg_ins INTEGER;

--MANEJO DEL ERROR.
ON EXCEPTION
SET sql_err, isam_err, error_info

UPDATE intercard:ctrl_info_ctes_vcas
SET status_proc = '0';

IF sql_err <> 0 THEN
	LET vcod_ret=sql_err;
	UPDATE intercard:ctrl_info_ctes_vcas
	SET(cod_err, descripcion_err) = (vcod_ret, isam_err||' ' ||error_info);
    RETURN vcod_ret, isam_err||' ' ||error_info;
END IF;
END EXCEPTION;

--set debug file to "/tmp/sp_tarj_det_vcas.out";
--TRACE ON;

LET vfecha = TODAY;
LET vfechaTime = TODAY;
LET vstatus_proc = '';

LET vcod_ret = '000';          
LET sql_err = 0;          
LET isam_err = 0;        
LET error_info = '';
LET iContador_pay = 0;

LET v_dia           = "";
LET v_mes           = "";
LET v_ano           = "";  
LET v_hora 			= CURRENT;
LET v_hora2 		= "";
LET v_sql           = "";

LET cEncabezado     = "";
LET cRuta 			= "/tmp/";
LET cRuta2 			= "/RESPALDOSNEW/VCAS_resultados/";
LET cNombreArchivo 	= "";
LET cNombreArchivo1 = "";
LET cNombreArchivo2 = "";

LET var_action 		= "";
LET var_numtarjeta  = "";
LET var_telefono    = "";
LET var_correo_elec = "";
LET var_fecha       = CURRENT;
LET vreg_ins 		= 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
 
SELECT status_proc
INTO vstatus_proc
FROM intercard:ctrl_info_ctes_vcas;

IF(vstatus_proc = '1') THEN
UPDATE intercard:ctrl_info_ctes_vcas
SET(cod_err, descripcion_err) = (vcod_ret, 'DESCARGA EN PROCESO');
RETURN vcod_ret, 'DESCARGA EN PROCESO';
END IF;
   
UPDATE intercard:ctrl_info_ctes_vcas SET status_proc = '1';  
 
SELECT '2019-12-06 00:00:00',  '2019-12-06 00:00:00'
INTO vfecha, vfechaTime
FROM intercard:ctrl_info_ctes_vcas;

-- ELIMINA REGISTROS DE TABLA DE RESULTADOS EN CASO DE QUE HAYA FALLADO EL SP Y HAYA GENERADO INFORMACION.
   
   TRUNCATE TABLE intercard:ctas_vcas;

  -- CREAR TEMPORALES PARA RESULTADO FINAL
    SELECT {+AVOID_FULL(intercard:info_tarjeta_pyt)} numtarjeta, fechaasignacion
    FROM intercard:info_tarjeta_pyt
    WHERE codstatustarjeta = 'ACT'
    AND fechaasignacion>=vfecha
    INTO temp tmptarj with no log;

    CREATE INDEX "informix".tmp_tartarj_vcas ON tmptarj(numtarjeta) ONLINE;

	SELECT bin
	FROM intercard:bines WHERE (bin in (510148, 554948 ,559471)) --marca  = 'VS' or 
	INTO temp BIN_VISA with no log;

    --TARJETAS DE CREDITO
    SELECT numcte,num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta)
    INTO temp tmpctestarj with no log;

    CREATE INDEX "informix".tmp_cte_pt ON tmpctestarj(numcte,num_tarjeta) ONLINE;

    -- CREATE INDEX "informix".tmp_tarj_pt ON tmpctestarj(num_tarjeta) ONLINE;

    --TARJETAS DE DEBITO
    INSERT INTO tmpctestarj
    SELECT numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta);

    -- TABLA TELEONOS TIPO 2
	SELECT {+AVOID_FULL(bdinteg:si_telefonos_actual)} telefono, numcte, status_tel, fecha_hora
    FROM bdinteg:si_telefonos_actual
    --WHERE (tipo_tel = 2 and  fecha_hora >=vfecha) or (numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1))
	WHERE ((fecha_hora >=vfechaTime) or (numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1))) and tipo_tel = 2
    INTO temp tmptelefono_tipo2 with no log;

    CREATE INDEX "informix".tmptelefono_tipo2_idx1  ON tmptelefono_tipo2(status_tel,fecha_hora) ONLINE;
    --CREATE INDEX "informix".tmptelefono_tipo2_idx2  ON tmptelefono_tipo2(numcte) ONLINE;


    --TEMPORAL DE TELEONOS
	SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE status_tel = 'A' and fecha_hora >= vfechaTime
    GROUP BY telefono, numcte
    UNION
    SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1) AND status_tel = 'A'
    GROUP BY telefono, numcte
    INTO temp tmptelefono with no log;

    CREATE INDEX "informix".tmptelefono_idx1 ON tmptelefono(numcte,telefono) ONLINE;
    --CREATE INDEX "informix".tmptelefono_idx2 ON tmptelefono(numcte) ONLINE;


    -- TABLA CORREOS  TIPO 1
	SELECT {+AVOID_FULL(bdinteg:si_correos)} tipo_correo, status_correo, secuencia, valido, numcte, correo_elec, fecha_hora
    FROM bdinteg:si_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1 AND C.fecha_hora >= vfechaTime
	INTO temp tmpsi_correos with no log;

	--CREATE INDEX "informix".tmpsi_correos_idx1 ON tmpsi_correos(tipo_correo,status_correo,fecha_hora, valido);
	CREATE INDEX "informix".tmpsi_correos_idx2 ON tmpsi_correos(numcte,tipo_correo,status_correo,valido);

	--TEMPORAL DE CORREOS

	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE numcte IN  (SELECT numcte FROM tmpctestarj WHERE 1=1)
	AND C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1
    GROUP BY correo_elec, numcte
	UNION
	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND fecha_hora >= vfechaTime AND C.valido = 1
	GROUP BY correo_elec, numcte
	INTO temp tmpcorreo with no log;

    CREATE INDEX "informix".tmp_correlec_vcas ON tmpcorreo(numcte,correo_elec) ONLINE;
    --CREATE INDEX "informix".tmp_numctecorr_vcas ON tmpcorreo(numcte) ONLINE;

   --TARJETAS DE CREDITO CTES
    SELECT numcte,num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono)
    INTO temp tmpctestarjfin with no log;

    CREATE INDEX "informix".tmp_cte_pts ON tmpctestarjfin(numcte,num_tarjeta) ONLINE;
	--CREATE INDEX "informix".tmp_tarj_pts ON tmpctestarjfin(num_tarjeta) ONLINE;

    --TARJETAS DE DEBITO CTES
    INSERT INTO tmpctestarjfin
    SELECT numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono);

	--CTES CON TARJETAS ACTUALIZADAS
    SELECT {+AVOID_FULL(intercard:info_tarjeta_pyt)} numtarjeta, A.fechaasignacion, B.numcte
    FROM intercard:info_tarjeta_pyt A, tmpctestarjfin B
    WHERE A.numtarjeta=B.num_tarjeta AND codstatustarjeta = 'ACT'
    GROUP BY A.numtarjeta, A.fechaasignacion, B.numcte
    INTO temp tmptarjeta with no log;

    CREATE INDEX "informix".tmp_numtarj_vcas ON tmptarjeta(numcte,numtarjeta) ONLINE;
    --CREATE INDEX "informix".tmp_numclient_vcas ON tmptarjeta(numcte) ONLINE;
    CREATE INDEX "informix".tmp_fechasig_vcas ON tmptarjeta(fechaasignacion) ONLINE;
   
-- INFORMACION QUE SE EJECUTARA CADA DETERMINADO TIEMPO.
BEGIN WORK;
FOREACH WITH HOLD
	SELECT CASE WHEN A.fechaasignacion >= vfecha THEN 'ADD' ELSE 'UPDATE' END AS action,
	A.numtarjeta,B.telefono AS telefono,C.correo_elec AS correo_elec,
	CURRENT AS fecha
    INTO var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha
    FROM tmptarjeta A
    LEFT JOIN tmptelefono B ON A.numcte=B.numcte
    LEFT JOIN tmpcorreo C ON A.numcte=C.numcte
    WHERE SUBSTR(A.numtarjeta,1,6) IN (SELECT bin FROM BIN_VISA )
	AND((B.telefono IS NOT NULL)OR(C.correo_elec IS NOT NULL))            
    GROUP BY A.numtarjeta, B.telefono, C.correo_elec,fecha,action

	LET iContador_pay = iContador_pay + 1;

	INSERT INTO "informix".ctas_vcas(action, numtarjeta, telefono, correo_elec, fecha)
    VALUES(var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha);
       
    IF iContador_pay = 1000 THEN
		COMMIT;
		LET iContador_pay = 0;
		BEGIN WORK;
	END IF;
END FOREACH;
COMMIT;

	-- DESCARGAR ARCHIVO.
	LET v_dia = LPAD(DAY(CURRENT),2,'0');  
	LET v_mes = LPAD(MONTH(CURRENT),2,'0');
	LET v_ano = year(CURRENT);
    LET v_hora2 = v_hora::CHAR(8);
	LET cNombreArchivo = TRIM(cRuta2)||'ISSUERNAME'||v_ano||v_mes||v_dia||SUBSTR(v_hora2,1,2)||SUBSTR(v_hora2,4,2)||SUBSTR(v_hora2,7,2)||'.csv';
	LET cNombreArchivo1 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux.csv';
    LET cNombreArchivo2 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux2.csv';
         
	-- DESCARGA DEL ARCHIVO .CSV.
	LET cEncabezado = 'echo "action,pan,mobilenumber,email,segmentationindicator," > /tmp/queryenc.sql';
    System cEncabezado;

	LET v_sql = 'echo "UNLOAD TO ' || TRIM (cNombreArchivo1) || ' DELIMITER '',''" > /tmp/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo "SELECT action,numtarjeta AS pan, ''+52''||RIGHT(LTRIM(RTRIM(telefono)),10) AS mobilenumber," >> /tmp/queryhist.sql ';
	System v_sql;

    LET v_sql = 'echo "LTRIM(RTRIM(correo_elec)) AS email, ''01'' AS segmentationindicator" >> /tmp/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo " from intercard:ctas_vcas  where numtarjeta <> ''''" >> /tmp/queryhist.sql';
	System v_sql;

	LET v_sql = "dbaccess intercard /tmp/queryhist.sql";
	System v_sql;

	LET v_sql="";

	--SE AÃÂADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAIDOS AL ARCHIVO AUXILIAR.
	LET v_sql = "sed 's/$//g' "|| TRIM(cRuta) || "queryenc.sql >> " || TRIM (cNombreArchivo2);
    SYSTEM TRIM(v_sql);

    LET v_sql="";

	LET v_sql = "sed 's/$//g' "|| TRIM (cNombreArchivo1) || " >> " || TRIM (cNombreArchivo2);
    SYSTEM TRIM(v_sql);

    --SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL.
    LET v_sql = "";
    LET v_sql = "sed -e 's/.$//' "|| TRIM(cNombreArchivo2) || " >> " || TRIM (cNombreArchivo);
    SYSTEM v_sql;

	--BORRADO DE SCRIPTS GENERADOS EN EL PROCESO.
    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cRuta) || "queryhist.sql";
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cRuta) || "queryenc.sql";
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cNombreArchivo1);
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cNombreArchivo2);
    SYSTEM TRIM(v_sql);

	-- DATOS PARA LA TABLA CONTROL.
	SELECT MAX(fecha::DATETIME YEAR TO SECOND + INTERVAL (01) SECOND(2) TO SECOND )
	INTO vfecha
	FROM intercard:ctas_vcas;

	IF  vfecha  IS NULL THEN
		LET vfecha = CURRENT;
	END IF

	-- CONTEO DE REGISTROS.
	SELECT COUNT(*)
	INTO vreg_ins
	FROM intercard:ctas_vcas;

	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS Y TEMPORALES.
    TRUNCATE TABLE intercard:ctas_vcas;

	DROP TABLE BIN_VISA;
	DROP TABLE tmpctestarj;
    DROP TABLE tmptelefono;
    DROP TABLE tmpcorreo;
	DROP TABLE tmptarjeta;
    DROP TABLE tmptarj;
    DROP TABLE tmpctestarjfin;

	-- ACTUALIZAR TABLA CONTROL.
	UPDATE intercard:ctrl_info_ctes_vcas
	SET ( fecha, status_proc,cod_err, descripcion_err, reg_insertados) = ( vfecha, '0', vcod_ret, 'DESCARGA EXITOSA', vreg_ins);

 
    RETURN vcod_ret, 'DESCARGA EXITOSA';
END PROCEDURE;