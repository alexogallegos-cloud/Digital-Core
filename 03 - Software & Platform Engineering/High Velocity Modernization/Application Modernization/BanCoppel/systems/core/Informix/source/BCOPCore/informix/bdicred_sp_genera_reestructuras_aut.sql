CREATE PROCEDURE "informix".sp_genera_reestructuras_aut(pempresa VARCHAR(3))

	RETURNING CHAR(5)     ;  --CodRet


	--*****************************************************
	--DECLARACION DE VARIABLES
	--*****************************************************
	---Variables de control de errores
	DEFINE pempresa         VARCHAR(3);
	DEFINE vCodRet          VARCHAR(6);
	DEFINE CodRet           VARCHAR(8);
	DEFINE p_mensaje        VARCHAR(80);
	DEFINE error_info       VARCHAR(80);
	DEFINE sql_err          INTEGER;
	DEFINE isam_err         INTEGER;
	DEFINE wBegin           CHAR(1);
	DEFINE wBegin2          CHAR(1);
	DEFINE vFechaApertura   DATE;
	DEFINE vFechaVenc       DATE;
	DEFINE cNumCte 			CHAR(20);
	DEFINE cNumCredito 		CHAR(20);
	DEFINE cNumProducto 	CHAR(4);
	DEFINE dEnganche 		DECIMAL(14,2);
	DEFINE dPagomensual 	DECIMAL(14,2);
	DEFINE dFecha			DATE;
	DEFINE dPagoIntencion	DECIMAL(14,2);
	DEFINE cCorreoElectronico	VARCHAR(100);
	DEFINE dVigencia		DATE;
	
	DEFINE vCapital 		DECIMAL(14,2);
	DEFINE vIntVigente 		DECIMAL(14,2);
	DEFINE vIntVencido 		DECIMAL(14,2);
	DEFINE vIvaIntVig 		DECIMAL(14,2); 
	DEFINE vIvaIntVen 		DECIMAL(14,2); 
	DEFINE vMoraOrd 		DECIMAL(14,2);
	DEFINE vIvaMoraOrd 		DECIMAL(14,2);
	DEFINE vMoraCopete 		DECIMAL(14,2);
	DEFINE vIvaMoraCope 	DECIMAL(14,2);
	DEFINE vNumCte 			CHAR(20);
	DEFINE vNumTarjeta 		CHAR(20);
	DEFINE tAdeudo 			DECIMAL(14,2);
	DEFINE tSubtotal 		DECIMAL(14,2);
	DEFINE vMtoRees 		DECIMAL(14,2);
	DEFINE valorfinal 		DECIMAL(14,2);
	DEFINE wmesespro 		DECIMAL(14,2);
	--DEFINE vCapital DECIMAL(14,2);
	DEFINE vInteres 		DECIMAL(14,2);
	DEFINE vIva 			DECIMAL(14,2);
	DEFINE vfecha 			DATE;
	DEFINE v_tasa_interes 	DECIMAL(14,2);
	DEFINE vcat 			DECIMAL(14,2);
	DEFINE vTasaMora 		DECIMAL(14,2);
	DEFINE vProyecInt 		DECIMAL(14,2);
	DEFINE vTasaInteres 	DECIMAL(14,2);
	DEFINE vCatIva 			DECIMAL(14,2);
	DEFINE vMercadeo 		CHAR(1);
	DEFINE pcuenta 			CHAR(20);
	DEFINE usuario         	CHAR(20);
	DEFINE vnum_solicitud 	CHAR(20);
	DEFINE pNumcta 			CHAR(20);
	DEFINE pPlazo 			CHAR(2);
	DEFINE cSucursal 		CHAR(4);
	DEFINE cDescProducto 	CHAR(40);
	DEFINE sPeriodoDeGracia CHAR(2);
	DEFINE vsdodisp   		money(16,2);
    DEFINE vstatuscta 		CHAR(1);
	DEFINE cArchMarcajeATM		CHAR(50);
	DEFINE cArchValidacionATM	CHAR(50);
	DEFINE cRutaArchivo			CHAR(100);
	DEFINE cDia					CHAR(2);
	DEFINE cMes					CHAR(2);
	DEFINE cAnio				CHAR(4);
	--DEFINE cEmpresa				CHAR(3);
	DEFINE cCommand				CHAR(1000);
	DEFINE cArchivoDbld			CHAR(100);
	DEFINE cArchivoLog			CHAR(100);
	DEFINE cArchivoOut			CHAR(100);
	DEFINE cArchivoCarga		CHAR(100);
	DEFINE dFechaHoy			DATE;
	DEFINE mfondo_insuficiente  INTEGER;
	DEFINE mPago_intencion money(16,2);
	DEFINE vProducto			CHAR(4);
	DEFINE vsucursal 			CHAR(4);
	DEFINE vCuentaClabe 		CHAR(18);
	DEFINE cProductoRTPP		CHAR(4);
	DEFINE bValidaArchivo		CHAR(1);

	ON EXCEPTION SET sql_err, isam_err, error_info
	
		IF bValidaArchivo = 'N' THEN
			INSERT INTO  bdicred:"informix".sd_bitacora_mec values 
			('001', '0010', today, sql_err, 'isam_err:'||isam_err||':error_info:'||error_info||' archivo no encontrado ', user, today, current );
			RETURN '00000';
		END IF;
		
		INSERT INTO  bdicred:"informix".sd_bitacora_mec values 
		('001', '0010', today, sql_err, 'isam_err:'||isam_err||':error_info:'||error_info, user, today, current );
		LET vCodRet   = sql_err;
		LET p_mensaje = error_info;
		ROLLBACK WORK;
		
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN vCodRet;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		LET wBegin = "S";
		ROLLBACK WORK;
		COMMIT WORK;
		--BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	ON EXCEPTION IN (-255)
		LET wBegin = "S";
		BEGIN WORK;
	END EXCEPTION WITH RESUME;

	TRUNCATE TABLE temp_validacion_ATM_reestructura;
      LET wBegin = "N";

      --BEGIN WORK;

	--SET DEBUG FILE TO '/informix/Ulises/INC/Reest_auto/sp_genera_reestructuras_aut.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;	
	SET LOCK MODE TO WAIT 3;

	--***********************
	--INICIALIZA VARIABLE
	--***********************
	LET  pempresa 		= '001';
	LET  vCodRet       	= '00000';
	LET  p_mensaje     	= 'PROCESO EXITOSO';
	LET  vTasaInteres   = 0;
	--LET  vTasaMora     	= 0;
	LET cNumCte 		= '';
	LET cNumCredito 	= '';
	LET cNumProducto 	= '';
	LET dEnganche 		= 0;
	LET dPagomensual 	= 0;
	LET dFecha			= DATE(1);
	LET dPagoIntencion	= 0;
	LET cCorreoElectronico	= '';
	LET dVigencia		= DATE(1);
	
	LET vCapital 		= 0;
	LET vIntVigente 	= 0;
	LET vIntVencido 	= 0;
	LET vIvaIntVig 		= 0; 
	LET vIvaIntVen 		= 0; 
	LET vMoraOrd 		= 0;
	LET vIvaMoraOrd 	= 0;
	LET vMoraCopete 	= 0;
	LET vIvaMoraCope 	= 0;
	LET vNumCte 		= '';
	LET vNumTarjeta 	= '';
	LET tAdeudo 		= 0;
	LET tSubtotal 		= 0;
	LET vMtoRees 		= 0;
	LET valorfinal 		= 0;
	LET wmesespro 		= 0;
	--LET vCapital = 0;
	LET vInteres 		= 0;
	LET vIva 			= 0;
	LET vfecha 			= '';
	LET v_tasa_interes	= 0;
	LET vcat 			= 0;
	LET vTasaMora 		= 0;
	LET vProyecInt 		= 0;
	LET vCatIva 		= 0;
	LET vMercadeo 		= '';
	LET pcuenta 		= '';
	LET usuario 		= 'informix';
	LET vnum_solicitud 	= '';
	LET pNumcta 		= '';
	LET pPlazo 			= '';
	LET cSucursal 		= '';
	LET cDescProducto 	= '';
	LET sPeriodoDeGracia = '';
	LET vsdodisp   		= 0;
    LET vstatuscta 		= " ";
	LET cArchMarcajeATM 	= 'Programacion_ATM_Reestructura_';
	LET cArchValidacionATM  = 'Programacion_ATM_Reestructura_';
	LET cRutaArchivo		= '/RESPALDOSNEW/'; --PRODUCCIÓN
	--LET cRutaArchivo		= '/RESPALDOSNEW/gpe/'; -- DESARROLLO
	LET cArchivoDbld		= 'f_carga_insumo1.cmd';
	LET cArchivoLog  		= 'f_carga_insumo1.log';
	LET cArchivoOut			= 'f_carga_insumo1.out';
	LET cArchivoCarga   	= 'dbload_cargaInsumo1.sh';
	LET cDia				= '';
	LET cMes				= '';
	LET cAnio				= '';
	LET dFechaHoy			= '';
	LET mfondo_insuficiente =  0;
	LET mPago_intencion 	=  0;
	LET vProducto    		= '';
    LET vSucursal    		= '';
    LET vCuentaClabe 		= '';
	LET cProductoRTPP		= '8600';
	LET bValidaArchivo		= 'N';
	
	--TRUNCATE TABLE "informix".sd_programacion_reestructuras_aut;--comentar
		
		SELECT fecha_hoy, DAY(fecha_hoy), MONTH(fecha_hoy), YEAR(fecha_hoy)
		INTO dFechaHoy, cDia, cMes, cAnio
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = pempresa;
		
		--Temporal solo PARA PRUEBAS
		/*LET dFechaHoy = MDY('07','29','2021');
		LET cDia = DAY(dFechaHoy);
		LET cMes = MONTH(dFechaHoy);
		LET cAnio = YEAR(dFechaHoy);
		LET cRutaArchivo = '/informix/Ulises/INC/Reest_auto/'; */
		--Temporal solo PARA PRUEBAS
		
		IF MONTH(dFechaHoy) < 10 THEN
			LET cMes = '0' || TRIM(cMes);
		END IF;
		
		IF DAY(dFechaHoy) < 10 THEN
			LET cDia = '0' || TRIM(cDia);
		END IF;
		
