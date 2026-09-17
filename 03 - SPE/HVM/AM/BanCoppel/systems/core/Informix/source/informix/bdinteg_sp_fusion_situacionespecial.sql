CREATE PROCEDURE "informix".sp_fusion_situacionespecial(pClienteTitular CHAR(20),pClienteTraspasaCtas CHAR(20),pUsuario CHAR(8))
RETURNING CHAR(8), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE iNomErr         INTEGER;
DEFINE iNanErr         INTEGER;
DEFINE vc_CodRet       CHAR(5);
DEFINE vc_Mensaje      CHAR(100);
DEFINE iEnTransaccion  SMALLINT;
DEFINE c_sitesp		   CHAR(3);
DEFINE dtFechaInsercion DATETIME HOUR TO FRACTION;
DEFINE cSit_Cliente_tit, cSit_Cliente_tras, cOri_Cliente_tit, cOri_Cliente_tras	CHAR(1);
DEFINE iCau_Cliente_tit, iCau_Cliente_tras, iPon_Cliente_tit, iPon_Cliente_tras,iSqlErr	INTEGER;


--ASIGNACION DE VARIABLES
LET vc_CodRet  = "00000";
LET vc_Mensaje = "EL PROCESO FUE REALIZADO CORRECTAMENTE";
LET iEnTransaccion = 0;
LET c_sitesp = '';
	
--SET DEBUG FILE TO "/informix/Ingrid/sp_fusion_situacionespecial.out";
--TRACE ON;
	
