CREATE PROCEDURE "informix".sp_cancela_celular_verif_ctes()
				RETURNING CHAR(5)     AS Cod_Retorno;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;	
DEFINE cNumCte 			CHAR(20);	
DEFINE iCont			SMALLINT;
DEFINE cTelefono		char(13);
DEFINE iSecuencia 		SMALLINT;
DEFINE iExisteTelAct	SMALLINT;
DEFINE iDuplicado		SMALLINT;
DEFINE iTipoTelCel		SMALLINT;
DEFINE cEstTelActivo	char(1);
DEFINE cTelVerif		char(1);
DEFINE iMaxCommit		INTEGER;
DEFINE cEstTelCancel	char(1);
DEFINE iExisteCuenta	SMALLINT;



--INICIALIZA VARIABLES
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	
LET cNumCte 			= '';	
LET iCont 				= 0;
LET cTelefono			= '';
LET iSecuencia			= 0;
LET iExisteTelAct		= 0;
LET iDuplicado	 		= 0;
LET iTipoTelCel			= 2;
LET cEstTelActivo		= 'A';
LET cTelVerif			= 'V';
LET iMaxCommit			= 5000;
LET cEstTelCancel		= 'C';
LET iExisteCuenta		= 0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_cancela_celular_verif_ctes.out";
	--SET DEBUG FILE TO "/ifxsif01/jagl/bdinteg/sp_cancela_celular_verif_ctes.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN WORK;
	FOREACH WITH HOLD
		SELECT
		{+AVOID_FULL("informix".si_telefonos)}
		telefono, tipo_tel, status_tel, verificado, COUNT(*)
		INTO cTelefono, iTipoTelCel, cEstTelActivo, cTelVerif, iDuplicado
		FROM bdinteg:"informix".si_telefonos tel
		WHERE
		tel.tipo_tel=iTipoTelCel
		AND tel.status_tel=cEstTelActivo
		AND tel.verificado = cTelVerif
		group by telefono, tipo_tel, status_tel, verificado
		having count(*) > 1
		
		LET iDuplicado = iDuplicado -1;
		
		--Cancela los registros duplicados, dejando solamente activo el registro mas actualizado
		FOREACH WITH HOLD
			SELECT 
			{+AVOID_FULL("informix".si_telefonos)}
			FIRST iDuplicado tel.numcte, tel.secuencia
			INTO cNumCte, iSecuencia
			FROM "informix".si_telefonos tel
			WHERE 
			tel.telefono = cTelefono
			AND tel.tipo_tel = iTipoTelCel
			AND tel.status_tel = cEstTelActivo
			AND tel.verificado = cTelVerif
			ORDER BY tel.fecha_hora ASC
			
			--Se valida que el registro no este ligado a una cuenta, en caso de que sea afirmativo, se descarta su cancelación de dicho reistro
			SELECT 
			{+AVOID_FULL(bdicheq:"informix".sc_cuenta_telefono)}
			COUNT(*)
			INTO iExisteCuenta
			FROM bdicheq:sc_cuenta_telefono
			WHERE num_cte = cNumCte
			AND telefono = cTelefono
			;
			
			IF iExisteCuenta > 0 THEN
				CONTINUE FOREACH;
			END IF;
			
			SELECT 
			{+AVOID_FULL(bdicheq:"informix".sc_cuenta_telefono_hist)}
			COUNT(*)
			INTO iExisteCuenta
			FROM bdicheq:sc_cuenta_telefono_hist
			WHERE num_cte = cNumCte
			AND telefono = cTelefono
			;
			
			IF iExisteCuenta > 0 THEN
				CONTINUE FOREACH;
			END IF;
			
			--Se consulta el teléfono actual del cliente para eliminar dicho registro
			SELECT 
			{+AVOID_FULL ("informix".si_telefonos_actual)}
			count(*)
			INTO iExisteTelAct
			FROM "informix".si_telefonos_actual
			WHERE 
			numcte = cNumCte
			AND tipo_tel = iTipoTelCel
			AND telefono = cTelefono
			AND secuencia = iSecuencia
			;
			
			--Se elimina el celular de la tabla si_telefonos_actual
			IF iExisteTelAct > 0 THEN
				DELETE "informix".si_telefonos_actual
				WHERE 
				numcte = cNumCte
				AND tipo_tel = iTipoTelCel
				AND telefono = cTelefono
				AND secuencia = iSecuencia
				;
				LET iCont=iCont+1;
			END IF;
			
			--Se actualiza el estatus del celular como cancelado en la tabla si_telefonos
			UPDATE "informix".si_telefonos
			SET status_tel = cEstTelCancel
			WHERE 
			numcte = cNumCte
			AND tipo_tel = iTipoTelCel
			AND telefono = cTelefono
			AND secuencia = iSecuencia
			;
			
			--Se registra el registro cancelado en la bitacora de teléfonos depurados
			INSERT INTO "informix".si_bit_telefonos_verif_depurados (numcte, telefono, tipo_tel, secuencia, fecha_insert) 
			VALUES (cNumCte, cTelefono, iTipoTelCel, iSecuencia, TODAY);

			LET iCont=iCont+2;
			
		END FOREACH;	
		
		IF iCont >= iMaxCommit THEN
			LET iCont = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;
	END FOREACH;	
	--Finaliza foreach principal
	COMMIT WORK;
	
	RETURN cCodRet;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA 07/01/2020',
