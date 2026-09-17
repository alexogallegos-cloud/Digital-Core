CREATE PROCEDURE "informix".sp_app_aplicapago(pUsuario CHAR(8), pNum_confirmacion CHAR(12),pMonto_destino CHAR(20), pFecha_peticion CHAR(8), pHora_peticion CHAR(6))
RETURNING
CHAR(5)   AS Codigo_Error,
CHAR(50)  AS Desc_error, 		 
CHAR(8)   AS Fecha_proceso,
CHAR(6)   AS Hora_proceso;	

--DEFINICION DE VARIABLES--
DEFINE iSql_err           			INTEGER;
DEFINE iSam_err		      			INTEGER;
DEFINE cCod_err           			CHAR(5);
DEFINE cCod_err2          			CHAR(5);
DEFINE cCod_err4       				CHAR(25);
DEFINE cDesc_error        			CHAR(150);
DEFINE cCadena_ent        			CHAR(100);
DEFINE cHora_sistema      			CHAR(6);
DEFINE cCta_benef         			CHAR(20);
DEFINE cSuc_cargo         			CHAR(4);
DEFINE cCta_pres          			CHAR(20);
DEFINE cCen_cargo 	      			CHAR(4);
DEFINE cCen_abono         			CHAR(4);
DEFINE cFolSuc            			CHAR(16);
DEFINE cPreferencia       			CHAR(40);
DEFINE cTrandet           			CHAR(4);
DEFINE dFechoy            			DATE;
DEFINE mSdodisp           			MONEY(14,2);
DEFINE mMontoret          			MONEY(14,2);
DEFINE cReferencia2       			CHAR(20);
DEFINE mImpcomconvenio    			MONEY(14,2);
DEFINE mIVAimpconvenio    			MONEY(14,2);
DEFINE mImpcomcte	      			MONEY(14,2);
DEFINE mIVAimpcomcte      			MONEY(14,2);
DEFINE cValor             			CHAR(100);
DEFINE cCategoria         			CHAR(2);
DEFINE cConvenio          			CHAR(3);
DEFINE cBank_ref_nm	      			CHAR(16);
DEFINE cImporte2	      			CHAR(16);
DEFINE itransaccion       			INTEGER;
DEFINE cSucAPP            			CHAR(4);
DEFINE cMonedaOrigen 	  			CHAR(3);
DEFINE mMontoOrigen 	  			MONEY(14,2);
DEFINE iLen_cta		   				INTEGER;
DEFINE cNumCte         				CHAR(20);
DEFINE cPaisOrigen			CHAR(3);
DEFINE iCodPais				CHAR(3);
DEFINE iValPais				INTEGER;

DEFINE iSecuencia					INTEGER;

 --SET DEBUG FILE TO "/informix/RPT/sp_app_aplicapago.out";
 --TRACE ON;


LET itransaccion      		 		= 0; 
LET iSql_err          		 		= 0;
LET cImporte2		  		 		= '';
LET iSam_err          		 		= 0;
LET cCod_err          		 		= '00000';
LET cCod_err2         		 		= '00000';
LET cCod_err4				 		= '';
LET cDesc_error 	  		 		= '';
LET cCadena_ent 	  		 		= TRIM(NVL(pUsuario,'NULL'))||"|" 
									  ||TRIM(NVL(pNum_confirmacion,'NULL'))||"|" 
							          ||TRIM(NVL(pFecha_peticion,'NULL'));
LET cHora_sistema     		 		= REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCta_benef        		 		= '';
LET cSuc_cargo        		 		= '';
LET cCta_pres 		  		 		= '';
LET cCen_cargo		  		 		= '';
LET cCen_abono  	  		 		= '';
LET cFolSuc  		  		 		= '';
LET cPreferencia 	  		 		= 'Pago de Remesa: '||pNum_confirmacion; 
LET cTrandet          		 		= '';
LET dFechoy           		 		= '';
LET mSdodisp          		 		= '';
LET mMontoret		  		 		= '';
LET cReferencia2      		 		= '';
LET mImpcomconvenio   		 		= 0;
LET mIVAimpconvenio   		 		= 0;
LET mImpcomcte        		 		= 0;
LET mIVAimpcomcte     		 		= 0;
LET cValor            		 		= '';
LET cCategoria        		 		= '';
LET cConvenio         		 		= '';
LET cBank_ref_nm   	  		 		= '';
LET cSucAPP           		 		= '';
LET mMontoOrigen 			 		= 0;
LET iLen_cta		   				=  0;
LET cNumCte            				= '';
LET cPaisOrigen						= '';		
LET iCodPais						= '';	
LET iValPais						= 0;

LET iSecuencia						= 0;

 BEGIN
 	ON EXCEPTION SET iSql_err,iSam_err
		IF iSql_err <> 0 THEN
			LET cCod_err = iSql_err; 
			LET cDesc_error = '';
			
			IF iSql_err = -284 THEN
			
				SELECT COUNT(*)
				INTO   iSecuencia
				FROM   bdisac:"informix".sac_app_getorder  
				WHERE  uniquereferencenumber = pNum_confirmacion 
				AND    estatus_getorder      = '02';
			
				IF iSecuencia > 1 THEN

					LET iSecuencia = 0;
					
					SELECT MAX(ROWID) secuencia
					INTO   iSecuencia
					FROM   bdisac:"informix".sac_app_getorder  
					WHERE  uniquereferencenumber = pNum_confirmacion 
					AND    estatus_getorder      = '02';

					UPDATE bdisac:"informix".sac_app_getorder  SET estatus_getorder='09' 
					WHERE  uniquereferencenumber = pNum_confirmacion  
					  AND  estatus_getorder      = '02' 
					  AND rowid <> iSecuencia;

					UPDATE bdisac:"informix".sac_app_getorder  SET estatus_getorder='01', intentos_envio = '1'
					WHERE  uniquereferencenumber = pNum_confirmacion  
					  AND  estatus_getorder      = '02' 
					  AND rowid = iSecuencia;
				END IF;
			END IF;					
		
			IF cCod_err4 = 'sp_registra_evento' THEN
			
				LET cDesc_error = 'El sp_registra_evento error no controlado = ' || iSql_err;
			
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapago', cCod_err, cDesc_error,iSql_err,isam_err, cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
				INTO cCod_err2;
			
				--No es un error
				LET cCod_err = '00000';
			
				RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
			
			ELSE
			
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapago', cCod_err, cDesc_error,iSql_err,isam_err, cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
				INTO cCod_err2;
				
				UPDATE bdisac:"informix".sac_app_getorder 
				SET    estatus_getorder      = '01',
					   intentos_envio        = intentos_envio + 1
				WHERE  uniquereferencenumber = pNum_confirmacion
				AND    estatus_getorder      = '02';
				
				SELECT valor 
				INTO   cSucAPP
				FROM   bdisac:"informix".sac_param
				WHERE  empresa   = '001'
				AND    cod_param = 87112;
				
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
				INTO cCod_err2;

				RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
				
			END IF;
		END IF;
	END EXCEPTION;
		
		ON EXCEPTION IN(-535)
			let itransaccion = 1;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH resume;
		
		BEGIN WORK;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--INSERT INTO "informix".sac_ws_procesos (proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		--VALUES ('sp_app_aplicapago',pFecha_peticion,pHora_peticion,'0','',pUsuario,current::date,cHora_sistema);	
		
		IF NVL(pNum_confirmacion,'') = '' THEN		
			LET cCod_err = '1100';
				
			SELECT NVL(opcode_sd, '')
			INTO   cDesc_error 
			FROM   bdisac:"informix".sac_app_cat_mensajes 
			WHERE  agent_trans_type_code = 'CFPA'         
			AND    opcode                = cCod_err;
			
			IF cDesc_error IS NULL THEN
				LET cDesc_error = 'Codigo no registrado en catalogo.';
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapago', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
		   
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;
		
		--Validacion Paises Permitidos
		select countrycodebranch into cPaisOrigen from sac_app_getorder where estatus_getorder = '02' and uniquereferencenumber = pNum_confirmacion;
		
		select pais into iCodPais from sac_paises_permitidos where appbts = cPaisOrigen;
		
		select count(*) into iValPais from bdinteg:si_paises_remesadoras where id_remesadora = '4' and id_pais = iCodPais;
		
		if iValPais = 0 THEN
		
			LET cCod_err = '00001';
			LET cDesc_error = 'Pais restringido';
			
			UPDATE bdisac:"informix".sac_app_getorder
			SET    estatus_getorder      = '04'
			WHERE  uniquereferencenumber = pNum_confirmacion 
			AND    estatus_getorder      = '02';

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapago', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
			
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		
		end if;
		
	    SELECT accountnumbersenderpay, currencycodeorigin, originamount 
		INTO   cCta_benef, cMonedaOrigen, mMontoOrigen
		FROM   bdisac:"informix".sac_app_getorder  
		WHERE  uniquereferencenumber = pNum_confirmacion  
		AND    estatus_getorder      = '02';
		
		LET iLen_cta = LENGTH(TRIM(cCta_benef));
				
		IF iLen_cta = 11 THEN
			SELECT cuenta, num_cte
			INTO   cCta_benef, cNumCte
			FROM   bdicheq:"informix".sc_maechq 
			WHERE  empresa = '001'
			AND    cuenta  = cCta_benef;
			
		ELIF iLen_cta = 16 THEN
			SELECT cuenta, numcte
			INTO   cCta_benef, cNumCte
			FROM   bdicheq:"informix".sc_tarjeta 
			WHERE  empresa     = '001'
			AND    num_tarjeta = cCta_benef;
			
		ELIF iLen_cta = 18 THEN
			SELECT cuenta, num_cte
			INTO   cCta_benef, cNumCte
			FROM   bdicheq:"informix".sc_maechq 
			WHERE  cuenta_clabe = cCta_benef;
			
		END IF;
		
		SELECT valor ----8709
		INTO   cValor
		FROM   bdisac:"informix".sac_param 
		WHERE  empresa   = '001'
		AND    cod_param = 87116;
		
		LET cCategoria = LPAD(SUBSTR(TRIM(cValor),2,1),2,'0');  
		LET cConvenio  = LPAD(SUBSTR(TRIM(cValor),3,2),3,'0');
			
		SELECT cuenta_prestadora, trans_cen_cargo_cliente, trans_suc_cargo,trans_cen_abono_convenio    
		INTO   cCta_pres, cCen_cargo, cSuc_cargo, cCen_abono
		FROM   bdisac:"informix".sac_convenios
		WHERE  numcategoria = cCategoria
		AND    numconvenio  = cConvenio;
		
		--Reviso si la remesa ya fue pagada
		SELECT b.folio_suc INTO cBank_ref_nm   
		FROM   bdisac:"informix".sac_movimientos b 
		WHERE  b.numcategoria               = cCategoria
		AND    b.numconvenio                = cConvenio
		AND    b.referencia1                = pNum_confirmacion
		AND    b.flag_confirmacion_central  = '1'
		AND    b.flag_confirmacion_sucursal = '1'
		AND    b.status_cancelado           = 'N';
			
		IF cBank_ref_nm IS NOT NULL OR cBank_ref_nm <> '' THEN
			LET cCod_err    = '1100';
			LET cDesc_error = 'REMESA PAGADA ANTERIORMENTE';

			UPDATE bdisac:"informix".sac_app_getorder 
			SET    estatus_getorder      = '98'
			WHERE  uniquereferencenumber = pNum_confirmacion 
			AND    estatus_getorder      = '02';		

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapago', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;  
		END IF;
		
		--Obtener el numero de sucursal asignada
		SELECT valor
		INTO   cSucAPP
		FROM   bdisac:"informix".sac_param 
		WHERE  empresa   = '001'
		AND    cod_param = 87112;
		
		--Reviso limite de remesas
		EXECUTE PROCEDURE bdisac:"informix".sp_app_valmonto_aut(pNum_confirmacion ,cCta_benef, cSucAPP, pMonto_destino, cMonedaOrigen, mMontoOrigen, cNumCte)
		INTO cCod_err, cDesc_error;

		IF cCod_err::INT <> 0 THEN
		
			UPDATE bdisac:"informix".sac_app_getorder
			SET    estatus_getorder      = '04'
			WHERE  uniquereferencenumber = pNum_confirmacion 
			AND    estatus_getorder      = '02';

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapago', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		
		END IF;
		------
		
		--LET cFolSuc = TRIM(pUsuario)||SUBSTR(TRIM(cHora_sistema),1,4)||SUBSTR(TRIM(pNum_confirmacion),8,5);
        LET cFolSuc = 'ac' || SUBSTR(TRIM(cHora_sistema),5,2) || TRIM(pNum_confirmacion);
			
		EXECUTE PROCEDURE bdisac:"informix".sp_calcula_comisiones(cCategoria,cConvenio,pMonto_destino)
		INTO cCod_err, mImpcomconvenio, mIVAimpconvenio, mImpcomcte, mIVAimpcomcte;

		IF cCod_err::INT <> 0 THEN
		
			LET cDesc_error = 'Error al momento de calcular las comisiones';

			UPDATE bdisac:"informix".sac_app_getorder 
			SET    estatus_getorder      = '01'
			WHERE  uniquereferencenumber = pNum_confirmacion 
			AND    estatus_getorder      = '02';
		
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapago', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
			
		END IF;

		EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001',cSucAPP, pUsuario,cCen_cargo,cSuc_cargo,cFolSuc,cCta_pres,0, pMonto_destino,'01',cPreferencia,'','')
		INTO cCod_err, cTrandet, dFechoy, mSdodisp, mMontoret;		
		
		IF cCod_err::INT <> 0 THEN
		
			LET cDesc_error = 'Error al momento de realizar el cargo en cuenta';			
			
			IF cCod_err::INT < 0 THEN
			
				UPDATE bdisac:"informix".sac_app_getorder 
				SET    estatus_getorder      = '01', intentos_envio = intentos_envio + 1
				WHERE  uniquereferencenumber = pNum_confirmacion 
				AND    estatus_getorder      = '02';	
				   
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
				INTO cCod_err2;	
			   
				IF itransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF   
	   
			ELSE
			
				UPDATE bdisac:"informix".sac_app_getorder 
				SET    estatus_getorder      = '04',
				       intentos_envio        = 0
				WHERE  uniquereferencenumber = pNum_confirmacion 
				AND    estatus_getorder      = '02';
				   
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
    			INTO cCod_err2;
				
			    ROLLBACK WORK;
				
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapago', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
			
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
			
		END IF;	
		
		EXECUTE PROCEDURE bdicheq:"informix".abono_ref('001',cSucAPP,pUsuario,cCen_abono,cSuc_cargo,cFolSuc,cCta_benef,1,pMonto_destino,pMonto_destino,0,0,0,'01',cPreferencia,'0','')
		INTO cCod_err;

		IF cCod_err::INT <> 0 THEN
		
			LET cDesc_error = 'Error al momento de realizar el abono';			
						
			IF cCod_err::INT < 0 THEN
			
				UPDATE bdisac:"informix".sac_app_getorder 
				SET    estatus_getorder      = '01', intentos_envio = intentos_envio + 1 
				WHERE  uniquereferencenumber = pNum_confirmacion 
				AND    estatus_getorder      = '02';
				   
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
				INTO cCod_err2;
				
				IF itransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF	   
				   
			ELSE
			
				UPDATE bdisac:"informix".sac_app_getorder 
				SET    estatus_getorder     = '04',
				       intentos_envio       = 0
				WHERE uniquereferencenumber = pNum_confirmacion
				AND   estatus_getorder      = '02';	
			
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
				INTO cCod_err2;
				
				ROLLBACK WORK;
				
			END IF;	
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapago', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
			
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
			
		END IF;

		LET cReferencia2   = SUBSTR(pNum_confirmacion,11,1);
		
		EXECUTE PROCEDURE bdisac:"informix".sp_grabapagoservicio(cSucAPP,cCategoria,cConvenio,pNum_confirmacion,cReferencia2, '4',pMonto_destino,mImpcomconvenio,mIVAimpconvenio,mImpcomcte,mIVAimpcomcte,cCta_pres, pUsuario, cFolSuc,cCen_abono,current::date)
		INTO cCod_err;
		
		IF cCod_err::INT <> 0 THEN
		
			LET cDesc_error = 'Error al momento de grabar en servicios';					
			
			IF cCod_err::INT < 0 THEN
				
				UPDATE bdisac:"informix".sac_app_getorder 
				SET    estatus_getorder      = '01',
				       intentos_envio        = intentos_envio + 1
				WHERE  uniquereferencenumber = pNum_confirmacion 
				AND    estatus_getorder      = '02';	
			ELSE
			
				UPDATE bdisac:"informix".sac_app_getorder 
				SET    estatus_getorder      = '04',
				       intentos_envio        = 0
				WHERE  uniquereferencenumber = pNum_confirmacion
				AND    estatus_getorder      = '02';	
				
			END IF;
			
			EXECUTE PROCEDURE bdicheq:"informix".reversion('001', cSucAPP, pUsuario, cFolSuc,'M')
			INTO cCod_err2;
			   
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_app_aplicapago', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
			
			ROLLBACK WORK;
			
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
			
		END IF;
		
		LET cDesc_error = 'Confirmacion CFPA exitosa';
			
		--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,'sp_app_aplicapago', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
		--INTO cCod_err;	

		
		UPDATE bdisac:"informix".sac_app_getorder 
		SET    estatus_getorder      = '03',
		       intentos_envio        = 0
		WHERE  uniquereferencenumber = pNum_confirmacion 
		AND    estatus_getorder      = '02';		
		   
		LET cImporte2 = TRIM (TO_CHAR(pMonto_destino,"###,###,###,###.##"));
		
		--No se evalua la variable "cCod_err4" ya que el resultado del codigo error del sp_registra_evento no afecte la funcionalidad del proceso principal
		LET cCod_err4 = 'sp_registra_evento';
			
		CALL bdimnsj:"informix".sp_registra_evento ('2' , 'BTS_ACTAS', '', cCta_benef, '' , '1', 
		     cCta_benef, cFolSuc, 'PAGO DE REMESA APPRIZA', cImporte2, '', '', '', '', '', '', '', '',  
		     pMonto_destino, '','', '', '', CURRENT, '') RETURNING cCod_err2;
			 
		COMMIT WORK;
		
		RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;

  END
 END PROCEDURE
 DOCUMENT
'Autor : Pedro Jimenez Guzman',
'FECHA : 07/11/2016',
'Descripcion: Realiza la aplicaciÃÂ³n del cargo en cuenta concentradora',
'			  y abono en cuenta de cliente beneficiario por concepto',
'			  de remesa APPRIZA con abono directo en cuenta',
'Ver.  : 1.0',
'BD    : bdisac',
'Autor : Viridiana Paredes Romero',
'FECHA : 30/05/2017',
'Descripcion: Se agragan validaciones de limites para las remesas de appriza',
'			  para los montos diarios y mensuales, tanto en pesos como en',
'			  dolares al igual que listas negras',
'Ver.  : 1.0',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_bts_aplicapagos(pUsuario CHAR(8), pNum_confirmacion CHAR(11), pMonto_destino CHAR(20), pFecha_peticion CHAR(8), pHora_peticion CHAR(6))
RETURNING
CHAR(5)   AS Codigo_Error,
CHAR(50)  AS Desc_error,
CHAR(8)   AS Fecha_proceso,
CHAR(6)   AS Hora_proceso;

--DEFINICION DE VARIABLES--
DEFINE iSql_err        				INTEGER;
DEFINE iSam_err		   				INTEGER;
DEFINE cCod_err        				CHAR(5);
DEFINE cCod_err2       				CHAR(5);
DEFINE cCod_err4       				CHAR(25);
DEFINE cDesc_error     				CHAR(150);
DEFINE cCadena_ent     				CHAR(100);
DEFINE cHora_sistema   				CHAR(6);
DEFINE cCta_benef      				CHAR(20);
DEFINE cSuc_cargo      				CHAR(4);
DEFINE cCta_pres       				CHAR(20);
DEFINE cCen_cargo 	   				CHAR(4);
DEFINE cCen_abono      				CHAR(4);
DEFINE cFolSuc         				CHAR(16);
DEFINE cPreferencia    				CHAR(40);
DEFINE cTrandet        				CHAR(4);
DEFINE dFechoy         				DATE;
DEFINE mSdodisp        				MONEY(14,2);
DEFINE mMontoret       				MONEY(14,2);
DEFINE cReferencia2    				CHAR(20);
DEFINE mImpcomconvenio 				MONEY(14,2);
DEFINE mIVAimpconvenio 				MONEY(14,2);
DEFINE mImpcomcte	   				MONEY(14,2);
DEFINE vIVAimpcomcte   				MONEY(14,2);
DEFINE cValor          				CHAR(100);
DEFINE cCategoria      				CHAR(2);
DEFINE cConvenio       				CHAR(3);
DEFINE cBank_ref_nm	   				CHAR(16);
DEFINE vImporte2	   				CHAR(16);
DEFINE cDesc_error2    				CHAR(50);
DEFINE cDesc_error3    				CHAR(150);
DEFINE vtransaccion    				INTEGER;
DEFINE cSucBTS         				CHAR(4);
DEFINE cMonedaOrigen   				CHAR(3);
DEFINE mMontoOrigen     			MONEY(14,2);
DEFINE iLen_cta		   				INTEGER;
DEFINE cNumCte         				CHAR(20);
DEFINE cPaisOrigen			CHAR(3);
DEFINE iCodPais				CHAR(3);
DEFINE iValPais				INTEGER;

--INICIALIZACION DE VARIABLES--
LET vtransaccion       		=  0; 
LET iSql_err           		=  0;
LET vImporte2		   		= '';
LET iSam_err           		=  0;
LET cCod_err           		= '00000';
LET cCod_err2          		= '00000';
LET cCod_err4          		= '';
LET cDesc_error 	   		= '';
LET cCadena_ent 	   		= TRIM(NVL(pUsuario,'NULL'))||"|" 
							  ||TRIM(NVL(pNum_confirmacion,'NULL'))||"|" 
				              ||TRIM(NVL(pFecha_peticion,'NULL'));
LET cHora_sistema      		= REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '');
LET cCta_benef         		= '';
LET cSuc_cargo         		= '';
LET cCta_pres 		   		= '';
LET cCen_cargo		   		= '';
LET cCen_abono  	   		= '';
LET cFolSuc  		   		= '';
LET cPreferencia 	   		= 'Pago de Remesa: '||pNum_confirmacion; 
LET cTrandet           		= '';
LET dFechoy            		= '';
LET mSdodisp           		= '';
LET mMontoret		   		= '';
LET cReferencia2       		= '';
LET mImpcomconvenio    		=  0;
LET mIVAimpconvenio    		=  0;
LET mImpcomcte         		=  0;
LET vIVAimpcomcte      		=  0;
LET cValor             		= '';
LET cCategoria         		= '';
LET cConvenio          		= '';
LET cBank_ref_nm   	   		= '';
LET cDesc_error2       		= '';
LET cDesc_error3       		= '';
LET cSucBTS            		= '';
LET cMonedaOrigen      		= '';
LET mMontoOrigen       		= '';
LET iLen_cta		   		=  0;
LET cNumCte            		= '';
LET cPaisOrigen						= '';		
LET iCodPais						= '';	
LET iValPais						= 0;

 --SET DEBUG FILE TO "/informix/RPT/sp_bts_aplicapagos.out";
 --TRACE ON;

 BEGIN
 	ON EXCEPTION SET iSql_err,iSam_err
		IF iSql_err <> 0 THEN
			LET cCod_err = iSql_err; 
			LET cDesc_error = '';
			
			IF cCod_err4 = 'sp_registra_evento' THEN
			
				LET cDesc_error = 'El sp_registra_evento error no controlado = ' || iSql_err;
			
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos', cCod_err, cDesc_error,iSql_err,isam_err, cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
				INTO cCod_err2;
			
				--No es un error
				LET cCod_err = '00000';
			
				RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
			
			ELSE
			
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos', cCod_err, cDesc_error,iSql_err,isam_err, cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
				INTO cCod_err2;
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET    estatus_sdep     = '01',
					intentos_envio   = intentos_envio + 1
				WHERE  num_confirmacion = pNum_confirmacion
				AND    estatus_sdep     = '02';
			
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9250', pUsuario, cFolSuc,'M')
				INTO cCod_err2;

				RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
				
			END IF;
			
		END IF;
	END EXCEPTION;
		
		ON EXCEPTION IN(-535)
			let vtransaccion = 1;
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH resume;
		
		BEGIN WORK;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO "informix".sac_ws_procesos (proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		VALUES ('sp_bts_aplicapagos',pFecha_peticion,pHora_peticion,'0','',pUsuario,current::date,cHora_sistema);	
		
		IF NVL(pNum_confirmacion,'') = '' THEN		
			LET cCod_err = '9902';
				
			SELECT NVL(opcode_sd, '')
			INTO   cDesc_error 
			FROM   bdisac:"informix".sac_bts_catmensajes 
			WHERE  agent_trans_type_code = 'PAYC' 
			AND    opcode                = cCod_err;
			
			IF cDesc_error IS NULL THEN
				LET cDesc_error = 'Codigo no registrado en catalogo.';
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
		   
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;
		
		--Validacion pais origen------------------------------------------------
		SELECT cod_pais_origen INTO cPaisOrigen FROM sac_bts_sdep WHERE estatus_sdep = '02' AND num_confirmacion = pNum_confirmacion;
		
		SELECT pais INTO iCodPais FROM sac_paises_permitidos WHERE appbts = cPaisOrigen;
		
		SELECT COUNT(*) INTO iValPais FROM bdinteg:si_paises_remesadoras WHERE id_remesadora = '5' AND id_pais = iCodPais;
		
		IF iValPais = 0 THEN
		
			LET cCod_err = '00001';
			LET cDesc_error = 'Pais restringido';
			
			UPDATE bdisac:"informix".sac_bts_sdep
			SET    estatus_sdep     = '04'
			WHERE  num_confirmacion = pNum_confirmacion
			AND    estatus_sdep     = '02';
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
			
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		
		END IF;
		
		SELECT cuenta_benef, cod_moneda_origen, monto_origen
		INTO   cCta_benef, cMonedaOrigen, mMontoOrigen
		FROM   bdisac:"informix".sac_bts_sdep 
		WHERE  num_confirmacion = pNum_confirmacion 
		AND    estatus_sdep     = '02';
		
		LET iLen_cta = LENGTH(TRIM(cCta_benef));
				
		IF iLen_cta = 11 THEN
			SELECT cuenta, num_cte
			INTO   cCta_benef, cNumCte
			FROM   bdicheq:"informix".sc_maechq 
			WHERE  empresa = '001'
			AND    cuenta  = cCta_benef;
			
		ELIF iLen_cta = 16 THEN
			SELECT cuenta, numcte
			INTO   cCta_benef, cNumCte
			FROM   bdicheq:"informix".sc_tarjeta 
			WHERE  empresa     = '001'
			AND    num_tarjeta = cCta_benef;
			
		ELIF iLen_cta = 18 THEN
			SELECT cuenta, num_cte
			INTO   cCta_benef, cNumCte
			FROM   bdicheq:"informix".sc_maechq 
			WHERE  cuenta_clabe = cCta_benef;
			
		END IF;
			
		SELECT valor 
		INTO   cValor
		FROM   bdisac:"informix".sac_param 
		WHERE  empresa   = '001'
		AND    cod_param = 87018;
	
		LET cCategoria = SUBSTR(TRIM(cValor),1,2);
		LET cConvenio  = SUBSTR(TRIM(cValor),3,5);
		
		SELECT cuenta_prestadora, trans_cen_cargo_cliente, trans_suc_cargo,trans_cen_abono_convenio    
		INTO   cCta_pres, cCen_cargo, cSuc_cargo, cCen_abono
		FROM   bdisac:"informix".sac_convenios
		WHERE  numcategoria = cCategoria
		AND    numconvenio  = cConvenio;
	   
	    --Reviso si la remesa ya fue pagada
		SELECT b.folio_suc INTO cBank_ref_nm
		FROM   bdisac:"informix".sac_movimientos b 
		WHERE  b.numcategoria               = cCategoria
		AND    b.numconvenio                = cConvenio
		AND    b.referencia1                = pNum_confirmacion
		AND    b.flag_confirmacion_central  = '1' 
		AND    b.flag_confirmacion_sucursal = '1' 
		AND    b.status_cancelado           = 'N';	
			
		IF cBank_ref_nm IS NOT NULL OR cBank_ref_nm <> '' THEN
			LET cCod_err    = '9998';
			LET cDesc_error = 'REMESA PAGADA ANTERIORMENTE';
	
			UPDATE bdisac:"informix".sac_bts_sdep 
			SET    estatus_sdep     = '98'
			WHERE  num_confirmacion = pNum_confirmacion
			AND    estatus_sdep     = '02';

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;  
		END IF;	  
		
		--Obtener el numero de sucursal asignada
		SELECT valor
		INTO   cSucBTS
		FROM   bdisac:"informix".sac_param 
		WHERE  empresa   = '001'
		AND    cod_param = 87015;
		
		--Reviso limite de remesas
		EXECUTE PROCEDURE bdisac:"informix".sp_validamontoremesabts_aut(pNum_confirmacion ,cCta_benef, cSucBTS, pMonto_destino, cMonedaOrigen, mMontoOrigen, cNumCte)
		INTO cCod_err, cDesc_error;

		IF cCod_err::INT <> 0 THEN
			
			UPDATE bdisac:"informix".sac_bts_sdep
			SET    estatus_sdep     = '04'
			WHERE  num_confirmacion = pNum_confirmacion
			AND    estatus_sdep     = '02';

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		
		END IF;
		------
		
		--LET cFolSuc = TRIM(pUsuario)||SUBSTR(TRIM(cHora_sistema),1,4)||SUBSTR(TRIM(pNum_confirmacion),7,5);
		LET cFolSuc = "btssc" || TRIM(pNum_confirmacion); --Se cambia la nomenclatura del folio_suc - NMR24OCT19
		
		EXECUTE PROCEDURE bdisac:"informix".sp_calcula_comisiones(cCategoria,cConvenio,pMonto_destino)
		INTO cCod_err, mImpcomconvenio, mIVAimpconvenio, mImpcomcte, vIVAimpcomcte;

		IF cCod_err::INT <> 0 THEN
			LET cDesc_error = 'Error al momento de calcular las comisiones';

			UPDATE bdisac:"informix".sac_bts_sdep
			SET    estatus_sdep     = '01'
			WHERE  num_confirmacion = pNum_confirmacion 
			AND    estatus_sdep     = '02';

			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;

			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;  
		END IF;

		EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001','9250', pUsuario,cCen_cargo,cSuc_cargo,cFolSuc,cCta_pres,0, pMonto_destino,'01',cPreferencia,'','')
		INTO cCod_err, cTrandet, dFechoy, mSdodisp, mMontoret;		
		
		IF cCod_err::INT <> 0 THEN
			LET cDesc_error = 'Error al momento de realizar el cargo en cuenta';			
			
			IF cCod_err::INT < 0 THEN
				--LET cDesc_error2 = 'Error en cargo_ref informix';
				--LET cDesc_error3 = 'El registro no se actualizo '|| pNum_confirmacion;
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET    estatus_sdep     = '01',
				       intentos_envio   = intentos_envio + 1
				WHERE  num_confirmacion = pNum_confirmacion 
				AND    estatus_sdep     = '02';	

				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9250', pUsuario, cFolSuc,'M')
				INTO cCod_err2;	

				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF;
	   
			ELSE
				--LET cDesc_error2 = 'Error al realizar el cargo_ref';
				--LET cDesc_error3 = 'No se actualizÃÂ³ el status a 04 cargo_ref '||pNum_confirmacion ;
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET    estatus_sdep     = '04',
				       intentos_envio   = 0
				WHERE  num_confirmacion = pNum_confirmacion 
				AND    estatus_sdep     = '02';

				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9250', pUsuario, cFolSuc,'M')
				INTO cCod_err2;	
			   
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
			
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion; 
		END IF;	
		
		EXECUTE PROCEDURE bdicheq:"informix".abono_ref('001','9250',pUsuario,cCen_abono,cSuc_cargo,cFolSuc,cCta_benef,1,pMonto_destino,pMonto_destino,0,0,0,'01',cPreferencia,'0','')
	    INTO cCod_err;

		IF cCod_err::INT <> 0 THEN
			LET cDesc_error = 'Error al momento de realizar el abono';			
						
			IF cCod_err::INT < 0 THEN
				--LET cDesc_error2 = 'Error en abono_ref informix';
				--LET cDesc_error3 = 'No se actualizÃÂ³ el status a 01 abono_ref '||pNum_confirmacion ;
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET    estatus_sdep     = '01',
				       intentos_envio   = intentos_envio + 1 
				WHERE  num_confirmacion = pNum_confirmacion 
				AND    estatus_sdep     = '02';

				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9250', pUsuario, cFolSuc,'M')
				INTO cCod_err2;
				
				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
					BEGIN WORK;
				ELSE
					ROLLBACK WORK;
				END IF;
				   
			ELSE
				--LET cDesc_error2 = 'Error al momento de realizar el abono_ref';
				--LET cDesc_error3 = 'No se actualizÃÂ³ el status a 04 abono_ref '||pNum_confirmacion;
					
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET    estatus_sdep     = '04',
				       intentos_envio   = 0
				WHERE  num_confirmacion = pNum_confirmacion
				AND    estatus_sdep     = '02';
			
				EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9250', pUsuario, cFolSuc,'M')
				INTO cCod_err2;
			
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
			
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion; 
		END IF;

		LET cReferencia2   = SUBSTR(pNum_confirmacion,11,1);
		
		EXECUTE PROCEDURE bdisac:"informix".sp_grabapagoservicio('9250',cCategoria,cConvenio,pNum_confirmacion,cReferencia2, '4',pMonto_destino,mImpcomconvenio,mIVAimpconvenio,mImpcomcte,vIVAimpcomcte,cCta_pres, pUsuario, cFolSuc,cCen_abono,current::date)
		INTO cCod_err;
		
		IF cCod_err::INT <> 0 THEN
			LET cDesc_error = 'Error al momento de grabar en servicios';					
			
			IF cCod_err::INT < 0 THEN
				--LET cDesc_error2 = 'Error en servicios informix';
				--LET cDesc_error3 = 'No se actualizÃÂ³ el status a 01 '||pNum_confirmacion;
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET    estatus_sdep     = '01',
				       intentos_envio   = intentos_envio + 1
				WHERE  num_confirmacion = pNum_confirmacion 
				AND    estatus_sdep     = '02';	
			ELSE
				--LET cDesc_error2 = 'Error al momento de grabar en servicios';
				--LET cDesc_error3 = 'No se actualizÃÂ³ el status a 04 '||pNum_confirmacion;
				
				UPDATE bdisac:"informix".sac_bts_sdep 
				SET    estatus_sdep     = '04',
				       intentos_envio   = 0
				WHERE  num_confirmacion = pNum_confirmacion
				AND    estatus_sdep     = '02';	
			END IF;
			
			EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9250', pUsuario, cFolSuc,'M')
			INTO cCod_err2;
			   
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_bts_aplicapagos', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
			INTO cCod_err2;
			   
			RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;
		END IF;
		
		LET cDesc_error = 'ConfirmaciÃ³n PAYC exitosa';
			
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,'sp_bts_aplicapagos', cCod_err, cDesc_error,'','', cCadena_ent,pUsuario, pFecha_peticion,pHora_peticion)
		INTO cCod_err;	
		
		--LET cDesc_error2  = 'Error al confirmar PAYC exitosa informix';
		--LET cDesc_error3  = 'No se actualizÃÂ³ el status a 03 '||pNum_confirmacion;		

		UPDATE bdisac:"informix".sac_bts_sdep 
		SET    estatus_sdep     = '03',
		       intentos_envio   = 0
		WHERE  num_confirmacion = pNum_confirmacion 
		AND    estatus_sdep     = '02';		
		   
		LET vImporte2 = TRIM (TO_CHAR(pMonto_destino,"###,###,###,###.##"));
		
		--No se evalua la variable "cCod_err4" ya que el resultado del codigo error del sp_registra_evento no afecte la funcionalidad del proceso principal
		LET cCod_err4 = 'sp_registra_evento';
			
		CALL bdimnsj:"informix".sp_registra_evento ('2' , 'BTS_ACTAS', '', cCta_benef, '' , '1', 
		cCta_benef, cFolSuc, 'PAGO DE REMESA DE BTS', vImporte2, '', '', '', '', '', '', '', '',  -- strings
		pMonto_destino, '','', '', '', CURRENT, '') RETURNING cCod_err2;						   -- importes
		
		RETURN cCod_err,cDesc_error,pFecha_peticion,pHora_peticion;

  END
 END PROCEDURE
 DOCUMENT
