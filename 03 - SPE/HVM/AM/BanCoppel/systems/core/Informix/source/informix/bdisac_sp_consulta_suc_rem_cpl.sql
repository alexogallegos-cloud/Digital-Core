CREATE PROCEDURE "informix".sp_consulta_suc_rem_cpl(pConfirmationNm CHAR(12), idSuc CHAR(4))
	
RETURNING CHAR(5) AS codret;

DEFINE cCod_ret     CHAR(5);
DEFINE iSqlErr      INTEGER;
DEFINE sucExiste    INTEGER;
DEFINE convActivo	CHAR(1);

LET cCod_ret        ='00000';
LET iSqlErr         = 0;
LET sucExiste       = 0;
LET convActivo		='';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCod_ret = iSqlErr;
				RETURN cCod_ret;	
				--RETURN bandera;	
			END IF;
		END EXCEPTION;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/informix/noe/sp_consulta_suc_rem_cpl.out';
		--TRACE ON;
        /*
            BTS long: 11 prefijos 117 al 188 y 319
            APPRIZA Long: 12 prefijos 700, 701, 702, 703 y 710
            
            WU: Long:10 prefijos <> 708, 972 y 973
            Orlandi Valuta Long: 10 prefijos 708
            Vigo: Long: 10 prefijos 972 y 973        
        */

        IF LENGTH(TRIM(idSuc)) = 0 OR NVL(TRIM(idSuc),'') = '' THEN

            LET cCod_ret = '07001';

        ELSE
			IF NVL(TRIM(idSuc),'') <> '5011' THEN			
				SELECT COUNT(*) INTO sucExiste FROM bdinteg:"informix".si_ptf WHERE id_ptf=TRIM(idSuc) and tipo='S' AND clave_sit not in('B');
				IF sucExiste = 0 THEN
					LET cCod_ret = '07002';
				END IF;				
			END IF;			
			
			IF LENGTH(TRIM(pConfirmationNm)) = 11 THEN
				LET convActivo = (SELECT trim(statusconvenio) FROM "informix".sac_convenios where numcategoria='07' and numconvenio='004');
			ELSE
				IF LENGTH(TRIM(pConfirmationNm)) = 12 OR  LENGTH(TRIM(pConfirmationNm)) = 8 THEN
					LET convActivo = (SELECT trim(statusconvenio) FROM "informix".sac_convenios where numcategoria='07' and numconvenio='009');
				ELSE
					IF LENGTH(TRIM(pConfirmationNm)) = 10 THEN
						IF SUBSTR(TRIM(pConfirmationNm),1,3) NOT IN('708','972','973') THEN
							LET convActivo = (SELECT trim(statusconvenio) FROM "informix".sac_convenios where numcategoria='07' and numconvenio='006');
						END IF;
						IF SUBSTR(TRIM(pConfirmationNm),1,3) IN('708') THEN
							LET convActivo = (SELECT trim(statusconvenio) FROM "informix".sac_convenios where numcategoria='07' and numconvenio='007');
						END IF;
						IF SUBSTR(TRIM(pConfirmationNm),1,3) IN('972','973') THEN
							LET convActivo = (SELECT trim(statusconvenio) FROM "informix".sac_convenios where numcategoria='07' and numconvenio='008');
						END IF;
					ELSE
						LET convActivo = 'I';
					END IF;
				END IF;
			END IF;

            IF convActivo <> 'A' THEN
            	LET cCod_ret = '07003'; --Convenio Inactivo
            END IF;

        END IF;

        RETURN cCod_ret;

	END
END PROCEDURE

DOCUMENT
'AUTOR: Mario Gallardo',
'FOLIO: Iniciatica Cobro de Remesas FSF',
'DESCRIPCION: Se omite sucursal 5011 en validacion',
'FECHA: 07/03/2022',
'-----------------------------',
'AUTOR: Noe Medina R.',
'FOLIO: ',
'DESCRIPCION: Valida el nÃºmero de Sucursal enviado en la solicitud de Consulta de HRemesas',
'FECHA: 29/01/2020',
'VERSION: 20200129.1102',
'BD:Bdisac';

