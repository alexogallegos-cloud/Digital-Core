CREATE PROCEDURE "informix".sp_datos_comple_detalle(pFolio char(12))
    RETURNING CHAR(5) as codret, CHAR(20) as Cliente, CHAR(12) as Folio, INTEGER as Elemento, CHAR(50) as Descripcion;

DEFINE iSqlErr          INTEGER;
DEFINE sCodRet          CHAR(5);
DEFINE sRetCod          CHAR(5);
DEFINE sErrProc         CHAR(5);
DEFINE sNumCte          CHAR(9);
DEFINE sRFC             CHAR(13);
DEFINE sPaterno         CHAR(26);
DEFINE sMaterno         CHAR(26);
DEFINE sNombre1         CHAR(26);
DEFINE sNombre2         CHAR(26);
DEFINE sFecha_Nac       CHAR(10);
DEFINE sTelefono        CHAR(10);
DEFINE sCteCoppel       CHAR(1);
DEFINE sNumCteCoppel    CHAR(11);
DEFINE sNumCteMovil     CHAR(9);
DEFINE sCodPos          CHAR(5);
DEFINE sDomicAct        CHAR(1);
DEFINE sNumSolBanco     CHAR(12);
DEFINE sNumSolCoppel    CHAR(12);
DEFINE sNumSolPresPer   CHAR(12);
DEFINE sFolioMovil      CHAR(15);
DEFINE sTipoBusqueda    CHAR(2);
DEFINE sEnviaSMS        CHAR(1);
DEFINE sCarrier         CHAR(1);
DEFINE sEmpresa         CHAR(60);
DEFINE sTelTrab         CHAR(10);

--VARIABLES PARA COMPARACION DE NOMBRES
DEFINE sNom1A           CHAR(26);
DEFINE sNom2A           CHAR(26);
DEFINE sApPatA          CHAR(26);
DEFINE sApMatA          CHAR(26);
DEFINE sFecNacA         CHAR(10);
DEFINE sNom1B           CHAR(26);
DEFINE sNom2B           CHAR(26);
DEFINE sApPatB          CHAR(26);
DEFINE sApMatB          CHAR(26);
DEFINE sFecNacB         CHAR(10);
DEFINE dPorcentaje      DECIMAL(6,1);
DEFINE dParamPorc       DECIMAL(6,1);
DEFINE sRFCCortoA       CHAR(10);
DEFINE sRFCCortoB       CHAR(10);
DEFINE sOCRMovil        CHAR(9);
DEFINE sOCR             CHAR(13);

--VARIABLES PARA COMPARACION DE DATOS
DEFINE sseccion         CHAR(3);
DEFINE sgrupo           CHAR(3);
DEFINE spregunta        CHAR(50);
DEFINE selemento        INTEGER;
DEFINE sdescripcion     CHAR(50);
DEFINE sparametro_sp    CHAR(15);
DEFINE scampo           CHAR(15);
DEFINE sclave           CHAR(2);
DEFINE sdescrip_clave   CHAR(50);

DEFINE sfolio           	CHAR(12);
DEFINE ssexo            	CHAR(1);
DEFINE sedo_civil       	CHAR(1);
DEFINE stpo_edo_civi    	CHAR(2);
DEFINE smeses_edo_civi  	CHAR(2);
DEFINE stipo_residencia 	CHAR(1);
DEFINE stiempo_domicilio 	CHAR(2);
DEFINE sactividad       	CHAR(2);
DEFINE stiempo_trabajo  	CHAR(2);
DEFINE stiempo_trab_ant 	CHAR(2);
DEFINE sedad            	CHAR(2);
DEFINE spers_dependen   	CHAR(2);
DEFINE scomp_ingresos   	CHAR(2);
DEFINE sescolaridad     	CHAR(2);
DEFINE spers_domicilio  	CHAR(2);
DEFINE spers_trabajan   	CHAR(2);
DEFINE sejecutivo       	CHAR(8);
DEFINE sfecha_insert    	DATE;

DEFINE svt_seccion      	CHAR(1);
DEFINE svt_entero       	CHAR(2);

DEFINE ssexot 				CHAR(1);
DEFINE sedo_civilt 			CHAR(1);
DEFINE stpo_edo_civit		CHAR(2);
DEFINE smeses_edo_civit 	CHAR(2);
DEFINE stipo_residenciat  	CHAR(1);
DEFINE stiempo_domiciliot 	CHAR(2);
DEFINE sactividadt 			CHAR(2);
DEFINE stiempo_trabajot 	CHAR(2);
DEFINE stiempo_trab_antt 	CHAR(2);
DEFINE sedadt 				CHAR(2);
DEFINE spers_dependent 		CHAR(2);
DEFINE scomp_ingresost 		CHAR(2);
DEFINE sescolaridadt 		CHAR(2);
DEFINE spers_domiciliot 	CHAR(2);
DEFINE spers_trabajant 		CHAR(2);

LET iSqlErr          =0;
LET sCodRet          ='00000';
LET sRetCod          ="99999";
LET sErrProc         ='';
LET sNumCte          ='';
LET sRFC             ='';
LET sPaterno         ='';
LET sMaterno         ='';
LET sNombre1         ='';
LET sNombre2         ='';
LET sFecha_Nac       ='';
LET sTelefono        ='';
LET sCteCoppel       ='';
LET sNumCteCoppel    ='';
LET sNumCteMovil     ='';
LET sCodPos          ='';
LET sDomicAct        ='';
LET sNumSolBanco     ='';
LET sNumSolCoppel    ='';
LET sNumSolPresPer   ='';
LET sFolioMovil      ='';
LET sTipoBusqueda    ='';
LET sEnviaSMS        ='0';
LET sCarrier         ='';

