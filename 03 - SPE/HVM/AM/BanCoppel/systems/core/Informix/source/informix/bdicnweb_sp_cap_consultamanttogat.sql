CREATE PROCEDURE "informix".sp_cap_consultamanttogat(pUsuario CHAR(8), pIdFuncion CHAR(10), pBandera CHAR(1), pProducto CHAR(4))
		RETURNING CHAR(5) AS codret,
		INTEGER		 AS plazo_inicio,
		INTEGER      AS plazo_fin,
		DECIMAL(9,6) AS tasa,
		DECIMAL(9,6) AS gat_nomina,
		DECIMAL(9,6) AS gat_real,
		DATE         AS fecha_publicacion,
		CHAR (2)     AS periodo,
		MONEY (14,2) AS rango_min,
		MONEY (14,2) AS rango_max,
		CHAR(4) 	 AS num_producto,
		CHAR(30)	 AS desc_producto,
		INTEGER 	 AS ROWID; 

    
	--DEFINICIÃN DE VARIABLES
	DEFINE cCodRet 		     CHAR(5);
	DEFINE iSqlErr 		     INTEGER;
	DEFINE iPlazoInicio      INTEGER;
	DEFINE iPlazoFin 	     INTEGER;
	DEFINE dTasa 		     DECIMAL(9,6);
	DEFINE dGatNomina 	     DECIMAL(9,6);
	DEFINE dGatReal 	     DECIMAL(9,6);
	DEFINE dFechaPublicacion DATE;
	DEFINE iNoRegistros      INTEGER;
	DEFINE iRegistros        INTEGER;
	DEFINE iRecuperacion     INTEGER;
	DEFINE iRowID			 INTEGER;

	DEFINE iPeriodo			 CHAR(2);
	DEFINE iRangoMin		 MONEY (14,2) ;
	DEFINE iRangoMax		 MONEY (14,2) ;
	DEFINE cNumProducto      CHAR(4);
	DEFINE cProductoDesc 	 CHAR(30);

	LET cCodRet 		= '00000';
	LET iSqlErr 		= 0;
	LET iPlazoInicio 	=0;
	LET iPlazoFin 	 	=0;
	LET dTasa 		 	=0.00;
	LET dGatNomina 	 	=0.00;
	LET dGatReal 	 	=0.00;
	LET dFechaPublicacion = '';
	LET iNoRegistros	= 0;
	LET iRegistros 		= 0;
	LET iRecuperacion	= 0;
	LET iRowID	= 0;

	LET iPeriodo		=0;
	LET iRangoMin		=0;
	LET iRangoMax		=0;
	LET cNumProducto 	= '';
	LET cProductoDesc	= '';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END EXCEPTION;

		-- SET DEBUG FILE TO '/tmp/mfinis/sp_cap_consultamanttogat.out';
		-- TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' OR pProducto = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--pagare,
		IF pBandera = '1' THEN
			FOREACH
				SELECT plazo_inicio, plazo_fin, tasa, gat_nomina, gat_real, periodo, rowid
				INTO 	iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal,iPeriodo, iRowID
				FROM bdinvers:"informix".sv_gat
				ORDER BY 1 ASC

			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
			END FOREACH;
		
		--1100 inversiï¿½n creciente
		ELIF pBandera = '2'  THEN

			FOREACH
				SELECT gat.fecha_publicacion, tipo.num_producto, tipo.desc_producto,  gat.tasa, gat.gat_nominal, gat.gat_real, gat.periodo, gat.ROWID 
				INTO dFechaPublicacion, cNumProducto, cProductoDesc, dTasa, dGatNomina, dGatReal, iPeriodo , iRowID  
				FROM bdicheq:"informix".sc_gat gat INNER JOIN bdicnweb:"informix".sw_cap_tipoproductogat tipo
				ON gat.producto = tipo.num_producto
				WHERE gat.producto = pProducto
				ORDER BY 1, 8 ASC


			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
			END FOREACH;

	
		ELIF pBandera = '3' THEN
			IF pProducto = "2500" OR pProducto = "2000" OR pProducto = "1900" OR pProducto = "1400" OR pProducto = "2400" OR pProducto = "1800" THEN  
				FOREACH
					SELECT gat.fecha_publicacion, gat.producto, gat.rango_min , gat.rango_max  ,gat.tasa, gat.gat_nominal, gat.gat_real, gat.periodo, gat.ROWID 
					INTO dFechaPublicacion, cNumProducto, iRangoMin, iRangoMax, dTasa, dGatNomina, dGatReal, iPeriodo, iRowID 
					FROM bdicheq:"informix".sc_gat gat
					WHERE gat.producto = pProducto
					ORDER BY 1, 8 ASC

					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
				END FOREACH;
			END IF;

		ELIF pBandera = '4' THEN
			IF pProducto = "2900" OR pProducto = "1300" THEN  
				FOREACH
					SELECT gat.fecha_publicacion, gat.producto, gat.tasa, gat.gat_nominal, gat.gat_real, gat.periodo, gat.ROWID 
					INTO dFechaPublicacion, cNumProducto, dTasa, dGatNomina, dGatReal, iPeriodo, iRowID
					FROM bdicheq:"informix".sc_gat gat
					WHERE gat.producto = pProducto
					ORDER BY 1, 7 ASC 

					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID WITH RESUME;
				END FOREACH;
			END IF;
		END IF;

		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iPlazoInicio, iPlazoFin, dTasa, dGatNomina, dGatReal, dFechaPublicacion, iPeriodo, iRangoMin, iRangoMax, cNumProducto, cProductoDesc, iRowID;
		END IF;
	END
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angï¿½lica Hï¿½rnandez Pï¿½rez',
'FECHA: 09/08/2016',
'MODULO: Dï¿½BITO',
'FUNCIONALIDAD: MANTENIMIENTOS GAT',
'DESCRIPCION: SPL que realiza la consulta los registros para producto pagare, inversiï¿½n creciente y cuenta ejecutiva jï¿½venes',
'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 30/06/2023',
'DESCRIPCION: Se agregaron nuevas banderas para mostrar los registros de Cuenta Efectiva Digital (2000), Cuenta Efectiva Cheques (1900), Cuenta BÃ¡sica general (1400), Cuenta Clic (2900), Cuenta Platino (2400), Cuenta Efectiva Plus (1800) y Cuenta Efectiva GC (1300)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_deb_calculagat(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5) 		AS codret;