--		TRUNCATE TABLE temp_validacion_ATM_reestructura;
		
		LET cArchMarcajeATM = TRIM(cArchMarcajeATM) || cDia || cMes || cAnio || '.txt';
		LET cArchValidacionATM = TRIM(cArchValidacionATM) || cDia || cMes || cAnio || '.txt';
		
		--Se valida que el archivo exista en la carpeta
		LET cCommand = ' cat ' || TRIM(cRutaArchivo) || cArchValidacionATM;
		SYSTEM TRIM(cCommand); --Se lee el archivo
		
		LET bValidaArchivo = 'S'; --Si existe el archivo se modifica la bandera
		
		--SE INICIA EL PROCESO DE CARGA DEL ARCHIVO A LA TABLA temp_validacion_ATM_reestructura
		LET cCommand = 'chmod 777 ' || TRIM(cRutaArchivo) || TRIM(cArchMarcajeATM);
		SYSTEM TRIM(cCommand);
		
--		LET cCommand = ' echo "FILE ' || TRIM(cRutaArchivo) || cArchMarcajeATM || ' DELIMITER ' || '''|''' || ' 8; " > ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld);
		LET cCommand = ' echo "FILE ' || TRIM(cRutaArchivo) || cArchMarcajeATM || ' DELIMITER ' || '''|''' || ' 6; " > ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld);
		SYSTEM TRIM(cCommand);
		
