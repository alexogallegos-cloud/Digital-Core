CREATE PROCEDURE "informix".sp_actcatalogos_sitesp() 
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

DEFINE v_id_motivo INTEGER;
DEFINE v_clv_motivo CHAR(5);
DEFINE v_desc_motivo CHAR(50);
DEFINE v_clv_status INTEGER;

DEFINE v_id_motivo_his INTEGER;
DEFINE v_clv_motivo_his CHAR(5);
DEFINE v_desc_motivo_his CHAR(50);
DEFINE v_clv_status_mhis INTEGER;
DEFINE v_fecha_insert_mhis DATE;


DEFINE v_id_persona INTEGER;
DEFINE v_clv_persona CHAR(5);
DEFINE v_desc_persona CHAR(50);
DEFINE v_clv_status_p INTEGER;

DEFINE v_id_persona_his INTEGER;
DEFINE v_clv_persona_his CHAR(5);
DEFINE v_desc_persona_his CHAR(50);
DEFINE v_clv_status_phis INTEGER;
DEFINE v_fecha_insert_phis DATE;

DEFINE v_idu_tipomovimiento INTEGER; 
DEFINE v_desc_tipomovimiento CHAR(100);

DEFINE v_idu_tipomovimiento_this INTEGER; 
DEFINE v_desc_tipomovimiento_his CHAR(100);
DEFINE v_fecha_insert_this DATE;

DEFINE v_idu_tiposituacion INTEGER; 
DEFINE v_clv_tiposituacion CHAR(2);
DEFINE v_des_tiposituacion CHAR(50);

DEFINE v_idu_tiposituacion_shis INTEGER; 
DEFINE v_clv_tiposituacion_his CHAR(2);
DEFINE v_des_tiposituacion_his CHAR(50);
DEFINE v_fecha_insert_shis DATE;

DEFINE v_idu_situacion INTEGER;
DEFINE v_clv_situacion CHAR(1);
DEFINE v_num_causasituacion INTEGER;
DEFINE v_nom_descsituacion CHAR(250);
DEFINE v_num_jerarquia INTEGER;
DEFINE v_clv_statussit CHAR(1);
DEFINE v_clv_activo SMALLINT;
DEFINE v_clv_compra SMALLINT;
DEFINE v_clv_borrar SMALLINT;
DEFINE v_num_mesescat1 SMALLINT; 
DEFINE v_num_mesescat2 SMALLINT;
DEFINE v_idu_tiposituacion_se INTEGER;
DEFINE v_clv_actualizable INTEGER;
DEFINE v_clv_marcarautomatico INTEGER;
DEFINE v_clv_desmarcarautomatico INTEGER;
DEFINE v_num_diascambioestatus INTEGER;
DEFINE v_num_mesesactualizadatos INTEGER;
DEFINE v_num_mesesdepurar INTEGER;
DEFINE v_idu_tipomovimiento_se INTEGER;


DEFINE v_idu_situacion_his INTEGER;
DEFINE v_clv_situacion_his CHAR(1);
DEFINE v_num_causasituacion_his INTEGER;
DEFINE v_nom_descsituacion_his CHAR(250);
DEFINE v_num_jerarquia_his INTEGER;
DEFINE v_clv_statussit_his CHAR(1);
DEFINE v_clv_activo_his SMALLINT;
DEFINE v_clv_compra_his SMALLINT;
DEFINE v_clv_borrar_his SMALLINT;
DEFINE v_num_mesescat1_his SMALLINT; 
DEFINE v_num_mesescat2_his SMALLINT;
DEFINE v_idu_tiposituacion_sehis INTEGER;
DEFINE v_clv_actualizable_his INTEGER;
DEFINE v_clv_marcarautomatico_his INTEGER;
DEFINE v_clv_desmarcarautomatico_his INTEGER;
DEFINE v_num_diascambioestatus_his INTEGER;
DEFINE v_num_mesesactualizadatos_his INTEGER;
DEFINE v_num_mesesdepurar_his INTEGER;
DEFINE v_idu_tipomovimiento_sehis INTEGER;
DEFINE v_fecha_insert_sehis DATE;

DEFINE contador_commit   INTEGER;
DEFINE val_trans_Commit   SMALLINT;


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

LET v_id_motivo =0;
LET v_clv_motivo ='';
LET v_desc_motivo ='';
LET v_clv_status =0;

LET v_id_motivo_his =0;
LET v_clv_motivo_his ='';
LET v_desc_motivo_his ='';
LET v_clv_status_mhis =0;
LET v_fecha_insert_mhis =DATE(1);

LET v_id_persona =0;
LET v_clv_persona ='';
LET v_desc_persona ='';
LET v_clv_status_p =0;

LET v_id_persona_his =0;
LET v_clv_persona_his ='';
LET v_desc_persona_his ='';
LET v_clv_status_phis =0;
LET v_fecha_insert_phis =DATE(1);

LET v_idu_tipomovimiento=0; 
LET v_desc_tipomovimiento ='';

LET v_idu_tipomovimiento_this =0; 
LET v_desc_tipomovimiento_his ='';
LET v_fecha_insert_this =DATE(1);

LET v_idu_tiposituacion =0; 
LET v_clv_tiposituacion ='';
LET v_des_tiposituacion ='';

LET v_idu_tiposituacion_shis =0; 
LET v_clv_tiposituacion_his ='';
LET v_des_tiposituacion_his ='';
LET v_fecha_insert_shis= DATE(1);

LET v_idu_situacion =0;
LET v_clv_situacion ='';
LET v_num_causasituacion =0;
LET v_nom_descsituacion ='';
LET v_num_jerarquia =0;
LET v_clv_statussit ='';
LET v_clv_activo =0;
LET v_clv_compra =0;
LET v_clv_borrar =0;
LET v_num_mesescat1 =0; 
LET v_num_mesescat2 =0;
LET v_idu_tiposituacion_se =0;
LET v_clv_actualizable =0;
LET v_clv_marcarautomatico =0;
LET v_clv_desmarcarautomatico =0;
LET v_num_diascambioestatus =0;
LET v_num_mesesactualizadatos =0;
LET v_num_mesesdepurar =0;
LET v_idu_tipomovimiento_se =0;

