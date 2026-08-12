CREATE PROCEDURE "informix".sp_envia_notificacion_pr(
					pTipoMsj char(1), pIdMsj char(10),pIdPlantilla char(12), pNumclt char(20),
					pNumcta char(20), pNumTarjeta char(16),pTipoproc char(1), pStr1 char(30), 
					pStr2 char(30), pStr3 char(30), pStr4 char (30), 
					pStr5 char(150), pStr6 char(100), pStr7 char(60), pStr8 char(60), 
					pStr9 char(15), pStr10 char(100), pcorreo_alterno char(100), pcelular_alterno char(10), 
					pImporte1 money (16,2), pImporte2 money (16,2),
					pImporte3 money (16,2), pImporte4 money (16,2), pImporte5 money (16,2), 
					pfecha1 datetime year to fraction(3), pfecha2 datetime year to fraction(3),
				    pIdsesion CHAR(200))

RETURNING CHAR(5), CHAR (150);  -- Codigo de Retorno.

DEFINE vsqlerr INTEGER;
DEFINE cCodRetLat CHAR(5);
DEFINE cMensajeRet CHAR(150);
DEFINE cCodRet CHAR(5);
DEFINE cIdSesion CHAR(200);

LET vsqlerr = 0;
LET cCodRetLat='';
LET cMensajeRet='';
LET cIdSesion='';
LET cCodRet='00000';

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
		 SELECT valor 
			INTO cMensajeRet
			FROM bdibpi:"informix".pr_param_mensajes 
			WHERE id_param='007' AND tipo_param='2';

         return vsqlerr, cMensajeRet;
      END IF;
   END EXCEPTION;
   
   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;
   
	--SET DEBUG FILE TO "/tmp/sp_envia_notificacion_pr.out";
	--TRACE ON;
	
	--VALIDA SESION PERMITIDA
			SELECT id_sesion 
			INTO cIdSesion
			FROM bdibpi:"informix".pr_sesiones_activas WHERE id_sesion=pIdsesion;
			
			IF NVL(cIdSesion,'')<>''  THEN
				--SE MANDA A LLAMAR LATINIA PARA MANDAR CODIGO POR SMS SE UTILIZA LA PLANTILLA SMS_RAYO1
					EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(pTipoMsj,pIdMsj,pIdPlantilla,pNumclt,pNumcta,pNumTarjeta,pTipoproc, 
					pStr1,pStr2,pStr3,pStr4,pStr5,pStr6,pStr7,pStr8,pStr9,pStr10,pcorreo_alterno,pcelular_alterno,pImporte1,pImporte2,pImporte3,
					pImporte4,pImporte5,pfecha1,pfecha2) 
					INTO cCodRetLat;
					IF cCodRetLat<>'00000' THEN
						LET cCodRet='00003'; --ERROR EN LATINIA
						SELECT valor 
						INTO cMensajeRet
						FROM bdibpi:"informix".pr_param_mensajes 
						WHERE id_param='007' AND tipo_param='2';
					END IF;

			ELSE
				LET cCodRet='00002';
				SELECT valor 
				INTO cMensajeRet
				FROM bdibpi:"informix".pr_param_mensajes 
				WHERE id_param='008' AND tipo_param='2';
			END IF;
			
		 return cCodRet, cMensajeRet;
		
END;

END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - PagoRayo',
'AUTOR.........: 95734511 - José Magdiel Martínez López',
'FECHA.........: 27/05/2014',
'MODIFICACIÓN..: Se crea stored procedure sp_envia_notificacion_pr para enviar notificación del pago del servicio rayo',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_elimina_acceso_pr( pRegistro CHAR(20),pIdSesion CHAR(200))
   returning CHAR(5);

    DEFINE sql_err INTEGER ;
    DEFINE cCod_ret CHAR(5);	
	LET cCod_ret='00000';
  --SET DEBUG FILE TO "/tmp/sp_elimina_acceso_pr.out";
  --TRACE ON;
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCod_ret = sql_err;
            RETURN cCod_ret;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF(NVL(pRegistro,'')='' OR NVL(pIdSesion,'')='')THEN
		LET cCod_ret = '00001';
		RETURN cCod_ret;
	END IF;
		DELETE  FROM bdibpi:"informix".pr_sesiones_activas WHERE id_sesion=pIdSesion OR num_celular=pRegistro;
	RETURN cCod_ret;
	
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - ProyectoRayo',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 27/05/2014',
'MODIFICACIÓN..: Se crea stored procedure, se elimina sesion para acceso ala api pago rayo',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_conscuenta_pr (pEmpresa char(3), pTarjeta char (20))
RETURNING 	char (5), 
			char (20); 
			
			
	DEFINE v_cCodRet	char (5);
	DEFINE v_cEmpresa	char (3);
	DEFINE v_cTarjeta	char (20);
	DEFINE v_cNumCta	char (20);
	DEFINE iSqlErr 		integer;
	
	LET v_cCodRet	= '00000';
	LET v_cEmpresa	= pEmpresa;
	LET v_cTarjeta	= pTarjeta;
	LET v_cNumCta	= '';
	LET iSqlErr		= 0;
	
	
	-- set debug file to "/tmp/sp_consCuenta.out";
    -- trace on;
    
    set isolation to dirty read;
    set lock mode to wait 3;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET v_cCodRet= iSqlErr;				
				RETURN v_cCodRet, v_cNumCta;
			END IF;
		END EXCEPTION;
		
		IF NVL(TRIM(v_cTarjeta),'') == '' OR v_cTarjeta IS NULL THEN
			LET v_cCodRet	= '00001';
		ELSE
			SELECT cuenta
			INTO v_cNumCta
			FROM bdicheq:'informix'.sc_tarjeta
			WHERE empresa = v_cEmpresa AND
				  num_tarjeta = TRIM(v_cTarjeta);
		END IF;
		RETURN v_cCodRet, v_cNumCta;
	END
