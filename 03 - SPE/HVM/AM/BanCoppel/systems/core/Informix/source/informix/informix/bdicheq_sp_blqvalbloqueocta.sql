CREATE PROCEDURE "informix".sp_blqvalbloqueocta(pCuenta CHAR(20))
Returning CHAR(5), CHAR(50);

    DEFINE vcodret  CHAR(5);
    DEFINE vsqlerr	INTEGER;
    DEFINE cMensaje char(50);
    DEFINE vexiste1 SMALLINT;
    DEFINE vexiste2 SMALLINT;

    LET vcodret = "00000"; -- si no esta bloqueada
    LET cMensaje = 'La cuenta no esta bloqueada';
    LET vexiste1 = 0;
    LET vexiste2 = 0;

    BEGIN
    
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            let vcodret = vsqlerr;
            RETURN vcodret, cMensaje ;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/sp_blqvalbloqueocta";
    --- TRACE ON;

    IF pCuenta = '' OR pCuenta IS NULL THEN
        LET vcodret = "30000"; 
        LET cMensaje = 'Falta Cuenta';
    END IF;
    
    SELECT COUNT(*) 
      INTO vexiste1 
      FROM bdicheq:sc_ctabloqueo
     WHERE cuenta = pCuenta;
     
    SELECT COUNT(*) 
      INTO vexiste2
      FROM bdicheq:sc_maechq
     WHERE cuenta = pCuenta
       AND status_cta = '5'
       AND motivo = '55';
    
    IF ( vexiste1 > 0 OR vexiste2 > 0 ) THEN 
        LET vcodret = "10000"; -- BLOQUEADA ACTUALMENTE
        LET cMensaje = 'La cuenta esta bloqueada';
        RETURN vcodret, cMensaje;
    END IF;

    IF NOT EXISTS( SELECT 1 FROM BDICHEQ:sc_histbloq WHERE cuenta = pCuenta) THEN
        LET vcodret = "20000"; -- NO ESTA BLOQUEADA PERO LO ESTUVO
        LET cMensaje = 'La cuenta estuvo bloqueada anteriormente';
        RETURN vcodret, cMensaje;
    END IF;

    RETURN vcodret, cMensaje;

    END
    
END PROCEDURE
DOCUMENT
'Autor   	 : Abigail Vasavilbazo Cañedo',
'DESCRIPCION : Este procedimiento valida que  la cuenta este bloqueada',
'FECHA		 : 15 Septiembre 2010',
'VERSION	 : 20100917.1044',
'BD			 : BDICHEQ',
'Autor       : Jorge Ivan Camacho Sánchez',
'DESCRIPCION : Se incluye las cuentas informadas',
'FECHA       : 02 Septiembre 2016',
'VERSION     : 20160902.1130',
'BD			 : BDICHEQ';