LET v_idu_situacion_his =0;
LET v_clv_situacion_his ='';
LET v_num_causasituacion_his =0;
LET v_nom_descsituacion_his ='';
LET v_num_jerarquia_his =0;
LET v_clv_statussit_his ='';
LET v_clv_activo_his =0;
LET v_clv_compra_his =0;
LET v_clv_borrar_his =0;
LET v_num_mesescat1_his =0; 
LET v_num_mesescat2_his =0;
LET v_idu_tiposituacion_sehis =0;
LET v_clv_actualizable_his =0;
LET v_clv_marcarautomatico_his =0;
LET v_clv_desmarcarautomatico_his =0;
LET v_num_diascambioestatus_his =0;
LET v_num_mesesactualizadatos_his =0;
LET v_num_mesesdepurar_his =0;
LET v_idu_tipomovimiento_sehis =0;
LET v_fecha_insert_sehis =DATE(1);
LET contador_commit   =0;
LET val_trans_Commit  =0;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            IF ( wBegin = "S" ) THEN
    			ROLLBACK WORK;
            END IF;
            IF (val_trans_Commit = -1) THEN
		        rollback work;
            END IF;

			TRUNCATE TABLE bdinteg:"informix".si_cat_motivossitesp;
			TRUNCATE TABLE bdinteg:"informix".si_cat_personas;
			TRUNCATE TABLE bdinteg:"informix".si_cat_tipomovimiento;
			TRUNCATE TABLE bdinteg:"informix".si_cat_tipossituacionesp;
			TRUNCATE TABLE bdinteg:"informix".si_cat_situacionesespeciales;
			
			FOREACH WITH HOLD
			    SELECT id_motivo, clv_motivo, desc_motivo, clv_status 
			    INTO v_id_motivo, v_clv_motivo, v_desc_motivo, v_clv_status
			    FROM bdinteg:"informix".si_cat_motivossitesp_hist 
			    WHERE fecha_insert BETWEEN dtCatIni AND dtCatFin
			    			    
			    IF (val_trans_Commit = 0) THEN
                    BEGIN WORK;
                    LET contador_commit = 0;
                    LET val_trans_Commit = -1;
                END IF;         
                INSERT INTO bdinteg:"informix".si_cat_motivossitesp (id_motivo, clv_motivo, desc_motivo, clv_status)
                VALUES(v_id_motivo, v_clv_motivo, v_desc_motivo, v_clv_status); 
                            
                DELETE FROM bdinteg:"informix".si_cat_motivossitesp_hist 
                WHERE id_motivo= v_id_motivo 
                AND fecha_insert BETWEEN dtCatIni AND dtCatFin;
                
                LET contador_commit = contador_commit  + 1;
			
                IF (contador_commit >= 1000) THEN
                    COMMIT WORK;
                    LET contador_commit = 0; 
                    BEGIN WORK;
                END IF;            
                     
            END FOREACH;
            IF val_trans_Commit = -1 THEN
                COMMIT WORK;
                LET contador_commit = 0;
                LET val_trans_Commit = 0;
            END IF;
            
            FOREACH WITH HOLD
			    SELECT id_persona, clv_persona, desc_persona, clv_status 
			    INTO v_id_persona ,v_clv_persona ,v_desc_persona ,v_clv_status_p
			    FROM bdinteg:"informix".si_cat_personas_hist
                WHERE fecha_insert BETWEEN dtCat2Ini AND dtCat2Fin
                
                IF (val_trans_Commit = 0) THEN
                    BEGIN WORK;
                    LET contador_commit = 0;
                    LET val_trans_Commit = -1;
                END IF;  
                
                INSERT INTO bdinteg:"informix".si_cat_personas (id_persona ,clv_persona ,desc_persona ,clv_status)
                VALUES(v_id_persona ,v_clv_persona ,v_desc_persona ,v_clv_status_p);
                           
                DELETE FROM bdinteg:"informix".si_cat_personas_hist 
                WHERE id_persona=v_id_persona
                AND fecha_insert BETWEEN dtCat2Ini AND dtCat2Fin;
                
                LET contador_commit = contador_commit  + 1;
			
                IF (contador_commit >= 1000) THEN
                    COMMIT WORK;
                    LET contador_commit = 0; 
                    BEGIN WORK;
                END IF;  
            END FOREACH;
            IF val_trans_Commit = -1 THEN
                COMMIT WORK;
                LET contador_commit = 0;
                LET val_trans_Commit = 0;
            END IF;
                
			FOREACH WITH HOLD
			    SELECT idu_tipomovimiento, desc_tipomovimiento 
			    INTO v_idu_tipomovimiento, v_desc_tipomovimiento
			    FROM bdinteg:"informix".si_cat_tipomovimiento_hist
			    WHERE fecha_insert BETWEEN dtCat3Ini AND dtCat3Fin			    
			    
			    IF (val_trans_Commit = 0) THEN
                    BEGIN WORK;
                    LET contador_commit = 0;
                    LET val_trans_Commit = -1;
                END IF;
                
			    INSERT INTO bdinteg:"informix".si_cat_tipomovimiento (idu_tipomovimiento, desc_tipomovimiento)
			    VALUES(v_idu_tipomovimiento, v_desc_tipomovimiento);
			    
			    DELETE FROM bdinteg:"informix".si_cat_tipomovimiento_hist 
			    WHERE idu_tipomovimiento=v_idu_tipomovimiento AND fecha_insert BETWEEN dtCat3Ini AND dtCat3Fin;
			    
			    LET contador_commit = contador_commit  + 1;
			
                IF (contador_commit >= 1000) THEN
                    COMMIT WORK;
                    LET contador_commit = 0; 
                    BEGIN WORK;
                END IF;  
            END FOREACH;
            IF val_trans_Commit = -1 THEN
                COMMIT WORK;
                LET contador_commit = 0;
                LET val_trans_Commit = 0;
            END IF;
			
			
			FOREACH WITH HOLD
			    SELECT idu_tiposituacion, clv_tiposituacion, des_tiposituacion 
			    INTO v_idu_tiposituacion, v_clv_tiposituacion, v_des_tiposituacion
			    FROM bdinteg:"informix".si_cat_tipossituacionesp_hist
                WHERE fecha_insert BETWEEN dtCat4Ini AND dtCat4Fin
                
                IF (val_trans_Commit = 0) THEN
                    BEGIN WORK;
                    LET contador_commit = 0;
                    LET val_trans_Commit = -1;
                END IF;
                
                INSERT INTO bdinteg:"informix".si_cat_tipossituacionesp (idu_tiposituacion, clv_tiposituacion, des_tiposituacion)
                VALUES(v_idu_tiposituacion, v_clv_tiposituacion, v_des_tiposituacion);
                
                DELETE FROM bdinteg:"informix".si_cat_tipossituacionesp_hist 
                WHERE idu_tiposituacion=v_idu_tiposituacion 
                AND fecha_insert BETWEEN dtCat4Ini AND dtCat4Fin;
                
                LET contador_commit = contador_commit  + 1;
			
                IF (contador_commit >= 1000) THEN
                    COMMIT WORK;
                    LET contador_commit = 0; 
                    BEGIN WORK;
                END IF;  
            END FOREACH;
            IF val_trans_Commit = -1 THEN
                COMMIT WORK;
                LET contador_commit = 0;
                LET val_trans_Commit = 0;
            END IF;
            
            FOREACH WITH HOLD
                SELECT idu_situacion,clv_situacion,num_causasituacion,nom_descsituacion,num_jerarquia,
					clv_statussit,clv_activo,clv_compra,clv_borrar,num_mesescat1,num_mesescat2,idu_tiposituacion,clv_actualizable,clv_marcarautomatico,
					clv_desmarcarautomatico,num_diascambioestatus,num_mesesactualizadatos,num_mesesdepurar,idu_tipomovimiento 
				INTO v_idu_situacion,v_clv_situacion,v_num_causasituacion,v_nom_descsituacion,v_num_jerarquia,
					v_clv_statussit,v_clv_activo,v_clv_compra,v_clv_borrar,v_num_mesescat1,v_num_mesescat2,v_idu_tiposituacion_se,v_clv_actualizable,v_clv_marcarautomatico,
					v_clv_desmarcarautomatico,v_num_diascambioestatus,v_num_mesesactualizadatos,v_num_mesesdepurar,v_idu_tipomovimiento_se
				FROM bdinteg:"informix".si_cat_situacionesespeciales_hist
                WHERE fecha_insert BETWEEN dtCat5Ini AND dtCat5Fin
                
			    IF (val_trans_Commit = 0) THEN
                    BEGIN WORK;
                    LET contador_commit = 0;
                    LET val_trans_Commit = -1;
                END IF;
                
                INSERT INTO bdinteg:"informix".si_cat_situacionesespeciales (idu_situacion,clv_situacion,num_causasituacion,nom_descsituacion,num_jerarquia,
                           clv_statussit,clv_activo,clv_compra,clv_borrar,num_mesescat1,num_mesescat2,idu_tiposituacion,clv_actualizable,clv_marcarautomatico,
                           clv_desmarcarautomatico,num_diascambioestatus,num_mesesactualizadatos,num_mesesdepurar,idu_tipomovimiento)
                VALUES(v_idu_situacion,v_clv_situacion,v_num_causasituacion,v_nom_descsituacion,v_num_jerarquia,
					    v_clv_statussit,v_clv_activo,v_clv_compra,v_clv_borrar,v_num_mesescat1,v_num_mesescat2,v_idu_tiposituacion_se,v_clv_actualizable,v_clv_marcarautomatico,
					    v_clv_desmarcarautomatico,v_num_diascambioestatus,v_num_mesesactualizadatos,v_num_mesesdepurar,v_idu_tipomovimiento_se);
			    
			    DELETE FROM bdinteg:"informix".si_cat_situacionesespeciales_hist
			    WHERE idu_situacion=v_idu_situacion 
			    AND fecha_insert BETWEEN dtCat5Ini AND dtCat5Fin;
			    
			    LET contador_commit = contador_commit  + 1;
			
                IF (contador_commit >= 1000) THEN
                    COMMIT WORK;
                    LET contador_commit = 0; 
                    BEGIN WORK;
                END IF;  
            END FOREACH;
            IF val_trans_Commit = -1 THEN
                COMMIT WORK;
                LET contador_commit = 0;
                LET val_trans_Commit = 0;
            END IF; 
			
			
			--DELETE FROM bdinteg:"informix".si_cat_motivossitesp_hist WHERE fecha_insert BETWEEN dtCatIni AND dtCatFin;
			--DELETE FROM bdinteg:"informix".si_cat_personas_hist WHERE fecha_insert BETWEEN dtCat2Ini AND dtCat2Fin;
			--DELETE FROM bdinteg:"informix".si_cat_tipomovimiento_hist WHERE fecha_insert BETWEEN dtCat3Ini AND dtCat3Fin;
			--DELETE FROM bdinteg:"informix".si_cat_tipossituacionesp_hist WHERE fecha_insert BETWEEN dtCat4Ini AND dtCat4Fin;
			--DELETE FROM bdinteg:"informix".si_cat_situacionesespeciales_hist WHERE fecha_insert BETWEEN dtCat5Ini AND dtCat5Fin;
			
			
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
   	
   SET LOCK MODE TO WAIT 3;

   --SET DEBUG FILE TO '/resplogifx/archivoscredito/sp_actcatalogos_sitesp.out';
   --TRACE ON;

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
                    
                    FOREACH WITH HOLD
                        SELECT id_motivo, clv_motivo, desc_motivo, clv_status, CURRENT 
                        INTO v_id_motivo_his, v_clv_motivo_his, v_desc_motivo_his, v_clv_status_mhis, v_fecha_insert_mhis
                        FROM bdinteg:"informix".si_cat_motivossitesp WHERE id_motivo>=0
                        
                        INSERT INTO bdinteg:"informix".si_cat_motivossitesp_hist (id_motivo, clv_motivo, desc_motivo, clv_status, fecha_insert)
                        VALUES(v_id_motivo_his, v_clv_motivo_his, v_desc_motivo_his, v_clv_status_mhis, v_fecha_insert_mhis);
                        
                    END FOREACH;
                    
                    LET dtCatFin = CURRENT;
                    
                    LET dtCat2Ini = CURRENT;
                    FOREACH WITH HOLD
                        SELECT id_persona, clv_persona, desc_persona, clv_status, CURRENT 
                        INTO v_id_persona_his, v_clv_persona_his, v_desc_persona_his, v_clv_status_phis, v_fecha_insert_phis
                        FROM bdinteg:"informix".si_cat_personas WHERE id_persona>=0
						
                        INSERT INTO bdinteg:"informix".si_cat_personas_hist(id_persona, clv_persona, desc_persona, clv_status, fecha_insert)
                        VALUES(v_id_persona_his, v_clv_persona_his, v_desc_persona_his, v_clv_status_phis, v_fecha_insert_phis);
                    END FOREACH;    
                    
                    LET dtCat2Fin = CURRENT;
                    
                    LET dtCat3Ini = CURRENT;
                    FOREACH WITH HOLD
                        SELECT idu_tipomovimiento, desc_tipomovimiento, CURRENT 
                        INTO v_idu_tipomovimiento_this, v_desc_tipomovimiento_his, v_fecha_insert_this
                        FROM bdinteg:"informix".si_cat_tipomovimiento WHERE idu_tipomovimiento>=0
                        
                        INSERT INTO bdinteg:"informix".si_cat_tipomovimiento_hist (idu_tipomovimiento, desc_tipomovimiento, fecha_insert)
                        VALUES(v_idu_tipomovimiento_this, v_desc_tipomovimiento_his, v_fecha_insert_this);
                    END FOREACH;
                   
                    LET dtCat3Fin = CURRENT;
                    
                    LET dtCat4Ini = CURRENT;
                    FOREACH WITH HOLD
                        SELECT idu_tiposituacion, clv_tiposituacion, des_tiposituacion, CURRENT 
                        INTO v_idu_tiposituacion_shis, v_clv_tiposituacion_his, v_des_tiposituacion_his, v_fecha_insert_shis
                        FROM bdinteg:"informix".si_cat_tipossituacionesp WHERE idu_tiposituacion>=0
                        
                        INSERT INTO bdinteg:"informix".si_cat_tipossituacionesp_hist (idu_tiposituacion, clv_tiposituacion, des_tiposituacion, fecha_insert)
                        VALUES(v_idu_tiposituacion_shis, v_clv_tiposituacion_his, v_des_tiposituacion_his, v_fecha_insert_shis);
                    END FOREACH;
                    
                    LET dtCat4Fin = CURRENT;
                    
                    LET dtCat5Ini = CURRENT;
                    FOREACH WITH HOLD
                        SELECT idu_situacion,clv_situacion,num_causasituacion,nom_descsituacion,num_jerarquia,
                           clv_statussit,clv_activo,clv_compra,clv_borrar,num_mesescat1,num_mesescat2,idu_tiposituacion,clv_actualizable,clv_marcarautomatico,
                           clv_desmarcarautomatico,num_diascambioestatus,num_mesesactualizadatos,num_mesesdepurar,idu_tipomovimiento, CURRENT
                        INTO v_idu_situacion_his,v_clv_situacion_his,v_num_causasituacion_his,v_nom_descsituacion_his,v_num_jerarquia_his,
                                v_clv_statussit_his,v_clv_activo_his,v_clv_compra_his,v_clv_borrar_his,v_num_mesescat1_his,v_num_mesescat2_his,v_idu_tiposituacion_sehis,v_clv_actualizable_his,v_clv_marcarautomatico_his,
                                v_clv_desmarcarautomatico_his,v_num_diascambioestatus_his,v_num_mesesactualizadatos_his,v_num_mesesdepurar_his,v_idu_tipomovimiento_sehis, v_fecha_insert_sehis
                        FROM bdinteg:"informix".si_cat_situacionesespeciales WHERE idu_situacion>=0
                    
                        INSERT INTO bdinteg:"informix".si_cat_situacionesespeciales_hist(idu_situacion,clv_situacion,num_causasituacion,nom_descsituacion,num_jerarquia,
                                clv_statussit,clv_activo,clv_compra,clv_borrar,num_mesescat1,num_mesescat2,idu_tiposituacion,clv_actualizable,clv_marcarautomatico,
                                clv_desmarcarautomatico,num_diascambioestatus,num_mesesactualizadatos,num_mesesdepurar,idu_tipomovimiento, fecha_insert)
                        VALUES(v_idu_situacion_his,v_clv_situacion_his,v_num_causasituacion_his,v_nom_descsituacion_his,v_num_jerarquia_his,
                                v_clv_statussit_his,v_clv_activo_his,v_clv_compra_his,v_clv_borrar_his,v_num_mesescat1_his,v_num_mesescat2_his,v_idu_tiposituacion_sehis,v_clv_actualizable_his,v_clv_marcarautomatico_his,
                                v_clv_desmarcarautomatico_his,v_num_diascambioestatus_his,v_num_mesesactualizadatos_his,v_num_mesesdepurar_his,v_idu_tipomovimiento_sehis, v_fecha_insert_sehis);
                    END FOREACH;
                    
                    LET dtCat5Fin = CURRENT;  
                    
                
                COMMIT WORK;
                TRUNCATE TABLE bdinteg:"informix".si_cat_motivossitesp; 
                TRUNCATE TABLE bdinteg:"informix".si_cat_personas;
                TRUNCATE TABLE bdinteg:"informix".si_cat_tipomovimiento;
                TRUNCATE TABLE bdinteg:"informix".si_cat_tipossituacionesp;
                TRUNCATE TABLE bdinteg:"informix".si_cat_situacionesespeciales;
             
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

