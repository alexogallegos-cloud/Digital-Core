CREATE PROCEDURE  "informix".sp_verificafechas(pfecha_sucursal  date)

   RETURNING CHAR(5),
             DATE,
             CHAR (1);
--Definicion de variables
   DEFINE cod_ret           CHAR(5);
   DEFINE sql_err           INTEGER;
   DEFINE vfecha_central    DATE;
   DEFINE iDiferencia       SMALLINT; 

-- Inicializa variables

   LET cod_ret           = "000";
   LET vfecha_central    = "";
   
   BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret,vfecha_central,iDiferencia;
      END IF;
   END EXCEPTION;

-- Valida los parametros de entrada
      IF pfecha_sucursal is null THEN 
         LET cod_ret = "110";
         RETURN cod_ret,vfecha_central,iDiferencia;
      END IF

-- Valida la sucursal asignada,como el usuario del Pase Contable

   SELECT fecha_hoy 
   INTO vfecha_central
   FROM bdinteg:si_fechas; 

   IF vfecha_central >= pfecha_sucursal THEN
      LET iDiferencia = 0; --Sigue Ejecucion
   ELSE
      LET iDiferencia = 1;
   END IF;

  RETURN cod_ret,vfecha_central,iDiferencia;
END;
END PROCEDURE
DOCUMENT
    'DESCRIPCION: Realiza una consulta la tabla co_fechas para obtener la fecha hoy y compararla con la fecha hoy recibida en pfecha_sucursal, esto es para',
                 'determinar, sí las fechas son iguales, el pase contable debe realizarse, si existe diferencia este no debe permitir su ejecución.',
    'AUTOR: Cristian Valentina Aguilar',
    'FECHA: Julio 2009',
    'VERSION: 20090706',
    'BD: BDICONT';

CREATE PROCEDURE "informix".spconsultarautorizacionfecharetroactiva( p_sEmpresa CHAR (3), p_sClaveAutorizacion CHAR(6), p_dFechaCaptura DATE,
p_dFechaInicial DATE, p_dFechaFinal DATE, p_sUsuarioAutoriza CHAR (8), p_sUsuarioSolicita CHAR(8))

       RETURNING CHAR (5) AS codret, CHAR(8) AS empresa, DATE AS fecha_captura, DATE AS fecha_inicial, DATE AS fecha_final, CHAR(8) AS usuario_autoriza, 
				CHAR(8) AS usuario_solicita, CHAR(6) AS clave_autorizacion, CHAR(1) AS estatus_uso, MONEY(18,2) AS importe;

	
	DEFINE v_sEmpresa			CHAR(3);
	DEFINE v_dFechaCaptura 		DATE;
	DEFINE v_dFechaInicial 		DATE;
	DEFINE v_dFechaFinal		DATE;
	DEFINE v_sUsuarioAutoriza	CHAR(8);
	DEFINE v_sUsuarioSolicita  	CHAR(8);
	DEFINE v_sClaveAutorizacion	CHAR(6);
	DEFINE v_sEstatusUso		CHAR(1);
	DEFINE v_mImporte			MONEY(18,2);
	DEFINE v_sConfirma			CHAR(5);
	DEFINE iSqlErr	   			INTEGER;
	DEFINE v_sCodRet			CHAR (5);		

	LET v_sCodRet = '00000';
 
 	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,'','','','','','','','','';
			END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/tmp/spConsultarAutorizacionFechaRetroactiva.out";                                                                                               
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'') = '' THEN
			LET v_sCodRet ='00001';
			RETURN v_sCodRet,'','','', '','','','','','';
		END IF;
		
		IF NVL(p_sClaveAutorizacion,'') = '' THEN
			LET p_sClaveAutorizacion = NULL;			
		END IF;
		
		IF NVL(p_dFechaCaptura, '') = '' THEN
			LET p_dFechaCaptura = NULL;			
		END IF;
		
		IF NVL(p_dFechaInicial, '') = '' THEN
			LET p_dFechaInicial = NULL;			
		END IF;
		
		IF NVL(p_dFechaFinal, '') = '' THEN
			LET p_dFechaFinal = NULL;			
		END IF;
		
		IF NVL(p_sUsuarioAutoriza, '') = '' THEN
			LET p_sUsuarioAutoriza = NULL;
		END IF;
		
		IF NVL(p_sUsuarioSolicita, '') = '' THEN
			LET p_sUsuarioSolicita = NULL;
		END IF;
	
		--OBTIENE LOS DATOS DEL USUARIO.
		FOREACH
			SELECT empresa, fecha_captura, fecha_inicial, fecha_final, usuario_autoriza, usuario_solicita, 
			clave_autorizacion, estatus_uso, importe 
			INTO v_sEmpresa, v_dFechaCaptura, v_dFechaInicial, v_dFechaFinal, v_sUsuarioAutoriza, v_sUsuarioSolicita,
			v_sClaveAutorizacion, v_sEstatusUso, v_mImporte
			FROM bdicont:co_clv_retroact 
			WHERE fecha_captura = NVL(p_dFechaCaptura, fecha_captura)
		      AND fecha_final = NVL(p_dFechaFinal,fecha_final) 
		      AND fecha_inicial = NVL(p_dFechaInicial, fecha_inicial)
			  AND usuario_autoriza = NVL(p_sUsuarioAutoriza,usuario_autoriza) 
              AND usuario_solicita = NVL(p_sUsuarioSolicita, usuario_solicita) 
			  AND clave_autorizacion = NVL (p_sClaveAutorizacion, clave_autorizacion)

			RETURN v_sCodRet, v_sEmpresa, v_dFechaCaptura, v_dFechaInicial, v_dFechaFinal, v_sUsuarioAutoriza, v_sUsuarioSolicita,
			v_sClaveAutorizacion, v_sEstatusUso, v_mImporte WITH RESUME;
			
		END FOREACH;
		
	END
END PROCEDURE;