LET sNom1A           ='';
LET sNom2A           ='';
LET sApPatA          ='';
LET sApMatA          ='';
LET sFecNacA         ='';
LET sNom1B           ='';
LET sNom2B           ='';
LET sApPatB          ='';
LET sApMatB          ='';
LET sFecNacB         ='';
LET dPorcentaje      =0;
LET dParamPorc       =0;
LET sRFCCortoA       ='';
LET sRFCCortoB       ='';
LET sOCRMovil        ='';
LET sOCR             ='';
LET sEmpresa         ='';
LET sTelTrab         ='';

LET sseccion         = "";
LET sgrupo           = "";
LET spregunta        = "";
LET selemento        = 0;
LET sdescripcion     = "";
LET sparametro_sp    = "";
LET scampo           = "";
LET sclave           = "";
LET sdescrip_clave   = "";

LET snumcte          = "";
LET sfolio           = "";
LET ssexo            = "";
LET sedo_civil       = "";
LET stpo_edo_civi    = "";
LET smeses_edo_civi  = "";
LET stipo_residencia = "";
LET stiempo_domicilio = "";
LET sactividad       = "";
LET stiempo_trabajo  = "";
LET stiempo_trab_ant = "";
LET sedad            = "";
LET spers_dependen   = "";
LET scomp_ingresos   = "";
LET sescolaridad     = "";
LET spers_domicilio  = "";
LET spers_trabajan   = "";
LET sejecutivo       = "";
LET sfecha_insert    = "";
LET svt_seccion      = "2";
LET svt_entero       = '0';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
		   RETURN iSqlErr, snumcte, sfolio, selemento, sdescripcion;
                END IF;
	END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--SET DEBUG FILE TO '/tmp/anj/movil/sp_cons_folio_movil.sql';