"Autor : Eduardo Pineda",
"FECHA : 27/01/2016",
"Descripcion: Validacion de monto max acumulado por cuenta ",
"Autor : Eduardo Pineda",
"FECHA : 14/05/2014",
"Descripcion: Optimizacion y evitamos bloqueos de tablas cuando realiza",
"			  la reversion en cargo_ref y abono_ref ",
"			  de remesa BTS con abono directo en cuenta",
"Autor : Martha Aguirre",
"FECHA : 17/10/2012",
"Descripcion: Realiza la aplicaciÃ³n del cargo en cuenta concentradora",
"			  y abono en cuenta de cliente beneficiario por concepto",
"			  de remesa BTS con abono directo en cuenta",
"Ver.  : 1.0",
"Autor : Pedro G Jimenez Guzman",
"FECHA : 25/05/2017",
"Descripcion: Realiza validacion de monto diario, mensual(pesos y dolares)",
"			  tambien valida en la lista negra",
"			  y el limite de operaciones mensuales y diarios",
"BD    : bdisac";

CREATE PROCEDURE "informix".sp_validamontoremesabts(p_cEmpresa CHAR(3), p_cNombre1 CHAR(40), p_cNombre2 CHAR(40), p_cApellidoPaterno CHAR(40), p_cApellidoMaterno CHAR(40), p_cFechaNacimiento CHAR(8), p_cFechaHoy CHAR(8), p_cMontoAPagar CHAR(20),p_sucursal  CHAR(4),p_moneda CHAR(3),cMontoDolares Money(16,2),pNum_confirmacion CHAR(16))
    
	RETURNING CHAR(5) AS CodRet;
 
    --Definicion de Variables
    DEFINE cCodRet      				CHAR(5);
	DEFINE vCodRet						CHAR(5);
	DEFINE iSqlErr						INTEGER;
	DEFINE mImpDia						MONEY(16,2);
	DEFINE mImpMes						MONEY(16,2);
	DEFINE mImpMesDolar					MONEY(14,2);
	DEFINE mImpDiaDolar 				MONEY(14,2);
	DEFINE cMaxDiario 					MONEY(14,2);
	DEFINE cMontoMaxMensual				MONEY(14,2);
	DEFINE iMaxOperaciones          	INTEGER;
	DEFINE dPri_dia_mes		 			DATE;
	DEFINE iNumOperMes					INTEGER;
	DEFINE cMaxDiarioDolar				MONEY(16,2);
	DEFINE cMaxMesDolar 				MONEY(16,2);
	DEFINE cMaxSuc						MONEY(16,2);
	DEFINE cMaxSucDolar					MONEY(16,2);
	DEFINE cMaxEdo						MONEY(16,2);
	DEFINE cMaxEdoDolar 				MONEY(16,2);
	DEFINE iNumOperDia 					INTEGER;
	DEFINE iTotalDiario 				INTEGER;
	DEFINE mTotalMensual				MONEY(16,2);
	DEFINE mTotalDiarioDolar 			MONEY(14,2);
	DEFINE mTotalMensualDolar			MONEY(14,2);
	DEFINE iNumMovsNoUSDHist			INTEGER;
	DEFINE dFechaHoy					DATE;
	DEFINE cRfc							CHAR(13);
	DEFINE cNombres						CHAR(85);
	DEFINE dFechaNac					DATE;
	DEFINE vimporte_pago_dia_usd    	MONEY(16,2);
	DEFINE vimporte_origen_dia_usd  	MONEY(16,2);
	DEFINE vcuenta_dia_usd				INTEGER;
	DEFINE vimporte_pago_dia_no_usd    	MONEY(16,2);
	DEFINE vimporte_origen_dia_no_usd	MONEY(16,2);
	DEFINE vcuenta_dia_no_usd			INTEGER;
	DEFINE vimporte_pago_mes_usd    	MONEY(16,2);
	DEFINE vimporte_origen_mes_usd  	MONEY(16,2);
	DEFINE vcuenta_mes_usd				INTEGER;
	DEFINE vimporte_pago_mes_no_usd    	MONEY(16,2);
	DEFINE vimporte_origen_mes_no_usd	MONEY(16,2);
	DEFINE vcuenta_mes_no_usd			INTEGER;
	DEFINE iCuentasListasNegras			INTEGER;
	DEFINE cUsr                         CHAR(4);
	
	
	-- Inicializa variables
    LET cCodRet 						= "00000";
	LET iSqlErr 						= 0;
	LET	mImpDia							= 0.00;
	LET	mImpMes							= 0.00;
	LET mImpMesDolar					= 0;
	LET mImpDiaDolar					= 0;
	LET cMaxDiario			    		= 0;
	LET cMontoMaxMensual				= 0;
    LET iMaxOperaciones         		= 0;
	LET dPri_dia_mes					= DATE(1);
	LET iNumOperMes						= 0;
	let cMaxMesDolar					= 0;
	LET cMaxSuc							= 0;
	let cMaxSucDolar					= 0;
	LET cMaxEdo							= 0;
	LET cMaxEdoDolar					= 0;
	LET iNumOperDia 					= 0;
	LET iTotalDiario					= 0;
	LET mTotalMensual					= 0;
	LET mTotalDiarioDolar 				= 0;
	LET mTotalMensualDolar				= 0;
	LET iNumMovsNoUSDHist				= 0;
	LET dFechaHoy						= '';
	LET cRfc							= '';
	LET cNombres						= '';
	LET dFechaNac						= '';
	LET iCuentasListasNegras			= 0;
	LET cUsr                            = '';
	

	BEGIN
	
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO '/RESPALDOSNEW/depuraremesas/exec_sp_validamontoremesabts.out';
		--TRACE ON;
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF NVL(p_cEmpresa,"") <> "" AND NVL(p_cNombre1,"") <> "" AND NVL(p_cApellidoPaterno,"") <> "" AND NVL(p_cFechaNacimiento,"") <> "" AND NVL(p_cFechaHoy,"") <> "" AND NVL(p_cMontoAPagar,"") <> "" THEN
		
			LET cNombres = TRIM(p_cNombre1) || " " || TRIM(p_cNombre2);
			LET dFechaNac = MDY(SUBSTRING(p_cFechaNacimiento FROM 5 FOR 2) ,SUBSTRING(p_cFechaNacimiento FROM 7 FOR 2) ,SUBSTRING(p_cFechaNacimiento FROM 1 FOR 4));
			LET dFechaHoy = MDY(SUBSTRING(p_cFechaHoy FROM 5 FOR 2), SUBSTRING(p_cFechaHoy FROM 7 FOR 2), SUBSTRING(p_cFechaHoy FROM 1 FOR 4));
			
			--Calculo el RFC del beneficiario
			EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(p_cApellidoPaterno, p_cApellidoMaterno, cNombres, dFechaNac)
			INTO vCodRet, cRfc;
			
			--Se agrega validacion para verificar si es cliente o si es cualquier usuario
			IF EXISTS(select * from bdinteg:"informix".si_cliente where rfc = TRIM(cRfc)) THEN
			
				--Valida si es cliente 
			
				--maximo de operaciones dia
				SELECT PESOS,USD 
				INTO cMaxDiario,cMaxDiarioDolar
				FROM "informix".sac_limite_monto
				WHERE abreviatura = 'BTS_DIA_'
				AND status = 1;
				
				--maximo de operaciones mensuales y limite en pesos y dolares
				SELECT PESOS,USD,operaciones
				INTO cMontoMaxMensual,cMaxMesDolar,iMaxOperaciones 
				FROM "informix".sac_limite_monto
				WHERE abreviatura = 'BTS_MES_'
				AND status = 1;
				
				--Maximo por sucursal
				SELECT pesos,usd 
				INTO cMaxSuc,cMaxSucDolar
				FROM "informix".sac_limite_suc 
				WHERE abreviatura = 'BTS_DIA_' 
				AND sucursal = p_sucursal--'0005' 
				AND status = 1;
					
				-- maximo por estado
				SELECT PESOS,USD 
				INTO cMaxEdo, cMaxEdoDolar
				FROM "informix".sac_limite_edo e
				INNER JOIN bdinteg:'informix'.si_sucursales s ON (e.estado = s.estado)
				WHERE abreviatura = 'BTS_DIA_'
				AND sucursal = p_sucursal--'0005'--sucursal
				AND status = 1;
			
			ELSE
				
				--Valida si no es cliente 
			
				--maximo de operaciones dia
				SELECT PESOS,USD 
				INTO cMaxDiario,cMaxDiarioDolar
				FROM "informix".sac_limite_monto
				WHERE abreviatura = 'BTS_DIA_'
				AND status = 1;
				
				--maximo de operaciones mensuales y limite en pesos y dolares
				SELECT PESOS,USD,operaciones
				INTO cMontoMaxMensual,cMaxMesDolar,iMaxOperaciones 
				FROM "informix".sac_limite_monto
				WHERE abreviatura = 'BTS_MES_'
				AND status = 1;
				
				--Maximo por sucursal
				SELECT pesos,usd 
				INTO cMaxSuc,cMaxSucDolar
				FROM "informix".sac_limite_suc_usuario 
				WHERE abreviatura = 'BTS_DIA_' 
				AND sucursal = p_sucursal--'0005' 
				AND status = 1;
					
				-- maximo por estado
				SELECT PESOS,USD 
				INTO cMaxEdo, cMaxEdoDolar
				FROM "informix".sac_limite_edo_usuario e
				INNER JOIN bdinteg:'informix'.si_sucursales s ON (e.estado = s.estado)
				WHERE abreviatura = 'BTS_DIA_'
				AND sucursal = p_sucursal--'0005'--sucursal
				AND status = 1;
				
				LET cUsr = '_USR';
				
			END IF;
			
												
			SELECT pri_dia_mes
			INTO dPri_dia_mes
			FROM "informix".sac_fechas;
			
			--Obtengo cifras pagadas durante el mes para el beneficiario
			SELECT NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_dia_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_dia_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN 1 ELSE 0 END),0) cuenta_dia_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_dia_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_dia_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN 1 ELSE 0 END),0) cuenta_dia_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_mes_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_mes_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN 1 ELSE 0 END),0) cuenta_mes_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_mes_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_mes_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN 1 ELSE 0 END),0) cuenta_mes_no_usd
			INTO   vimporte_pago_dia_usd, vimporte_origen_dia_usd, vcuenta_dia_usd, vimporte_pago_dia_no_usd, vimporte_origen_dia_no_usd, vcuenta_dia_no_usd,
			       vimporte_pago_mes_usd, vimporte_origen_mes_usd, vcuenta_mes_usd, vimporte_pago_mes_no_usd, vimporte_origen_mes_no_usd, vcuenta_mes_no_usd
			FROM   sac_remesas_estadistica
			WHERE  rfc               = cRfc
			AND    numcategoria      = '07'
			AND    numconvenio       = '004'
			AND    fecha_pago       >= dPri_dia_mes
			AND    fecha_pago       <= dFechaHoy
			AND    status_cancelado != 'S'
			AND    origen            in('V','T');
			
			--Determino el numero de movimientos hechos en moneda distinta de dolares
			LET iNumMovsNoUSDHist = vcuenta_dia_no_usd + vcuenta_mes_no_usd;
			
			--Determino el numero de operaciones del mes
			LET iNumOperMes	= vcuenta_dia_usd + vcuenta_dia_no_usd + vcuenta_mes_usd + vcuenta_mes_no_usd;
			
			--Determino el numero de operaciones del dia
			LET iNumOperDia = vcuenta_dia_usd + vcuenta_dia_no_usd;
			
			--Reviso si esta en listas negras
			SELECT COUNT(*)
			INTO   iCuentasListasNegras
			FROM   bdiauditor:"informix".tbl_listainterna
			WHERE  rfc = cRfc;
		    
			--Determino casuistica para evaluar si existen cobros hechos en moneda diferente de dolar
			IF iNumMovsNoUSDHist > 0 OR p_moneda <> 'USD' THEN
			
				LET mImpDia = vimporte_pago_dia_usd + vimporte_pago_dia_no_usd;
				LET mImpMes = vimporte_pago_mes_usd + vimporte_pago_mes_no_usd;
				
				--Caso de que algun movimiento (incluyendo el de la peticion) sea diferente de dolares
	   	    	LET iTotalDiario	= mImpDia + p_cMontoAPagar;
				LET mTotalMensual 	= mImpMes + iTotalDiario;
	
				--1. Limite por numero de transacciones (mensual)
				IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales
					LET cCodRet= '00157';
					INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, p_cMontoAPagar, iNumOperMes, (mImpMes + mImpDia), 'BTS_MES_OPE' || cUsr,pNum_confirmacion);
						
					--2. Limite diario por sucursal (17,500 pesos)
				ELIF cMaxSuc > 0 AND (iTotalDiario > cMaxSuc) THEN  --valida monto diario por sucursal
					LET cCodRet= '00158';
					INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, p_cMontoAPagar, iNumOperDia, mImpDia, 'BTS_DIA_SUC_MN' || cUsr,pNum_confirmacion);				
					
					--3. Limite por estado (17,500 pesos)
				ELIF cMaxEdo > 0 AND (iTotalDiario > cMaxEdo) THEN  --valida monto diario por sucursal
					LET cCodRet= '00159';
					INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, p_cMontoAPagar, iNumOperDia, mImpDia, 'BTS_DIA_EDO_MN' || cUsr,pNum_confirmacion);				
					
					--4. Restriccion de listas negras	
				ELIF iCuentasListasNegras > 0 THEN
					LET cCodRet= '00160';
					INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY,  p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, p_cMontoAPagar, iNumOperDia, mImpDia, 'BTS_LISTA' || cUsr,pNum_confirmacion);				
											
					--5. Limite diario (33,000 pesos 
				ELIF iTotalDiario > cMaxDiario THEN  --valida monto diario					
					LET cCodRet= '00161';
					INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY,  p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, p_cMontoAPagar, iNumOperDia, mImpDia, 'BTS_DIA_MN' || cUsr,pNum_confirmacion);				
					
					--6. Limite mensual (66,000 pesos
				ELIF mTotalMensual > cMontoMaxMensual THEN --valida iAcumulado mensual
					LET cCodRet= '00162';
					INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY,  p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, p_cMontoAPagar, iNumOperMes, (mImpMes + mImpDia), 'BTS_MES_MN' || cUsr,pNum_confirmacion);
					
					--7. Limite iAcumulado en todas las remesas (100,000 pesos)
				END IF;
			ELSE
			
				LET mImpDiaDolar = vimporte_origen_dia_usd + vimporte_origen_dia_no_usd;
				LET mImpMesDolar = vimporte_origen_mes_usd + vimporte_origen_mes_no_usd;
					
				LET mTotalDiarioDolar 	= mImpDiaDolar + cMontoDolares;
				LET mTotalMensualDolar 	= mImpMesDolar + mTotalDiarioDolar;

				--1. Limite por numero de transacciones (mensual) 
				IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales				
					LET cCodRet= '00164';
					INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, cMontoDolares, iNumOperMes, (mImpMesDolar + mImpDiaDolar), 'BTS_MES_OPE' || cUsr,pNum_confirmacion);									

					--2. Limite diario por sucursal (800 dolares)
				ELIF cMaxSucDolar > 0 AND (mTotalDiarioDolar > cMaxSucDolar) THEN  --valida monto diario por sucursal
						LET cCodRet= '00165';
						INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY,p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'BTS_DIA_SUC_USD' || cUsr,pNum_confirmacion);				
					
					--3. Limite por estado ( 800 dolares)
				ELIF cMaxEdoDolar > 0 AND (mTotalDiarioDolar > cMaxEdoDolar) THEN  --valida monto diario por sucursal
					LET cCodRet= '00166';
					INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'BTS_DIA_EDO_USD' || cUsr,pNum_confirmacion);	
					
					--4. Restriccion de listas negras
				ELIF iCuentasListasNegras > 0 THEN
					LET cCodRet= '00160';
					INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'BTS_LISTA' || cUsr,pNum_confirmacion);				
							
					--5. Limite diario (800 dolares)
				ELIF mTotalDiarioDolar > cMaxDiarioDolar THEN  --valida monto diario					
					LET cCodRet= '00167';
					INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'BTS_DIA_USD' || cUsr,pNum_confirmacion);				
				
					--6. Limite mensual (1,500 dolares)
				ELIF mTotalMensualDolar > cMaxMesDolar THEN --valida iAcumulado mensual
					LET cCodRet= '00168';
					INSERT INTO "informix".sac_remesaslimitepld_bts (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_sucursal, cMontoDolares,iNumOperMes, (mImpMesDolar + mImpDiaDolar), 'BTS_MES_USD' || cUsr,pNum_confirmacion);
				
					--7. Limite iAcumulado en todas las remesas (5,000 dolares)
				End if;
				
			END if;

			IF cCodRet = '00000' THEN						
				EXECUTE PROCEDURE "informix".sp_validamontos(p_cEmpresa,p_cNombre1,p_cNombre2,p_cApellidoPaterno,p_cApellidoMaterno,p_cFechaNacimiento,p_cFechaHoy,p_cMontoAPagar,p_sucursal,p_moneda,(vimporte_origen_mes_usd + vimporte_origen_mes_no_usd + vimporte_origen_dia_usd + vimporte_origen_dia_no_usd),'BTS',pNum_confirmacion,cRfc,dPri_dia_mes)
				INTO cCodRet;
				
				IF cCodRet = '00001' THEN  --Se excedio en dolares
					LET cCodRet = '00169';
				END IF;
				
				IF cCodRet = '00002' THEN  --Se excedio en pesos
					LET cCodRet = '00163';
				END IF;
			END IF;
						
		ELSE 
			LET cCodRet= '00170';
		END IF;
		RETURN cCodRet;
		
	END 
END PROCEDURE
DOCUMENT
 'AUTOR: Urias Rocha Felipe de Jesus',
 'DESCRIPCION: valida si a un Cliente se le permite Cobrar una envio BTS dependiendo de un monto maximo por dia.',
 'FECHA: 20120417',
 'BD:   bdisac',
 'MODIFICACION',
 'AUTOR: Jose Angel Lopez Adams',
 'DESCRIPCION: Se modifica SP para que la sumatoria de montos pagados se haga sin necesidad de un FOREACH, utilizando un JOIN entre las tablas sac_movimientos y sac_bts_payi',
 'SOLICITA: Jaime Gonzalez Prado',
 'FECHA: 20140509',
 'MODIFICA: Noel Leon',
 'DESCRIPCION: Se agregan validaciones para pesos y dolares',
 'FOLIO: 222-limite de remesas',
 'FECHA: 29/05/2017';

CREATE PROCEDURE "informix".sp_validamontoremesawu_web(
p_cEmpresa 				CHAR(3),
p_cNombre1 				CHAR(40),
p_cNombre2 				CHAR(40),
p_cApellidoPaterno 		CHAR(40),
p_cApellidoMaterno 		CHAR(40),
p_cFechaNacimiento 		CHAR(8),
p_cFechaHoy 			CHAR(10),
p_cEstado 				CHAR(2),
p_mMontoAPagar 			CHAR(20),
p_cSucursal 			CHAR(4), 
p_moneda 				CHAR(3),
cMontoDolares 			MONEY(16,2),
pNum_confirmacion 		CHAR(16),
p_retcode 				CHAR(5),
p_desc_error 			CHAR(250),
p_mtcn 					CHAR(10),
p_new_mtcn 				CHAR(16),
p_foreign_rs_refnum_rq 	CHAR(16),
pEmisorNameType 		CHAR(1),
pBenefNameType 			CHAR(1),
pMoneyTransKey 			CHAR(10),
pForeignRsRefNumRp 		CHAR(16),
pFusionStatus 			CHAR(4),
pEmisorCodMoneda 		CHAR(3),
pBenefEdo 				CHAR(40),
pForeignRsSystemIdRp 	CHAR(11)
)

