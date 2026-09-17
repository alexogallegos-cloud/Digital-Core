CREATE PROCEDURE "informix".sp_sac_conciliadeta(pfecha DATE)
	returning 	char(5)  	as CodRetorno,
				CHAR(90)	as mensaje;
				
	
	--ElaborÃÂ³: Alejandro Osuna Iza
	--Actividad: Extrae la informaciÃÂ³n de la tabla de sac_eglobal_detalle y de la sc_movhis para el proceso de generacion del reporte de detalle de la concilacion.
	--Solicito: Jorge NuÃÂ±ez
	--Fecha: 16 de Marzo de 2010

	--Declaracion de variables
	DEFINE vCodRet 			CHAR(5);
	DEFINE cSqlErr			INTEGER;
	DEFINE vcod_txn 		CHAR(2);
	DEFINE vmensaje			CHAR(90);
	DEFINE vcod_registro 	CHAR(1);
	DEFINE vnum_tarjeta 	CHAR(16);
	DEFINE vnum_referencia 	CHAR(23);
	DEFINE vfecha_txn 		CHAR(4);
	DEFINE vimporte_txn 	INTEGER;
	DEFINE vcod_actual_des 	CHAR(3);
	DEFINE vnombre_negocio 	CHAR(25);
	DEFINE vcod_razon 		CHAR(2);
	DEFINE vind_deposito 	CHAR(1);
	DEFINE vsucursal 		CHAR(4);
	DEFINE vcuenta_cargo 	CHAR(20);
	DEFINE vtransacc_suc 	CHAR(4);
	DEFINE iimporte 		MONEY(12,2);
	DEFINE vnum_refemov 	CHAR(40);
	DEFINE iContadorBan		INTEGER;
	DEFINE itotal_txn		INTEGER;
	DEFINE itotal_sif		MONEY(12,2);
	DEFINE videntifica		CHAR(1);
	DEFINE vbanco_des		CHAR(20);
	DEFINE vCod_razon91		CHAR(25);
	DEFINE vCod_razon92		CHAR(25);
	DEFINE vCod_razon93		CHAR(25);
	DEFINE vCod_razon94		CHAR(25);
	DEFINE vcod_razonF 		CHAR(30);
	DEFINE vsFolioSuc		CHAR(16);
    DEFINE vconsmovhis      CHAR(10);
	DEFINE dFecha_ua        DATE;
    
	
	--inicializacion de variables
	LET vCodRet 			= '00000';
	LET cSqlErr				= 0;
	LET vcod_txn 			= '';
	LET vmensaje			= '';
	LET vcod_registro 		= '';
	LET vnum_tarjeta		= '';
	LET vnum_referencia		= '';
	LET vfecha_txn			= '';
	LET vimporte_txn		= '';
	LET vcod_actual_des		= '';
	LET vnombre_negocio		= '';
	LET vcod_razon			= '';
	LET vind_deposito		= '';
	LET vsucursal			= '';
	LET vcuenta_cargo		= '';
	LET vtransacc_suc		= '';
	LET iimporte 			= 0.00;
	LET vnum_refemov		= '';
	LET iContadorBan		= 0;
	LET itotal_txn			= 0;
	LET itotal_sif			= 0.00;
	LET videntifica			= '';
	LET vbanco_des			= '';
	LET vCod_razon91		= 'Pago en Efectivo';
	LET vCod_razon92		= 'Pago con Cargo en Cuenta';
	LET vCod_razon93		= 'Pago con Cargo Cta (PP)';
	LET vCod_razon94		= 'Pago Internet';
	LET vcod_razonF			= '';
	LET vsFolioSuc          = '';
	LET dFecha_ua           ='01-01-1900';   

	--SET DEBUG FILE TO "/informix/EPG/sp_sac_conciliadeta.out";
	--TRACE ON;

	BEGIN
		 ON EXCEPTION SET cSqlErr
	        IF cSqlerr <> 0 THEN
				LET vmensaje = 'Error de Informix';
	            Let vCodRet = cSqlErr;
				RETURN vCodRet,vmensaje;
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

            SELECT valor
            INTO vconsmovhis
            FROM bdicheq:sc_param
            WHERE codparam = 'fechcon_movhis'
            AND  empresa = '001';
			
			SELECT fecha_ultimo_archivo + 1
			INTO dFecha_ua
			FROM bdisac:sac_eglobal_archivos
			WHERE fecha_archivo = pfecha;

		--Se validan los datos de entrada...
		IF pfecha is null THEN
			Let vCodRet = '06001';  
				SELECT {+INDEX (bdisac:sac_eglobal_mensajes_error idx_eg_mensajes)} TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE  cod_ret = '06001' and modulo is not null;
				RETURN vCodRet,vmensaje ;
		END IF;
		
		IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'sac_reporte') THEN
				TRUNCATE bdisac:sac_reporte;
		ELSE
				CREATE TABLE  bdisac:sac_reporte(tipo CHAR(1),cod_txn CHAR(2),cod_registro CHAR(20),num_tarjeta CHAR(16),num_referencia CHAR(23),
														fecha_txn CHAR(4),importe_txn INTEGER,cod_actual_des CHAR(3),nombre_negocio CHAR(25),
														cod_razon 	CHAR(30),ind_deposito CHAR(1),sucursal CHAR(4),cuenta_cargo CHAR(20),
														transacc_suc CHAR(4),importe MONEY(12,2),num_refemov CHAR(40));
		END IF;	
		
		--1.- El Sistema valida que existe el registro de algÃÂºn archivo que coincide con la Fecha recibida como dato de entrada.
		--	1.a.- El Sistema validÃÂ³ que no existe el registro de algÃÂºn archivo que coincide con la Fecha recibida como dato de entrada.
		IF EXISTS(SELECT conciliado FROM bdisac:sac_eglobal_archivos WHERE fecha_archivo = pfecha) THEN
			--2.- El Sistema valida que el Archivo obtenido tiene estatus de Transmitido.
			--2.a.- El Sistema validÃÂ³ que el Archivo obtenido no tiene estatus de Transmitido.
			IF EXISTS(SELECT conciliado FROM bdisac:sac_eglobal_archivos WHERE fecha_archivo = pfecha AND estatus = '1') THEN

                IF pfecha >= vconsmovhis THEN
				--se extrae la informacion para los movimeintos conciliados
                    FOREACH
                        --obtiene los datos de los movimientos conciliados
                        SELECT UNIQUE 	TRIM(sac_det.cod_txn),TRIM(sac_det.codigo_registro),TRIM(sac_det.numero_tarjeta),TRIM(sac_det.num_referencia),
                                        TRIM(sac_det.fecha_txn),TRIM(sac_det.importe_txn),TRIM(sac_det.cod_actual_destino),TRIM(sac_det.nombre_negocio),
                                        TRIM(sac_det.cod_razon),TRIM(sac_det.ind_deposito_efectivo), TRIM(movhis.sucursal), TRIM(movhis.cuenta), TRIM(movhis.transacc_suc),
                                        movhis.monto_tot, TRIM(movhis.referencia), TRIM(movhis.folio_suc)
                        INTO 			vcod_txn,vcod_registro,vnum_tarjeta,vnum_referencia,
                                        vfecha_txn,vimporte_txn,vcod_actual_des,vnombre_negocio,vcod_razon,
                                        vind_deposito,vsucursal,vcuenta_cargo,vtransacc_suc,iimporte,vnum_refemov, vsFolioSuc
                        FROM bdisac:sac_eglobal_detalle AS sac_det, bdicheq:sc_movhis AS movhis
                        WHERE sac_det.fecha_archivo = pfecha
							AND movhis.fech_alt >= dFecha_ua
							AND movhis.fech_alt <= pfecha
							AND sac_det.folio_suc = movhis.folio_suc
							AND sac_det.conciliado ='1'
							AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33004', '33005', '33006', '33007','33011','33012','33013') )

                        LET iContadorBan = iContadorBan + 1;
						IF vind_deposito ='1' THEN
							LET vcuenta_cargo = '';
							LET vcod_razonF = vCod_razon91;
						ELSE
                            SELECT LIMIT 1 TRIM(movhis.cuenta) INTO vcuenta_cargo 
                            FROM bdicheq:sc_movhis AS movhis
                            WHERE  movhis.empresa = '001' AND movhis.folio_suc = vsFolioSuc
                            AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33008','33014') );					  
							IF vsucursal = '5003' THEN -- Internet
								LET vcod_razonF = vCod_razon94;
							ELIF vsucursal = '8501' THEN -- Pago Programado
								LET vcod_razonF = vCod_razon93;
							ELSE
								LET vcod_razonF = vCod_razon92;
							END IF;
						END IF;
						
						SELECT {+INDEX (bdisac:sac_eglobal_banco idxebco)} descripcion INTO vbanco_des FROM bdisac:sac_eglobal_banco WHERE cod_reg = vcod_registro;
						
                        INSERT INTO bdisac:sac_reporte(tipo,cod_txn,cod_registro,num_tarjeta,num_referencia,fecha_txn ,importe_txn ,cod_actual_des ,nombre_negocio,
                                                        cod_razon ,ind_deposito,sucursal,cuenta_cargo,transacc_suc ,importe ,num_refemov )
                        VALUES('1',vcod_txn,vbanco_des,vnum_tarjeta,vnum_referencia,vfecha_txn,vimporte_txn,vcod_actual_des,vnombre_negocio,vcod_razonF,vind_deposito,
                                vsucursal,vcuenta_cargo,vtransacc_suc,iimporte,vnum_refemov);
                    END FOREACH
                 ELSE
                    FOREACH
                        --obtiene los datos de los movimientos conciliados
                        SELECT UNIQUE 	TRIM(sac_det.cod_txn),TRIM(sac_det.codigo_registro),TRIM(sac_det.numero_tarjeta),TRIM(sac_det.num_referencia),
                                        TRIM(sac_det.fecha_txn),TRIM(sac_det.importe_txn),TRIM(sac_det.cod_actual_destino),TRIM(sac_det.nombre_negocio),
                                        TRIM(sac_det.cod_razon),TRIM(sac_det.ind_deposito_efectivo), TRIM(movhis.sucursal), TRIM(movhis.cuenta), TRIM(movhis.transacc_suc),
                                        movhis.monto_tot, TRIM(movhis.referencia), TRIM(movhis.folio_suc)
                        INTO 			vcod_txn,vcod_registro,vnum_tarjeta,vnum_referencia,
                                        vfecha_txn,vimporte_txn,vcod_actual_des,vnombre_negocio,vcod_razon,
                                        vind_deposito,vsucursal,vcuenta_cargo,vtransacc_suc,iimporte,vnum_refemov, vsFolioSuc
                        FROM bdisac:sac_eglobal_detalle AS sac_det, bdicheq:sc_movhis_old AS movhis
                        WHERE sac_det.fecha_archivo = pfecha
							AND movhis.fech_alt >= dFecha_ua 
							AND movhis.fech_alt <= pfecha
							AND sac_det.folio_suc = movhis.folio_suc
							AND sac_det.conciliado ='1'
							AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33004', '33005', '33006', '33007','33011','33012','33013') )

                        LET iContadorBan = iContadorBan + 1;
						IF vind_deposito ='1' THEN
							LET vcuenta_cargo = '';
							LET vcod_razonF = vCod_razon91;
						ELSE
                            SELECT LIMIT 1 TRIM(movhis.cuenta) INTO vcuenta_cargo 
                            FROM bdicheq:sc_movhis_old AS movhis
                            WHERE  movhis.empresa = '001' AND movhis.folio_suc = vsFolioSuc
                            AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33008','33014') );					  
							IF vsucursal = '5003' THEN -- Internet
								LET vcod_razonF = vCod_razon94;
							ELIF vsucursal = '8501' THEN -- Pago Programado
								LET vcod_razonF = vCod_razon93;
							ELSE
								LET vcod_razonF = vCod_razon92;
							END IF;
						END IF;

						SELECT {+INDEX (bdisac:sac_eglobal_banco idxebco)} descripcion INTO vbanco_des FROM bdisac:sac_eglobal_banco WHERE cod_reg = vcod_registro;

                        INSERT INTO bdisac:sac_reporte(tipo,cod_txn,cod_registro,num_tarjeta,num_referencia,fecha_txn ,importe_txn ,cod_actual_des ,nombre_negocio,
                                                        cod_razon ,ind_deposito,sucursal,cuenta_cargo,transacc_suc ,importe ,num_refemov )
                        VALUES('1',vcod_txn,vbanco_des,vnum_tarjeta,vnum_referencia,vfecha_txn,vimporte_txn,vcod_actual_des,vnombre_negocio,vcod_razonF,vind_deposito,
                                vsucursal,vcuenta_cargo,vtransacc_suc,iimporte,vnum_refemov);
                    END FOREACH
                 END IF;
				
				----obtiene los datos de los movimientos no conciliados en ARchivo E-Global
				FOREACH
					SELECT UNIQUE 	TRIM(sac_det.cod_txn),TRIM(sac_det.codigo_registro),TRIM(sac_det.numero_tarjeta),TRIM(sac_det.num_referencia),
									TRIM(sac_det.fecha_txn),TRIM(sac_det.importe_txn),TRIM(sac_det.cod_actual_destino),TRIM(sac_det.nombre_negocio),
									TRIM(sac_det.cod_razon),TRIM(sac_det.ind_deposito_efectivo), TRIM(sac_det.folio_suc)
					INTO 			vcod_txn,vcod_registro,vnum_tarjeta,vnum_referencia,
									vfecha_txn,vimporte_txn,vcod_actual_des,vnombre_negocio,vcod_razon,
									vind_deposito, vsFolioSuc
					FROM bdisac:sac_eglobal_detalle AS sac_det
					WHERE sac_det.fecha_archivo = pfecha
						AND sac_det.conciliado = '0'
					
					IF vind_deposito = '1' THEN
						LET vcod_razonF = vCod_razon91;
					ELSE
						LET vcod_razonF = vCod_razon92;
					END IF;
				
					LET iContadorBan = iContadorBan + 1;
					SELECT {+INDEX (bdisac:sac_eglobal_banco idxebco)} descripcion INTO vbanco_des FROM bdisac:sac_eglobal_banco WHERE cod_reg = vcod_registro;
					
					LET vsucursal = '';
					LET vcuenta_cargo = '';
					LET vtransacc_suc = '';
					LET iimporte = '';
					LET vnum_refemov = '';
					INSERT INTO bdisac:sac_reporte(tipo,cod_txn,cod_registro,num_tarjeta,num_referencia,fecha_txn ,importe_txn ,cod_actual_des ,nombre_negocio,
													cod_razon ,ind_deposito,sucursal,cuenta_cargo,transacc_suc ,importe ,num_refemov )
					VALUES('2',vcod_txn,vbanco_des,vnum_tarjeta,vnum_referencia,vfecha_txn,vimporte_txn,vcod_actual_des,vnombre_negocio,vcod_razonF,vind_deposito,
							vsucursal,vcuenta_cargo,vtransacc_suc,iimporte,vnum_refemov);
				END FOREACH
				----obtiene los datos de los movimientos no conciliados en tabla de movimientos Historicos
                IF pfecha >= vconsmovhis THEN
                    FOREACH
                        SELECT {+INDEX (bdisac:sac_eglobal_noconcil idxfar)} UNIQUE  TRIM(nococil.sucursal), TRIM(nococil.cuenta_cargo), TRIM(nococil.transacc_suc),
                                        nococil.importe, TRIM(nococil.referencia), LPAD(TRIM(movhis.Referencia), 16, '0')
                        INTO 		vsucursal,vcuenta_cargo,vtransacc_suc,iimporte,vnum_refemov, vnum_tarjeta
                        FROM bdicheq:sc_movhis AS movhis, bdisac:sac_eglobal_noconcil AS nococil
                        WHERE nococil.fecha_archivo = pfecha
							AND movhis.fech_alt >= dFecha_ua 
							AND movhis.fech_alt <= pfecha
							AND movhis.folio_suc = nococil.folio_suc
							AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33004', '33005', '33006', '33007','33011','33012','33013') )
                  
                        LET iContadorBan = iContadorBan + 1;
                        LET vbanco_des = '';
                        LET vcod_txn = '';
                        LET vcod_registro  = '';
                        LET vnum_tarjeta  = '';
                        LET vnum_referencia  = '';
                        LET vfecha_txn  = '';
                        LET vimporte_txn  = '';
                        LET vcod_actual_des  = '';
                        LET vnombre_negocio  = '';
                        LET vcod_razon  = ''; 
                        LET vind_deposito = '';

                        INSERT INTO bdisac:sac_reporte(tipo,cod_txn,cod_registro,num_tarjeta,num_referencia,fecha_txn ,importe_txn ,cod_actual_des ,nombre_negocio,
                                                        cod_razon ,ind_deposito,sucursal,cuenta_cargo,transacc_suc ,importe ,num_refemov )
                        VALUES('3',vcod_txn,vbanco_des,vnum_tarjeta,vnum_referencia,vfecha_txn,vimporte_txn,vcod_actual_des,vnombre_negocio,vcod_razon,vind_deposito,
                                vsucursal,vcuenta_cargo,vtransacc_suc,iimporte,vnum_refemov);
                    END FOREACH
                 ELSE
                    FOREACH
                        SELECT {+INDEX (bdisac:sac_eglobal_noconcil idxfar)} unique  TRIM(nococil.sucursal), TRIM(nococil.cuenta_cargo), TRIM(nococil.transacc_suc),
                                        nococil.importe, TRIM(nococil.referencia), LPAD(TRIM(movhis.Referencia), 16, '0')
                        INTO 		vsucursal,vcuenta_cargo,vtransacc_suc,iimporte,vnum_refemov, vnum_tarjeta
                        FROM bdicheq:sc_movhis_old AS movhis, bdisac:sac_eglobal_noconcil AS nococil
                        WHERE nococil.fecha_archivo = pfecha
							AND movhis.fech_alt >= dFecha_ua 
							AND movhis.fech_alt <= pfecha
							AND movhis.folio_suc = nococil.folio_suc
							AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33004', '33005', '33006', '33007','33011','33012','33013') )

                        LET iContadorBan = iContadorBan + 1;
                        LET vbanco_des = '';
                        LET vcod_txn = '';
                        LET vcod_registro  = '';
                        LET vnum_tarjeta  = '';
                        LET vnum_referencia  = '';
                        LET vfecha_txn  = '';
                        LET vimporte_txn  = '';
                        LET vcod_actual_des  = '';
                        LET vnombre_negocio  = '';
                        LET vcod_razon  = ''; 
                        LET vind_deposito = '';

                        INSERT INTO bdisac:sac_reporte(tipo,cod_txn,cod_registro,num_tarjeta,num_referencia,fecha_txn ,importe_txn ,cod_actual_des ,nombre_negocio,
                                                        cod_razon ,ind_deposito,sucursal,cuenta_cargo,transacc_suc ,importe ,num_refemov )
                        VALUES('3',vcod_txn,vbanco_des,vnum_tarjeta,vnum_referencia,vfecha_txn,vimporte_txn,vcod_actual_des,vnombre_negocio,vcod_razon,vind_deposito,
                                vsucursal,vcuenta_cargo,vtransacc_suc,iimporte,vnum_refemov);
                    END FOREACH

                 END IF;
			ELSE
				LET vCodRet = '06002';
				SELECT {+INDEX (bdisac:sac_eglobal_mensajes_error idx_eg_mensajes)} TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE  cod_ret = '06002' and modulo is not null;
				RETURN vCodRet,vmensaje;
			END IF;
		ELSE
			LET vCodRet = '06000';
			SELECT {+INDEX (bdisac:sac_eglobal_mensajes_error idx_eg_mensajes)} TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE  cod_ret = '06000' and modulo is not null;
			RETURN vCodRet,vmensaje;
		END IF;
		
		IF iContadorBan = 0 THEN
			LET vCodRet = '06000';
			SELECT {+INDEX (bdisac:sac_eglobal_mensajes_error idx_eg_mensajes)} TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE  cod_ret = '06000' and modulo is not null;
			RETURN vCodRet,vmensaje;
		END IF;
		LET vCodRet = '00000';
		SELECT {+INDEX (bdisac:sac_eglobal_mensajes_error idx_eg_mensajes)} TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE  cod_ret = '00000' and modulo is not null;
		RETURN vCodRet,vmensaje;
	END;	