--SET DEBUG FILE TO 'sergio.out';
--TRACE ON;

       --BUSCANDO LA EQUIVALENCIA

       LET snumcte          = "";
       LET sfolio           = "";
       LET ssexo            = "";
       LET sedo_civil       = "";

       DELETE FROM "informix".si_datos_comple_deta
       WHERE folio = pFolio;

       FOREACH
        SELECT numcte,folio,ap_sexo,edo_civil, tpo_edo_civil, meses_edo_civil, tipo_residencia, tiempo_domicilio, actividad,
               tiempo_trabajo, tiempo_trab_ant, edad, pers_dependen, comp_ingresos, escolaridad, pers_domicilio,
               pers_trabajan,ejecutivo,fecha_insert
       INTO snumcte,sfolio,ssexo,sedo_civil, stpo_edo_civi, smeses_edo_civi, stipo_residencia, stiempo_domicilio, sactividad,
             stiempo_trabajo, stiempo_trab_ant, sedad, spers_dependen, scomp_ingresos, sescolaridad, spers_domicilio,
             spers_trabajan,sejecutivo,sfecha_insert
        FROM "informix".si_solicitud_movil
        WHERE folio = pFolio
        AND numcte IS NOT NULL


        IF sfolio IS NOT NULL AND ssexo IS NOT NULL THEN
		
		   LET ssexot = TRIM(ssexo);
           
           SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = ssexot
           AND grupo = "2";

           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
        ELSE
           LET sRetCod ="001";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","2",sfolio,0,sRetCod," ");
           EXIT FOREACH;
        END IF;

        IF sfolio IS NOT NULL AND sedo_civil IS NOT NULL THEN
			
		   LET sedo_civilt = TRIM(sedo_civil);
		
           SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = sedo_civilt
           AND grupo = "3";

           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
        ELSE
           LET sRetCod ="002";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","3",sfolio,0,sRetCod," ");
           EXIT FOREACH;

        END IF;

        IF stpo_edo_civi IS NULL OR stpo_edo_civi < 0 THEN
           LET stpo_edo_civi = 0;
        ELSE
           IF stpo_edo_civi > 59 AND stpo_edo_civi < 99 THEN
              LET stpo_edo_civi = "76";
           END IF; 
        END IF;

        IF sfolio IS NOT NULL AND stpo_edo_civi IS NOT NULL AND stpo_edo_civi != "" THEN
           ---Hay que validar por pocision.
           LET svt_entero = '0';
           LET svt_entero = stpo_edo_civi;
           LET stpo_edo_civi = svt_entero;
		   
		   LET stpo_edo_civit = TRIM(stpo_edo_civi);

           SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = stpo_edo_civit
           AND seccion = svt_seccion
           AND grupo = "4";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE
           LET sRetCod ="003";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","4",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="004";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","4",sfolio,0,sRetCod," ");
           
           EXIT FOREACH;

        END IF;


        IF smeses_edo_civi IS NULL OR TRIM(smeses_edo_civi) ='' OR smeses_edo_civi > 11 THEN
           LET smeses_edo_civi = "-1";
        END IF;

        IF sfolio IS NOT NULL AND smeses_edo_civi IS NOT NULL AND smeses_edo_civi != "" THEN
           
		   LET smeses_edo_civit = TRIM(smeses_edo_civi);
		   
		   SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = smeses_edo_civit
           AND seccion = svt_seccion
           AND grupo = "41";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE
           LET sRetCod ="005";

           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","41",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="006";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","41",sfolio,0,sRetCod," ");
           EXIT FOREACH;
        END IF;

        IF sfolio IS NOT NULL AND stipo_residencia IS NOT NULL AND stipo_residencia != "" THEN
           
		   LET stipo_residenciat = TRIM(stipo_residencia);
		   
		   SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = stipo_residenciat
           AND seccion = svt_seccion
           AND grupo = "5";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE
           LET sRetCod ="007";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","5",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="008";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","5",sfolio,0,sRetCod," ");
           EXIT FOREACH;
        END IF;

        IF stiempo_domicilio IS NULL OR stiempo_domicilio < 0 THEN

           LET stiempo_domicilio = "0";
        ELSE

           IF stiempo_domicilio > 75 AND stiempo_domicilio <= 99 THEN
              LET stiempo_domicilio = "75";
           END IF;

        END IF;

        IF sfolio IS NOT NULL AND stiempo_domicilio IS NOT NULL AND stiempo_domicilio != "" THEN
           ---Hay que validar por pocision.
           LET svt_entero = '0';
           LET svt_entero = stiempo_domicilio;
           LET stiempo_domicilio = svt_entero;
		   
		   LET stiempo_domiciliot = TRIM(stiempo_domicilio);

           SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = stiempo_domiciliot
           AND seccion = svt_seccion
           AND grupo = "6";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE
           LET sRetCod ="009";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","6",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="010";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","6",sfolio,0,sRetCod," ");
           EXIT FOREACH;
        END IF;

        IF sfolio IS NOT NULL AND sactividad IS NOT NULL AND sactividad != "" THEN
           
		   LET sactividadt = TRIM(sactividad);
		   
		   SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = sactividadt
           AND seccion = svt_seccion
           AND grupo = "7";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE
           LET sRetCod ="011";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","7",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="012";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","7",sfolio,0,sRetCod," ");
           EXIT FOREACH;
        END IF;


        IF stiempo_trabajo IS NULL OR stiempo_trabajo < 0 THEN

           LET stiempo_trabajo = "0";

        ELSE

           IF stiempo_trabajo > 61 AND stiempo_trabajo <= 99 THEN
              LET stiempo_trabajo = "NO";
           END IF;
           
        END IF;

        IF sfolio IS NOT NULL AND stiempo_trabajo IS NOT NULL AND stiempo_trabajo != "" THEN
           ---Hay que validar por pocision.
           LET svt_entero = '0';
           LET svt_entero = stiempo_trabajo;
           LET stiempo_trabajo = svt_entero;
		   
		   LET stiempo_trabajot = TRIM(stiempo_trabajo);

           SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = stiempo_trabajot
           AND seccion = svt_seccion
           AND grupo = "8";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE
           LET sRetCod ="013";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","8",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="014";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","8",sfolio,0,sRetCod," ");
           EXIT FOREACH;

        END IF;
        
        IF stiempo_trabajo>=2 THEN 
            LET stiempo_trab_ant = "NO";
        ELSE
            IF stiempo_trab_ant IS NULL OR stiempo_trab_ant < 0 THEN
               LET stiempo_trab_ant = "NO";
            ELSE
               IF stiempo_trab_ant > 77 AND stiempo_trab_ant <= 99 THEN
                  LET stiempo_trab_ant = "NO";
               END IF;
            END IF;
        END IF;

        IF sfolio IS NOT NULL AND stiempo_trab_ant IS NOT NULL AND stiempo_trab_ant != "" THEN

            ---Hay que validar por pocision.
           LET svt_entero = '0';
           LET svt_entero = stiempo_trab_ant;
           LET stiempo_trab_ant = svt_entero;

           LET stiempo_trab_antt = TRIM(stiempo_trab_ant);
		   
		   SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = stiempo_trab_antt
           AND seccion = svt_seccion
           AND grupo = "9";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE
           LET sRetCod ="015";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","9",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="016";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","9",sfolio,0,sRetCod," ");
           EXIT FOREACH;
        END IF;

        IF sedad IS NULL OR sedad < 18 THEN
           LET sedad = "18";
        ELSE

           IF sedad > 71 AND sedad <= 99 THEN
              LET sedad = "71";
           END IF;
        END IF;

        IF sfolio IS NOT NULL AND sedad IS NOT NULL AND sedad != "" THEN

           --Valida la eded, para saber si es lineal o en rango
           IF sedad <= 25 THEN
              
			  LET sedadt = TRIM(sedad);
			  
			  SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
              INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
              FROM "informix".si_datos_complementarios_detalle
              WHERE clave = sedadt
              AND seccion = svt_seccion
              AND grupo = "10";

              IF sseccion IS NOT NULL THEN
              ---Inserta el Detalle por folio
              INSERT INTO "informix".si_datos_comple_deta
              VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);

              ELSE
              LET sRetCod ="017";
              LET sCodRet = sRetCod;
              ---Inserta el Detalle por folio Erroneo
              INSERT INTO "informix".si_datos_comple_deta
              VALUES("2","10",sfolio,0,sRetCod," ");
              EXIT FOREACH;
              END IF;
           ELSE
               IF sedad >= 26 AND sedad <= 30 THEN
                        SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo,
                        clave,descrip_clave
                        INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
                        FROM "informix".si_datos_complementarios_detalle
                        WHERE clave = "26"
                        AND seccion = svt_seccion
                        AND grupo = "10";

                        IF sseccion IS NOT NULL THEN
                           ---Inserta el Detalle por folio
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
                        ELSE
                           LET sRetCod ="018";
                           LET sCodRet = sRetCod;
                            ---Inserta el Detalle por folio Erroneo
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES("2","10",sfolio,0,sRetCod," ");
                           EXIT FOREACH;
                        END IF;
               END IF;
               IF sedad >= 31 AND sedad <= 35 THEN
                        SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo,
                        clave,descrip_clave
                        INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
                        FROM "informix".si_datos_complementarios_detalle
                        WHERE clave = "31"
                        AND seccion = svt_seccion
                        AND grupo = "10";

                        IF sseccion IS NOT NULL THEN
                           ---Inserta el Detalle por folio
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
                        ELSE
                           LET sRetCod ="019";
                           LET sCodRet = sRetCod;
                            ---Inserta el Detalle por folio Erroneo
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES("2","10",sfolio,0,sRetCod," ");
                           EXIT FOREACH;
                        END IF;
               END IF;
               IF sedad >= 36 AND sedad <= 40 THEN
                        SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo,
                        clave,descrip_clave
                        INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
                        FROM "informix".si_datos_complementarios_detalle
                        WHERE clave = "36"
                        AND seccion = svt_seccion
                        AND grupo = "10";

                        IF sseccion IS NOT NULL THEN
                           ---Inserta el Detalle por folio
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
                        ELSE
                           LET sRetCod ="020";
                           LET sCodRet = sRetCod;
                            ---Inserta el Detalle por folio Erroneo
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES("2","10",sfolio,0,sRetCod," ");
                           EXIT FOREACH;
                        END IF;
               END IF;
               IF sedad >= 41 AND sedad <= 45 THEN
                        SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo,
                        clave,descrip_clave
                        INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
                        FROM "informix".si_datos_complementarios_detalle
                        WHERE clave = "41"
                        AND seccion = svt_seccion
                        AND grupo = "10";

                        IF sseccion IS NOT NULL THEN
                           ---Inserta el Detalle por folio
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
                        ELSE
                           LET sRetCod ="021";
                           LET sCodRet = sRetCod;
                            ---Inserta el Detalle por folio Erroneo
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES("2","10",sfolio,0,sRetCod," ");
                           EXIT FOREACH;
                        END IF;
               END IF;
               IF sedad >= 46 AND sedad <= 50 THEN
                        SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo,
                        clave,descrip_clave
                        INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
                        FROM "informix".si_datos_complementarios_detalle
                        WHERE clave = "46"
                        AND seccion = svt_seccion
                        AND grupo = "10";

                        IF sseccion IS NOT NULL THEN
                           ---Inserta el Detalle por folio
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
                        ELSE
                           LET sRetCod ="022";
                           LET sCodRet = sRetCod;
                            ---Inserta el Detalle por folio Erroneo
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES("2","10",sfolio,0,sRetCod," ");
                           EXIT FOREACH;
                        END IF;
               END IF;
               IF sedad >= 51 AND sedad <= 55 THEN
                        SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo,
                        clave,descrip_clave
                        INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
                        FROM "informix".si_datos_complementarios_detalle
                        WHERE clave = "51"
                        AND seccion = svt_seccion
                        AND grupo = "10";

                        IF sseccion IS NOT NULL THEN
                           ---Inserta el Detalle por folio
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
                        ELSE
                           LET sRetCod ="023";
                           LET sCodRet = sRetCod;
                            ---Inserta el Detalle por folio Erroneo
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES("2","10",sfolio,0,sRetCod," ");
                           EXIT FOREACH;
                        END IF;
               END IF;
               IF sedad >= 56 AND sedad <= 60 THEN
                        SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo,
                        clave,descrip_clave
                        INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
                        FROM "informix".si_datos_complementarios_detalle
                        WHERE clave = "56"
                        AND seccion = svt_seccion
                        AND grupo = "10";

                        IF sseccion IS NOT NULL THEN
                           ---Inserta el Detalle por folio
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
                        ELSE
                           LET sRetCod ="024";
                           LET sCodRet = sRetCod;
                            ---Inserta el Detalle por folio Erroneo
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES("2","10",sfolio,0,sRetCod," ");
                           EXIT FOREACH;
                        END IF;
               END IF;
               IF sedad >= 61 AND sedad <= 65 THEN
                        SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo,
                        clave,descrip_clave
                        INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
                        FROM "informix".si_datos_complementarios_detalle
                        WHERE clave = "61"
                        AND seccion = svt_seccion
                        AND grupo = "10";

                        IF sseccion IS NOT NULL THEN
                           ---Inserta el Detalle por folio
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
                        ELSE
                           LET sRetCod ="025";
                           LET sCodRet = sRetCod;
                            ---Inserta el Detalle por folio Erroneo
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES("2","10",sfolio,0,sRetCod," ");
                           EXIT FOREACH;
                        END IF;
               END IF;
               IF sedad >= 66 AND sedad <= 70 THEN
                        SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo,
                        clave,descrip_clave
                        INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
                        FROM "informix".si_datos_complementarios_detalle
                        WHERE clave = "66"
                        AND seccion = svt_seccion
                        AND grupo = "10";

                        IF sseccion IS NOT NULL THEN
                           ---Inserta el Detalle por folio
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
                        ELSE
                           LET sRetCod ="026";
                           LET sCodRet = sRetCod;
                            ---Inserta el Detalle por folio Erroneo
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES("2","10",sfolio,0,sRetCod," ");
                           EXIT FOREACH;
                        END IF;
               END IF;
               IF sedad >= 71 THEN
                        SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo,
                        clave,descrip_clave
                        INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
                        FROM "informix".si_datos_complementarios_detalle
                        WHERE clave = "71"
                        AND seccion = svt_seccion
                        AND grupo = "10";

                        IF sseccion IS NOT NULL THEN
                           ---Inserta el Detalle por folio
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
                        ELSE
                           LET sRetCod ="027";
                           LET sCodRet = sRetCod;
                            ---Inserta el Detalle por folio Erroneo
                           INSERT INTO "informix".si_datos_comple_deta
                           VALUES("2","10",sfolio,0,sRetCod," ");
                           EXIT FOREACH;
                        END IF;
               END IF;
           END IF;
        ELSE
           LET sRetCod ="028";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","10",sfolio,0,sRetCod," ");
           EXIT FOREACH;
        END IF;

        IF spers_dependen IS NULL OR spers_dependen < 0 THEN

           LET spers_dependen = "0";
       
        ELSE

           IF spers_dependen > 11 AND spers_dependen <= 99 THEN
              LET spers_dependen = "11";
           END IF;

        END IF;

        IF sfolio IS NOT NULL AND spers_dependen IS NOT NULL AND spers_dependen != "" THEN
           ---Hay que validar por pocision.
           LET svt_entero = '0';
           LET svt_entero = spers_dependen;
           LET spers_dependen = svt_entero;

           LET spers_dependent = TRIM(spers_dependen);
		   
		   SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = spers_dependent
           AND seccion = svt_seccion
           AND grupo = "11";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE
           LET sRetCod ="029";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","11",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="030";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","11",sfolio,0,sRetCod," ");
           EXIT FOREACH;
        END IF;

        IF sfolio IS NOT NULL AND scomp_ingresos IS NOT NULL AND scomp_ingresos != "" THEN
           IF scomp_ingresos != "1" THEN
              LET scomp_ingresos = "1";
           END IF;
		   
		   LET scomp_ingresost = TRIM(scomp_ingresos);
		   
           SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = scomp_ingresost
           AND seccion = svt_seccion
           AND grupo = "38";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE
           LET sRetCod ="031";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","38",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="032";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","38",sfolio,0,sRetCod," ");
           EXIT FOREACH;
        END IF;

        IF sfolio IS NOT NULL AND sescolaridad IS NOT NULL AND sescolaridad != "" THEN
           
		   LET sescolaridadt = TRIM(sescolaridad);
		   
		   SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = sescolaridadt
           AND seccion = svt_seccion
           AND grupo = "21";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE
           LET sRetCod ="033";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","21",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="034";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","21",sfolio,0,sRetCod," ");
           EXIT FOREACH;
        END IF;

        IF spers_domicilio IS NULL OR spers_domicilio < 0 THEN
           LET spers_domicilio = "1";
        ELSE

           IF spers_domicilio > 10 AND spers_domicilio <= 99 THEN
              LET spers_domicilio = "10";
           END IF;

        END IF;

        IF sfolio IS NOT NULL AND spers_domicilio IS NOT NULL AND spers_domicilio != "" THEN
           
		   LET spers_domiciliot = TRIM(spers_domicilio);
		   
		   SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = spers_domiciliot
           and seccion = svt_seccion
           AND grupo = "22";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE
           LET sRetCod ="035";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","22",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="036";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","22",sfolio,0,sRetCod," ");
           EXIT FOREACH;
        END IF;

        ---Inserta el Detalle por folio
        INSERT INTO "informix".si_datos_comple_deta
        VALUES("2","16",sfolio,2,"000","NO");

        IF spers_trabajan IS NULL OR spers_trabajan < 0 THEN

           LET spers_trabajan = "1";

        ELSE

           IF spers_trabajan > 10 AND spers_trabajan <= 99 THEN
              LET spers_trabajan = "10";
           END IF;

        END IF;
        IF sfolio IS NOT NULL AND spers_trabajan IS NOT NULL AND spers_trabajan != "" THEN
           
		   LET spers_trabajant = TRIM(spers_trabajan);
		   
		   SELECT {+INDEX (bdinteg:si_datos_complementarios_detalle idx_detalle_movil)} seccion,grupo,pregunta,elemento,descripcion,parametro_sp,campo, clave,descrip_clave
           INTO sseccion, sgrupo, spregunta, selemento, sdescripcion, sparametro_sp, scampo, sclave, sdescrip_clave
           FROM "informix".si_datos_complementarios_detalle
           WHERE clave = spers_trabajant
           AND seccion = svt_seccion
           AND grupo = "39";

           IF sseccion IS NOT NULL THEN
           ---Inserta el Detalle por folio
           INSERT INTO "informix".si_datos_comple_deta
           VALUES(sseccion,sgrupo,sfolio,selemento,sCodRet,sdescripcion);
           ELSE

           LET sRetCod ="037";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","39",sfolio,0,sRetCod," ");
           EXIT FOREACH;
           END IF;
        ELSE
           LET sRetCod ="038";
           LET sCodRet = sRetCod;
           ---Inserta el Detalle por folio Erroneo
           INSERT INTO "informix".si_datos_comple_deta
           VALUES("2","39",sfolio,0,sRetCod," ");
           EXIT FOREACH;

        END IF;

     END FOREACH;