END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - PagoRayo',
'AUTOR.........: 95734511 - José Magdiel Martínez López',
'FECHA.........: 27/05/2014',
'MODIFICACIÓN..: Se crea stored procedure sp_consCuenta_pr que consulta la cuenta asociada a una tarjeta',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_cancelaservicio_suc_pr (pCelular CHAR(10))
RETURNING 	CHAR (5);
	
	
	
	DEFINE v_cCodRet	CHAR (5);
	DEFINE v_cCelular	char (10);
	DEFINE iSqlErr		INTEGER;
	DEFINE iCont		INTEGER;
	
	LET v_cCodRet	= '00000';
	LET v_cCelular	= pCelular;
	LET iSqlErr 	= 0;
	LET iCont 		= 0;

	-- SET DEBUG FILE TO "/tmp/sp_cancelaServicio_pr.out";
    -- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET v_cCodRet= iSqlErr;				
				RETURN v_cCodRet;
			END IF;
		END EXCEPTION;
		
		IF NVL(TRIM(v_cCelular),'') = '' OR v_cCelular IS NULL THEN
			LET v_cCodRet	= '00001';
		ELSE
			SELECT COUNT(celular) INTO iCont 
			FROM bdibpi:'informix'.pr_registro_app
			WHERE celular = v_cCelular;
			IF iCont > 0 THEN
				INSERT INTO bdibpi:'informix'.pr_registro_app_his (id_usuario,num_cliente,celular,cuenta,contrasenia,
							alias,imei,mac,folio_activacion,estatus_servicio,fecha_ulti_acceso,fecha_reg,fecha_mod)
				SELECT id_usuario,num_cliente,celular,cuenta,contrasenia,alias,imei,mac,folio_activacion,
					   'C',fecha_ulti_acceso,fecha_reg,fecha_mod
				FROM bdibpi:'informix'.pr_registro_app
				WHERE celular = v_cCelular AND estatus_servicio IN('A','I');
				
				DELETE FROM bdibpi:'informix'.pr_registro_app
				WHERE celular = v_cCelular;
				
				INSERT INTO bdicheq:"informix".sc_cuenta_telefono_hist (num_cte,cuenta,telefono,canal,es_transfer,user_insert,fecha_hora_insert) 
				SELECT * 
				FROM bdicheq:"informix".sc_cuenta_telefono 
				WHERE telefono = v_cCelular AND es_transfer = 'R';
				
				DELETE FROM bdicheq:"informix".sc_cuenta_telefono
				WHERE telefono = v_cCelular AND es_transfer = 'R';
			ELSE
				LET v_cCodRet = '00002';
			END IF;
				
		END IF;
		RETURN v_cCodRet;
	END