BEGIN
	--MANEJO DEL ERROR
	ON EXCEPTION SET iNomErr, iNanErr, vc_Mensaje
	
        IF iNomErr <> 0 THEN
			LET vc_CodRet=iNomErr;			
			
			IF iEnTransaccion = 1 THEN
				ROLLBACK;
			END IF;	
			
			RETURN vc_CodRet, vc_Mensaje;
			
		END IF;
	END EXCEPTION;
	
	-- SITUACIONES ESPECIALES --
    BEGIN WORK;	
		LET iEntransaccion = 1;
		
		IF EXISTS (SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} numcte FROM bdisitesp:se_ctessitespcte WHERE numcte = pClienteTraspasaCtas) THEN
			IF EXISTS (SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} numcte FROM bdisitesp:se_ctessitespcte WHERE numcte = pClienteTitular) THEN
				SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)}b.situacion, b.causa, cvesitesporigen, NVL(a.ponderacion,0)
				INTO cSit_Cliente_tit, iCau_Cliente_tit, cOri_Cliente_tit, iPon_Cliente_tit 
				FROM bdisitesp:se_catsitesp a, bdisitesp:se_ctessitespcte b
				WHERE a.causa = b.causa
				AND a.situacion = b.situacion
				AND b.numcte = pClienteTitular;
				
				SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} b.situacion, b.causa, cvesitesporigen, NVL(a.ponderacion,0)
				INTO cSit_Cliente_tras, iCau_Cliente_tras, cOri_Cliente_tras, iPon_Cliente_tras
				FROM bdisitesp:se_catsitesp a, bdisitesp:se_ctessitespcte b
				WHERE a.situacion = b.situacion
				AND a.causa = b.causa
				AND b.numcte = pClienteTraspasaCtas;
							
				IF (cSit_Cliente_tras = 'U' AND iCau_Cliente_tras = 3) AND (cSit_Cliente_tit = 'U' AND iCau_Cliente_tit = 3) THEN
					
					SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
					INSERT INTO bdinteg:si_fusctessitespcte (idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
								usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje)
					SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto, usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje
					FROM bdisitesp:se_ctessitespcte
					WHERE numcte = pClienteTitular;

					INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
					VALUES ('SITUACION ESPECIAL','se_ctessitespcte',pClienteTitular,pClienteTraspasaCtas,TRIM(pClienteTitular)||'|'||TRIM(pClienteTraspasaCtas)||'|'||'U3',dtFechaInsercion,pUsuario,CURRENT::DATE);
					
					UPDATE {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} bdisitesp:se_ctessitespcte 
					SET situacion = 'U', causa = 65, cvesitesporigen = '6' 
					WHERE numcte = pClienteTitular;
				ELIF (cSit_Cliente_tit = 'U' AND iCau_Cliente_tit = 3) AND (cSit_Cliente_tras||iCau_Cliente_tras <> 'U3') OR 
					 (cSit_Cliente_tit||iCau_Cliente_tit <> 'U3') AND (cSit_Cliente_tras||iCau_Cliente_tras <> 'U3') THEN
					IF (iPon_Cliente_tras < iPon_Cliente_tit) OR (cSit_Cliente_tit||iCau_Cliente_tit = 'U3' AND iPon_Cliente_tras > iPon_Cliente_tit)  THEN
						SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
						INSERT INTO bdisitesp:se_ctessitespcte_his (tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
						SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} tipomovto,numcte, empresa, situacion, causa, cvesitesporigen, sucursal, USER, usralta, fchalta, usrmodifica, fchmodifica
						FROM bdisitesp:se_ctessitespcte
						WHERE numcte = pClienteTitular;
						
						INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
						VALUES ('SITUACION ESPECIAL','se_ctessitespcte_his',pClienteTitular,pClienteTraspasaCtas,TRIM(pClienteTitular)||'|'||TRIM(pClienteTraspasaCtas)||'|'||cSit_Cliente_tit||iCau_Cliente_tit||'|'||cSit_Cliente_tras||iCau_Cliente_tras,dtFechaInsercion,pUsuario,CURRENT::DATE);

						INSERT INTO bdinteg:si_fusctessitespcte (idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
								usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje)
						SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto, usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje
						FROM bdisitesp:se_ctessitespcte
						WHERE numcte = pClienteTitular;

						INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
						VALUES ('SITUACION ESPECIAL','se_ctessitespcte',pClienteTitular,pClienteTraspasaCtas,TRIM(pClienteTitular)||'|'||TRIM(pClienteTraspasaCtas)||'|'||cSit_Cliente_tit||iCau_Cliente_tit||'|'||cSit_Cliente_tras||iCau_Cliente_tras,dtFechaInsercion,pUsuario,CURRENT::DATE);

						
						UPDATE {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} bdisitesp:se_ctessitespcte 
						SET situacion = cSit_Cliente_tras, causa = iCau_Cliente_tras, cvesitesporigen = '6'
						WHERE numcte = pClienteTitular;				
					END IF;					
				END IF;
			ELSE
				--Consultamos si el cliente incorrecto tiene U#
				SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} situacion || causa
				INTO c_sitesp
				FROM bdisitesp:se_ctessitespcte
				WHERE numcte = pClienteTraspasaCtas;
				IF(c_sitesp = 'U3') THEN
					--Si tiene una U3, insertamos un registro al cliente correcto, con los datos del incorrecto, pero cambiando la situacion especial a U65
					INSERT INTO bdisitesp:se_ctessitespcte (idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
				   	usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje)
					SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} (SELECT MAX(idmovto) + 1 FROM bdisitesp:se_ctessitespcte), empresa, pClienteTitular, 'U', 65, '6', sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
				   	usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje
				   	FROM bdisitesp:se_ctessitespcte
					WHERE numcte = pClienteTraspasaCtas;
				ELSE
					--Si no tiene U3 insertamos un registro al cliente correcto, con los datos del cliente incorrecto
					INSERT INTO bdisitesp:se_ctessitespcte (idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
				   	usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje)
				   	SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} (SELECT MAX(idmovto) + 1 FROM bdisitesp:se_ctessitespcte), empresa, pClienteTitular, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
				   	usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje
					FROM bdisitesp:se_ctessitespcte
					WHERE numcte = pClienteTraspasaCtas;
				END IF;		
			END IF;
			
			SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
			
			INSERT INTO bdinteg:si_fusctessitespcte (idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
				   usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje)
			SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
				   usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje
			FROM bdisitesp:se_ctessitespcte
			WHERE numcte = pClienteTraspasaCtas;

			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('SITUACION ESPECIAL','si_fusctessitespcte',pClienteTitular,pClienteTraspasaCtas,TRIM(pClienteTitular)||'|'||TRIM(pClienteTraspasaCtas),dtFechaInsercion,pUsuario,CURRENT::DATE);
			

			DELETE {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)}
			FROM bdisitesp:se_ctessitespcte
			WHERE numcte = pClienteTraspasaCtas;
			
			INSERT INTO bdinteg:si_fusctessitespcte_his(idmovto, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
			SELECT {+INDEX (bdisitesp:se_ctessitespcte_his se_ctessitespcte_his_idx2)} idmovto, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica
			FROM  bdisitesp:se_ctessitespcte_his
			WHERE numcte = pClienteTraspasaCtas;

			INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('SITUACION ESPECIAL','si_fusctessitespcte_his',pClienteTitular,pClienteTraspasaCtas,TRIM(pClienteTitular)||'|'||TRIM(pClienteTraspasaCtas),dtFechaInsercion,pUsuario,CURRENT::DATE);
			
			
			DELETE {+INDEX (bdisitesp:se_ctessitespcte_his se_ctessitespcte_his_idx2)}
			FROM bdisitesp:se_ctessitespcte_his
			WHERE numcte = pClienteTraspasaCtas;

		ELIF EXISTS (SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} numcte FROM bdisitesp:se_ctessitespcte WHERE numcte = pClienteTitular) THEN
			SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} situacion || causa
			INTO c_sitesp
			FROM bdisitesp:se_ctessitespcte
			WHERE numcte = pClienteTitular;
			
			--Si el cliente titular tiene una situacion 'U3' se actualizara a 'U65'
			IF(c_sitesp = 'U3') THEN
				SELECT DBINFO('utc_to_datetime',sh_curtime) INTO dtFechaInsercion FROM sysmaster:"informix".sysshmvals;
				INSERT INTO bdinteg:si_fusctessitespcte (idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
							usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje)
				SELECT {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto, usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje
				FROM bdisitesp:se_ctessitespcte
				WHERE numcte = pClienteTitular;

				INSERT INTO log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES ('SITUACION ESPECIAL','se_ctessitespcte',pClienteTitular,pClienteTraspasaCtas,TRIM(pClienteTitular)||'|'||TRIM(pClienteTraspasaCtas)||'|'||'U3',dtFechaInsercion,pUsuario,CURRENT::DATE);
				
				UPDATE {+INDEX (bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} bdisitesp:se_ctessitespcte 
				SET situacion = 'U', causa = 65, cvesitesporigen = '6' 
				WHERE numcte = pClienteTitular;
			END IF;
		END IF;
		
		COMMIT WORK;
		
		LET iEnTransaccion = 0;
		
	RETURN vc_CodRet,vc_Mensaje;
END;
END PROCEDURE
DOCUMENT
'REALIZA:Fusión de situaciones especiales',
'EQUIPO:Análisis y diseño de Mannto.4',
'FECHA:09/06/2015',
'VERSION:20150609',
'MODIFICO: Ingrid Pamela Cázarez Villegas',
'DESCRIPCION: Se realiza fusión de las situaciones especiales.';

CREATE PROCEDURE "informix".sp_agregarbitacora_bpi_pba(pFechaOper datetime year to second, pNumTrans char(4),pNumSuc char(4),pIdUsuario integer,pIpUsuario char(15),pFechaApli date,pCtaOrigen char(12),pCtaDesti char(18),pMonto money,pSecTrans char(16),pCgen1 char(40),pCgen2 char(40),pCgen3 char(40),pCgen4 char(40))
 returning char(5);
 
    -- Realizo   : Javier Alonso Chávez Trujillo
    -- Actividad : Agrega Bitacora
    -- Solicitó  : Mauricio Leon
    -- Fecha     : 25/11/2008
	--//////////////////////////////////////////
	-- Realizo   : Walber Castro
	-- Actividad : se modifica el tipo de dato del parametro de entrada Monto ya que redondeaba las cifras grandes.
	-- Solicitó  : Mauricio Leon
	-- Fecha     : 23/08/2010
	-- ////////////////////////////////////////
	-- Bibiana Gaxiola Verdugo
	-- Se agrega la actualización del movimiento en la tabla de cuentas frecuentes para la caducidad de las mismas.
	-- 21/01/2013
 
 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;
DEFINE vCtasFrec CHAR(1);
DEFINE vNumCte CHAR(10);
DEFINE vCveCaducidad CHAR(1);

--INICIALIZA VARIABLES
LET cod_ret  = "000";

--SET DEBUG FILE TO "/home/informix/bibiana/sp_agregarbitacora_bpi.out";
--TRACE ON;

BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
   
	INSERT INTO si_bpibitacora(fecha_oper,  
			     id_operacion, 
			     sucursal, 
			     id_usuario,
			     ipusuario, 
			     fecha_aplic, 
			     cuenta_origen,
			     destino,
			     monto_oper, 
			     sec_transaccion,
			     cgenerico1,
			     cgenerico2,
			     cgenerico3,
			     cgenerico4) VALUES (pFechaOper,
						  pNumTrans,
						  pNumSuc,
						  pIdUsuario,
						  pIpUsuario,
						  pFechaApli,
						  pCtaOrigen,
						  pCtaDesti,
						  pMonto,
						  pSecTrans,
						  pCgen1,
						  pCgen2,
						  pCgen3,
						  pCgen4);
	--RETURN cod_ret;

		
		SELECT ctas_frec INTO vCtasFrec FROM bdibpi:"informix".bpi_cat_operaciones WHERE id_oper = pNumTrans;
		
		IF (vCtasFrec = '1') THEN --- Significa que son operaciones que involucran cuentas frecuentes
		
			SELECT numcliente INTO vNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo';
		
			IF (pNumTrans IN ('1016','2100','2017','2020','2021','2022','2023')) THEN
				SELECT cve_caducidad INTO vCveCaducidad FROM bdiprog:"informix".pp_ctasterceros WHERE cuenta = pCtaDesti AND num_cte = vNumCte;

				IF (vCveCaducidad = '3') THEN
					UPDATE bdiprog:"informix".pp_ctasterceros SET fecha_movtos = today WHERE cuenta = pCtaDesti AND num_ctE = vNumCte;
					RETURN cod_ret;
				ELSE
					RETURN cod_ret;
				END IF;
			ELSE
			--IN ('1015','1017','1020','1021','1022','1023','1024','1025')) THEN 
				SELECT cve_caducidad INTO vCveCaducidad FROM bdiprog:"informix".pp_ctasterceros WHERE cuenta = pCgen2 AND num_cte = vNumCte;
			
				IF (vCveCaducidad = '3') THEN
					UPDATE bdiprog:"informix".pp_ctasterceros SET fecha_movtos = today WHERE cuenta = pCgen2 AND num_ctE = vNumCte;
					RETURN cod_ret;
				ELSE
					RETURN cod_ret;
				END IF;
			END IF;
			
		END IF;
		RETURN cod_ret;
	--END IF;
	--RETURN cod_ret;
END;
END PROCEDURE;