END PROCEDURE
 DOCUMENT
'AUTOR: Alejandro Osuna Iza',
'Proyecto: Pago interbancario de tarjetas de credito',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Extrae la informaciÃÂ³n de la tabla de sac_eglobal_detalle y de la sc_movhis para el proceso de generacion del reporte de detalle de la concilacion.',
'Fecha: 2010/03/16',
'Version: 20100316.0953',
'BD: BdiSac',
'',
'AUTOR: Casanova Edeza Hector Juan.',
'Proyecto: Pago interbancario de tarjetas de credito',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Guarda la cuenta de la tarjeta a la que pertenece la tarjeta en lugar de la cuenta concentradora.',
'Fecha: 2010/05/19',
'Version: 20100519.1131',
'BD: BdiSac',
'AUTOR: Eduardo Pineda GuzmÃÂ¡n',
'Proyecto: Pago interbancario de tarjetas de credito',
'Descripcion: Se optimiza la busqueda de registros en movhis, solamente se consultan los registros de la fecha solicitada', 
'Fecha: 2014/02/10',
'BD: BdiSac';

CREATE PROCEDURE  "informix".sp_yvesrocher_valdv(pNumReferencia CHAR(17))
RETURNING CHAR(5) AS CodigoRetorno;


--DEFINICION DE LAS VARIABLES
DEFINE iCodRet      	CHAR(5); 
DEFINE iSqlErr      	INTEGER; 
DEFINE iSuma        	INTEGER; 
DEFINE iAux         	INTEGER; 
DEFINE iDig_ver     	INTEGER; 
DEFINE iResiduo     	INTEGER; 
DEFINE i            	INTEGER; 
DEFINE iMulti       	INTEGER;
DEFINE cCadena	    	CHAR(30); 
DEFINE iAux2        	INTEGER; 
DEFINE iDig_ver_cap 	INTEGER; 
DEFINE cNumReferencia   CHAR(16);