/*=====================================
|     DEFINICIÃN DE VARIABLES         |
=====================================*/
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRet 			CHAR(5);

/*======================================
|     INICIALIZACIÃN DE VARIABLES      |
======================================*/
	LET iSqlErr = 0;
	LET cCodRet = "00000";

    BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_deb_calculagat.out';
		--TRACE ON;

        IF  pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet;
			END IF;

        EXECUTE PROCEDURE bdicheq:"informix".sp_calculagat() INTO cCodRet;
        

        IF cCodRet = '-1202' THEN
            LET cCodRet = '00454'; --Probable divisiÃ³n entre 0 en periodos
        END IF;

        RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 30/06/2023',
'MODULO: DÃBITO',
'FUNCIONALIDAD: MANTENIMIENTOS GAT',
'DESCRIPCION: SPL que llama al SP calculagat para calcular automaticamente la GAT para las cuentas de captacion',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_insermedianainflacion(pUsuario CHAR(8), 
													pIdFuncion CHAR(10), 
													pIdConsulta INTEGER, 
													pMedInflacion DECIMAL(9,6), 
													pFechaPublicacion DATETIME YEAR TO FRACTION(3))

RETURNING   CHAR(5)    					 AS codret,
  			DECIMAL(9,6) 				 AS med_inflacion,
    		DATETIME YEAR TO FRACTION(3) AS fecha_publicacion;


/*=====================================
|     DEFINICIÃN DE VARIABLES         |
=====================================*/
	DEFINE iSqlErr 			INTEGER;
	DEFINE cCodRet 			CHAR(5);
	DEFINE dMedianInflacion DECIMAL(9,6);
	DEFINE dfechaPubli 		DATETIME YEAR TO FRACTION(3);
	DEFINE iregistros 		INTEGER;


/*======================================
|     INICIALIZACIÃN DE VARIABLES      |
======================================*/
	LET iSqlErr = 0;
	LET cCodRet = "00000";

	LET dMedianInflacion = 0.0;
	LET dfechaPubli = "";
	LET iregistros = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_insermedianainflacion.out';
		--TRACE ON;

		IF  pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END IF;

		IF pIdConsulta = '2' THEN
			IF pMedInflacion IS NULL OR pFechaPublicacion IS NULL OR pMedInflacion = '' OR pFechaPublicacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,dMedianInflacion, dfechaPubli;
			END IF;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
				RETURN cCodRet,dMedianInflacion, dfechaPubli;
			END IF;

		/* CONSULTAMOS LA TODAS LAS MEDIANAS DE INFLACIÃN */
		IF pIdConsulta = '1' THEN 
			FOREACH
				SELECT med_inflacion, fecha_publicacion
				INTO dMedianInflacion, dfechaPubli
				FROM bdicheq:sc_medianainflacion 
				ORDER BY 2 DESC
				
				LET iregistros = iregistros + 1;
				RETURN cCodRet,dMedianInflacion, dfechaPubli WITH RESUME;
			END FOREACH;

		/* INSERCIÃN DE UNA NUEVA MEDIANA DE INFLACIÃN*/
		ELIF pIdConsulta = '2' THEN 
			INSERT INTO bdicheq:sc_medianainflacion(med_inflacion, fecha_publicacion) VALUES (pMedInflacion, pFechaPublicacion);
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END IF;	

		IF iregistros = 0 THEN
			LET cCodRet = "00017";
			RETURN cCodRet,dMedianInflacion, dfechaPubli;
		END IF;
	END;
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 27/06/2023',
'MODULO: DÃBITO',
'FUNCIONALIDAD: MEDIANA INFLACIÃN ',
'DESCRIPCION: SP ENCARGADO DE REALIZAR CONSULTAR TODAS LAS MEDIANAS DE INFLACIÃN EXISTENTES EN LA TABLA bdicheq:sc_medianainflacion (IdConsulta = 1) Ã REALIZAR LA INSERCIÃN DE UNA NUEVA MEDIANA DE INFLACIÃN (IdConsulta = 2)',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_grabarcambiostatusolicitudmc(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumSolicitud1 CHAR(20), pNumSolicitud2 CHAR(20), pNumCliente CHAR(20), pEjecutivoAnaliza CHAR(10), pEjecutivoAutoriza CHAR(10), pStatusInicial CHAR(2), pStatusFinal CHAR(2), pMontoAnterior  DECIMAL(18,2), pMontoNuevo DECIMAL(18,2), pCausa CHAR(3), pComentario CHAR(500), pTipoMovto CHAR(1), pTipoBusqueda CHAR(1), pBanderaMotor CHAR(1))

        RETURNING CHAR(5) AS codret, CHAR(80) AS DESCRIPCION, CHAR(1) AS BANDERAMOTORMC;

        DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
        DEFINE iSqlErr INTEGER;
        DEFINE cMensaje CHAR(80);
        DEFINE cEmpresa CHAR(3);
	DEFINE cBanderaMotorMC CHAR(1);
        
        LET cCodRet = '00000';
        LET cCodRetSp = '';
        LET iSqlErr = 0;
        LET cMensaje = '';
        LET cEmpresa = '001';
	LET cBanderaMotorMC = '0';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cMensaje, cBanderaMotorMC;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_grabarcambiostatusolicitudmc.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pNumSolicitud1 = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet,  cMensaje, cBanderaMotorMC;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet,  cMensaje, cBanderaMotorMC;
                END IF;
                
                EXECUTE PROCEDURE bdisolic:'informix'.sp_mc_grabacambiostatus (cEmpresa, pNumSolicitud1, pNumSolicitud2, pNumCliente, pEjecutivoAnaliza, pEjecutivoAutoriza, 
                            pStatusInicial, pStatusFinal, pMontoAnterior, pMontoNuevo, pCausa, UPPER(pComentario), pTipoMovto, pTipoBusqueda, pBanderaMotor) INTO cCodRetSp, cMensaje, cBanderaMotorMC;

                IF cCodRetSp::INTEGER < 0 THEN
                        RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃÂON DEL SP bdisolic:sp_mc_grabacambiostatus';
                ELIF cCodRetSp::INTEGER = 1 THEN
                        LET cCodRet = '00003';
                ELIF cCodRetSp::INTEGER = 2 THEN -- OCURRIO UN ERROR AL REALIZAR LA ACTUALIZACION DE LA SOLICITUD.
                        LET cCodRet = '00219';
                ELIF cCodRetSp::INTEGER = 3 THEN -- ERROR AL PROCESAR LA SOLICITUD
                        LET cCodRet = '00236';
                END IF;
                
                RETURN cCodRet, cMensaje, cBanderaMotorMC;
        
        END;
                                                
END PROCEDURE

;