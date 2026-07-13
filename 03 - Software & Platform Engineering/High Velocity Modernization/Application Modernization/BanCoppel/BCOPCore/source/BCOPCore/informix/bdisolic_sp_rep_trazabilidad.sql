CREATE PROCEDURE "informix".sp_rep_trazabilidad()
    RETURNING CHAR(5) AS codret,CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE cBanDetError CHAR(1);
	DEFINE iTotal INTEGER;
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cFechaHoraArchivo CHAR(35);
	DEFINE ctabname CHAR(128);
	DEFINE pRutaDescarga CHAR(100);
	
	DEFINE iContador INTEGER;
	DEFINE dFechaRef DATE;
	DEFINE cNumcte CHAR(20);
	DEFINE cNumSol CHAR(20);
	DEFINE dFechaSol DATE;
	DEFINE dUltimaFecha DATE;
	DEFINE iHuellaDecActual INTEGER;
	DEFINE dFechaHueDecAct DATETIME YEAR TO SECOND;
	DEFINE iHuellaDec  INTEGER;
	DEFINE iHuella  INTEGER;
	DEFINE cSucursal CHAR(4);
	DEFINE cProducto CHAR(4);
	DEFINE cNumIdINE CHAR(30);
	DEFINE dFechaNumIdINE DATE;
	DEFINE dFechaDatosGen DATE;
	DEFINE dFechaStatus DATE;
	DEFINE dFechaDir1 DATE;
	DEFINE dFechaDir2 DATE;
	DEFINE iValidaParam INTEGER;
	DEFINE dFechaStatSol DATE;
	DEFINE cStatSol CHAR(2);
	DEFINE dFechaEvaBuro DATE;
	DEFINE dFechaMC DATE;
	DEFINE dFechaOS DATE;
	DEFINE dFechaCAC DATE;
	DEFINE cStatusSol CHAR(2);
	DEFINE dFechaAT  DATE;
	DEFINE dFechaExpAlta DATE;
	DEFINE dFechaDocAP DATE;
	DEFINE dFechaComple DATE;
	DEFINE dFechaHueDec DATETIME YEAR TO SECOND;
	DEFINE dFechaCteHue DATE;
	DEFINE dFechaBioFac DATETIME YEAR TO SECOND;
	DEFINE dFechaAltaCte DATE;
	DEFINE cTipoCte CHAR(1);
	DEFINE dFechaCteTit DATE;
	DEFINE dFechaPol DATE;
	DEFINE dFechaCapRef DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cBanDetError = 'f';
	LET iTotal = 0;
	LET dFechaHoy ='';
	LET dHoraHoy = '';
	LET cFechaHoraArchivo='';
	LET ctabname ='';
	LET pRutaDescarga ='/resplogifx/archivoscartera/';
	
	LET iContador =0;
	LET cNumcte = '';
	LET cNumSol = '';
	LET dFechaSol ='';
	LET dUltimaFecha ='';
	LET iHuellaDecActual = 0;
	LET iHuellaDec = 0;
	LET iHuella = 0;
	LET cSucursal='';
	LET dFechaHueDecAct = '';
	LET cProducto ='';
	LET cNumIdINE = '';
	LET dFechaNumIdINE = '';
	LET dFechaDatosGen='';
	LET cStatusSol ='';
	LET dFechaStatus ='';
	LET dFechaDir1 = '';
	LET dFechaDir2 ='';
	LET iValidaParam = 0;
	LET dFechaStatSol ='';
	LET cStatSol='';
	LET dFechaEvaBuro ='';
	LET dFechaMC ='';
	LET dFechaOS ='';
	LET dFechaCAC ='';
	LET dFechaAT ='';
	LET dFechaExpAlta ='';
	LET dFechaDocAP ='';
	LET dFechaComple ='';
	LET dFechaHueDec ='';
	LET dFechaCteHue ='';
	LET dFechaBioFac ='';
	LET dFechaAltaCte ='';
	LET cTipoCte ='';
	LET dFechaCteTit ='';
	LET dFechaRef =DATE(1);
	LET dFechaPol ='';
	LET dFechaCapRef = '';
	
	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
			IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
			
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;      

		--SET DEBUG FILE TO '/home/e99804975/PruebaBatch/sp_rep_trazabilidad.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
								
		SELECT tabname
		INTO ctabname
		FROM systables
		WHERE tabname = 'sw_rep_traza_tmp';

		IF NVL(ctabname,'') <> '' THEN
			--DROP INDEX bdisolic:"informix".idx_sw_rep_traza_tmp;
			DROP TABLE bdisolic:"informix".sw_rep_traza_tmp;
		END IF;

		CREATE TABLE bdisolic:"informix".sw_rep_traza_tmp(
																id SERIAL,
																movimiento INTEGER,
																sucursal CHAR(4),
																fecha_hora DATETIME YEAR TO SECOND,
																operacion CHAR(60),
																producto CHAR (4),
																num_solicitud CHAR (20),
																estatus CHAR (2),
																PRIMARY KEY (id)
		);
		--CREATE INDEX "informix".idx_sw_rep_traza_tmp ON "informix".sw_rep_traza_tmp
		--(id) USING btree;
		
		FOREACH WITH HOLD	
		--select numcte, num_solicitud,fecha INTO cNumcte,cNumSol,dFechaSol from "informix".ss_prospecteo_solicitudes where canal_sol = '4' and fecha = TODAY-1
			select limit 20 p.numcte, p.num_solicitud,p.fecha,p.num_producto,s.sucursal
			INTO cNumcte,cNumSol,dFechaSol,cProducto,cSucursal 
			from ss_solicitudes s 
			inner join "informix".ss_prospecteo_solicitudes p on s.numcte = p.numcte and s.num_solicitud = p.num_solicitud
			where s.sucursal ='8503' and s.canal_sol='4' and s.num_producto in ('6500','6001') and s.fecha_insert = TODAY-1
			
			
			/*select first 20 p.numcte, p.num_solicitud,p.fecha,p. num_producto 
			INTO cNumcte,cNumSol,dFechaSol,cProducto  
			from "informix".ss_prospecteo_solicitudes p
			where p.canal_sol =4 
			*/
			
		--select first 20 numcte, num_solicitud,fecha,num_producto INTO cNumcte,cNumSol,dFechaSol,cProducto  from "informix".ss_prospecteo_solicitudes where num_solicitud='650571772997'
		 		
		--Busca sucursal
		--select suc_martriz INTO cSucursal from bdinteg:"informix".si_sucmatriz where numcte =cNumcte;	
		
		-----------------------
		------Valida INE-------
		
		select numidentifi,fecha_INSERT INTO cNumIdINE,dFechaNumIdINE  from bdinteg:"informix".si_ctepf where numcte =cNumcte and fecha_insert >=dFechaSol ;
		
		IF NVL(dFechaNumIdINE::DATE,'') > dFechaRef THEN 
			LET iContador = iContador +1;
			LET dUltimaFecha = dFechaNumIdINE;
			INSERT INTO "informix".sw_rep_traza_tmp VALUES (0,iContador,cSucursal,dUltimaFecha,'Validacion de INE',cProducto,cNumSol,'AT');
		END IF;
		
		----------------------------
		------Datos generales-------
		
		select fecha_alta INTO dFechaDatosGen  from bdinteg:"informix".si_cliente where numcte =cNumcte and fecha_alta >=dFechaSol;
		
		IF NVL(dFechaDatosGen::DATE,'') > dFechaRef THEN 
			LET iContador = iContador +1;
			LET dUltimaFecha = dFechaDatosGen;
			INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Datos Generales',cProducto,cNumSol,'AT');
		END IF;
		
		----------------------------
		------Oferta producto-------
		--select status_solicitud,fecha_INSERT INTO cStatusSol,dFechaStatus from bdisolic:"informix".ss_solicitudes where numcte =cNumcte and fecha_insert = TODAY-1 and canal_sol ='4';
		select FIRST 1 status_solicitud,fecha_INSERT INTO cStatusSol,dFechaStatus from bdisolic:"informix".ss_solicitudes where numcte =cNumcte and canal_sol = '4' and year (fecha_insert) =2023;
		
		IF (cStatusSol) <>'AP' THEN
			LET iContador = iContador +1;
			LET dUltimaFecha = dFechaStatus;
			INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Oferta Producto',cProducto,cNumSol,cStatusSol);
		END IF;
 
		
		----------------------------
		------Direccion-------------
		select first 1 fecha_INSERT INTO dFechaDir1 from bdinteg:"informix".si_direcciones where numcte =cNumcte and fecha_insert >=dFechaSol ;
		
		IF NVL(dFechaDir1::DATE,'') > dFechaRef THEN 
			LET iContador = iContador +1;
			LET dUltimaFecha = dFechaDir1;
			INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Direccion',cProducto,cNumSol,'AT');
		ELSE 
			select first 1 fecha_INSERT INTO dFechaDir2 from bdinteg:"informix".si_direcciones_actual where numcte =cNumcte and fecha_insert >=dFechaSol ;
			IF NVL(dFechaDir2::DATE,'') > dFechaRef THEN 
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaDir2;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Direccion',cProducto,cNumSol,'AT');
			END IF;
		END IF;
		
		------------------------------------------------------------
		------Registro de personas politicamente expuestas----------
		
		select FIRST 1 fecha_INSERT INTO dFechaPol from bdinteg:"informix".si_cteppes  where numcte =cNumcte and fecha_insert >=dFechaSol;
		
		IF NVL(dFechaPol::DATE,'') > dFechaRef THEN 
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaPol;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Registro de personas politicamente expuestas',cProducto,cNumSol,cStatusSol);
		END IF;
		
		--------------------------------
		------Captura referencias-------
		select FIRST 1 fecha_INSERT INTO dFechaCapRef from bdinteg:"informix".si_refclientes where numcte =cNumcte and num_solicitud = cNumSol and fecha_insert >= dFechaSol ;

		IF NVL(dFechaCapRef::DATE,'') > dFechaRef THEN 
			LET iContador = iContador +1;
			LET dUltimaFecha = dFechaCapRef;
			INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Captura de referencias',cProducto,cNumSol,'AT');
		END IF;
		
		-----------------------------------
		------Validacion parametrico-------
		select count(*) INTO iValidaParam from bdinteg:"informix".si_refclientes where numcte =cNumcte and num_solicitud = cNumSol and fecha_insert >= dFechaSol ;

		IF NVL(iValidaParam,0) >= 16 THEN 
			LET iContador = iContador +1;
			INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Validacion Parametrico',cProducto,cNumSol,'AT');
		END IF;
		
		-----------------------------
		------Alta solicitud---------
		select status_solicitud,fecha INTO cStatSol,dFechaStatSol  from "informix".ss_prospecteo_solicitudes where num_solicitud = cNumSol;

		IF NVL(cStatSol,'') = '' THEN 
			LET cStatSol = cStatusSol;
		
		END IF;
		
		IF cStatSol NOT IN ('IN','PA') THEN 
			LET iContador = iContador +1;
			
			LET dUltimaFecha = dFechaStatSol;
			
			INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Alta Solicitud',cProducto,cNumSol,cStatSol);
		END IF;
		
		
		-----------------------------
		------Evaluacion buro--------
		select FIRST 1 b.fecha_INSERT INTO dFechaEvaBuro  from bdisolic:"informix".ss_solicitudes_sic a inner join bdiburo:"informix".br_respuesta b on a.num_solicitud_sic=b.num_solicitud where a.num_solicitud_sic=cNumSol and a.numcte=cNumcte;

		IF NVL(dFechaEvaBuro::DATE,'') > dFechaRef THEN 
			 
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaEvaBuro;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Evaluacion Buro',cProducto,cNumSol,cStatSol);
 
		END IF;
		
		-----------------------------
		------Validacion MC----------
		select FIRST 1 fecha_INSERT INTO dFechaMC  from bdisolic:"informix".ss_solicitudes_mc where num_solicitud=cNumSol;

		IF NVL(dFechaMC::DATE,'') > dFechaRef THEN 
			 
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaMC;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Validacion en mesa de control',cProducto,cNumSol,cStatSol);
 
		END IF;
		
		-----------------------------
		------Validacion OS----------
		select FIRST 1 fecha_solicitud INTO dFechaOS  from bdisolic:"informix".ss_solicitud_os where num_solicitud=cNumSol;

		IF NVL(dFechaOS::DATE,'') > dFechaRef THEN 
			 
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaOS;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Validacion en orden de supervision de calle',cProducto,cNumSol,cStatSol);
 
		END IF;
		
		-----------------------------
		------Validacion CAC---------
		select FIRST 1 fecha_insert INTO dFechaCAC  from bdisolic:"informix".ss_solicitudes_cac where num_solicitud=cNumSol;

		IF NVL(dFechaCAC::DATE,'') > dFechaRef THEN 
			 
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaCAC;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Validacion en revision de linea superior',cProducto,cNumSol,cStatSol);
 
		END IF;
		
		------------------------------
		------Validacion AT/RT--------
		select first 1  status_solicitud,fecha_insert INTO cStatusSol,dFechaAT from bdisolic:"informix".ss_autorizacion where num_solicitud=cNumSol and status_solicitud IN('AT','RT') ;
		
		IF NVL(dFechaAT::DATE,'') > dFechaRef THEN 
			 
			LET iContador = iContador +1;
			LET dUltimaFecha = dFechaAT;
							
			IF cStatusSol ='AT' THEN
			
			INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'AUTORIZADA',cProducto,cNumSol,cStatusSol);
		
			ELSE
		
			INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'RECHAZADA',cProducto,cNumSol,cStatusSol);
			
			LET iContador = 0;
			CONTINUE FOREACH;
		
			END IF;
				
		END IF;
		
		-----------------------------------------
		------Expediente alta solicitud ---------
		select FIRST 1 fecha_alta  INTO dFechaExpAlta  from bdidigital@coppelimg_tcp:"informix".dg_expediente where cliente =cNumcte and cod_docto in (

		select cod_docto from bdidigital@coppelimg_tcp:"informix".dg_tipodocumento where cod_docto in (select cod_docto from bdidigital@coppelimg_tcp:"informix".dg_definicion_det where cod_definicion='103'));
		
		IF NVL(dFechaExpAlta::DATE,'') > dFechaRef THEN 
			 
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaExpAlta;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Expediente completo de alta de solicitud',cProducto,cNumSol,cStatSol);
 
		END IF;
		
		-----------------------------------
		------Documentos apertura ---------
		select FIRST 1 fecha_alta INTO dFechaDocAP  from bdidigital@coppelimg_tcp:"informix".dg_expediente where cliente =cNumcte and cod_docto in (

		select cod_docto from bdidigital@coppelimg_tcp:"informix".dg_tipodocumento where cod_docto in (select cod_docto from bdidigital@coppelimg_tcp:"informix".dg_definicion_det where cod_definicion='104'));
		
		IF NVL(dFechaDocAP::DATE,'') > dFechaRef THEN 
			 
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaDocAP;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Digitalizacion de documentos para apertura',cProducto,cNumSol,cStatSol);
 
		END IF;

		-----------------------------------------------
		------Datos generales complementarios ---------
		select FIRST 1 fecha_actualiza INTO dFechaComple  from bdinteg:"informix".si_telefonos where numcte=cNumcte;

		IF NVL(dFechaComple::DATE,'') > dFechaRef THEN 
			 
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaComple;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Datos generales complementarios',cProducto,cNumSol,cStatSol);
 
		END IF;
		
		------------------------------------------
		------Registro biometricos dactilar ------
		
		--Busca Registro de 4 dedos 
		select first 1 fecha_INSERT INTO dFechaHueDecAct  from bdinteg:"informix".si_cte_huella_dec_actual where numcte =cNumcte and fecha_insert >=dFechaSol;

		IF NVL(dFechaHueDecAct::DATE,'') > dFechaRef THEN 
			LET iContador = iContador +1;
			LET dUltimaFecha = dFechaHueDecAct;
			INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Registro de bimetricos (dactilar)',cProducto,cNumSol,cStatSol);
		
		ELSE
		
			--Busca Registro de 4 dedos 
			select first 1 fecha_insert INTO dFechaHueDec  from bdinteg:"informix".si_cte_huella_dec where numcte =cNumcte and fecha_insert >=dFechaSol;
			
			IF NVL(dFechaHueDec::DATE,0) > 0 THEN
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaHueDec;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Registro de bimetricos (dactilar)',cProducto,cNumSol,cStatSol);
			ELSE
				--Busca Registro unidactilar
				select first 1 fecha_alta INTO dFechaCteHue  from bdinteg:"informix".si_cte_huella where numcte =cNumcte and fech_ult_camb >=dFechaSol;
				
				IF NVL(dFechaCteHue::DATE,0) > 0 THEN
					LET iContador = iContador +1;
					LET dUltimaFecha = dFechaCteHue;
					INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Registro de bimetricos (dactilar)',cProducto,cNumSol,cStatSol);				
				END IF;

			END IF;
			
		END IF;
		
		------------------------------------------
		------Registro biometricos facial --------
		select first 1 fech_ult_camb INTO dFechaBioFac from bdinteg:"informix".si_cte_rostro where numcte=cNumcte and fech_ult_camb >=dFechaSol;

		IF NVL(dFechaBioFac::DATE,'') > dFechaRef THEN 
			 
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaBioFac;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Registro de bimetricos (facial)',cProducto,cNumSol,cStatSol);
 
		END IF;
		
		-----------------------------------------
		------Expediente alta de cliente---------
		select FIRST 1 fecha_alta INTO dFechaAltaCte from bdidigital@coppelimg_tcp:"informix".dg_expediente  where cliente =cNumcte and cod_docto in (

		select cod_docto from bdidigital@coppelimg_tcp:"informix".dg_tipodocumento where cod_docto in (select cod_docto from bdidigital@coppelimg_tcp:"informix".dg_definicion_det where cod_definicion='104'));
		
		IF NVL(dFechaAltaCte::DATE,'') > dFechaRef THEN 
			 
				LET iContador = iContador +1;
				LET dUltimaFecha = dFechaAltaCte;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Validacion de expediente completo de alta cliente',cProducto,cNumSol,cStatSol);
 
		END IF;

		------------------------------------------------
		------Registro del cliente como titular --------
		select tipo_cliente,fecha_alta INTO cTipoCte,dFechaCteTit from bdinteg:"informix".si_cliente where numcte=cNumcte and fecha_alta >=dFechaSol;

		IF NVL(dFechaCteTit::DATE,'') > dFechaRef THEN 
			 
				IF cTipoCte ='1' THEN 
					LET iContador = iContador +1;
				LET dUltimaFecha = dFechaCteTit;
				INSERT INTO "informix".sw_rep_traza_tmp  VALUES(0,iContador,cSucursal,dUltimaFecha,'Registro del cliente como titular',cProducto,cNumSol,'AP');
				END IF;
		END IF;
		
		LET iContador = 0;

		END FOREACH; 
		
 
		SELECT COUNT(*) INTO iTotal FROM "informix".sw_rep_traza_tmp;
		
		IF iTotal = 0 THEN			
			LET cCodRet ='00002'; --NO HAY DATOS PARA GENERAR EL REPORTE			
		END IF;
		
		
        IF cCodRet='00000' THEN 
		--GENERACION DE REPORTE	
			LET cCmd1 ="";
			LET cCmd1 ="SELECT 'NO. MOVIMIENTO','NO. SUCURSAL','FECHA Y HORA (FIN DE ETAPA)','OPERACION OFI','PRODUCTO','NUMERO DE SOLICITUD','ESTATUS' FROM systables  WHERE tabid = 1 ";
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM ( ";
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT movimiento::CHAR(11),''''||sucursal,LPAD(DAY(fecha_hora),2,0)||'/'||LPAD(MONTH(fecha_hora),2,0)||'/'||YEAR(fecha_hora)||' '||TO_CHAR(fecha_hora, '%H:%M:%S'),operacion,producto,num_solicitud,estatus FROM ""informix"".sw_rep_traza_tmp  ORDER BY id)"; 
			
			LET dFechaHoy = CURRENT;
			LET dHoraHoy = CURRENT;
			
			LET cFechaHoraArchivo = TO_CHAR(dFechaHoy, '%d%m%Y')||"_"||TO_CHAR(dHoraHoy, '%H%M%S');
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR	
					
			LET cNombreArchivo = 'REP_TRAZA_'||TRIM(cFechaHoraArchivo)||'.xls';

			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);
			LET cRutaGral = cRutaGral;
			
                BEGIN WORK;
                    LET ven_transacc = 1;

                    LET cSql = '';

					LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '|| '''	'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';

					
                    SYSTEM TRIM(cSql);

                    LET cSql = '';
                    LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
                    SYSTEM TRIM(cSql);

                    LET cSql = '';
                    --RUTA PRUEBAS
					--LET cSql = '/informix/bin/dbaccess bdisolic '||TRIM(pRutaDescarga)||'query.sql';
					--RUTA PRODUCTIVA
					LET cSql = '/ifxsif01/bin/dbaccess bdisolic '||TRIM(pRutaDescarga)||'query.sql';
                    SYSTEM TRIM(cSql);
                    LET cSql = '';
                    LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
                    SYSTEM TRIM(cSql);

                    -- Se manipula el archivo para agregar el salto de linea
                    LET cSql = '';
                    LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                    SYSTEM TRIM(cSql);

                    LET cSql = '';
                    LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                    SYSTEM TRIM(cSql);

                    -- Eliminamos el archivo original
                    LET cSql = '';
                    LET cSql = "rm -rf "||TRIM(cRutaGral);
                    SYSTEM TRIM(cSql);

                    LET cSql = '';
                    LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                    SYSTEM TRIM(cSql);

                    -- Eliminamos el caracter delimitador ';' al final de la linea
                    LET cSql = '';
                    LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                    SYSTEM TRIM(cSql);

                    -- Se manipula el archivo para agregar el salto de linea
                    LET cSql = '';
                    LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                    SYSTEM TRIM(cSql);

                    LET cSql = '';
                    LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                    SYSTEM TRIM(cSql);

                    LET cSql = '';
                    LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                    SYSTEM TRIM(cSql);

                    LET cSql = '';
                    LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                    SYSTEM TRIM(cSql);

                    LET cSql = '';
                    LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                    SYSTEM TRIM(cSql);

                       		   
					LET cBanDetError = 't';

				COMMIT WORK;
				LET ven_transacc = 0;
                IF bInTransaction = 't' THEN
                    BEGIN WORK;
				END IF;
				 
	    END IF;
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