RETURN sCodRet, NVL(snumcte,''), NVL(sfolio,''), selemento , NVL(sdescripcion,'');
END
END PROCEDURE
DOCUMENT
"Spl para obtener la equivalencia de datos del los clientes ",
"base de datos: bdinteg",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 27/Febrero/2015",
"Ver.  : 1.0",
"Mod   : Se Modifica para Validacion de Rango de Edades",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 03/Marzo/2015",
"Mod   : Se Homologa el Grupo en la seleccion",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 04/Marzo/2015",
"Ver.  : 1.2",
"Mod   : Se Homologa los Minimos y Maximos en la seleccion de Grupo",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 18/Marzo/2015",
"Ver.  : 1.3",
"Mod   : Se Homologa los Codigos de Retorno e indices ",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 23/Abril/2015",
"Ver.  : 1.4",
"Mod   : Se Homologa los calores caracter a valores enteros ",
"AUTOR : Sergio Fabricio Ruiz Jimenez",
"FECHA : 05/Mayo/2015",
"Ver.  : 1.5",
"Mod   : Se cambia el campo sexo por ap_sexo *select L-184",
"AUTOR : Eduardo MM",
"FECHA : 27/Diciembre/2018",
"Ver.  : 1.5.1";

CREATE PROCEDURE "informix".sp_limiteperfil(pSucursal CHAR(4), pEjecutivo CHAR(8), pGerente CHAR(8))
	--DATOS A REGRESAR
	RETURNING  
	CHAR(5) AS cCodRet,
	INTEGER AS iLimite;