RETURNING CHAR(5) AS cod_ret;

    --Definicion de Variables
    DEFINE cCodRet      				CHAR(5);
	DEFINE cCodRetWu      				CHAR(5);
	DEFINE vCodRet						CHAR(5);
	DEFINE iSqlErr						INTEGER;
	DEFINE mImpDia						MONEY(16,2); -- FOLIO: 1508 --12/11/2015	
	DEFINE mImpMes						MONEY(16,2); -- FOLIO: 1508 --12/11/2015	
	DEFINE cEstado                 		CHAR(2);		
	DEFINE mMontoMaxMensual				MONEY(16,2); -- FOLIO: 1508 -- 02/11/2015
	DEFINE dPri_dia_mes					DATE; 	    -- FOLIO: 1508 -- 02/11/2015
	DEFINE mTotalDiario					MONEY(16,2);	
	DEFINE mTotalMensual				MONEY(16,2);
	DEFINE iNumOperMes					INTEGER;
	DEFINE iNumOperDia					INTEGER;
	DEFINE cMaxDiario 					MONEY(16,2);
	DEFINE cMaxDiarioDolar				MONEY(16,2);
	DEFINE cMaxMesDolar 				MONEY(16,2);
	DEFINE iMaxOperaciones          	INTEGER;
	DEFINE cMaxSuc						MONEY(16,2);
	DEFINE cMaxSucDolar					MONEY(16,2);
	DEFINE cMaxEdo						MONEY(16,2);
	DEFINE cMaxEdoDolar 				MONEY(16,2);
	DEFINE mImpMesDolar					MONEY(14,2);
	DEFINE mImpDiaDolar 				MONEY(14,2);
	define mTotalDiarioDolar 			MONEY(14,2);
	define mTotalMensualDolar 			MONEY(14,2);
	DEFINE iNumMovsNoUSDHist			INTEGER;
	DEFINE iNumMovsNoUSD				INTEGER;
	DEFINE cFechaNacimiento				CHAR(10);
	DEFINE cFechaHoy					CHAR(10);
	DEFINE cSPCodRet 					CHAR(5); 
	DEFINE iMensaje 					CHAR(50);
	DEFINE cid_ptf	 					CHAR(5); 
	DEFINE ccve_pais 					CHAR(3);
	DEFINE cnompais 					CHAR(20);
	DEFINE ccalle 						VARCHAR(100); 
	DEFINE cnum_ext 					VARCHAR(6); 
	DEFINE cnum_int 					VARCHAR(5); 
	DEFINE ccve_col 					CHAR(8);
	DEFINE cnomcol 						VARCHAR(100);
	DEFINE ccve_mun 					CHAR(3);
	DEFINE cnommunicipio 				VARCHAR(60);
	DEFINE ccve_localidad 				CHAR(14);
	DEFINE cnomlocalidad 				VARCHAR(60);
	DEFINE ccp 							CHAR(5); 
	DEFINE ccve_ciudad 					CHAR(3);
	DEFINE cnomciudad 					VARCHAR(60);
	DEFINE ccve_estado 					CHAR(2); 
	DEFINE cnomestado 					VARCHAR(30);
	DEFINE ctel1 						VARCHAR(14); 
	DEFINE ctel2 						VARCHAR(14);
	DEFINE ctipo 						VARCHAR(5);
	DEFINE dFechaHoy					DATE;
	DEFINE cRfc							CHAR(13);
	DEFINE cNombres						CHAR(85);
	DEFINE dFechaNac					DATE;
	DEFINE vimporte_pago_dia_usd    	MONEY(16,2);
	DEFINE vimporte_origen_dia_usd  	MONEY(16,2);
	DEFINE vcuenta_dia_usd				INTEGER;
	DEFINE vimporte_pago_dia_no_usd    	MONEY(16,2);
	DEFINE vimporte_origen_dia_no_usd	MONEY(16,2);
	DEFINE vcuenta_dia_no_usd			INTEGER;
	DEFINE vimporte_pago_mes_usd    	MONEY(16,2);
	DEFINE vimporte_origen_mes_usd  	MONEY(16,2);
	DEFINE vcuenta_mes_usd				INTEGER;
	DEFINE vimporte_pago_mes_no_usd    	MONEY(16,2);
	DEFINE vimporte_origen_mes_no_usd	MONEY(16,2);
	DEFINE vcuenta_mes_no_usd			INTEGER;
	DEFINE iCuentasListasNegras			INTEGER;
	DEFINE vCategoria 					CHAR(2);
	DEFINE vConvenio  					CHAR(5);
	DEFINE cUsr                         CHAR(4);
	
	-- Inicializa variables
    LET cCodRet 						= "00000";
	LET cCodRetWu 						= "00000";
	LET iSqlErr	 						= 0;
	LET	mImpDia							= 0.00;
	LET	mImpMes							= 0.00;
	LET cEstado                     	= "";
	LET mMontoMaxMensual				= 0.00;
	LET dPri_dia_mes					= DATE(1);	
	LET	mTotalDiario					= 0.00;	
	LET mTotalMensual					= 0.00;
	LET iNumOperMes						= 0;
	LET iNumOperDia						= 0;
	LET cMaxDiario						= 0;
	LET cMaxDiarioDolar 				= 0;
	LET cMaxMesDolar 			    	= 0;
	LET iMaxOperaciones					= 0;
	LET cMaxSuc                     	= 0;
	LET cMaxSucDolar                	= 0;
	LET cMaxEdo							= 0;
	LET cMaxEdoDolar 					= 0;
	LET mImpMesDolar					= 0;
	LET mImpDiaDolar					= 0;
	let mTotalDiarioDolar           	= 0;
	let mTotalMensualDolar          	= 0;
	LET iNumMovsNoUSDHist				= 0;
	LET iNumMovsNoUSD					= 0;
	LET cFechaNacimiento				= '';
	LET cFechaHoy						= '';
	LET cMontoDolares					= cMontoDolares / 100.00;
	LET cSPCodRet 						= '00000';
	LET iMensaje 						= '';
	LET cid_ptf 						= '';
	LET ccve_pais 						= '';
	LET cnompais 						= '';
	LET ccalle 							= '';
	LET cnum_ext 						= ''; 
	LET cnum_int 						= '';
	LET ccve_col 						= '';
	LET cnomcol 						= '';
	LET ccve_mun 						= '';
	LET cnommunicipio 					= '';
	LET ccve_localidad 					= '';
	LET cnomlocalidad 					= '';
	LET ccp 							= '';
	LET ccve_ciudad 					= '';
	LET cnomciudad 						= '';
	LET ccve_estado 					= ''; 
	LET cnomestado 						= '';
	LET ctel1 							= '';
	LET ctel2 							= '';
	LET ctipo 							= '';
	LET dFechaHoy						= '';
	LET cRfc							= '';
	LET cNombres						= '';
	LET dFechaNac						= '';
	LET iCuentasListasNegras			= 0;
	LET vCategoria						= '07';
	LET vConvenio						= '999';
	LET vCodRet							= '000000';
	LET cUsr                            = '';


	BEGIN
		ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				RETURN cCodRet;
            END IF;
        END EXCEPTION;
		
		--SET DEBUG FILE TO "/RESPALDOSNEW/depuraremesas/sp_validamontoremesawu_web.out";
	    --TRACE ON;

        SET ISOLATION TO DIRTY READ;
	    SET LOCK MODE TO WAIT 3;
		
		IF NVL(p_cEmpresa,"") <> "" AND NVL(p_cNombre1,"") <> "" AND NVL(p_cApellidoPaterno,"") <> "" AND NVL(p_cFechaNacimiento,"") <> "" AND NVL(p_cFechaHoy,"") <> "" AND NVL(p_cEstado,"") <> "" AND NVL(p_mMontoAPagar,"") <> "" THEN
		
			--LET cFechaNacimiento = SUBSTRING (p_cFechaNacimiento FROM 5 FOR 4)||SUBSTRING (p_cFechaNacimiento FROM 3 FOR 2)||SUBSTRING (p_cFechaNacimiento FROM 1 FOR 2);
			--LET cFechaHoy = SUBSTRING(p_cFechaHoy FROM 5 FOR 4)||SUBSTRING(p_cFechaHoy FROM 3 FOR 2)||SUBSTRING(p_cFechaHoy FROM 1 FOR 2);
			
			--LET cFechaNacimiento = SUBSTRING (p_cFechaNacimiento FROM 1 FOR 2)||SUBSTRING (p_cFechaNacimiento FROM 3 FOR 2)||SUBSTRING (p_cFechaNacimiento FROM 5 FOR 4);
			--LET cFechaHoy = SUBSTRING(p_cFechaHoy FROM 1 FOR 2)||SUBSTRING(p_cFechaHoy FROM 3 FOR 2)||SUBSTRING(p_cFechaHoy FROM 5 FOR 4);
			
			LET cFechaNacimiento = SUBSTRING (p_cFechaNacimiento FROM 5 FOR 4)||SUBSTRING (p_cFechaNacimiento FROM 3 FOR 2)||SUBSTRING(p_cFechaNacimiento FROM 1 FOR 2);
			--LET cFechaHoy_test = SUBSTRING(p_cFechaHoy FROM 1 FOR 4)||SUBSTRING(p_cFechaHoy FROM 6 FOR 2)||SUBSTRING(p_cFechaHoy FROM 9 FOR 2);
			LET cFechaHoy = SUBSTRING (p_cFechaHoy FROM 5 FOR 4)||SUBSTRING (p_cFechaHoy FROM 3 FOR 2)||SUBSTRING(p_cFechaHoy FROM 1 FOR 2);
			
			LET cNombres  = TRIM(p_cNombre1) || " " || TRIM(p_cNombre2);
			
			LET dFechaNac = MDY(SUBSTRING(p_cFechaNacimiento FROM 3 FOR 2) ,SUBSTRING(p_cFechaNacimiento FROM 1 FOR 2) ,SUBSTRING(p_cFechaNacimiento FROM 5 FOR 4));
			
			--Calculo el RFC del beneficiario
			EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(p_cApellidoPaterno, p_cApellidoMaterno, cNombres, dFechaNac)
			INTO vCodRet, cRfc;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_consucursales(p_cSucursal) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
			IF cSPCodRet != '00000' THEN
				LET cCodRet = "00002";
				RETURN cCodRet;
			ELSE
				LET cEstado = ccve_estado;						
			END IF;	
			
			IF EXISTS(select * from bdinteg:"informix".si_cliente where rfc = TRIM(cRfc)) THEN
			
				--Valida si es cliente
				
				SELECT PESOS,USD
				INTO cMaxDiario,cMaxDiarioDolar
				FROM bdisac:"informix".sac_limite_monto
				WHERE abreviatura = 'WU_DIA_'
				AND status = 1;

				--maximo de operaciones mensuales y limite en pesos y dolares
				SELECT PESOS,USD,operaciones
				INTO mMontoMaxMensual,cMaxMesDolar,iMaxOperaciones 
				FROM bdisac:"informix".sac_limite_monto
				WHERE abreviatura = 'WU_MES_'
				AND status = 1;
				
				--Maximo por sucursal
				SELECT pesos,usd 
				INTO cMaxSuc,cMaxSucDolar
				FROM bdisac:"informix".sac_limite_suc 
				WHERE abreviatura = 'WU_DIA_' 
				AND sucursal = p_cSucursal 
				AND status = 1;
				
				-- maximo por estado
				SELECT PESOS,USD 
				INTO cMaxEdo, cMaxEdoDolar
				FROM bdisac:"informix".sac_limite_edo
				WHERE abreviatura = 'WU_DIA_'			
				AND status = 1
				AND estado = cEstado;
			
			ELSE
				
				--Valida si no es cliente
				
				SELECT PESOS,USD
				INTO cMaxDiario,cMaxDiarioDolar
				FROM bdisac:"informix".sac_limite_monto
				WHERE abreviatura = 'WU_DIA_'
				AND status = 1;

				--maximo de operaciones mensuales y limite en pesos y dolares
				SELECT PESOS,USD,operaciones
				INTO mMontoMaxMensual,cMaxMesDolar,iMaxOperaciones 
				FROM bdisac:"informix".sac_limite_monto
				WHERE abreviatura = 'WU_MES_'
				AND status = 1;
				
				--Maximo por sucursal
				SELECT pesos,usd 
				INTO cMaxSuc,cMaxSucDolar
				FROM bdisac:"informix".sac_limite_suc_usuario 
				WHERE abreviatura = 'WU_DIA_' 
				AND sucursal = p_cSucursal 
				AND status = 1;
				
				-- maximo por estado
				SELECT PESOS,USD 
				INTO cMaxEdo, cMaxEdoDolar
				FROM bdisac:"informix".sac_limite_edo_usuario
				WHERE abreviatura = 'WU_DIA_'			
				AND status = 1
				AND estado = cEstado;
				
				LET cUsr = '_USR';
				
			END IF;
			
			
			SELECT pri_dia_mes
			INTO dPri_dia_mes
			FROM bdinteg:"informix".si_fechas;
			
			
			LET dFechaHoy = MDY(SUBSTRING(p_cFechaHoy FROM 3 FOR 2), SUBSTRING(p_cFechaHoy FROM 1 FOR 2), SUBSTRING(p_cFechaHoy FROM 5 FOR 4));
			
			--Obtengo cifras pagadas durante el mes para el beneficiario
			SELECT NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_dia_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_dia_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago  = dFechaHoy THEN 1 ELSE 0 END),0) cuenta_dia_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_dia_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_dia_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago  = dFechaHoy THEN 1 ELSE 0 END),0) cuenta_dia_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_mes_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_mes_usd,
				   NVL(SUM(CASE WHEN moneda_origen = 'USD'  AND fecha_pago != dFechaHoy THEN 1 ELSE 0 END),0) cuenta_mes_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN importe_pago ELSE 0 END),0) importe_pago_mes_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN importe_origen ELSE 0 END),0) importe_origen_mes_no_usd,
				   NVL(SUM(CASE WHEN moneda_origen != 'USD' AND fecha_pago != dFechaHoy THEN 1 ELSE 0 END),0) cuenta_mes_no_usd
			INTO   vimporte_pago_dia_usd, vimporte_origen_dia_usd, vcuenta_dia_usd, vimporte_pago_dia_no_usd, vimporte_origen_dia_no_usd, vcuenta_dia_no_usd,
			       vimporte_pago_mes_usd, vimporte_origen_mes_usd, vcuenta_mes_usd, vimporte_pago_mes_no_usd, vimporte_origen_mes_no_usd, vcuenta_mes_no_usd
			FROM   bdisac:"informix".sac_remesas_estadistica
			WHERE  rfc               =  cRfc
			AND    numcategoria      =  '07'
			AND    numconvenio       IN ('006', '007', '008')
			AND    fecha_pago       >=  dPri_dia_mes
			AND    fecha_pago     	<=  dFechaHoy
			AND    status_cancelado	!=  'S'
			AND    origen            in ('V','T');
			
			--Determino el numero de movimientos hechos en moneda distinta de dolares
			LET iNumMovsNoUSDHist = vcuenta_dia_no_usd + vcuenta_mes_no_usd;
			
			--Determino el numero de operaciones del mes
			LET iNumOperMes	= vcuenta_dia_usd + vcuenta_dia_no_usd + vcuenta_mes_usd + vcuenta_mes_no_usd;
			
			--Determino el numero de operaciones del dia
			LET iNumOperDia = vcuenta_dia_usd + vcuenta_dia_no_usd;
			
			--Reviso si esta en listas negras
			SELECT COUNT(*)
			INTO   iCuentasListasNegras
			FROM   bdiauditor:"informix".tbl_listainterna
			WHERE  rfc = cRfc;
				
			--Determino casuistica para evaluar si existen cobros hechos en moneda diferente de dolar
			IF iNumMovsNoUSDHist > 0 OR p_moneda <> 'USD' THEN
			
				LET mImpDia = vimporte_pago_dia_usd + vimporte_pago_dia_no_usd;
				LET mImpMes = vimporte_pago_mes_usd + vimporte_pago_mes_no_usd;
			
				--Caso de que algun movimiento (incluyendo el de la peticion) sea diferente de dolares
				LET mTotalDiario  = mImpDia + CAST(p_mMontoAPagar AS MONEY(14,2));
				LET mTotalMensual = mImpMes + mTotalDiario;

				--1. Limite por numero de transacciones (mensual) p_cEmpresa CHAR(3), p_cNombre1 CHAR(40), p_cNombre2 CHAR(40), p_cApellidoPaterno CHAR(40), p_cApellidoMaterno CHAR(40), p_cFechaNacimiento CHAR(8), p_cFechaHoy CHAR(8) , p_cMontoAPagar CHAR(20),p_cSucursal  CHAR(4),p_moneda CHAR(3),cMontoDolares Money(16,2),pNum_confirmacion
				IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales
					LET cCodRet= '00157';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperMes, (mImpMes + mImpDia), 'WU_MES_OPE' || cUsr,pNum_confirmacion);
						
					--2. Limite diario por sucursal (17,500 pesos / 800 dolares)
				ELIF cMaxSuc > 0 AND (mTotalDiario > cMaxSuc) THEN  --valida monto diario por sucursal
					LET cCodRet= '00158';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperDia, mImpDia, 'WU_DIA_SUC_MN' || cUsr,pNum_confirmacion);				
					
					--3. Limite por estado (17,500 pesos / 800 dolares)
				ELIF cMaxEdo > 0 AND (mTotalDiario > cMaxEdo) THEN  --valida monto diario por sucursal
					LET cCodRet= '00159';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperDia,mImpDia, 'WU_DIA_EDO_MN' || cUsr,pNum_confirmacion);
					
					--4. Restriccion de listas negras	 p_cApellidoPaterno CHAR(40), p_cApellidoMaterno CHAR(40), p_cFechaNacimiento PENDIENTE COMENTARIO
				ELIF iCuentasListasNegras > 0 THEN
					LET cCodRet= '00160';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY,  p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperDia, mImpDia, 'WU_LISTA' || cUsr,pNum_confirmacion);				
											
					--5. Limite diario (33,000 pesos / 800 dolares)
				ELIF mTotalDiario > cMaxDiario THEN  --valida monto diario					
					LET cCodRet= '00161';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY,  p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperDia, mImpDia, 'WU_DIA_MN' || cUsr,pNum_confirmacion);				
					
					--6. Limite mensual (66,000 pesos / 1,500 dolares)
				ELIF mTotalMensual > mMontoMaxMensual THEN --valida acumulado mensual
					LET cCodRet= '00162';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY,  p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, p_mMontoAPagar, iNumOperMes, (mImpMes + mImpDia), 'WU_MES_MN' || cUsr,pNum_confirmacion);
					
				END IF;
			ELSE
			
				LET mImpDiaDolar = vimporte_origen_dia_usd + vimporte_origen_dia_no_usd;
				LET mImpMesDolar = vimporte_origen_mes_usd + vimporte_origen_mes_no_usd;
			
				LET mTotalDiarioDolar    = mImpDiaDolar + cMontoDolares;
				LET mTotalMensualDolar = mImpMesDolar + mTotalDiarioDolar;

				--1. Limite por numero de transacciones (mensual) p_cEmpresa CHAR(3), p_cNombre1 CHAR(40), p_cNombre2 CHAR(40), p_cApellidoPaterno CHAR(40), p_cApellidoMaterno CHAR(40), p_cFechaNacimiento CHAR(8), p_cFechaHoy CHAR(8) , p_cMontoAPagar CHAR(20),p_cSucursal  CHAR(4),p_moneda CHAR(3),cMontoDolares Money(16,2),pNum_confirmacion
				IF iNumOperMes >= iMaxOperaciones THEN --valida numero de operaciones mensuales				
					LET cCodRet= '00164';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, cMontoDolares, iNumOperMes, (mImpMesDolar + mImpDiaDolar), 'WU_MES_OPE' || cUsr,pNum_confirmacion);									

					--2. Limite diario por sucursal (17,500 pesos / 800 dolares)
				ELIF cMaxSucDolar > 0 AND (mTotalDiarioDolar > cMaxSucDolar) THEN  --valida monto diario por sucursal
						LET cCodRet= '00165';
						INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
						VALUES (TODAY,p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'WU_DIA_SUC_USD' || cUsr,pNum_confirmacion);				
					
					--3. Limite por estado (17,500 pesos / 800 dolares)
				ELIF cMaxEdoDolar > 0 AND (mTotalDiarioDolar > cMaxEdoDolar) THEN  --valida monto diario por sucursal
					LET cCodRet= '00166';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'WU_DIA_EDO_USD' || cUsr,pNum_confirmacion);	
					
					--4. Restriccion de listas negras
				ELIF iCuentasListasNegras > 0 THEN
					LET cCodRet= '00160';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'WU_LISTA' || cUsr,pNum_confirmacion);				
							
					--5. Limite diario (33,000 pesos / 800 dolares)
				ELIF mTotalDiarioDolar > cMaxDiarioDolar THEN  --valida monto diario					
					LET cCodRet= '00167';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal, cMontoDolares, iNumOperDia, mImpDiaDolar, 'WU_DIA_USD' || cUsr,pNum_confirmacion);				
				
					--6. Limite mensual (66,000 pesos / 1,500 dolares)
				ELIF mTotalMensualDolar > cMaxMesDolar THEN --valida acumulado mensual
					LET cCodRet= '00168';
					INSERT INTO bdisac:"informix".sac_remesaslimitepld_wu (fecha, nombre1, nombre2, apellidopaterno, apellidomaterno, fechanacimiento, sucursal, montopagar, numoperaciones, montoacumulado, codigo,numconfirmacion)
					VALUES (TODAY, p_cNombre1, p_cNombre2, p_cApellidoPaterno, p_cApellidoMaterno, p_cFechaNacimiento, p_cSucursal,cMontoDolares, iNumOperMes, (mImpMesDolar + mImpDiaDolar), 'WU_MES_USD' || cUsr,pNum_confirmacion);
				
				End IF;		

			END IF;

			IF cCodRet = '00000' THEN
				EXECUTE PROCEDURE bdisac:"informix".sp_validamontos(p_cEmpresa,p_cNombre1,p_cNombre2,p_cApellidoPaterno,p_cApellidoMaterno,cFechaNacimiento,cFechaHoy,p_mMontoAPagar,p_cSucursal,p_moneda,cMontoDolares,'WU',pNum_confirmacion,cRfc,dPri_dia_mes)
				INTO cCodRet;
				
				IF cCodRet = '00001' THEN  --Se excedio en dolares
					LET cCodRet = '00169';
				END IF;
				
				IF cCodRet = '00002' THEN  --Se excedio en pesos
					LET cCodRet = '00163';
				END IF
				
				EXECUTE PROCEDURE bdisac:"informix".sp_grabaremadic(vCategoria, vConvenio, p_mtcn, pEmisorCodMoneda, cMontoDolares)
				INTO vCodRet;
				
				-- IF cCodRet = '00000' THEN --hsrr
					-- EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_search(p_foreign_rs_refnum_rq,p_mtcn,p_retcode,pEmisorNameType,pBenefNameType,pMoneyTransKey,p_new_mtcn,pForeignRsRefNumRp,p_desc_error,SUBSTRING(p_foreign_rs_refnum_rq FROM 1 FOR 8),cMontoDolares,pFusionStatus,pEmisorCodMoneda,pBenefEdo,p_cSucursal,pForeignRsSystemIdRp,SUBSTRING(p_foreign_rs_refnum_rq FROM 1 FOR 8))
					-- INTO cCodRetWu, p_desc_error;
				-- END IF;
			END IF;

		ELSE   
		   LET cCodRet = "00170";
		   RETURN cCodRet;
		END IF;					
		
		RETURN cCodRet;		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÃÂÃÂÃÂÃÂN: Valida si a un Cliente se le permite Cobrar una envio WU dependiendo de un monto maximo por dia.',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sacreportedetalletransaccionsucursal2 (pUsuario CHAR(8), 
                                                                    pIdFuncion CHAR(10), 
                                                                    dFechaIni DATE, 
                                                                    dFechaFin DATE,
                                                                    pRegistros INTEGER,
                                                                    pRecuperacion INTEGER)

-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno, --Codigo de Retorno
CHAR(8) AS usuario,
CHAR(16) AS folio_suc,
CHAR(40) AS nomconvenio,
CHAR(20) AS referencia1,
CHAR(20) AS referencia2,
DATETIME YEAR to FRACTION(3) AS Fecha_Operacion,
DATE AS Fecha_Aplicacion,
MONEY(16,2) AS importe_pago,
MONEY(16,2) AS importe_comision_convenio,
MONEY(16,2) AS iva_comision_convenio,
MONEY(16,2) AS importe_comision_cte,
MONEY(16,2) AS iva_comision_cte,
CHAR(1) AS forma_pago,
CHAR(12) AS cuenta_cargo,
CHAR(40) AS region;


-- DEFINICION DE VARIABLES
DEFINE cCodRet                  CHAR(5);
DEFINE iSqlErr                  INTEGER;
DEFINE cUsuario                 CHAR(8);
DEFINE cFolioSuc                CHAR(16);
DEFINE cNomconvenio             CHAR(40);
DEFINE cReferencia1             CHAR(20);
DEFINE cReferencia2             CHAR(20);
DEFINE mImpComisionConvenio    MONEY(16,2);
DEFINE mIVAComisionConvenio    MONEY(16,2);
DEFINE mImpComisionCte         MONEY(16,2);
DEFINE mIVAComisionCte         MONEY(16,2);
DEFINE mImportePago            MONEY(16,2);
DEFINE cFormaPago               CHAR(1);
DEFINE cCuentaCargo             CHAR(12);
DEFINE cRegion                  CHAR(40);
DEFINE iNoRegistros             INTEGER;
DEFINE cFechaOperacion          DATETIME YEAR to FRACTION(3);
DEFINE cFechaAplicacion         DATE;

--SET DEBUG FILE TO "/tmp/mfinis/sp_sacreportedetalletransaccionsucursal2.out";
--TRACE ON;


--INICIALIZACION DE VARIABLES--
LET cCodRet               = "00000";
LET cUsuario              = "";
LET cFolioSuc             = "";
LET cNomConvenio          = "";
LET cReferencia1          = "";
LET cReferencia2          = "";
LET mImportePago         = 0;
LET mImpComisionConvenio = 0;
LET mIVAComisionConvenio = 0;
LET mImpComisionCte      = 0;
LET mIVAComisionCte      = 0;
LET cFormaPago            = "";
LET cCuentaCargo          = "";
LET cRegion               = "";
LET iNoRegistros          = 0;
LET cFechaOperacion       = "";
LET cFechaAplicacion      = "";


BEGIN

    ON EXCEPTION SET iSqlErr

        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, cFechaOperacion, cFechaAplicacion, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
        END IF;
    END EXCEPTION;
    
        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		    RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, cFechaOperacion, cFechaAplicacion, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
		END IF;

    IF pIdFuncion = "" OR  pUsuario = ""  THEN
        LET cCodRet = "00003";
        RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, cFechaOperacion, cFechaAplicacion, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
    ELSE
            FOREACH
                SELECT --{+INDEX(bdisac:sac_convenios idx_sac_convenios)} 
                SKIP pRegistros FIRST pRecuperacion b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.fecha_insert, b.fecha_pago, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
                b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre
                INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, cFechaOperacion, cFechaAplicacion, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e
                WHERE b.fecha_pago >= dFechaIni
                AND b.fecha_pago <= dFechaFin
                AND b.numcategoria = '08'
                AND b.numconvenio = '001'
                AND a.numcategoria = b.numcategoria
                AND a.numconvenio = b.numconvenio
                AND b.id_sucursal IN ('5003','5008','5011') 
                AND b.status_cancelado <> 'S'
                AND flag_confirmacion_central = 1
                AND flag_confirmacion_sucursal = 1
                AND c.sucursal = b.id_sucursal
                AND d.plaza = c.plaza
                AND e.regional = d.regional
                ORDER BY 3  ASC
                LET iNoRegistros = iNoRegistros + 1;
                RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, cFechaOperacion, cFechaAplicacion, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                WITH RESUME;
            END FOREACH;
    END IF;

     IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, cFechaOperacion, cFechaAplicacion, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;

	ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, cFechaOperacion, cFechaAplicacion, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
	END IF;		
END;
END PROCEDURE
DOCUMENT
'AUTOR : JosÃ© Antonio RamÃ­rez Franco',
'DESCRIPCION: Procedimiento almacenado encargado de obtener los registros de la tabla bdisac:sac_movimientoshistorial de Central del convenio 08 y sucuarsales 5003,5008 y 5011',
'FECHA : 07/12/2023',
'AUTOR : Mario Gonzalez Vazquez',
'DESCRIPCION: Se modifica la consulta y se crean variables en el SPL para agregar los siguientes campos: fecha_insert fecha_pago de la tabla: bdisac:sac_movimientoshistorial',
'FECHA : 28/02/2024',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_actualizahistoricodetransacciones(dFecha_hoy DATE)

    RETURNING CHAR(5);  --CÃDIGO DE RETORNO

    DEFINE cCodRet                  CHAR(5);
    DEFINE cCodRetSP                CHAR(5);
    DEFINE cInfoErr                 CHAR(100);
    DEFINE iSqlErr                  INTEGER;
    DEFINE iIsamErr                 INTEGER;

    DEFINE cClave                       CHAR(1);
    DEFINE cTipomovimiento                      CHAR(1);
    DEFINE iSucursal                            SMALLINT;
    DEFINE iCiudad                                      SMALLINT;
    DEFINE iCliente                             INTEGER;
    DEFINE iClienteetp                          INTEGER;
    DEFINE iCaja                                        SMALLINT;
    DEFINE iRecibo                                      INTEGER;
    DEFINE iFactura                 INTEGER;
    DEFINE iImporte                 INTEGER;
    DEFINE iSaldoinicial            INTEGER;
    DEFINE iSaldofinal              INTEGER;
    DEFINE iSaldocuenta             INTEGER;
    DEFINE iVencidoinicial          INTEGER;
    DEFINE iMinimoinicial           INTEGER;
    DEFINE iMontodolar              INTEGER;
    DEFINE iBase                    INTEGER;
    DEFINE dFechasaldacon           DATE;
    DEFINE iImportesaldacon         INTEGER;
    DEFINE cTipoconvenio            CHAR(1);
    DEFINE cSubtipoconvenio         CHAR(1);
    DEFINE iPlazoconvenio           SMALLINT;
    DEFINE cEjercicio               CHAR(1);
    DEFINE cClavetdaocob            CHAR(1);
    DEFINE cGrabacartera            CHAR(1);
    DEFINE cAnexo                   CHAR(1);
    DEFINE cClavelocal              CHAR(1);
    DEFINE cClientelocalizar        CHAR(1);
    DEFINE cTiposeguro              CHAR(1);
    DEFINE cFlagseguroconyugal      CHAR(1);
    DEFINE cMovtoseguro             CHAR(1);
    DEFINE cFlagmontoseguro         CHAR(1);
    DEFINE cStatusseguro            CHAR(1);
    DEFINE iCausabaja               SMALLINT;
    DEFINE iCantidadseguros         SMALLINT;
    DEFINE iCantidadsegurosanterior SMALLINT;
    DEFINE iCantidadmeses           SMALLINT;
    DEFINE iBonificacion            INTEGER;
    DEFINE iMesesvencidos           SMALLINT;
    DEFINE dFechanacimiento         DATE;
    DEFINE iEdad                    SMALLINT;
    DEFINE cSexo                    CHAR(1);
    DEFINE cAreaajuste              CHAR(1);
    DEFINE dFechaabonoajuste        DATE;
    DEFINE cClaveajuste             CHAR(2);
    DEFINE cAjuste                  CHAR(2);
    DEFINE iSsucursalorigen         SMALLINT;
    DEFINE iNumerocontrol           INTEGER;
    DEFINE iComision                INTEGER;
    DEFINE iClienteremitente        INTEGER;
    DEFINE cTipogastoviaje          CHAR(1);
    DEFINE iCentro                  INTEGER;
    DEFINE cFlagincluyerecibo       CHAR(1);
    DEFINE iRuta                    INTEGER;
    DEFINE iFolio                   INTEGER;
    DEFINE cCuenta                  CHAR(20);
    DEFINE iIva                     INTEGER;
    DEFINE iTelefono                INT8;
    DEFINE cCompania                CHAR(1);
    DEFINE cContrato                CHAR(22);
    DEFINE cCredito                 CHAR(15);
    DEFINE fFechavencimiento        DATE;
    DEFINE fFechavencimientoanterior DATE;
    DEFINE fFecha                   DATE;
    DEFINE iEfectuo                 INTEGER;
    DEFINE iCajaoriginal            SMALLINT;
    DEFINE iFoliosucursal           INT8;
    DEFINE cRpu                     CHAR(12);
    DEFINE cFlagmovtosupervisor     CHAR(1);
    DEFINE iInteres                 INTEGER;
    DEFINE iImporteventa            INTEGER;
    DEFINE iFolioanterior           INTEGER;
    DEFINE iDigito                  SMALLINT;
    DEFINE cSac                     CHAR(9);
    DEFINE dFechadocumento          DATE;
    DEFINE iNumerocuenta            INTEGER;
    DEFINE iNumerosubcuenta         INTEGER;
    DEFINE iNumeroconcepto          SMALLINT;
    DEFINE iRegistropatronal        CHAR(11);
    DEFINE iFormaaportacionafore    SMALLINT;
    DEFINE cIpcarteracliente        CHAR(15);
    DEFINE dFechamovto              DATE;
    DEFINE iCandidato               SMALLINT;
    DEFINE iStatusafore             SMALLINT;
    DEFINE cStatus_coppel           CHAR(1);

    DEFINE cStatus_cancelado        CHAR(1);

--20110907-I
        DEFINE vmax_fechaold            DATE;
        DEFINE vfecharesp               DATE;
        DEFINE vcontregshist                    INTEGER;
        DEFINE vcontregsold                             INTEGER;
        DEFINE vMensaje CHAR (200);
        DEFINE vcodretODP CHAR (5);
        DEFINE vcodretBTS CHAR (5);
        DEFINE iCte_prospecto                   INT8;