END PROCEDURE
DOCUMENT
'FOLIO.........: 1549 - PagoRayo',
'AUTOR.........: 95734511 - José Magdiel Martínez López',
'FECHA.........: 27/05/2014',
'MODIFICACIÓN..: Se crea stored procedure sp_cancelaServicio_pr para cancelar el servicio pago rayo  ',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI',
'FOLIO.........: 1785 - MejorasPagoRayo',
'AUTOR.........: Carolina Verdugo',
'FECHA.........: 12/02/2016',
'MODIFICACIÓN..: Se modifica procedimiento para que borre de la tabla sc_cuenta_telefono y pase a la historica se agrega estatus I  ',
'SOLICITA......: Jesus Montoya',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_depura_tbl_bpi_bitacora_total(pfechaini date,pfechafin date )
RETURNING CHAR(5), INTEGER, CHAR(100);
---------------------------------------------------------------------------------
-- Procedimiento   : sp_depura_tbl_bpi_bitacora_total
-- Version         : 1.0
-- Fecha creacion  : Abril 2015
-- Descripcion     : Depura la información de la tabla bpi_bitacora
-----------------------------------------------------------------------------------
--Definicion de variables del proceso, operaciones con fechas y manejo de errores--
-----------------------------------------------------------------------------------
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
	DEFINE error_info		CHAR(100);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
	DEFINE vcontador2       INTEGER;
	DEFINE vcomienza        SMALLINT;
    DEFINE vabierto         SMALLINT;
	DEFINE vf_depura        DATE;
	DEFINE vf_oper          DATE;
	DEFINE vf_ultdiames     DATE;
	DEFINE vrow      		INTEGER;
	DEFINE vrownew      	INTEGER;
	DEFINE vtable			CHAR(50);
	DEFINE vtbl				CHAR(20);
	DEFINE vfecha_oper     	DATE;         
	DEFINE vid_operacion   	CHAR(4);      
	DEFINE vsucursal       	CHAR(4);      
	DEFINE vid_usuario     	INTEGER;      
	DEFINE vipusuario      	CHAR(15);     
	DEFINE vfecha_aplic    	DATE;         
	DEFINE vcuenta_origen  	CHAR(12);     
	DEFINE vdestino        	CHAR(18);     
	DEFINE vmonto_oper     	DECIMAL(14,2);
	DEFINE vsec_transaccion	CHAR(16);     
	DEFINE vcgenerico1     	CHAR(100);    
	DEFINE vcgenerico2     	CHAR(100);    
	DEFINE vcgenerico3     	CHAR(200);    
	DEFINE vcgenerico4     	CHAR(40);     
	DEFINE vcgenerico5     	CHAR(60);     
	DEFINE vcgenerico6     	CHAR(100);    
	DEFINE vreferencia     	CHAR(100);    
	DEFINE vfolio          	CHAR(16);     
	DEFINE vsql             CHAR(4000);
	DEFINE cRuta			CHAR(200);
	DEFINE pfecha1          CHAR(4);
	DEFINE pfecha2          CHAR(4);
	--DEFINE vfecha_oper	    DATE;
	