CREATE PROCEDURE "informix".sp_sac_rep_sem_remesas(pfecharepor DATE, pDiasProceso INTEGER)
RETURNING CHAR(5) AS iCodRet,
	char(50) as iMensaje;
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cInfoErr CHAR(100);
DEFINE iCodRet CHAR(5);
DEFINE iMensaje CHAR(50);
DEFINE cRutaArch CHAR(100);

DEFINE cConteoAPP INTEGER;
DEFINE cConteoBTS INTEGER;
DEFINE cConteoOVA INTEGER;
DEFINE cConteoVIG INTEGER;
DEFINE cConteoWUN INTEGER;

DEFINE cStmt CHAR (500);
DEFINE cConteoREM VARCHAR(50);
DEFINE cDiaActual DATE;
DEFINE cDia CHAR(2);
DEFINE cMes CHAR(2);
DEFINE cAnio CHAR(4);

DEFINE vfecha_proceso DATE;
DEFINE vfecha_procesoI DATE;
DEFINE vfecha_procesoF DATE;
DEFINE vValida INTEGER;
DEFINE vValida2 INTEGER;

--SET DEBUG FILE TO '/informix/ENP/reporteRemesas/sp_sac_rep_sem_remesas.out';
--TRACE ON;

-- Inicializa variables
LET cCodRet = '00000';
LET cInfoErr = '';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET iCodRet = "00000";
LET iMensaje = '';
LET cRutaArch = '';

LET iSqlErr = 0;
LET cConteoAPP = 0;
LET cConteoBTS = 0;
LET cConteoOVA = 0;
LET cConteoWUN = 0;

LET cStmt = '';
LET cConteoREM = '0';
LET cDiaActual = MDY('01', '01', '1900');
LET cDia = '';
LET cMes = '';
LET cAnio = '';

LET vfecha_proceso = pfecharepor;
LET vfecha_procesoF = pfecharepor;
LET vfecha_procesoI = pfecharepor - pDiasProceso;
LET vValida = 0;
LET vValida2 = 0;

