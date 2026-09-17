CREATE PROCEDURE "informix".sp_actcatalogos_sitesp_prb() 
RETURNING CHAR(6);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cCadena  CHAR (500);
DEFINE cRuta CHAR (50);
DEFINE cCat1 CHAR (50);
DEFINE cCat2 CHAR (50);
DEFINE cCat3 CHAR (50);
DEFINE cCat4 CHAR (50);
DEFINE cCat5 CHAR (50);
DEFINE dtCatIni DATETIME YEAR TO SECOND;
DEFINE dtCatFin DATETIME YEAR TO SECOND;
DEFINE dtCat2Ini DATETIME YEAR TO SECOND;
DEFINE dtCat2Fin DATETIME YEAR TO SECOND;
DEFINE dtCat3Ini DATETIME YEAR TO SECOND;
DEFINE dtCat3Fin DATETIME YEAR TO SECOND;
DEFINE dtCat4Ini DATETIME YEAR TO SECOND;
DEFINE dtCat4Fin DATETIME YEAR TO SECOND;
DEFINE dtCat5Ini DATETIME YEAR TO SECOND;
DEFINE dtCat5Fin DATETIME YEAR TO SECOND;


DEFINE wBegin                CHAR(1);

LET iSqlErr = 0;
LET cCodRet = '000001';
LET cCadena = '';
LET cRuta = '';
LET cCat1 = '';
LET cCat2 = '';
LET cCat3 = '';
LET cCat4 = '';
LET cCat5 = '';
LET wBegin = '';
LET dtCatIni = CURRENT;
LET dtCatFin = CURRENT;
LET dtCat2Ini = CURRENT;
LET dtCat2Fin = CURRENT;
LET dtCat3Ini = CURRENT;
LET dtCat3Fin = CURRENT;
LET dtCat4Ini = CURRENT;
LET dtCat4Fin = CURRENT;
LET dtCat5Ini = CURRENT;
LET dtCat5Fin = CURRENT;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            IF ( wBegin = "S" ) THEN
    			ROLLBACK WORK;
            END IF;

			TRUNCATE TABLE bdinteg:"informix".si_cat_motivossitesp;
			TRUNCATE TABLE bdinteg:"informix".si_cat_personas;
			TRUNCATE TABLE bdinteg:"informix".si_cat_tipomovimiento;
			TRUNCATE TABLE bdinteg:"informix".si_cat_tipossituacionesp;
			TRUNCATE TABLE bdinteg:"informix".si_cat_situacionesespeciales;
			
			INSERT INTO bdinteg:"informix".si_cat_motivossitesp (id_motivo, clv_motivo, desc_motivo, clv_status)
			SELECT id_motivo, clv_motivo, desc_motivo, clv_status FROM bdinteg:"informix".si_cat_motivossitesp_hist 
			WHERE fecha_insert BETWEEN dtCatIni AND dtCatFin;
			
			INSERT INTO bdinteg:"informix".si_cat_personas (id_persona ,clv_persona ,desc_persona ,clv_status)
			SELECT id_persona, clv_persona, desc_persona, clv_status FROM bdinteg:"informix".si_cat_personas_hist
			WHERE fecha_insert BETWEEN dtCat2Ini AND dtCat2Fin;
			
			INSERT INTO bdinteg:"informix".si_cat_tipomovimiento (idu_tipomovimiento, desc_tipomovimiento)
			SELECT idu_tipomovimiento, desc_tipomovimiento FROM bdinteg:"informix".si_cat_tipomovimiento_hist
			WHERE fecha_insert BETWEEN dtCat3Ini AND dtCat3Fin;
			
			INSERT INTO bdinteg:"informix".si_cat_tipossituacionesp (idu_tiposituacion, clv_tiposituacion, des_tiposituacion)
			SELECT idu_tiposituacion, clv_tiposituacion, des_tiposituacion FROM bdinteg:"informix".si_cat_tipossituacionesp_hist
			WHERE fecha_insert BETWEEN dtCat4Ini AND dtCat4Fin;
			
			INSERT INTO bdinteg:"informix".si_cat_situacionesespeciales (idu_situacion,clv_situacion,num_causasituacion,nom_descsituacion,num_jerarquia,
					   clv_statussit,clv_activo,clv_compra,clv_borrar,num_mesescat1,num_mesescat2,idu_tiposituacion,clv_actualizable,clv_marcarautomatico,
					   clv_desmarcarautomatico,num_diascambioestatus,num_mesesactualizadatos,num_mesesdepurar,idu_tipomovimiento)
			SELECT idu_situacion,clv_situacion,num_causasituacion,nom_descsituacion,num_jerarquia,
					clv_statussit,clv_activo,clv_compra,clv_borrar,num_mesescat1,num_mesescat2,idu_tiposituacion,clv_actualizable,clv_marcarautomatico,
					clv_desmarcarautomatico,num_diascambioestatus,num_mesesactualizadatos,num_mesesdepurar,idu_tipomovimiento FROM bdinteg:"informix".si_cat_situacionesespeciales_hist
			WHERE fecha_insert BETWEEN dtCat5Ini AND dtCat5Fin;
			
			DELETE FROM bdinteg:"informix".si_cat_motivossitesp_hist WHERE fecha_insert BETWEEN dtCatIni AND dtCatFin;
			DELETE FROM bdinteg:"informix".si_cat_personas_hist WHERE fecha_insert BETWEEN dtCat2Ini AND dtCat2Fin;
			DELETE FROM bdinteg:"informix".si_cat_tipomovimiento_hist WHERE fecha_insert BETWEEN dtCat3Ini AND dtCat3Fin;
			DELETE FROM bdinteg:"informix".si_cat_tipossituacionesp_hist WHERE fecha_insert BETWEEN dtCat4Ini AND dtCat4Fin;
			DELETE FROM bdinteg:"informix".si_cat_situacionesespeciales_hist WHERE fecha_insert BETWEEN dtCat5Ini AND dtCat5Fin;
			
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
   	
   SET LOCK MODE TO WAIT 3;

   SET DEBUG FILE TO '/resplogifx/archivoscartera/altaunica/sp_actcatalogos_sitesp.out';
   TRACE ON;

    LET wBegin = "N";

	SELECT valor INTO cCat1 FROM bdinteg:"informix".si_param WHERE cod_param = 360;
	SELECT valor INTO cCat2 FROM bdinteg:"informix".si_param WHERE cod_param = 361;
	SELECT valor INTO cCat3 FROM bdinteg:"informix".si_param WHERE cod_param = 362;
	SELECT valor INTO cCat4 FROM bdinteg:"informix".si_param WHERE cod_param = 363;
	SELECT valor INTO cCat5 FROM bdinteg:"informix".si_param WHERE cod_param = 364;
	SELECT valor INTO cRuta FROM bdinteg:"informix".si_param WHERE cod_param = 348;
	
	IF NVL(cRuta,'') <> '' THEN
			IF NVL(cCat1,'') <> '' AND NVL(cCat2,'') <> '' AND NVL(cCat3,'') <> '' AND NVL(cCat4,'') <> '' AND NVL(cCat5,'') <> ''THEN
				BEGIN WORK;
                LET wBegin = "S";
				LET dtCatIni = CURRENT;
				LET cCat1 = TRIM(cCat1)||'_'||YEAR(dtCatIni)||LPAD(MONTH(dtCatIni),2,0)||LPAD(DAY(dtCatIni),2,0)||'.txt';
				LET cCat2 = TRIM(cCat2)||'_'||YEAR(dtCatIni)||LPAD(MONTH(dtCatIni),2,0)||LPAD(DAY(dtCatIni),2,0)||'.txt';
				LET cCat3 = TRIM(cCat3)||'_'||YEAR(dtCatIni)||LPAD(MONTH(dtCatIni),2,0)||LPAD(DAY(dtCatIni),2,0)||'.txt';
				LET cCat4 = TRIM(cCat4)||'_'||YEAR(dtCatIni)||LPAD(MONTH(dtCatIni),2,0)||LPAD(DAY(dtCatIni),2,0)||'.txt';
				LET cCat5 = TRIM(cCat5)||'_'||YEAR(dtCatIni)||LPAD(MONTH(dtCatIni),2,0)||LPAD(DAY(dtCatIni),2,0)||'.txt';
				
				INSERT INTO bdinteg:"informix".si_cat_motivossitesp_hist (id_motivo, clv_motivo, desc_motivo, clv_status, fecha_insert)
				SELECT id_motivo, clv_motivo, desc_motivo, clv_status, CURRENT FROM bdinteg:"informix".si_cat_motivossitesp;
				DELETE FROM bdinteg:"informix".si_cat_motivossitesp;
				LET dtCatFin = CURRENT;
				
				LET dtCat2Ini = CURRENT;
				INSERT INTO bdinteg:"informix".si_cat_personas_hist(id_persona, clv_persona, desc_persona, clv_status, fecha_insert)
				SELECT id_persona, clv_persona, desc_persona, clv_status, CURRENT FROM bdinteg:"informix".si_cat_personas;
				DELETE FROM bdinteg:"informix".si_cat_personas;
				LET dtCat2Fin = CURRENT;
				
				LET dtCat3Ini = CURRENT;
				INSERT INTO bdinteg:"informix".si_cat_tipomovimiento_hist (idu_tipomovimiento, desc_tipomovimiento, fecha_insert)
				SELECT idu_tipomovimiento, desc_tipomovimiento, CURRENT FROM bdinteg:"informix".si_cat_tipomovimiento;
				DELETE FROM bdinteg:"informix".si_cat_tipomovimiento;
				LET dtCat3Fin = CURRENT;
				
				LET dtCat4Ini = CURRENT;
				INSERT INTO bdinteg:"informix".si_cat_tipossituacionesp_hist (idu_tiposituacion, clv_tiposituacion, des_tiposituacion, fecha_insert)
				SELECT idu_tiposituacion, clv_tiposituacion, des_tiposituacion, CURRENT FROM bdinteg:"informix".si_cat_tipossituacionesp;
				DELETE FROM bdinteg:"informix".si_cat_tipossituacionesp;
				LET dtCat4Fin = CURRENT;
				
				LET dtCat5Ini = CURRENT;
				INSERT INTO bdinteg:"informix".si_cat_situacionesespeciales_hist(idu_situacion,clv_situacion,num_causasituacion,nom_descsituacion,num_jerarquia,
							clv_statussit,clv_activo,clv_compra,clv_borrar,num_mesescat1,num_mesescat2,idu_tiposituacion,clv_actualizable,clv_marcarautomatico,
							clv_desmarcarautomatico,num_diascambioestatus,num_mesesactualizadatos,num_mesesdepurar,idu_tipomovimiento, fecha_insert)
				SELECT idu_situacion,clv_situacion,num_causasituacion,nom_descsituacion,num_jerarquia,
					   clv_statussit,clv_activo,clv_compra,clv_borrar,num_mesescat1,num_mesescat2,idu_tiposituacion,clv_actualizable,clv_marcarautomatico,
					   clv_desmarcarautomatico,num_diascambioestatus,num_mesesactualizadatos,num_mesesdepurar,idu_tipomovimiento, CURRENT
				FROM bdinteg:"informix".si_cat_situacionesespeciales;
				DELETE FROM bdinteg:"informix".si_cat_situacionesespeciales;
				LET dtCat5Fin = CURRENT;
                
                COMMIT WORK;
                LET wBegin = "N";