--========== DEFINIR VARIABLES =======
	DEFINE iSqlErr SMALLINT;
	DEFINE iSamErr SMALLINT;
	DEFINE cErrorInfo CHAR(40);
	DEFINE cCodRet CHAR(5);
	DEFINE iLimite INTEGER;
	DEFINE iGerente INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cHora1 CHAR(5);
	DEFINE cHora2 CHAR(5);
	DEFINE iNumCambios	INTEGER;
--============= INICIALIZA VARIABLES ============
	LET iSqlErr = 0;
	LET iSamErr = 0;
	LET cErrorInfo = '';
	LET cCodRet = '00000';
	LET iLimite = 0;
	LET iGerente = 0;
	LET cEjecutivo = '';
	LET cHora1 = '';
	LET cHora2 = '';
	LET iNumCambios = 0;
--============= TRAER CLIENTES ===================
BEGIN
	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		LET cCodRet = iSqlErr;
		RETURN  cCodRet,iLimite;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO "/informix/Acuellar/sp_limiteperfil.out";
	--TRACE ON;

	IF ( (NVL(pSucursal,'')) = '' OR (NVL(pEjecutivo,'')) = '' OR (NVL(pGerente,'')) = '' )  THEN
		LET cCodRet = '00001'; 
	ELSE
		-- Valida si un Ejecutivo ha dado de alta a mÃÂ¡s de un gerente
		SELECT COUNT(c.cod_usuario) 
		INTO iLimite
		FROM bdinteg: "informix".si_cambio_perf c
		INNER JOIN bdinteg: "informix".si_fechas f ON c.fecha_cambio = f.fecha_Hoy
		WHERE c.sucursal = pSucursal AND c.password_ant = 'E' AND c.password_nuevo = 'A';
		--AND c.cod_usuario = pEjecutivo;

		select valor
		into iNumCambios
		from si_param
		where cod_param = '471';

		IF iLimite <= iNumCambios then	

			-- Ultimo cambio de promoto a gerente de un empleado
			SELECT c.cod_usuario, max(c.hora_cambio)
			into cEjecutivo, cHora1
			FROM bdinteg: "informix".si_cambio_perf c
			INNER JOIN bdinteg: "informix".si_fechas f ON c.fecha_cambio = f.fecha_Hoy
			WHERE c.sucursal = pSucursal AND c.password_ant = 'E' AND c.password_nuevo = 'A'
			and c.hora_cambio = 
			(select max(hora_cambio) FROM bdinteg: "informix".si_cambio_perf
			where password_ant = 'E' AND password_nuevo = 'A' and sucursal = c.sucursal
			and fecha_cambio = f.fecha_Hoy)
			and c.cod_usuario <> pGerente
			GROUP BY cod_usuario;

			-- Revisar si ese empleado ya no es gerente
			SELECT max(c.hora_cambio)
			into cHora2
			FROM bdinteg: "informix".si_cambio_perf c
			INNER JOIN bdinteg: "informix".si_fechas f ON c.fecha_cambio = f.fecha_Hoy
			WHERE c.sucursal = pSucursal AND c.cod_usuario = cEjecutivo;

			IF cHora1 = cHora2 then

				LET cCodRet = '00001'; 
				-- es el ultimo cambio NO se puede

			elif cHora1 < cHora2 then

				LET cCodRet = '00000'; 
				-- ya NO es gerente

			end if;

		else

			LET cCodRet = '00002';

		END IF;

	END IF;

	RETURN cCodRet,iLimite;