--INICIALIZACION DE LAS VARIABLES
LET iCodRet		= '00000';
LET iSqlErr		= 0;
LET iSuma		= 0;
LET iAux		= 0;
LET iDig_ver	= 0;
LET iResiduo	= 0;
LET i			= 16;
LET iMulti		= 2;
LET cCadena		= '';
LET iAux2		= 0;
LET iDig_ver_cap	= 0;
LET cNumReferencia	= '';

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET iCodRet = iSqlErr;
		  RETURN iCodRet;
	   END IF;
	END EXCEPTION;

--	SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_yvesrocher_valdv.out';
--	TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF TRIM(pNumReferencia) = '' THEN
		LET iCodRet = '00001';	
	ELSE
		IF LENGTH(TRIM(pNumReferencia)) <> 17 THEN
			LET iCodRet = '00002';			
		ELSE
			LET iDig_ver_cap = SUBSTR(pNumReferencia,17,1);
			LET cNumReferencia = SUBSTR(pNumReferencia,1,16);
			
			WHILE i <> 0
				LET iAux = SUBSTR(cNumReferencia,i,1);
				LET iAux2 = iMulti * iAux;
				LET cCadena = TRIM(cCadena)||iAux2;
					
					IF iMulti = 2 THEN 
						LET iMulti = 1; 
					ELSE
						IF iMulti = 1 THEN 
							LET iMulti = 2; 
						END IF; 
					END IF;
					
				LET i = i - 1;
				LET iAux = 0;	
				LET iAux2 = 0;			
			END WHILE;
			
			LET i = LENGTH(cCadena);
			
			WHILE i <> 0
				LET iAux = SUBSTR(cCadena,i,1);
				LET iSuma = iSuma + iAux;
				LET i = i - 1;
				LET iAux = 0;				
			END WHILE;
			
			LET iResiduo = MOD(iSuma,10);
			
			IF iResiduo = 0 THEN 
				IF iResiduo <> iDig_ver_cap THEN LET iCodRet = '00109'; END IF;
			ELSE
				LET iDig_ver = 10 - iResiduo;
				IF iDig_ver <> iDig_ver_cap THEN LET iCodRet = '00109'; END IF;
			END IF;
		END IF;		
	END IF;	
	RETURN iCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio: 1454',
'Autor: Vazquez Herrera Hugo Guadalupe  ',
'Fecha: 07/08/2014',
'Descripción: Se crea un procedimiento en central para validar el digito verificador para YVES ROCHER',
'Sustento: RQM 10 498 PgsRef_YVES ROCHER.doc',
'Solicita: Leonardo Hernandez',
'BD: bdisac';

CREATE PROCEDURE  "informix".sp_prefijos_cvecobrem (pNumCategoria CHAR(2),pNumConvenio CHAR(3))

RETURNING CHAR(5) AS iCodRet, char(50) as iMensaje;
	--GENERAR REPOTE PREFIJOS CLAVE DE COBRO DE REMESAS--
	
	DEFINE iCodRet 			CHAR(5);
	DEFINE iMensaje			CHAR(50);
	DEFINE iServicio		CHAR(50);
	DEFINE cRutaArch 		CHAR(100);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cDia 			CHAR(2);
	DEFINE cMes 			CHAR(2);
	DEFINE cAnio 			CHAR(4);
	DEFINE dFecha_Hoy 		DATE;
	DEFINE dFecha_Pago		DATE;
	DEFINE iCuenta_Pago 	INTEGER;
	DEFINE cStmt 			VARCHAR (255);
	DEFINE i				INTEGER;
	DEFINE cPrefijo			CHAR(4);


	--SET DEBUG FILE TO '/informix/HMLG/sp_prefijos_cvecobrem.out';
	--TRACE ON;
		
	LET iCodRet = '00000';
	LET cRutaArch = '';
	LET iServicio = '';
	LET iSqlErr = 0;
	LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
	LET dFecha_Hoy = MDY('01','01','1900');
	LET dFecha_Pago = MDY('01','01','1900');
	LET iCuenta_Pago = 0;
	LET cStmt = '';
	LET iMensaje = '';
	LET i = 0;
	LET cPrefijo = '';

	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = '00001';
			LET iMensaje = "Proceso NO Exitoso Error BD. " || iSqlErr || ' ' || iServicio;
			
			SYSTEM 'rm -f /home/systelmex/temp';
			SYSTEM 'rm -f /home/systelmex/prefijo';
			SYSTEM 'rm -f /home/systelmex/informacion';  
			SYSTEM 'rm -f /home/systelmex/temp1';
			SYSTEM 'rm -f /home/systelmex/prefijo1';
			SYSTEM 'rm -f /home/systelmex/informacion1';
			SYSTEM 'rm -f /home/systelmex/temp3';
			SYSTEM 'rm -f /home/systelmex/prefijo3';
			SYSTEM 'rm -f /home/systelmex/informacion3';
			
			drop table if exists t1pccr;
			drop table if exists t2pccr;
			drop table if exists t3pccr;
			
			RETURN iCodRet,iMensaje;
		END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT fecha_hoy 
		INTO dFecha_Hoy 
		FROM bdisac:sac_fechas
		WHERE empresa = "001";
		
		LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
        LET cMEs = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
        LET cAnio = LPAD(YEAR(dFecha_Hoy::DATE), 4, '0');
		
		
		IF pNumConvenio = '004' THEN
			LET cRutaArch = '/home/systelmex/Prefcvecobrem_BTS_DDMMAAAA.csv';
			LET iServicio = 'BTS';
		ELIF pNumConvenio = '009' THEN
			LET cRutaArch = '/home/systelmex/Prefcvecobrem_Apriza_DDMMAAAA.csv';
			LET iServicio = 'Apriza';
		ELSE
			LET iCodRet = '00001';
			LET iMensaje = 'Proceso NO Exitoso, Input no valido: ' || pNumCategoria || '-' ||pNumConvenio;
		END IF;
		
		
		IF iCodRet = '00000' THEN
			
			LET cRutaArch = REPLACE(cRutaArch,'AAAA',cAnio);
			LET cRutaArch = REPLACE(cRutaArch,'MM',cMes);
			LET cRutaArch = REPLACE(cRutaArch,'DD',cDia);
		
			LET cStmt = 'rm -f ' || cRutaArch;
			SYSTEM cStmt;
		
			SYSTEM 'rm -f /home/systelmex/temp';
			SYSTEM 'rm -f /home/systelmex/prefijo';
			SYSTEM 'rm -f /home/systelmex/informacion';  
			SYSTEM 'rm -f /home/systelmex/temp1';
			SYSTEM 'rm -f /home/systelmex/prefijo1';
			SYSTEM 'rm -f /home/systelmex/informacion1';
			SYSTEM 'rm -f /home/systelmex/temp3';
			SYSTEM 'rm -f /home/systelmex/prefijo3';
			SYSTEM 'rm -f /home/systelmex/informacion3';
			drop table if exists t1pccr;
			drop table if exists t2pccr;
			drop table if exists t3pccr;
			
		
			LET cStmt = 'echo "' || "PREFIJOS CLAVE DE COBRO DE REMESAS "  || iServicio || '" >> ' || cRutaArch;
			SYSTEM cStmt; 
	
			--FIJA EL MES QUE LE CORRESPONDE AL REPORTE PARA LAS BUSQUEDAS
			IF cMes <> "01" then
				LET cMes = Month(dFecha_Hoy - 1 units month);
			ELSE
				LET cMes = Month(dFecha_Hoy - 1 units month);
				LET cAnio = Year(dFecha_Hoy)-1;
			END IF;
		
			--Extrae a una tabla temporal t1 los datos nedesarios para el reporte segun el mes 
		
			SELECT SUBSTR(referencia1,1,4) prefijo, fecha_pago, COUNT(*) AS operaciones FROM bdisac:sac_movimientoshistorial
				WHERE numcategoria = pNumCategoria
				AND numconvenio = pNumConvenio
				AND status_cancelado <> 'S'
				AND MONTH(fecha_pago) = cMes
				AND YEAR(fecha_pago) = cAnio
				GROUP BY 1,2
				ORDER BY fecha_pago,prefijo
				INTO temp t1pccr WITH NO LOG;
		
			--Obtiene los prefijos del mes y los envia a una tabla temporal t2
			SELECT UNIQUE prefijo 
			FROM bdisac:t1pccr 
			ORDER BY 1 
			INTO TEMP t2pccr  WITH NO LOG;
			--Obtiene las fechas del mes y los envia a una tabla temporal t3
			SELECT UNIQUE fecha_pago 
			FROM bdisac:t1pccr  
			ORDER BY 1 
			INTO TEMP t3pccr  WITH NO LOG;
		
			SYSTEM 'echo "Fecha," > /home/systelmex/temp';
			SYSTEM 'echo "," > /home/systelmex/temp1';
			
			FOREACH
		
				SELECT PREFIJO
				INTO cPrefijo
				FROM t2pccr  ORDER BY 1
			
				--Acomoda titulos [Prefijo 1,Prefijo2,....PrefijoN]
				SYSTEM 'echo "Prefijo ' || i+1 || '," > /home/systelmex/prefijo1';
				SYSTEM 'paste -d "\0" /home/systelmex/temp1 /home/systelmex/prefijo1 > /home/systelmex/informacion1';
				SYSTEM 'cp /home/systelmex/informacion1 /home/systelmex/temp1';
			
				--Acomoda Prefijos
				SYSTEM 'echo "' || cPrefijo || '," > /home/systelmex/prefijo';
				SYSTEM 'paste -d "\0" /home/systelmex/temp /home/systelmex/prefijo > /home/systelmex/informacion';
				SYSTEM 'cp /home/systelmex/informacion /home/systelmex/temp';
									
				let i = i + 1;

			END FOREACH;
		
			SYSTEM 'tail -n +1 /home/systelmex/informacion1 >> ' || cRutaArch;
			SYSTEM 'tail -n +1 /home/systelmex/informacion >> ' || cRutaArch;
			
			FOREACH
			
				SELECT fecha_pago 
				INTO dFecha_Pago
				FROM t3pccr  ORDER BY 1
			
				LET cDia = LPAD(DAY(dFecha_Pago::DATE), 2, '0');
				LET cMEs = LPAD(MONTH(dFecha_Pago::DATE), 2, '0');
				LET cAnio = LPAD(YEAR(dFecha_Pago::DATE), 4, '0');
			
				SYSTEM 'echo "' || cDia || '/' || cMes || '/' || cAnio || '," > /home/systelmex/temp3';
			
				FOREACH
			
					SELECT t2pccr.prefijo, NVL(t1pccr.operaciones,0) as Cuenta_Pago
					INTO cPrefijo, iCuenta_Pago
					FROM OUTER t1pccr , t2pccr 
					WHERE t1pccr.prefijo = t2pccr.prefijo
					AND t1pccr.fecha_pago = dFecha_Pago
					ORDER BY 1
				
					SYSTEM 'echo "' || iCuenta_Pago || '," > /home/systelmex/prefijo3';
					SYSTEM 'paste -d "\0" /home/systelmex/temp3 /home/systelmex/prefijo3 > /home/systelmex/informacion3';
					SYSTEM 'cp /home/systelmex/informacion3 /home/systelmex/temp3';
				
				END FOREACH;
			
				SYSTEM 'tail -n +1 /home/systelmex/informacion3 >> ' || cRutaArch;
		
			END FOREACH;
		
			SYSTEM 'rm -f /home/systelmex/temp';
			SYSTEM 'rm -f /home/systelmex/prefijo';
			SYSTEM 'rm -f /home/systelmex/informacion';
			SYSTEM 'rm -f /home/systelmex/temp1';
			SYSTEM 'rm -f /home/systelmex/prefijo1';
			SYSTEM 'rm -f /home/systelmex/informacion1';
			SYSTEM 'rm -f /home/systelmex/temp3';
			SYSTEM 'rm -f /home/systelmex/prefijo3';
			SYSTEM 'rm -f /home/systelmex/informacion3';
			drop table t1pccr;
			drop table t2pccr;
			drop table t3pccr;
		
			LET iMensaje = 'Proceso Exitoso ' || iServicio;
			LET iCodRet ='00000';
		
		END IF;
		
		RETURN iCodRet,iMensaje;
		
	END;

END PROCEDURE;