--20110907-F
        DEFINE vfechacomp               DATE;

        DEFINE iCont                            INT;
        ---------------------------------------------------------------------------------------
        -- Variables para insersiÃ³n -----------------------------------------------------------
        DEFINE pid_sucursal                     CHAR(4);
        DEFINE pnumcategoria                    CHAR(2);
        DEFINE pnumconvenio                     CHAR(5);
        DEFINE preferencia1                     CHAR(40);
        DEFINE preferencia2                     CHAR(40);
        DEFINE pforma_pago                      CHAR(1);
        DEFINE pimporte_pago                    MONEY;
        DEFINE pimporte_comision_convenio       MONEY;
        DEFINE piva_comision_convenio           MONEY;
        DEFINE pimporte_comision_cte            MONEY;
        DEFINE piva_comision_cte                MONEY;
        DEFINE pcuenta_cargo                    CHAR(12);
        DEFINE pusuario                         CHAR(8);
        DEFINE pfolio_suc                       CHAR(16);
        DEFINE ptransacc_suc                    CHAR(4);
        DEFINE pflag_confirmacion_central       SMALLINT;
        DEFINE pflag_confirmacion_sucursal      SMALLINT;
        DEFINE pfecha_pago                      DATE;
        DEFINE pfecha_insert                    DATETIME YEAR TO SECOND;
        DEFINE pstatus_cancelado                CHAR(1);
        DEFINE porigen                          CHAR(4);
        DEFINE psucursal_cpl                    CHAR(4);
        DEFINE pcaja_cpl                        CHAR(3);
        DEFINE ptransaccion                     CHAR(5);
        DEFINE phora                            CHAR(6);
        DEFINE pfolio_operacion                 CHAR(18);
        DEFINE preferencia3                     CHAR(40);
        DEFINE preferencia4                     CHAR(40);
        ---------------------------------------------------------------------------------------

        --SET DEBUG FILE TO "/informix/LuisBeltran/BDISAC/sp_actualizahist.out";
        --TRACE ON;
        SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;



        LET cCodRet = '00000';
        LET cCodRetSP = '00000';
        LET cInfoErr = '';
        LET iSqlErr  = 0;
        LET iIsamErr  = 0;

        LET cClave = '';
        LET cTipomovimiento = '';
        LET iSucursal = 0;
        LET iCiudad = 0;
        LET iCliente = 0;
        LET iClienteetp = 0;
        LET iCaja = 0;
        LET iRecibo = 0;
        LET iFactura = 0;
        LET iImporte = 0;
        LET iSaldoinicial = 0;
        LET iSaldofinal = 0;
        LET iSaldocuenta = 0;
        LET iVencidoinicial = 0;
        LET iMinimoinicial = 0;
        LET iMontodolar = 0;
        LET iBase = 0;
        LET dFechasaldacon  = EXTEND(MDY(1,1,1990), YEAR to SECOND);
        LET iImportesaldacon = 0;
        LET cTipoconvenio = '';
        LET cSubtipoconvenio = '';
        LET iPlazoconvenio = 0;
        LET cEjercicio = '';
        LET cClavetdaocob = '';
        LET cGrabacartera = '';
        LET cAnexo = '';
        LET cClavelocal = '';
        LET cClientelocalizar = '';
        LET cTiposeguro = '';
        LET cFlagseguroconyugal = '';
        LET cMovtoseguro = '';
        LET cFlagmontoseguro = '';
        LET cStatusseguro = '';
        LET iCausabaja = 0;
        LET iCantidadseguros = 0;
        LET iCantidadsegurosanterior = 0;
        LET iCantidadmeses = 0;
        LET iBonificacion = 0;
        LET iMesesvencidos = 0;
        LET dFechanacimiento = EXTEND(MDY(1,1,1990), YEAR to SECOND);
        LET iEdad = 0;
        LET cSexo  = '';
        LET cAreaajuste  = '';
        LET dFechaabonoajuste  = EXTEND(MDY(1,1,1990), YEAR to SECOND);
        LET cClaveajuste  = '';
        LET cAjuste  = '';
        LET iSsucursalorigen = 0;
        LET iNumerocontrol = 0;
        LET iComision = 0;
        LET iClienteremitente = 0;
        LET cTipogastoviaje = '';
        LET iCentro = 0;
        LET cFlagincluyerecibo = '';
        LET iRuta  = 0;
        LET iFolio  = 0;
        LET cCuenta = '';
        LET iIva  = 0;
        LET iTelefono  = 0;
        LET cCompania = '';
        LET cContrato = '';
        LET cCredito = '';
        LET fFechavencimiento  = EXTEND(MDY(1,1,1990), YEAR to SECOND);
        LET fFechavencimientoanterior = EXTEND(MDY(1,1,1990), YEAR to SECOND);
        LET fFecha  = EXTEND(MDY(1,1,1990), YEAR to SECOND);
        LET iEfectuo = 0;
        LET iCajaoriginal = 0;
        LET iFoliosucursal = 0;
        LET cRpu = '';
        LET cFlagmovtosupervisor = '';
        LET iInteres = 0;
        LET iImporteventa = 0;
        LET iFolioanterior = 0;
        LET iDigito = 0;
        LET cSac = '';
        LET dFechadocumento  = EXTEND(MDY(1,1,1990), YEAR to SECOND);
        LET iNumerocuenta = 0;
        LET iNumerosubcuenta = 0;
        LET iNumeroconcepto = 0;
        LET iRegistropatronal = '';
        LET iFormaaportacionafore = 0;
        LET cIpcarteracliente = '';
        LET dFechamovto   = EXTEND(MDY(1,1,1990), YEAR to SECOND);
        LET iCandidato = 0;
        LET iStatusafore = 0;
        LET cStatus_coppel = '';

        LET cStatus_cancelado = '';

--20110907-I
        LET vmax_fechaold    = '';
        LET vfecharesp       = '';
        LET vcontregshist        = 0;
        LET vcontregsold     = 0;
        LET vMensaje = '';
        LET vcodretODP = '00000';
        LET vCodretBTS = '00000';
        LET iCte_prospecto = 0;
--20110907-F
        LET vfechacomp    = '';

        LET iCont = 0;

        ---------------------------------------------------------------------------------------
        -- Variables para insersiÃ³n -----------------------------------------------------------
        LET pid_sucursal                = '';
        LET pnumcategoria               = '';
        LET pnumconvenio                = '';
        LET preferencia1                = '';
        LET preferencia2                = '';
        LET pforma_pago                 = '';
        LET pimporte_pago               = 0;
        LET pimporte_comision_convenio  = 0;
        LET piva_comision_convenio      = 0;
        LET pimporte_comision_cte       = 0;
        LET piva_comision_cte           = 0;
        LET pcuenta_cargo               = '';
        LET pusuario                    = '';
        LET pfolio_suc                  = '';
        LET ptransacc_suc               = '';
        LET pflag_confirmacion_central  = 0;
        LET pflag_confirmacion_sucursal = 0;
        LET pfecha_pago                 = EXTEND(MDY(1,1,1990), YEAR to SECOND);
        LET pfecha_insert               = EXTEND(MDY(1,1,1990), YEAR to SECOND);
        LET pstatus_cancelado           = '';
        LET porigen                     = '';
        LET psucursal_cpl               = '';
        LET pcaja_cpl                   = '';
        LET ptransaccion                = '';
        LET phora                       = '';
        LET pfolio_operacion            = '';
        LET preferencia3                = '';
        LET preferencia4                = '';
        ---------------------------------------------------------------------------------------
    BEGIN

        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr;
                    ROLLBACK WORK;
                    EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_ActualizaHistoricodeTransacciones");
                    RETURN cCodRet;
                END IF;
        END EXCEPTION;
        --BEGIN WORK;

        -- Se cambia instrucciÃ³n de inserciÃ³n para poder realizar COMMIT cada 1000 registros
        BEGIN WORK;
                FOREACH WITH HOLD
                        SELECT {+INDEX("informix".sac_movimientos "informix".idxsac_mov4)}
                                id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio,
                            iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc,
                            flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado,
                            origen, sucursal_cpl, caja_cpl, transaccion, hora, folio_operacion, referencia3, referencia4
                        INTO
                                pid_sucursal,pnumcategoria,pnumconvenio,preferencia1,preferencia2,pforma_pago,pimporte_pago,pimporte_comision_convenio,piva_comision_convenio,pimporte_comision_cte,
                                piva_comision_cte,pcuenta_cargo,pusuario,pfolio_suc,ptransacc_suc,pflag_confirmacion_central,pflag_confirmacion_sucursal,pfecha_pago,pfecha_insert,pstatus_cancelado,
                                porigen,psucursal_cpl,pcaja_cpl,ptransaccion,phora,pfolio_operacion,preferencia3,preferencia4
                        FROM "informix".sac_movimientos
                        WHERE fecha_pago = dFecha_hoy

                        LET iCont = iCont + 1;

                        INSERT INTO "informix".sac_movimientoshistorial VALUES
                                (pid_sucursal,pnumcategoria,pnumconvenio,preferencia1,preferencia2,pforma_pago,pimporte_pago,pimporte_comision_convenio,piva_comision_convenio,pimporte_comision_cte,
                                 piva_comision_cte,pcuenta_cargo,pusuario,pfolio_suc,ptransacc_suc,pflag_confirmacion_central,pflag_confirmacion_sucursal,pfecha_pago,pfecha_insert,pstatus_cancelado,
                                 porigen,psucursal_cpl,pcaja_cpl,ptransaccion,phora,pfolio_operacion,preferencia3,preferencia4);

                        IF iCont = 1000 THEN
                                LET iCont = 0;
                                COMMIT WORK;
                                BEGIN WORK;
                        END IF;
        END  FOREACH;
                COMMIT WORK;

/*
                INSERT INTO "informix".sac_movimientoshistorial (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago,
                                        importe_pago, importe_comision_convenio, iva_comision_convenio,importe_comision_cte, iva_comision_cte,
                                        cuenta_cargo, usuario, folio_suc, transacc_suc, flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago,
                                        fecha_insert, status_cancelado, origen, sucursal_cpl, caja_cpl, transaccion, hora, folio_operacion, referencia3, referencia4)
                SELECT {+INDEX("informix".sac_movimientos "informix".idxsac_mov4)} id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio,
                                   iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc,
                                   flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado,
                   origen, sucursal_cpl, caja_cpl, transaccion, hora, folio_operacion, referencia3, referencia4
                  FROM "informix".sac_movimientos
             WHERE fecha_pago = dFecha_hoy;
 */

                 -- 20110907-I:
--      SE AGREGA MANNTTO. DE REGISTROS DE 'BDISAC:SAC_MOVIMIENTOSHISTORIAL' A 'BDISAC:SAC_MOVIMIENTOSHISTORIAL_OLD'
--      SOLO SE CONSIDERAN LOS DEL ÃLTIMO DÃA (FECHA_PAGO + 1) DE LA TABLA 'BDISAC:SAC_MOVIMIENTOSHISTORIAL_OLD'

        SELECT {+INDEX("informix".sac_movimientoshistorial_old "informix".idx_sac_movimientoshist3)}
        MAX (fecha_pago) INTO vmax_fechaold
          FROM "informix".sac_movimientoshistorial_old;

        let vfecharesp = vmax_fechaold +1;
        let vfechacomp = dFecha_hoy - 90;

        SELECT {+INDEX("informix".sac_movimientoshistorial "informix".idxsac_movhis235)}
        COUNT (*) INTO vcontregshist
          FROM "informix".sac_movimientoshistorial
     WHERE fecha_pago >= vfecharesp
       AND fecha_pago < vfechacomp;

--      PROCESO DE INSERT DE LA TABLA DE HISTORICOS A REPOSITORIO (OLD):
                -- Se cambia instrucciÃ³n de inserciÃ³n para poder realizar COMMIT cada 1000 registros
                LET iCont = 0;

        BEGIN WORK;
                FOREACH WITH HOLD
                        SELECT {+INDEX("informix".sac_movimientoshistorial "informix".idxsac_movhis235)}
                                id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio,
                                iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc,
                                flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado,
                origen,sucursal_cpl,caja_cpl,transaccion,hora,folio_operacion,referencia3,referencia4
            INTO
                                pid_sucursal,pnumcategoria,pnumconvenio,preferencia1,preferencia2,pforma_pago,pimporte_pago,pimporte_comision_convenio,piva_comision_convenio,pimporte_comision_cte,
                                piva_comision_cte,pcuenta_cargo,pusuario,pfolio_suc,ptransacc_suc,pflag_confirmacion_central,pflag_confirmacion_sucursal,pfecha_pago,pfecha_insert,pstatus_cancelado,
                                porigen,psucursal_cpl,pcaja_cpl,ptransaccion,phora,pfolio_operacion,preferencia3,preferencia4
                        FROM "informix".sac_movimientoshistorial
            WHERE fecha_pago >= vfecharesp
                                AND fecha_pago < vfechacomp

                        LET iCont = iCont + 1;


                        INSERT INTO "informix".sac_movimientoshistorial_old VALUES
                                (pid_sucursal,pnumcategoria,pnumconvenio,preferencia1,preferencia2,pforma_pago,pimporte_pago,pimporte_comision_convenio,piva_comision_convenio,pimporte_comision_cte,
                                 piva_comision_cte,pcuenta_cargo,pusuario,pfolio_suc,ptransacc_suc,pflag_confirmacion_central,pflag_confirmacion_sucursal,pfecha_pago,pfecha_insert,pstatus_cancelado,
                                 porigen,psucursal_cpl,pcaja_cpl,ptransaccion,phora,pfolio_operacion,preferencia3,preferencia4);

                        IF iCont = 1000 THEN
                                LET iCont = 0;
                                COMMIT WORK;
                                BEGIN WORK;
                        END IF;

                END FOREACH;
                COMMIT WORK;
/*
                INSERT INTO "informix".sac_movimientoshistorial_old
                                (id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio,
                                iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc,
                                flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado,
                origen,sucursal_cpl,caja_cpl,transaccion,hora,folio_operacion,referencia3,referencia4)
                 SELECT {+AVOID_FULL("informix".sac_movimientoshistorial)} id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio,
                                iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc,
                                flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado,
                origen,sucursal_cpl,caja_cpl,transaccion,hora,folio_operacion,referencia3,referencia4
           FROM "informix".sac_movimientoshistorial
          WHERE fecha_pago >= vfecharesp
                    AND fecha_pago < vfechacomp;
*/
                SELECT {+INDEX("informix".sac_movimientoshistorial_old "informix".idx_sac_movimientoshist3)}
                COUNT (*) INTO vcontregsold
                  FROM "informix".sac_movimientoshistorial_old
                 WHERE fecha_pago >= vfecharesp
                   AND fecha_pago < vfechacomp;

                IF vcontregsold = vcontregshist THEN
                        DELETE FROM "informix".sac_movimientoshistorial
                                  WHERE fecha_pago >= vfecharesp
                                        AND fecha_pago < vfechacomp;
                ELSE

                        LET iSqlErr = 9999;
                        LET iIsamErr = 9999;
                        LET cInfoErr = 'No se insertaron en la tabla bdisac:sac_movimientoshistorial_old todos los registros.';
                        EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_ActualizaHistoricodeTransacciones");
                END IF;

                -- 20110907-f:
                ---20220318

/*              INSERT INTO "informix".sac_movimientos_detalle_td_historial
                SELECT folio_abono,subfolio,cliente,sucursal,tienda,secuencia,tipo_cuenta,cartera,importe,factura,status_coppel,fecha_abono,a.fecha_insert
                FROM "informix".sac_movimientos_detalle_td a, "informix".sac_movimientos b
                WHERE a.fecha_abono = dFecha_hoy
                 AND numcategoria = '01'
                 AND numconvenio = '001'
                 AND a.folio_abono = b.referencia2
                 AND a.cliente = b.referencia1; */


                        INSERT INTO "informix".sac_movimientos_detalle_td_historial
                        SELECT folio_abono,subfolio,cliente,sucursal,tienda,secuencia,tipo_cuenta,cartera,importe,factura,status_coppel,fecha_abono,a.fecha_insert
					   FROM "informix".sac_movimientos_detalle_td a
                        INNER JOIN "informix".sac_movimientos b ON a.cliente = b.referencia1
                        WHERE a.fecha_abono = dFecha_hoy
                        AND numcategoria = '01'
                        AND numconvenio = '001'
                        AND a.folio_abono = b.referencia2
                        AND b.status_cancelado <> 'S';


                ---20220318
                LET iCont = 0;

        BEGIN WORK;
                FOREACH WITH HOLD
                                SELECT clave, tipomovimiento, sucursal, ciudad, cliente, clienteetp, caja, recibo, factura, importe, saldoinicial,
                                        saldofinal, saldocuenta, vencidoinicial, minimoinicial, montodolar, base, fechasaldacon, importesaldacon,
                                        tipoconvenio, subtipoconvenio, plazoconvenio, ejercicio, clavetdaocob, grabacartera, anexo, clavelocal,
                                        clientelocalizar, tiposeguro, flagseguroconyugal, movtoseguro, flagmontoseguro, statusseguro, causabaja,
                                        cantidadseguros, cantidadsegurosanterior, cantidadmeses, bonificacion, mesesvencidos, fechanacimiento, edad,
                                        sexo, areaajuste, fechaabonoajuste, claveajuste, ajuste, sucursalorigen, numerocontrol, comision, clienteremitente,
                                        tipogastoviaje, centro, flagincluyerecibo, ruta, folio, cuenta, iva, telefono, compania, contrato, credito,
                                        fechavencimiento, fechavencimientoanterior, fecha, efectuo, cajaoriginal, foliosucursal, rpu, flagmovtosupervisor,
                                        interes,importeventa, folioanterior, digito, sac, fechadocumento, numerocuenta, numerosubcuenta, numeroconcepto,
                                        registropatronal, formaaportacionafore, ipcarteracliente, fechamovto, candidato, statusafore, status_coppel,
                                        b.status_cancelado, cte_prospecto
                                INTO cClave, cTipomovimiento, iSucursal, iCiudad, iCliente, iClienteetp, iCaja, iRecibo, iFactura, iImporte, iSaldoinicial,
                                        iSaldofinal, iSaldocuenta, iVencidoinicial, iMinimoinicial, iMontodolar, iBase, dFechasaldacon, iImportesaldacon,
                                        cTipoconvenio,cSubtipoconvenio, iPlazoconvenio, cEjercicio, cClavetdaocob, cGrabacartera, cAnexo, cClavelocal,
                                        cClientelocalizar, cTiposeguro, cFlagseguroconyugal,cMovtoseguro, cFlagmontoseguro, cStatusseguro, iCausabaja,
                                        iCantidadseguros, iCantidadsegurosanterior, iCantidadmeses, iBonificacion, iMesesvencidos, dFechanacimiento, iEdad,
                                        cSexo, cAreaajuste, dFechaabonoajuste, cClaveajuste, cAjuste, iSsucursalorigen, iNumerocontrol, iComision,
                                        iClienteremitente, cTipogastoviaje, iCentro, cFlagincluyerecibo, iRuta, iFolio, cCuenta, iIva, iTelefono, cCompania,
                                        cContrato, cCredito, fFechavencimiento, fFechavencimientoanterior, fFecha, iEfectuo, iCajaoriginal, iFoliosucursal,
                                        cRpu, cFlagmovtosupervisor, iInteres, iImporteventa, iFolioanterior, iDigito, cSac, dFechadocumento,iNumerocuenta,
                                        iNumerosubcuenta, iNumeroconcepto, iRegistropatronal, iFormaaportacionafore, cIpcarteracliente, dFechamovto,iCandidato,
                                        iStatusafore, cStatus_coppel, cStatus_cancelado, iCte_prospecto
                                FROM "c92357113".sac_movimientosdetalle a, "informix".sac_movimientos b
                           WHERE a.fecha = dFecha_hoy
                                 AND numcategoria = '01'
                                 AND numconvenio = '002'
                                 AND a.recibo = b.referencia2
                                 AND (a.cliente = b.referencia1 or b.referencia1 = a.cte_prospecto)

                                IF cStatus_cancelado = 'S' THEN
                                        LET cClave = LOWER(cClave);
                                END IF;

                                LET iCont = iCont + 1;

                                INSERT INTO "informix".sac_movimientosdetallehistorial VALUES (cClave, cTipomovimiento, iSucursal, iCiudad, iCliente,
                                        iClienteetp, iCaja, iRecibo,iFactura, iImporte, iSaldoinicial, iSaldofinal, iSaldocuenta, iVencidoinicial,
                                        iMinimoinicial, iMontodolar, iBase, dFechasaldacon, iImportesaldacon, cTipoconvenio, cSubtipoconvenio,iPlazoconvenio,
                                        cEjercicio, cClavetdaocob, cGrabacartera, cAnexo, cClavelocal, cClientelocalizar, cTiposeguro, cFlagseguroconyugal,
                                        cMovtoseguro, cFlagmontoseguro, cStatusseguro, iCausabaja, iCantidadseguros, iCantidadsegurosanterior, iCantidadmeses,
                                        iBonificacion,iMesesvencidos, dFechanacimiento, iEdad, cSexo, cAreaajuste, dFechaabonoajuste, cClaveajuste, cAjuste,
                                        iSsucursalorigen, iNumerocontrol, iComision, iClienteremitente, cTipogastoviaje, iCentro, cFlagincluyerecibo, iRuta,
                                        iFolio, cCuenta, iIva, iTelefono, cCompania, cContrato,cCredito,fFechavencimiento,fFechavencimientoanterior, fFecha,
                                        iEfectuo, iCajaoriginal, iFoliosucursal, cRpu,cFlagmovtosupervisor, iInteres, iImporteventa, iFolioanterior, iDigito,
                                        cSac, dFechadocumento, iNumerocuenta, iNumerosubcuenta, iNumeroconcepto, iRegistropatronal,iFormaaportacionafore,
                                        cIpcarteracliente, dFechamovto, iCandidato, iStatusafore, cStatus_coppel, iCte_prospecto);

                                IF iCont = 1000 THEN
                                        LET iCont = 0;
                                        COMMIT WORK;
                                        BEGIN WORK;
                                END IF;
                END  FOREACH;
                COMMIT WORK;
        --COMMIT WORK;

                -- TRASPASO Y BLOQUEO DE ENVÃOS
       IF cCodRet='00000' THEN
          EXECUTE PROCEDURE "informix".sp_dinya_BloqueaEnviosNoCobrados() INTO cCodRet;
     --end if;
                --20110923-I SE AGREGA EL LLAMADO A LOS SPS QUE GENERAN ARCHIVOS DE BTS Y ODP QUINCENALMENTE:
          EXECUTE FUNCTION "informix".sp_genrepordenespago() INTO vcodretodp, vmensaje;
          EXECUTE FUNCTION "informix".sp_genrepremesasbts() INTO vcodretbts, vmensaje;
       END IF;

        RETURN cCodRet;
    END;
END PROCEDURE
DOCUMENT
'AUTOR : JosÃ© Angel LÃ³pez Adams',
'DESCRIPCION: Se encarga de pasar los movimientos diarios al historico correspondiente',
'EJECUTADO O LLAMADO POR:',
'sp_ProcesoCierreDiarioSAC()',
'FECHA : Septiembre de 2008',
'VERSION: 20080930',
'BD    : bdisac',
'MODIFICO: Dulce Ramirez',
'DESCRIPCION DE LA MODIFICACIÃN: Envia registro por registro a la sac_movimientosdetallehistorial...',
'...para que vaya validando el status_cancelado y pase la clave en minusculas si esta cancelado',
'FECHA MODIFICACION: Junio de 2009',
'AUTOR : FRG',
'DESCRIPCION: Se agrega procedimiento de Manntto. de tabla Movs. HistÃ³ricos a Repositorio',
'EJECUTADO O LLAMADO POR:',
'sp_ProcesoCierreDiarioSAC()',
'FECHA : Septiembre de 2011',
'VERSION: 20110907',
'BD    : bdisac',
'*****************',
'Folio: 1448',
'Autor: 94912599 ',
'Fecha: 10/07/2014',
'DescripciÃ³n: Se modifica  para que guarde un registro en la tabla sac_movimientosdetallehistorial esto',
'Tomando en cuenta los convenios 002 de la tabla sac_movimientosdetalle',
'Sustento:RQI 62 038 VentaClubdeProteccionCppl-BCP_InterfacesCaja_v3',
'Solicita: FermÃ­n Ramos',
'BD: bdisac',
'*****************',
'Folio: 821',
'Autor: 98640909 - Luis Beltran',
'Fecha: 01/04/2022',
'DescripciÃ³n:se modifica spl para que realice el backup en la tabla historica para los pagos de abonos coppel por servicios omnicanales',
'MODIFICO: Uriel Amador Islas',
'DESCRIPCION DE LA MODIFICACIÃN: Envia registro por registro a la en las tablas sac_movimientoshistorial y sac_movimientoshistorial_old, y se realiza commit por cada 1000 registros',
'FECHA MODIFICACION: 29/08/2023',
'BD    : bdisac',
'*****************',
'Descripcion: Se agrega nueva validacion para evitar fallas de ejecucion del JOB_CIERRE_PAGOSERVICIOS_PRO',
'ModificÃ³:Victor Manuel Hernandez Lopez',
'Fecha_modificacion:06/02/2024 - 25/04/2024',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_liq_com_cte_cfe(cTipoLiq CHAR(1))
	RETURNING CHAR(5)  AS CodRet, CHAR(16) AS Folio, CHAR(60) AS Mensaje;
		  
	-- DECLARACION DE VARIABLES.
    DEFINE Sql_Err           		INTEGER; 		--Error de SQL
    DEFINE Isam_Err          		INTEGER; 		--Error del ISAM
    DEFINE Desc_Err          		CHAR(50);		--Descripcion del error
    DEFINE cCodRet	         		CHAR(5);  		--Codigo de retorno del SP
	DEFINE cCod_err2          		CHAR(5);	    --Codigo de error para bitacora de eventos
	DEFINE cCuenta           		CHAR(20);	    --Variable para validacion de cuenta
    DEFINE cFolio            		CHAR(16);       --Folio de la operacion
    DEFINE cNombreServicio          CHAR(10);       --Nombre del servicio
	DEFINE cNumcategoria     		CHAR(5);        --No. de categoria de la CFE
	DEFINE cNumconvenio      		CHAR(5);        --No. de convenio de la CFE
	DEFINE cCuenta_prestadora 		CHAR(20);       --Cuenta prestadora del servicio
	DEFINE cMensaje          		CHAR(60);       --Mensaje de retorno del SP
	DEFINE cCtranssuc		 		CHAR(4);        --Transaccsuc Cargo
	DEFINE iSdo_actual		 		INTEGER;        --Saldo actual de la cuenta prestadora
	DEFINE dFecha_hoy	     		DATE;           --Fecha del sistema de Servicios Al Cliente
	DEFINE cDescripcionSPJ	 		CHAR(100);      --Descripcion para bitacora
    DEFINE cTranret             	CHAR(4);        --Transaccion de retorno del cargo_ref
    DEFINE mSdodisp             	MONEY (14,2);   --Saldo disponible de retorno de cargo_ref
    DEFINE mMontoret            	MONEY (14,2);   --Monto retiro de retorno de cargo_ref
	DEFINE deImporte_Comision_srv 	DECIMAL(10,2);  --Importe suma de comision de sac_movimientos 
	DEFINE deImporte_Comision_chq 	DECIMAL(10,2);  --Importe suma de comision de sc_movdia
	DEFINE deImporte_Coms_IVA_srv 	DECIMAL(10,2);  --Importe suma de iva de la comision de sac_movimientos
	DEFINE deImporte_Coms_IVA_chq 	DECIMAL(10,2);  --Importe suma de iva de la comision de sc_movdia
	DEFINE deImporte_Servicios		DECIMAL(10,2);	--Importe de Servicios para validacion de diferencias
	DEFINE deImporte_Cheques		DECIMAL(10,2);	--Importe de Cheques para validacion de diferencias
	DEFINE cProcLiqComs 			CHAR(15);       --Nombre del proceso de liquidaciÃ³n de comisiones
	DEFINE cProcLiqIVA 				CHAR(15);       --Nombre del proceso de liquidaciÃ³n del IVA de la comision
	DEFINE cNombreSp				CHAR(18);		--Nombre del SP actual para registro en bitacoras
	DEFINE cSucCoppel				CHAR(4);		--Numero de la sucursal de Coppel
	
	--SET DEBUG FILE TO '/home/c90314833/sp_liq_com_cte_cfe.out';
    --TRACE ON;
	
    -- INICIALIZACION DE VARIABLES.
	LET Sql_Err 	= 0;
    LET Isam_Err 	= 0;
    LET Desc_Err 	= '';
    LET cCodRet  	= '00001';
	LET cCod_err2 	= '00000';
	LET cCuenta  	= '';  
    LET cFolio  	= '';
	LET cNombreServicio = 'CFE';
	LET cNumcategoria 	= '04';
	LET cNumconvenio 	= '001';
	LET cCuenta_prestadora = '0';
	LET cMensaje 		= '';
	LET cCtranssuc 		= '';
	LET iSdo_actual  	= 0;	
	LET dFecha_hoy				=CURRENT;
	LET cDescripcionSPJ	 		='Ejecuta liquidacion de comisiones del servicio:';
    LET cTranret                ='';
    LET mSdodisp                ='';
    LET mMontoret               ='';
	LET deImporte_Comision_srv 	=0.00;
	LET deImporte_Comision_chq  =0.00;
	LET deImporte_Coms_IVA_srv 	=0.00;
	LET deImporte_Coms_IVA_chq  =0.00;
	LET deImporte_Servicios 	=0.00;
	LET deImporte_Cheques		=0.00;
	LET cProcLiqComs 			='LIQU_COMCFE';
	LET cProcLiqIVA 			='LIQU_COMIVACFE';
	LET cNombreSp				='sp_liq_com_cte_cfe';
	LET cSucCoppel				='9764';
	
	
	