--		LET cCommand = ' echo "INSERT INTO temp_validacion_ATM_reestructura(fecha,numcte,num_credito,num_producto,pago_intencion,pago_mensual,correo_electronico,vigencia); ">> ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld);		
		LET cCommand = ' echo "INSERT INTO "informix".temp_validacion_ATM_reestructura(fecha,num_credito,pago_intencion,pago_mensual,correo_electronico,vigencia); ">> ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld);		
		SYSTEM TRIM(cCommand);
		
		LET cCommand = ' chmod 777 ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = ' echo "dbload -d bdicred -c ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld) || ' -l ' || TRIM(cRutaArchivo) || TRIM(cArchivoLog) || ' -e 10000 -n 1000 -k | tee -a ' || TRIM(cRutaArchivo) ||
						TRIM(cArchivoOut) || '" > ' || TRIM(cRutaArchivo) || TRIM(cArchivoCarga);
		SYSTEM TRIM(cCommand);
		
		LET cCommand = ' chmod 777 ' || TRIM(cRutaArchivo) || TRIM(cArchivoCarga);
		SYSTEM TRIM(cCommand);

		LET cCommand = '/usr/bin/sh ' || TRIM(cRutaArchivo) || TRIM(cArchivoCarga);
		SYSTEM TRIM(cCommand);

		--FIN EL PROCESO DE CARGA DEL ARCHIVO A LA TABLA temp_validacion_ATM_reestructura

	FOREACH WITH HOLD
			SELECT fecha,num_credito,pago_intencion,pago_mensual,correo_electronico,vigencia
			INTO dFecha,cNumCredito,dPagoIntencion,dPagomensual,cCorreoElectronico,dVigencia
			FROM temp_validacion_ATM_reestructura

--			BEGIN WORK;

			UPDATE bdicred:sd_programacion_reestructuras_aut
			SET pago_intencion	= dPagoIntencion,
				pago_mensual	= dPagomensual,
				correo_electronico = cCorreoElectronico,
				vigencia		= dVigencia
			WHERE fecha = dFecha
			  AND num_credito = cNumCredito;

--			COMMIT WORK;
	END FOREACH;	

--RETURN vCodRet;
--set isolation to dirty read; 
	
	FOREACH WITH HOLD
			SELECT numcte,num_credito,num_producto,pago_intencion,pago_mensual
			INTO cNumCte, cNumCredito, cNumProducto, dEnganche, dPagomensual
			FROM bdicred:sd_programacion_reestructuras_aut
			WHERE vigencia >= dFechaHoy and marcaje = '1'
--			WHERE fecha = dFecha
			
/*			SELECT nombre_prod 
			INTO cDescProducto
			FROM bdicred:sd_definicion
			WHERE num_producto = cNumProducto;*/
			
/*			SELECT tar.num_tarjeta
			INTO  vNumTarjeta
			FROM sd_tarjeta tar
			WHERE tar.empresa      = pempresa
			AND tar.num_credito = cNumCredito
			AND tar.tipo_tarjeta  = 'T'
			AND tar.status_tar = 'A';*/
			
			IF cNumProducto IN ('6001','6600','7000','8100','8500') THEN --Activaciòn Reestructura TDC
				CONTINUE FOREACH;	
					EXECUTE PROCEDURE bdicred:"informix".sp_consulta_sdo(pempresa, cNumCredito , vNumTarjeta )
					INTO vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd,
					vIvaMoraOrd, vMoraCopete, vIvaMoraCope, vNumCte, vNumTarjeta;
					
							--	adeudo subtotal y total
					
						
						LET tAdeudo = vCapital + /*vIntVigente +*/ vIntVencido;
						LET tAdeudo = tAdeudo + /*vIvaIntVig +*/ vIvaIntVen;
						LET tAdeudo = tAdeudo + vMoraOrd + vMoraCopete;
						LET tAdeudo = tAdeudo + vIvaMoraCope + vIvaMoraOrd;
						
						
						
						LET tSubtotal = vMoraCopete + vIvaMoraCope;
						
					  ---  .txtTotal.RawData = RawData - txtSubtotal.RawData
						
						
						--monto de la reestrura = monto adeudo - subtotal
						LET vMtoRees = (tAdeudo - tSubtotal ) - dEnganche;
						
						
						---