'MODULO: Integral',
'BD: bdinteg',
'FUNCIONALIDAD: Cancelación de teléfonos celulares duplicados y verificados de clientes',
'DESCRIPCION: SPL encargado de cancelar los teléfonos celulares duplicdos, activos y verificados de los clientes'
;

CREATE PROCEDURE "informix".sp_depura_celular_prospectos()
				RETURNING CHAR(5)     AS Cod_Retorno;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;	
DEFINE cNumCte 			CHAR(20);	
DEFINE iCont			SMALLINT;
DEFINE cTelefono		char(13);
DEFINE iSecuencia 		SMALLINT;
DEFINE iExisteTelAct	SMALLINT;
DEFINE iTipoTelCel		SMALLINT;
DEFINE cEstTelActivo	char(1);
DEFINE cEstTelCancel	char(1);
DEFINE iMaxCommit		INTEGER;
DEFINE dFechaAlta		DATE;
DEFINE iTipoCliente		SMALLINT;
DEFINE iTipoClienteTit	SMALLINT;
DEFINE iTipoClientePros	SMALLINT;


--INICIALIZA VARIABLES
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	
LET cNumCte 			= '';	
LET iCont 				= 0;
LET cTelefono			= '';
LET iSecuencia			= 0;
LET iExisteTelAct		= 0;
LET iTipoTelCel			= 2;
LET cEstTelActivo		= 'A';
LET cEstTelCancel		= 'C';
LET iMaxCommit			= 5000;
LET dFechaAlta			= TODAY-1;
LET iTipoClienteTit		= 1;
LET iTipoClientePros	= 2;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO "/informix/jagl/bdinteg/sp_depura_celular_prospectos.out";
	--SET DEBUG FILE TO "/ifxsif01/jagl/bdinteg/sp_depura_celular_prospectos.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--Depura los registros de los prospectos tales que su fecha_alta sea igual al día anterior
	LET iCont = 0;
	BEGIN WORK;
	--Comienza foreach
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_telefonos_actual)}
		tel.telefono
		INTO cTelefono
		FROM "informix".si_cliente cte
		INNER JOIN "informix".si_telefonos_actual tel ON tel.numcte=cte.numcte
		WHERE cte.fecha_alta = dFechaAlta
		AND tel.tipo_tel = iTipoTelCel
		AND tel.status_tel = cEstTelActivo

		FOREACH WITH HOLD
			SELECT 
			{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_telefonos)}
			cte.numcte, tel.secuencia
			INTO cNumCte, iSecuencia
			FROM "informix".si_cliente cte
			INNER JOIN "informix".si_telefonos tel ON tel.numcte=cte.numcte
			WHERE cte.tipo_cliente = iTipoClientePros
			AND tel.telefono = cTelefono
			AND tel.tipo_tel = iTipoTelCel
			AND tel.status_tel = cEstTelActivo
			AND EXISTS
			(
				SELECT 
				{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_telefonos)}
				1 
				FROM "informix".si_cliente cte2
				INNER JOIN "informix".si_telefonos tel2 ON tel2.numcte=cte2.numcte 
				WHERE cte2.tipo_cliente = iTipoClienteTit 
				AND tel2.telefono = cTelefono 
				AND tel2.tipo_tel = iTipoTelCel 
				AND tel2.status_tel = cEstTelActivo
			)

			--Se consulta si existe un registro en la tabla si_telefonos_actual para dicho prospecto con el teléfono a depurar
			SELECT 
			{+AVOID_FULL ("informix".si_telefonos_actual)}
			count(*)
			INTO iExisteTelAct
			FROM "informix".si_telefonos_actual
			WHERE 
			numcte = cNumCte
			AND tipo_tel = iTipoTelCel
			AND telefono = cTelefono
			AND secuencia = iSecuencia
			;
			
			--Se elimina el celular de la tabla si_telefonos_actual para el prospecto
			IF iExisteTelAct > 0 THEN
				DELETE "informix".si_telefonos_actual
				WHERE 
				numcte = cNumCte
				AND tipo_tel = iTipoTelCel
				AND telefono = cTelefono
				AND secuencia = iSecuencia
				;
				LET iCont=iCont+1;
			END IF;
			
			--Se actualiza el estatus del celular como cancelado en la tabla si_telefonos para el prospecto
			UPDATE "informix".si_telefonos
			SET status_tel = cEstTelCancel
			WHERE 
			numcte = cNumCte
			AND tipo_tel = iTipoTelCel
			AND telefono = cTelefono
			AND secuencia = iSecuencia
			;

			LET iCont=iCont+1;
						
			IF iCont >= iMaxCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		END FOREACH;	
	END FOREACH;	
	--Finaliza foreach
	COMMIT WORK;
	
	--Depura los registros de los prospectos tales que su fecha de registro de su teléfono sea igual al día anterior
	LET iCont = 0;
	BEGIN WORK;
	--Comienza foreach
	FOREACH WITH HOLD
		SELECT 
		{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_telefonos)}
		tel.telefono
		INTO 
		cTelefono
		FROM "informix".si_cliente cte
		INNER JOIN "informix".si_telefonos tel ON tel.numcte=cte.numcte
		WHERE 
		cte.fecha_alta != dFechaAlta
		AND tel.tipo_tel = iTipoTelCel
		AND tel.status_tel = cEstTelActivo
		AND tel.fecha_hora >= dFechaAlta
		
		FOREACH WITH HOLD
			SELECT 
			{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_telefonos)}
			cte.numcte, tel.secuencia
			INTO cNumCte, iSecuencia
			FROM "informix".si_cliente cte
			INNER JOIN "informix".si_telefonos tel ON tel.numcte=cte.numcte
			WHERE cte.tipo_cliente = iTipoClientePros
			AND tel.telefono = cTelefono
			AND tel.tipo_tel = iTipoTelCel
			AND tel.status_tel = cEstTelActivo
			AND EXISTS
			(
				SELECT 
				{+AVOID_FULL ("informix".si_cliente), AVOID_FULL ("informix".si_telefonos)}
				1 
				FROM "informix".si_cliente cte2
				INNER JOIN "informix".si_telefonos tel2 ON tel2.numcte=cte2.numcte 
				WHERE cte2.tipo_cliente = iTipoClienteTit 
				AND tel2.telefono = cTelefono 
				AND tel2.tipo_tel = iTipoTelCel 
				AND tel2.status_tel = cEstTelActivo
			)

			--Se consulta si existe un registro en la tabla si_telefonos_actual para dicho prospecto con el teléfono a depurar
			SELECT 
			{+AVOID_FULL ("informix".si_telefonos_actual)}
			count(*)
			INTO iExisteTelAct
			FROM "informix".si_telefonos_actual
			WHERE 
			numcte = cNumCte
			AND tipo_tel = iTipoTelCel
			AND telefono = cTelefono
			AND secuencia = iSecuencia
			;
			
			--Se elimina el celular de la tabla si_telefonos_actual para el prospecto
			IF iExisteTelAct > 0 THEN
				DELETE "informix".si_telefonos_actual
				WHERE 
				numcte = cNumCte
				AND tipo_tel = iTipoTelCel
				AND telefono = cTelefono
				AND secuencia = iSecuencia
				;
				LET iCont=iCont+1;
			END IF;
			
			--Se actualiza el estatus del celular como cancelado en la tabla si_telefonos para el prospecto
			UPDATE "informix".si_telefonos
			SET status_tel = cEstTelCancel
			WHERE 
			numcte = cNumCte
			AND tipo_tel = iTipoTelCel
			AND telefono = cTelefono
			AND secuencia = iSecuencia
			;

			LET iCont=iCont+1;
						
			IF iCont >= iMaxCommit THEN
				LET iCont = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;
		END FOREACH;	
	END FOREACH;	
	--Finaliza foreach
	COMMIT WORK;

	RETURN cCodRet;
	