CREATE PROCEDURE "informix".sp_traslada_boletos(p_cve_sorteo char(5), p_fecha_pase DATE)
RETURNING CHAR(5)  AS Codigo_retorno, 
          CHAR(80) AS Mensaje,
          CHAR(1)  AS Reverso,
          CHAR(25) AS StorePro;              
               
    DEFINE vsqlerr           INTEGER; 
    DEFINE v_codigo_retorno	CHAR(5);
    DEFINE v_mensaje	  	    CHAR(80);
    DEFINE v_reverso         CHAR(1);
    DEFINE v_store_pro       CHAR(25);
    DEFINE vrowid      INTEGER;
    DEFINE vd_valida   DATE;
    DEFINE vd_fecha2   DATE;
    DEFINE vd_fsorteo  DATE;
    DEFINE vc_numcte   CHAR(10);
    DEFINE vi_nociudadcoppel  INTEGER;
    DEFINE vi_nocoloniacoppel INTEGER;
    DEFINE vc_nomzonacoppel   CHAR(20);
    DEFINE vc_nomcuidad       CHAR(20);  
    DEFINE vc_nombre          CHAR(25);
    DEFINE vc_telef1          CHAR(10);
    DEFINE vc_telef2          CHAR(13);
    DEFINE vc_domicilio       CHAR(50);
    DEFINE vc_nomcalle        CHAR(20); 
    DEFINE vc_numextcalle     CHAR(10);
    DEFINE vc_nomcolonia      CHAR(20);
    DEFINE vc_nombre_cte   CHAR(45);
    DEFINE vc_cvesorteo    INTEGER;
	DEFINE v_foliosuc CHAR(16);
    DEFINE v_param		  CHAR(5);  -- FMV 21-Sep-10: ParÃÂ¡metro para traer clave de sorteo normal 2010.
	
	DEFINE vc_cvesorteo2		CHAR(5);
	DEFINE vc_boletoini			CHAR(13);
	DEFINE vc_boletofin			INTEGER;
	DEFINE vc_f_registro		DATE;
	DEFINE vc_estado			INTEGER;
	DEFINE vc_sucursal			CHAR(4);
	DEFINE vc_area				CHAR(1);
	DEFINE vc_caja				INTEGER;
	DEFINE vc_tipomov			CHAR(10);
	DEFINE vc_importe			CHAR(10);
	DEFINE vc_telefono1			CHAR(10);
	DEFINE vc_telefono2			CHAR(10);
	DEFINE vc_nom				CHAR(45);
	DEFINE vc_ciudad			CHAR(20);
	DEFINE vc_dom				CHAR(50);
	DEFINE vc_fecha				DATE;
	DEFINE vc_origen			CHAR(10);
	DEFINE vc_secuencia			INTEGER;
	DEFINE vc_entfed			CHAR(25);

    --SET debug file TO "/tmp/traslada_boletos2.out";
    --TRACE ON;

    LET v_codigo_retorno = "00000";
    LET v_mensaje = "Proceso Inicia Correctamente";
    LET v_reverso = '0';
    LET v_store_pro = 'sp_traslada_boletos';
    LET vrowid     = 0;
    LET vd_valida  = (p_fecha_pase - 1 units day);
    LET vd_fsorteo = (vd_valida - 1 units day);

    --SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET ISOLATION COMMITTED READ;
    SET LOCK MODE TO wait 3;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exception, Verifique Datos SQL!";
            LET v_reverso = '1';         
            LET v_store_pro = 'sp_traslada_boletos';
            RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
        END IF;
    END EXCEPTION;
	   /*VALIDA QUE LA BANDERA DEL CONCURSO 00002 SEA 2*/
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = p_cve_sorteo AND flag_sort = 2 AND vd_valida BETWEEN f_ini AND f_fin) THEN
					
				/*se agrega para optimizacion de busqueda*/
    
				-- FMV 21-Sep-10: ParÃÂ¡metro para traer clave de sorteo normal 2010.
				SELECT valor 
				INTO v_param 
				FROM bdinteg:si_param
				WHERE cod_param = 118;
				
				SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo 
				INTO vc_cvesorteo
				FROM si_sorteo
				WHERE cve_sorteo = v_param;     -- FMV 21-Sep-10    
				
				IF NOT EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo 
								 FROM bdinteg:si_sorteo 
								WHERE cve_sorteo = v_param) THEN -- FMV 21-Sep-10 
					LET v_codigo_retorno = "00040";
					LET v_mensaje = "Se Genero Error en si_sorteo, No Existe Sorteo!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';                 
				END IF;   
				
				IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} cve_sorteo
							 FROM bdinteg:si_sorteo
							WHERE cve_sorteo = v_param  -- FMV 21-Sep-10 
							  AND f_fin < vd_fsorteo) THEN                  
					LET v_codigo_retorno = "00042";
					LET v_mensaje = "Se Genero Error en si_sorteo, Sorteo No esta Vigente!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';                 
				END IF;
				
				--*********************************************************--
				-- Creado por: Francisco Martinez Viveros	
				--Fecha Creacion: 31/AGOSTO/2010
				--Fecha Modifica: 09/NOVIEMBRE/2010 
				--Objetivo: Traspasa los boletos generados diariamente y 
				--          los envia a la tabla historica con los datos del clte.    
				--*********************************************************--

				
				IF (p_fecha_pase is null) THEN
					LET v_codigo_retorno = "00030";
					LET v_mensaje = "Se genero error de Ejecucion, Verifique Fecha Nula!";
					LET v_reverso = '1';
					LET v_store_pro = 'sp_traslada_boletos';
					RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
				END IF;
				
				-- BGM 08-Nov-2010: se coloca en primera instancia el foreach para actualizar los datos del cliente 
				-- sobre la misma tabla si_boleto
				-- FOREACH 1 
				FOREACH cursor_actual WITH HOLD FOR              
					SELECT {+index (si_boleto idx_si_bol_clte)} fecha, numcte   --FMV 8-NOV-10: SE ADICIONA INDICE               
					INTO vd_fecha2, vc_numcte  
					FROM bdinteg:"informix".si_boleto 
					WHERE fecha = vd_valida 
					AND numcte > '0000000'

					BEGIN WORK;

					-- BGM 08-Nov-2010: se coloca query optimizado por Faviola MartÃÂ­nez.
					-- FMV 09-Nov-2010: Query filtrado por Faviola MartÃÂ­nez, con aquellos Clientes q no tienen datos completos.

					SELECT {+index (SI_CATCALLES idx_catcalles)}
							CAT.numerociudadcoppel,CAT.numerocoloniacoppel,CAT.nombrezonacoppel, 
							CIU.NOMBRECIUDAD, SCA.NOMBRECALLE, SE.nombre,tel1.telefono, tel2.telefono,
							dom.numeroextcalle, CAT.nombrezona    
					  INTO vi_nociudadcoppel, vi_nocoloniacoppel, vc_nomzonacoppel, vc_nomcuidad,
							vc_nomcalle, vc_nombre, vc_telef1, vc_telef2, vc_numextcalle,
							vc_nomcolonia
					FROM BDINTEG:SI_DIRECCIONES_ACTUAL DOM  
					LEFT OUTER JOIN BDINTEG:SI_CATCALLES SCA ON (DOM.NUMEROCALLE = SCA.NUMEROCALLE)
					LEFT OUTER JOIN BDINTEG:SI_CATZONAS CAT ON (DOM.NUMEROCIUDAD = CAT.NUMEROCIUDAD AND DOM.NUMEROCOLONIA = CAT.NUMEROCOLONIA)  
					LEFT JOIN BDINTEG:SI_CATCIUDADES CIU ON (DOM.NUMEROCIUDAD = CIU.NUMEROCIUDAD  )
					LEFT JOIN BDINTEG:SI_ESTADOS SE ON ( DOM.estado   = SE.ESTADO )
					LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dom.numcte AND tel1.tipo_tel = 1)
					LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dom.numcte AND tel2.tipo_tel = 2)
					WHERE DOM.NUMCTE = vc_numcte 
					-- AND DOM.SECUENCIA IN (SELECT MAX(SID.SECUENCIA) FROM BDINTEG:SI_DIRECCIONES_ACTUAL SID WHERE SID.NUMCTE = DOM.NUMCTE AND SID.TIPO_DIR = 1 ) 
					AND DOM.TIPO_DIR  = 1;
					
					--FMV: Se Adiciona validacion para los telefonos por si el dato en null
					IF (vc_telef1 IS NULL) OR (vc_telef1= '') THEN 
						LET vc_telef1 = '0';
					END IF;
					
					IF (vc_telef2 IS NULL) OR (vc_telef2= '') THEN 
						LET vc_telef2 = '0';
					END IF;
					
					LET vc_nombre_cte = (SELECT trim(nombre1)||' '||   
												trim(nombre2)||' '||    
												trim(apell_paterno)||' '|| 
												trim(apell_materno)                                            
												FROM bdinteg:si_cliente WHERE numcte = vc_numcte);    
												
					LET vc_domicilio =  trim(vc_nomcalle)||' '||
										trim(vc_numextcalle)||' '||                                                                      
										trim(vc_nomcolonia);
										
				--07/11/2017.-INI: Se realiza la implementaciÃÂ³n del SP <sp_quitar_acentos.sql> para eliminar 
				--caracteres especiales de Nombre de Cliente y Domicilio.(Patricia Del Razo)
				
					-- BGM 08-Nov-2010: se hace el update sobre si_boleto en lugar de si_boleto_hist
					UPDATE bdinteg:"informix".si_boleto        --{+index (si_mensajes_enviar_his idx_msgs_envhis)}
					SET telefono1 = sp_limpia_telefono(vc_telef1), --16/11/2017: (PatriciaDelRazo): aÃÂ±ado SP para limpiar alfabeto de telefono1
						telefono2 = sp_limpia_telefono(vc_telef2), --16/11/2017: (PatriciaDelRazo): aÃÂ±ado SP para limpiar alfabeto de telefono2
						nombre    = sp_quitar_acentos(vc_nombre_cte),
						ciudad    = vc_nomcuidad,
						domicilio = sp_quitar_acentos(vc_domicilio),
						ent_fed = vc_nombre --SE AGREGA PARA GUARDARSE EN LA TABLA
					WHERE CURRENT OF cursor_actual;  
						
					COMMIT WORK;
				--07/11/2017.- FIN: EliminaciÃÂ³n de caracteres especiales. (Patricia Del Razo)
				
				END FOREACH; 
				
				IF (v_reverso <> '0') THEN        
					RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
				END IF;
				
				LET v_codigo_retorno = "00000";
				LET v_mensaje = "Proceso Pase de Boletos, Termino Correctamente!";
				LET v_reverso = '0';         
				LET v_store_pro = 'sp_traslada_boletos';    

				-- BGM 08-Nov-2010: se cambia de posiciÃÂ³n el FOREACH para que al final haga el traslado a si_boleto_hist, 
				-- pero sin borrar los datos de si_boleto porque los necesitarÃÂ¡ el sp_detalle_boletos

				FOREACH cursor_inserta WITH HOLD FOR
					SELECT  {+index (si_boleto idx_si_boleto)}numcte, foliosuc,cve_sorteo, boleto_ini, boleto_fin, f_registro, estado, sucursal, area, caja, tipomov, importe, telefono1, telefono2, nombre, ciudad, domicilio, fecha, origen, secuencia, ent_fed
						INTO vc_numcte, v_foliosuc, vc_cvesorteo2, vc_boletoini, vc_boletofin, vc_f_registro, vc_estado, vc_sucursal , vc_area, vc_caja, vc_tipomov, vc_importe, vc_telefono1, vc_telefono2, vc_nom, vc_ciudad, vc_dom, vc_fecha,vc_origen, vc_secuencia, vc_entfed
					FROM bdinteg:"informix".si_boleto
					WHERE fecha = today 
					AND numcte > '0000000'
					
					BEGIN WORK;
					
					INSERT INTO bdinteg:"informix".si_boleto_hist (cve_sorteo, boleto_ini, boleto_fin, f_registro, numcte, estado, sucursal, area, caja, tipomov, foliosuc, importe, telefono1, telefono2, nombre, ciudad, domicilio, fecha, origen, secuencia, ent_fed)
					VALUES( vc_cvesorteo2, vc_boletoini, vc_boletofin, vc_f_registro,vc_numcte, vc_estado, vc_sucursal , vc_area, vc_caja, vc_tipomov, v_foliosuc, vc_importe, vc_telefono1, vc_telefono2, vc_nom, vc_ciudad, vc_dom, vc_fecha,vc_origen, vc_secuencia, vc_entfed);          
					  
				COMMIT WORK;                           
				END FOREACH;
	ELSE
		LET v_codigo_retorno = "22222";
        LET v_mensaje = "ÃÂ¡EL SORTEO NAVIDEÃÂO NO ESTA ACTIVO!";
        LET v_reverso = '1';
        LET v_store_pro = v_store_pro;     
	END IF;			
    
    END;   --begin        
    
    RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
    