/*					IF pNumcta is not null THEN
						EXECUTE PROCEDURE bdicheq:"informix".cons_saldo(pNumcta)
						INTO vCodRet,vsdodisp,vstatuscta;
					END IF;
					
					IF dEnganche > vsdodisp or pNumcta is null  THEN 
					LET mfondo_insuficiente = 1;
					--EXIT FOREACH; --sera fondo insuficiente
					END IF*/
					
--					IF pNumcta IS NULL or mfondo_insuficiente = 1 THEN
		
						SELECT COUNT(*)
							INTO mPago_intencion
							FROM sd_movdia 
							WHERE empresa = '001'
							AND fecha_mov = dFechaHoy
							AND num_credito = cNumCredito
							AND monto >= dEnganche
							AND codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
							AND codigo_ref = 1
							AND reversado = 'N';
							
--					END IF;
				
					IF  mPago_intencion > 0 THEN
						
					
							EXECUTE PROCEDURE bdisolic:"informix".asigna_numsol(pempresa , '6011' )
							INTO vCodRet, vnum_solicitud;

									
					--la proyeccion
						FOREACH	
							EXECUTE PROCEDURE bdicred:"informix".proyecta(pempresa  ,vMtoRees/*valortotal */,dPagomensual /*dEnganche*/ /*pagopropuesto*/ ,'6011' ,
							cNumCredito/*num_sol*/, 'S' /*apli_plan*/  ,vnum_solicitud )
							 INTO vCodRet,valorfinal,wmesespro,vCapital,vInteres,vIva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt
							
							--RETURN vCodRet,valorfinal,wmesespro,vCapital,vInteres,vIva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt WITH RESUME;
						END FOREACH;
							
							
							
							SELECT max(plazo)
							INTO pPlazo
							FROM bdicred:"informix".sd_proyecta
							WHERE num_solicitud = vnum_solicitud;
							
							SELECT sucursal
							INTO cSucursal
							FROM bdicred:"informix".sd_maecred
							WHERE num_credito = cNumCredito;
							
							
/*							SELECT tar.num_tarjeta
							INTO  vNumTarjeta
							FROM sd_tarjeta tar
							WHERE tar.empresa      = pempresa
							AND tar.num_credito = cNumCredito
							AND tar.tipo_tarjeta  = 'T'
							AND tar.status_tar = 'A';
*/							

							EXECUTE PROCEDURE bdicheq:cons_cuentas(pempresa, cNumCte)
							INTO vCodRet, pNumcta, vProducto, vSucursal, vCuentaClabe;
							
							EXECUTE PROCEDURE bdicred:"informix".sp_apertura_credito_aut(pempresa ,
														vnum_solicitud /*P_SOLICITUD*/     ,
														vNumTarjeta   ,
														pPlazo      ,
														vMtoRees /*P_MTOSOL*/ ,
														dEnganche ,	 --A LA TABLA SD_MAECRECRD
													   cNumCte   ,
														pNumcta  ,
														cSucursal ,
														'A'  ,
														'6011'  ,
														usuario  ,
														tAdeudo )
							INTO vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
								
							--//Verifica si fue exitoso
