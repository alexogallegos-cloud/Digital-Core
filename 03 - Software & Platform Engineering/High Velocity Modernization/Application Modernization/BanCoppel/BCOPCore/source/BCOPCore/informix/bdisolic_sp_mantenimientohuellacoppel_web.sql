CREATE PROCEDURE "informix".sp_mantenimientohuellacoppel_web(cEmpresa CHAR(3), cNumCte CHAR(20), cTipo CHAR(1), iRegistros SMALLINT)
RETURNING
CHAR(5),   ---cod_ret
INTEGER,   ---Seguridad
SMALLINT,  ---Secuencia
CHAR(1),   ---Estado
CHAR(942), ---DMapa
CHAR(942), ---IMapa
CHAR(8),   ---Usuario
CHAR(4),   ---Sucursal
CHAR(8),   ---FechaA_lta
CHAR(8),   ---Usuario_Camb
CHAR(8),   ---Fecha_Camb
INTEGER,   ---# Cliente Coppel
CHAR(1),   ---FlagAdicional
CHAR(1),   ---Sexo
INTEGER;   ---TipoSensor

    DEFINE cCodRet              CHAR(5);
    DEFINE iSqlErr              INTEGER;
	DEFINE iSeguridad			INTEGER;
	DEFINE iSecuencia 			SMALLINT;
	DEFINE cEstado  			CHAR(1);
	DEFINE cDmapa 				CHAR(942);
	DEFINE cImapa 				CHAR(942);
	DEFINE cUsuario 			CHAR(8);
	DEFINE cSucursal 			CHAR(4);
	DEFINE cFechaAlta   		CHAR(8);
	DEFINE cUsuarioCamb 		CHAR(8);
	DEFINE cFechaCamb   		CHAR(8);
	DEFINE iClienteCoppel   	INTEGER;
	DEFINE cFlagAdicional 		CHAR(1);
	DEFINE cSexo 				CHAR(1);
	DEFINE iTipoSensor 	    	INTEGER;
	DEFINE iCiclo               SMALLINT;
	
	SET LOCK MODE TO WAIT 3;
		
