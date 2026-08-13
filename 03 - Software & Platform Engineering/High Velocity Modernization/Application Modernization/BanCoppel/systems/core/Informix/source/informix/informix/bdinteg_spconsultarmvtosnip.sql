CREATE PROCEDURE "informix".spconsultarmvtosnip( psEmpresa CHAR(3), psNumTarjeta CHAR(16) )

	RETURNING CHAR(5) AS CodigoRetorno, 
		CHAR(10) AS Fecha, CHAR(9) AS Hora, CHAR(4) AS Sucursal, CHAR(8) AS Empleado, CHAR(45) AS Nombre;

	DEFINE iSqlErr          	INTEGER;
	DEFINE sCodigoRetorno        CHAR(5);
	
	DEFINE sFecha		CHAR(10);
	DEFINE sHora		CHAR(9);
	DEFINE sSucursal	CHAR(4);
	DEFINE sEmpleado	CHAR(8);
	DEFINE sNombre		CHAR(45);
	
	--SET DEBUG FILE TO  "/respaldosbd/ulises/spConsultarMvtosNIP.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			
			IF iSqlErr <> 0 THEN
			
				LET sCodigoRetorno = iSqlErr;
				
				RETURN sCodigoRetorno, NULL, NULL, NULL, NULL, NULL;
				
			END IF;
		END EXCEPTION;

		--VALIDA PARÁMETROS DE ENTRADA.
		IF ( NVL( psEmpresa, '' ) = '' AND NVL( psNumTarjeta, '' ) ) THEN

			LET sCodigoRetorno = '00001';
			
			RETURN sCodigoRetorno, NULL, NULL, NULL, NULL, NULL;

		END IF;

		LET sFecha 		= '';
		LET sHora 		= '';
		LET sSucursal	= '';
		LET sEmpleado  	= '';
		LET sNombre   	= '';

		FOREACH
			SELECT TO_CHAR( a.fechahorainauth, '%d/%m/%Y' ), a.fechahorainauth::DATETIME HOUR TO SECOND, SUBSTR( a.idterminal, 1, 4 ), 
					SUBSTR( a.idterminal, 5, 8 ), b.nombre
				INTO sFecha, sHora, sSucursal, sEmpleado, sNombre
			FROM intercard:movimientohistorico a
				LEFT OUTER JOIN bdinteg:si_ejecut b ON ( SUBSTR( a.idterminal, 5, 8 ) = b.ejecutivo )
			WHERE a.codtran = 95 AND empresa = psEmpresa AND a.numtarjeta = psNumTarjeta

			LET sCodigoRetorno = '00000';			

			RETURN sCodigoRetorno, sFecha, sHora, sSucursal, sEmpleado, sNombre WITH RESUME;

		END FOREACH;

		FOREACH
			SELECT TO_CHAR( a.fechahorainauth, '%d/%m/%Y' ), a.fechahorainauth::DATETIME HOUR TO SECOND, SUBSTR( a.idterminal, 1, 4 ), SUBSTR( a.idterminal, 5, 8 ), b.nombre
				INTO sFecha, sHora, sSucursal, sEmpleado, sNombre
			FROM intercard:movimiento a
				LEFT OUTER JOIN bdinteg:si_ejecut b ON ( SUBSTR( a.idterminal, 5, 8 ) = b.ejecutivo )
			WHERE a.codtran = 95 AND empresa = psEmpresa AND a.numtarjeta = psNumTarjeta

			LET sCodigoRetorno = '00000';			

			RETURN sCodigoRetorno, sFecha, sHora, sSucursal, sEmpleado, sNombre WITH RESUME;

		END FOREACH;
		
	END
END PROCEDURE
DOCUMENT
'CREADO:		Ulises Rodríguez Márquez.',
'FECHA:			05 de Mayo de 2010.',
'DESCRIPCIÓN:	Consulta los movimientos del mantenimiento de NIP de una tarjeta.',
'RETORNO:		00000 Datos obtenidos satisfactoriamente',
'				00001 Parametros insuficientes.',

'MODIFICÓ: 		Ulises Rodríguez Márquez',
'FECHA: 		06/01/2011',
'MODIFICACIÓN: 	Se agrega la búsqueda sobre la intercard:movimiento.',

'MODIFICÓ: 		Bernardo Beltrán Herrera',
'FECHA: 		24/10/2012',
'MODIFICACIÓN: 	Se agrega la búsqueda sobre la intercard:movimientohistorico_old.',

'MODIFICÓ: 		Bernardo Beltrán Herrera',
'FECHA: 		23/01/2014',
'MODIFICACIÓN: 	Se elimina referencia a la tabla intercard:movimientohistorico_old.'

;

CREATE PROCEDURE "informix".sp_actualiza_gerentes( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER; 
    
    DEFINE vcCodRet1    CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE viTrxAbierta SMALLINT;
    DEFINE viContador   INTEGER;
    DEFINE vdFechaHoy   DATE;
    DEFINE vcSucAnt     CHAR(4);
    DEFINE vcSucursal   CHAR(4);
    DEFINE vcEjecutivo  CHAR(8);
    DEFINE vcNombreGte  CHAR(45);
    DEFINE vdFechaIns   DATE;
    
    LET vcCodRet1    = '000';
    LET vcCodRet2    = '000';
    LET vcCodRet3    = 'PROCESO REALIZADO CORRECTAMENTE';
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET viTrxAbierta = 0;
    LET viContador   = 0;    
    LET vdFechaHoy   = '';
    LET vcSucAnt     = '';
    LET vcSucursal   = '';
    LET vcEjecutivo  = '';
    LET vcNombreGte  = '';
    LET vdFechaIns   = '';
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/tmp/sp_actualiza_gerentes.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet1 = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            IF viTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_actualiza_gerentes.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vdFechaHoy
      FROM si_fechas
     WHERE empresa = pEmpresa;
     
    LET vcSucAnt = '0000';
    
    FOREACH WITH HOLD
        SELECT sucursal, ejecutivo, nombre, fecha_insert
          INTO vcSucursal, vcEjecutivo, vcNombreGte, vdFechaIns
          FROM si_ejecut 
         WHERE sucursal IN ( SELECT sucursal FROM si_sucursales WHERE tpo_sucursal = 'S' )
           AND ejecutivo LIKE '9%'
           AND password NOT IN('BAJA', 'baja')
           AND vigencia > vdFechaHoy
           AND puesto = '001'
         ORDER BY sucursal, fecha_insert
           
        BEGIN WORK;
        LET viTrxAbierta = 1;
        
        IF vcSucursal <> vcSucAnt THEN
            UPDATE si_sucursales
               SET gerente = vcNombreGte
             WHERE sucursal = vcSucursal;
        END IF;
        
        LET vcSucAnt = vcSucursal;
        
        LET viContador = viContador + 1;        
        
        COMMIT WORK;
        LET viTrxAbierta = 0;
        
        LET vcSucursal  = '';
        LET vcEjecutivo = '';
        LET vcNombreGte = '';
        LET vdFechaIns  = '';
    END FOREACH;
    
    END;
    
    RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador;
    
END PROCEDURE;