/*							IF vCodRet <> "00000" THEN
								ROLLBACK WORK;
								IF (wBegin = "S") THEN
									BEGIN WORK;
								END IF;
								RETURN vCodRet;
							END IF;
*/					END IF;
			
			ELSE --Activaciòn Reestructura Prestamos		
					
					SELECT cuenta
					INTO pNumcta
					FROM bdicheq:"informix".sc_maechq
					WHERE num_cte =cNumCte
					AND status_cta = '1';
					
					EXECUTE PROCEDURE bdicred:"informix".sp_consulta_sdocrd(pempresa , cNumCredito  )
						INTO vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd,
					vIvaMoraOrd, vMoraCopete, vIvaMoraCope, vNumCte;
						
					
							--	adeudo subtotal y total
					
						
						LET tAdeudo = vCapital + /*vIntVigente +*/ vIntVencido;
						LET tAdeudo = tAdeudo + /*vIvaIntVig +*/ vIvaIntVen;
						LET tAdeudo = tAdeudo + vMoraOrd + vMoraCopete;
						LET tAdeudo = tAdeudo + vIvaMoraCope + vIvaMoraOrd;
						
						
						
						LET tSubtotal = vMoraCopete + vIvaMoraCope;
						
					  ---  .txtTotal.RawData = RawData - txtSubtotal.RawData
						
						
						--monto de la reestrura = monto adeudo - subtotal
						LET vMtoRees = (tAdeudo - tSubtotal ) - dEnganche;
			
					EXECUTE PROCEDURE bdicheq:"informix".cons_saldo(pNumcta)
					INTO vCodRet,vsdodisp,vstatuscta;
					
			
					EXECUTE PROCEDURE bdisolic:"informix".asigna_numsol(pempresa, cProductoRTPP)
					INTO vCodRet, vnum_solicitud;
					
					BEGIN WORK;
			--la proyeccion
					FOREACH	--WITH HOLD
					EXECUTE PROCEDURE bdicred:"informix".sp_proyecta_prestamos(pEmpresa ,
                                                vMtoRees     ,
                                                dPagomensual    ,
                                                cProductoRTPP    ,
                                                cNumCredito     ,
                                                'S'   ,
                                                vnum_solicitud   ,
                                                sPeriodoDeGracia  )
						INTO vCodRet,valorfinal,wmesespro,vCapital,vInteres,vIva,vfecha,v_tasa_interes,vcat,vTasaMora,vProyecInt
					
					IF vCodRet::SMALLINT <> 0 then
							ROLLBACK WORK;
							IF (wBegin = "S") THEN
								BEGIN WORK;
							END IF;
							RETURN vCodRet;
						ELSE
							COMMIT WORK;
							--CONTINUE FOREACH;
						end if;
					END FOREACH;
					
					SELECT max(plazo)
					INTO pPlazo
					FROM bdicred:"informix".sd_proyecta
					WHERE num_solicitud = vnum_solicitud;
					
					SELECT sucursal
					INTO cSucursal
					FROM bdicred:"informix".sd_maecredcrd
					WHERE num_credito = cNumCredito;				
					
					EXECUTE PROCEDURE bdicred:"informix".sp_apertura_credito_restructura_prestamo(pempresa   ,		vnum_solicitud  ,
																	cNumCredito,		pPlazo ,
																	vMtoRees,	dEnganche ,	
																	cNumCte  ,		pNumcta ,
																	cSucursal ,		'A' ,
																	cProductoRTPP ,		usuario  ,
																	tAdeudo  ,		sPeriodoDeGracia )
					INTO vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
					
			--//Verifica si fue exitoso
					IF vCodRet <> "00000" THEN
						ROLLBACK WORK;
						IF (wBegin = "S") THEN
							BEGIN WORK;
						END IF;
						RETURN vCodRet;
					ELSE
						BEGIN WORK;
						UPDATE bdicred:sd_programacion_reestructuras_aut
						SET marcaje	= '2'
						WHERE fecha = dFecha
						AND num_credito = cNumCredito;
						COMMIT WORK;
						
					end if;
					CONTINUE FOREACH;
			END IF;

	END FOREACH;	
	
	LET cCommand = 'rm ' || TRIM(cRutaArchivo) || TRIM(cArchivoDbld);
	SYSTEM TRIM(cCommand);
	
	LET cCommand = 'rm ' || TRIM(cRutaArchivo) || TRIM(cArchivoLog);
	SYSTEM TRIM(cCommand);
	
	LET cCommand = 'rm ' || TRIM(cRutaArchivo) || TRIM(cArchivoOut);
	SYSTEM TRIM(cCommand);
	
	LET cCommand = 'rm ' || TRIM(cRutaArchivo) || TRIM(cArchivoCarga);
	SYSTEM TRIM(cCommand);

	RETURN vCodRet;
END PROCEDURE
DOCUMENT
'RQM 09 580 Reestructuras Automaticas',
'Autor: Guadalupe Espinoza Valenzuela',
'BD: bdicred',
'Fecha: 2021';

CREATE PROCEDURE "informix".sp_reverso_repostar( pProducto CHAR(4),pTarjetaAnt CHAR(20),pTarjetaNew CHAR(20))
RETURNING CHAR(6)         AS codigo_retorno,
          VARCHAR(100,1)  AS mensaje_retorno;

DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
-- Actualiza producto de la tarjeta nueva en intercard INI
DEFINE Scodproducto          CHAR(03);
-- Actualiza producto de la tarjeta nueva en intercard FIN

LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'PROCESO EXITOSO';

-- Actualiza producto de la tarjeta nueva en intercard INI
LET Scodproducto        = "";
-- Actualiza producto de la tarjeta nueva en intercard FIN

--SET DEBUG FILE TO '/ifxsif01/Male/INC27214/sp_reverso_repostar.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;

      RETURN cCodRet, cMensajeRet;
    END IF;
END EXCEPTION;

select first 1 codproductotarjeta
into Scodproducto
from intercard:"informix".binproducto  
where codprodcta = pProducto
and bin = substr(pTarjetaNew,1,6);

IF  TRIM(NVL(pTarjetaAnt,''))=''  OR TRIM(NVL(pProducto,''))=''  OR TRIM(NVL(pTarjetaNew,''))=''   THEN
  LET cCodRet = '000001';
  LET cMensajeRet = 'El parámetro no es valido';

  RETURN cCodRet, cMensajeRet;