---------------------------
--Inicializando variables--
---------------------------
	--SET DEBUG FILE TO "/informix/ireb/sp_depura_tbl_bpi_bitacora_total.out"; --Se genera log en un archivo .out
	--TRACE ON;
	
		LET error_info		= '';
		LET vcodret1        = '00000';
		LET vcodret2        = '00000';
		LET sql_err	        = 0;
		LET isam_err        = 0;
		LET vcontador1      = 0;
		LET vcontador2      = 0;
		LET vcomienza       = -1;
		LET vabierto        = 0;
		LET vrow			= 0;
		LET vrownew			= 0;
		LET cRuta 			= '/respaldos/bpi/';
		LET vtbl			= '';
		

	/*Incia SP*/
	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		IF sql_err <> 0 THEN
			LET vcodret1 = sql_err;
			LET vcodret2 = isam_err;
			LET error_info = error_info;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;

	LET pfecha1	= TO_CHAR (pfechaini,'%Y');
	LET pfecha2	= TO_CHAR (pfechafin,'%Y');
	
	IF pfecha1 = pfecha2 THEN
	
		--OBTIENE REGISTROS
		SELECT COUNT(*) INTO vrow FROM bdibpi:bpi_bitacora WHERE fecha_oper::DATE BETWEEN pfechaini AND pfechafin;
		
		--VALIDACION DE LA TABLA
		LET vtable = 'bpi_bitacorahis'||pfecha1;
		SELECT tabname INTO vtbl FROM sysmaster:systabnames WHERE dbsname = 'bdibpi' and tabname = vtable;
		
		IF vtbl IS NULL  THEN

			--CREA TABLA
			LET vsql="";
			LET vsql = 'echo "CREATE TABLE bdibpi:bpi_bitacorahis'|| pfecha1 ||' (fecha_oper  DATETIME YEAR to SECOND DEFAULT CURRENT YEAR to SECOND, id_operacion CHAR(4), sucursal CHAR(4), id_usuario INTEGER, ipusuario CHAR(15), fecha_aplic DATE, cuenta_origen CHAR(12), destino CHAR(18), monto_oper DECIMAL(14,2),sec_transaccion CHAR(16), cgenerico1 CHAR(100), cgenerico2 CHAR(100), cgenerico3 CHAR(200), cgenerico4 CHAR(40), cgenerico5 CHAR(60), cgenerico6 CHAR(100), referencia CHAR(100), folio CHAR(16));'||
			' CREATE INDEX informix.fechacuenta_'|| pfecha1 ||' ON bdibpi:bpi_bitacorahis'|| pfecha1 ||'(fecha_aplic, cuenta_origen);'||
			' CREATE INDEX informix.fechaid_'|| pfecha1 ||' ON bdibpi:bpi_bitacorahis'|| pfecha1 ||'(fecha_oper, id_operacion);'||
			' CREATE INDEX informix.idfecha_'|| pfecha1 ||' ON bdibpi:bpi_bitacorahis'|| pfecha1 ||'(id_operacion, fecha_aplic);'||
			' CREATE INDEX informix.idfechaoper_'|| pfecha1 ||' ON bdibpi:bpi_bitacorahis'|| pfecha1 ||'(fecha_oper);" > '|| SUBSTR(cRuta,1,LENGTH(cRuta)) ||'createtbl.sql';
			SYSTEM TRIM(vsql);
					
			--EJECUCIÓN DEL ARCHIVO PARA CREAR TABLA
			LET vsql = "";
			LET vsql = 'dbaccess bdibpi '|| SUBSTR(cRuta,1,LENGTH(cRuta)) ||'createtbl.sql';
			SYSTEM TRIM(vsql);

			--SE ELIMINA EL ARCHIVO ARCHIVO PARA CREAR TABLA
			LET vsql = "";
			LET vsql = 'rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'createtbl.sql';
			SYSTEM TRIM(vsql);
				
			LET vcodret1 = '00000';
			LET error_info = 'FUE CREADA LA TABLA' ;
		ELSE		
		
			LET vcodret1 = '00001';
			LET error_info = 'ERROR AL CREAR TABLA' ;
		
		END IF;
		
		IF vrow > 0 THEN
			
			--INSERTA REGISTROS A LA TABLA HISTORICA			
			LET vsql="";
			LET vsql = 'echo "INSERT INTO bdibpi:bpi_bitacorahis'|| pfecha1 ||' (fecha_oper,id_operacion,sucursal,id_usuario,ipusuario,fecha_aplic,cuenta_origen,destino,monto_oper,sec_transaccion,cgenerico1,cgenerico2,cgenerico3,cgenerico4,cgenerico5,cgenerico6,referencia,folio) SELECT fecha_oper,id_operacion, sucursal,id_usuario,ipusuario,fecha_aplic,cuenta_origen,destino,monto_oper,sec_transaccion,cgenerico1,cgenerico2,cgenerico3,cgenerico4,cgenerico5,cgenerico6,referencia,folio FROM bdibpi:bpi_bitacora WHERE fecha_oper::DATE BETWEEN '''||pfechaini||''' AND '''||pfechafin||''';" > '|| SUBSTR(cRuta,1,LENGTH(cRuta)) ||'pasobitacora.sql';
			SYSTEM TRIM(vsql);
				
			--EJECUCIÓN DEL ARCHIVO PARA INSERTAR REGISTROS
			LET vsql = "";
			LET vsql = 'dbaccess bdibpi '|| SUBSTR(cRuta,1,LENGTH(cRuta)) ||'pasobitacora.sql';
			SYSTEM TRIM(vsql);
		
			--SE ELIMINA EL ARCHIVO 
			LET vsql = "";
			LET vsql = 'rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'pasobitacora.sql';
			SYSTEM TRIM(vsql);
		
		
			--ELIMINA REGISTROS DE LA TABLA si_cambiostcte 
			FOREACH cursor_borra WITH HOLD FOR
				SELECT fecha_oper
				  INTO vfecha_oper 
				  FROM bdibpi:bpi_bitacora
				 WHERE fecha_oper::DATE BETWEEN pfechaini AND pfechafin

				IF vcomienza = -1 THEN
					LET vcomienza = 0;
					BEGIN WORK;
					LET vabierto = 1;
				END IF;

				DELETE FROM bdibpi:bpi_bitacora 
				 WHERE CURRENT OF cursor_borra;

				LET vcontador1 = vcontador1 + 1;
				LET vcontador2 = vcontador2 + 1;

				IF vcontador2 >= 1000 THEN
					LET vcontador2 = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
			END FOREACH;	
			
			IF vabierto = 1 THEN
				COMMIT WORK;
			END IF;
		
			LET vcodret1 = '00000';
			LET error_info	= 'FINALIZO CON EXITO, DEPURANDO '||vrow||' REGISTROS';
				
		ELSE 
				
			LET vcodret1 = '00002';
			LET error_info = 'NO EXISTEN REGISTROS' ;
					
		END IF;
	ELSE
		
		LET vcodret1 = '00003';
		LET error_info = 'NO SE PUEDE DEPURAR CON LAS FECHAS ESTABLECIDAS' ;
	
	END IF;
	
		RETURN vcodret1, vcontador1, error_info;	
	END;
END PROCEDURE
;