CREATE PROCEDURE "informix".sp_blqconsultabloqueo(pCuenta CHAR(20))
RETURNING CHAR(5)  AS Codret,
          CHAR(60) AS Mensaje,
          CHAR(1)  AS Movimiento,
          CHAR(5)  AS Clave,
          CHAR(1)  AS Status,
          MONEY(14,2) AS ImporteBloq,
          DATE  AS FechaBloq,
          CHAR(8) AS Usuario,
          CHAR(50) AS MotivoBloq,
          CHAR(50) AS OpcionBloq,
          CHAR(20) AS AreaSolic,
          CHAR(20) AS TipoBloq,
          CHAR(20) AS Cliente,
          CHAR(2) AS ClaveArea,
          CHAR(1) AS CodigoArea,
          CHAR(2) AS ClaveTipoBloq,
          CHAR(1) AS CodTipoBloq;
	
    DEFINE iSqlErr      INTEGER;
    DEFINE cCodRet      CHAR(5);
    DEFINE cMensaje     CHAR(60);
	DEFINE cMovimiento  CHAR(1);
	DEFINE cClave       CHAR(5);
	DEFINE cStatus      CHAR(1);
	DEFINE mImporteBloq MONEY(14,2);
	DEFINE dFechaBloq   DATE;
	DEFINE cUsuario     CHAR(8);
	DEFINE cMotivoBloq  CHAR(50);
	DEFINE cOpcionBloq  CHAR(50);
	DEFINE cAreaSolic   CHAR(20);
	DEFINE cTipoBloq    CHAR(20);
	DEFINE cCliente     CHAR(20);
	DEFINE ibandera		INTEGER;
	DEFINE ValorParam   CHAR(60);
	DEFINE cClaveArea   CHAR(2);
	DEFINE cCodigoArea  CHAR(1);
	DEFINE cCveTipoBloq CHAR(2);
	DEFINE cCodTipoBloq CHAR(1);
    DEFINE vstatus_cta  CHAR(1);
	
    LET iSqlErr         = 0;
    LET cCodRet         = "00000";
    LET cMensaje        = "EL PROCESO TERMINO EXISTOSAMENTE";
	LET cMovimiento     = "";
    LET cClave          = "";
    LET cStatus         = "";
	LET mImporteBloq    = 0.00;
	LET dFechaBloq      = "";
	LET cUsuario        = "";
	LET cMotivoBloq     = "";
	LET cOpcionBloq     = "";
	LET cAreaSolic      = "";
	LET cTipoBloq       = "";
	LET cCliente        = "";
	LET ibandera        = 0;	
	LET ValorParam      = "";
	LET cClaveArea      = "";
	LET cCodigoArea     = "";
	LET cCveTipoBloq    = "";
	LET cCodTipoBloq    = "";
    LET vstatus_cta     = "";
    
    BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodret = iSqlErr;
            LET cMensaje = 'ERROR INESPERADO EN LA EJECUCION DEL PROCEDIMIENTO';
            RETURN cCodRet, TRIM(cMensaje), TRIM(cMovimiento), TRIM(cClave), TRIM(cStatus), mImporteBloq, dFechaBloq,
                   TRIM(cUsuario), TRIM(cMotivoBloq), TRIM(cOpcionBloq), TRIM(cAreaSolic), TRIM(cTipoBloq), TRIM(cCliente),
                   TRIM(cClaveArea), TRIM(cCodigoArea), TRIM(cCveTipoBloq), TRIM(cCodTipoBloq);
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/informix/jivan/sp_blqconsultabloqueo.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;

    SELECT TRIM(Valor)
      INTO ValorParam  
      FROM bdicheq:sc_param 
     WHERE codparam = 'longcta';

    -- // Compara si el numero de cuenta cumple con el rango permitido.
    IF LENGTH(pCuenta) <> ValorParam THEN 
        LET cCodRet = '00001';
        LET cMensaje = 'NO ES UN NUMERO DE CUENTA VALIDO';
        RETURN cCodRet, TRIM(cMensaje), TRIM(cMovimiento), TRIM(cClave), TRIM(cStatus), mImporteBloq, dFechaBloq,
               TRIM(cUsuario), TRIM(cMotivoBloq), TRIM(cOpcionBloq), TRIM(cAreaSolic), TRIM(cTipoBloq), TRIM(cCliente),
               TRIM(cClaveArea), TRIM(cCodigoArea), TRIM(cCveTipoBloq), TRIM(cCodTipoBloq);
    END IF;
    
    -- // Verifica si la cuenta se encuentra la maestros de cheques.
    IF NOT EXISTS (SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = '001' and cuenta = pCuenta) THEN
        LET cCodRet = '00002';
        LET cMensaje = 'NO SE ENCUENTRA LA CUENTA EN LA BD';
        RETURN cCodRet, TRIM(cMensaje), TRIM(cMovimiento), TRIM(cClave), TRIM(cStatus), mImporteBloq, dFechaBloq,
               TRIM(cUsuario), TRIM(cMotivoBloq), TRIM(cOpcionBloq), TRIM(cAreaSolic), TRIM(cTipoBloq), TRIM(cCliente),
               TRIM(cClaveArea), TRIM(cCodigoArea), TRIM(cCveTipoBloq), TRIM(cCodTipoBloq);
    END IF;
    
    SELECT status_cta
      INTO vstatus_cta
      FROM bdicheq:sc_maechq
     WHERE cuenta = pCuenta;
     
    IF vstatus_cta = '3' THEN
        
        -- // Muestra un historial de bloqueos de una cuenta especifica.
        FOREACH
            SELECT NVL(hist.tipo_mov, ' '), NVL(hist.clave, ' '), NVL(hist.status_blo, ' '), NVL(hist.importe, 0), 
                   NVL(hist.fecha, ' '), NVL(hist.usuario, ' '), NVL(bloq.codigo, ' ')||' '||NVL(bloq.descripcion, ' '), 
                   NVL(opcbloq.opcion, ' ')||' '||NVL(opcbloq.descripcion, ' '), NVL(areabloq.descripcion, ' '), 
                   NVL(tipbloq.descripcion, ' '), NVL(maechq.num_cte, ' '), NVL(hist.cve_area, ' '),
                   NVL(hist.cod_area, ' '), NVL(hist.cve_tipobloq, ' '), NVL(hist.cod_tipobloq, ' ')
              INTO cMovimiento, cClave, cStatus, mImporteBloq, 
                   dFechaBloq, cUsuario, cMotivoBloq, 
                   cOpcionBloq, cAreaSolic, 
                   cTipoBloq, cCliente, cClaveArea, 
                   cCodigoArea, cCveTipoBloq, cCodTipoBloq
              FROM bdicheq:sc_histbloq hist
             LEFT OUTER JOIN bdicheq:sc_bloqueo       bloq     ON (hist.motivo = bloq.codigo)
             LEFT OUTER JOIN bdicheq:sc_opcionbloqueo opcbloq  ON (hist.opcion = opcbloq.opcion)
             LEFT OUTER JOIN bdicheq:sc_tipobloqueo   tipbloq  ON (hist.cve_tipobloq = tipbloq.clave)
             LEFT OUTER JOIN bdicheq:sc_areabloqueo   areabloq ON (hist.cve_area = areabloq.clave)
             INNER JOIN bdicheq:sc_maechq             maechq   ON (hist.cuenta = maechq.cuenta) 
             WHERE hist.cuenta = pCuenta
             ORDER BY hist.fecha DESC, hist.hora DESC
            
            LET ibandera = 1;

            RETURN cCodRet, TRIM(cMensaje), TRIM(cMovimiento), TRIM(cClave), TRIM(cStatus), mImporteBloq, dFechaBloq,
                   TRIM(cUsuario), TRIM(cMotivoBloq), TRIM(cOpcionBloq), TRIM(cAreaSolic), TRIM(cTipoBloq), TRIM(cCliente),
                   TRIM(cClaveArea), TRIM(cCodigoArea), TRIM(cCveTipoBloq), TRIM(cCodTipoBloq) WITH RESUME;
        END FOREACH
        
    ELIF vstatus_cta = '5' THEN
        
        -- // BLOQUEO PARA CUENTAS INFORMADAS
        SELECT 'B', '09', 'B', mae.sdo_actual, mae.fecha_proceso, 'informix', bloq.codigo||' '||TRIM(bloq.descripcion),
               '3'||' '||'BLOQUEO DE CARGOS', 'OPERACIONES', 'OFICIO', mae.num_cte, '04', 'O', '06', 'O'
          INTO cMovimiento, cClave, cStatus, mImporteBloq, dFechaBloq, cUsuario, cMotivoBloq, 
               cOpcionBloq, cAreaSolic, cTipoBloq, cCliente, cClaveArea, cCodigoArea, cCveTipoBloq, cCodTipoBloq
          FROM bdicheq:sc_maechq mae
         INNER JOIN bdicheq:sc_bloqueo bloq ON ( mae.motivo = bloq.codigo )
         WHERE mae.cuenta = pCuenta;
    
        LET ibandera = 1;

        RETURN cCodRet, TRIM(cMensaje), TRIM(cMovimiento), TRIM(cClave), TRIM(cStatus), mImporteBloq, dFechaBloq,
               TRIM(cUsuario), TRIM(cMotivoBloq), TRIM(cOpcionBloq), TRIM(cAreaSolic), TRIM(cTipoBloq), TRIM(cCliente),
               TRIM(cClaveArea), TRIM(cCodigoArea), TRIM(cCveTipoBloq), TRIM(cCodTipoBloq);
        
    END IF;
    
    -- // Comentado para futuras pruebas
    IF ibandera = 0 THEN
        LET cCodRet = '00003';
        LET cMensaje = 'LA CUENTA NUNCA A SIDO BLOQUEADA';
        RETURN cCodRet, TRIM(cMensaje), TRIM(cMovimiento), TRIM(cClave), TRIM(cStatus), mImporteBloq, dFechaBloq,
               TRIM(cUsuario), TRIM(cMotivoBloq), TRIM(cOpcionBloq), TRIM(cAreaSolic), TRIM(cTipoBloq), TRIM(cCliente),
               TRIM(cClaveArea), TRIM(cCodigoArea), TRIM(cCveTipoBloq), TRIM(cCodTipoBloq);
    END IF;

    END;
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: llena el grid con los valores historicos de la cuenta',
'AUTOR: Valentín López',
'FECHA: Septiembre 2010',
'VERSION: 201015.1225';