--				BEGIN WORK;
				
				LET cCadena = '/usr/bin/echo "LOAD FROM ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cCat1,1,LENGTH(cCat1)) ||''' INSERT INTO bdinteg:"informix".si_cat_motivossitesp" >' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_motivossitesp.sql';
                --system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cCat1,1,LENGTH(cCat1));
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/ifxsif01/bin/dbaccess bdinteg ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_motivossitesp.sql';
				system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_motivossitesp.sql';
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/usr/bin/rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_motivossitesp.sql';
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena)); 
				
				LET cCadena = '';
				LET cCadena = '/usr/bin/echo "LOAD FROM ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cCat2,1,LENGTH(cCat2)) ||''' INSERT INTO bdinteg:"informix".si_cat_personas" >' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_personas.sql';
                --system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cCat2,1,LENGTH(cCat2)) ;
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/ifxsif01/bin/dbaccess bdinteg ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_personas.sql';
				system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_personas.sql';
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/usr/bin/rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_personas.sql';
				SYSTEM cCadena; 
				
				LET cCadena = '';
				LET cCadena = '/usr/bin/echo "LOAD FROM ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cCat3,1,LENGTH(cCat3)) ||''' INSERT INTO bdinteg:"informix".si_cat_tipomovimiento" >' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_tipomovimiento.sql';
                --system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cCat3,1,LENGTH(cCat3));
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/ifxsif01/bin/dbaccess bdinteg ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_tipomovimiento.sql';
				system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_tipomovimiento.sql';
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/usr/bin/rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_tipomovimiento.sql';
				SYSTEM cCadena;
				
				LET cCadena = '';
				LET cCadena = '/usr/bin/echo "LOAD FROM ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cCat4,1,LENGTH(cCat4)) ||''' INSERT INTO bdinteg:"informix".si_cat_tipossituacionesp" >' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_tipossituacionesp.sql';
                --system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cCat4,1,LENGTH(cCat4));
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/ifxsif01/bin/dbaccess bdinteg ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_tipossituacionesp.sql';
				system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_tipossituacionesp.sql';
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/usr/bin/rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_tipossituacionesp.sql';
				SYSTEM cCadena; 
				
				LET cCadena = '';
				LET cCadena = '/usr/bin/echo "LOAD FROM ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cCat5,1,LENGTH(cCat5)) ||''' INSERT INTO bdinteg:"informix".si_cat_situacionesespeciales" >' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_situacionesespeciales.sql';
                --system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cCat5,1,LENGTH(cCat5));
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/ifxsif01/bin/dbaccess bdinteg ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_situacionesespeciales.sql';
				system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_situacionesespeciales.sql';
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/usr/bin/rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'cat_situacionesespeciales.sql';
				SYSTEM cCadena; 
