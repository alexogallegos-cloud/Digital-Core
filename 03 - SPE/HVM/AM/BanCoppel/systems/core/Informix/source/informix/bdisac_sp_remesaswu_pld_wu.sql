CREATE PROCEDURE "informix".sp_remesaswu_pld_wu(NombreProceso CHAR(3),FechaIni DATE, FechaFin DATE)
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;
    DEFINE iSqlErr             		INTEGER;
    DEFINE iIsamErr                 INTEGER;
    DEFINE cInfoErr            		CHAR(100);
	DEFINE cCodRet			        CHAR(5);
	DEFINE cMensaje					CHAR(80);
	DEFINE cStatus					CHAR(1);
	DEFINE dFecha_remesa            DATE;
    DEFINE cTipo_remesa            	CHAR(3);
    DEFINE cAbono_cuenta            CHAR(2);
    DEFINE cNum_confirmacion        CHAR(20);
    DEFINE mMonto_total             MONEY;
    DEFINE mMonto_dolares           MONEY; 
    DEFINE cTransaccion            	CHAR(4);
    DEFINE cFolio_sucursal          CHAR(16);
    DEFINE dFecha_alta           	DATE;
    DEFINE cBeneficiario_nombre1    CHAR(30);
    DEFINE cBeneficiario_nombre2    CHAR(30);
    DEFINE cBeneficiario_appaterno  CHAR(30);
    DEFINE cBeneficiario_apmaterno 	CHAR(30);
    DEFINE dBeneficiario_fecha_nac  DATE;
    DEFINE cBeneficiario_estado     CHAR(50);
    DEFINE cBeneficiario_mncpo_del  CHAR(50);
    DEFINE cBeneficiario_ciudad		CHAR(50);
    DEFINE cBeneficiario_direccion	CHAR(100);
	DEFINE cBeneficiario_colonia	CHAR(80);
	DEFINE cBeneficiario_calle		CHAR(50);
	DEFINE cBeneficiario_num_ext	CHAR(5);
	DEFINE cBeneficiario_num_int	CHAR(5);
	DEFINE cBeneficiario_depto		CHAR(10);
	DEFINE cBeneficiario_cp			CHAR(9);
	DEFINE cOrdenante_nombre1		CHAR(40);
	DEFINE cOrdenante_nombre2		CHAR(40);
	DEFINE cOrdenante_appaterno		CHAR(40);
	DEFINE cOrdenante_apmaterno		CHAR(40);
	DEFINE cOrdenante_direccion		CHAR(100);
	DEFINE cSucursal				CHAR(4);
	DEFINE cUsuario					CHAR(8);
	DEFINE dFecha_Proceso			DATE;	
	DEFINE cFechaFor          		CHAR(8);
	DEFINE cReferencia1				CHAR(40);
	DEFINE dFecha_Pago         		DATE;
	DEFINE mImporte_Pago			MONEY;
	DEFINE vPt_Mtcn					VARCHAR(16);
	DEFINE dSecuencia				DATETIME YEAR to SECOND;
	DEFINE dFechain					DATETIME YEAR to SECOND;
	DEFINE iCuantosCheq				INTEGER;
	DEFINE iCuantosMovtos			INTEGER;
	DEFINE iCuantosSearch			INTEGER;
	DEFINE iCuantosPay				INTEGER;
	DEFINE dHora_proceso 			DATETIME HOUR to FRACTION(3);
	DEFINE cMoney_transfer_key		CHAR(10);
	DEFINE cForeign_rs_refnum_rq	CHAR(16);
	DEFINE sCont					SMALLINT;
	
	DEFINE cHora_remesa				CHAR(8);
	DEFINE cColonia_ordenante		CHAR(100);
	DEFINE cCiudad_id_ordenante		CHAR(40);
	DEFINE cOcupacion_beneficiario	CHAR(30);
	DEFINE cName_benef_suc			CHAR(120);
	DEFINE cNum_id_benef_suc		CHAR(30);
	DEFINE dFecha_envio_remesa		DATE;
	
	DEFINE cCod_pais_origen			CHAR(3);
	DEFINE cCod_moneda_origen		CHAR(3);
	DEFINE cCod_pais_destino        CHAR(3);
	DEFINE cCod_moneda_destino      CHAR(3);
	DEFINE cTipo_cambio             CHAR(21);	
	DEFINE cTp_id_benef             CHAR(3);
	DEFINE cNum_id_benef            CHAR(20);
	DEFINE cCod_pais_benef          CHAR(3);
	DEFINE cCp_benef                CHAR(10);
	DEFINE cTel_benef               CHAR(15);				
	DEFINE cCd_remitente            CHAR(40);
	DEFINE cCod_edo_remitente       CHAR(3);	
	DEFINE cCod_pais_remitente      CHAR(3);
	DEFINE cCp_remitente            CHAR(10);
	DEFINE cTel_remitente           CHAR(15);	
	DEFINE cReceiver_firstname    	CHAR(30);
    DEFINE cReceiver_given_name   	CHAR(30);
    DEFINE cReceiver_middlename  	CHAR(30);
    DEFINE cReceiver_last_name 		CHAR(30);
	DEFINE cReceiver_paternalname  	CHAR(30);
    DEFINE cReceiver_maternalname 	CHAR(30);
	
	--SET DEBUG FILE TO  '/INFORMIXTMP/HMLG/EXEC_sp_remesaswu_pld_wu.out';
	--TRACE ON;	
				
	LET cCodRet  					= "00000";
	LET cMensaje 					= 'PROCESO EXITOSO';	
	LET cStatus						= '0';	
	LET dFecha_remesa               = mdy(01,01,1900);	
	LET cTipo_remesa              	= '';
    LET cAbono_cuenta               = '';
    LET cNum_confirmacion         	= '';
    LET mMonto_total                = 0;
    LET mMonto_dolares           	= 0;
    LET cTransaccion            	= '';
    LET cFolio_sucursal             = '';
    LET dFecha_alta           		= mdy(01,01,1900);
    LET cBeneficiario_nombre1      	= '';
    LET cBeneficiario_nombre2       = '';
    LET cBeneficiario_appaterno     = '';
    LET cBeneficiario_apmaterno 	= '';
    LET dBeneficiario_fecha_nac   	= '';
    LET cBeneficiario_estado      	= '';
    LET cBeneficiario_mncpo_del    	= '';
    LET cBeneficiario_ciudad		= '';
    LET cBeneficiario_direccion		= '';
	LET cBeneficiario_colonia		= '';
	LET cBeneficiario_calle			= '';
	LET cBeneficiario_num_ext		= '';
	LET cBeneficiario_num_int		= '';
	LET cBeneficiario_depto			= '';
	LET cBeneficiario_cp			= '';
	LET cOrdenante_nombre1			= '';
	LET cOrdenante_nombre2			= '';
	LET cOrdenante_appaterno		= '';
	LET cOrdenante_apmaterno		= '';
	LET cOrdenante_direccion		= '';
	LET cSucursal					= '';
	LET cUsuario					= '';
	LET dFecha_Proceso				= FechaFin;	
	LET cFechaFor          			= '';
	LET cReferencia1				= '';
	LET dFecha_Pago         		= mdy(01,01,1900);
	LET mImporte_Pago				= 0;
	LET vPt_Mtcn					= '';
	LET dSecuencia					= '';
	LET dFechain					= '';
	LET iCuantosCheq				= 0;
	LET iCuantosMovtos				= 0;
	LET iCuantosSearch				= 0;
	LET iCuantosPay					= 0;
	LET dHora_proceso 				= '';
	LET cMoney_transfer_key			= '';
	LET cForeign_rs_refnum_rq		= '';
	LET sCont						 = 0;
	
	LET cHora_remesa				= '';
	LET cColonia_ordenante			= '';
	LET cCiudad_id_ordenante		= '';
	LET cOcupacion_beneficiario		= '';	
	LET cName_benef_suc				= '';
	LET cNum_id_benef_suc			= '';
	LET dFecha_envio_remesa			= mdy(01,01,1900);
	
	LET cCod_pais_origen			= '';
	LET cCod_moneda_origen			= '';
	LET cCod_pais_destino       	= '';
	LET cCod_moneda_destino     	= '';
	LET cTipo_cambio            	= '0';	
	LET cTp_id_benef            	= '';
	LET cNum_id_benef           	= '';	
	LET cCod_pais_benef         	= '';
	LET cCp_benef               	= '';
	LET cTel_benef              	= '';
	LET cCd_remitente           	= '';	
	LET cCod_edo_remitente      	= '';
	LET cCod_pais_remitente     	= '';
	LET cCp_remitente           	= '';
	LET cTel_remitente          	= '';
	LET cReceiver_firstname      	= '';
    LET cReceiver_given_name        = '';
    LET cReceiver_middlename        = '';
    LET cReceiver_last_name 		= '';
	LET cReceiver_paternalname     	= '';
    LET cReceiver_maternalname      = '';


    --SET DEBUG FILE TO  '/ifxsif01/yoselin/job/sp_wu.out';
	--TRACE ON;	
		
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_remesaswu_pld_wu" || "Remesa:" || cNum_confirmacion);
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION
		
		ON EXCEPTION IN (-535)	
			IF sCont > 0 THEN 
				COMMIT WORK;							
			END IF;	
		END EXCEPTION WITH RESUME;
		
		IF NombreProceso = "" OR FechaIni = "" OR FechaFin = "" THEN
			LET cCodRet = '00001';
			LET cMensaje = "FALTAN PARAMETROS DE ENTRADA";
            RETURN cCodRet, cMensaje;
		ELSE
			set isolation to dirty read;
			SET LOCK MODE TO WAIT 3;
			BEGIN WORK;
			FOREACH WITH HOLD
				--select {+AVOID_FULL(bdicheq:"informix".sc_movhis )}
				select NVL(folio_suc,''),NVL(fech_alt,mdy(01,01,1900)),NVL(transacc_suc,''),NVL(sucursal,''),NVL(usuario,''),NVL(monto_tot,0), NVL(substr(fech_hor,1,8),'')
				into cFolio_sucursal,dFecha_alta,cTransaccion,cSucursal,cUsuario,mMonto_total, cHora_remesa
				 from bdicheq:"informix".sc_movhis
				where empresa = '001'
				  and transacc in ('1151','1121','1552','1381')
				  and fech_alt >= FechaIni
				  and fech_alt <= FechaFin
				  and cancelad <> 'S'					  
				  INSERT INTO "informix".sac_cheques_wu (folio_suc,fech_alt,transacc_suc,sucursal, usua, monto_tot, hora_remesa)
				  VALUES(cFolio_sucursal, dFecha_alta, cTransaccion, cSucursal, cUsuario, mMonto_total,cHora_remesa);
				  
				  LET sCont = sCont + 1;						
					IF sCont = 500 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;	
				  
			END FOREACH;		

			IF sCont < 500 and sCont >= 0 THEN
				COMMIT WORK;
				LET sCont = 0;			
			END IF;
			
			SELECT count(*)
			INTO iCuantosCheq
			FROM "informix".sac_cheques_wu;
			
			BEGIN WORK;
			FOREACH WITH HOLD
				--select {+INDEX("informix".sac_cheques_wu idxsac_cheques_wuff)} NVL(referencia1,''),NVL(a.folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(importe_pago,0),NVL(usuario,''),NVL(id_sucursal,''), NVL(b.transacc_suc,''), NVL(hora_remesa,'')
				select NVL(referencia1,''),NVL(a.folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(importe_pago,0),NVL(usuario,''),NVL(id_sucursal,''), NVL(b.transacc_suc,''), NVL(hora_remesa,'')
				into cReferencia1,cFolio_sucursal,dFecha_Pago,mImporte_Pago,cUsuario,cSucursal,cTransaccion,cHora_remesa
				  from "informix".sac_movimientoshistorial a, "informix".sac_cheques_wu b
				 where fecha_pago >= FechaIni
				   and fecha_pago <= FechaFin
				   and numcategoria = '07'
				   and numconvenio = '006'
				   and status_cancelado <> 'S'
				   and a.folio_suc = b.folio_suc
				   and b.fech_alt = a.fecha_pago
				   and a.id_sucursal = b.sucursal
				   and a.usuario = b.usua
				   and a.importe_pago = b.monto_tot				
				INSERT INTO "informix".sac_servicios_wu (referencia1,folio_suc,fecha_pago,importe_pago,usuario,id_sucursal,transacc_suc,hora_remesa)
				  VALUES(cReferencia1,cFolio_sucursal,dFecha_Pago,mImporte_Pago,cUsuario,cSucursal,cTransaccion,cHora_remesa);	

				   LET sCont = sCont + 1;						
					IF sCont = 500 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;	
				  
			END FOREACH;	

			IF sCont < 500 and sCont >= 0 THEN
				COMMIT WORK;
				LET sCont = 0;			
			END IF;
			
			SELECT count(*)
			INTO iCuantosMovtos
			FROM "informix".sac_servicios_wu;				
			
			BEGIN WORK;
			FOREACH WITH HOLD
				select NVL(mtcn,''),max(fecha_insert) secuencia, money_transfer_key,foreign_rs_refnum_rp
				into vPt_Mtcn, dSecuencia, cMoney_transfer_key,cForeign_rs_refnum_rq
				 from "informix".sac_wu_pay
				 where fecha_insert::date >= FechaIni
				   and fecha_insert::date <= FechaFin
				   --and mtcn in (select {+INDEX("informix".sac_servicios_wu idxsac_servicios_wur1)} referencia1 from "informix".sac_servicios_wu)
				   and mtcn in (select referencia1 from "informix".sac_servicios_wu)
				 group by mtcn, money_transfer_key,foreign_rs_refnum_rp
				INSERT INTO "informix".sac_secuencias_pay (mtcn, secuencia, money_transfer_key,Foreign_rs_refnum_rq)
				  VALUES(vPt_Mtcn, dSecuencia, cMoney_transfer_key,cForeign_rs_refnum_rq);
				  
				  LET sCont = sCont + 1;						
					IF sCont = 500 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;
					
				  
			END FOREACH;
			
			IF sCont < 500 and sCont >= 0 THEN
				COMMIT WORK;
				LET sCont = 0;
			END IF;
			
			BEGIN WORK;
			FOREACH WITH HOLD		
			--select {+INDEX("informix".sac_secuencias_pay idxsac_secuencias_paysm)} NVL(a.mtcn,''),NVL(a.benef_nombre1,''),NVL(a.benef_nombre2,''),NVL(a.benef_appaterno,''),NVL(a.benef_apmaterno,''),
			select NVL(a.mtcn,''),NVL(a.benef_nombre1,''),NVL(a.benef_nombre2,''),NVL(a.benef_appaterno,''),NVL(a.benef_apmaterno,''),
				   NVL(a.benef_fecha_nac,''),NVL(a.benef_edo,''),NVL(a.benef_col_del_mncpo,''),NVL(a.benef_ciudad,''),'',NVL(a.benef_col_del_mncpo,''),NVL(a.benef_calle_num,''),NVL(a.benef_calle_num,''),
				   '','',NVL(a.benef_cp,''), NVL(a.money_transfer_key,''), NVL(a.foreign_rs_refnum_rp,''), NVL(a.benef_ocupacion,''),
				   NVL(a.benef_nombre1,'') || " " || NVL(a.benef_nombre2,'') || " " || NVL(a.benef_appaterno,'') || " " || NVL(a.benef_apmaterno,''),NVL(a.benef_id_number,''),
				   NVL(a.benef_id_type,''),NVL(a.benef_id_number,''),NVL(a.benef_pais,''),NVL(a.benef_cp,''),NVL(a.benef_tel_particular,'')
				   into vPt_Mtcn,cBeneficiario_nombre1,cBeneficiario_nombre2,cBeneficiario_appaterno,cBeneficiario_apmaterno,cFechaFor,
					cBeneficiario_estado,cBeneficiario_mncpo_del,cBeneficiario_ciudad,cBeneficiario_direccion,cBeneficiario_colonia,
					cBeneficiario_calle,cBeneficiario_num_ext,cBeneficiario_num_int,cBeneficiario_depto,cBeneficiario_cp, cMoney_transfer_key, cForeign_rs_refnum_rq,
					cOcupacion_beneficiario, cName_benef_suc, cNum_id_benef_suc,
					cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef
			  from "informix".sac_wu_pay a,"informix".sac_secuencias_pay b
			 where a.fecha_insert::date >= FechaIni
			   and a.fecha_insert::date <= FechaFin
			   and a.fecha_insert = b.secuencia
			   and a.mtcn = b.mtcn
			   and a.money_transfer_key = b.money_transfer_key
			   and a.mtcn in (select NVL(referencia1,'') from "informix".sac_servicios_wu)
               --and a.mtcn in (select {+INDEX("informix".sac_servicios_wu idxsac_servicios_wur1)} NVL(referencia1,'') from "informix".sac_servicios_wu)			   
			 	   
			INSERT INTO "informix".sac_datos_pay_wu (mtcn,beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno, 
					beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,beneficiario_ciudad,
					beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int, 
					beneficiario_depto,beneficiario_cp,money_transfer_key,foreign_rs_refnum_rq,ocupacion_beneficiario,name_benef_suc,num_id_benef_suc,
					tp_id_benef,num_id_benef,cod_pais_benef,cp_benef,tel_benef)
				  VALUES(vPt_Mtcn,cBeneficiario_nombre1,cBeneficiario_nombre2,cBeneficiario_appaterno,cBeneficiario_apmaterno,cFechaFor,
					cBeneficiario_estado,cBeneficiario_mncpo_del,cBeneficiario_ciudad,cBeneficiario_direccion,cBeneficiario_colonia,
					cBeneficiario_calle,cBeneficiario_num_ext,cBeneficiario_num_int,cBeneficiario_depto,cBeneficiario_cp,cMoney_transfer_key,cForeign_rs_refnum_rq,
					cOcupacion_beneficiario,cName_benef_suc,cNum_id_benef_suc,cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef);
					
					LET sCont = sCont + 1;						
					IF sCont = 500 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;
					
			END FOREACH;

			IF sCont < 500 and sCont >= 0 THEN
				COMMIT WORK;
				LET sCont = 0;			
			END IF;
			
			SELECT count(*)
			INTO iCuantosPay
			FROM "informix".sac_datos_pay_wu;
			
			--delete {+INDEX(bdisac:"informix".sac_secuencia_search_wu idxsac_secuencia_searchps_wu)} from "informix".sac_secuencia_search_wu;
			delete from "informix".sac_secuencia_search_wu;
			
 			FOREACH WITH HOLD	
				--select {+AVOID_FULL(bdisac:"informix".sac_wu_search )} NVL(a.mtcn,'') pt_mtcn,
                select NVL(a.mtcn,'') pt_mtcn,				
				MAX(a.fecha_insert) AS fechahorainsercion
				into vPt_Mtcn,dFechain
				 from bdisac:"informix".sac_wu_search a, bdisac:"informix".sac_datos_pay_wu b
				 where a.fecha_insert::date >= FechaIni
				   and a.fecha_insert::date <= FechaFin
				   --and a.mtcn in (select {+AVOID_FULL("informix".sac_servicios_wu )} referencia1 from "informix".sac_servicios_wu)
				   and a.mtcn in (select referencia1 from "informix".sac_servicios_wu)
				   and a.retcode='00000'
				   and a.mtcn = b.mtcn
				   and a.money_transfer_key = b.money_transfer_key
				   GROUP BY a.mtcn
				 INSERT INTO "informix".sac_secuencia_search_wu (Pt_Mtcn,fechahorainsercion)  VALUES(vPt_Mtcn,dFechain);
			
			END FOREACH;
			
			BEGIN WORK;
			FOREACH WITH HOLD
				--select {+INDEX("informix".sac_secuencia_search_wu idxsac_secuencia_searchps_wu)} NVL(a.mtcn,''),
				select NVL(a.mtcn,''),
					   CASE WHEN length(a.monto_total_destino) = 0 THEN NVL(((DECODE(a.monto_total_destino,'', '0', NULL, '0', a.monto_total_destino)::INTEGER)/100)::MONEY,0)
					   ELSE NVL(((DECODE(a.monto_total_destino,'', '0', NULL, '0', a.monto_total_destino)::INTEGER)/100)::MONEY,0) END,
					   CASE WHEN a.emisor_cod_pais = 'US' THEN NVL(((DECODE(a.monto_origen,'', '0', NULL, '0', monto_origen)::INTEGER)/100)::MONEY,0) ELSE 0 END,
					   Case when length(a.emisor_nombre1) = 0 then NVL(a.emisor_nombre2,'') else NVL(a.emisor_nombre1,'') end,
					   Case when length(a.emisor_nombre2) = 0 then '' else NVL(a.emisor_nombre2,'') end,
					   Case when length(a.emisor_appaterno) = 0 then NVL(a.emisor_appaterno,'') else NVL(a.emisor_appaterno,'') end,
					   NVL(a.emisor_apmaterno,''),
					   NVL(a.emisor_ciudad,'') || ', ' || NVL(a.emisor_cod_pais,'') || ', ' || NVL(a.emisor_calle,'') || ' , C.P.' || NVL(emisor_cp,'') ordenante_direccion,
					   Case when length(a.benef_nombre1) = 0 then NVL(a.benef_nombre1,'') else NVL(a.benef_nombre1,'') end,NVL(a.benef_nombre2,''),
					   Case when length (a.benef_appaterno) = 0 then NVL(a.benef_appaterno,'') else NVL(a.benef_appaterno,'') end,
					   NVL(a.benef_apmaterno,''),NVL(a.benef_edo,''),NVL(a.benef_ciudad,''),NVL(a.benef_ciudad,''),NVL(a.benef_calle,''), NVL(a.money_transfer_key,''), NVL(a.emisor_calle,''),
					   a.fecha_alta_remesa::date,NVL(a.emisor_cod_pais,''),NVL(a.emisor_cod_moneda,''),NVL(a.benef_cod_pais,''),NVL(a.benef_cod_moneda,''),
					   NVL(a.tipo_cambio,''),NVL(a.emisor_ciudad,''),NVL(a.emisor_edo,''),NVL(a.emisor_cod_pais,''),
					   NVL(a.emisor_cp,''),NVL(a.emisor_cod_pais,'')
					   into vPt_Mtcn,mMonto_total,mMonto_dolares,cOrdenante_nombre1,cOrdenante_nombre2,cOrdenante_appaterno, 
						cOrdenante_apmaterno,cOrdenante_direccion,cBeneficiario_nombre1,cBeneficiario_nombre2,cBeneficiario_appaterno,cBeneficiario_apmaterno,
						cBeneficiario_estado,cBeneficiario_mncpo_del,cBeneficiario_ciudad,cBeneficiario_calle, cMoney_transfer_key, cColonia_ordenante,dFecha_envio_remesa,
						cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,
						cCp_remitente,cTel_remitente
				from bdisac:"informix".sac_wu_search a,"informix".sac_secuencia_search_wu b
				where a.mtcn = b.pt_mtcn
				  and a.fecha_insert = b.fechahorainsercion
				  and a.fecha_insert::date >= FechaIni
				  and a.fecha_insert::date <= FechaFin					  
				  INSERT INTO "informix".sac_datos_search (pt_mtcn,monto_total,monto_dolares,ordenante_nombre1,
					ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,beneficiario_nombre1, beneficiario_nombre2,
					beneficiario_appaterno,beneficiario_apmaterno,beneficiario_estado,beneficiario_mncpo_del,beneficiario_ciudad,beneficiario_calle, money_transfer_key,
					colonia_ordenante,fecha_envio_remesa,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,cd_remitente,cod_edo_remitente,cod_pais_remitente,
						cp_remitente,tel_remitente)
				  VALUES(vPt_Mtcn,mMonto_total,mMonto_dolares,cOrdenante_nombre1,cOrdenante_nombre2,cOrdenante_appaterno, 
				  cOrdenante_apmaterno,cOrdenante_direccion,cBeneficiario_nombre1,cBeneficiario_nombre2,cBeneficiario_appaterno,cBeneficiario_apmaterno,
				  cBeneficiario_estado,cBeneficiario_mncpo_del,cBeneficiario_ciudad,cBeneficiario_calle, cMoney_transfer_key, cColonia_ordenante,dFecha_envio_remesa,
				  cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,
				  cCp_remitente,cTel_remitente);
				  
				  -->
				  
				  LET sCont = sCont + 1;						
					IF sCont = 500 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;
				  
			END FOREACH;	

			IF sCont < 500 and sCont >= 0 THEN
				COMMIT WORK;
				LET sCont = 0;			
			END IF;	
			
			SELECT count(*)
			INTO iCuantosSearch
			FROM "informix".sac_datos_search;
			
			--DROP TABLE tmpsac_secuencia_search;
			BEGIN WORK;
			FOREACH WITH HOLD
				--select {+INDEX("informix".sac_servicios_wu idxsac_servicios_wur1)} NVL(fecha_pago,mdy(01,01,1900)),'WUN','NO',NVL(referencia1,''),NVL(importe_pago,0),NVL(monto_dolares,0),NVL(transacc_suc,''),
				select NVL(fecha_pago,mdy(01,01,1900)),'WUN','NO',NVL(referencia1,''),NVL(importe_pago,0),NVL(monto_dolares,0),NVL(transacc_suc,''),
					   NVL(folio_suc,''),TODAY,NVL(c.beneficiario_nombre1,''),NVL(c.beneficiario_nombre2,''),NVL(c.beneficiario_appaterno,''),NVL(c.beneficiario_apmaterno,''),NVL(beneficiario_fecha_nac,'01011900'),
					   NVL(c.beneficiario_estado,''),NVL(c.beneficiario_mncpo_del,''),NVL(c.beneficiario_ciudad,''),NVL(beneficiario_direccion,''),NVL(beneficiario_colonia,''),NVL(c.beneficiario_calle,''),NVL(beneficiario_num_ext,''),
					   NVL(beneficiario_num_int,''),NVL(beneficiario_depto,''),NVL(beneficiario_cp,''),NVL(ordenante_nombre1,''),NVL(ordenante_nombre2,''),
						NVL(ordenante_appaterno,''),NVL(ordenante_apmaterno,''),NVL(ordenante_direccion,''),NVL(id_sucursal,''),NVL(usuario,''),NVL(hora_remesa,''), NVL(colonia_ordenante,''),
						NVL(ciudad_id_ordenante,''), NVL(ocupacion_beneficiario,''), NVL(name_benef_suc,''), NVL(num_id_benef_suc,''), fecha_envio_remesa,
						cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,cd_remitente,cod_edo_remitente,cod_pais_remitente,
						cp_remitente,tel_remitente,tp_id_benef,num_id_benef,cod_pais_benef,cp_benef,tel_benef						
				INTO dFecha_remesa,cTipo_remesa,cAbono_cuenta,cNum_confirmacion,mMonto_total,mMonto_dolares,cTransaccion,cFolio_sucursal,dFecha_alta, 
					cBeneficiario_nombre1,cBeneficiario_nombre2,cBeneficiario_appaterno,cBeneficiario_apmaterno,cFechaFor,cBeneficiario_estado, 
					cBeneficiario_mncpo_del,cBeneficiario_ciudad,cBeneficiario_direccion,cBeneficiario_colonia,cBeneficiario_calle,cBeneficiario_num_ext, 
					cBeneficiario_num_int,cBeneficiario_depto,cBeneficiario_cp,cOrdenante_nombre1,cOrdenante_nombre2,cOrdenante_appaterno,cOrdenante_apmaterno, 
					cOrdenante_direccion,cSucursal,cUsuario,cHora_remesa,cColonia_ordenante,cCiudad_id_ordenante, cOcupacion_beneficiario, cName_benef_suc,
					cNum_id_benef_suc, dFecha_envio_remesa,cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,
					cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente,cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef
				 from "informix".sac_servicios_wu a,"informix".sac_datos_search b,"informix".sac_datos_pay_wu c
				  where a.referencia1 = b.pt_mtcn
                  and a.referencia1 = c.mtcn
                  and a.folio_suc = c.foreign_rs_refnum_rq
				  and b.pt_mtcn = c.mtcn
				  and b.money_transfer_key = c.money_transfer_key
				  LET dBeneficiario_fecha_nac = MDY(SUBSTR(cFechaFor,3,2),SUBSTR(cFechaFor,1,2),SUBSTR(cFechaFor,5,4));					  
				  LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);
				  INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
						beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
						beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
						beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
						fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
						numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
						tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
						cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,
						ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,num_id_benef_suc,fecha_envio_remesa)
				  VALUES(dFecha_remesa,cTipo_remesa,cAbono_cuenta,cNum_confirmacion,mMonto_total,mMonto_dolares,cTransaccion,cFolio_sucursal,dFecha_alta, 
					cBeneficiario_nombre1,cBeneficiario_nombre2,cBeneficiario_appaterno,cBeneficiario_apmaterno,dBeneficiario_fecha_nac,cBeneficiario_estado, 
					cBeneficiario_mncpo_del,cBeneficiario_ciudad,cBeneficiario_direccion,cBeneficiario_colonia,cBeneficiario_calle,cBeneficiario_num_ext, cBeneficiario_num_int,
					cBeneficiario_depto,cBeneficiario_cp,cOrdenante_nombre1,cOrdenante_nombre2,cOrdenante_appaterno,cOrdenante_apmaterno,cOrdenante_direccion, cSucursal,
					cUsuario,dFecha_Proceso,
					mdy(01,01,1900),'','','','',cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,'','','','',cTp_id_benef,cNum_id_benef,'',cCod_pais_benef,cCp_benef,cTel_benef,
					'','','','','',cCd_remitente,'',cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente,'',dHora_proceso, cHora_remesa,cColonia_ordenante,'',cCiudad_id_ordenante,
					cOcupacion_beneficiario,cName_benef_suc,cNum_id_benef_suc,dFecha_envio_remesa);
					
					LET sCont = sCont + 1;						
					IF sCont = 500 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;
					
			END FOREACH;
			
			IF sCont < 500 and sCont >= 0 THEN
				COMMIT WORK;
				LET sCont = 0;			
			END IF;
			IF iCuantosCheq <> iCuantosMovtos THEN
				BEGIN WORK;
				FOREACH WITH HOLD						
					--select {+INDEX("informix".sac_cheques_wu idxsac_cheques_wuff)} 
					select NVL(folio_suc,''),NVL(fech_alt,mdy(01,01,1900)),NVL(transacc_suc,''),NVL(sucursal,''),NVL(usua,''),NVL(monto_tot,0), NVL(hora_remesa,'')
					into cFolio_Sucursal,dFecha_alta,cTransaccion,cSucursal,cUsuario,mMonto_total,cHora_remesa
					from "informix".sac_cheques_wu 
					--where folio_suc not in (select {+INDEX("informix".sac_servicios_wu idxsac_servicios_wur1)} folio_suc from "informix".sac_servicios_wu)
                    where folio_suc not in (select folio_suc from "informix".sac_servicios_wu)					
					LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);
					INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
						beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
						beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
						beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
						fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
						numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
						tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,
						cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
						hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
						num_id_benef_suc,fecha_envio_remesa)
					VALUES(dFecha_alta,'WUN','NO','',mMonto_total,0,cTransaccion,cFolio_sucursal,(today), 
						'','','','',mdy(01,01,1900),'','','','','','','','','','','','','','','',cSucursal,cUsuario,dFecha_Proceso,
						mdy(01,01,1900),'','','','','','','','','0','','','','','','','','','','','','','','','','','','','','','','',
						dHora_proceso,cHora_remesa,cColonia_ordenante,'',cCiudad_id_ordenante,'','','',dFecha_envio_remesa);										
						
					LET sCont = sCont + 1;						
					IF sCont = 500 THEN
						COMMIT WORK;
						LET sCont = 0;
						BEGIN WORK;
					END IF;
						
				END FOREACH;	

					IF sCont < 500 and sCont >= 0 THEN
						COMMIT WORK;
						LET sCont = 0;			
					END IF;
					
				
				ELSE IF (iCuantosPay <> iCuantosMovtos) AND (iCuantosSearch <> iCuantosMovtos) THEN	

					BEGIN WORK;
					FOREACH WITH HOLD						
						--select {+INDEX("informix".sac_servicios_wu idxsac_servicios_wur1)} 
						select NVL(referencia1,''),NVL(folio_suc,''),NVL(fecha_pago,mdy(01,01,1900)),NVL(usuario,''),NVL(id_sucursal,''),NVL(transacc_suc,''),NVL(hora_remesa,'')
						into cReferencia1, cFolio_Sucursal, dFecha_alta, cUsuario, cSucursal, cTransaccion, cHora_remesa
						from "informix".sac_servicios_wu 
						where referencia1 not in (select {+INDEX("informix".sac_datos_pay_wu idxsac_datos_pay_wum)} mtcn from "informix".sac_datos_pay_wu)
						and referencia1 not in (select {+INDEX("informix".sac_datos_search idxsac_datos_searchp)} pt_mtcn from "informix".sac_datos_search)
						--select {+INDEX("informix".sac_cheques_wu idxsac_cheques_wuff)} monto_tot
						select monto_tot
						into mMonto_total
						from "informix".sac_cheques_wu 
						where folio_suc = cFolio_Sucursal
						and fech_alt = dFecha_alta
						and transacc_suc = cTransaccion
						and sucursal = cSucursal
						and usua = cUsuario;
						LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);
						
						--select {+AVOID_FULL(bdisac:"informix".sac_wu_search )} MAX(fecha_insert)
						select MAX(fecha_insert)
						into dFechain
						 from bdisac:"informix".sac_wu_search
						 where fecha_insert::date >= FechaIni
						   and fecha_insert::date <= FechaFin 
						   and mtcn = cReferencia1
						   and retcode = '00000'
						 group by mtcn;
						 
 						--select {+AVOID_FULL(bdisac:"informix".sac_wu_search )}
						select Case when length(emisor_nombre1) = 0 then NVL(emisor_nombre1,'') else NVL(emisor_nombre1,'') end, 
						Case when length(emisor_nombre2) = 0 then '' else NVL(emisor_nombre2,'') end,
						Case when length(emisor_appaterno) = 0 then NVL(emisor_appaterno,'') else NVL(emisor_appaterno,'') end,
						Case when length(emisor_apmaterno) = 0 then '' else NVL(emisor_apmaterno,'') end,
						NVL(emisor_calle,'') || " " || NVL(emisor_ciudad,'') || " " || " C.P " || NVL(emisor_cp,''),
						NVL(emisor_calle,''), NVL(emisor_ciudad,''), fecha_alta_remesa::date,NVL(emisor_cod_pais,''),NVL(emisor_cod_moneda,''),NVL(benef_cod_pais,''),NVL(benef_cod_moneda,''),
					    NVL(tipo_cambio,''),NVL(emisor_ciudad,''),NVL(emisor_edo,''),NVL(emisor_cod_moneda,''),
					    NVL(emisor_cp,''),NVL(emisor_telefono,'')
						into cOrdenante_nombre1,cOrdenante_nombre2,cOrdenante_appaterno,cOrdenante_apmaterno,cOrdenante_direccion,cColonia_ordenante,cCiudad_id_ordenante,
						dFecha_envio_remesa,cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,cCod_edo_remitente,cCod_pais_remitente,
						cCp_remitente,cTel_remitente						
						from bdisac:"informix".sac_wu_search
						where mtcn = cReferencia1
						AND fecha_insert = dFechain;

						--select {+AVOID_FULL(bdisac:"informix".sac_wu_search )}
						select MAX(fecha_insert)
						INTO dFechain
						 from bdisac:"informix".sac_wu_search
						 where fecha_insert::date >= FechaIni
						   and fecha_insert::date <= FechaFin
						   and mtcn = cReferencia1
						 group by mtcn;					

						 -->aqui
						--select {+AVOID_FULL(bdisac:"informix".sac_wu_pay )} 
						select Case when length(benef_nombre1) = 0 then NVL(benef_nombre1,'') else NVL(benef_nombre1,'') end, 
						Case when length(benef_nombre2) = 0 then '' else NVL(benef_nombre2,'') end,
						Case when length(benef_appaterno) = 0 then NVL(benef_appaterno,'') else NVL(benef_appaterno,'') end,
						Case when length(benef_apmaterno) = 0 then '' else NVL(benef_apmaterno,'') end,
						NVL(benef_fecha_nac,''),NVL(benef_edo,''),NVL(benef_ciudad,''),
						NVL(benef_calle_num,'') || " " || NVL(benef_col_del_mncpo,'') || " C.P " || NVL(benef_cp,''),
						NVL(benef_ocupacion,''),NVL(benef_id_number,'')
						INTO cBeneficiario_nombre1,cBeneficiario_nombre2,cBeneficiario_appaterno,cBeneficiario_apmaterno,
						cFechaFor,cBeneficiario_estado,cBeneficiario_ciudad, cBeneficiario_direccion, cOcupacion_beneficiario,cNum_id_benef_suc
						FROM bdisac:"informix".sac_wu_pay
						WHERE mtcn = cReferencia1
						and fecha_insert >= FechaIni
						and fecha_insert <= FechaFin + 1 UNITS DAY
						and fecha_insert = dFechain;			
						LET dBeneficiario_fecha_nac = MDY(SUBSTR(cFechaFor,3,2),SUBSTR(cFechaFor,1,2),SUBSTR(cFechaFor,5,4));
						
						INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
						beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
						beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,beneficiario_cp,
						ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
						fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
						numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
						tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
						hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
						num_id_benef_suc,fecha_envio_remesa)
						VALUES(dFecha_alta,'WUN','NO',cReferencia1,mMonto_total,0,cTransaccion,cFolio_sucursal,(today), 
							NVL(cBeneficiario_nombre1,''),NVL(cBeneficiario_nombre2,''),NVL(cBeneficiario_appaterno,''),NVL(cBeneficiario_apmaterno,''),dBeneficiario_fecha_nac,NVL(cBeneficiario_estado,''),'',
							NVL(cBeneficiario_ciudad,''),NVL(cBeneficiario_direccion,''),'','','','','','',NVL(cOrdenante_nombre1,''),NVL(cOrdenante_nombre2,''),NVL(cOrdenante_appaterno,''),NVL(cOrdenante_apmaterno,''),
							NVL(cOrdenante_direccion,''),cSucursal,cUsuario,dFecha_Proceso,
							mdy(01,01,1900),'','','','',cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,
							'','','','','','','','','','','',
							'','','','',cCd_remitente,'',cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente,'',
							dHora_proceso,cHora_remesa,NVL(cColonia_ordenante,''),'',NVL(cCiudad_id_ordenante,''),NVL(cOcupacion_beneficiario,''),
							NVL(cBeneficiario_nombre1,'') || " " || NVL(cBeneficiario_nombre2,'') || " " || NVL(cBeneficiario_appaterno,'') || " " || NVL(cBeneficiario_apmaterno,''),
							NVL(cNum_id_benef_suc,''),dFecha_envio_remesa);										
							
						LET sCont = sCont + 1;						
						IF sCont = 500 THEN
							COMMIT WORK;
							LET sCont = 0;
							BEGIN WORK;
						END IF;
							
					END FOREACH;

						IF sCont < 500 and sCont >= 0 THEN
							COMMIT WORK;
							LET sCont = 0;			
						END IF;
					
					ELSE IF (iCuantosPay <> iCuantosMovtos) THEN
	
						BEGIN WORK;
						FOREACH WITH HOLD					
							--select {+INDEX("informix".sac_datos_search idxsac_datos_searchp)} NVL(pt_mtcn,''),NVL(monto_total,0),NVL(monto_dolares,0),NVL(ordenante_nombre1,''),
							select NVL(pt_mtcn,''),NVL(monto_total,0),NVL(monto_dolares,0),NVL(ordenante_nombre1,''),
								NVL(ordenante_nombre2,''),NVL(ordenante_appaterno,''),NVL(ordenante_apmaterno,''),NVL(ordenante_direccion,''),
								NVL(beneficiario_nombre1,''),NVL(beneficiario_nombre2,''),
								NVL(beneficiario_appaterno,''),NVL(beneficiario_apmaterno,''),NVL(beneficiario_estado,''),NVL(beneficiario_mncpo_del,''),NVL(beneficiario_ciudad,''),NVL(beneficiario_calle,''),
								b.referencia1,b.folio_suc,b.fecha_pago,b.usuario,b.id_sucursal,b.transacc_suc, NVL(b.hora_remesa,''), NVL(colonia_ordenante,''), NVL(ciudad_id_ordenante,''),
								fecha_envio_remesa,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,cd_remitente,cod_edo_remitente,cod_pais_remitente,
								cp_remitente,tel_remitente
							into vPt_Mtcn,mMonto_total,mMonto_dolares,cOrdenante_nombre1,cOrdenante_nombre2,cOrdenante_appaterno, 
								cOrdenante_apmaterno,cOrdenante_direccion,cBeneficiario_nombre1,cBeneficiario_nombre2,cBeneficiario_appaterno,cBeneficiario_apmaterno,
								cBeneficiario_estado,cBeneficiario_mncpo_del,cBeneficiario_ciudad,cBeneficiario_calle,
								cReferencia1,cFolio_Sucursal,dFecha_alta,cUsuario,cSucursal,cTransaccion, cHora_remesa, cColonia_ordenante, cCiudad_id_ordenante,
								dFecha_envio_remesa,cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,cCd_remitente,
								cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente
							from "informix".sac_datos_search a, "informix".sac_servicios_wu b
							where pt_mtcn not in (select {+INDEX("informix".sac_datos_pay_wu idxsac_datos_pay_wum)} mtcn from "informix".sac_datos_pay_wu)
							and pt_mtcn = b.referencia1
							and monto_total = b.importe_pago

							LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);
							INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
							beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
							beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,beneficiario_cp,
							ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
							fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
							numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,cod_agnt_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
							tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
							hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,ciudad_id_ordenante,ocupacion_beneficiario,name_benef_suc,
							num_id_benef_suc,fecha_envio_remesa)
							VALUES(dFecha_alta,'WUN','NO',vPt_Mtcn,mMonto_total,mMonto_dolares,cTransaccion,cFolio_sucursal,(today), 
								cBeneficiario_nombre1,cBeneficiario_nombre2,cBeneficiario_appaterno,cBeneficiario_apmaterno,mdy(01,01,1900),cBeneficiario_estado,cBeneficiario_mncpo_del,
								cBeneficiario_ciudad,'',cBeneficiario_mncpo_del,cBeneficiario_calle,'','','','',
								cOrdenante_nombre1,cOrdenante_nombre2,cOrdenante_appaterno,cOrdenante_apmaterno, cOrdenante_direccion, cSucursal,cUsuario,dFecha_Proceso,
								mdy(01,01,1900),'','','','',cCod_pais_origen,cCod_moneda_origen,cCod_pais_destino,cCod_moneda_destino,cTipo_cambio,
								'','','','','','','','','','','',
								'','','','',cCd_remitente,'',cCod_edo_remitente,cCod_pais_remitente,cCp_remitente,cTel_remitente,'',
								dHora_proceso,cHora_remesa,cColonia_ordenante,'',cCiudad_id_ordenante,'', cBeneficiario_nombre1 || " " || cBeneficiario_nombre2 || " " || cBeneficiario_appaterno || " " || cBeneficiario_apmaterno,
								cNum_id_benef_suc,dFecha_envio_remesa);								
								
							LET sCont = sCont + 1;						
							IF sCont = 500 THEN
								COMMIT WORK;
								LET sCont = 0;
								BEGIN WORK;
							END IF;
								
						END FOREACH;	

							IF sCont < 500 and sCont >= 0 THEN
								COMMIT WORK;
								LET sCont = 0;			
							END IF;
						
						ELSE IF (iCuantosSearch <> iCuantosMovtos) THEN	
					
							BEGIN WORK;
							FOREACH WITH HOLD
								--SELECT {+INDEX("informix".sac_datos_pay_wu idxsac_datos_pay_wum)} NVL(mtcn,''),NVL(beneficiario_nombre1,''),NVL(beneficiario_nombre2,''),NVL(beneficiario_appaterno,''),
                                SELECT NVL(mtcn,''),NVL(beneficiario_nombre1,''),NVL(beneficiario_nombre2,''),NVL(beneficiario_appaterno,''), 								
									NVL(beneficiario_apmaterno,''),NVL(beneficiario_fecha_nac,'01011900'),NVL(beneficiario_estado,''),NVL(beneficiario_mncpo_del,''),NVL(beneficiario_ciudad,''),
									NVL(beneficiario_direccion,''),NVL(beneficiario_colonia,''),NVL(beneficiario_calle,''),NVL(beneficiario_num_ext,''),NVL(beneficiario_num_int,''), 
									NVL(beneficiario_depto,''),NVL(beneficiario_cp,''),
									b.referencia1,b.folio_suc,b.fecha_pago,b.usuario,b.id_sucursal,b.transacc_suc,b.importe_pago, NVL(b.hora_remesa,''), NVL(ocupacion_beneficiario,''),
									NVL(name_benef_suc,''), NVL(num_id_benef_suc,''),tp_id_benef,num_id_benef,cod_pais_benef,cp_benef,tel_benef
								INTO vPt_Mtcn,cBeneficiario_nombre1,cBeneficiario_nombre2,cBeneficiario_appaterno,cBeneficiario_apmaterno,cFechaFor,
									cBeneficiario_estado,cBeneficiario_mncpo_del,cBeneficiario_ciudad,cBeneficiario_direccion,cBeneficiario_colonia,
									cBeneficiario_calle,cBeneficiario_num_ext,cBeneficiario_num_int,cBeneficiario_depto,cBeneficiario_cp,
									cReferencia1,cFolio_Sucursal,dFecha_alta,cUsuario,cSucursal,cTransaccion,mMonto_total, cHora_remesa, cOcupacion_beneficiario,cName_benef_suc,
									cNum_id_benef_suc,cTp_id_benef,cNum_id_benef,cCod_pais_benef,cCp_benef,cTel_benef
								FROM "informix".sac_datos_pay_wu a, "informix".sac_servicios_wu b
								--WHERE mtcn not in (select {+INDEX("informix".sac_datos_search idxsac_datos_searchp)} pt_mtcn from "informix".sac_datos_search)
                                WHERE mtcn not in (select pt_mtcn from "informix".sac_datos_search)									
								AND a.foreign_rs_refnum_rq = b.folio_suc

								LET dBeneficiario_fecha_nac = MDY(SUBSTR(cFechaFor,3,2),SUBSTR(cFechaFor,1,2),SUBSTR(cFechaFor,5,4));					  
								LET dHora_proceso = current::DATETIME HOUR to FRACTION(3);								
								INSERT INTO "informix".sac_pld_remesas (fecha_remesa,tipo_remesa,abono_cuenta,num_confirmacion,monto_total,monto_dolares,transaccion,folio_sucursal,fecha_alta,
								beneficiario_nombre1,beneficiario_nombre2,beneficiario_appaterno,beneficiario_apmaterno,beneficiario_fecha_nac,beneficiario_estado,beneficiario_mncpo_del,
								beneficiario_ciudad,beneficiario_direccion,beneficiario_colonia,beneficiario_calle,beneficiario_num_ext,beneficiario_num_int,beneficiario_depto,
								beneficiario_cp,ordenante_nombre1,ordenante_nombre2,ordenante_appaterno,ordenante_apmaterno,ordenante_direccion,sucursal,usuario,fecha_proceso,
								fecha_peticion,hora_peticion,hora_transaccion,cnxn_status,tipo_pago_servicio,cod_pais_origen,cod_moneda_origen,cod_pais_destino,cod_moneda_destino,tipo_cambio,
								numero_de_cliente_benef,tipo_cta_benef,cuenta_benef,tp_id_benef,num_id_benef,cod_edo_benef,cod_pais_benef,cp_benef,tel_benef,cod_agente_org,
								tp_cta_remitente,cuenta_remitente,cod_banco_remitente,ref_num_remitente,cd_remitente,region_benef,cod_edo_remitente,cod_pais_remitente,cp_remitente,tel_remitente,fec_exp_id_rmtnte,
								hora_proceso,hora_remesa,colonia_ordenante,tipo_id_ordenante,ciudad_id_ordenante,
								ocupacion_beneficiario,name_benef_suc,num_id_benef_suc,fecha_envio_remesa)
								  VALUES(dFecha_alta,'WUN','NO',vPt_Mtcn,mMonto_total,0,cTransaccion,cFolio_sucursal,(today), 
									cBeneficiario_nombre1,cBeneficiario_nombre2,cBeneficiario_appaterno,cBeneficiario_apmaterno,dBeneficiario_fecha_nac,cBeneficiario_estado,cBeneficiario_mncpo_del,
									cBeneficiario_ciudad,cBeneficiario_direccion,cBeneficiario_colonia,cBeneficiario_calle,cBeneficiario_num_ext, cBeneficiario_num_int,cBeneficiario_depto,
									cBeneficiario_cp,'','','','','',cSucursal,cUsuario,dFecha_Proceso,
									mdy(01,01,1900),'','','','','','','','','0',
									'','','','',cTp_id_benef,cNum_id_benef,'',cCod_pais_benef,cCp_benef,cTel_benef,
									'','','','','','','','','','','',
									dHora_proceso,cHora_remesa,'','',cCiudad_id_ordenante,
									cOcupacion_beneficiario,cName_benef_suc,cNum_id_benef_suc,dFecha_envio_remesa);									
									
								LET sCont = sCont + 1;						
								IF sCont = 500 THEN
									COMMIT WORK;
									LET sCont = 0;
									BEGIN WORK;
								END IF;									
									
							END FOREACH;	

								IF sCont < 500 and sCont >= 0 THEN
									COMMIT WORK;
									LET sCont = 0;			
								END IF;
							
						END IF;						
					END IF;					
				END IF;			
			END IF;							
		RETURN cCodRet, cMensaje;
		END IF;
	END;
END PROCEDURE;