END;
END PROCEDURE
DOCUMENT 'AUTOR: Jorge Alberto Garcia Lopez',
'FECHA 03/12/2020',
'MODULO: Integral',
'BD: bdinteg',
'FUNCIONALIDAD: Depuración de teléfonos celulares de prospectos',
'DESCRIPCION: SPL encargado de depurar los teléfonos celulares de los prospectos, tales que exista un cliente con dicho teléfono';

CREATE PROCEDURE "informix".sp_conciliar_colspmx_cp(p_NumEstado INTEGER,
                                                p_Usuario   CHAR(8))
RETURNING CHAR(5) AS Cod_Ret;
--Macf 2010-08-27 v 1.1
--DECLARACIONES
DEFINE v_cod_ret				CHAR(5);
DEFINE iSqlErr					INTEGER;
DEFINE iSamErr					INTEGER;
DEFINE s_DescCiudad				CHAR(100);
DEFINE p_FechaHoy				DATE;
DEFINE i_CveEstado				INTEGER;
DEFINE i_CiudadCoppel			INTEGER;
DEFINE s_Asenta					CHAR(60);
DEFINE i_NumColonia				INTEGER;
DEFINE s_CodigoPostal			CHAR(5);
DEFINE s_TipoAsenta				CHAR(25);
DEFINE s_Municipio				CHAR(40);
DEFINE i_NvaColonia				INTEGER;
DEFINE cEmpresa                 CHAR(3);
DEFINE iNumCol1                 INTEGER;
DEFINE iNumCol2                 INTEGER;
DEFINE cBanCons                 CHAR(1);
DEFINE cEdo1                    CHAR(2);
DEFINE cEdo2                    CHAR(2);
DEFINE cCd1                     CHAR(3);
DEFINE cCd2                     CHAR(3);
DEFINE cPais1                   CHAR(3);
DEFINE cPais2                   CHAR(3);
DEFINE cCod1                    CHAR(5);
DEFINE cCod2                    CHAR(5);
DEFINE cCdCoppel1               INTEGER;
DEFINE cCdCoppel2               INTEGER;
DEFINE iRegistros               INTEGER;
DEFINE parEstado1				SMALLINT;
DEFINE parEstado2				SMALLINT;
DEFINE cNombreProceso           CHAR(30);
DEFINE vMensaje                 CHAR(80);
DEFINE i_CP_Catzonas        INTEGER;