BEGIN

		ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
			IF Sql_Err <> 0 THEN
				LET cCodRet = Sql_Err;
				EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (Sql_Err, Isam_Err, Desc_Err, cNombreSp);
			 RETURN cCodRet, cFolio, cMensaje;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;				
		
		--OBTIENE LA FECHA DEL DIA DE LA BD DE SERVICIO AL CLIENTE
		SELECT fecha_hoy  INTO dFecha_hoy FROM sac_fechas WHERE empresa = '001';
		
		--OBTIENE LOS DATOS DEL CONVENIO DEL SERVICIO
		SELECT cuenta_prestadora, trans_suc_cargo		   
		INTO cCuenta_prestadora, cCtranssuc
		FROM "informix".sac_convenios 
		WHERE numcategoria = cNumcategoria
		AND numconvenio  = cNumconvenio;
		
		--INSERTA REGISTRO EN BITACORA
		EXECUTE PROCEDURE "informix".sp_bitacoraspj(0, 'IND_LH_SC', dFecha_Hoy, '0', 'informix', cNombreSp, TRIM(cDescripcionSPJ) || ' ' || TRIM(cNombreServicio));
						
		--VALIDA LA EXISTENCIA DE LA CUENTA PRESTADORA DEL SERVICIO
		SELECT mae.cuenta INTO cCuenta
		FROM bdicheq:"informix".sc_maechq mae
		INNER JOIN bdicheq:"informix".sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta )
		INNER JOIN bdicheq:"informix".sc_producto pro ON ( pro.empresa = mae.empresa AND pro.producto = mae.producto )
		INNER JOIN bdinteg:"informix".si_cliente cte ON ( cte.numcte = mae.num_cte )
		LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta tar ON ( tar.empresa = mae.empresa AND tar.cuenta = mae.cuenta AND tar.tipo_tarjeta = 'T' AND tar.status_tar = 'A' )
		WHERE mae.empresa = '001'         
		AND mae.cuenta = cCuenta_prestadora; 
				
		--VALIDA SI EL PARAMETRO DE CUENTA ESTA VACIO O NULO, O ES DIFERENTE AL PARAMETRO EN LA TABLA DE CONVENIOS.
		IF cCuenta is null OR cCuenta = '' OR cCuenta <> cCuenta_prestadora THEN
			LET cFolio = '';
			LET cCodRet = '00100';
			LET cMensaje = 'No existe cuenta';
			RETURN cCodRet, cFolio, cMensaje;
		END IF;	
		
		--OBTIENE LA SUMA DE LOS MONTOS DE LA COMISIÃN Y EL IVA DE LA COMISION DEL CLIENTE DE LA CFE, DEL SISTEMA SE SERVICIOS. 
		SELECT NVL(SUM(importe_comision_cte),0), NVL(SUM(iva_comision_cte),0)
		INTO deImporte_Comision_srv,deImporte_Coms_IVA_srv
		FROM "informix".sac_movimientos
		WHERE numcategoria = cNumcategoria
		AND numconvenio = cNumconvenio
		AND fecha_pago = dFecha_hoy
		AND status_cancelado <> 'S'
		AND id_sucursal <> cSucCoppel
		AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1);					
		
		--CONSULTAR SALDO ACTUAL DE LA CUENTA
		SELECT sdo_actual INTO iSdo_actual 
		FROM bdicheq:"informix".sc_maechq 
		WHERE cuenta = cCuenta;
		
		--VALIDAR EL TIPO DE LIQUIDACION A REALIZAR: 
		-- 0 - COMISION 
		IF(cTipoLiq = '0') THEN
			--VALIDAR QUE NO EXISTE UN PROCESO PREVIO DE LIQUIDACION DE LA COMISION.
			IF EXISTS (SELECT * FROM "informix".sac_procesos_liqhs WHERE proceso = cProcLiqComs AND status = '1' AND fecha_proceso = dFecha_hoy) THEN
				LET cCodRet = "00001";
				LET cMensaje = "Liquidacion de Comision CFE ya ha sido ejecutada";
				RETURN cCodRet, cFolio, cMensaje;
			ELIF NOT EXISTS (SELECT * FROM "informix".sac_procesos_liqhs WHERE proceso = cProcLiqComs AND status = '0' AND fecha_proceso = dFecha_hoy) THEN
				--REGISTRO DE PROCESO DE LIQUIDACION.
				INSERT INTO "informix".sac_procesos_liqhs(proceso, fecha_proceso, status, user_insert, saldo_cta_pres, importe_srv, inporte_chq, fecha_insert)
				VALUES (cProcLiqComs, dFecha_hoy, '0', 'informix','','','', CURRENT);							
				
				--OBTENER LA SUMA DE LOS MONTOS DE COMISION AL CLIENTE DE LA CFE, IDENTIFICADOS CON LA TX 1495
				SELECT  NVL(SUM(monto_tot),0) INTO deImporte_Comision_chq
				FROM    bdicheq:"informix".sc_movdia
				WHERE   transacc = '1495' 
				AND     transacc_suc = cCtranssuc
				AND     fech_alt = today
				AND     cancelad <> 'S';
				
				IF deImporte_Comision_chq <= 0 THEN
					LET cCodRet  = '00000';
					LET cMensaje = 'No hay Movimientos';
					UPDATE bdisac:"informix".sac_procesos_liqhs SET status = '1', saldo_cta_pres = iSdo_actual, importe_srv = deImporte_Comision_srv, inporte_chq = deImporte_Comision_chq
					 WHERE PROCESO = cProcLiqComs
					   AND status = '0' 
					   AND fecha_proceso = dFecha_hoy;			   

					--ACTUALIZA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_LH_SC', dFecha_Hoy, '1', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || TRIM(cNombreServicio));			
					RETURN cCodRet, cFolio, cMensaje;			
				END IF;
				
				LET deImporte_Servicios = deImporte_Comision_srv;
				LET deImporte_Cheques = deImporte_Comision_chq;
				
				IF (iSdo_actual >= deImporte_Comision_chq) THEN
					
					--GENERACION DE FOLIO_SUC 
					LET cFolio = 'sys_cfec'||LPAD(MONTH(CURRENT::DATE),2,0)||LPAD(DAY(CURRENT::DATE),2,0)||SUBSTR(TRIM(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '')),1,2)||'02';
					
					IF deImporte_Comision_chq > 0 THEN
						--CARGO A CUENTA PRESTADORA DE LA CFE POR EL MONTO DE LA SUMA DE LA COMISION
						CALL bdicheq:"informix".cargo_ref ('001', cSucCoppel, 'informix', '1435', cCtranssuc, cFolio, cCuenta, 0, deImporte_Comision_chq, '01', 'Cargo Comision Pago Cfe', '', '') 
						Returning cCodRet,cTranret,dFecha_hoy,mSdodisp,mMontoret;
						IF cCodRet = '000' THEN								
							LET cCodRet = '00000';
							LET cMensaje = 'Exitoso';								
						ELSE
							LET cMensaje = 'Error controlado cargo_ref '||cProcLiqComs; 
							EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (cCodRet, '', cMensaje, cNombreSp);
							RETURN cCodRet, cFolio, cMensaje;
						END IF;
					END IF;	
				ELSE
					LET cFolio = '';
					LET cCodRet = '00999';
					LET cMensaje = 'Saldo no disponible en cuenta Cfe';
					RETURN cCodRet, cFolio, cMensaje;
				END IF;
				
				--ACTUALIZACION DE REGISTRO DEL PROCESO DE LIQUIDACION DE COMISIONES DE LA CFE
				IF cCodRet = '00000' THEN
					UPDATE "informix".sac_procesos_liqhs
					SET status = '1', saldo_cta_pres = iSdo_actual, importe_srv = deImporte_Comision_srv, inporte_chq = deImporte_Comision_chq
					WHERE proceso = cProcLiqComs AND status = '0' AND fecha_proceso = dFecha_hoy;
				ELSE
					UPDATE "informix".sac_procesos_liqhs
					SET status = '0', saldo_cta_pres = iSdo_actual, importe_srv = 0, inporte_chq = 0
					WHERE proceso = cProcLiqComs AND status = '0' AND fecha_proceso = dFecha_hoy;
				END IF;
			END IF;
		--VALIDAR EL OTRO POSIBLE TIPO DE LIQUIDACION A REALIZAR:
		-- 1 - IVA DE LA COMISION	
		ELIF (cTipoLiq = '1') THEN 
			
			--VALIDAR QUE NO EXISTE UN PROCESO PREVIO DE LIQUIDACION DEL DE IVA DE LA COMISION 
			IF EXISTS (SELECT * FROM "informix".sac_procesos_liqhs WHERE proceso = cProcLiqIVA AND status = '1' AND fecha_proceso = dFecha_hoy) THEN
				LET cCodRet = "00001";
				LET cMensaje = "Liquidacion de IVA de Comision CFE ya ha sido ejecutada";
				RETURN cCodRet, cFolio, cMensaje;
			ELIF NOT EXISTS (SELECT * FROM "informix".sac_procesos_liqhs WHERE proceso = cProcLiqIVA AND status = '0' AND fecha_proceso = dFecha_hoy) THEN
				--REGISTRO DE PROCESO DE LIQUIDACION.
				INSERT INTO "informix".sac_procesos_liqhs(proceso, fecha_proceso, status, user_insert, saldo_cta_pres, importe_srv, inporte_chq, fecha_insert)
				VALUES (cProcLiqIVA, dFecha_hoy, '0', 'informix','','','', CURRENT);													

				--OBTENER LA SUMA DE LOS MONTOS DEL IVA DE COMISION AL CLIENTE DE LA CFE, IDENTIFICADOS CON LA TX 1496
				SELECT  NVL(SUM(monto_tot),0) INTO deImporte_Coms_IVA_chq
				FROM    bdicheq:"informix".sc_movdia
				WHERE   transacc = '1496' 
				AND     transacc_suc = cCtranssuc
				AND     fech_alt = today
				AND     cancelad <> 'S';																
				
				IF deImporte_Coms_IVA_chq <= 0 THEN
					LET cCodRet  = '00000';
					LET cMensaje = 'No hay Movimientos';
					UPDATE bdisac:"informix".sac_procesos_liqhs SET status = '1', saldo_cta_pres = iSdo_actual, importe_srv = deImporte_Coms_IVA_srv, inporte_chq = deImporte_Coms_IVA_chq
					 WHERE PROCESO = cProcLiqIVA
					   AND status = '0' 
					   AND fecha_proceso = dFecha_hoy;			   

					--ACTUALIZA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_LH_SC', dFecha_Hoy, '1', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || TRIM(cNombreServicio));			
					RETURN cCodRet, cFolio, cMensaje;			
				END IF;
				
				LET deImporte_Servicios = deImporte_Coms_IVA_srv;
				LET deImporte_Cheques = deImporte_Coms_IVA_chq;
				
				IF (iSdo_actual >= deImporte_Coms_IVA_chq) THEN
					
					--GENERACION DE FOLIO_SUC 
					LET cFolio = 'sys_cfei'||LPAD(MONTH(CURRENT::DATE),2,0)||LPAD(DAY(CURRENT::DATE),2,0)||SUBSTR(TRIM(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '')),1,2)||'02';
					
					IF deImporte_Coms_IVA_chq > 0 THEN
						--CARGO A CUENTA PRESTADORA DE LA CFE POR EL MONTO DE LA SUMA DEL IVA DE LA COMISION
						CALL bdicheq:"informix".cargo_ref ('001', cSucCoppel, 'informix', '1436', cCtranssuc, cFolio, cCuenta, 0, deImporte_Coms_IVA_chq, '01', 'Cargo IVA comision Pago Cfe', '', '') 
						Returning cCodRet,cTranret,dFecha_hoy,mSdodisp,mMontoret;
						IF cCodRet = '000' THEN
							LET cCodRet = '00000';
							LET cMensaje = 'Exitoso';
						ELSE
							LET cMensaje = 'Error controlado cargo_ref'||cProcLiqIVA; 
							EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (cCodRet, '', cMensaje, cNombreSp);	
							RETURN cCodRet, cFolio, cMensaje;								
						END IF;
					END IF;	
				ELSE
					LET cFolio = '';
					LET cCodRet = '00999';
					LET cMensaje = 'Saldo no disponible en cuenta CFE';
					RETURN cCodRet, cFolio, cMensaje;

				END IF;
				
				--ACTUALIZACION DE REGISTRO DEL PROCESO DE LIQUIDACION DEL IVA DE LA COMISION DE LA CFE
				IF cCodRet = '00000' THEN
					UPDATE "informix".sac_procesos_liqhs
					SET status = '1', saldo_cta_pres = iSdo_actual, importe_srv = deImporte_Coms_IVA_srv, inporte_chq = deImporte_Coms_IVA_chq
					WHERE proceso = cProcLiqIVA AND status = '0' AND fecha_proceso = dFecha_hoy;
				ELSE
					UPDATE "informix".sac_procesos_liqhs
					SET status = '0', saldo_cta_pres = iSdo_actual, importe_srv = 0, inporte_chq = 0
					WHERE proceso = cProcLiqIVA AND status = '0' AND fecha_proceso = dFecha_hoy;
				END IF;
			END IF;
		ELSE
			LET cFolio = '';
			LET cCodRet = '00002';
			LET cMensaje = 'Tipo de liquidacion incorrecta';
			RETURN cCodRet, cFolio, cMensaje;
		END IF;			

		IF deImporte_Servicios = deImporte_Cheques THEN
			RETURN cCodRet, cFolio, cMensaje;
		ELIF iSdo_actual < deImporte_Cheques THEN
			--ENVIO DE CORREO DE NOTIFICACION LATINIA
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_CTAPRE','GRUPO_HOMO_SERV', '','', '2',
			cNombreServicio,iSdo_actual,deImporte_Cheques,'','','','','','','','','',1,0,0,0,0,'','') 
			INTO cCod_err2;
			
			LET cCodRet = '00101';
			LET cMensaje = 'Diferencia en sdo_cta';
			RETURN cCodRet, cFolio, cMensaje;
		ELIF deImporte_Servicios < deImporte_Cheques THEN
			--ENVIO DE CORREO DE NOTIFICACION LATINIA
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_PGOCHE','GRUPO_HOMO_SERV', '','', '2',
			cNombreServicio,deImporte_Servicios,deImporte_Cheques,'','','','','','','','','',1,0,0,0,0,'','') 
			INTO cCod_err2;
			
			LET cCodRet = '00102';
			LET cMensaje = 'Diferencia en Importe de servicios';
			RETURN cCodRet, cFolio, cMensaje;
		ELIF deImporte_Servicios > deImporte_Cheques	THEN
			--ENVIO DE CORREO DE NOTIFICACION LATINIA
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_PGOSER','GRUPO_HOMO_SERV', '','', '2',
			cNombreServicio,deImporte_Servicios,deImporte_Cheques,'','','','','','','','','',1,0,0,0,0,'','')
			INTO cCod_err2;
			
			LET cCodRet = '00103';
			LET cMensaje = 'Diferencia en Importe de cheques';			
			RETURN cCodRet, cFolio, cMensaje;
		END IF;
END;	
END PROCEDURE
DOCUMENT
'+----------------------------------------------------------------------------------------------------------------------+',
'+ Realizo: Daniel Hernandez Garcia																						+',
'+ Proyecto: RQM 10 1619 Cobro Comision CFE																				+',
'+ Funcion del SP: Realizar la liquidacion de la comision e iva de la comision del cliente para el servicio de la CFE 	+',
'+----------------------------------------------------------------------------------------------------------------------+';

CREATE PROCEDURE "informix".sp_sac_insertaremesasnoconciliadaswu(pFecha_Inicio DATE, pFecha_Fin DATE, pUsuario CHAR(8))