CREATE PROCEDURE "informix".sp_validaportanom_bpi(pSentido CHAR(1),pNumCliente CHAR(9), pCuentaReceptora CHAR(18),pCuentaOrdenante CHAR(18),pEmpRFC CHAR(12),pCveBcoOrdenante CHAR(3))
RETURNING
	CHAR(5),CHAR(150);

	DEFINE iSql_err INTEGER ;
    DEFINE cCod_ret CHAR(5);
	DEFINE cEstatusPort CHAR(2);
	DEFINE cCuentaOrdenante CHAR(20);
	DEFINE cCuentaReceptora CHAR(20);
	DEFINE cRFC CHAR(12);
	DEFINE cMensajeRetorno CHAR(150);
	DEFINE iContMismoFlujo INTEGER;
	DEFINE cCuenta CHAR(20);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cCuentaClabe CHAR(18);
	DEFINE cNombreBanco CHAR(40);

	LET cCod_ret  = '00000';
	LET cEstatusPort ='';
	LET cRFC='';
	LET cCuentaOrdenante='';
	LET cCuentaReceptora='';
	LET cMensajeRetorno='';
	LET cCuenta='';
	LET cNumTarjeta='';
	LET cCuentaClabe='';
	LET iContMismoFlujo=1;
	LET cNombreBanco='';

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret,cMensajeRetorno;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/gaby/spl_validaportanom_bpi/sp_validaportanom_bpi.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--SE OBTIENEN TODOS LOS DATOS DEL MISMO PRODUCTO
		SELECT cuenta,cuenta_clabe
		INTO cCuenta, cCuentaClabe
		FROM bdicheq:"informix".sc_maechq
		WHERE num_cte = pNumCliente AND cuenta_clabe = pCuentaReceptora;

		SELECT num_tarjeta
		INTO cNumTarjeta
		FROM bdicheq:"informix".sc_tarjeta
		WHERE cuenta=cCuenta AND status_tar='A';

		--SE OBTIENE EL NOMBRE LARGO DEL BANCO ORDENANTE
		SELECT descripcion
		INTO cNombreBanco
		FROM bdinteg:"informix".si_bancos
		WHERE banco=pCveBcoOrdenante;

		--SE ASIGNA EL RETORNO DEL BANCO CUANDO REGRESEE EXITO EL PROCEDIMIENTO, PARA SU USO POSTERIOR EN LA GENERACION DEL COMPROBANTE
		--DE SOLICITUD
		LET cMensajeRetorno=cNombreBanco;
		
		
		-------		
	IF TRIM(pCuentaReceptora) = TRIM(pCuentaOrdenante)  THEN  --Solicitud nueva, valida que la cuenta ordenante no sea igual a la receptora
							SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
							INTO cMensajeRetorno
							FROM bdibpi:"informix".bpi_catmensajesportanom
							WHERE id_mensaje=10;
							
							LET cCod_ret='00013';
							RETURN cCod_ret,cMensajeRetorno;
	END IF;

	IF pSentido=2 AND pCveBcoOrdenante = '137' THEN --Solicitud nueva, valida que el banco ordenante no sea igual al receptor
						SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
						INTO cMensajeRetorno
						FROM bdibpi:"informix".bpi_catmensajesportanom
						WHERE id_mensaje=10;
						
						LET cCod_ret='00014';
						RETURN cCod_ret,cMensajeRetorno;
	END IF;

	IF pSentido=1 THEN  --SENTIDO BANCOPPEL-OTRO BANCO
			IF SUBSTR(pCuentaReceptora, 0,3) = SUBSTR(pCuentaOrdenante,0,3) then   --Solicitud nueva, valida que el banco ordenante no sea igual al receptor
				SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
					INTO cMensajeRetorno
					FROM bdibpi:"informix".bpi_catmensajesportanom
					WHERE id_mensaje=10;
					
					LET cCod_ret='00015';
					RETURN cCod_ret,cMensajeRetorno;
					--VALIDACION DE TARJETA BANCOPPEL	
			END IF;		
			IF  EXISTS(
				SELECT cve_banco FROM bdicheq:sc_bines WHERE cve_banco='137' AND bin = SUBSTR(pCuentaReceptora, 0,6) ) THEN
					SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
						INTO cMensajeRetorno
						FROM bdibpi:"informix".bpi_catmensajesportanom
						WHERE id_mensaje=10;
						
						LET cCod_ret='00016';
						RETURN cCod_ret,cMensajeRetorno;
			END IF;
	END IF;
	
		
		
		--------

		IF pSentido=2 THEN --SENTIDO OTRO BANCO -BANCOPPEL
			FOREACH
				 SELECT {+INDEX (sc_portacec_solicitud, idx_cte_estport)}  estatus_portabilidad,cta_ordenante,cta_receptora,rfc_empresa
				 INTO cEstatusPort,cCuentaOrdenante,cCuentaReceptora,cRFC
				 FROM bdicheq:"informix".sc_portacec_solicitud
				 WHERE num_cte=pNumCliente AND estatus_portabilidad NOT IN(3,4,5,6)

				 --MISMA CUENTA RECEPTORA Y ORDENANTE
				 IF TRIM(cCuentaOrdenante)=TRIM(pCuentaOrdenante) AND (TRIM(cCuentaReceptora)=TRIM(pCuentaReceptora) OR TRIM(cCuentaReceptora)=TRIM(cNumTarjeta) OR TRIM(cCuentaReceptora)=TRIM(cCuenta) ) THEN
					IF iContMismoFlujo=2 THEN
						LET cCod_ret='00001';

						SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
						INTO cMensajeRetorno
						FROM bdibpi:"informix".bpi_catmensajesportanom
						WHERE id_mensaje=10;

						LET iContMismoFlujo=1;
						RETURN cCod_ret,cMensajeRetorno;

					ELIF cEstatusPort=1 THEN
						IF TRIM(cRFC)=TRIM(pEmpRFC) THEN

							SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
							INTO cMensajeRetorno
							FROM bdibpi:"informix".bpi_catmensajesportanom
							WHERE id_mensaje=5;

							LET cCod_ret='00002';

							RETURN cCod_ret,cMensajeRetorno;
						END IF;
					ELIF cEstatusPort=2 THEN
						IF TRIM(cRFC)=TRIM(pEmpRFC) THEN

							SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
							INTO cMensajeRetorno
							FROM bdibpi:"informix".bpi_catmensajesportanom
							WHERE id_mensaje=8;

							LET cCod_ret='00003';

							RETURN cCod_ret,cMensajeRetorno;
						END IF;

					END IF;

					LET iContMismoFlujo=iContMismoFlujo+1;
				--MISMA CUENTA RECEPTORA PERO DISTINTA CUENTA ORDENANTE
				 ELIF (TRIM(cCuentaReceptora)=TRIM(pCuentaReceptora) OR TRIM(cCuentaReceptora)=TRIM(cNumTarjeta) OR TRIM(cCuentaReceptora)=TRIM(cCuenta) ) AND TRIM(cCuentaOrdenante)<> TRIM(pCuentaOrdenante) THEN
					IF iContMismoFlujo=2 THEN
						LET cCod_ret='00004';

						SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
						INTO cMensajeRetorno
						FROM bdibpi:"informix".bpi_catmensajesportanom
						WHERE id_mensaje=10;

						LET iContMismoFlujo=1;
						RETURN cCod_ret,cMensajeRetorno;

					ELIF cEstatusPort=1 THEN
						IF TRIM(cRFC)=TRIM(pEmpRFC) THEN

							SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
							INTO cMensajeRetorno
							FROM bdibpi:"informix".bpi_catmensajesportanom
							WHERE id_mensaje=5;

							LET cCod_ret='00005';
							RETURN cCod_ret,cMensajeRetorno;

						END IF;
					ELIF cEstatusPort=2 THEN
						IF TRIM(cRFC)=TRIM(pEmpRFC) THEN

							SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
							INTO cMensajeRetorno
							FROM bdibpi:"informix".bpi_catmensajesportanom
							WHERE id_mensaje=8;

							LET cCod_ret='00006';
							RETURN cCod_ret,cMensajeRetorno;
						END IF;
					END IF;
					LET iContMismoFlujo=iContMismoFlujo+1;

				--MISMA DISTINTA CUENTA RECEPTORA PERO MISMA CUENTA ORDENANTE
				 ELIF (TRIM(cCuentaReceptora)=TRIM(pCuentaReceptora) AND TRIM(cCuentaReceptora)=TRIM(cNumTarjeta) AND TRIM(cCuentaReceptora)=TRIM(cCuenta) )  AND TRIM(cCuentaOrdenante)= TRIM(pCuentaOrdenante) THEN
					IF cEstatusPort=1 THEN
						IF TRIM(cRFC)=TRIM(pEmpRFC) THEN

							SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
							INTO cMensajeRetorno
							FROM bdibpi:"informix".bpi_catmensajesportanom
							WHERE id_mensaje=5;

							LET cCod_ret='00007';
							RETURN cCod_ret,cMensajeRetorno;
						END IF;
					ELIF cEstatusPort=2 THEN
						IF TRIM(cRFC)=TRIM(pEmpRFC) THEN

							SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
							INTO cMensajeRetorno
							FROM bdibpi:"informix".bpi_catmensajesportanom
							WHERE id_mensaje=8;

							LET cCod_ret='00008';
							RETURN cCod_ret,cMensajeRetorno;
						END IF;
					END IF;

				 --LA CUENTA RECEPTORA YA TIENE UNA SOLICITUD COMO CUENTA ORDENANTE
				 ELIF (TRIM(pCuentaReceptora) = TRIM(cCuentaOrdenante)) THEN
				 			SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
							INTO cMensajeRetorno
							FROM bdibpi:"informix".bpi_catmensajesportanom
							WHERE id_mensaje=3;

							LET cCod_ret='00008';
							RETURN cCod_ret,cMensajeRetorno;
				END IF;
			END FOREACH;

		ELIF pSentido=1 THEN  --SENTIDO BANCOPPEL-OTRO BANCO
			FOREACH
				 SELECT {+INDEX (sc_portacec_solicitud, idx_cte_cve_estatus)} estatus_portabilidad,cta_ordenante,cta_receptora,rfc_empresa
				 INTO cEstatusPort,cCuentaOrdenante,cCuentaReceptora,cRFC
				 FROM bdicheq:"informix".sc_portacec_solicitud
				 WHERE num_cte=pNumCliente AND clave_sentido=1 AND estatus_portabilidad NOT IN(3,4,5,6)

				  --MISMA CUENTA ORDENANTE
			IF TRIM(cCuentaOrdenante)=TRIM(pCuentaOrdenante) AND TRIM(cCuentaReceptora)=TRIM(pCuentaReceptora)  then
				 IF iContMismoFlujo>1 THEN
						SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
						INTO cMensajeRetorno
						FROM bdibpi:"informix".bpi_catmensajesportanom
						WHERE id_mensaje=3;

						LET cCod_ret='00009';
						LET iContMismoFlujo=1;
						RETURN cCod_ret,cMensajeRetorno;

				ELIF TRIM(cCuentaOrdenante)=TRIM(pCuentaOrdenante) OR TRIM(cCuentaOrdenante)=TRIM(cCuenta) OR TRIM(cCuentaOrdenante)=TRIM(cNumTarjeta) THEN
					IF cEstatusPort=1 THEN
						SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
						INTO cMensajeRetorno
						FROM bdibpi:"informix".bpi_catmensajesportanom
						WHERE id_mensaje=3;

						LET cCod_ret='00010';
						RETURN cCod_ret,cMensajeRetorno;
					ELIF cEstatusPort=2 THEN
						SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
						INTO cMensajeRetorno
						FROM bdibpi:"informix".bpi_catmensajesportanom
						WHERE id_mensaje=9;

						LET cCod_ret='00011';
						RETURN cCod_ret,cMensajeRetorno;
					END IF;
				ELIF TRIM(cCuentaOrdenante)<> TRIM(pCuentaOrdenante) AND TRIM(cCuentaOrdenante)=TRIM(cCuenta) AND TRIM(cCuentaOrdenante)=TRIM(cNumTarjeta)THEN
					LET cCod_ret='00000';
					RETURN cCod_ret,cMensajeRetorno;

				--LA CUENTA ORDENANTE YA TIENE UNA SOLICITUD COMO CUENTA RECEPTORA
				ELIF( TRIM(pCuentaOrdenante) <> '' OR TRIM(pCuentaOrdenante) IS NOT NULL)THEN
					FOREACH
					SELECT {+INDEX (sc_portacec_solicitud, idx_cte_estport)} estatus_portabilidad,cta_ordenante,cta_receptora,rfc_empresa
					INTO cEstatusPort,cCuentaOrdenante,cCuentaReceptora,cRFC
					FROM bdicheq:"informix".sc_portacec_solicitud
					WHERE num_cte=pNumCliente AND estatus_portabilidad NOT IN(3,4,5,6)

					IF  TRIM(pCuentaOrdenante) = TRIM(cCuentaReceptora)  THEN

				 		SELECT {+INDEX (bdibpi:"informix".bpi_catmensajesportanom, idx_idmensaje)} desc_mensaje
						INTO cMensajeRetorno
						FROM bdibpi:"informix".bpi_catmensajesportanom
						WHERE id_mensaje=4;

						LET cCod_ret='00008';
						RETURN cCod_ret,cMensajeRetorno;
					END IF;
					END FOREACH;
				END IF;
				LET iContMismoFlujo=iContMismoFlujo+1;
			END IF;	
			END FOREACH;
		ELSE
			LET cCod_ret='00012';
		END IF;

		RETURN cCod_ret,cMensajeRetorno;

	END;