END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÃÂLEZ',
'FECHA DE MODIFICACIÃÂN: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 2, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG',
'MODIFICADO POR: ISRAEL FLORES GONZÃÂLEZ',
'FECHA DE MODIFICACIÃÂN: 15 NOVIEMBRE DE 2016',
'OBJETIVO: SE CAMBIA EL SET ISOLATION TO DIRTY READ POR',
'          SET ISOLATION TO COMMITTED READ LAST COMMITTED',
'          PARA QUE SE ACTUALCE COMPLETAMENTE LA tabla si_boleto',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_dicta_consultactesdictamen_hawk2(pTipoConsulta CHAR(1), pSucursal CHAR(4), pFechaIni DATE, pFechaFin DATE, pNumCte CHAR(20), pTipoDictamen CHAR(1), pAnalista CHAR(8))
		--RETORNOS
		RETURNING
		CHAR(6)		AS CodRet,
		DATETIME YEAR TO SECOND AS FechaAlerta,
		DATETIME YEAR TO SECOND AS FechaAtendida,
		SMALLINT	AS Coincidencias,
		CHAR(4)		AS NumSucursal,
		CHAR(8)		AS NumEmpProm,
		CHAR(45)	AS NombrePromotor,
		CHAR(20)	AS NumCte,
		CHAR(100)	AS NomCte,
		CHAR(8)		AS EmpAnalista,
		CHAR(45)	AS NomAnalista,
		CHAR(20)	AS TiempoResp,
		CHAR(20)	AS NumCteCoinc,
		--CHAR(104)	AS NombreCteCoinc,
		CHAR(25)	AS DescCoinc,
		
		CHAR(1) AS Origen,
		CHAR(30) AS DescripOrigen,
		CHAR(40) AS NomSucursal,
		CHAR(30) AS EstadoSucursal,
		CHAR(60) AS CiudadSucursal;
		

	DEFINE iSqlErr INTEGER; 
	DEFINE cCodRet CHAR(6);
	DEFINE dtFechaAlerta DATETIME YEAR TO SECOND;
	DEFINE dtFechaAtendida DATETIME YEAR TO SECOND;
	DEFINE dtFechaFinDicta	DATETIME YEAR TO SECOND;
	DEFINE cTiempoResp CHAR(20);
	DEFINE sCoincidencias SMALLINT;
	DEFINE cSucursal CHAR(4);
	DEFINE cNumEmpProm CHAR(8);
	DEFINE cNombrePromotor CHAR(45);
	DEFINE cNomAnalista CHAR(45);
	DEFINE cNumCte CHAR(20);
	DEFINE cNomCte CHAR(100);
	DEFINE cEmpAnalista CHAR(8);
	DEFINE cTipoCoinc CHAR(1);
	DEFINE cNumCteCoinc CHAR(20);
	DEFINE cTipoDictamen CHAR(1);

	DEFINE cDescCoinc CHAR(25);
	
	DEFINE dtFechaIniDicta	DATETIME YEAR TO SECOND;
	DEFINE cOrigen CHAR(1);
	DEFINE cDescripOrigen CHAR(30);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cEstadoSuc CHAR(30);
	DEFINE cCiudadSuc CHAR(60);
	
 
	--Inicializacion de variables
	LET iSqlErr = 0;
	LET cCodRet = '000000';
	LET dtFechaAlerta = '';
	LET dtFechaAtendida = '';
	LET dtFechaFinDicta = '';
	LET cTiempoResp = '00:00:00';
	LET sCoincidencias = 0;
	LET cSucursal = '';
	LET cNumEmpProm = '';
	LET cNombrePromotor = '';
	LET cNomAnalista = '';
	LET cNumCte = '';
	LET cNomCte = '';
	LET cEmpAnalista = '';
	LET cTipoCoinc			= '';
	LET cNumCteCoinc		= '';
	LET cTipoDictamen		= '';

	LET cDescCoinc			= '';

	LET dtFechaIniDicta		= '';
	LET cOrigen = '';
	LET cDescripOrigen = '';
	LET cNomSucursal = '';
	LET cEstadoSuc = '';
	LET cCiudadSuc = ''; 
	

	BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/mfinis/sp_dicta_consultactesdictamen_hawk2.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
		
	-- VALIDACIÃ?N DE CADA FUNCIONALIDAD DEL PROCEDIMIENTO.
	IF pTipoConsulta = '1' THEN -- CONSULTA POR TODOS LOS DICTAMENES REALIZADOS.
		
		FOREACH
			--SELECT SKIP pPaginacion LIMIT 20 bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd, "informix".si_catorigenhuellas sc
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = 108
			  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
              AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			  AND bc.origen = sc.cod_origen 
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				--SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				SELECT {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} MAX(fecha_dicta_fin), MAX(fecha_dicta_ini) INTO dtFechaFinDicta, dtFechaIniDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				--LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaIniDicta::DATETIME YEAR TO SECOND);
				
					-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)--, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
				
				
			
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')),TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')),TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;	
		
	ELIF pTipoConsulta = '2' AND TRIM(NVL(pSucursal,"")) <> "" THEN -- CONSULTA POR SUCURSAL.
		
	
		
		FOREACH
			--SELECT SKIP pPaginacion LIMIT 20 bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd,"informix".si_catorigenhuellas sc
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = '108'
			  AND bd.sucursal = pSucursal
              AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
              AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			  AND bc.origen = sc.cod_origen 
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				--SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				SELECT {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} MAX(fecha_dicta_fin), MAX(fecha_dicta_ini) INTO dtFechaFinDicta, dtFechaIniDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				--LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaIniDicta::DATETIME YEAR TO SECOND);
				
					-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)--, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --,cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
			
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')),TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')),TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;	
		
	ELIF pTipoConsulta = '3' THEN -- CONSULTA POR FECHAS.
	
		IF NVL(pFechaIni, DATE(1)) = DATE(1) OR NVL(pFechaFin, DATE(1)) = DATE(1) THEN
			LET cCodRet = '000001';
		ELSE
			
			
			FOREACH
				--SELECT bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
				SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
				INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
				FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd, "informix".si_catorigenhuellas sc
				WHERE bc.numcte = bd.numcte
				  AND bc.status_alerta = '3'
				  AND bd.situacion = 'P' 
				  AND bd.causa = '108'
				  AND bd.fecha_dicta_ini::DATE >= pFechaIni
				  AND bd.fecha_dicta_fin::DATE <= pFechaFin
				  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
				  AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
				  AND bc.origen = sc.cod_origen 
				GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
				
					-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
					SELECT nombre INTO cNombrePromotor
					FROM "informix".si_ejecut
					WHERE ejecutivo = cNumEmpProm;
					
					-- OBTENEMOS EL NOMBRE DEL ANALISTA.
					SELECT nombre INTO cNomAnalista
					FROM "informix".si_ejecut
					WHERE ejecutivo = cEmpAnalista;
					
					-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
					--SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
					SELECT  {+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} MAX(fecha_dicta_fin), MAX(fecha_dicta_ini) INTO dtFechaFinDicta, dtFechaIniDicta
					FROM "informix".si_bitacora_dictamenes
					WHERE numcte = cNumCte;
					
					-- CALCULAMOS EL TIEMPO DE RESPUESTA.
					--LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
					LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaIniDicta::DATETIME YEAR TO SECOND);
					
						-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
					SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) --, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
					INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
					FROM "informix".si_cliente
					WHERE numcte = cNumCte;
					
					--OBTENEMOS LOS DATOS DE LA SUCURSAL
					SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
					INTO cNomSucursal,cEstadoSuc,cCiudadSuc
					FROM "informix".si_sucursales ss 
					INNER JOIN "informix".si_estados se ON ss.estado = se.estado
					INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
					AND ss.ciudad = sc.ciudad 
					WHERE ss.sucursal = cSucursal;
					
				
					
					RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
			END FOREACH;
			
			-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '000002'; 
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
			END IF;	
		END IF;
		
	ELIF pTipoConsulta = '4' AND TRIM(pNumCte) <> ""  THEN -- CONSULTA POR CLIENTE.
		
				
		FOREACH
			--SELECT SKIP pPaginacion LIMIT 20 bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd, "informix".si_catorigenhuellas sc
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = '108'
		      AND bc.numcte = pNumCte
			  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
			  AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			  AND bc.origen = sc.cod_origen 
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				--SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				SELECT MAX(fecha_dicta_fin), MAX(fecha_dicta_ini) INTO dtFechaFinDicta, dtFechaIniDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				--LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaIniDicta::DATETIME YEAR TO SECOND);
				
					-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) --, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
				
				
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;	
		
	ELIF pTipoConsulta = '5' THEN -- MUESTRA TODOS LOS REGISTROS PARA EXPORTARLOS A EXCEL.
		
		FOREACH
			--SELECT bc.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bc.sucursal, bc.numemp, bc.numcte, bc.analista_fraudes
			SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, MAX(bd.fecha_dicta_ini), bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, sCoincidencias, cSucursal, cNumEmpProm, cNumCte, cEmpAnalista, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_comparaciones bc, "informix".si_bitacora_dictamenes bd, "informix".si_catorigenhuellas sc
			WHERE bc.numcte = bd.numcte
              AND bc.status_alerta = '3'
              AND bd.situacion = 'P' 
			  AND bd.causa = '108'
			  AND bc.numcte = DECODE(pNumCte, "", bc.numcte, pNumCte) 
			  AND bd.sucursal = DECODE(pSucursal, "", bd.sucursal, pSucursal)
			  AND bd.fecha_dicta_ini::DATE >= DECODE(NVL(pFechaIni, DATE(1)), DATE(1), bd.fecha_dicta_ini::DATE, pFechaIni) 
			  AND bd.fecha_dicta_fin::DATE <= DECODE(NVL(pFechaFin, DATE(1)), DATE(1), bd.fecha_dicta_fin::DATE, pFechaFin) 
			  AND bc.analista_fraudes = DECODE(pAnalista, "", bc.analista_fraudes, pAnalista) 
			  AND bd.tipo_dictamen = DECODE(pTipoDictamen, "", bd.tipo_dictamen, pTipoDictamen)
			  AND bc.origen = sc.cod_origen 
			GROUP BY bd.fecha_insert, bc.num_huellas, bd.sucursal, bc.numemp, bd.numcte, bc.analista_fraudes, bc.origen, sc.desc_origen 
			
				-- OBTENEMOS EL NOMBRE DEL PROMOTOR.
				SELECT nombre INTO cNombrePromotor
				FROM "informix".si_ejecut
				WHERE ejecutivo = cNumEmpProm;
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- OBTENEMOS LA FECHA DEL DICTAMEN DE LA ULTIMA COINCIDENCIA DE CLIENTE.
				--SELECT MAX(fecha_dicta_fin) INTO dtFechaFinDicta
				SELECT MAX(fecha_dicta_fin), MAX(fecha_dicta_ini) INTO dtFechaFinDicta, dtFechaIniDicta
				FROM "informix".si_bitacora_dictamenes
				WHERE numcte = cNumCte;
				
				-- CALCULAMOS EL TIEMPO DE RESPUESTA.
				--LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaAlerta::DATETIME YEAR TO SECOND);
				LET cTiempoResp = (dtFechaFinDicta::DATETIME YEAR TO SECOND) - (dtFechaIniDicta::DATETIME YEAR TO SECOND);
				
						-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) --, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
				
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;	
		
	ELIF pTipoConsulta = '6' AND TRIM(pNumCte) <> "" THEN -- DETALLE DE INFORME DE DICTAMENES.
		
	
		
		FOREACH
			--SELECT SKIP pPaginacion LIMIT 20 fecha_insert, fecha_dicta_fin, sucursal, numcte, tipo, numcte_coinc, tipo_dictamen, numemp, (fecha_dicta_fin::DATETIME YEAR TO SECOND - fecha_dicta_ini::DATETIME YEAR TO SECOND)
			SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, bd.fecha_dicta_fin, bd.sucursal, bd.numcte, bd.tipo, numcte_coinc, bd.tipo_dictamen, bd.numemp, (bd.fecha_dicta_fin::DATETIME YEAR TO SECOND - bd.fecha_dicta_ini::DATETIME YEAR TO SECOND), bd.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, cSucursal, cNumCte, cTipoCoinc, cNumCteCoinc, cTipoDictamen, cEmpAnalista, cTiempoResp, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_dictamenes bd,"informix".si_catorigenhuellas sc
			WHERE bd.numcte = pNumCte
			AND bd.origen = sc.cod_origen 
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- CONSULTAMOS LA DESCRIPCION DEL TIPO COINCIDENCIA.
				SELECT descripcion INTO cDescCoinc
				FROM "informix".si_empresa_huella
				WHERE numempresa = cTipoCoinc;
				
					
							-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) --, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;	
		
	ELIF pTipoConsulta = '7' AND TRIM(pNumCte) <> ""  THEN -- TOTAL DETALLE DE INFORME DE DICTAMENES PARA EXPORTAR A EXCEL.
	
		FOREACH
			SELECT {+INDEX("informix".si_catorigenhuellas idx_si_catorigenhuellas)}{+INDEX("informix".si_bitacora_dictamenes idxsi_bitacora_dictamenes_numcte)} {+INDEX("informix".si_bitacora_comparaciones idxsi_bitacora_comparaciones_numcte)} {+INDEX("informix".si_catorigenhuellas 4282_9173)} bd.fecha_insert, bd.fecha_dicta_fin, bd.sucursal, bd.numcte, bd.tipo, bd.numcte_coinc, bd.tipo_dictamen, bd.numemp, (bd.fecha_dicta_fin::DATETIME YEAR TO SECOND - bd.fecha_dicta_ini::DATETIME YEAR TO SECOND), bd.origen, sc.desc_origen 
			INTO dtFechaAlerta, dtFechaAtendida, cSucursal, cNumCte, cTipoCoinc, cNumCteCoinc, cTipoDictamen, cEmpAnalista, cTiempoResp, cOrigen, cDescripOrigen
			FROM "informix".si_bitacora_dictamenes bd, "informix".si_catorigenhuellas sc
			WHERE bd.numcte = pNumCte
			AND bd.origen = sc.cod_origen 
				
				-- OBTENEMOS EL NOMBRE DEL ANALISTA.
				SELECT nombre INTO cNomAnalista
				FROM "informix".si_ejecut
				WHERE ejecutivo = cEmpAnalista;
				
				-- CONSULTAMOS LA DESCRIPCION DEL TIPO COINCIDENCIA.
				SELECT descripcion INTO cDescCoinc
				FROM "informix".si_empresa_huella
				WHERE numempresa = cTipoCoinc;
				

							-- OBTENEMOS EL NOMBRE DEL CLIENTE BANCOPPEL.
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno) --, TRIM(tpo_persona), TRIM(razon_social), TRIM(apell_paterno), TRIM(apell_materno), TRIM(tipo_cliente)
				INTO cNomCte --, cTipo_Persona, cRazon_Social , cApell_Paterno, cApell_Materno, cTipoCliente
				FROM "informix".si_cliente
				WHERE numcte = cNumCte;
				
				--OBTENEMOS LOS DATOS DE LA SUCURSAL
				SELECT ss.nombre AS sucursal, se.nombre AS estado, sc.nombre AS ciudad
				INTO cNomSucursal,cEstadoSuc,cCiudadSuc
				FROM "informix".si_sucursales ss 
				INNER JOIN "informix".si_estados se ON ss.estado = se.estado
				INNER JOIN  "informix".si_ciudades sc ON se.estado = sc.estado
				AND ss.ciudad = sc.ciudad 
				WHERE ss.sucursal = cSucursal;
				
				
				
				RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,'')) WITH RESUME;
		END FOREACH;
		
		-- NO SE ENCUENTRAN CLIENTES DICTAMINADOS.
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '000002'; 
			RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
		END IF;
	ELSE
		LET cCodRet = '000001';
	END IF;
	
	IF cCodRet <> '000000' THEN
		RETURN TRIM(cCodRet),NVL(dtFechaAlerta,DATE(1)), NVL(dtFechaAtendida,DATE(1)), NVL(sCoincidencias,0), TRIM(NVL(cSucursal,'')), TRIM(NVL(cNumEmpProm,'')), TRIM(NVL(cNombrePromotor,'')), TRIM(NVL(cNumCte,'')), TRIM(NVL(cNomCte,'')), TRIM(NVL(cEmpAnalista,'')), TRIM(NVL(cNomAnalista,'')), TRIM(NVL(cTiempoResp,'')), TRIM(NVL(cNumCteCoinc,'')), TRIM(NVL(cDescCoinc,'')), TRIM(NVL(cOrigen,'')), TRIM(NVL(cDescripOrigen,'')), TRIM(NVL(cNomSucursal,'')), TRIM(NVL(cEstadoSuc,'')), TRIM(NVL(cCiudadSuc,''));
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: 97122114, Luis Alberto Madrid Castro',
'FOLIO: 230142 - 1530  - EvaluaciÃÂ³n de Resultados de ComparaciÃÂ³n de Huellas en LÃÂ­nea en Alta de Cliente ',
'DESCRIPCION: Creacion de SP_DICTA_CONSULTADICTAMEN_HAWK., para llenar el reporte hawk',
'FECHA: 29/01/2016',
'BD:BDINTEG ';