RETURNING 
		CHAR(5)		AS codigo_respuesta,
		CHAR(80)    AS mensaje_respuesta;
		
		--DEFINICION DE VARIABLES 
		DEFINE iSqlError 			INTEGER;
		DEFINE cCodRet 				VARCHAR(5);
		DEFINE dFechaHoy 			DATE ;
		DEFINE iServicios 			INTEGER; 
		DEFINE cDiferencia 			VARCHAR(16);
		DEFINE dFechaIni 			DATE;
		DEFINE dFechaFin 			DATE;
		DEFINE cFolioSucCheques 	VARCHAR(16);
		DEFINE cReferencia 			VARCHAR(11);
		DEFINE cReferencia1			VARCHAR(40);
		DEFINE cCuentaPrestadora	VARCHAR(11);	
		DEFINE iSumaServicios		INTEGER;
		DEFINE iPagosCheques        INTEGER;
		DEFINE cStatus				VARCHAR(1);
		DEFINE iCantidadPagosServ   INTEGER;	
		DEFINE cTransaccEfec        VARCHAR(4);
		DEFINE cTransaccAbo         VARCHAR(4);
		DEFINE cCategoria 			VARCHAR(2);
		DEFINE cConvenio 			VARCHAR(3);
		DEFINE cFolioSucServicios   VARCHAR(16);
		DEFINE cExiste				VARCHAR(2);
		DEFINE dFechaMaxima 		DATETIME YEAR TO FRACTION(5);
		DEFINE iCountServicios		INTEGER;
		DEFINE iCount 				INTEGER;
		
		DEFINE cMensaje				VARCHAR(80);
		DEFINE cRev					CHAR(1);
		DEFINE iCantidadCheques		INTEGER;
		DEFINE iCantidadPagosPAY	INTEGER;		
		DEFINE cDescripcionSPJ	    VARCHAR(100);
		DEFINE sCont				INTEGER;
		DEFINE iFolio_suc_serv      VARCHAR(13);
		DEFINE foreignA				VARCHAR(20);
		DEFINE mt_cn                VARCHAR(13);
		DEFINE iFolio_suc      		VARCHAR(16);
		DEFINE iProceso             VARCHAR(13);
		DEFINE sCommit              INTEGER;
		DEFINE countFolios          INTEGER;
		DEFINE countFoliosSuc       INTEGER;
		DEFINE cStmt 			    CHAR (500);
		
		--INICIALIZAMOS LAS VARIABLES
		LET iSqlError = 0; 
		LET cCodRet = '00000';
		LET dFechaHoy = CURRENT;
		LET iServicios = 0;
		LET cDiferencia ="Sin Diferencia";
		LET dFechaIni=CURRENT;
		LET dFechaFin = CURRENT;
		LET cFolioSucCheques = "";
		LET cReferencia ="";
		LET cReferencia1 ="";
		LET cCuentaPrestadora = "";
		LET iPagosCheques = 0;
		LET cStatus = '0';
		LET iCantidadPagosServ = 0;
		LET cTransaccEfec      = "";
		LET cTransaccAbo      = "";
		LET cFolioSucServicios = "";
		LET cExiste = "NO";
		LET dFechaMaxima = CURRENT;
		LET iCountServicios = 0;
		LET iCount =0;
		--LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
		--LET cConvenio = SUBSTRING(pConvenio FROM 3 FOR 3);
		LET cCategoria = '';
		LET cConvenio = '';
		
		LET cMensaje				='PROCESO EXITOSO';
		LET cRev					='';
		LET iCantidadCheques		= 0;
		LET iCantidadPagosPAY		= 0;		
		LET cDescripcionSPJ	 		= 'Inserta datos de Remesas NO conciliadas de WU, OV y VG';
		LET sCont				    = 0;
		LET iFolio_suc_serv			= '';
		LET foreignA                = '';
		LET mt_cn                   = '';
		LET iFolio_suc              = '';
		LET iProceso                = '';
		LET sCommit                 =  0;
		LET countFolios             =  0;
		LET countFoliosSuc          =  0;
		LET cStmt                   = '';
		
		BEGIN
			
			ON EXCEPTION SET iSqlError
				IF iSqlError <> 0 THEN		
					
					LET cCodRet = iSqlError;
					LET cMensaje = "ERROR";
					
					TRUNCATE bdisac:"informix".sac_chequesrevwu_paso;
					TRUNCATE bdisac:"informix".sac_serviciosrevwu_paso;
					TRUNCATE bdisac:"informix".sac_conciliacionrevwu_paso;
					--Eliminamos las tablas pagadas	
					TRUNCATE bdisac:"informix".sac_chequeswu_paso;
					TRUNCATE bdisac:"informix".sac_servicioswu_paso;
					TRUNCATE bdisac:"informix".sac_wucaja_paso;
					
					RETURN cCodRet, cMensaje;					

				END IF;
			END EXCEPTION;
			
			
			--SET DEBUG FILE TO  '/RESPALDOSNEW/enrique/sp_sac_insertaremesasnoconciliadaswu_pbacost.out';
			--TRACE ON;
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			IF (pFecha_Inicio =="" OR pFecha_Inicio IS NULL) OR (pFecha_Fin =="" OR pFecha_Fin IS NULL) THEN 
				LET cCodRet = '00001'; --Parametros vacios
				LET cMensaje = "ERROR";
				RETURN cCodRet,cMensaje;	
			ELSE 
				IF pFecha_Inicio = pFecha_Fin THEN		
					
					SELECT proceso 
					into iProceso 
					FROM "informix".sac_procesos_jobs 
					where fecha_proceso = pFecha_Fin and proceso='IND_RNC_WU';
					IF NVL(iProceso,"") == "" THEN
						--INSERTA EN BITACORA
						EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_RNC_WU', pFecha_Fin, '0', 'informix', 'sp_sac_insertaremesasnoconciliadaswu_pbacost', cDescripcionSPJ);
					ELSE
						SELECT status 
						INTO cStatus
						FROM "informix".sac_procesos_jobs 
						WHERE fecha_proceso = pFecha_Fin and proceso='IND_RNC_WU';
						IF cStatus = '0' THEN						
							DELETE {+INDEX("informix".sac_wu_remesasnoconciliadas idxsac_wu_remesasnoconciliadasnnr)} FROM "informix".sac_wu_remesasnoconciliadas where retfecha = pFecha_Fin;										
						END IF;
					END IF;			
				END IF;	
				IF cStatus = '0' THEN
					--Remesas NO Conciliadas REVERSADAS
					FOREACH	
						select numcategoria, numconvenio
						into cCategoria, cConvenio
						from bdisac:"informix".sac_convenios
						where numcategoria || numconvenio in ('07006','07007','07008')
						
						TRUNCATE TABLE bdisac:"informix".sac_chequesrevwu_paso;
						TRUNCATE TABLE bdisac:"informix".sac_serviciosrevwu_paso;
						TRUNCATE TABLE bdisac:"informix".sac_conciliacionrevwu_paso;
						TRUNCATE TABLE bdisac:"informix".sac_chequeswu_paso;
						TRUNCATE TABLE bdisac:"informix".sac_servicioswu_paso;
						TRUNCATE TABLE bdisac:"informix".sac_wucaja_paso;
						
						SELECT fecha_hoy {+INDEX(bdisac:"informix".sac_fechas idx_fechas1)}
						INTO dFechaHoy
						FROM bdisac:"informix".sac_fechas
						WHERE empresa = '001'; 
						
						SELECT cuenta_prestadora, trans_cen_efectivo_cliente, trans_cen_cargo_cliente
						INTO cCuentaPrestadora, cTransaccEfec, cTransaccAbo
						FROM bdisac:"informix".sac_convenios 
						WHERE numcategoria= cCategoria
						AND numconvenio= cConvenio;
						
						--Tomamos los valores de las fecha de los parametros
						LET dFechaIni = pFecha_Inicio;
						LET dFechaFin = pFecha_Fin;
						
						LET cRev					='1';
						LET iCantidadPagosPAY		= 0;
						
						IF dFechaIni = dFechaFin AND dFechaIni = dFechaHoy THEN --Consulta al dia
						
							--INSERT {+INDEX("informix".sac_chequesrevwu_paso idx_tmpchequesrevwu1)} INTO bdisac:"informix".sac_chequesrevwu_paso
							drop table if exists temp988_sc_movdia;
							SELECT folio_suc, fech_alt, cancelad, referencia
							FROM bdicheq:"informix".sc_movdia 
							WHERE fech_alt = dFechaHoy
							AND cuenta = cCuentaPrestadora
							AND transacc IN (cTransaccEfec,cTransaccAbo)
							INTO temp988_sc_movdia;
							
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasc_movdia.unl SELECT folio_suc, fech_alt, ''' || pUsuario || ''' FROM temp988_sc_movdia WHERE cancelad = ''S'' AND referencia = ''REV'';">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							-- Carga de informacion sac_chequesrevwu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasc_movdia.unl INSERT INTO bdisac:"informix".sac_chequesrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasc_movdia.unl';
							SYSTEM cStmt;
							
							--Insertamos en las tablas pagadas  
							--INSERT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} INTO bdisac:"informix".sac_chequeswu_paso
							
							
							--Se descarga la informaciÃ³n
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasc_movdia.unl SELECT folio_suc, fech_alt, ''' || pUsuario || ''' FROM temp988_sc_movdia WHERE cancelad <> ''S'';">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_chequeswu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasc_movdia.unl INSERT INTO bdisac:"informix".sac_chequeswu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasc_movdia.unl';
							SYSTEM cStmt;
							
							
							--INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso
							drop table if exists temp988_sac_movimientos;
							SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert 
							FROM bdisac:"informix".sac_movimientos
							WHERE numcategoria= cCategoria
							AND numconvenio= cConvenio
							AND fecha_pago= dFechaHoy
							INTO temp988_sac_movimientos; 
							
							--Se descarga la informaciÃ³n
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_movimientos.unl SELECT folio_suc,referencia1,status_cancelado, fecha_pago,fecha_insert, ''' || pUsuario || ''' FROM temp988_sac_movimientos;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_serviciosrevwu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_movimientos.unl INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_movimientos.unl';
							SYSTEM cStmt;
							
							--Insertamos en las tablas pagadas  
							--INSERT INTO bdisac:"informix".sac_servicioswu_paso
							
							--Se descarga la informaciÃ³n
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_movimientos.unl SELECT folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, ''' || pUsuario || ''' FROM temp988_sac_movimientos;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_servicioswu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_movimientos.unl INSERT INTO bdisac:"informix".sac_servicioswu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_movimientos.unl';
							SYSTEM cStmt;
							
							--Se elimina tabla temp988_sc_movdia
							drop table if exists temp988_sc_movdia;
							-- Se elimina tabla temporal temp988_sac_movimientos
							drop table if exists temp988_sac_movimientos;
							
						ELIF (dFechaIni <> dFechaFin AND dFechaIni <> dFechaHoy AND dFechaFin <> dFechaHoy) OR (dFechaIni = dFechaFin AND dFechaIni <> dFechaHoy AND dFechaFin <> dFechaHoy) THEN --Consulta del dia
					
							--INSERT {+INDEX("informix".sac_chequesrevwu_paso idx_tmpchequesrevwu1)} INTO bdisac:"informix".sac_chequesrevwu_paso
							drop table if exists temp988_sc_movhis;
							SELECT folio_suc, fech_alt, cancelad, referencia
							FROM bdicheq:"informix".sc_movhis 
							WHERE cuenta = cCuentaPrestadora
							AND fech_alt BETWEEN dFechaIni AND dFechaFin -- UAI - se cambia filtro por between
							AND transacc IN (cTransaccEfec,cTransaccAbo)
							INTO temp988_sc_movhis;
							
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_chequesrevwu_paso.unl SELECT folio_suc, fech_alt, ''' || pUsuario || ''' FROM temp988_sc_movhis WHERE cancelad = ''S'' AND referencia = ''REV'';">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_chequesrevwu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_chequesrevwu_paso.unl INSERT INTO bdisac:"informix".sac_chequesrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_chequesrevwu_paso.unl';
							SYSTEM cStmt;
							
							----Insertamos en las tablas pagadas
							--INSERT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} INTO bdisac:"informix".sac_chequeswu_paso
														
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl SELECT folio_suc, fech_alt, ''' || pUsuario || ''' FROM temp988_sc_movhis WHERE cancelad <> ''S'';">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_chequeswu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl INSERT INTO bdisac:"informix".sac_chequeswu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl';
							SYSTEM cStmt;
					
							--INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso
							drop table if exists temp988_sac_movimientoshistorial;
							SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert
							FROM bdisac:"informix".sac_movimientoshistorial
							WHERE numcategoria= cCategoria
							AND numconvenio= cConvenio
							AND fecha_pago BETWEEN dFechaIni AND dFechaFin -- UAI - Se reorganizan filtros y se implementa between
							INTO temp988_sac_movimientoshistorial;
							
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_serviciosrevwu_paso.unl SELECT folio_suc,referencia1,status_cancelado, fecha_pago,fecha_insert, ''' || pUsuario || ''' FROM temp988_sac_movimientoshistorial;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_serviciosrevwu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_serviciosrevwu_paso.unl INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_serviciosrevwu_paso.unl';
							SYSTEM cStmt;
							
							---Insertamos en las tablas pagadas
							--INSERT INTO bdisac:"informix".sac_servicioswu_paso
														
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl SELECT folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, ''' || pUsuario || ''' FROM temp988_sac_movimientoshistorial;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_servicioswu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl INSERT INTO bdisac:"informix".sac_servicioswu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl';
							SYSTEM cStmt;
							
							--Se elimina tabla temp988_sc_movhis
							drop table if exists temp988_sc_movhis;
							--Se elimina tabla temp988_sac_movimientoshistorial
							drop table if exists temp988_sac_movimientoshistorial;
						ELSE
							
							--INSERT {+INDEX("informix".sac_chequesrevwu_paso idx_tmpchequesrevwu1)} INTO bdisac:"informix".sac_chequesrevwu_paso
							drop table if exists temp988_sc_movdia;
							SELECT folio_suc, fech_alt, cancelad, referencia
							FROM bdicheq:"informix".sc_movdia 
							WHERE fech_alt = dFechaHoy
							--AND cancelad = 'S'
							AND cuenta = cCuentaPrestadora
							AND transacc IN (cTransaccEfec,cTransaccAbo)
							--AND referencia = 'REV'
							INTO temp988_sc_movdia;
							
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasc_movdia.unl SELECT folio_suc, fech_alt, ''' || pUsuario || ''' FROM temp988_sc_movdia WHERE cancelad = ''S'' AND referencia = ''REV'';">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_chequesrevwu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasc_movdia.unl INSERT INTO bdisac:"informix".sac_chequesrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasc_movdia.unl';
							SYSTEM cStmt;

							--Insertamos en las tablas pagadas
							--INSERT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} INTO bdisac:"informix".sac_chequeswu_paso
													
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl SELECT folio_suc, fech_alt, ''' || pUsuario || ''' FROM temp988_sc_movdia WHERE cancelad <> ''S'';">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_chequeswu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl INSERT INTO bdisac:"informix".sac_chequeswu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl';
							SYSTEM cStmt;	
							
							--INSERT {+INDEX("informix".sac_chequesrevwu_paso idx_tmpchequesrevwu1)} INTO bdisac:"informix".sac_chequesrevwu_paso
							drop table if exists temp988_sc_movhis;
							SELECT folio_suc, fech_alt, cancelad, referencia
							FROM bdicheq:"informix".sc_movhis 
							WHERE cuenta = cCuentaPrestadora
							AND fech_alt BETWEEN dFechaIni AND dFechaFin -- UAI - se cambia filtro por between
							--AND cancelad = 'S'
							AND transacc IN (cTransaccEfec,cTransaccAbo)
							--AND referencia = 'REV'
							INTO temp988_sc_movhis;
							
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_chequesrevwu_paso.unl SELECT folio_suc, fech_alt, ''' || pUsuario || ''' FROM temp988_sc_movhis WHERE cancelad = ''S'' AND referencia = ''REV'';">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_chequesrevwu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_chequesrevwu_paso.unl INSERT INTO bdisac:"informix".sac_chequesrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_chequesrevwu_paso.unl';
							SYSTEM cStmt;		
							
							
							----Insertamos en las tablas pagadas
							--INSERT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} INTO bdisac:"informix".sac_chequeswu_paso
							
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl SELECT folio_suc, fech_alt, ''' || pUsuario || ''' FROM temp988_sc_movhisWHERE cancelad <> ''S'';">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_chequeswu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl INSERT INTO bdisac:"informix".sac_chequeswu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl';
							SYSTEM cStmt;		
								
							
							--INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso
							drop table if exists temp988_sac_movimientos;
							SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert 
							FROM bdisac:"informix".sac_movimientos
							WHERE fecha_pago= dFechaHoy
							AND numcategoria=  cCategoria
							AND numconvenio= cConvenio
							INTO temp988_sac_movimientos;
							
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_serviciosrevwu_paso.unl SELECT folio_suc,referencia1,status_cancelado, fecha_pago,fecha_insert, ''' || pUsuario || ''' FROM temp988_sac_movimientos;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_serviciosrevwu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_serviciosrevwu_paso.unl INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_serviciosrevwu_paso.unl';
							SYSTEM cStmt;		
							
							--Insertamos en las tablas pagadas
							--INSERT INTO bdisac:"informix".sac_servicioswu_paso
							
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl SELECT folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, ''' || pUsuario || ''' FROM temp988_sac_movimientos;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_servicioswu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl INSERT INTO bdisac:"informix".sac_servicioswu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl';
							SYSTEM cStmt;		

							
							--INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso
							drop table if exists temp988_sac_movimientoshistorial;
							SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago, fecha_insert
							FROM bdisac:"informix".sac_movimientoshistorial
							WHERE numcategoria=  cCategoria 
							AND fecha_pago BETWEEN dFechaIni AND dFechaFin -- UAI - Se reorganizan filtros y se implementa between
							AND numconvenio= cConvenio
							INTO temp988_sac_movimientoshistorial;
							
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_serviciosrevwu_paso.unl SELECT folio_suc,referencia1,status_cancelado, fecha_pago, fecha_insert, ''' || pUsuario || ''' FROM temp988_sac_movimientoshistorial;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_serviciosrevwu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_serviciosrevwu_paso.unl INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_serviciosrevwu_paso.unl';
							SYSTEM cStmt;		
							
							---Insertamos en las tablas pagadas
							--INSERT INTO bdisac:"informix".sac_servicioswu_paso
							
							-- Descarga de informacion
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl SELECT folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, ''' || pUsuario || ''' FROM temp988_sac_movimientoshistorial;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							--Se carga la informacion sac_servicioswu_paso
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl INSERT INTO bdisac:"informix".sac_servicioswu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl';
							SYSTEM cStmt;		
							
							--Se elimina tabla temp988_sc_movdia
							drop table if exists temp988_sc_movdia;
							--Se elimina tabla temp988_sc_movhis
							drop table if exists temp988_sc_movhis;
							-- Se elimina tabla temporal temp988_sac_movimientos
							drop table if exists temp988_sac_movimientos;
							--Se elimina tabla temp988_sac_movimientoshistorial
							drop table if exists temp988_sac_movimientoshistorial;
						END IF;
							
							--INSERT INTO bdisac:"informix".sac_wucaja_paso
												
							--Se implementa FOREACH para quitar la bÃºsqueda secuencial
							drop table if exists temp988_sac_wu_pay;
								
							SELECT mtcn, foreign_rs_refnum_rq,fecha_insert
							FROM bdisac:"informix".sac_wu_pay											   
							WHERE 
			--	2014.03.07 FRG-i
							fecha_insert::DATE  >= dFechaIni
							AND fecha_insert::DATE  <= dFechaFin
							and retcode = '00000'
							and mtcn in
								(select referencia1 from bdisac:sac_movimientoshistorial
								WHERE 
								fecha_pago >= dFechaIni
								AND fecha_pago <= dFechaFin
								AND numcategoria= cCategoria 
								AND numconvenio= cConvenio)
							INTO temp988_sac_wu_pay;
								
							/*LET iCount = 0;
							
							BEGIN WORK;
							FOREACH WITH HOLD
								SELECT referencia1 
								INTO cReferencia1
								FROM bdisac:sac_movimientoshistorial
								WHERE fecha_pago BETWEEN dFechaIni AND dFechaFin -- UAI - Se reorganizan filtros y se implementa between
									AND numcategoria= cCategoria 
									AND numconvenio= cConvenio
								
								IF iCount > 0 THEN -- Solo inserta los los registros por referencia
									INSERT INTO temp988_sac_wu_pay
									SELECT mtcn, foreign_rs_refnum_rq,fecha_insert
									FROM bdisac:"informix".sac_wu_pay											   
									WHERE 
					--	2014.03.07 FRG-i
										fecha_insert::DATE BETWEEN dFechaIni AND dFechaFin -- UAI - Se reorganizan filtros y se implementa between
										AND retcode = '00000'
										AND mtcn = cReferencia1;
								ELSE -- Crea la tabla temporal y procede a insertar la informaciÃ³n por referencia
									SELECT mtcn, foreign_rs_refnum_rq,fecha_insert
									FROM bdisac:"informix".sac_wu_pay											   
									WHERE 
					--	2014.03.07 FRG-i
										fecha_insert::DATE BETWEEN dFechaIni AND dFechaFin -- UAI - Se reorganizan filtros y se implementa between
										AND retcode = '00000'
										AND mtcn = cReferencia1
									INTO temp988_sac_wu_pay;
								END IF;
								
								--Hago commit y vuelvo a iniciar
								LET iCount = iCount + 1;
								
								IF iCount = 1000 THEN
									COMMIT WORK;
									LET iCount = 1;
									BEGIN WORK;
								END IF;
								
							END FOREACH;
							COMMIT WORK;*/
							
							LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_wu_pay.unl SELECT mtcn, foreign_rs_refnum_rq,fecha_insert::DATE, ''' || pUsuario || ''' FROM temp988_sac_wu_pay;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
                            SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;	
							
							drop table if exists temp988_sac_wu_pay;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
							SYSTEM cStmt;
							LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_wu_pay.unl INSERT INTO bdisac:"informix".sac_wucaja_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
							SYSTEM cStmt;
							LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_wu_pay.unl';
							SYSTEM cStmt;	
							
						WHILE (dFechaIni <= dFechaFin)

							SELECT COUNT(folio_suc) --SERVICIOS
							INTO iCantidadPagosServ
							FROM bdisac:"informix".sac_serviciosrevwu_paso
							WHERE fecha_pago = dFechaIni
							AND status_cancelado = 'S'
							AND usuario = pUsuario;
							
							--REALIZAMOS LA BUQUEDA PORFECHAS ANTERIORES
							SELECT COUNT(folio_suc)  --cheques
							INTO iPagosCheques
							FROM bdisac:"informix".sac_chequesrevwu_paso
							WHERE fech_alt = dFechaIni
							AND usuario = pUsuario;
								
							IF (iCantidadPagosServ = iPagosCheques)THEN
								LET cDiferencia = "Sin Diferencia";	
								
								INSERT INTO "informix".sac_wu_remesasnoconciliadas (retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
								VALUES (cCodRet,dFechaIni,iCantidadPagosServ,iPagosCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
							ELSE
								DELETE {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} FROM bdisac:"informix".sac_conciliacionrevwu_paso WHERE usuario = pUsuario;
								IF (iPagosCheques > iCantidadPagosServ) THEN
									
										--INSERT INTO bdisac:"informix".sac_conciliacionrevwu_paso
										drop table if exists temp988_sac_chequesrevwu_paso;
										SELECT cheq.folio_suc ,mov.referencia1 
										FROM bdisac:"informix".sac_chequesrevwu_paso cheq, bdisac:"informix".sac_serviciosrevwu_paso mov
										WHERE cheq.fech_alt = dFechaIni
										AND  cheq.fech_alt = mov.fecha_pago
										AND  cheq.folio_suc =  mov.folio_suc
										AND cheq.usuario = pUsuario
										AND cheq.usuario = mov.usuario
										AND cheq.folio_suc NOT IN (SELECT folio_suc
															FROM bdisac:"informix".sac_serviciosrevwu_paso
															WHERE fecha_pago = dFechaIni
															AND status_cancelado = 'S'
															AND usuario = pUsuario)
										INTO temp988_sac_chequesrevwu_paso;
										LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_conciliacionrevwu_paso.unl SELECT cheq.folio_suc ,mov.referencia1, ''' || pUsuario || ''' FROM temp988_sac_chequesrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
										SYSTEM cStmt;
										LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
										SYSTEM cStmt;
										LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
										SYSTEM cStmt;
										
										
										drop table if exists temp988_sac_chequesrevwu_paso;
										LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
										SYSTEM cStmt;
										LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_conciliacionrevwu_paso.unl INSERT INTO bdisac:"informix".sac_conciliacionrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
										SYSTEM cStmt;
										LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
										SYSTEM cStmt;
										LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
										SYSTEM cStmt;
										LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_conciliacionrevwu_paso.unl';
										SYSTEM cStmt;							
										
								END IF;

								IF (iCantidadPagosServ > iPagosCheques) THEN
								
										--INSERT INTO bdisac:"informix".sac_conciliacionrevwu_paso
										drop table if exists temp988_sac_serviciosrevwu_paso;
										SELECT folio_suc, referencia1
										FROM bdisac:"informix".sac_serviciosrevwu_paso
										WHERE fecha_pago = dFechaIni
										AND status_cancelado = 'S'
										AND usuario = pUsuario
										AND  folio_suc NOT IN(SELECT folio_suc 
															  FROM bdisac:"informix".sac_chequesrevwu_paso
															  WHERE fech_alt = dFechaIni
															  AND usuario = pUsuario)
										AND folio_suc NOT IN(SELECT {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} folio_suc 
															FROM bdisac:"informix".sac_conciliacionrevwu_paso
															WHERE usuario = pUsuario)
										INTO temp988_sac_serviciosrevwu_paso;
										
										LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_conciliacionrevwu_paso.unl SELECT folio_suc, referencia1, ''' || pUsuario || ''' FROM temp988_sac_serviciosrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
										SYSTEM cStmt;
										LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
										SYSTEM cStmt;
										LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
										SYSTEM cStmt;
										
										
										drop table if exists temp988_sac_serviciosrevwu_paso;
										LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
										SYSTEM cStmt;
										LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_conciliacionrevwu_paso.unl INSERT INTO bdisac:"informix".sac_conciliacionrevwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
										SYSTEM cStmt;
										LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
										SYSTEM cStmt;
										LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
										SYSTEM cStmt;
										LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_conciliacionrevwu_paso.unl';
										SYSTEM cStmt;		
															
								END IF; 					    

								LET iCount = 0; -- Se inicializa la variable
								
								FOREACH 
								
									SELECT {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} DISTINCT(referencia) 
									INTO cReferencia
									FROM bdisac:"informix".sac_conciliacionrevwu_paso
									WHERE usuario = pUsuario
									
									SELECT {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} COUNT(referencia)
									INTO iSumaServicios 
									FROM bdisac:"informix".sac_conciliacionrevwu_paso
									WHERE referencia = cReferencia
									AND usuario = pUsuario; 
									
									SELECT {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} COUNT(referencia)
									INTO iCountServicios 
									FROM bdisac:"informix".sac_conciliacionrevwu_paso
									WHERE usuario = pUsuario; 	 
									
									IF iSumaServicios > 1 THEN 
										LET iCount = iCount + iSumaServicios ;
									ELSE 
										LET iCount = iCount + 1;
									END IF;						
										
									  SELECT MAX(fecha_insert) 
									  INTO dFechaMaxima 
									  FROM bdisac:"informix".sac_servicioswu_paso 
									  WHERE fecha_pago = dFechaIni
									  AND referencia1 = cReferencia
									  AND usuario = pUsuario;
										
										--IF EXISTS (SELECT folio_suc FROM bdisac:"informix".sac_servicioswu_paso WHERE fecha_insert = dFechaMaxima AND status_cancelado = 'N' AND referencia1 = cReferencia AND usuario = pUsuario) THEN --
										SELECT folio_suc,count(*) 
										into iFolio_suc_serv,countFolios 
										FROM bdisac:"informix".sac_servicioswu_paso 
										WHERE fecha_insert = dFechaMaxima 
										AND status_cancelado = 'N' 
										AND referencia1 = cReferencia 
										AND usuario = pUsuario group by folio_suc;
										
										IF NVL(iFolio_suc_serv,"") <> "" and countFolios > 0 THEN	
											SELECT folio_suc 
											INTO cFolioSucServicios
											FROM bdisac:"informix".sac_servicioswu_paso
											WHERE fecha_insert = dFechaMaxima 
											AND status_cancelado = 'N'
											AND fecha_insert = dFechaMaxima
											AND referencia1 = cReferencia
											AND usuario = pUsuario;
											
											--IF EXISTS(SELECT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} folio_suc FROM bdisac:"informix".sac_chequeswu_paso  WHERE folio_suc = cFolioSucServicios AND fech_alt = dFechaIni AND usuario = pUsuario) THEN 
											SELECT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} folio_suc, count(*)
											into iFolio_suc,countFoliosSuc
											FROM bdisac:"informix".sac_chequeswu_paso  
											WHERE fech_alt = dFechaIni 
											AND folio_suc = cFolioSucServicios
											AND usuario = pUsuario group by folio_suc;	
											
											IF NVL(iFolio_suc,"") <> "" and countFoliosSuc > 0 THEN
													--IF EXISTS (SELECT foreign_rs_refnum_rq,mtcn FROM bdisac:"informix".sac_wucaja_paso WHERE foreign_rs_refnum_rq= cFolioSucServicios AND mtcn = cReferencia AND usuario = pUsuario)THEN 
													SELECT foreign_rs_refnum_rq,mtcn 
													into foreignA,mt_cn 
													FROM bdisac:"informix".sac_wucaja_paso 
													WHERE foreign_rs_refnum_rq= cFolioSucServicios 
													AND mtcn = cReferencia 
													AND usuario = pUsuario;	
													
													IF NVL(foreignA,"") <> "" THEN
														LET cExiste = "SI";
													ELSE 
														LET cExiste = "NO";	
														
													END IF;
											END IF;	
										END IF;
									
									IF cExiste = "NO" THEN 
									
										IF iSumaServicios > 1 THEN 
											LET cDiferencia = cReferencia || "(" || iSumaServicios||")";	
											INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
											VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iPagosCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
								 
										ELSE 
											LET cDiferencia = cReferencia;
											INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
											VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iPagosCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
								 
										END IF;
										
									ELIF  cExiste = "SI" AND iCount = iCountServicios AND cDiferencia = "Sin Diferencia" THEN 
											INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
											VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iPagosCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
								
									END IF;
									
									LET cFolioSucServicios = "";							
									LET cExiste = "NO";
									LET cReferencia = "";
									LET iSumaServicios =0;
								END FOREACH;
							END IF;
							
							--AUMENTAMOS UN DIA EN LA dFechaIni
							LET iSumaServicios = 0;
							LET iCantidadPagosServ = 0;
							LET iPagosCheques =0;
							LET iServicios = 0;
							LET iCount = 0;
							LET iCountServicios =0;
							LET cDiferencia = "Sin Diferencia";	
							LET dFechaIni = dFechaIni + INTERVAL(1) DAY TO DAY;
						END WHILE;
					END FOREACH;
					--Remesas NO Conciliadas PAGADAS
					FOREACH
						select numcategoria, numconvenio
						into cCategoria, cConvenio
						from bdisac:"informix".sac_convenios
						where numcategoria || numconvenio in ('07006','07007','07008')
						
						TRUNCATE TABLE bdisac:"informix".sac_chequeswu_paso;
						TRUNCATE TABLE bdisac:"informix".sac_servicioswu_paso;
						TRUNCATE TABLE bdisac:"informix".sac_conciliacionwu_paso;
						TRUNCATE TABLE bdisac:"informix".sac_wucaja_paso;
			
						SELECT trans_cen_efectivo_cliente, trans_cen_cargo_cliente
						INTO cTransaccEfec, cTransaccAbo
						FROM bdisac:"informix".sac_convenios
						WHERE numcategoria= cCategoria 
						AND numconvenio= cConvenio;
						
						--Tomamos los valores de las fecha de los parametros
						LET dFechaIni = pFecha_Inicio;
						LET dFechaFin = pFecha_Fin;
						
						LET cRev					='0';
						
						--insert into bdisac:"informix".sac_servicioswu_paso
						drop table if exists temp988_sac_movimientoshistorial;
						select folio_suc,referencia1,status_cancelado,flag_confirmacion_sucursal,fecha_pago,fecha_insert
						from bdisac:"informix".sac_movimientoshistorial 
						where fecha_pago >= dFechaIni
					    and fecha_pago <= dFechaFin
						and numcategoria = cCategoria
						and numconvenio = cConvenio
						INTO temp988_sac_movimientoshistorial;
										
						LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl SELECT folio_suc,referencia1,status_cancelado,flag_confirmacion_sucursal,fecha_pago,fecha_insert, ''' || pUsuario || ''' FROM temp988_sac_movimientoshistorial;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						
						
						drop table if exists temp988_sac_movimientoshistorial;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl INSERT INTO bdisac:"informix".sac_servicioswu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_servicioswu_paso.unl';
						SYSTEM cStmt;				
						
						--INSERT {+INDEX("informix".sac_servicioswu_paso idx_tmpservicioswu1)} INTO bdisac:"informix".sac_chequeswu_paso
						drop table if exists temp988_sc_movhis;
						select a.folio_suc,a.fech_alt 
						FROM bdicheq:"informix".sc_movhis a
						INNER JOIN bdisac:"informix".sac_servicioswu_paso b
							ON b.folio_suc = a.folio_suc
							AND b.fecha_pago = a.fech_alt
							AND b.usuario = pUsuario
						WHERE sucursal != ''
							AND a.fech_alt >= dFechaIni
							AND a.fech_alt <= dFechaFin
							AND a.transacc IN (cTransaccEfec,cTransaccAbo)
							AND a.cancelad <> 'S'
						INTO temp988_sc_movhis;
										
						LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl SELECT folio_suc,fech_alt, ''' || pUsuario || ''' FROM temp988_sc_movhis;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						
						
						drop table if exists temp988_sc_movhis;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl INSERT INTO bdisac:"informix".sac_chequeswu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl';
						SYSTEM cStmt;		
						
						 
						--INSERT {+INDEX("informix".sac_servicioswu_paso idx_tmpservicioswu1)} INTO bdisac:"informix".sac_chequeswu_paso
						drop table if exists temp988_sc_movhis_old;
						select a.folio_suc,a.fech_alt 
						FROM bdicheq:"informix".sc_movhis_old a
						INNER JOIN bdisac:"informix".sac_servicioswu_paso b
							ON b.folio_suc = a.folio_suc
							AND b.fecha_pago = a.fech_alt
							AND b.usuario = pUsuario
						WHERE sucursal != ''
							AND a.fech_alt >= dFechaIni
							AND a.fech_alt <= dFechaFin
							AND a.transacc IN (cTransaccEfec,cTransaccAbo)
							AND a.cancelad <> 'S'
						INTO temp988_sc_movhis_old;
										
						LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl SELECT folio_suc,fech_alt, ''' || pUsuario || ''' FROM temp988_sc_movhis_old;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						
						
						drop table if exists temp988_sc_movhis_old;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl INSERT INTO bdisac:"informix".sac_chequeswu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_chequeswu_paso.unl';
						SYSTEM cStmt;		
						
							
						
						--insert {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} into bdisac:"informix".sac_conciliacionwu_paso
						drop table if exists temp988_sac_movimientoshistorial;
						select a.folio_suc, a.referencia1
						from bdisac:"informix".sac_movimientoshistorial a, bdisac:"informix".sac_chequeswu_paso b				
						where a.numcategoria = cCategoria
						and a.numconvenio = cConvenio
						and a.folio_suc = b.folio_suc																												
						and a.fecha_pago = b.fech_alt																						 
						and b.usuario = pUsuario
						INTO temp988_sac_movimientoshistorial;
										
						LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_movimientoshistorial.unl SELECT folio_suc, referencia1, ''' || pUsuario || ''' FROM temp988_sac_movimientoshistorial;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						
						
						drop table if exists temp988_sac_movimientoshistorial;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_movimientoshistorial.unl INSERT INTO bdisac:"informix".sac_conciliacionwu_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_movimientoshistorial.unl';
						SYSTEM cStmt;		
							
						   
						--insert {+INDEX("informix".sac_conciliacionwu_paso idx_conciliacionwu)} into bdisac:"informix".sac_wucaja_paso
						drop table if exists temp988_sac_wu_pay; -- UAI - Se implementa inner join y se cambia formato en filtro de fecha
						select a.mtcn,a.foreign_rs_refnum_rq,a.fecha_insert 
						from bdisac:"informix".sac_wu_pay a
						inner join bdisac:"informix".sac_conciliacionwu_paso b on b.referencia = a.mtcn
					    where a.fecha_insert between (EXTEND(MDY(MONTH(dFechaIni),DAY(dFechaIni),YEAR(dFechaIni)), YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND) 
												 and (EXTEND(MDY(MONTH(dFechaFin),DAY(dFechaFin),YEAR(dFechaFin)), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)
					    and a.conf_pago='P' 
					    and a.retcode = '00000'
					    and b.usuario = pUsuario	
						INTO temp988_sac_wu_pay;
										
						LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/depuraremesas/actualizasac_wu_pay.unl SELECT mtcn,foreign_rs_refnum_rq,fecha_insert::DATE, ''' || pUsuario || ''' FROM temp988_sac_wu_pay;">/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt = 'chmod 777 /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						
						drop table if exists temp988_sac_wu_pay;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr1.sql';
						SYSTEM cStmt;
						LET cStmt = 'echo "LOAD FROM /RESPALDOSNEW/depuraremesas/actualizasac_wu_pay.unl INSERT INTO bdisac:"informix".sac_wucaja_paso;">/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt= 'dbaccess bdisac	/RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/reportemetenr2.sql';
						SYSTEM cStmt;
						LET cStmt = 'rm -f /RESPALDOSNEW/depuraremesas/actualizasac_wu_pay.unl';
						SYSTEM cStmt;	
						
						 WHILE (dFechaIni <= dFechaFin)
						 
							SELECT COUNT(folio_suc) --SERVICIOS
							INTO iCantidadPagosServ
							FROM bdisac:"informix".sac_servicioswu_paso
							WHERE fecha_pago = dFechaIni
							AND status_cancelado = 'N'
							--AND flag_confirmacion_sucursal <> 0
							AND usuario = pUsuario;
				
							SELECT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} COUNT(folio_suc) --CHEQUES
							INTO iCantidadCheques
							FROM bdisac:"informix".sac_chequeswu_paso
							WHERE fech_alt = dFechaIni
							AND usuario = pUsuario;
							
							SELECT COUNT(mtcn)  --PAGOS
							INTO iCantidadPagosPAY
							FROM bdisac:"informix".sac_wucaja_paso
							WHERE fecha_insert::DATE = dFechaIni
							AND usuario = pUsuario;

							IF iCantidadPagosServ = iCantidadCheques AND iCantidadPagosPAY = iCantidadPagosServ THEN
								LET cDiferencia = "Sin Diferencia";
								
								INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
								VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iCantidadCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
							ELSE					
								 FOREACH --	UAI - Se separa consulta para obtener la referencia por bÃºsqueda secuencial
									select referencia 
									into cReferencia
									from bdisac:"informix".sac_conciliacionwu_paso
									where usuario = pUsuario
									
									IF NOT EXISTS(select a.mtcn
													 from bdisac:"informix".sac_wu_pay a
													 where a.fecha_insert between (EXTEND(MDY(MONTH(dFechaIni),DAY(dFechaIni),YEAR(dFechaIni)), YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND) 
																			  and (EXTEND(MDY(MONTH(dFechaFin),DAY(dFechaFin),YEAR(dFechaFin)), YEAR to SECOND)+23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)
													 and a.conf_pago='P' 
													 and a.retcode = '00000'
													 and a.mtcn = cReferencia) THEN
										LET cDiferencia = cReferencia;
										INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
										VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iCantidadCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
									END IF;
									
									
								END FOREACH;
		
							END IF;
							
							IF cDiferencia = "" THEN
								INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
								VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iCantidadCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
							  
							END IF;
							
							--AUMENTAMOS UN DIA EN LA dFechaIni
							LET iCantidadPagosServ = 0;
							LET iCantidadPagosPAY = 0;
							LET iCantidadCheques =0;
							LET cDiferencia = "";
							
							LET dFechaIni = dFechaIni + INTERVAL(1) DAY TO DAY;	
						END WHILE;
					END FOREACH;
				END IF;
			END IF;	
			--ACTUALIZA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_RNC_WU', pFecha_Fin, '1', 'informix', 'sp_sac_insertaremesasnoconciliadaswu_pbacost', cDescripcionSPJ);				
			
			UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_remesasnoconciliadas;
			RETURN cCodRet, cMensaje;			
			
		END 
		
		TRUNCATE TABLE bdisac:"informix".sac_chequesrevwu_paso;
		TRUNCATE TABLE bdisac:"informix".sac_serviciosrevwu_paso;
		TRUNCATE TABLE bdisac:"informix".sac_conciliacionrevwu_paso;
		TRUNCATE TABLE bdisac:"informix".sac_chequeswu_paso;
		TRUNCATE TABLE bdisac:"informix".sac_servicioswu_paso;
		TRUNCATE TABLE bdisac:"informix".sac_wucaja_paso;
		
END PROCEDURE
DOCUMENT 'AUTOR: Uriel Amador Islas',
'FECHA MODIFICACION: 24/04/2024',
'DESCRIPCION: Se omite la creaciÃ³n de tablas temporales consecutivamente.';

CREATE PROCEDURE "informix".sp_liqui_comision_sky(sCategoria CHAR(2), sConvenio CHAR(3))
	RETURNING CHAR(5)  AS CodRet, CHAR(16) AS Folio, CHAR(60) AS Mensaje;
		  
		-- // DECLARACION DE VARIABLES.
	DEFINE Sql_Err           INTEGER;       --Error de SQL
	DEFINE Isam_Err          INTEGER; 		--Error del ISAM
	DEFINE Desc_Err          CHAR(50);		--Descripcion del error 
	DEFINE cCod_err2         CHAR(5);	    --Codigo de error para bitacora de eventos

	-- COMISION Sky
	DEFINE cCodRet_Sky	         	CHAR(5);  		--Codigo de retorno del SP  
	DEFINE vCuenta_Sky          	CHAR(20);	    --Variable para validacion de cuenta	
	DEFINE vFolio_Sky            	CHAR(16);       --Folio de la operacion
	DEFINE pCuenta_Sky		        CHAR(20);       --Cuenta prestadora del servicio
	DEFINE vMensaje_Sky				CHAR(60);       --Mensaje de retorno del SP
	DEFINE vTotal_Cargo_Coms_Sky	MONEY(14,2);    --Total cargo de comision SKY
	DEFINE vTotal_Cargo_Iva_Sky		MONEY(14,2);    --Total cargo de IVA SKY
	DEFINE vTotal_Comision_Sky		MONEY(14,2);    --Total comision SKY
	DEFINE iSdo_actual_Sky			MONEY(14,2);    --Saldo actual de cuenta SKY
	DEFINE ctranret_Sky				CHAR(4);        --Transaccion de retorno del cargo_ref
	DEFINE DFecha_hoy_Sky			DATE;           --Fecha del sistema de Servicios Al Cliente
	DEFINE msdodisp_Sky				MONEY (14,2);   --Saldo disponible de retorno de cargo_ref
	DEFINE mmontoret_Sky			MONEY (14,2);   --Monto retiro de retorno de cargo_ref
	DEFINE cNombreSp				CHAR(18);		--Nombre del SP actual para registro en bitacoras
	DEFINE deImporte_Servicios		DECIMAL(10,2);	--Importe de Servicios para validacion de diferencias
	DEFINE deImporte_Cheques		DECIMAL(10,2);	--Importe de Cheques para validacion de diferencias
	DEFINE cNombreServicio          CHAR(10);       --Nombre del servicio
	DEFINE cDescripcionSPJ	 		CHAR(100);      --Descripcion para bitacora
	
	

	--SET DEBUG FILE TO "/informix/VIMA/sp_liqui_comision_sky.out";
	--TRACE ON;
	
	-- INICIALIZACION DE VARIABLES.
	LET Sql_Err	      = 0;
	LET Isam_Err      = 0;
	LET Desc_Err      = '';
	LET cCod_err2 	= '00000';

	-- COMISION SKY
	LET cCodRet_Sky					='00001';
	LET vCuenta_Sky       			= '';  
	LET vFolio_Sky        			= '';
	LET pCuenta_Sky       			= '';
	LET vMensaje_Sky				= '';
	LET iSdo_actual_Sky				=0;
	LET vTotal_Cargo_Coms_Sky		=0;
	LET vTotal_Cargo_Iva_Sky		=0;
	LET vTotal_Comision_Sky			=0;
	LET ctranret_Sky				='';
	LET DFecha_hoy_Sky				=CURRENT;
	LET msdodisp_Sky				='';
	LET mmontoret_Sky				='';
	LET cNombreSp		    		='sp_liqui_comision_sky';
	LET deImporte_Servicios 	    =0.00;
	LET deImporte_Cheques	    	=0.00;
	LET cNombreServicio             = 'SKY';
	LET cDescripcionSPJ	    		='Ejecuta liquidacion de comisiones del servicio:';
	LET cNombreServicio             = 'SKY';
	
	--GUARDA MENSAJE EN SPL SI DA ERROR LA EJECUCIÃN
	BEGIN

		ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
			IF Sql_Err <> 0 THEN
				LET cCodRet_Sky = Sql_Err;
				EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (Sql_Err, Isam_Err, Desc_Err, cNombreSp);
			 RETURN cCodRet_Sky, vFolio_Sky, vMensaje_Sky;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;				
		
		--OBTIENE LA FECHA DEL DIA DE LA BD DE SERVICIO AL CLIENTE
		SELECT fecha_hoy  
		INTO DFecha_hoy_Sky 
		FROM sac_fechas 
		WHERE empresa = '001';  
		
		--OBTIENE LA CUENTA DE SKY
		SELECT valor INTO pCuenta_Sky 
		FROM   bdisac:"informix".sac_param 
		WHERE  cod_param = '6001';
		
		
		--VALIDA QUE EXISTA LA CUENTA Y CLIENTE							
		SELECT mae.cuenta INTO vCuenta_Sky
		FROM bdicheq:"informix".sc_maechq mae
		INNER JOIN bdicheq:"informix".sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta )
		INNER JOIN bdicheq:"informix".sc_producto pro ON ( pro.empresa = mae.empresa AND pro.producto = mae.producto )
		INNER JOIN bdinteg:"informix".si_cliente cte ON ( cte.numcte = mae.num_cte )
		LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta tar ON ( tar.empresa = mae.empresa AND tar.cuenta = mae.cuenta AND tar.tipo_tarjeta = 'T' AND tar.status_tar = 'A' )
		WHERE mae.empresa = '001'         
		AND mae.cuenta = pCuenta_Sky; 
		
		

		-- // VERIFICA QUE LA CUENTA EXISTA               
		IF vCuenta_Sky is null OR vCuenta_Sky = '' OR vCuenta_Sky <> pCuenta_Sky THEN
			LET vFolio_Sky = '';
			LET cCodRet_Sky = '00100';
			LET vMensaje_Sky = 'No existe cuenta SKY';
			RETURN cCodRet_Sky, vFolio_Sky, vMensaje_Sky;
		END IF;						


		--INICIA PROCESO SKY SI COINCIDE EL CONVENIO Y CATEGORIA				

	IF EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_liqhs WHERE proceso = 'LIQU_COMISSKY' AND status = '1' AND fecha_proceso = DFecha_hoy_Sky) THEN --IF SI LA LIQUIDACION YA FUE EJECUTADA
		LET cCodRet_Sky= "00001";
		LET vMensaje_Sky = "Liquidacion SKY ya ha sido ejecutada";
		RETURN cCodRet_Sky, vFolio_Sky, vMensaje_Sky;
	ELIF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_liqhs WHERE proceso = 'LIQU_COMISSKY' AND status = '0' AND fecha_proceso = DFecha_hoy_Sky) THEN
		INSERT INTO bdisac:"informix".sac_procesos_liqhs(proceso, fecha_proceso, status, user_insert, saldo_cta_pres, importe_srv, inporte_chq, fecha_insert)
		VALUES ('LIQU_COMISSKY', DFecha_hoy_Sky, '0', 'informix','','','', CURRENT);
		

		-- VALIDAMOS EL SALDO EN LA CUENTA
		 SELECT sdo_actual INTO iSdo_actual_Sky 
		 FROM bdicheq:"informix".sc_maechq 
		 WHERE cuenta = pCuenta_Sky;
		
		--OBTIENE EL TOTAL DE LA COMISION
		 SELECT  NVL(SUM(monto_tot),0) INTO vTotal_Cargo_Coms_Sky
		 FROM    bdicheq:"informix".sc_movdia
		 WHERE   transacc = '1411' 
		 AND     transacc_suc = '8601'
		 AND     fech_alt = today   
		 AND     cancelad <> 'S';
		
		 --OBTIENE EL TOTAL DEL IVA
		 SELECT  NVL(SUM(monto_tot),0) INTO vTotal_Cargo_Iva_Sky
		 FROM    bdicheq:"informix".sc_movdia
		 WHERE   transacc = '1412' 
		 AND     transacc_suc = '8601'
		 AND     fech_alt = today 
		 AND     cancelad <> 'S';
		
		
		 
		IF vTotal_Cargo_Coms_Sky <= 0 THEN
			LET cCodRet_Sky  = '00000';
			LET vMensaje_Sky = 'No hay Movimientos';
			UPDATE bdisac:"informix".sac_procesos_liqhs SET status = '1', saldo_cta_pres = iSdo_actual_Sky, importe_srv = vTotal_Cargo_Coms_Sky, inporte_chq = vTotal_Cargo_Iva_Sky
			WHERE PROCESO = 'LIQU_COMISSKY'
			AND status = '0' 
			AND fecha_proceso = DFecha_hoy_Sky;			   

			--ACTUALIZA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_LH_SC', DFecha_hoy_Sky, '1', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || TRIM(cNombreServicio));			
			RETURN cCodRet_Sky, vFolio_Sky, vMensaje_Sky;			
		END IF; 
		 
			

		LET vTotal_Comision_Sky = (vTotal_Cargo_Coms_Sky + vTotal_Cargo_Iva_Sky);
					
		IF (iSdo_actual_Sky >= vTotal_Comision_Sky) THEN --IF SALDO ACTUAL ES MAYOR O IGUAL A LA COMISION SIGUE EL FLUJO

				LET vFolio_Sky = 'sys_sky'||LPAD(MONTH(CURRENT::DATE),2,0)||LPAD(DAY(CURRENT::DATE),2,0)||SUBSTR(TRIM(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '')),1,2)||'006';
							
			IF vTotal_Comision_Sky > 0 THEN --IF COMISION MAYOR A CERO
							
				CALL bdicheq:"informix".cargo_ref ('001', '9764', 'informix', '1207', '8601', vFolio_Sky, 
					vCuenta_Sky, 0, vTotal_Cargo_Coms_Sky, '01', 'Cargo Comision Pago Sky', '', 'informix') 
				Returning cCodRet_Sky,ctranret_Sky,DFecha_hoy_Sky,msdodisp_Sky,mmontoret_Sky;
				
				IF cCodRet_Sky = '000' THEN -- IF CARGO REF COMISION
					LET cCodRet_Sky  = '00000';
					LET vMensaje_Sky = 'Exitoso';
				ELSE
					CALL bdicheq: "informix".reversion ('001', '9764', ',informix', vFolio_Sky, 'M') Returning cCodRet_Sky;	
					LET cCodRet_Sky = '00008'; --Error en el abono de la comision
				END IF;				
					CALL bdicheq:"informix".cargo_ref ('001', '9764', 'informix', '1237', '8601', vFolio_Sky, 
					vCuenta_Sky, 0, vTotal_Cargo_Iva_Sky, '01', 'Cargo IVA comision Pago Sky', '', 'informix') 
				Returning cCodRet_Sky,ctranret_Sky,DFecha_hoy_Sky,msdodisp_Sky,mmontoret_Sky;
				
				IF cCodRet_Sky = '000' THEN --IF CARGO REF IVA
					LET cCodRet_Sky  = '00000';
					LET vMensaje_Sky = 'Exitoso';
					
				ELSE
					CALL bdicheq: "informix".reversion ('001', '9764', ',informix', vFolio_Sky, 'M') Returning cCodRet_Sky;	
					LET cCodRet_Sky = '00008'; --ERROR AL ABONAR LA COMISION
									
				END IF;			END IF;	--CIERRE IF COMISION MAYOR A CERO
			
		ELSE --IF SALDO ACTUAL ES DIFERENTE A MAYOR O IGUAL DE LA COMISION SIGUE EL FLUJO
		
				LET vFolio_Sky = '';
				LET cCodRet_Sky = '00999';
				LET vMensaje_Sky = 'Saldo no disponible en cuenta SKY';
				RETURN cCodRet_Sky, vFolio_Sky, vMensaje_Sky;

		END IF; --CIERRE --IF SALDO ACTUAL ES MAYOR O IGUAL A LA COMISION SIGUE EL FLUJO
					
		IF cCodRet_Sky = '00000' THEN --IF UPDATE TABLA sac_procesos_liqhs
			UPDATE bdisac:"informix".sac_procesos_liqhs
			SET status = '1', saldo_cta_pres = iSdo_actual_Sky, importe_srv = vTotal_Cargo_Coms_Sky, inporte_chq = vTotal_Cargo_Iva_Sky
			WHERE proceso = 'LIQU_COMISSKY' AND status = '0';
		ELSE
			UPDATE bdisac:"informix".sac_procesos_liqhs
			SET status = '0', saldo_cta_pres = iSdo_actual_Sky, importe_srv = 0, inporte_chq = 0
			WHERE proceso = 'LIQU_COMISSKY' AND status = '0';
		END IF; --CIERRE IF UPDATE TABLA sac_procesos_liqhs
						
	END IF;	--IF SI LA LIQUIDACION YA FUE EJECUTADA