END PROCEDURE
DOCUMENT
'FOLIO.........: 1636-BPI-PortabilidadNomina',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 15/02/2015',
'MODIFICACIÓN..: Se crea stored procedure para validacion de portabilidad de nomina',
'SOLICITA......: Alejandro Vazquez',
'BD............: bdicheq',
'Se agregan filtros para que no se pueda seleccionar una cuenta ordenante como cuenta receptora y viceversa',
'Bibiana Gaxiola Verdugo',
'Fecha: 30/03/2016',
'Se agregan filtros para valida que el banco ordenante no sea igual al receptor',
'Gabriela Aguilar',
'Fecha: 14/09/2016';

CREATE PROCEDURE "informix".sp_consultacedulas2( pFechaConcil DATE, pTipo SMALLINT, pregistros INTEGER, precuperacion INTEGER )
RETURNING CHAR(5), CHAR(40), CHAR(14), DECIMAL(18,2), DECIMAL(18,2), DECIMAL(18,2), CHAR(255), CHAR(1);
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iExiste          SMALLINT;
    DEFINE cNombre          CHAR(40);
    DEFINE cCtaContable     CHAR(14);
    DEFINE mSdoCheques      DECIMAL(18,2);
    DEFINE mSdoContab       DECIMAL(18,2);
    DEFINE mDifSaldos       DECIMAL(18,2);
    DEFINE cObservaciones   CHAR(255);
    DEFINE cEditable        CHAR(1);
    
    LET cCodRet1       = '000';
    LET cCodRet2       = '';
    LET cCodRet3       = '';
    LET iSqlErr	       = 0;
    LET iSamErr        = 0;
    LET cDesErr        = '';
    LET iExiste        = 0;
    LET cNombre        = '';
    LET cCtaContable   = '';
    LET mSdoCheques    = 0.00;
    LET mSdoContab     = 0.00;
    LET mDifSaldos     = 0.00;
    LET cObservaciones = '';
    LET cEditable      = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    END EXCEPTION;  
    
    -- SET DEBUG FILE TO "/tmp/sp_consultacedulas2.out";
    -- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:"informix".sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'CAPITAL';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT SKIP pregistros FIRST precuperacion nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:"informix".sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'CAPITAL'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:"informix".sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INTERES';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT SKIP pregistros FIRST precuperacion nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:"informix".sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INTERES'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:"informix".sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'SOBREGIRO';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT SKIP pregistros FIRST precuperacion nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:"informix".sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'SOBREGIRO'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:"informix".sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT SKIP pregistros FIRST precuperacion nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:"informix".sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
        END IF;
	ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
        INTO iExiste
        FROM bdicheq:"informix".sc_cedulacontable
        WHERE fecha_concil = pFechaConcil
			AND concepto = 'INT PAGARE';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT SKIP pregistros FIRST precuperacion nombre, cta_contable, sdo_sistema, sdo_balanza, dif_saldos, observaciones, editable
                  INTO cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable
                  FROM bdicheq:"informix".sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INT PAGARE'
                   
                RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable WITH RESUME;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, cCtaContable, mSdoCheques, mSdoContab, mDifSaldos, cObservaciones, cEditable;
		END IF;
	END IF;
     
    END;
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 27/06/2016',
'DESCRIPCION:Se agrego una consulta con el concepto de inteses de pagare para el pTipo = 5 de la consulta de cedulas',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_consultacedulas2_totales( pFechaConcil DATE, pTipo SMALLINT )
RETURNING CHAR(5), INTEGER;
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iExiste          SMALLINT;
    DEFINE cNombre          CHAR(40);
    DEFINE cCtaContable     CHAR(14);
    DEFINE mSdoCheques      DECIMAL(18,2);
    DEFINE mSdoContab       DECIMAL(18,2);
    DEFINE mDifSaldos       DECIMAL(18,2);
    DEFINE cObservaciones   CHAR(255);
    DEFINE cEditable        CHAR(1);
    DEFINE vNoRegistros INTEGER;
	
    LET cCodRet1       = '000';
    LET cCodRet2       = '';
    LET cCodRet3       = '';
    LET iSqlErr	       = 0;
    LET iSamErr        = 0;
    LET cDesErr        = '';
    LET iExiste        = 0;
    LET cNombre        = '';
    LET cCtaContable   = '';
    LET mSdoCheques    = 0.00;
    LET mSdoContab     = 0.00;
    LET mDifSaldos     = 0.00;
    LET cObservaciones = '';
    LET cEditable      = '';
	LET vNoRegistros = 0;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, vNoRegistros;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consultacedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, vNoRegistros;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:"informix".sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'CAPITAL';
           
        IF iExiste > 0 THEN
            --FOREACH
                SELECT COUNT(*)
				  INTO vNoRegistros
                  FROM bdicheq:"informix".sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'CAPITAL';
                   
                RETURN cCodRet1, vNoRegistros;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            --END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, vNoRegistros;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:"informix".sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INTERES';
           
        IF iExiste > 0 THEN
            --FOREACH
                SELECT COUNT(*)
				  INTO vNoRegistros
                  FROM bdicheq:"informix".sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'INTERES';
                   
                RETURN cCodRet1, vNoRegistros;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            --END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, vNoRegistros;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:"informix".sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'SOBREGIRO';
           
        IF iExiste > 0 THEN
            --FOREACH
                SELECT COUNT(*)
				  INTO vNoRegistros
                  FROM bdicheq:"informix".sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'SOBREGIRO';
                   
                RETURN cCodRet1, vNoRegistros;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            --END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, vNoRegistros;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:"informix".sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'PAGARE';
           
        IF iExiste > 0 THEN
            --FOREACH
                SELECT COUNT(*)
				  INTO vNoRegistros
                  FROM bdicheq:"informix".sc_cedulacontable
                 WHERE fecha_concil = pFechaConcil
                   AND concepto = 'PAGARE';
                   
                RETURN cCodRet1, vNoRegistros;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            --END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, vNoRegistros;
        END IF;
	ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
        INTO iExiste
        FROM bdicheq:"informix".sc_cedulacontable
        WHERE fecha_concil = pFechaConcil
			AND concepto = 'INT PAGARE';
           
        IF iExiste > 0 THEN
            --FOREACH
                SELECT COUNT(*)
				INTO vNoRegistros
				FROM bdicheq:"informix".sc_cedulacontable
				WHERE fecha_concil = pFechaConcil
					AND concepto = 'INT PAGARE';
                   
               RETURN cCodRet1, vNoRegistros;
                
                LET cNombre = '';
                LET cCtaContable = '';
                LET mSdoCheques = 0.00;
                LET mSdoContab = 0.00;
                LET mDifSaldos = 0.00;
            --END FOREACH;
        ELSE
            LET cCodRet1 = '100';
           RETURN cCodRet1, vNoRegistros;
		END IF;
	END IF;
     
    END;
    
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 27/06/2016',
'DESCRIPCION:Se agrego una consulta para el total de inteses de pagare con el pTipo = 5 de la consulta de cedulas',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_movnomina_consolidados(pEmpresa CHAR(3),pFecDesde CHAR(10),pFecHasta CHAR(10))
RETURNING CHAR (5)	   AS Codret,
          CHAR (10)    AS num_empleado,
          CHAR (30)    AS apell_paterno,	
          CHAR (20)    AS apell_materno,
          CHAR (30)    AS nombres,		
          CHAR (20)    AS cuenta_abono,	
          MONEY (16,2) AS importe,		
          INTEGER      AS concepto,		
          CHAR (60)    AS descripcion,	
          CHAR (1 )    AS status,			
          CHAR (30)    AS descripcionst,	
          DATE         AS fecha_aplicado,
          CHAR (17)    AS nombre_archivo;	


	DEFINE cCod_ret		 	CHAR (5);
	DEFINE iSqlErr			INTEGER; 
	DEFINE cNum_empleado	CHAR (10);		  
	DEFINE cApell_paterno	CHAR (30);		  
	DEFINE cApell_materno	CHAR (20);		  
	DEFINE cNombres		 	CHAR (30);		  
	DEFINE cCuenta_abono	CHAR (20);		  
	DEFINE mImporte		 	MONEY (16,2);  
	DEFINE iConcepto		INTEGER; 
	DEFINE cDescripcion	    CHAR (60);		  
	DEFINE cStatus			CHAR (1);		  
	DEFINE cDescripcionst	CHAR (30);		  
	DEFINE dtFecha_aplicado DATE;
	DEFINE cNombre_archivo	CHAR (17);

	LET cCod_ret		 = '00000';
	LET iSqlErr		 	 = 0;
	LET cNum_empleado	 = '';
	LET cApell_paterno	 = '';
	LET cApell_materno	 = '';
	LET cNombres		 = '';
	LET cCuenta_abono	 = '';
	LET mImporte		 = 0;
	LET iConcepto		 = 0;
	LET cDescripcion	 = '';
	LET cStatus			 = '';
	LET cDescripcionst	 = '';
	LET dtFecha_aplicado = DATE(1);
	LET cNombre_archivo	 = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  	
	--SET DEBUG FILE TO "/respaldosbd/Pedro/sp_movnomina_consolidados.out";
	--TRACE ON; 
	BEGIN
	-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			LET cCod_ret = iSqlErr;
			LET cNum_empleado	 = '';
			LET cApell_paterno	 = '';
			LET cApell_materno	 = '';
			LET cNombres		 = '';
			LET cCuenta_abono	 = '';
			LET mImporte		 = 0;
			LET iConcepto		 = 0;
			LET cDescripcion	 = '';
			LET cStatus			 = '';
			LET cDescripcionst	 = '';
			LET dtFecha_aplicado = DATE(1);
			LET cNombre_archivo	 = '';
			RETURN NVL(cCod_ret,''),NVL(cNum_empleado,''),NVL(cApell_paterno,''),NVL(cApell_materno,''),NVL(cNombres,''),NVL(cCuenta_abono,''),NVL(mImporte,0),NVL(iConcepto,0),NVL(cDescripcion,''),NVL(cStatus,''),NVL(cDescripcionst,''),NVL(dtFecha_aplicado,DATE(1)),NVL(cNombre_archivo,'');
		END EXCEPTION;
		
		--Validar Parametros de entrada:
		
		IF NVL(pEmpresa,'')='' OR nvl(pFecDesde,DATE(1)) = DATE(1) OR NVL(pFecHasta,DATE(1))= DATE(1) THEN
			LET cCod_ret = '00001';
		ELIF nvl(pFecDesde,DATE(1)) >= NVL(pFecHasta,DATE(1)) THEN
			LET cCod_ret = '00002';
		ELSE
			FOREACH
				SELECT a.num_empleado,a.apell_paterno ,a.apell_materno ,a.nombres ,a.cuenta_abono,a.importe,a.concepto,con.descripcion,a.status, sta.descripcion,fec.fecha_aplicado,a.nombre_archivo
				INTO cNum_empleado,cApell_paterno,cApell_materno,cNombres,cCuenta_abono,mImporte,iConcepto,cDescripcion,cStatus,cDescripcionst,dtFecha_aplicado,cNombre_archivo
				FROM bdicheq:"informix".sc_nominamovimientoshist a
				INNER JOIN bdicheq:"informix".sc_nominaconceptos con ON (a.concepto = con.codigoconcepto)
				INNER JOIN bdicheq:"informix".sc_nominaestatus sta ON (a.status = sta.cod_status AND sta.tpo_status='02')
				INNER JOIN bdicheq:"informix".sc_nominaencabezadosumariohist fec ON ( fec.empresa = pEmpresa AND fec.nombre_archivo = a.nombre_archivo AND fec.fecha_aplicado BETWEEN pFecDesde AND pFecHasta )
				UNION ALL
				SELECT a.num_empleado,a.apell_paterno ,a.apell_materno ,a.nombres ,a.cuenta_abono,a.importe,a.concepto,con.descripcion,a.status, sta.descripcion,fec.fecha_aplicado,a.nombre_archivo
				FROM bdicheq:"informix".sc_nominamovimientos a
				INNER JOIN bdicheq:"informix".sc_nominaconceptos con ON (a.concepto = con.codigoconcepto)
				INNER JOIN bdicheq:"informix".sc_nominaestatus sta ON (a.status = sta.cod_status AND sta.tpo_status='02')
				INNER JOIN bdicheq:"informix".sc_nominaencabezadosumario fec ON ( fec.empresa = pEmpresa AND fec.nombre_archivo = a.nombre_archivo AND fec.fecha_aplicado BETWEEN pFecDesde AND pFecHasta)
				ORDER BY a.num_empleado,fec.fecha_aplicado
				
				RETURN NVL(cCod_ret,''),NVL(cNum_empleado,''),NVL(cApell_paterno,''),NVL(cApell_materno,''),NVL(cNombres,''),NVL(cCuenta_abono,''),NVL(mImporte,0),NVL(iConcepto,0),NVL(cDescripcion,''),NVL(cStatus,''),NVL(cDescripcionst,''),NVL(dtFecha_aplicado,DATE(1)),NVL(cNombre_archivo,'') WITH RESUME;
			END FOREACH
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCod_ret = '00003';
			END IF
		END IF
		IF cCod_ret::INTEGER <> 0 THEN
			RETURN NVL(cCod_ret,''),NVL(cNum_empleado,''),NVL(cApell_paterno,''),NVL(cApell_materno,''),NVL(cNombres,''),NVL(cCuenta_abono,''),NVL(mImporte,0),NVL(iConcepto,0),NVL(cDescripcion,''),NVL(cStatus,''),NVL(cDescripcionst,''),NVL(dtFecha_aplicado,DATE(1)),NVL(cNombre_archivo,'');
		END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR:Pedro Gaspar Jimenez Guzman',