BEGIN
	ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
        END IF;
        RETURN cCodRet, iSeguridad, iSecuencia, cEstado, cDmapa, cImapa, cUsuario, cSucursal, cFechaAlta, cUsuarioCamb, cFechaCamb, iClienteCoppel, cFlagAdicional, cSexo, iTipoSensor; 
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_MantenimientoHuellaCoppel.out";
    --TRACE ON;

	LET cCodRet         = '00000';
	LET iSeguridad	    = 0;
	LET iSecuencia 		= 0;
	LET cEstado 		= "";
	LET cDmapa 			= "";
	LET cImapa 			= "";
	LET cUsuario 		= "";
	LET cSucursal 		= "";
	LET cFechaAlta 		= "";
	LET cUsuarioCamb 	= "INFORMIX";
	LET cFechaCamb 		= "19000101";
	LET iClienteCoppel 	= 0;
	LET cFlagAdicional 	= "";
	LET cSexo 			= "";
	LET iTipoSensor 	= 0;
	LET iCiclo          = 0;

	IF (cEmpresa IS NULL OR cEmpresa = '')  OR  (cNumCte IS NULL OR cNumCte = '') OR  (cTipo IS NULL OR cTipo = '') THEN 
		LET cCodRet = '00001';
	ELSE
		IF cTipo = '0' THEN
			IF EXISTS(SELECT 1 FROM bdinteg:"informix".si_adiccoppel WHERE numcte = cNumCte AND secuencia = '1') THEN
				SELECT a.numctecoppel, b.sexo, c.secuencia, c.estado, c.dmapa, c.imapa, c.usuario, c.sucursal, 
						YEAR(c.fecha_alta) || LPAD(MONTH(c.fecha_alta),2,'0') || LPAD(DAY(c.fecha_alta),2,'0') AS fecha_alta,
						c.usuario_camb, YEAR(c.fecha_camb) || LPAD(MONTH(c.fecha_camb),2,'0') || LPAD(DAY(c.fecha_camb),2,'0') AS fecha_camb, 
						2 AS tipo_sensor
				INTO iClienteCoppel, cSexo, iSecuencia, cEstado, cDmapa, cImapa, cUsuario, cSucursal,
	                 cFechaAlta, cUsuarioCamb, cFechaCamb, iTipoSensor		
				FROM bdinteg:"informix".si_adiccoppel a, bdinteg:"informix".si_ctepf b, bdinteg:"informix".si_cte_huella c
					WHERE  a.empresa = cEmpresa 
					AND a.numcte = cNumCte
					AND a.secuencia = '1'
					AND a.numcte = b.numcte
					AND a.numcte = c.numcte
					AND c.estado = 'A';
					
					LET cFlagAdicional      = cTipo;
					LET iSeguridad			= NVL(iSeguridad,0);
					LET iSecuencia 			= NVL(iSecuencia,0);
					LET cEstado 			= NVL(cEstado,"");
					LET cDmapa 				= NVL(cDmapa,"");
					LET cImapa 			    = NVL(cImapa,"");
					LET cUsuario 			= NVL(cUsuario,"informix");
					LET cSucursal 			= NVL(cSucursal,"");
					LET cFechaAlta 		    = NVL(cFechaAlta,"19000101");
					LET cUsuarioCamb 		= NVL(cUsuarioCamb,"informix");
					LET cFechaCamb 		    = NVL(cFechaCamb,"19000101");
					LET iClienteCoppel 	    = NVL(iClienteCoppel,0);
					LET cFlagAdicional   	= NVL(cFlagAdicional,"");
					LET cSexo 				= NVL(cSexo,"");
					LET iTipoSensor 		= NVL(iTipoSensor,0);

					RETURN cCodRet, iSeguridad, iSecuencia, cEstado, cDmapa, cImapa, cUsuario, cSucursal, cFechaAlta, cUsuarioCamb, cFechaCamb, iClienteCoppel, cFlagAdicional, cSexo, iTipoSensor; 
			ELSE
				LET cCodRet = '00002';
			END IF;
		ELIF cTipo = '1' THEN
			IF EXISTS(SELECT 1 FROM bdinteg:"informix".si_adiccoppel WHERE numcte = cNumCte AND secuencia <> '1') THEN
				FOREACH
					SELECT a.numctecoppel, b.sexo, c.secuencia, c.estado, c.dmapa, c.imapa, c.usuario, c.sucursal, 
						YEAR(c.fecha_alta) || LPAD(MONTH(c.fecha_alta),2,'0') || LPAD(DAY(c.fecha_alta),2,'0') AS fecha_alta,
						c.usuario_camb, YEAR(c.fecha_camb) || LPAD(MONTH(c.fecha_camb),2,'0') || LPAD(DAY(c.fecha_camb),2,'0') AS fecha_camb, 
						2 AS tipo_sensor
					INTO iClienteCoppel, cSexo, iSecuencia, cEstado, cDmapa, cImapa, cUsuario, cSucursal,
						cFechaAlta, cUsuarioCamb, cFechaCamb, iTipoSensor
					FROM bdinteg:"informix".si_adiccoppel a, bdinteg:"informix".si_ctepf b, bdinteg:"informix".si_cte_huella c
						WHERE  a.empresa = cEmpresa 
						AND a.numcte = cNumCte
						AND a.secuencia <> '1'
						AND a.numcte = b.numcte
						AND a.numcte = c.numcte
						AND c.estado = 'A'
						
						LET iCiclo = iCiclo + 1;
						
						IF iCiclo <= iRegistros THEN
							CONTINUE FOREACH;
						END IF;
						
						LET cFlagAdicional      = cTipo;
						LET iSeguridad			= NVL(iSeguridad,0);
						LET iSecuencia 			= NVL(iSecuencia,0);
						LET cEstado 			= NVL(cEstado,"");
						LET cDmapa 				= NVL(cDmapa,"");
						LET cImapa 			    = NVL(cImapa,"");
						LET cUsuario 			= NVL(cUsuario,"informix");
						LET cSucursal 			= NVL(cSucursal,"");
						LET cFechaAlta 		    = NVL(cFechaAlta,"19000101");
						LET cUsuarioCamb 		= NVL(cUsuarioCamb,"informix");
						LET cFechaCamb 		    = NVL(cFechaCamb,"19000101");
						LET iClienteCoppel 	    = NVL(iClienteCoppel,0);
						LET cFlagAdicional   	= NVL(cFlagAdicional,"");
						LET cSexo 				= NVL(cSexo,"");
						LET iTipoSensor 		= NVL(iTipoSensor,0);
						
						RETURN cCodRet, iSeguridad, iSecuencia, cEstado, cDmapa, cImapa, cUsuario, cSucursal, cFechaAlta, cUsuarioCamb, cFechaCamb, iClienteCoppel, cFlagAdicional, cSexo, iTipoSensor WITH RESUME; 
						
				END FOREACH;
			ELSE
				LET cCodRet = '00003';
			END IF;
		ELSE
			LET cCodRet = '00004';
		END IF;
	END IF;
	
	IF 	cCodRet <> '00000' THEN
		RETURN cCodRet, iSeguridad, iSecuencia, cEstado, cDmapa, cImapa, cUsuario, cSucursal, cFechaAlta, cUsuarioCamb, cFechaCamb, iClienteCoppel, cFlagAdicional, cSexo, iTipoSensor; 
	END IF;
			
END;
--##############################################################################
--## Procedimiento   : sp_AltaClienteHuellaAdicional
--## Base de Datos   : bdinteg
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Febrero de 2009
--##Descripcion : 
--##############################################################################
END PROCEDURE;