END IF;
			--En caso de error se elimina el registro de la nueva tarjeta
			DELETE FROM intercard:"informix".tarjetacuenta WHERE numtarjeta = pTarjetaNew;
			DELETE FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = pTarjetaNew;
			UPDATE bdicred:"informix".sd_tarjeta SET status_tar='A' WHERE num_Tarjeta = pTarjetaAnt;
			UPDATE intercard:"informix".tarjeta 
			SET fechanacimiento=NULL,CodStatusAsignada='NOA', fechaasignacion=NULL, CodStatusTarjeta='INA', UsuarioUltModif=NULL, FechaUltModif=NULL, codproductotarjeta=Scodproducto
			WHERE numtarjeta = pTarjetaNew;

	RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para reverso de reposición de tarjetas en caso de error en Apertp',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 02/02/2023',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_conssdoticket_web(cEmpresa  CHAR (3),CNumCredito CHAR (20), dFechaHoy Date)
  RETURNING CHAR (5) AS CodRet,
  DECIMAL(14,2)  AS SusCompras,
  DECIMAL(14,2)  AS Disposiciones,
  DECIMAL(14,2)  AS SusComisiones,
  DECIMAL(14,2)  AS Iva,
  DECIMAL (14,2) AS SusAbonos,
  DECIMAL(14,2)  AS dmorapagados,
  DECIMAL (14,2) AS divamorapagados,
  DECIMAL (14,2) AS interespagototaltc;

 -- DEFINICION DE VARIABLES --
DEFINE sSqlErr SMALLINT;
DEFINE cCodRet CHAR(5);
DEFINE cCodRetOtro CHAR(5);
DEFINE dSusAbonos DECIMAL(14,2);
DEFINE dmorapagados DECIMAL(14,2);
DEFINE divamorapagados DECIMAL(14,2);
DEFINE dSusCompras DECIMAL(14,2);
DEFINE dSusComisiones DECIMAL(14,2);
DEFINE dDisposiciones DECIMAL(14,2);
DEFINE dIvaComisiones DECIMAL(14,2);
DEFINE dComisionesSbc DECIMAL(14,2);
DEFINE dIvaComisionesSbc DECIMAL(14,2);
DEFINE dComisRepos DECIMAL(14,2);
DEFINE dIva DECIMAL(14,2);
DEFINE dPeriodoIni DATE;
DEFINE dPeriodoFin DATE;
DEFINE dFechaCentral DATE;
DEFINE dPeriodoAnterior DATE;
DEFINE iDiasPeriodo INTEGER;
DEFINE cNumCre CHAR (20);
DEFINE dintpagtaltc DECIMAL (14,2);
DEFINE iDia_corte INTEGER;
---RGH
DEFINE dSusAbonos2 DECIMAL(14,2);
DEFINE dmorapagados2 DECIMAL(14,2);
DEFINE divamorapagados2 DECIMAL(14,2);
DEFINE dSusCompras2 DECIMAL(14,2);
DEFINE dSusComisiones2 DECIMAL(14,2);
DEFINE dDisposiciones2 DECIMAL(14,2);
DEFINE dIvaComisiones2 DECIMAL(14,2);
DEFINE dComisionesSbc2 DECIMAL(14,2);
DEFINE dIvaComisionesSbc2 DECIMAL(14,2);
DEFINE dComisRepos2 DECIMAL(14,2);
DEFINE dCrediSoluciones DECIMAL(14,2);
DEFINE dCrediSoluciones2 DECIMAL(14,2);								  
 -- INICIALIZACION DE VARIABLES --
LET sSqlErr = 0;
LET cCodRet = '00000';
LET cCodRetOtro = '000';
LET dSusAbonos = 0;
LET dmorapagados = 0;
LET divamorapagados = 0;
LET dSusCompras = 0;
LET dSusComisiones = 0;
LET dDisposiciones = 0;
LET dIvaComisiones = 0;
LET dComisionesSbc = 0;
LET dIvaComisionesSbc = 0;
LET dComisRepos = 0;
LET dIva = 0;
LET dPeriodoIni = '';
LET dPeriodoFin = '';
LET dFechaCentral = '';
LET dPeriodoAnterior = '';
LET iDiasPeriodo = 0;
LET cNumCre = '';
LET dintpagtaltc = 0;
LEt iDia_corte = 0;

--RGH

LET dSusAbonos2 = 0;
LET dmorapagados2 = 0;
LET divamorapagados2 = 0;
LET dSusCompras2 = 0;
LET dSusComisiones2 = 0;
LET dDisposiciones2 = 0;
LET dIvaComisiones2 = 0;
LET dComisionesSbc2 = 0;
LET dIvaComisionesSbc2 = 0;
LET dComisRepos2 = 0;