--INICIALIZACIONES
LET v_cod_ret				    = "00000";
LET iSqlErr					    = 0;
LET iSamErr					    = 0;
LET s_DescCiudad			    = "";
LET p_FechaHoy				    = DATE(1);
LET i_CveEstado				    = 0;
LET i_CiudadCoppel			    = 0;
LET s_Asenta				    = "";
LET i_NumColonia			    = 0;
LET s_CodigoPostal			    = "";
LET s_TipoAsenta			    = "";
LET s_Municipio				    = "";
LET i_NvaColonia			    = 0;
LET cEmpresa                    = "001";
LET iNumCol1                    = 0;
LET iNumCol2                    = 999999;
LET cBanCons                    = "";
LET cEdo1                       = "";
LET cEdo2                       = "ZZ";
LET cCd1                        = "";
LET cCd2                        = "ZZZ";
LET cPais1                      = "";
LET cPais2                      = "ZZZ";
LET cCod1                       = "";
LET cCod2                       = "ZZZZZ";
LET cCdCoppel1                  = 1;
LET cCdCoppel2                  = 999999;
LET iRegistros                  = 0;
LET parEstado1					= 0;
LET parEstado2					= 0;
LET cNombreProceso  = 'CONCILIAR COLS ACTUALIZAR CP';
LET vMensaje        = 'PROCESO INICIALIZADO';
LET i_CP_Catzonas = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
---SET pdqpriority 20;

BEGIN

ON EXCEPTION SET iSqlErr, iSamErr
    LET v_cod_ret = iSqlErr;
    RETURN v_cod_ret;
END EXCEPTION;

--SET DEBUG FILE TO "/ids10_uc9/macf/conciliar_colspmx_cp.out";
--TRACE ON;

    --insertar control de procesos
    INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
    VALUES(cNombreProceso, v_cod_ret, vMensaje, iRegistros ,user, p_FechaHoy,
    (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));


--OBTIENE LA FECHA DEL SISTEMA
SELECT fecha_hoy
  INTO p_FechaHoy
  FROM si_fechas
 WHERE empresa = cEmpresa;