BEGIN 
		ON EXCEPTION
			SET iSqlErr IF (iSqlErr != 0) THEN LET iCodRet = iSqlErr;
			LET iMensaje = "Proceso NO Exitoso Error BD.";
			IF cRutaArch IS NOT NULL
			OR cRutaArch <> "" THEN LET cStmt = 'rm -f ' || cRutaArch;
			SYSTEM cStmt;
			END IF;
			
			DROP TABLE IF EXISTS tmp_sac_rem_VOW_101538;
			DROP TABLE IF EXISTS tmp_sac_rem_BTS_101538;
			DROP TABLE IF EXISTS tmp_sac_rem_APP_101538;
			DROP TABLE IF EXISTS tmp_sac_rem_BTS_CD_101538;
			DROP TABLE IF EXISTS tmp_sac_rem_VOW_CD_101538;
			DROP TABLE IF EXISTS tmp_sac_totalRemesas_101538;
			
			RETURN iCodRet,
			iMensaje;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		DROP TABLE IF EXISTS tmp_sac_rem_VOW_101538;
		DROP TABLE IF EXISTS tmp_sac_rem_BTS_101538;
		DROP TABLE IF EXISTS tmp_sac_rem_APP_101538;
		DROP TABLE IF EXISTS tmp_sac_rem_BTS_CD_101538;
		DROP TABLE IF EXISTS tmp_sac_rem_VOW_CD_101538;
		DROP TABLE IF EXISTS tmp_sac_totalRemesas_101538;

		SELECT fecha_hoy INTO cDiaActual
		FROM bdisac :sac_fechas
		WHERE empresa = "001";

		LET cDia = LPAD(DAY(cDiaActual::DATE), 2, '0');
		LET cMEs = LPAD(MONTH(cDiaActual::DATE), 2, '0');
		LET cAnio = LPAD(YEAR(cDiaActual::DATE), 4, '0');
		LET cRutaArch = '/RESPALDOSNEW/sac_reporteSemanal.csv';
		LET cRutaArch = REPLACE(cRutaArch, 'AAAA', cAnio);
		LET cRutaArch = REPLACE(cRutaArch, 'MM', cMes);
		LET cRutaArch = REPLACE(cRutaArch, 'DD', cDia);
		LET cStmt = 'rm -f ' || cRutaArch;
		SYSTEM cStmt;
		---Trae unicamente las remesas pagadas en ventanilla 
		
			--REMESAS VIG' 'OVA' 'WUN--
			SELECT fecha_proceso,
				tipo_remesa,
				COUNT(*) AS num_remesa,
				cod_edo_remitente,
				cd_remitente,
				beneficiario_estado,
				beneficiario_ciudad
			FROM sac_pld_remesas 
			WHERE fecha_proceso BETWEEN vfecha_procesoI
				AND vfecha_procesoF
				AND sucursal NOT IN ('9250', '9251', '9764')
				AND tipo_remesa in ('VIG','OVA','WUN')
				AND cod_pais_origen = 'US'
				AND beneficiario_ciudad <> 'DISTRITO FEDERAL'
			GROUP BY tipo_remesa,
				fecha_proceso,
				cod_edo_remitente,
				cd_remitente,
				beneficiario_estado,
				beneficiario_ciudad 
			INTO TEMP tmp_sac_rem_VOW_101538 WITH NO LOG;

			--REMESAS VIG' 'OVA' 'WUN  (DF)--
			SELECT  fecha_proceso,
				tipo_remesa,
				COUNT(*) AS num_remesa,
				cod_edo_remitente,
				cd_remitente,
				beneficiario_ciudad as beneficiario_estado,
				beneficiario_mncpo_del AS beneficiario_ciudad
			FROM sac_pld_remesas 
			WHERE fecha_proceso BETWEEN vfecha_procesoI
				AND vfecha_procesoF
				AND sucursal NOT IN ('9250', '9251', '9764')
				AND tipo_remesa in ('VIG','OVA','WUN')
				AND cod_pais_origen = 'US'
				AND beneficiario_ciudad = 'DISTRITO FEDERAL'
			GROUP BY tipo_remesa,
				fecha_proceso,
				cod_edo_remitente,
				cd_remitente,
                beneficiario_mncpo_del,
				beneficiario_estado,
                beneficiario_ciudad
			INTO TEMP tmp_sac_rem_VOW_CD_101538 WITH NO LOG;
			
			--REMESAS BTS--

			SELECT fecha_proceso,
				tipo_remesa,
				COUNT(*) AS num_remesa,
				cod_edo_remitente,
				cd_remitente,
				beneficiario_ciudad as beneficiario_estado,
				beneficiario_estado AS beneficiario_ciudad
			FROM sac_pld_remesas 
			WHERE fecha_proceso BETWEEN vfecha_procesoI
				AND vfecha_procesoF
				AND sucursal NOT IN ('9250', '9251', '9764')
				AND tipo_remesa = 'BTS'
				AND cod_pais_origen = 'USA'
				AND beneficiario_ciudad <> 'DISTRITO FEDERAL'
			GROUP BY tipo_remesa,
				fecha_proceso,
				cod_edo_remitente,
				cd_remitente,
				beneficiario_estado,
                beneficiario_ciudad 
			INTO TEMP tmp_sac_rem_BTS_101538 WITH NO LOG;

			--REMESAS BTS  (DF)--
			
			SELECT  fecha_proceso,
				tipo_remesa,
				COUNT(*) AS num_remesa,
				cod_edo_remitente,
				cd_remitente,
				beneficiario_ciudad as beneficiario_estado,
				beneficiario_mncpo_del AS beneficiario_ciudad
			FROM sac_pld_remesas 
			WHERE fecha_proceso BETWEEN vfecha_procesoI
				AND vfecha_procesoF
				AND sucursal NOT IN ('9250', '9251', '9764')
				AND tipo_remesa = 'BTS'
				AND cod_pais_origen = 'USA'
				AND beneficiario_ciudad = 'DISTRITO FEDERAL'
			GROUP BY tipo_remesa,
				fecha_proceso,
				cod_edo_remitente,
				cd_remitente,
                beneficiario_mncpo_del,
				beneficiario_estado,
                beneficiario_ciudad
			INTO TEMP tmp_sac_rem_BTS_CD_101538 WITH NO LOG;

				--REMESAS APP--

			SELECT a.fecha_proceso,
				a.tipo_remesa,
				COUNT(*) AS num_remesa,
				a.cod_edo_remitente,
				a.cd_remitente,
				b.countrycode as beneficiario_estado,
				b.city AS beneficiario_ciudad
			FROM sac_pld_remesas a
            INNER JOIN sac_app_payi b ON a.num_confirmacion = b.unirefnum    
            	AND a.folio_sucursal = b.refnum
			WHERE fecha_proceso BETWEEN vfecha_procesoI
				AND vfecha_procesoF
				AND a.sucursal NOT IN ('9250', '9251', '9764')
				AND a.tipo_remesa = 'APP'
                AND a.cod_pais_origen = 'USA'
			GROUP BY a.tipo_remesa,
				a.fecha_proceso,
				a.cod_edo_remitente,
				a.cd_remitente,
				b.countrycode,
				b.city
			INTO TEMP tmp_sac_rem_APP_101538 WITH NO LOG;
		

			---CONSOLIDACION DE TABLAS 

				SELECT * FROM tmp_sac_rem_VOW_101538
				UNION
				SELECT * FROM tmp_sac_rem_BTS_101538
				UNION
				SELECT * FROM tmp_sac_rem_APP_101538
				UNION
				SELECT * FROM tmp_sac_rem_BTS_CD_101538
				UNION
				SELECT * FROM tmp_sac_rem_VOW_CD_101538
				INTO tmp_sac_totalRemesas_101538;

				DROP TABLE IF EXISTS tmp_sac_rem_VOW_101538;
				DROP TABLE IF EXISTS tmp_sac_rem_BTS_101538;
				DROP TABLE IF EXISTS tmp_sac_rem_APP_101538;
				DROP TABLE IF EXISTS tmp_sac_rem_BTS_CD_101538;
				DROP TABLE IF EXISTS tmp_sac_rem_VOW_CD_101538;

		SELECT COUNT(*) INTO vValida
		FROM tmp_sac_totalRemesas_101538;

		IF vValida <> 0 THEN 
			--GERNERA ARCHIVO CSV

			LET cRutaArch = '/RESPALDOSNEW/sac_reporteSemanal_DDMMAAAA.csv';
			LET cRutaArch = REPLACE(cRutaArch, 'AAAA', cAnio);
			LET cRutaArch = REPLACE(cRutaArch, 'MM', cMes);
			LET cRutaArch = REPLACE(cRutaArch, 'DD', cDia);

			LET cStmt = 'rm -f ' || cRutaArch;
			SYSTEM cStmt;

			LET vfecha_procesoF = vfecha_procesoF - 1;

			LET cStmt = 'echo "' || "REPORTE SEMANAL DE REMESAS " || vfecha_procesoI || " - " || vfecha_procesoF || '" >> ' || cRutaArch;
			SYSTEM cStmt;

			LET cStmt = 'echo "' || "FECHA" || "," || "REMESADORA" || "," || "NUMERO DE REMESAS" || "," || "ESTADO ORIGEN" || "," || "CIUDAD ORIGEN" || "," || "ESTADO DESTINO" || "," || "CIUDAD DESTINO" || '" >> ' || cRutaArch;
			SYSTEM cStmt;

			LET cStmt = 'echo "UNLOAD TO /RESPALDOSNEW/sac_reporteSemanal.csv  DELIMITER '','' SELECT * FROM tmp_sac_totalRemesas_101538 ;">/RESPALDOSNEW/reporteRemesas.sql';
			SYSTEM cStmt;

			let cStmt = 'dbaccess bdisac	/RESPALDOSNEW/reporteRemesas.sql';
			SYSTEM cStmt;

			SYSTEM 'tail -n +1 /RESPALDOSNEW/sac_reporteSemanal.csv >> ' || cRutaArch;

			LET cStmt = 'rm -f /RESPALDOSNEW/reporteRemesas.sql';
			SYSTEM cStmt;

			LET cStmt = 'rm -f /RESPALDOSNEW/sac_reporteSemanal.csv';
			SYSTEM cStmt;

			LET iCodRet = "00000";
			LET iMensaje = "Proceso Exitoso";
		ELSE 
			LET iCodRet = "00001";
			LET iMensaje = "Ejecucion sin registros Existentes";
		END IF;
		
		DROP TABLE IF EXISTS tmp_sac_totalRemesas_101538;
		
		
		RETURN iCodRet,
			   iMensaje;
		END;
END PROCEDURE;