'FOLIO: 117',
'DESCRIPCION: Consulta la dispersión de nomina por rango de fechas.',
'FECHA: 2016-09-17',
'SOLICITA: Juan Carlos Lopez',
'RQM: RQM 02 073 Modificacion al reporte de dispersion de nomina.pdf',
'VERSION:20160917.1124',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cargarchivoportab_cancelaciones(pfecha_reg date,pnombrearchivo CHAR(30),cod_oper CHAR(2),itotalsol integer)
RETURNING CHAR(5),  --CODIGO RETORNO
		  CHAR(35), --NOMBRE DEL ARCHIVO
		  CHAR(50); --RUTA EN CENTRAL DONDE SE DEPOSITO ARCHIVO

		  
   -- // DESCRIPCION DE LOS PARAMETROS DE ENTRADA
    /*  pfecha_reg:       Fecha en la cual se va a cargar el arhivo
        pnombrearchivo:   Nombre del archivo que se va a cargar
		cod_oper:         Tipo de operación:  22= CANCELACIONES
		itotalsol:        Numero total de solicitudes cargadas en central 								  
	*/
	
	
	
--##############################################
---- DEFINIR  VARIABLES  GENERALES---	
--##############################################	
	
DEFINE cSqlerr				 INTEGER;
DEFINE cIsamErr				 INTEGER;
DEFINE cDescErr				 char(50);
DEFINE cCodret      		 char(5);
DEFINE cCodret2      		 char(5);
DEFINE cCodret3      		 char(50);	
DEFINE cruta_archi			 char(50);	
	