LET dCrediSoluciones = 0;
LET dCrediSoluciones2 = 0;						 
BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, dSusCompras, dDisposiciones, dSusComisiones , dIva, dSusAbonos, dmorapagados, divamorapagados, dintpagtaltc;
        END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

   SELECT {+INDEX(sd_fechas idx_sdfechas)} fecha_hoy
     INTO dFechaCentral
     FROM bdicred:sd_fechas
   WHERE empresa = cEmpresa;

    SELECT dia_corte
    INTO iDia_corte
    FROM bdicred:sd_maecredanexo
    WHERE empresa = cEmpresa
        AND num_credito = cNumCredito;

   if day(dFechaCentral) <= iDia_corte then
      let dPeriodoIni = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral)) - 1 units month;
   else
      let dPeriodoIni = mdy(month(dFechaCentral),iDia_corte,year(dFechaCentral));
   end if;
	--IFRS Cambio de formula para el calculo a restar para cuando el crÃ©dito se encuentre en orden(vencido traspasado)
    select sdo_cap_insoluto +
           int_tra_no_exig -
		   case when NVL(int_tra_no_exig,0) > 0 then NVL(sdo_int_anticip,0) else 0 end +
           --case when NVL(monto_vencido+mto_venc_trasp,0) > 0 then sdo_int_anticip else 0 end +
            nvl((select campo_trabajo1
                   from bdicred:sd_amortiza_credito
                  where a.empresa = empresa
                    and a.num_credito = num_credito
                    and a.fecha = fecha_cuota),0)
    INTO dintpagtaltc
    from bdicred:sd_maesdoshist a
    where empresa = cEmpresa
    and num_credito = cNumCredito
    and fecha = (SELECT max(fecha)
                   FROM bdicred:sd_maesdoshist
                  where a.empresa = empresa
                    and a.num_credito = num_credito);

	IF dintpagtaltc IS NULL THEN
	   LET dintpagtaltc = 0;
	END IF;
--IFRS Se contemplan nuevos codigos Ref para identificar las nuevas transacciones creadas para IFRS
FOREACH	WITH HOLD

SELECT SUM(CASE WHEN codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END
	ELSE 0 END), --MENOS SUS ABONOS
	SUM(CASE WHEN codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref = 2 THEN monto ELSE 0 END
	ELSE 0 END), --Moratorios pagados
    	SUM(CASE WHEN codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref in (6616,6617) THEN monto ELSE 0 END
	ELSE 0 END), --Iva moratorios pagados
	SUM(CASE WHEN codigo_fun = '002' THEN
	CASE WHEN codigo_ref in(37,57,937,938) THEN monto ELSE 0 END
	ELSE 0 END),  --MAS SUS COMPRAS
	
	SUM(CASE WHEN codigo_fun in ('061','081') THEN
	CASE WHEN codigo_ref in(5,8,16) THEN monto ELSE 0 END
	ELSE 0 END),  --SUS CREDISOLUCIONES CARGADAS
	
	SUM(CASE WHEN codigo_fun = '339' THEN
		--CASE WHEN codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101) THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101,993,994,995,996) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END),  --MAS COMISIONES
	SUM(CASE WHEN codigo_fun = '002' THEN
		CASE WHEN codigo_ref IN (30,50,40,41,42,60,61,62,63,64,65) THEN monto ELSE 0 END 
	ELSE 0 END),   --MAS DISPOSICIONES EN EFECTIVO
	SUM(CASE WHEN codigo_fun = '340' THEN
		--CASE WHEN codigo_ref IN (1,2,27,30,31) THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref IN (1,2,27,30,31,901,902,903,904) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END),  --MAS IVA COMISIONES
	SUM(CASE WHEN codigo_fun = '336' THEN
	CASE WHEN codigo_ref = 23 THEN monto ELSE 0 END
	ELSE 0 END),  --MAS COMISIONES SBC
	SUM(CASE WHEN codigo_fun = '336' THEN
	CASE WHEN codigo_ref = 24 THEN monto ELSE 0 END
	ELSE 0 END),  --MAS IVA SBC
	SUM(CASE WHEN codigo_fun = '033' THEN
		--CASE WHEN codigo_ref = 6212 THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref in (6212,9090) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END)  --COMISION REPOSICION
	INTO dSusAbonos2,
	dmorapagados2,
	divamorapagados2,
	dSusCompras2,
	dCrediSoluciones2,
	dSusComisiones2,
	dDisposiciones2,
	dIvaComisiones2,
	dComisionesSbc2,
	dIvaComisionesSbc2,
	dComisRepos2
	FROM bdicred:sd_movdia
	WHERE empresa = cEmpresa
	AND num_credito = cNumCredito
	AND fecha_mov > dPeriodoIni
--	AND fecha_mov <= dPeriodoFin
	AND reversado = "N"

if dSusAbonos2 is null then let dSusAbonos2 = 0; end if;
if dmorapagados2 is null then let dmorapagados2 = 0; end if;
if divamorapagados2 is null then let divamorapagados2 = 0; end if;
if dSusCompras2 is null then let dSusCompras2 = 0; end if;
if dCrediSoluciones2 is null then let dCrediSoluciones2 = 0; end if;																
if dSusComisiones2 is null then let dSusComisiones2 = 0; end if;
if dDisposiciones2 is null then let dDisposiciones2 = 0; end if;
if dIvaComisiones2 is null then let dIvaComisiones2 = 0; end if;
if dComisionesSbc2 is null then let dComisionesSbc2 = 0; end if;
if dIvaComisionesSbc2 is null then let dIvaComisionesSbc2 = 0; end if;
if dComisRepos2 is null then let dComisRepos2 = 0; end if;