END;
END PROCEDURE
DOCUMENT
'Folio: 466 - RQM 08 030 Limitar OFI Cantidad de Veces que Asigna el Perfil de Gerente',
'Autor: 97893323 Judith Moreno',
'BD: bdinteg',
'Solicita: CUTBERTO GONZALEZ',
'Fecha: 20/08/2018',
'Descripcion: Se crea procedimiento para obtener la cantidad de cambios de perfil de cualquier perfil a Gerente';

CREATE PROCEDURE "informix".sp_altasolicitudmovil_mx()
RETURNING CHAR(5);

--Declaracion de variables
DEFINE vcodret           CHAR(5);
DEFINE vcodretdet        CHAR(5);
DEFINE iSecuencia        INTEGER;
DEFINE iSqlErr           INTEGER;
DEFINE sid               INTEGER;
DEFINE snumcte           CHAR(20);
DEFINE sfolio            CHAR(12);
DEFINE sstatus_valua     INTEGER;
DEFINE sempresa          CHAR(3);
DEFINE svalor_param      INTEGER; 
DEFINE sfecha_insert     DATE;
DEFINE iNumCte			 CHAR(9);

--Inicializacion de variables
LET vcodret              = '000';
LET vcodretdet           = "000";
LET iSecuencia           = 0;
LET sid                  = 0;
LET snumcte              = "";
LET sfolio               = "";
LET sstatus_valua        = 0;
LET sempresa             = "";
LET svalor_param         = 0;
LET sfecha_insert        = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3; 