-- DEFINIR VARIABLES RUTAS
DEFINE ccancRutaArchivo      char(60);	
	
	
--## variables para  fecha de hoy
DEFINE dFechaHoy 			DATE;	
DEFINE cfecha_dmy           char(10);	
DEFINE vfecha_reg           char(8);  	
	
--##Variable para ver si el archivo ya fue procesado	
DEFINE itot_arch			INTEGER;	
	
--##Variables para el nombre del archivo	
DEFINE cArchivresp           char(35);
DEFINE cnombarcpar           char(20);	

--## Variable para ejecutar el System 
DEFINE cSQL 				 char(250);	
	
--## Estatus de carga del proceso 	
DEFINE cEstatuscarga	 	 char(1);	
	
--## Bandera para carga de proceso	
DEFINE cBandera 			 char(1);	
	
	
DEFINE cLinea 				 char(500);	
	
DEFINE iNumReg 				 INTEGER;	
	
DEFINE ven_transacc         SMALLINT;	
DEFINE cMensaje 			 char(110);	
DEFINE pempresa              char(3);	
	

DEFINE cRenglon 			 char(500);
	
-- DEFINIR VARIABLES ENCABEZADO 

DEFINE cfecha_presentacion   char(8);
DEFINE ccod_operacion        char(2);
DEFINE cnum_secuencia        INTEGER;
DEFINE cbanco_rec            INTEGER;
DEFINE csent_archi           char(1);	
	
-- DEFINIR VARIABLES DETALLE  
DEFINE ccod_ope              char(2); 
DEFINE isecuencia            integer; 
DEFINE cfolio_cancelacion    char(30);
DEFINE cfecha_solicitud      char(8);
DEFINE cnombre_cte           char(60);
DEFINE crfc_cte              char(13);
DEFINE ccta_receptora        char(20);
DEFINE ctipo_cta_receptora   char(2);
DEFINE cbco_receptor         char(5);
DEFINE ccta_ordenante        char(20);
DEFINE ctipo_cta_ordenante   char(2);
DEFINE cbco_ordenante        char(5);
DEFINE cfecha_nacimiento     char(8);
DEFINE crfc_empresa          char(12);
DEFINE cestatus_respuesta    char(2);
DEFINE cfecha_respuesta      char(8);
DEFINE ccurp_cte             char(18);	
DEFINE cfolio_solicitud      char(30);	
	
-- DEFINIR VARIABLES SUMARIO
DEFINE cnumsecuencia         INTEGER;
DEFINE ccodoperacion     	 INTEGER;
DEFINE itotalregistros   	 INTEGER;

DEFINE iRegistros		 	INTEGER; 	
	
DEFINE ivalidafolioexis	 INTEGER;	
	
	
	
	
--#############################################	
-- INICIALIZAR VALORES INICIALES --
--#############################################
LET cSqlerr 			= 0;
LET cIsamErr 			= 0;
LET cDescErr 			= '';
LET cCodret 			= '00000';
LET cCodret2 			= '';
LET cCodret3 			= '';	
LET cArchivresp         = "";	
LET cruta_archi			 = '';	
	

-- INICIALIZAR VARIABLES RUTAS		
LET ccancRutaArchivo     = '';	
	
	
-- Variables para fecha de hoy

LET dFechaHoy   		= DATE(1);	
LET cfecha_dmy          = '';
LET vfecha_reg          = ''; 

--Varible para archivo duplicado
LET itot_arch			   = 0;	
	
--Varibles para nombre del archivo	
LET cArchivresp            = "";
LET cnombarcpar            = "canceporta40137E";	
	
--Varibles para ejecutar System	
LET cSQL 				= '';	

-- Estatus de carga del proceso	
LET cEstatuscarga       = '0'; 	



LET cBandera = "F";
LET cLinea = '';
LET iNumReg = 0;
LET ven_transacc           = 0;	
LET cMensaje               = '';	
LET  pempresa              = '001';

LET cRenglon = '';

-- INICIALIZAR VARIABLES ENCABEZADO 

LET cfecha_presentacion  = '';
LET ccod_operacion       = '';
LET cnum_secuencia       = 0;
LET cbanco_rec           = 0;
LET csent_archi          = '';


-- INICIALIZAR VARIABLES DETALLE
LET  ccod_ope             = '';
LET  isecuencia           = 0;
LET cfolio_cancelacion    = '';
LET  cfecha_solicitud     = '';
LET  cnombre_cte          = '';
LET  crfc_cte             = '';
LET  ccta_receptora       = '';
LET  ctipo_cta_receptora  = '';
LET  cbco_receptor        = '';
LET  ccta_ordenante       = '';
LET  ctipo_cta_ordenante  = '';
LET  cbco_ordenante       = '';
LET  cfecha_nacimiento    = '';
LET  crfc_empresa         = '';
LET  cestatus_respuesta   = '';
LET  cfecha_respuesta     = '';
LET  ccurp_cte            = '';
LET  cfolio_solicitud     = '';

-- INICIALIZAR VARIABLES SUMARIO
LET cnumsecuencia      = 0;
LET ccodoperacion      = 0;  
LET itotalregistros    = 0;

LET iRegistros			   = 0;