END;	
END PROCEDURE
DOCUMENT
'DESARROLLADOR: VICTOR MANUEL HERNANDEZ LOPEZ',
'FECHA: 28 MAYO 2024',
'FUNCION DEL SPL: REALIZAR LA COMISION DE LA LIQUIDACION PARA EL CONVENIO SKY Y EJECUTARLO EN EL SPL sp_liquidacion_homoserv';

CREATE PROCEDURE "informix".sp_liquidacion_homoserv(pCategoria CHAR(2), pConvenio CHAR(3))
	RETURNING CHAR(5)  AS CodRet, CHAR(16) AS Folio, CHAR(60) AS Mensaje;
		  
		-- // DECLARACION DE VARIABLES.
    DEFINE Sql_Err                          INTEGER;
    DEFINE Isam_Err                         INTEGER;
    DEFINE Desc_Err                         CHAR(50);
    DEFINE cCodRet	                        CHAR(5);  
	DEFINE vCuenta                          CHAR(20);	
    DEFINE vFolio                           CHAR(16);
	DEFINE vFolio_Comisiones		        CHAR(16);
	DEFINE vFolio_IVA_Comisiones	        CHAR(16);
    DEFINE cNombre                          CHAR(10);
	DEFINE iImporte_Pago_srv                INTEGER;
	DEFINE iCuenta_Pago_srv                 INTEGER;
	DEFINE iImporte_Pago_chq                INTEGER;
	DEFINE iImporte_Comision_Srv			DECIMAL(10,2);
	DEFINE iImporte_IVA_Comision_Srv		DECIMAL(10,2);
	DEFINE iImporte_Cobro_Comisiones_Srv	DECIMAL(10,2);
	DEFINE iImporte_Pago_chq_2              INTEGER;
	DEFINE cNumcategoria                    CHAR(2);
	DEFINE cNumconvenio                     CHAR(3);
	DEFINE cCuenta_prestadora               CHAR(20);
	DEFINE vMensaje                         CHAR(60);
	DEFINE pCuenta                          CHAR(20);
	DEFINE vTranret                         CHAR(4);
	DEFINE vFechoy                          DATE;
	DEFINE vSdodisp                         money(14,2);
	DEFINE vMontoret                        money(14,2);
	DEFINE cCtranssuc		                CHAR(4);
	DEFINE cTransCoppel                     CHAR(4);
	DEFINE cEtranssuc		                CHAR(4);
	DEFINE cCtransacc                       CHAR(4);
	DEFINE cCtransacc_Com		            CHAR(4);
	DEFINE cCtransacc_IVA_Com	            CHAR(4);
    DEFINE cAtransacc                       CHAR(4);
	DEFINE cCargo_cliente                   CHAR(4);
	DEFINE cEfectivo_cliente                CHAR(4);
	DEFINE cConsecutivo                     CHAR(2);
	DEFINE iSdo_actual		                INTEGER;
	DEFINE dFecha_hoy	                    DATE;
	DEFINE cDescripcionSPJ	                CHAR(100);
	DEFINE iImporte_Comisiones	            INTEGER;
	DEFINE iIva_Convenio		            INTEGER;
	DEFINE cCod_err2          	            CHAR(5);
	
	-- COMISION Sky
    DEFINE cCodRet_Sky	         	        CHAR(5);  
	DEFINE vCuenta_Sky          	        CHAR(20);	
    DEFINE vFolio_Sky            	        CHAR(16);
	DEFINE pCuenta_Sky		                CHAR(20);
	DEFINE vMensaje_Sky				        CHAR(60);
	DEFINE vTotal_Cargo_Coms_Sky	        MONEY(14,2);
	DEFINE vTotal_Cargo_Iva_Sky		        MONEY(14,2);
	DEFINE vTotal_Comision_Sky		        MONEY(14,2);
	DEFINE iSdo_actual_Sky			        MONEY(14,2);
	DEFINE ctranret_Sky				        CHAR(4);
	DEFINE DFecha_hoy_Sky			        DATE;
	DEFINE msdodisp_Sky				        MONEY (14,2);
	DEFINE mmontoret_Sky			        MONEY (14,2);

	--SET DEBUG FILE TO "/informix/EPG/sp_liquidacion_homoserv.out";
    --TRACE ON;
	
    -- // INICIALIZACION DE VARIABLES.
	LET Sql_Err	                           = 0;
    LET Isam_Err                           = 0;
    LET Desc_Err                           = '';
    LET cCodRet                            = '00001';
	LET cCod_err2                          = '00000';
	LET vCuenta                            = '';  
    LET vFolio                             = '';
	LET vFolio_Comisiones		           = '';
	LET vFolio_IVA_Comisiones	           = '';
	LET cNombre                            = '';
	LET iImporte_Pago_srv                  = '0';
	LET iCuenta_Pago_srv 	               = 0;
	LET iImporte_Pago_chq                  = '0';
	LET iImporte_Comision_Srv			   = 0.00;
	LET iImporte_IVA_Comision_Srv		   = 0.00;
	LET iImporte_Cobro_Comisiones_Srv	   = 0.00;
	LET iImporte_Pago_chq_2                = '0';
	LET cNumcategoria                      = '';
	LET cNumconvenio                       = '';
	LET cCuenta_prestadora                 = '0';
	LET vMensaje                           = '';
	LET pCuenta                            = '';
	LET vTranret                           = " ";
	LET vFechoy                            = " ";
	LET vSdodisp                           = 0;
	LET vMontoret                          = 0;
	LET cCtranssuc                         = '';
	LET cTransCoppel                       = '';
	LET cEtranssuc                         = '';
	LET cCtransacc                         = '';
	LET cCtransacc_Com		               = '';
	LET cCtransacc_IVA_Com	               = '';
    LET cAtransacc                         = '';
	LET cCargo_cliente                     = '';
	LET cEfectivo_cliente                  = '';
    LET cConsecutivo                       = '';	
	LET iSdo_actual                        = 0;
	LET dFecha_hoy	                       = CURRENT;
	LET cDescripcionSPJ	                   = 'Ejecuta liquidacion del servicio homologado:';
	LET iImporte_Comisiones	               = 0;
	LET iIva_Convenio	                   = 0;
	
	-- COMISION Sky
	LET cCodRet_Sky					       ='00000';
	LET vCuenta_Sky       			       = '';  
    LET vFolio_Sky        			       = '';
	LET pCuenta_Sky       			       = '';
	LET vMensaje_Sky				       = '';
	LET iSdo_actual_Sky				       =0;
	LET vTotal_Cargo_Coms_Sky		       =0;
	LET vTotal_Cargo_Iva_Sky		       =0;
	LET vTotal_Comision_Sky			       =0;
	LET ctranret_Sky				       ='';
	LET DFecha_hoy_Sky				       =CURRENT;
	LET msdodisp_Sky				       ='';
	LET mmontoret_Sky				       ='';

	
	
    BEGIN

	ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        IF Sql_Err <> 0 THEN
            LET cCodRet = Sql_Err;
            EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (Sql_Err, Isam_Err, Desc_Err, "sp_liquidacion_homoserv");
         RETURN cCodRet, vFolio, vMensaje;
        END IF;
    END EXCEPTION;
    
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	

	SELECT fecha_hoy  INTO dFecha_hoy FROM sac_fechas WHERE empresa = '001';

	SELECT numcategoria, numconvenio, nomcomercialempresa, cuenta_prestadora, trans_suc_cargo, trans_suc_efectivo, 
		   trans_cen_cargo_cliente, trans_cen_efectivo_cliente, trans_cliq_cpl, trans_aliq_cpl, 
		   CASE WHEN pCategoria||pConvenio= '02003' THEN '01'--AXTEL
				WHEN pCategoria||pConvenio= '04001' THEN '02'--CFE
				WHEN pCategoria||pConvenio= '06004' THEN '03'--CABLEMAS
				WHEN pCategoria||pConvenio= '09011' THEN '04'--JAPAC
				WHEN pCategoria||pConvenio= '09002' THEN '05' END,--ARABELA
		   NVL(imp_com_trans_conv,0), NVL(iva_convenio,0), trans_cen_efectivo_cliente_cpl
	  INTO cNumcategoria, cNumconvenio, cNombre, cCuenta_prestadora, cCtranssuc, cEtranssuc, 
		   cCargo_cliente, cEfectivo_cliente, cCtransacc, cAtransacc, cConsecutivo, iImporte_Comisiones, iIva_Convenio, cTransCoppel
	  FROM bdisac:"informix".sac_convenios 
	 WHERE numcategoria = pCategoria
	   AND numconvenio  = pConvenio;
	   
	IF pCategoria = '04' AND pConvenio = '001' THEN
		LET cNombre = 'CFE';
	END IF;
	
	--INSERTA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_LH_SC', dFecha_Hoy, '0', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || NVL(TRIM(cNombre),''));
	
	IF cConsecutivo = "05" THEN   --Caso Liquidacion de Comisiones
		--VERIFICO QUE NO SE HAYA EJECUTADO LA LIQUIDACION DE COMISIONES
		IF EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_liqbcpl WHERE proceso = 'LIQU_'||cNombre AND status = '1' AND fecha_proceso = dFecha_hoy) THEN
			LET cCodRet= "00001";
			LET vMensaje = "Liquidacion ya ha sido ejecutado";
			RETURN cCodRet, vFolio, vMensaje;
		ELIF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_liqbcpl WHERE proceso = 'LIQU_'||cNombre AND status = '0' AND fecha_proceso = dFecha_hoy) THEN
			INSERT INTO bdisac:"informix".sac_procesos_liqbcpl(proceso, fecha_proceso, status, user_insert, saldo_cta_pres, importe_srv, importe_chq, importe_comision, iva_comision, fecha_insert)
			VALUES ('LIQU_'||cNombre, dFecha_hoy, '0', 'informix','','','','','', CURRENT);
		END IF;
	ELSE
		--VERIFICO QUE NO SE HAYA EJECUTADO LA LIQUIDACION
		IF EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_liqhs WHERE proceso = 'LIQU_'||cNombre AND status = '1' AND fecha_proceso = dFecha_hoy) THEN
			LET cCodRet= "00001";
			LET vMensaje = "Liquidacion ya ha sido ejecutado";
			RETURN cCodRet, vFolio, vMensaje;
		ELIF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_liqhs WHERE proceso = 'LIQU_'||cNombre AND status = '0' AND fecha_proceso = dFecha_hoy ) THEN
			INSERT INTO bdisac:"informix".sac_procesos_liqhs(proceso, fecha_proceso, status, user_insert, saldo_cta_pres, importe_srv, inporte_chq, fecha_insert)
			VALUES ('LIQU_'||cNombre, dFecha_hoy, '0', 'informix','','','', CURRENT);
		END IF;
	END IF;
	
	IF cConsecutivo = "05" THEN   --Caso Liquidacion de Comisiones
		--Busco la transaccion para Comisiones de Arabela
		SELECT valor INTO cCtransacc_Com 
		FROM   bdisac:"informix".sac_param 
		WHERE  cod_param = '41';
		
		--Busco la transaccion para IVA de Comisiones de Arabela
		SELECT valor INTO cCtransacc_IVA_Com
		FROM   bdisac:"informix".sac_param 
		WHERE  cod_param = '42';
		
		
	ELSE
	
		SELECT valor INTO pCuenta 
		FROM   bdisac:"informix".sac_param 
		WHERE  cod_param = '40';
		
		SELECT mae.cuenta INTO vCuenta FROM bdicheq:"informix".sc_maechq mae
		 INNER JOIN bdicheq:"informix".sc_maenoc noc ON ( noc.empresa = mae.empresa AND noc.cuenta = mae.cuenta )
		 INNER JOIN bdicheq:"informix".sc_producto pro ON ( pro.empresa = mae.empresa AND pro.producto = mae.producto )
		 INNER JOIN bdinteg:"informix".si_cliente cte ON ( cte.numcte = mae.num_cte )
		  LEFT OUTER JOIN bdicheq:"informix".sc_tarjeta tar ON ( tar.empresa = mae.empresa AND tar.cuenta = mae.cuenta AND tar.tipo_tarjeta = 'T' AND tar.status_tar = 'A' )
		 WHERE mae.empresa = '001'         
		   AND mae.cuenta = pCuenta; 
		
		-- // VERIFICA QUE LA CUENTA EXISTA               
		IF vCuenta is null OR vCuenta = '' OR vCuenta <> pCuenta THEN
			LET vFolio = '';
			LET cCodRet = '00100';
			LET vMensaje = 'No existe cuenta';
			RETURN cCodRet, vFolio, vMensaje;
		END IF;
		
	END IF
   
	IF cConsecutivo = "05" THEN   --Caso ARABELA
	
		--MONTO TOTAL DE LAS OPERACIONES DE SERVICIOS CRUZADO CON CHEQUES
		SELECT NVL(SUM(importe_pago),0), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0)
		INTO   iImporte_Pago_srv, iImporte_Comision_Srv, iImporte_IVA_Comision_Srv
		FROM   bdisac:sac_movimientos
		WHERE  numcategoria     = cNumcategoria
		AND    numconvenio      = cNumconvenio
		AND    status_cancelado <> 'S'
		AND    fecha_pago       = dFecha_hoy
		AND    folio_suc IN
		(	SELECT folio_suc
			FROM   bdicheq:sc_movdia
			WHERE  fech_alt     =  dFecha_hoy
			AND    transacc     IN (cCargo_cliente, cEfectivo_cliente, cTransCoppel)
			AND    transacc_suc IN (cCtranssuc, cEtranssuc)
			AND    cancelad     <> 'S'
		);
		
		LET iImporte_Pago_chq   = iImporte_Pago_srv;
		LET iImporte_Pago_chq_2 = iImporte_Pago_srv;
		   
		   
	ELSE
		
		--MONTO TOTAL DE LAS OPERACIONES DE SERVICIOS
		SELECT NVL(SUM(importe_pago),0), NVL(SUM(importe_comision_convenio),0), NVL(SUM(iva_comision_convenio),0)
		  INTO iImporte_Pago_srv, iImporte_Comision_Srv, iImporte_IVA_Comision_Srv
		  FROM bdisac:"informix".sac_movimientos
		 WHERE numcategoria = cNumcategoria
		   AND numconvenio = cNumconvenio
		   AND fecha_pago = dFecha_hoy
		   AND status_cancelado <> 'S'
		   AND id_sucursal <> '9764'
		   AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1);
		   
		--IMPORTE TOTAL EN CHEQUES
		SELECT NVL(SUM(monto_tot),0), NVL(SUM(monto_tot),0) INTO iImporte_Pago_chq, iImporte_Pago_chq_2
		  FROM bdicheq:"informix".sc_movdia 
		 WHERE transacc IN (cCargo_cliente, cEfectivo_cliente) 
		   AND transacc_suc IN (cCtranssuc, cEtranssuc)
		   AND fech_alt = dFecha_hoy
		   AND cancelad <> 'S';
		   
	END IF;
		
		--SALDO EN LA CTA PRESTADORA
		SELECT sdo_actual INTO iSdo_actual 
		  FROM bdicheq:"informix".sc_maechq 
		 WHERE cuenta = cCuenta_prestadora;
		
		-----OPERACIONES PARA CARGO Y ABONO
		IF cConsecutivo = "05" THEN   --Caso ARABELA
		
			--Hago el calculo de las comisiones Para Servicios y Cheques
			LET iImporte_Cobro_Comisiones_Srv 	= iImporte_Comision_Srv + iImporte_IVA_Comision_Srv; --Calculo el total del cobro de comisiones de Servicios
			
			--SI EL SALDO EN LA CTA PRESTADORA ES MENOR A LA COMISION DETECTADA EN CHEQUES NO APLICA CARGO
			IF iSdo_actual < iImporte_Cobro_Comisiones_Srv THEN
			
				LET cCodRet  = '00000';
				LET vMensaje = 'No hay Saldo en la Cuenta';
				
				UPDATE bdisac:"informix".sac_procesos_liqbcpl
				   SET status           = '1',
				       saldo_cta_pres   = iSdo_actual,
					   importe_srv      = iImporte_Pago_srv,
					   importe_chq      = iImporte_Pago_chq,
					   importe_comision = iImporte_Comision_Srv,
					   iva_comision     = iImporte_IVA_Comision_Srv
				 WHERE proceso          = 'LIQU_'||cNombre
				   AND status           = '0'
				   AND fecha_proceso    = dFecha_hoy;
				
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod('1', 'BPI_PGOARA', 'PGOARA_NA', 'GRUPO_ARABELA', '', '', '2', 
				iImporte_Comision_Srv, iImporte_IVA_Comision_Srv, '','','','','','','','','','',1,0,0,0,0,CURRENT,'')
				INTO cCod_err2;

				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_LH_SC', dFecha_Hoy, '1', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || NVL(TRIM(cNombre),''));
				RETURN cCodRet, vFolio, vMensaje;
		
			END IF;
		
			--GENERACION DEL 1ER FOLIO_SUC
			LET vFolio_Comisiones = 'sys_bcpl'||LPAD(MONTH(CURRENT::DATE),2,0)||LPAD(DAY(CURRENT::DATE),2,0)||SUBSTR(TRIM(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '')),1,2)||cConsecutivo;
			
			--SE EJECUTA EL CARGO DE COMISIONES
			EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001','9764','informix',cCtransacc_Com,cCtranssuc,vFolio_Comisiones,cCuenta_prestadora,0,iImporte_Comision_Srv,'01','Cargo Comisiones','','')
			   INTO cCodRet, vTranret, vFechoy, vSdodisp, vMontoret;
				IF cCodRet = '000' THEN
					LET cCodRet  = '00000';
					LET vMensaje = 'Exitoso';
				ELSE
					LET vMensaje = 'Error controlado cargo_ref Comisiones';
					EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (cCodRet, '', vMensaje, 'sp_liquidacion_homoserv');
				END IF;
				
			--En caso de que la aplicacion del Cargo de comisiones haya sido correcta, se realizara el Cargo IVA de Comisiones
			IF cCodRet = '00000' THEN
			
				--GENERACION DEL 2DO FOLIO_SUC
				LET vFolio_IVA_Comisiones = 'sys_bcpl'||LPAD(MONTH(CURRENT::DATE),2,0)||LPAD(DAY(CURRENT::DATE),2,0)||SUBSTR(TRIM(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '')),1,2)||cConsecutivo;
				
				--SE EJECUTA EL CARGO DE IVA DE COMISIONES
				EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001','9764','informix',cCtransacc_IVA_Com,cCtranssuc,vFolio_IVA_Comisiones,cCuenta_prestadora,0,iImporte_IVA_Comision_Srv,'01','Cargo Pago IVA de Comisiones','','')
				   INTO cCodRet, vTranret, vFechoy, vSdodisp, vMontoret;
					IF cCodRet = '000' THEN
						LET cCodRet  = '00000';
						LET vMensaje = 'Exitoso';
					ELSE
						LET vMensaje = 'Error controlado cargo_ref';
						EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (cCodRet, '', vMensaje, 'sp_liquidacion_homoserv');
					END IF;
					
				IF cCodRet = '00000' THEN
					UPDATE bdisac:"informix".sac_procesos_liqbcpl
					   SET status           = '1',
					       saldo_cta_pres   = iSdo_actual,
						   importe_srv      = iImporte_Pago_srv,
						   importe_chq      = iImporte_Pago_chq,
						   importe_comision = iImporte_Comision_Srv,
						   iva_comision     = iImporte_IVA_Comision_Srv
					 WHERE proceso          = 'LIQU_'||cNombre
					   AND status           = '0'
					   AND fecha_proceso    = dFecha_hoy;
					--ACTUALIZA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_LH_SC', dFecha_Hoy, '1', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || NVL(TRIM(cNombre),''));			
				ELSE
					UPDATE bdisac:"informix".sac_procesos_liqbcpl
					   SET status           = '0',
					       saldo_cta_pres   = iSdo_actual,
						   importe_srv      = iImporte_Pago_srv,
						   importe_chq      = iImporte_Pago_chq,
						   importe_comision = iImporte_Comision_Srv,
						   iva_comision     = iImporte_IVA_Comision_Srv
					 WHERE proceso          = 'LIQU_'||cNombre
					   AND status           = '0'
					   AND fecha_proceso    = dFecha_hoy;			   
					LET vMensaje = vFolio_IVA_Comisiones || " " || vMensaje;
					RETURN cCodRet, vFolio_Comisiones, vMensaje;
				END IF;
				
			END IF; 
			
			IF iImporte_Pago_srv = iImporte_Pago_chq THEN
				RETURN cCodRet, vFolio_Comisiones, vMensaje;
			ELIF iImporte_Pago_srv < iImporte_Pago_chq THEN
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_PGOCHE','GRUPO_HOMO_SERV', '','', '2',
				cNombre,iImporte_Pago_srv,iImporte_Pago_chq,'','','','','','','','','',1,0,0,0,0,'','') 
				INTO cCod_err2;
				
				LET cCodRet  = '00104';
				LET vMensaje = 'Dif Servicios vs Cheques';
				RETURN cCodRet, vFolio, vMensaje;
			ELIF iImporte_Pago_srv > iImporte_Pago_chq	THEN
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_PGOSER','GRUPO_HOMO_SERV', '','', '2',
				cNombre,iImporte_Pago_srv,iImporte_Pago_chq,'','','','','','','','','',1,0,0,0,0,'','')
				INTO cCod_err2;
				
				LET cCodRet  = '00104';
				LET vMensaje = 'Dif Servicios vs Cheques';
				RETURN cCodRet, vFolio, vMensaje;	
			END IF; ---FIN ARABELA
			

		ELSE
		
			IF pCategoria = '04' AND pConvenio = '001' THEN
				CALL bdisac:"informix".sp_liqui_comision_sky('06', '001') --SE EJECUTA PROCEDIMIENTO PARA COMISION SKY
				RETURNING cCodRet_Sky, vFolio_Sky, vMensaje_Sky; 
	        END IF;
		

		
		
			--SI EL SALDO EL LA CTA PRESTADORA ES MENOR A LO QUE HAY EN CHEQUES, SE LIQUIDA LO QUE HAY EN LA CTA PRESTADORA
			IF iSdo_actual < iImporte_Pago_chq THEN 
				LET iImporte_Pago_chq = iSdo_actual;
			END IF;	
			
			--SI EL IMPORTE EN CHEQUES ES CERO NO APLICA CARGO NI ABONO
			IF iImporte_Pago_chq <= 0 THEN
				LET cCodRet  = '00000';
				LET vMensaje = 'No hay Movimientos';
				UPDATE bdisac:"informix".sac_procesos_liqhs SET status = '1', saldo_cta_pres = iSdo_actual, importe_srv = iImporte_Pago_srv, inporte_chq = iImporte_Pago_chq_2
				 WHERE PROCESO = 'LIQU_'||cNombre
				   AND status = '0' 
				   AND fecha_proceso = dFecha_hoy;			   

				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_LH_SC', dFecha_Hoy, '1', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || NVL(TRIM(cNombre),''));			
				RETURN cCodRet, vFolio, vMensaje;			
			END IF;

			--GENRECION DE FOLIO_SUC
			LET vFolio = 'sys_bcpl'||LPAD(MONTH(CURRENT::DATE),2,0)||LPAD(DAY(CURRENT::DATE),2,0)||SUBSTR(TRIM(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', '')),1,2)||cConsecutivo;
			
			--SE EJECUTA EL CARGO TOTAL DEL SERVICIO
			EXECUTE PROCEDURE bdicheq:"informix".cargo_ref('001','9764','informix',cCtransacc,cCtranssuc,vFolio,cCuenta_prestadora,0,iImporte_Pago_chq,'01','Cargo Pago Liquidacion HomoServicios','','') 
			   INTO cCodRet, vTranret, vFechoy, vSdodisp, vMontoret;
				IF cCodRet = '000' THEN
					--SE EJECUTA EL ABONO TOTAL DEL SERVICIO A LA CUENTA CONCENTRADORA
					EXECUTE PROCEDURE bdicheq:"informix".abono_ref('001','9764','informix',cAtransacc,cCtranssuc,vFolio,pCuenta,1,iImporte_Pago_chq,iImporte_Pago_chq,0,0,0,'01','Abono Pago Liquidacion HomoServicios ','0','') 
						INTO cCodRet;
					IF cCodRet = '000' THEN
						LET cCodRet  = '00000';
						LET vMensaje = 'Exitoso';
					ELSE
						--SI OCURRE UN ERROR EN EL ABONO SE REVERSA LA OPERACION
						EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (cCodRet, '', vMensaje, 'sp_liquidacion_homoserv');	
						EXECUTE PROCEDURE bdicheq:"informix".reversion('001', '9764', 'informix', vFolio, '') into cCodRet;
						LET vMensaje = 'Error abono_ref';
						LET cCodRet  = '00200';
						RETURN cCodRet, vFolio, vMensaje;
					END IF;
				ELSE 
					LET vMensaje = 'Error controlado cargo_ref';	
					EXECUTE PROCEDURE sp_sac_GuardaMensajeerror (cCodRet, '', vMensaje, 'sp_liquidacion_homoserv');					
				END IF;	
			
			IF cCodRet = '00000' THEN	
				UPDATE bdisac:"informix".sac_procesos_liqhs SET status = '1', saldo_cta_pres = iSdo_actual, importe_srv = iImporte_Pago_srv, inporte_chq = iImporte_Pago_chq_2
				 WHERE PROCESO = 'LIQU_'||cNombre
				   AND status = '0' 
				   AND fecha_proceso = dFecha_hoy;
				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_LH_SC', dFecha_Hoy, '1', 'informix', 'sp_liquidacion_homoserv', TRIM(cDescripcionSPJ) || ' ' || NVL(TRIM(cNombre),''));			

	
			ELSE
				UPDATE bdisac:"informix".sac_procesos_liqhs SET status = '0', saldo_cta_pres = iSdo_actual, importe_srv = iImporte_Pago_srv, inporte_chq = iImporte_Pago_chq_2
				 WHERE PROCESO = 'LIQU_'||cNombre
				   AND status = '0' 
				   AND fecha_proceso = dFecha_hoy;			   
				RETURN cCodRet, vFolio, vMensaje;
			END IF;	
			
			
			IF iImporte_Pago_srv = iImporte_Pago_chq THEN
				RETURN cCodRet, vFolio, vMensaje;
			ELIF iSdo_actual < iImporte_Pago_chq_2 THEN
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_CTAPRE','GRUPO_HOMO_SERV', '','', '2',
				cNombre,iSdo_actual,iImporte_Pago_chq_2,'','','','','','','','','',1,0,0,0,0,'','') 
				INTO cCod_err2;
				
				LET cCodRet  = '00101';
				LET vMensaje = 'Dif sdo_cta';
				RETURN cCodRet, vFolio, vMensaje;
			ELIF iImporte_Pago_srv < iImporte_Pago_chq THEN
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_PGOCHE','GRUPO_HOMO_SERV', '','', '2',
				cNombre,iImporte_Pago_srv,iImporte_Pago_chq,'','','','','','','','','',1,0,0,0,0,'','') 
				INTO cCod_err2;
				
				LET cCodRet  = '00102';
				LET vMensaje = 'Dif Serv';
				RETURN cCodRet, vFolio, vMensaje;
			ELIF iImporte_Pago_srv > iImporte_Pago_chq	THEN
				--Envio de correo de notificacion Latinia
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1','HOMO_SERV','HOMO_PGOSER','GRUPO_HOMO_SERV', '','', '2',
				cNombre,iImporte_Pago_srv,iImporte_Pago_chq,'','','','','','','','','',1,0,0,0,0,'','')
				INTO cCod_err2;
				
				LET cCodRet  = '00103';
				LET vMensaje = 'Dif Chqs';			
				RETURN cCodRet, vFolio, vMensaje;
			END IF;
		END IF;

