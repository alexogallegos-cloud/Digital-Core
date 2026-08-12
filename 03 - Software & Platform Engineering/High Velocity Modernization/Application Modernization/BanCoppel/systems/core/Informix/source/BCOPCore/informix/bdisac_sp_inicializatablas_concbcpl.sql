CREATE PROCEDURE "informix".sp_inicializatablas_concbcpl(pIdentificador CHAR(4),pFecha_hoy DATE)
RETURNING CHAR(5), CHAR(80);
    DEFINE iSqlErr, iIsamErr  INTEGER;
    DEFINE cCodRet            CHAR(5);
	DEFINE cMensaje			  CHAR(80);
    DEFINE cInfoErr           CHAR(100);
	DEFINE cTienda        	  CHAR(4);
	DEFINE cCaja          	  CHAR(3);
    DEFINE cFoliosucursal 	  CHAR(16);
	DEFINE cFechapago		  DATE;
    DEFINE cNumerotiket   	  VARCHAR(18);
	DEFINE cNumcategoria	  CHAR(2);
	DEFINE cNumconvenio		  CHAR(3);
	DEFINE dFecha_ini		  DATE;
	DEFINE vDias              INTEGER;
	DEFINE cMovimiento        CHAR(2);
	DEFINE cTipomovimiento    CHAR(2);
	
	LET cTienda        		= '';
	LET cCaja          		= '';
    LET cFoliosucursal 		= '';
	LET cFechapago          = DATE(1);
    LET cNumerotiket   		= '';
	LET cNumcategoria 		= '';
	LET cNumconvenio 		= '';
	LET cMovimiento         = '';
	LET cTipomovimiento     = '';
	LET dFecha_ini			= DATE(1);
    LET cCodRet             = '00000';
	LET cMensaje			= 'PROCESO EXITOSO';
	LET vDias  				= 0;

	--SET DEBUG FILE TO  '/tmp/adrian/sp_inicializatablas_concbcpl.out';
	--TRACE ON;
	
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR AL INTENTAR ENVIAR AL HISTORICO";
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_inicializatablas_concbcpl");
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		IF pIdentificador = 'CARG' THEN		
			TRUNCATE TABLE bdisac:"informix".sac_conc_archtemp1;
			TRUNCATE TABLE bdisac:"informix".sac_conc_archtemp2;
		END IF;	
		
		IF pIdentificador = 'HIST' THEN
		
			--Primero paso a la tabla old todo lo que ya fue conciliado
			INSERT INTO bdisac:"informix".sac_conciliacion_bcpl_cpl_old
			SELECT movimiento,tipomovimiento,importe,fechapago,tienda,numempleado,empresa,ciudad,descripcion,caja,foliosucursal,numerotiket,
				   contrato,campo1,campo2,campo3,campo4,campo5,campo6,campo7,campo8,campo9,campo10,
				   fecha_insert,st_conciliado,fecha_concil,nombre_archivo,TODAY as fechacarga
			FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
			WHERE  st_conciliado = 1;
			
			DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
			WHERE  st_conciliado = 1;
			
			--OBTENGO VALOR DE DIAS DE GRACIA
			SELECT valor
			INTO   vDias
			FROM   "informix".sac_param
			WHERE  empresa   = '001'
			AND    cod_param = '118';

			FOREACH
				SELECT a.numcategoria, a.numconvenio, b.movimiento, b.tipomovimiento
				INTO   cNumcategoria, cNumconvenio, cMovimiento, cTipomovimiento
				FROM   bdisac:"informix".sac_convenios as a, bdisac:"informix".sac_servicios_cpl as b
				WHERE  a.numcategoria = b.numcategoria
				AND    a.numconvenio  = b.numconvenio
				AND    b.conciliacion = '1'
				
				--SELECCIONA LA FECHA DEL ULTIMO ARCHIVO GENERADO
				SELECT fecha_ultimo_archivo
				INTO   dFecha_ini
				FROM   "informix".sac_controlarchivoscobranza
				WHERE  numcategoria = cNumcategoria
				AND    numconvenio  = cNumconvenio;
				
				FOREACH
					--Barro los registros que no han sido conciliados y que ya pasaron el periodo de Coppel
					SELECT foliosucursal, fechapago
					INTO   cFoliosucursal, cFechapago
					FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
					WHERE  st_conciliado  = 0
					AND    fechapago      < dFecha_ini - vDias
					AND    movimiento     = cMovimiento
					AND    tipomovimiento = cTipomovimiento
					
					INSERT INTO bdisac:"informix".sac_conciliacion_bcpl_cpl_old
					SELECT movimiento,tipomovimiento,importe,fechapago,tienda,numempleado,empresa,ciudad,descripcion,caja,foliosucursal,numerotiket,
						   contrato,campo1,campo2,campo3,campo4,campo5,campo6,campo7,campo8,campo9,campo10,
						   fecha_insert,st_conciliado,fecha_concil,nombre_archivo,TODAY as fechacarga
					FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl
					WHERE  foliosucursal = cFoliosucursal
					AND    fechapago     = cFechapago;
					
					DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
					WHERE  foliosucursal = cFoliosucursal
					AND    fechapago     = cFechapago;
					
				END FOREACH;
				
			END FOREACH;
			
			--Guardo toda la informaciÃ³n histÃ³rica de Cifras
			INSERT INTO bdisac:"informix".sac_conciliacion_cifras_old
			SELECT fechapago, tienda, importe, movimiento, tipomovimiento, numeromovs, empresa, fecha_concil, nombre_archivo, TODAY as fechacarga
			FROM   bdisac:"informix".sac_conciliacion_cifras;
			
			DELETE
			FROM   bdisac:"informix".sac_conciliacion_cifras
			WHERE  1 = 1;
			
			
			--IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			--	LET cCodRet = '00001';
			--	RETURN cCodRet;
			--ELSE 
				--TRUNCATE TABLE bdisac:"informix".sac_conciliacion_bcpl_cpl;			
			--END IF;
			
		END IF;

		IF pIdentificador = 'UPTD' THEN
			--set pdqpriority 0;
			--UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_conciliacion_bcpl_no_cpl;
		END IF;				
        
        RETURN cCodRet, cMensaje;
    END;
END PROCEDURE
;