LET ivalidafolioexis = 0;

	BEGIN
		------  Control de Errores no Controlados
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				Let cCodret = cSqlerr;   
				Let cCodret2 = cIsamErr;   
				Let cCodret3 = cDescErr;   
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;	
				
				END IF;
			   RETURN cCodret, cArchivresp, cruta_archi;
			END IF;
		END EXCEPTION;
		
		
		  --SET DEBUG FILE TO "/informix/VILLELA/sp_cargarchivoportab_cancelaciones.out";
		  --TRACE ON;
	  
		  SET LOCK MODE TO WAIT 3;
		  SET ISOLATION TO DIRTY READ;
	
		  BEGIN WORK;
		  LET ven_transacc = 1;
		
		  IF LENGTH(NVL(pfecha_reg,'')) = 0 OR LENGTH(NVL(pnombrearchivo,'')) = 0 OR LENGTH(NVL(cod_oper,'')) = 0  OR LENGTH(NVL(itotalsol,'')) = 0
			  THEN
			  LET cCodret='77777';   --PARAMETROS VACIOS	
			  RETURN cCodret, cArchivresp, cruta_archi;
		  END IF;
			
		
		
	--Se leerá de la tabla de parámetros (sc_parametros), aquellos datos fijos(rutas).
		
	      SELECT {+INDEX(sc_param idx_param1 )} valor
		  INTO ccancRutaArchivo 
		  FROM BDICHEQ:sc_param 
		  WHERE empresa = "001" 
		  AND codparam = 'rta_canpor_s';
		
		
	   -- Se leera la fecha de Hoy. 
	
		select fecha_hoy
		into dFechaHoy
		from sc_fechas
		where empresa = pempresa;	
		
		
		 --// PONE EN VARIABLES LA FECHA SOLICITADA (D/M/Y)	
		LET cfecha_dmy = LPAD(DAY(pfecha_reg),2,0)||'/'||LPAD(MONTH(pfecha_reg),2,0)||'/'||(YEAR(pfecha_reg));
		
	     --// PONE EN VARIABLES LA FECHA SOLICITADA (AAAAMMDD)
		LET vfecha_reg = YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0); 
		

		-- Busca en bitacora total de archivos procesados
		
	    select count(*) 
		into  itot_arch
		FROM  BDICHEQ: sc_portacec_bitacora_archivo_cancelaciones
		where fecha_carga=vfecha_reg and archivo=pnombrearchivo
		and estatus_carga ='0';
		
					
		IF   itot_arch > 0  THEN -- TRATA DE VOLVER A CARGAR EL ARCHIVO
		
			LET cCodret = '33333';
			LET cEstatuscarga = '1'; 
			
			
			LET cArchivresp= TRIM(cnombarcpar) || TRIM(vfecha_reg) || '.txt';
			LET cruta_archi=ccancRutaArchivo;
		
		ELSE
		

				--------------Validar que el archivo exista en la ruta del servidor ---------------------------------------------
			--- BORRAR  LA TABLA DE TEMPORAL EN CASO DE QUE EXISTA
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'portacanc_tmp2') THEN
				DROP TABLE bdicheq:"informix".portacanc_tmp2;

			END IF
			
		
			--- CREAR LA TABLA DE TEMPORAL
			CREATE TABLE bdicheq:"informix".portacanc_tmp2 (linea CHAR(500));
		
		
			LET cSQL = '';
			--- GUARDA LOS NOMBRES DE LOS ARCHIVOS EXISTENTES EN LA RUTA EL CARPETA.CAR
			LET cSQL = 'ls ' ||trim(ccancRutaArchivo)||' > '||trim(ccancRutaArchivo)||'carpeta.car';
			SYSTEM cSQL;

			LET cSQL = '';
			--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
			LET cSQL = 'echo " LOAD FROM '  ||trim(ccancRutaArchivo) || 'carpeta.car' || ' INSERT INTO portacanc_tmp2" > '|| trim(ccancRutaArchivo) || 'Temporal.sql';
			SYSTEM cSQL;

			LET cSQL = '';
			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
			--Let cSQL = 'dbaccess bdicheq ' ||trim(ccancRutaArchivo)|| 'Temporal.sql';   --Se activa para desarrollo   
			LET cSQL = '/ifxsif01/bin/dbaccess bdicheq ' ||trim(ccancRutaArchivo)|| 'Temporal.sql'; 
			COMMIT WORK;
			SYSTEM cSQL;
		
		
			BEGIN WORK;
			--- CICLO PARA BUSCAR EL NOMBRE DEL ARCHIVO
			FOREACH
				SELECT linea INTO cLinea FROM portacanc_tmp2
				IF cLinea = pNombreArchivo THEN
					LET cBandera = "T";
					EXIT FOREACH;
				END IF
			END FOREACH
		
		
			--- BORRAR LA TABLA TEMPORAL
			DROP TABLE portacanc_tmp2;
				
				--- VALIDA QUE EL ARCHIVO EXISTA
		IF cBandera = "F" THEN			
			LET cCodret = '191';
			LET cEstatuscarga = '1'; 
			LET pnombrearchivo= 'Codigo error 191'; 
			--Obtener los mensajes de retorno 
			SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
		
	
		ELSE
	
			-----------------------------------	
			--LIMPIAR LAS TABLAS TEMPORALES
			DELETE FROM sc_portaarchtemp WHERE num_serial is not null;
			
				---------Se carga archivo ( LOAD)---------
			Let cSQL = '';
			Let  cSQL = 'echo "load from '||trim(ccancRutaArchivo) ||trim(pnombrearchivo)||
						' insert into sc_portaarchtemp(columna);" > ' ||trim(ccancRutaArchivo) || 'cargaarchivo.sql';
			System cSQL;
			Let cSQL = '';
			--Let cSQL = 'dbaccess bdicheq '||trim(ccancRutaArchivo) ||'cargaarchivo.sql';  --Se activa para desarrollo
			Let cSQL = '/ifxsif01/bin/dbaccess bdicheq '||trim(ccancRutaArchivo) ||'cargaarchivo.sql';   
			COMMIT WORK;
			System cSQL;
			BEGIN WORK;
	
	
			----###############LIMPIA LOS REGISTROS EN BLANCO######################## ----------------------------------------
			 DELETE FROM BDICHEQ:sc_portaarchtemp WHERE LENGTH(TRIM(columna))<=1;
	
			 ------------------------------------------------------------------------------------------	      			
						------------------VALIDACIONES SOBRE EL ARCHIVO----------------------
							--- VALIDA QUE NO EXISTAN TIPOS DE REGISTROS AJENOS A LOS AUTORIZADOS
			IF EXISTS(SELECT columna FROM sc_portaarchtemp WHERE SUBSTR(columna,1,2) NOT IN ("01","02","09")) THEN
				--Existe un tipo de registro que no es autorizado
				LET cCodret = '175';
				LET cEstatuscarga = '1'; 
				LET pnombrearchivo= 'Codigo error 175'; 
				--Obtener los mensajes de retorno 
				SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
	
			ELSE
	
				--- VALIDA QUE EXISTAN LOS NUMEROS DE REGISTROS CORRESPONDIENTES
				LET iNumReg = 0;
				--- OBTENER EL NUMERO DE REGISTROS DE ENCABEZADO
				SELECT COUNT(*)::INTEGER INTO iNumReg FROM  sc_portaarchtemp WHERE SUBSTR(columna,1,2) = "01";
				IF iNumReg = 0 THEN
					--No Existe Encabezado en el archivo
					LET cCodret = '176';
					LET cEstatuscarga = '1'; 
					LET pnombrearchivo= 'Codigo error 176'; 
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
	
	
					--Existe mas de un Encabezado en el archivo	
					ELIF iNumReg > 1 THEN			
					LET cCodret = '177';
					LET cEstatuscarga = '1'; 
					LET pnombrearchivo= 'Codigo error 177'; 
					--Obtener los mensajes de retorno 
					SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
	
	
				ELSE
			
					LET iNumReg		= 0;
					--- OBTENER EL NUMERO DE REGISTROS DE SUMARIO
					SELECT COUNT(*)::INTEGER INTO iNumReg FROM  sc_portaarchtemp WHERE SUBSTR(columna,1,2) = "09";
					IF iNumReg = 0 THEN
						--No Existe Sumario en el archivo
						LET cCodret = '178';
						LET cEstatuscarga = '1'; 
						LET pnombrearchivo= 'Codigo error 178'; 
						--Obtener los mensajes de retorno 
						SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
						
					ELIF iNumReg > 1 THEN
						--Existe mas de un Sumario en el archivo
						LET cCodret = '179';
						LET cEstatuscarga = '1'; 
						LET pnombrearchivo= 'Codigo error 179'; 
						--Obtener los mensajes de retorno 
						SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
	
	
					ELSE
					 
						LET iNumReg		= 0;
						--- OBTENER EL NUMERO DE REGISTROS DE DETALLE
						SELECT COUNT(*)::INTEGER INTO iNumReg FROM  sc_portaarchtemp WHERE SUBSTR(columna,1,2) = "02";
						IF iNumReg = 0 THEN
							--No Existe Detalle en el archivo
							LET cCodret = '180';
							LET cEstatuscarga = '1'; 
							LET pnombrearchivo= 'Codigo error 180'; 
							--Obtener los mensajes de retorno 
							SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;
	

						ELSE
	
	
								FOREACH		
													
									SELECT columna INTO cRenglon FROM sc_portaarchtemp ORDER BY(num_serial)		

									--ASIGNACION DE VALORES A LAS VARIABLES
									IF SUBSTR(cRenglon,1,2) = "01" THEN --- ENCABEZADO		
										LET  cnum_secuencia = SUBSTR(cRenglon,3,7);
										LET  ccod_operacion = SUBSTR(cRenglon,10,2);
										LET  cbanco_rec = SUBSTR(cRenglon,12,5);	
										LET  csent_archi = SUBSTR(cRenglon,17,1);	
										LET  cfecha_presentacion = SUBSTR(cRenglon,18,8);

										
									ELIF  SUBSTR(cRenglon,1,2) = "02" THEN --- DETALLE
													LET isecuencia = SUBSTR(cRenglon,3,7);			
													LET ccod_ope   = SUBSTR(cRenglon,10,2);
												    LET cfolio_cancelacion = SUBSTR(cRenglon,12,30);													
													LET cfecha_solicitud = SUBSTR(cRenglon,42,8);
													LET cnombre_cte  = SUBSTR(cRenglon,50,99);
													LET crfc_cte     = SUBSTR(cRenglon,149,13);
													LET ccta_receptora  = SUBSTR(cRenglon,162,18);
													LET ctipo_cta_receptora = SUBSTR(cRenglon,180,2);
													LET cbco_receptor = SUBSTR(cRenglon,182,5);
													LET ccta_ordenante = SUBSTR(cRenglon,187,18);
													LET ctipo_cta_ordenante = SUBSTR(cRenglon,205,2);
													LET cbco_ordenante = SUBSTR(cRenglon,207,5);
													LET cfecha_nacimiento = SUBSTR(cRenglon,212,8);
													LET crfc_empresa = SUBSTR(cRenglon,220,13);
													LET cestatus_respuesta = SUBSTR(cRenglon,233,2);
													LET cfecha_respuesta = SUBSTR(cRenglon,235,8);
													LET ccurp_cte = SUBSTR(cRenglon,243,18);	
										            LET cfolio_solicitud = SUBSTR(cRenglon,261,30);
													
													
													
												IF  bdiprog:isnumeric(isecuencia) <> '1' 
															OR TRIM(ccod_ope) = '' OR (ccod_ope IS null)
															OR TRIM(cfolio_cancelacion) = '' OR (cfolio_cancelacion IS null)
															OR TRIM(cfecha_solicitud) = '' OR (cfecha_solicitud IS null) 
															OR TRIM(cnombre_cte) = '' OR (cnombre_cte IS null) 
															OR TRIM(crfc_cte) = '' OR (crfc_cte IS null) 
															OR TRIM(ccta_receptora) = '' OR (ccta_receptora IS null) 
															OR TRIM(ctipo_cta_receptora) = '' OR (ctipo_cta_receptora IS null)
															OR TRIM(cbco_receptor) = '' OR (cbco_receptor IS null) 
															OR TRIM(ccta_ordenante) = '' OR (ccta_ordenante IS null) 
															OR TRIM(ctipo_cta_ordenante) = ''  OR (ctipo_cta_ordenante IS null) 
															OR TRIM(cbco_ordenante) = ''  OR (cbco_ordenante IS null) 
															OR TRIM(cfecha_nacimiento) = ''  OR (cfecha_nacimiento IS null) 
															OR TRIM(crfc_empresa) = ''  OR (crfc_empresa IS null) 
															OR TRIM(cestatus_respuesta) = ''  OR (cestatus_respuesta IS null) 
															OR TRIM(cfecha_respuesta) = ''  OR (cfecha_respuesta IS null) 
															OR TRIM(ccurp_cte) = ''  OR (ccurp_cte IS null) 
															OR TRIM(cfolio_solicitud) = '' OR (cfolio_solicitud IS null)
															
															THEN
															--Error Un valor nULLOS En EL Archivo
															LET cCodret = '182';
															LET cEstatuscarga = '1'; 
															LET pnombrearchivo= 'Codigo error 182'; 
															--Obtener los mensajes de retorno 
															SELECT DESCRIPCION INTO cMensaje FROM bdinteg:si_codret WHERE sistema = '01' AND codigo_retorno = cCodret;	
												
												ELSE 
												
												
														-- // INSERTA EN LA TABLA sc_portacec_archfolio registra por cada folio de solicitud la fecha de carga y nombre de archivo 
														
														    			
															select count(*)
															into ivalidafolioexis
															from bdicheq: sc_portacec_archfolio_cancelaciones
															where folio_solicitud = cfolio_solicitud;

															
															IF ivalidafolioexis= 0 THEN -- //CONDICION PARA VALIDAR QUE EL FOLIO NO ESTE DUPLICADO
																		
																		
																update sc_portacec_solicitud
																set cod_operacion='22',
																estatus_portabilidad  = '4',														
																clave_origen='3',
																clave_sentido='0',
																folio_cancelacion = cfolio_cancelacion,
																fecha_solca_portabilidad= vfecha_reg,
																suc_cancela= 'OTBN.',
																user_cancela='informix'
																where folio_solicitud = cfolio_solicitud;			

															END IF
															
															INSERT INTO sc_portacec_archfolio_cancelaciones 
															(fecha_carga, archivo, folio_solicitud,folio_cancelacion,cta_receptora,bco_receptor,cta_ordenante,bco_ordenante )
															values (vfecha_reg,pnombrearchivo,cfolio_solicitud,cfolio_cancelacion,ccta_receptora,cbco_receptor,ccta_ordenante,cbco_ordenante);		
																		
												END IF												
																										
													
									ELIF 	SUBSTR(cRenglon,1,2) = "09" THEN       --- SUMARIO			
													LET cnumsecuencia =   SUBSTR(cRenglon,3,7);
													LET ccodoperacion =   SUBSTR(cRenglon,10,2); 
													LET itotalregistros = SUBSTR(cRenglon,12,7);				
													
										
									END IF	---CONDICION PARA EXTRAER DATOS (ENCABEZADO, DETALLE Y SUMARIO)
						

								END FOREACH		
	
	
		                END IF --VALIDA DETALLE	
							
				    END IF--VALIDA SUMARIO
						
			   END IF	--VALIDA ENCABEZADO

		    END IF -- VALIDA TIPOS DE REGISTROS
			
		END IF-- VALIDACION QUE EL ARCHIVO EXISTA
				
	 END IF -- VALIDA QUE EL ARCHIVO NO SE VUELVA A PROCESAR
		

			INSERT INTO sc_portacec_bitacora_archivo_cancelaciones
			(fecha_carga, fecha_presentacion, archivo, estatus_carga, total_registros)
			values(vfecha_reg,cfecha_presentacion,pnombrearchivo,cEstatuscarga,itotalregistros); 
		

			COMMIT WORK;				
			LET ven_transacc = 0;
					
			RETURN cCodret, cArchivresp, cruta_archi;
		
	END
    END PROCEDURE ;