--SET DEBUG FILE TO '/informix/emm/sp_altasolicitudmovil.out';
--TRACE ON;

BEGIN
 ON EXCEPTION SET iSqlErr
     IF iSqlErr <> 0 THEN
	LET vcodret = iSqlErr;
	RETURN vCodret;
    END IF;
 END EXCEPTION

 --Efectua la revision del numero de folio-

 CALL bdinteg:sp_monitor_folio() RETURNING vcodret;

 IF TRIM(vcodret)!="000" THEN
    INSERT INTO "informix".si_valida_folio_detalle(folio, rutina, numcte, cod_ret, fecha)
        VALUES('','sp_altasolicitudmovil','',vcodret,current);
 END IF;

   ---Ejecuta Cursor principal de reviso de folios para solicitud movil
 FOREACH
        SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_valida_opera)} id, numcte, folio,status_valua,fecha_insert
        INTO sid, snumcte,sfolio,sstatus_valua,sfecha_insert
        FROM bdinteg:"informix".si_solicitud_movil
        WHERE bdinteg:si_solicitud_movil.folio_procesado = "0"
        AND bdinteg:si_solicitud_movil.status_valua = 0
        ORDER BY folio

        --Ejecuta rutina de alta de solicitud por folio
        IF sfolio IS NOT NULL THEN

            CALL sp_ALTA_CTEMOVIL(sfolio)
            RETURNING vcodretdet,snumcte;

            IF vcodretdet = "00000" OR vcodretdet = "000000" THEN

               UPDATE "informix".si_solicitud_movil
               SET(status_valua)=(1)
              WHERE folio = sfolio;

            END IF;
        END IF;
		
		IF snumcte <> '' THEN
			SELECT numcte INTO iNumCte FROM bdinteg:"informix".si_bitacora_ife where id_sol_movil <> '' and id_sol_movil = sid;
			
			IF iNumCte = '' THEN
				UPDATE bdinteg:"informix".si_bitacora_ife SET numcte = snumcte WHERE id_sol_movil = sid;
			END IF;
		END IF;
		
 END FOREACH;


RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
"Autor      : Sergio Fabricio Ruiz Jimenez",
"Descripcion: Ejecuta Cursor principal de folios para solicitud movil",
"Fecha      : 09/04/2015",
"Version    : 1.0",
"Modifico   : ",
"Autor      : Eduardo Martinez",
"Descripcion: Agrega el numcte a si_bitacora_ife",
"Fecha      : 01/11/2019",
"Version    : 1.0",
"Modifico   : ";

CREATE PROCEDURE "informix".sp_altasolicitudmovil_old()
RETURNING CHAR(5);

--Declaracion de variables
DEFINE vcodret           CHAR(5);
DEFINE vcodretdet        CHAR(5);
DEFINE iSecuencia        INTEGER;
DEFINE iSqlErr           INTEGER;
DEFINE sid               INTEGER;
DEFINE snumcte           CHAR(20);
DEFINE sfolio            CHAR(12);
DEFINE sstatus_valua     INTEGER;
DEFINE sempresa          CHAR(3);
DEFINE svalor_param      INTEGER; 
DEFINE sfecha_insert     DATE;
DEFINE iNumCte			 CHAR(9);

--Inicializacion de variables
LET vcodret              = '000';
LET vcodretdet           = "000";
LET iSecuencia           = 0;
LET sid                  = 0;
LET snumcte              = "";
LET sfolio               = "";
LET sstatus_valua        = 0;
LET sempresa             = "";
LET svalor_param         = 0;
LET sfecha_insert        = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3; 

--SET DEBUG FILE TO '/informix/emm/sp_altasolicitudmovil.out';
--TRACE ON;