END	
END PROCEDURE
DOCUMENT
'Desarrollador: Eduardo Pineda Guzman',
'Modifica: Victor Manuel Hernandez Lopez',
'Fecha: 30 MAYO 2024',
'Funcion del SPL: Se separa del flujo el proceso de sky, para que se ejecute sin depender de la transaccionalidad de cfe u otro servicio';

CREATE PROCEDURE  "informix".sp_metricas_envio_dinero_mes (pfecharepor DATE)

RETURNING CHAR(5) AS iCodRet, char(50) as iMensaje;
	--GENERAR REPOTE DE METRICAS DE ENVIOS DE DINERO REMESAS Y ENROLAMIENTO--
	
	DEFINE iCodRet 			CHAR(5);
	DEFINE iMensaje			CHAR(50);
	DEFINE cRutaArch 		CHAR(100);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cDia 			CHAR(2);
	DEFINE cMes 			CHAR(2);
	DEFINE cAnio 			CHAR(4);
	DEFINE dFecha_Hoy 		DATE;
	DEFINE cStmt 			CHAR (500);
	DEFINE vValida			INTEGER;
	
	

	DEFINE vfecha_proceso			DATE;
	DEFINE vfecha_procesoI			DATE;
	DEFINE vfecha_procesoF			DATE;
	DEFINE vtipo_remesa				CHAR(3); 
	DEFINE vabono_cuenta			CHAR(2);
	DEFINE vmonto_total				MONEY;
	DEFINE vmonto_dolares			MONEY;
	DEFINE vbeneficiario_nombre1	CHAR(30);
	DEFINE vbeneficiario_nombre2	CHAR(30); 
	DEFINE vbeneficiario_appaterno	CHAR(30);
	DEFINE vbeneficiario_apmaterno	CHAR(30);
	DEFINE vbeneficiario_fecha_nac	DATE;
	DEFINE vbeneficiario_estado		CHAR(50);
	DEFINE vbeneficiario_mncpo_del	CHAR(50);
	DEFINE vbeneficiario_ciudad		CHAR(50);
	DEFINE vbeneficiario_direccion	CHAR(100);
	DEFINE vbeneficiario_colonia	CHAR(80);
	DEFINE vbeneficiario_calle 		CHAR(50);
	DEFINE vsucursal				CHAR(4);
	DEFINE vnum_confirmacion		CHAR(20);
	DEFINE vfolio_sucursal			CHAR(16);
	DEFINE vnumCliente				CHAR(20);
	DEFINE vNombreBenef				CHAR(300);
	
	
	DEFINE vnombre_estado			CHAR(30);
	--DEFINE vsucursal				CHAR(4); 
	DEFINE vtotal_enrolados			INTEGER;
	DEFINE vtotal_penrolados		INTEGER;
	DEFINE vtotal_t1				INTEGER;
	DEFINE vtotal_t2				INTEGER;
	DEFINE vtotal_pt1				INTEGER;
	DEFINE vtotal_pt2				INTEGER;
	DEFINE vtusuarios_enrolados 	INTEGER;
	DEFINE vtusuarios_no_enrolados 	INTEGER;
	DEFINE vPromedio			 	DECIMAL;
	
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_metricas_envio_dinero.out';
	--TRACE ON; 
	--SET DEBUG FILE TO '/INFORMIXTMP/HMLG/sp_metricas_envio_dinero.out';
	--TRACE ON;
	
	LET vfecha_proceso			= MDY('01','01','1900');
	LET vfecha_procesoF			= MDY('01','01','1900');
	LET vfecha_procesoI			= MDY('01','01','1900');	
	LET iCodRet = "00000";
	LET cRutaArch = '';
	LET iSqlErr = 0;
	LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
	LET dFecha_Hoy = MDY('01','01','1900');
	LET cStmt = '';
	LET iMensaje = '';
	LET vValida = 0;
	

	LET vtipo_remesa			= '';	
	LET vabono_cuenta			= '';
	LET vmonto_total			= 0;	
	LET vmonto_dolares			= 0;
	LET vbeneficiario_nombre1	= '';
	LET vbeneficiario_nombre2	= '';
	LET vbeneficiario_appaterno	= '';
	LET vbeneficiario_apmaterno	= '';
	LET vbeneficiario_fecha_nac	= MDY('01','01','1900');
	LET vbeneficiario_estado	= '';	
	LET vbeneficiario_mncpo_del	= '';
	LET vbeneficiario_ciudad	= '';	
	LET vbeneficiario_direccion	= '';
	LET vbeneficiario_colonia	= '';
	LET vbeneficiario_calle 	= '';	
	LET vsucursal				= '';
	LET vnum_confirmacion		= '';
	LET vfolio_sucursal			= '';
	LET vnumCliente				= '';
	LET vNombreBenef			= '';	
	
		
	LET vnombre_estado 			= '';						
	LET vtotal_enrolados		= 0;			
	LET vtotal_penrolados		= 0;		
	LET vtotal_t1				= 0;			
	LET vtotal_t2				= 0;			
	LET vtotal_pt1				= 0;			
	LET vtotal_pt2				= 0;			
	LET vtusuarios_enrolados 	= 0;	
	LET vtusuarios_no_enrolados	= 0; 	
	LET vPromedio				= 0.00;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			LET iMensaje = "Proceso NO Exitoso Error BD.";
			
			
			IF cRutaArch IS NOT NULL OR cRutaArch <> "" THEN 
				LET cStmt = 'rm -f ' || cRutaArch;
				SYSTEM cStmt;
			END IF;
			
			drop table if exists tempsuc_pivMovHis1;
			
			DROP TABLE IF EXISTS tempsuc_edo;
			DROP TABLE IF EXISTS tempsuc_periodo;
			DROP TABLE IF EXISTS temptipoctee;
			DROP TABLE IF EXISTS temptipocte1;
			DROP TABLE IF EXISTS temptipocte2;
			DROP TABLE IF EXISTS temptipocte11;
			DROP TABLE IF EXISTS temptipocte22;
			DROP TABLE IF EXISTS tempsuc1;
			DROP TABLE IF EXISTS temp_wu_enrol;
			DROP TABLE IF EXISTS temp_wu_noenrol;
			DROP TABLE IF EXISTS temp_app_enrol;
			DROP TABLE IF EXISTS temp_app_noenrol;
			DROP TABLE IF EXISTS temp_bts_enrol;
			DROP TABLE IF EXISTS temp_bts_noenrol;
			DROP TABLE IF EXISTS tempsuc_piv;
			DROP TABLE IF EXISTS tempsuc_pivMovHis;
			DROP TABLE IF EXISTS tempsuc_edo_t1t2;
			DROP TABLE IF EXISTS temp_totalrempag;
			DROP TABLE IF EXISTS temp_reporteenrolamiento58;
			DROP TABLE IF EXISTS tempsuc_periodot;
			
			
			RETURN iCodRet,iMensaje;
			
		END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
			drop table if exists tempsuc_pivMovHis1;
			DROP TABLE IF EXISTS tempsuc_edo;
			DROP TABLE IF EXISTS tempsuc_periodo;
			DROP TABLE IF EXISTS temptipoctee;
			DROP TABLE IF EXISTS temptipocte1;
			DROP TABLE IF EXISTS temptipocte2;
			DROP TABLE IF EXISTS temptipocte11;
			DROP TABLE IF EXISTS temptipocte22;
			DROP TABLE IF EXISTS tempsuc1;
			DROP TABLE IF EXISTS temp_wu_enrol;
			DROP TABLE IF EXISTS temp_wu_noenrol;
			DROP TABLE IF EXISTS temp_app_enrol;
			DROP TABLE IF EXISTS temp_app_noenrol;
			DROP TABLE IF EXISTS temp_bts_enrol;
			DROP TABLE IF EXISTS temp_bts_noenrol;
			DROP TABLE IF EXISTS tempsuc_piv;
			DROP TABLE IF EXISTS tempsuc_pivMovHis;
			DROP TABLE IF EXISTS tempsuc_edo_t1t2;
			DROP TABLE IF EXISTS temp_totalrempag;
			DROP TABLE IF EXISTS temp_reporteenrolamiento58;
			DROP TABLE IF EXISTS tempsuc_periodot;
		
		
		IF pfecharepor IS NULL OR  pfecharepor = "" THEN
		
			SELECT fecha_hoy 
			INTO dFecha_Hoy 
			FROM bdisac:sac_fechas
			WHERE empresa = "001";
		
			LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
			LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');
		
			LET vfecha_proceso			= dFecha_Hoy;
			LET dFecha_Hoy 				= vfecha_proceso -36;
			
			SELECT  id_sucursal,numcategoria,numconvenio,referencia1,folio_suc,status_cancelado,fecha_insert
				FROM sac_movimientoshistorial 
				WHERE fecha_insert >= EXTEND(dFecha_Hoy, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
				AND fecha_insert <= EXTEND(vfecha_proceso, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				AND numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764')  
				AND status_cancelado = 'N'
			INTO TEMP tempsuc_pivMovHis1  WITH NO LOG;
			
			
			SELECT FIRST 1 MIN(fecha_insert),MAX(fecha_insert)
				INTO vfecha_procesoI,vfecha_procesoF
				FROM tempsuc_pivMovHis1
				WHERE MONTH(fecha_insert) = MONTH(dFecha_Hoy +15);
				
		ELSE 
		
			LET vfecha_proceso			= pfecharepor;
			LET dFecha_Hoy 				= vfecha_proceso -36;
			
			LET cDia = LPAD(DAY(vfecha_proceso::DATE), 2, '0');
			LET cMEs = LPAD(MONTH(vfecha_proceso::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(vfecha_proceso::DATE), 4, '0');
			
			
			SELECT  id_sucursal,numcategoria,numconvenio,referencia1,folio_suc,status_cancelado,fecha_insert
				FROM sac_movimientoshistorial 
				WHERE fecha_insert >= EXTEND(dFecha_Hoy, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
				AND fecha_insert <= EXTEND(vfecha_proceso, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				AND numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764')  
				AND status_cancelado = 'N'
			INTO TEMP tempsuc_pivMovHis1  WITH NO LOG;
			
			SELECT FIRST 1 MIN(fecha_insert),MAX(fecha_insert)
				INTO vfecha_procesoI,vfecha_procesoF
				FROM tempsuc_pivMovHis1
				WHERE MONTH(fecha_insert) = MONTH(dFecha_Hoy +15);

		END IF;
				
		
		IF vfecha_procesoI IS NOT NULL OR vfecha_procesoF IS NOT NULL THEN 
				
			--"METRICAS DE ENVIOS DE DINERO REPORTE 2 MENSUAL"
			
			
			--01 Genera tabla Pivote con sucursales que pagaron remesas
				
			SELECT  id_sucursal,numcategoria,numconvenio,referencia1,folio_suc,status_cancelado,fecha_insert
				FROM tempsuc_pivMovHis1 
				WHERE fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                AND fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND
				AND numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764')  
				AND status_cancelado = 'N'
			INTO TEMP tempsuc_pivMovHis  WITH NO LOG;
			
			drop table if exists tempsuc_pivMovHis1;
			
			SELECT  id_sucursal as sucursal
				FROM tempsuc_pivMovHis 
				WHERE numcategoria = '07'
				AND numconvenio IN ('004','006','007','008','009')
				AND id_sucursal NOT IN ('9250','9251','9764') 
				AND status_cancelado = 'N'
				GROUP BY id_sucursal
			INTO TEMP tempsuc_piv  WITH NO LOG;
			
			--02 Totales de ususarios enrolados por sucursal de tabla pivote 
			SELECT b.cve_estado,d.nombre AS nombre_estado,a.sucursal
				FROM tempsuc_piv a
				LEFT JOIN bdinteg:si_ptf b on a.sucursal = b.id_ptf and b.tipo in ('S','O')
				LEFT JOIN bdinteg:si_estados d ON b.cve_pais = d.pais
				AND b.cve_estado = d.estado
				GROUP BY a.sucursal, b.cve_estado,d.nombre
			INTO TEMP tempsuc_edo  WITH NO LOG;
			
			--03 Total de enrolados y por periodo del reporte
			SELECT sucursal,NVL(count(*),0) as total_enrolados 
				FROM sac_cte_remesas  /*fechas para totales*/
				WHERE fecha_insert 
				BETWEEN vfecha_procesoI 
				AND vfecha_procesoF
				AND sucursal <> ''
				GROUP BY sucursal
			INTO TEMP tempsuc_periodot  WITH NO LOG; 
			
			SELECT sucursal,NVL(count(*),0) as totale_periodo 
				FROM sac_cte_remesas
				WHERE fecha_insert 
				BETWEEN vfecha_procesoI 
				AND vfecha_procesoF
				AND sucursal <> ''
				GROUP BY sucursal
			INTO TEMP tempsuc_periodo  WITH NO LOG; 
			
			
			--04 Junta tablas temporales tempsuc_edo y tempsuc_periodo
			SELECT a.cve_estado,a.nombre_estado,a.sucursal,NVL(cc.total_enrolados,0) as total_enrolados,NVL(b.totale_periodo,0) AS total_penrolados  
				FROM tempsuc_edo a
				LEFT JOIN tempsuc_periodo b ON a.sucursal = b.sucursal
				LEFT JOIN tempsuc_periodot cc ON a.sucursal = cc.sucursal
			INTO TEMP tempsuc1  WITH NO LOG;
			
			DROP TABLE IF EXISTS tempsuc_edo;
			DROP TABLE IF EXISTS tempsuc_periodo;
			DROP TABLE IF EXISTS tempsuc_periodot;
			
			--05 Busqueda del tipo de cliente de cada enrolado *****
			
			SELECT sucursal, numcte, fecha_insert 
				FROM bdisac:sac_cte_remesas
				WHERE fecha_insert 
				BETWEEN vfecha_procesoI 
				AND vfecha_procesoF
			INTO TEMP temptotcteenr WITH NO LOG;
			
			SELECT a.sucursal,a.numcte,a.fecha_insert,b.tipo_cliente
				FROM temptotcteenr a
				LEFT JOIN bdinteg:si_cliente b ON a.numcte = b.numcte /*fechas para totales*/
				WHERE a.fecha_insert 
				BETWEEN vfecha_procesoI 
				AND vfecha_procesoF
			INTO TEMP temptipoctee  WITH NO LOG;
			
			--06 genera tablas con totales por el tipo de cliente 
			SELECT sucursal,NVL(count(*),0) AS total_ct1
				FROM temptipoctee
				WHERE tipo_cliente = 1
				GROUP BY sucursal 
			INTO TEMP temptipocte1  WITH NO LOG;
				
			SELECT sucursal,NVL(count(*),0) AS total_ct2
				FROM temptipoctee
				WHERE tipo_cliente = 2
				GROUP BY sucursal 
			INTO TEMP temptipocte2  WITH NO LOG;
				
			SELECT sucursal,NVL(count(*),0) AS total_ct1p
				FROM temptipoctee
				WHERE tipo_cliente = 1
				AND fecha_insert >= vfecha_procesoI
				AND fecha_insert <= vfecha_procesoF
				GROUP BY sucursal 
			INTO TEMP temptipocte11  WITH NO LOG;
				
			SELECT sucursal,NVL(count(*),0) AS total_ct2p
				FROM temptipoctee
				WHERE tipo_cliente = 2
				AND fecha_insert >= vfecha_procesoI
				AND fecha_insert <= vfecha_procesoF
				GROUP BY sucursal 
			INTO TEMP temptipocte22  WITH NO LOG;
			
			
			DROP TABLE IF EXISTS temptipoctee;
			
			
			--6 Junta tablas temporales a 1 reporte
			SELECT a.cve_estado,a.nombre_estado,a.sucursal,a.total_enrolados,
				a.total_penrolados,
				NVL(total_ct1,0)AS  total_t1,
				NVL(total_ct2,0)AS total_t2,
				NVL(total_ct1p,0)AS total_pt1,
				NVL(total_ct2p,0)AS total_pt2
				FROM tempsuc1 a
				LEFT JOIN temptipocte1 d ON a.sucursal = d.sucursal
				LEFT JOIN temptipocte2 e ON a.sucursal = e.sucursal
				LEFT JOIN temptipocte11 f ON a.sucursal = f.sucursal
				LEFT JOIN temptipocte22 h ON a.sucursal = h.sucursal
			INTO TEMP tempsuc_edo_t1t2  WITH NO LOG;
			
			DROP TABLE IF EXISTS temptipocte1;
			DROP TABLE IF EXISTS temptipocte2;
			DROP TABLE IF EXISTS temptipocte11;
			DROP TABLE IF EXISTS temptipocte22;
			DROP TABLE IF EXISTS tempsuc1;
			
			--7 BUSQUEDA DE TOTALES POR REMESADORA 
			
				--7.1 BUSQEDA PARA WU
				
					SELECT a.id_sucursal,count(unique(a.referencia1)) as TotalWU_usuenrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_wu_pay w ON a.referencia1 = w.mtcn
						AND a.folio_suc = w.foreign_rs_refnum_rp
						WHERE a.numcategoria = '07'
						AND a.numconvenio IN ('006','007','008')
                        and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND w.numcte <> ''
                        and w.conf_pago = 'P'
                        and w.txn_status = 'A' 
                        and w.retcode = '00000'
						GROUP BY a.id_sucursal
                       INTO TEMP temp_wu_enrol  WITH NO LOG;
					
					SELECT a.id_sucursal,count(unique(a.referencia1)) as TotalWU_usu_no_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_wu_pay w ON a.referencia1 = w.mtcn
						AND a.folio_suc = w.foreign_rs_refnum_rp
						WHERE a.numcategoria = '07'
						AND a.numconvenio IN ('006','007','008')
						and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND w.numcte = ''
                        and w.conf_pago = 'P'
                        and w.txn_status = 'A' 
                        and w.retcode = '00000'
						GROUP BY a.id_sucursal
                       INTO TEMP temp_wu_noenrol  WITH NO LOG;					
			
				--7.2 BUSQUEDA PARA APPRIZA
				
					SELECT trim(ap.nnumber) as sucursal,count(unique(ap.unirefnum)) as TotalAPP_usu_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_app_payi ap ON a.referencia1 = ap.unirefnum
						AND a.folio_suc = ap.refnum
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '009'
                        and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND 
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND ap.numcte <> ''
                        and ap.txn_status = 'A'
                        and ap.r_code_d = 'P000' 
                        and ap.r_code = '0000'
						GROUP BY ap.nnumber
                    INTO TEMP temp_app_enrol   WITH NO LOG;
					
					SELECT trim(ap.nnumber) as sucursal,count(unique(ap.unirefnum)) as TotalAPP_usu_no_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_app_payi ap ON a.referencia1 = ap.unirefnum
						AND a.folio_suc = ap.refnum
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '009'
                        and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND 
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND  
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
						AND ap.numcte = ''
                        and ap.txn_status = 'A'
                        and ap.r_code_d = 'P000' 
                        and ap.r_code = '0000'
						GROUP BY ap.nnumber
                    INTO TEMP temp_app_noenrol   WITH NO LOG;


				--7.3 BUSQUEDA PARA BTS

					SELECT a.id_sucursal as sucursal,count(unique(bt.confirmation_nm)) as TotalBTS_usu_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_bts_payi bt ON a.referencia1 = bt.confirmation_nm
						AND a.folio_suc = bt.bank_ref_nm
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '004'
						and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND 
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
                        AND bt.numcte <> ''
						AND bt.opcode = '1100'
						AND bt.txn_status = 'A'
						GROUP BY a.id_sucursal
                    INTO TEMP temp_bts_enrol   WITH NO LOG;
					
					SELECT a.id_sucursal as sucursal,count(unique(bt.confirmation_nm)) as TotalBTS_usu_no_enrol
						FROM tempsuc_pivMovHis a
						LEFT JOIN sac_bts_payi bt ON a.referencia1 = bt.confirmation_nm
						AND a.folio_suc = bt.bank_ref_nm
						WHERE a.numcategoria = '07'
						AND a.numconvenio = '004'
						and a.fecha_insert >= EXTEND(vfecha_procesoI, YEAR to SECOND)+00 UNITS HOUR+00 UNITS MINUTE+00 UNITS SECOND
                        and a.fecha_insert <= EXTEND(vfecha_procesoF, YEAR to SECOND)+24 UNITS HOUR+60 UNITS MINUTE+60 UNITS SECOND 
						AND a.id_sucursal NOT IN ('9250','9251','9764')
						AND a.status_cancelado = 'N'
                        AND bt.numcte = ''
						AND bt.opcode = '1100'
						AND bt.txn_status = 'A'
						GROUP BY a.id_sucursal
                    INTO TEMP temp_bts_noenrol   WITH NO LOG;


					
				--7.4 Union de resultados
				
					SELECT a.sucursal,
						(NVL(app1.totalapp_usu_enrol,0) + NVL(bts1.totalbts_usu_enrol,0) + NVL(wu1.totalwu_usuenrol,0)) as tusuarios_enrolados,
						(NVL(app2.totalapp_usu_no_enrol,0) + NVL(bts2.totalbts_usu_no_enrol,0) + NVL(wu2.totalwu_usu_no_enrol,0)) as tusuarios_no_enrolados
						FROM tempsuc_piv a
						LEFT JOIN temp_app_enrol app1 ON a.sucursal = app1.sucursal
						LEFT JOIN temp_bts_enrol bts1 ON a.sucursal = bts1.sucursal
						LEFT JOIN temp_wu_enrol wu1 ON a.sucursal = wu1.id_sucursal
						LEFT JOIN temp_app_noenrol app2 ON a.sucursal = app2.sucursal
						LEFT JOIN temp_bts_noenrol bts2 ON a.sucursal = bts2.sucursal
						LEFT JOIN temp_wu_noenrol wu2 ON a.sucursal = wu2.id_sucursal
					INTO TEMP temp_totalrempag  WITH NO LOG;
					
					DROP TABLE IF EXISTS temp_wu_enrol;
					DROP TABLE IF EXISTS temp_wu_noenrol;
					DROP TABLE IF EXISTS temp_app_enrol;
					DROP TABLE IF EXISTS temp_app_noenrol;
					DROP TABLE IF EXISTS temp_bts_enrol;
					DROP TABLE IF EXISTS temp_bts_noenrol;
					
			--8 GENERA REPORTE 

				SELECT a.nombre_estado,a.sucursal,
				a.total_penrolados,
				a.total_pt1,a.total_pt2,
				b.tusuarios_enrolados,b.tusuarios_no_enrolados,0 as promedio
				FROM tempsuc_edo_t1t2 a
				LEFT JOIN temp_totalrempag b ON a.sucursal = b.sucursal
				INTO temp_reporteenrolamiento58;
			
				DROP TABLE IF EXISTS tempsuc_piv;
				DROP TABLE IF EXISTS tempsuc_pivMovHis;
				DROP TABLE IF EXISTS tempsuc_edo_t1t2;
				DROP TABLE IF EXISTS temp_totalrempag;
				
				SELECT COUNT(*) 
				INTO vValida
				FROM temp_reporteenrolamiento58;
				
				
				IF vValida <> 0  THEN
					
				
					LET cRutaArch = '/home/systelmex/metricas_envio_dinero_2_mes_DDMMAAAA.csv';
			
					LET cRutaArch = REPLACE(cRutaArch,'AAAA',cAnio);
					LET cRutaArch = REPLACE(cRutaArch,'MM',cMes);
					LET cRutaArch = REPLACE(cRutaArch,'DD',cDia);

					LET cStmt = 'rm -f ' || cRutaArch;
					SYSTEM cStmt;			
										
					LET cStmt = 'echo "' || "METRICAS DE ENVIOS DE DINERO REPORTE 2 MENSUAL " || vfecha_procesoI ||" - "|| vfecha_procesoF || '" >> ' || cRutaArch;
					SYSTEM cStmt; 
			
					LET cStmt = 'echo "' || "ESTADO" || "," ||"SUCURSAL" || "," || "CLIENTES ENROLADOS PERIODO" || "," || "CLIENTES ENROLADOS T1 PERIODO" || "," || "CLIENTES ENROLADOS T2 PERIODO" || "," || 
						"TOTAL TRANSACCIONES USUARIO ENROLADO PERIODO" || "," || "TOTAL TRANSACCIONES USUARIO NO ENROLADO PERIODO" || "," || "PROMEDIO USUARIO ENROLADO PERIODO" || '" >> ' || cRutaArch;
						SYSTEM cStmt;
				/*
					FOREACH
					
						SELECT  sucursal,total_penrolados,tusuarios_enrolados
						INTO vsucursal,vtotal_enrolados,vtusuarios_enrolados
						FROM temp_reporteenrolamiento58
						
						
						
						IF vtusuarios_enrolados <> 0  THEN
							IF vtotal_enrolados <> 0 THEN
								LET vPromedio = ROUND((ROUND(vtusuarios_enrolados,2)/ROUND(vtotal_enrolados,2)),2);
								UPDATE temp_reporteenrolamiento58 SET promedio = vPromedio WHERE sucursal = vsucursal;
							ELSE
								UPDATE temp_reporteenrolamiento58 SET promedio = 0 WHERE sucursal = vsucursal;
							END IF;
						ELSE
							UPDATE temp_reporteenrolamiento58 SET promedio = 0 WHERE sucursal = vsucursal;
						END IF;
						
						
					END FOREACH;
					*/
					
					LET cStmt = 'rm -f /home/systelmex/metricas_envio_dinerom_2.csv';
					SYSTEM cStmt;
					
					LET cStmt = 'echo "UNLOAD TO /home/systelmex/metricas_envio_dinerom_2.csv DELIMITER '','' SELECT * FROM temp_reporteenrolamiento58 ORDER BY 1,2;">/home/systelmex/reportemetenrm2.sql';
					SYSTEM cStmt;
				
					let cStmt= 'dbaccess bdisac	/home/systelmex/reportemetenrm2.sql';
					system cStmt;
					
					SYSTEM 'tail -n +1 /home/systelmex/metricas_envio_dinerom_2.csv >> ' || cRutaArch;
					
					LET cStmt = 'rm -f /home/systelmex/reportemetenrm2.sql';
					SYSTEM cStmt;
					LET cStmt = 'rm -f /home/systelmex/metricas_envio_dinerom_2.csv';
					SYSTEM cStmt;
					
					DROP TABLE IF EXISTS temp_reporteenrolamiento58;
					LET iCodRet = "00000";				
					LET iMensaje =  "Proceso Exitoso 2 Mensual";
					
					
					INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
						VALUES ('REP_MET_ENV_DIN_ENROL_2m',today,'1','informix',CURRENT,'1','sp_metricas_envio_dinero_mensual','Reporte Metricas de Envio de Dinero y Enrolamiento 2 mensual');
	
				
				ELSE
					LET cStmt = 'rm -f ' || cRutaArch;
					SYSTEM cStmt;
				
					LET iCodRet = "00000";				
					LET iMensaje =  "Proceso Exitoso 2 mensual  Sin Datos";
					INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
						VALUES ('REP_MET_ENV_DIN_ENROL_2m',today,'1','informix',CURRENT,'1','sp_metricas_envio_dinero_mensual','Reporte Metricas de Envio de Dinero y Enrolamiento 2 mensual');
				END IF;
					
		ELSE
			
			LET iCodRet = "00001";				
			LET iMensaje =  "Proceso NO Exitoso";
			INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
			VALUES ('REP_MET_ENV_DIN_ENROL_2m',today,'0','informix',CURRENT,'1','sp_metricas_envio_dinero_mensual','Reporte Metricas de Envio de Dinero y Enrolamiento 2 mensual');
		
		END IF;
		
		
		RETURN iCodRet,iMensaje;
		
	END;

END PROCEDURE;