--				COMMIT WORK;
				LET cCodRet = '000000';
			ELSE
				LET cCodRet = '000002';
			END IF;
	END IF;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'AUTOR: Ivan Michel Valdez Rodriguez',
'FOLIO: 1746',
'DESCRIPCION: Se crea procedimiento almacenado para que modifique los catalogos de las situaciones especiales',
'FECHA: 13/08/2015',
'VERSION: 20150813.1632',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_actualiza_lugar_nac()
				returning CHAR(5) AS Cod_Retorno,INTEGER as Idreg;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE sRetCod          CHAR(5);
DEFINE IidErr			INTEGER;
DEFINE sCve_elector     CHAR(18);
DEFINE cNumcte          CHAR(20);

LET sCve_elector        = '';
LET cNumcte				= '';
LET iexiste				=0;
LET iSql_err				   =0;
LET sRetCod          	="99999";
LET cCodRet 			= "00000";
LET IidErr				=0;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,IidErr;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/VH/PM/sp_cnsif_consnumcte.out";
	--TRACE ON;
		

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	FOREACH
		SELECT {+  INDEX(bdinteg:si_solicitud_movil idx_movil_cveelector) } numcte,cve_elector INTO cNumcte,sCve_elector FROM si_solicitud_movil WHERE LENGTH(TRIM(cve_elector))=18 AND status_valua IS NOT NULL AND (numcte IS NOT NULL OR numcte<>'') 
		
		IF SUBSTR(TRIM(scve_elector),13,2) NOT IN('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
			LET sCve_elector        = '';
			LET cNumcte				= '';
		ELSE
			LET iexiste=0;
			SELECT COUNT(*) INTO iexiste FROM "informix".si_ctepf WHERE numcte=TRIM(cNumcte) and lugar_nac='';
			IF iexiste<>0 THEN
				UPDATE "informix".si_ctepf set lugar_nac=SUBSTR(TRIM(scve_elector),13,2) WHERE numcte=TRIM(cNumcte);
			END IF;
		END IF;
	END FOREACH;

	RETURN cCodRet,IidErr;
END
END PROCEDURE;