BEGIN
 ON EXCEPTION SET iSqlErr
     IF iSqlErr <> 0 THEN
	LET vcodret = iSqlErr;
	RETURN vCodret;
    END IF;
 END EXCEPTION

 --Efectua la revision del numero de folio-

 CALL bdinteg:sp_monitor_folio() RETURNING vcodret;

 IF TRIM(vcodret)!="000" THEN
    INSERT INTO "informix".si_valida_folio_detalle(folio, rutina, numcte, cod_ret, fecha)
        VALUES('','sp_altasolicitudmovil','',vcodret,current);
 END IF;

   ---Ejecuta Cursor principal de reviso de folios para solicitud movil
 FOREACH
        SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_valida_opera)} id, numcte, folio,status_valua,fecha_insert
        INTO sid, snumcte,sfolio,sstatus_valua,sfecha_insert
        FROM bdinteg:"informix".si_solicitud_movil
        WHERE bdinteg:si_solicitud_movil.folio_procesado = "0"
        AND bdinteg:si_solicitud_movil.status_valua = 0
        ORDER BY folio

        --Ejecuta rutina de alta de solicitud por folio
        IF sfolio IS NOT NULL THEN

            CALL sp_ALTA_CTEMOVIL(sfolio)
            RETURNING vcodretdet,snumcte;

            IF vcodretdet = "00000" OR vcodretdet = "000000" THEN

               UPDATE "informix".si_solicitud_movil
               SET(status_valua)=(1)
              WHERE folio = sfolio;

            END IF;
        END IF;
		
		IF snumcte <> '' THEN
			SELECT {+INDEX(si_bitacora_ife idx_id_sol_mov_2019)} numcte INTO iNumCte FROM bdinteg:"informix".si_bitacora_ife where id_sol_movil <> '' and id_sol_movil = sid;
			
			IF iNumCte = '' THEN
				UPDATE {+INDEX(si_bitacora_ife idx_id_sol_mov_2019)} bdinteg:"informix".si_bitacora_ife SET numcte = snumcte WHERE id_sol_movil = sid;
			END IF;
		END IF;
		
 END FOREACH;


RETURN vcodret;
END;
END PROCEDURE
DOCUMENT
"Autor      : Sergio Fabricio Ruiz Jimenez",
"Descripcion: Ejecuta Cursor principal de folios para solicitud movil",
"Fecha      : 09/04/2015",
"Version    : 1.0",
"Modifico   : ",
"Autor      : Eduardo Martinez",
"Descripcion: Agrega el numcte a si_bitacora_ife",
"Fecha      : 01/11/2019",
"Version    : 1.0",
"Modifico   : ";

CREATE PROCEDURE "informix".sp_generar_reporte_sos()
RETURNING 	VARCHAR(6) AS cCodRet,
			VARCHAR(40) AS cMensaje;
			--VARCHAR(40) AS cRegistros;
			
		  
/*DEFINICION DE VARIABLES */

DEFINE 	cCodRet      	  VARCHAR(6);
DEFINE 	cMensaje      	  VARCHAR(40);
DEFINE 	cRegistros     	  VARCHAR(40);
DEFINE 	vsNombreArchivo   VARCHAR(50);
DEFINE 	vsNombreArchivo2  VARCHAR(50);
DEFINE  cSQL			  VARCHAR(250);
DEFINE  cSQL1			  LVARCHAR(500);
DEFINE  cSQL2			  LVARCHAR(500);
DEFINE  cSQL3			  LVARCHAR(500);
DEFINE  iCont			  INTEGER;	
DEFINE  iSqlErr			  INTEGER;
DEFINE	dFecha		      DATE;
DEFINE  vNumcte		      VARCHAR(20);
DEFINE  vNumcte2		  VARCHAR(20);
DEFINE  vNomCorr		      VARCHAR(104);
DEFINE  vNomINC		      VARCHAR(104);
DEFINE  vFechaNacCor	  DATE;
DEFINE  vFechaNacINC	  DATE;

/*FIN DE DEFINICION DE VARIABLES*/
LET cCodRet   = 0;
LET cMensaje   = '';
LET cRegistros = '';
LET vsNombreArchivo = '';
LET vsNombreArchivo2 = '';
LET cSQL	    = '';
LET cSQL1	    = '';
LET cSQL2	    = '';
LET cSQL3	    = '';	  
LET iCont	    = 0;	  
LET iSqlErr     = 0;
LET dFecha = DATE(0);
LET vNumcte	= '';
LET vNumcte2	= '';
LET vNomCorr	= '';
LET vNomINC	= '';
LET vFechaNacCor = DATE(0);
LET vFechaNacINC = DATE(0);




BEGIN
	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN -- manejador de errores
			LET cCodRet = iSqlErr;
			LET cMensaje  = 'ERROR AL GENERAR REPORTE';
		
			RETURN cCodRet,cMensaje;
		END IF;
	END EXCEPTION;
	

	
	
	--Nombre del archivo
	LET vsNombreArchivo = '/RESPALDOSNEW/REPORTE_CORRECCION_DATOS.csv';
	LET vsNombreArchivo2 = '/RESPALDOSNEW/REPORTE_FUSION_DATOS.csv';
						

		LET cSQL='dbaccess bdinteg /RESPALDOSNEW/generar_reporte_correcciones_sos.sql';
		SYSTEM cSQL;

		LET cSQL='dbaccess bdinteg /RESPALDOSNEW/generar_reporte_fusion_sos.sql';
		SYSTEM cSQL;
		
		LET cSQL2='zip /RESPALDOSNEW/REPORTE_CORRECCION_DATOS.zip -P 4846+16svh13th516*2019 /RESPALDOSNEW/REPORTE_CORRECCION_DATOS.csv';
		SYSTEM cSQL2;
		
		LET cSQL3='zip /RESPALDOSNEW/REPORTE_FUSION_DATOS.zip -P 4846+16svh13th516*2019 /RESPALDOSNEW/REPORTE_FUSION_DATOS.csv';
		SYSTEM cSQL3;
		
		LET cMensaje  = 'REPORTE GENERADO CORRECTAMENTE';
		
		LET cCodRet = '000000';

	RETURN cCodRet,cMensaje;
END;
END PROCEDURE;