--IFRS Se contemplan nuevos codigos Ref para identificar las nuevas transacciones creadas para IFRS
SELECT SUM(CASE WHEN codigo_fun IN (select {+ INDEX (sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref = 1 THEN monto ELSE 0 END
	ELSE 0 END), --MENOS SUS ABONOS
	SUM(CASE WHEN codigo_fun IN (select {+ INDEX (sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref = 2 THEN monto ELSE 0 END
	ELSE 0 END),--Moratorios pagados
    	SUM(CASE WHEN codigo_fun IN (select {+ INDEX (sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual) THEN
	CASE WHEN codigo_ref in (6616,6617) THEN monto ELSE 0 END
	ELSE 0 END), --Iva moratorios pagados
	SUM(CASE WHEN codigo_fun = '002' THEN
	CASE WHEN codigo_ref in(37,57,937,938) THEN monto ELSE 0 END
	ELSE 0 END),  --MAS SUS COMPRAS
	
	SUM(CASE WHEN codigo_fun in ('061','081') THEN
	CASE WHEN codigo_ref in(5,8,16) THEN monto ELSE 0 END
	ELSE 0 END),  --SUS CREDISOLUCIONES CARGADAS
	
	SUM(CASE WHEN codigo_fun = '339' THEN
		--CASE WHEN codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101) THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101,993,994,995,996) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END),  --MAS COMISIONES
	SUM(CASE WHEN codigo_fun = '002' THEN
		CASE WHEN codigo_ref IN (30,50,40,41,42,60,61,62,63,64,65) THEN monto ELSE 0 END 
	ELSE 0 END),   --MAS DISPOSICIONES EN EFECTIVO
	SUM(CASE WHEN codigo_fun = '340' THEN
		--CASE WHEN codigo_ref IN (1,2,27,30,31) THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref IN (1,2,27,30,31,901,902,903,904) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END),  --MAS IVA COMISIONES
	SUM(CASE WHEN codigo_fun = '336' THEN
	CASE WHEN codigo_ref = 23 THEN monto ELSE 0 END
	ELSE 0 END),  --MAS COMISIONES SBC
	SUM(CASE WHEN codigo_fun = '336' THEN
	CASE WHEN codigo_ref = 24 THEN monto ELSE 0 END
	ELSE 0 END),  --MAS IVA SBC
	SUM(CASE WHEN codigo_fun = '033' THEN
		--CASE WHEN codigo_ref = 6212 THEN monto ELSE 0 END --TRANSACCIONES ANTERIORES
		CASE WHEN codigo_ref in (6212,9090) THEN monto ELSE 0 END --TRANSACCIONES CON IFRS
	ELSE 0 END)  --COMISION REPOSICION
INTO 	dSusAbonos,
	dmorapagados,
	divamorapagados,
	dSusCompras,
	dCrediSoluciones,			  
	dSusComisiones,
	dDisposiciones,
	dIvaComisiones,
	dComisionesSbc,
	dIvaComisionesSbc,
	dComisRepos
FROM bdicred:sd_movhis
WHERE empresa = cEmpresa
	AND num_credito = cNumCredito
	AND fecha_mov > dPeriodoIni
--	AND fecha_mov <= dPeriodoFin
	AND reversado = "N";

if dSusAbonos is null then let dSusAbonos = 0; end if;
if dmorapagados is null then let dmorapagados = 0; end if;
if divamorapagados is null then let divamorapagados = 0; end if;
if dSusCompras is null then let dSusCompras = 0; end if;
if dCrediSoluciones is null then let dCrediSoluciones = 0; end if;																  
if dSusComisiones is null then let dSusComisiones = 0; end if;
if dDisposiciones is null then let dDisposiciones = 0; end if;
if dIvaComisiones is null then let dIvaComisiones = 0; end if;
if dComisionesSbc is null then let dComisionesSbc = 0; end if;
if dIvaComisionesSbc is null then let dIvaComisionesSbc = 0; end if;
if dComisRepos is null then let dComisRepos = 0; end if;

	LET dSusAbonos = dSusAbonos + dSusAbonos2;
	LET dmorapagados = dmorapagados + dmorapagados2;
	LET divamorapagados = divamorapagados + divamorapagados2;
	--	LET dSusCompras = dSusCompras + dSusCompras2;

	LET dSusCompras = dSusCompras + dSusCompras2 + dCrediSoluciones + dCrediSoluciones2;
	LET dSusComisiones = dSusComisiones + dSusComisiones2;
	LET dDisposiciones = dDisposiciones + dDisposiciones2;
	LET dIvaComisiones = dIvaComisiones + dIvaComisiones2;
	LET dComisionesSbc = dComisionesSbc + dComisionesSbc2;
	LET dIvaComisionesSbc = dIvaComisionesSbc + dIvaComisionesSbc2;
	LET dComisRepos = dComisRepos + dComisRepos2;

	LET dSusComisiones = NVL(dSusComisiones, 0) + NVL(dComisionesSbc, 0) + NVL(dComisRepos, 0);
	LET dIva = NVL(dIvaComisiones, 0) + NVL(dIvaComisionesSbc, 0);

IF dSusCompras IS NULL AND dDisposiciones IS NULL AND dSusAbonos IS NULL THEN
	LET dSusAbonos = 0;
	LET dSusCompras = 0;
	LET dDisposiciones = 0;
END IF;

RETURN cCodRet, dSusCompras, dDisposiciones, dSusComisiones , dIva, dSusAbonos, dmorapagados,
	divamorapagados, dintpagtaltc WITH RESUME;

End FOREACH;

END;
END PROCEDURE;