--VALIDA QUE EL ESTADO NO ESTE VACIO
IF NVL(p_NumEstado,"") = "" OR NVL(p_Usuario,"") = "" THEN
    RETURN "00001";
END IF;

--OPCION DE CONCILIACION POR MEDIO DE UN ESTADO
IF p_NumEstado > 0 THEN
   LET cBanCons = "E";
   LET cEdo1 = LPAD(p_NumEstado,2,"0");
ELSE
	LET cEdo1 = LPAD(0,2,"0");
   LET cBanCons = "G";
END IF;

--OBTIENE LAS DISTINTAS CIUDADES PERTENECIENTES AL ESTADO DE SEPOMEX
FOREACH WITH HOLD
	SELECT estado
	INTO parEstado1
	FROM si_estados
	WHERE estado = CASE WHEN cEdo1 > 0 THEN cEdo1
          ELSE estado END
	FOREACH WITH HOLD
	      SELECT {+ INDEX (bdinteg:si_catsepomex sicatsepomex)} a.ciudad_coppel, b.d_codigo, b.d_tipo_asenta, b.d_mnpio, b.d_asenta, b.d_ciudad,  b.c_estado
	        INTO i_CiudadCoppel  ,  s_CodigoPostal ,  s_TipoAsenta    ,  s_Municipio  ,  s_Asenta    ,  s_DescCiudad  ,  i_CveEstado
	        FROM bdinteg:si_ciudades a, bdinteg:si_catsepomex b
	       WHERE a.ciudad   BETWEEN cCd1   AND cCd2
	         AND a.estado   BETWEEN parEstado1  AND parEstado1
	         AND a.pais     BETWEEN cPais1 AND cPais2
	         AND a.d_ciudad = b.d_ciudad
	         AND b.d_codigo BETWEEN cCod1  AND cCod2
	         AND b.d_ciudad = a.d_ciudad
	         AND b.c_estado = a.estado
	         --AND b.estatus  = 2
	         AND a.ciudad_coppel BETWEEN cCdCoppel1 AND cCdCoppel2
	     

	        LET s_DescCiudad = TRIM(s_DescCiudad);
	        LET s_Asenta     = TRIM(s_Asenta);
	        LET s_TipoAsenta = TRIM(s_TipoAsenta);
	        LET i_CveEstado  = LPAD(i_CveEstado,2,"0");
			    LET s_CodigoPostal = s_CodigoPostal::INTEGER;

	           --BUSCA LA COLONIA EN EL CATALOGO Y OBTIENE EL NUMERO DE COLONIA EN CASO AFIRMATIVO
	           --SELECT FIRST 1 numerocolonia
	        SELECT {+ INDEX (bdinteg:si_catzonas idx_catzonass)} FIRST 1 numerocolonia, codigopostalzona   
	          INTO i_NumColonia, i_CP_Catzonas
	          FROM bdinteg:si_catzonas
	         WHERE numerociudad  = i_CiudadCoppel
	           AND numerocolonia BETWEEN iNumCol1 AND iNumCol2
	           AND municipiozona = s_Municipio
	           AND nombrezona    = s_Asenta;

              IF s_CodigoPostal  <> i_CP_Catzonas THEN
                 UPDATE bdinteg:si_catzonas
                    SET codigopostalzona = s_CodigoPostal, usr_modifica = 'UPD_CPS'
                  WHERE numerociudad  = i_CiudadCoppel
                    AND numerocolonia = i_NumColonia;
              END IF;

          LET s_DescCiudad 		 = "";
					LET i_CveEstado 		 = 0;
					LET i_CiudadCoppel		 = 0;
					LET s_CodigoPostal 		 = "";
					LET s_TipoAsenta 		 = "";
					LET s_Municipio			 = "";
					LET s_Asenta 			 = "";
					LET i_NumColonia 		 = 0;
          
	END FOREACH;
END FOREACH;
LET iRegistros = DBINFO("sqlca.sqlerrd2");

-- Indica que no hay registros con el filtro indicado.
IF iRegistros = 0 THEN
   LET v_cod_ret = "00002";
END IF;

LET vMensaje = 'PROCESO EXITOSO';

        INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
        VALUES(cNombreProceso, v_cod_ret, vMensaje, iRegistros ,user, p_FechaHoy,
        (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));


    RETURN v_cod_ret;
END
END PROCEDURE;