CREATE PROCEDURE "informix".sp_cifra_archivo_medalia( pCodigo CHAR(20) ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3	        CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr	        CHAR(150);
    DEFINE vUsuario         CHAR(20);
    DEFINE vLLave           CHAR(200);
    DEFINE vNomarch         CHAR(100);
    DEFINE vRutaOrigen      CHAR(100);
    DEFINE vRutaDestino     CHAR(100);
    DEFINE vNomarchSalida   CHAR(100);
    DEFINE vRutaOriginales  CHAR(100);
    DEFINE vNomarch_salida  CHAR(100);
    
    
    LET cCodRet         = '';
    LET cCodRet2        = 0;
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET vUsuario        = '';
    LET vLLave          = '';
    LET vNomarch        = '';
    LET vRutaOrigen     = '';
    LET vRutaDestino    = '';
    LET vNomarchSalida  = '';
    LET vRutaOriginales = '';
    LET vNomarch_salida = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_medalia.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
--    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_masttro.out";
--    TRACE ON;
    
    FOREACH
        SELECT TRIM(usuario), TRIM(llave), TRIM(nomarch), TRIM(ruta_origen), TRIM(nomarch_salida), TRIM(ruta_destino), TRIM(ruta_originales)
          INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales    
          FROM bdinteg:si_configura_pgp_chq
         WHERE codigo = pCodigo
         ORDER BY secuencia
        
        IF vUsuario <> user THEN
            LET cCodRet = '200';
            RETURN cCodRet;
        END IF;
        
        SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/'||TRIM(vUsuario)||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin" > '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        SYSTEM 'echo "export HOME=/home/'||TRIM(vUsuario)||'" >> '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        SYSTEM 'echo "/opt/pgp/bin/pgp --encrypt -i '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' -r '||''''||TRIM(vLLave)||''''||" --armor --compression --output "||TRIM(vRutaDestino)||TRIM(vNomarch_salida)||'" >> '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        SYSTEM '/usr/bin/chmod 777 '||TRIM(vRutaOrigen)||'blinda_medalia.sh';   
        SYSTEM '/usr/bin/sh '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        SYSTEM '/usr/bin/mv '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' '||vRutaOriginales; 
    END FOREACH;
    
    LET cCodRet = '00000';
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE;