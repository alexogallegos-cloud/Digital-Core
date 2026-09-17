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