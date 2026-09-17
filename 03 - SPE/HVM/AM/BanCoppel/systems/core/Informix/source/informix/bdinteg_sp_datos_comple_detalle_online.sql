CREATE PROCEDURE "informix".sp_datos_comple_detalle_online(pFolio char(25))
    RETURNING CHAR(5) as codret, CHAR(20) as Cliente, CHAR(25) as Folio, INTEGER as Elemento, CHAR(50) as Descripcion;

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
DEFINE sCodRetEdad      CHAR(5);
DEFINE pap_fecha_nac	DATE;
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

DEFINE sfolio           	CHAR(25);
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
DEFINE wBegin               CHAR (1);

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
LET sCodRetEdad		 ='';

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
LET pap_fecha_nac	 = '';
LET wBegin           ="";

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
		   RETURN iSqlErr, snumcte, sfolio, selemento, sdescripcion;
                END IF;
	END EXCEPTION;

		/*ON EXCEPTION IN (-535)
		LET wBegin = "S";
      --ROLLBACK WORK;
      --COMMIT WORK;
		BEGIN WORK;
		COMMIT WORK;
		END EXCEPTION WITH RESUME;*/
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
--SET DEBUG FILE TO '/informix/sp_datos_comple_detalle_online.out';
--SET DEBUG FILE TO 'sergio.out';
--TRACE ON;

	--BEGIN WORK;
       --BUSCANDO LA EQUIVALENCIA

       LET snumcte          = "";
       LET sfolio           = "";
       LET ssexo            = "";
       LET sedo_civil       = "";

       DELETE FROM "informix".si_datos_comple_deta
       WHERE folio = pFolio;


       FOREACH

	  		SELECT numcte,numero_control,ap_sexo, estado_civil, tpo_edo_civil, meses_edo_civil, tipo_residencia, tpo_domicilio, actividad,
				   tpo_trabajo, tpo_trab_ant, pers_dependen, escolaridad, pers_domicilio,
				   pers_trabajan,ejecutivo,DATE(fecha_hora), ap_fecha_nac
		    INTO snumcte,sfolio,ssexo,sedo_civil, stpo_edo_civi, smeses_edo_civi, stipo_residencia, stiempo_domicilio, sactividad,
				 stiempo_trabajo, stiempo_trab_ant, spers_dependen, sescolaridad, spers_domicilio,
				 spers_trabajan,sejecutivo,sfecha_insert, pap_fecha_nac
			FROM "informix".si_solicitud_movil_online
			WHERE numero_control = pFolio
			AND numcte IS NOT NULL

		EXECUTE PROCEDURE bdinteg:"informix".sp_ObtenerEdadPersona(TODAY,pap_fecha_nac)
		INTO sCodRetEdad,sedad;
	  		IF sCodRetEdad <> '000' THEN
			LET scodret = '0003';
			RETURN scodret, NVL(snumcte,''), NVL(sfolio,''), selemento , NVL(sdescripcion,'');
		END IF;

		LET scomp_ingresos   = "1";

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
/*RGH
        IF sedo_civilt = 'S' THEN
            LET stpo_edo_civi = sedad;
        END IF;
        
RGH*/

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
		   
			IF spers_trabajant = '0' THEN
				LET spers_trabajant = '';
			END IF;

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

		--COMMIT WORK;
		--IF wbegin = 'N' THEN
			--BEGIN WORK;
		--END IF;	 
	 
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

CREATE PROCEDURE "informix".sp_alta_ctebpi()
RETURNING CHAR(5) as codret, CHAR(20) as Cliente;

DEFINE iSqlErr		INTEGER;
DEFINE sCodRet          CHAR(5);
DEFINE sRetCod          CHAR(5);
DEFINE ssCodRet         CHAR(6);
DEFINE ssMensaje        CHAR(80);
DEFINE sErrProc		CHAR(5);
DEFINE sPaterno         CHAR(26);
DEFINE sMaterno         CHAR(26);

--VARIABLES PARA COMPARACION DE NOMBRES
DEFINE pFolio           CHAR(12);
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

--VARIABLES PARA COMPARACION DE DATOS
DEFINE sgrupo           CHAR(3);
DEFINE spregunta        CHAR(50);
DEFINE selemento        INTEGER;
DEFINE sdescripcion     CHAR(50);
DEFINE sparametro_sp    CHAR(15);
DEFINE scampo           CHAR(15);
DEFINE sclave           CHAR(2);
DEFINE sdescrip_clave   CHAR(50);

DEFINE sid                INTEGER;
DEFINE snumcte            CHAR(20);
DEFINE scte_coppel        CHAR(1);
DEFINE snumcte_coppel     CHAR(20);
DEFINE sapell_paterno     CHAR(26);
DEFINE sapell_materno     CHAR(26);
DEFINE snombre1           CHAR(26);
DEFINE snombre2           CHAR(26);
DEFINE sfecha_nac         CHAR(10);
DEFINE srfc               CHAR(13);
DEFINE ssexo              CHAR(1);
DEFINE scalle             CHAR(40);
DEFINE scolonia           CHAR(60);
DEFINE sdeleg_mpo         CHAR(40);
DEFINE sedo               CHAR(40);
DEFINE scod_postal        CHAR(5);
DEFINE sdomicilio_actual  CHAR(1);
DEFINE sdomicilio_alta    CHAR(1);
DEFINE scve_elector       CHAR(18);
DEFINE scurp              CHAR(18);
DEFINE sfecha_registro    CHAR(7);
DEFINE sestado            CHAR(2);
DEFINE smunicipio         CHAR(3);
DEFINE sseccion           CHAR(4);
DEFINE slocalidad         CHAR(4);
DEFINE semision           CHAR(4);
DEFINE svigencia          CHAR(4);
DEFINE socr               CHAR(13);
DEFINE snivel_ingresos    CHAR(8);
DEFINE sedo_civil         CHAR(1);
DEFINE stpo_edo_civil     CHAR(2);
DEFINE smeses_edo_civil   CHAR(2);
DEFINE stipo_residencia   CHAR(1);
DEFINE stiempo_domicilio  CHAR(2);
DEFINE sactividad         CHAR(2);
DEFINE ssubactividad      CHAR(2);
DEFINE sempresa           CHAR(60);
DEFINE stel_trabajo       CHAR(10);
DEFINE stiempo_trabajo    CHAR(2);
DEFINE stiempo_trab_ant   CHAR(2);
DEFINE sedad              CHAR(2);
DEFINE spers_dependen     CHAR(2);
DEFINE scomp_ingresos     CHAR(2);
DEFINE sescolaridad       CHAR(2);
DEFINE spers_domicilio    CHAR(2);
DEFINE spais_nacimiento	  CHAR(3);
DEFINE spers_trabajan     CHAR(2);
DEFINE sproducto          CHAR(3);
DEFINE stelefono_casa     CHAR(10);
DEFINE stelefono          CHAR(10);
DEFINE scarrier           CHAR(1);
DEFINE semail             CHAR(100);
DEFINE snum_tdc_coppel    CHAR(12);
DEFINE sstatus_tdc_coppel CHAR(2);
DEFINE snum_prestamo      CHAR(12);
DEFINE sstatus_prestamo   CHAR(2);
DEFINE snum_tdc_bcoppel   CHAR(12);
DEFINE sstatus_tdc_bcoppel CHAR(2);
DEFINE ssituacion_esp     CHAR(1);
DEFINE scausa             CHAR(4);
DEFINE sfolio             CHAR(12);
DEFINE sgeolocalizacion   CHAR(20);
DEFINE sfirma_bc          CHAR(1);
DEFINE sfotografias       CHAR(1);
DEFINE sprocesado_trans   CHAR(1);
DEFINE sfolio_procesado   CHAR(1);
DEFINE sstatus_solicitud  CHAR(8);
DEFINE sejecutivo         CHAR(8);
DEFINE sfecha_insert      DATE;

DEFINE svt_seccion      CHAR(1);
DEFINE svt_empresa      CHAR(3);
DEFINE svt_numcte       CHAR(20);
DEFINE svt_ejecutivo    CHAR(8);
DEFINE svt_fecha_hoy    DATE;
DEFINE svt_elemento     INTEGER;
DEFINE svt_descrip      CHAR(50);

DEFINE ssvt_seccion     CHAR(3);
DEFINE svt_grupo        CHAR(3);
DEFINE svt_folio        CHAR(12);
DEFINE ssvt_elemento    INTEGER;
DEFINE svt_cod_ret      CHAR(3);
DEFINE svt_clave        CHAR(2);

DEFINE sivt_empresa     CHAR(3);
DEFINE sivt_secuencia   INTEGER;
DEFINE sivt_descripcion CHAR(20);
DEFINE siivt_secuencia  INTEGER;

DEFINE svt_campo1       CHAR(1);
DEFINE svt_campo2       CHAR(1);
DEFINE svt_campo3       CHAR(1);

DEFINE svt_producto     CHAR(4);
DEFINE svt_mensaje      VARCHAR(200);
DEFINE svt_dia          CHAR(2);
DEFINE svt_mes          CHAR(2);
DEFINE svt_year         CHAR(4);
DEFINE svt_solic1       CHAR(20);
DEFINE svt_solic2       CHAR(20);
DEFINE svt_solic3       CHAR(20);
DEFINE svt_sucursal     CHAR(4);

DEFINE ssvt_Pais        CHAR(3);
DEFINE ssvt_sEdo        CHAR(2);
DEFINE ssvt_sCiudad     CHAR(5);
DEFINE ssvt_sCP         CHAR(5);
DEFINE ssvt_sNumCiudad  CHAR(6);
DEFINE ssvt_sColonia    CHAR(6);
DEFINE ssvt_sMpo        CHAR(5);
DEFINE vt_fech_hora     CHAR(19);
DEFINE vt_fech_hora2    CHAR(19);
DEFINE sSPosc1          CHAR(1);
DEFINE sSPosc2          CHAR(1);
DEFINE sSPosc3          CHAR(1);
DEFINE sSPosc4          CHAR(1);
DEFINE sSPosc5          CHAR(1);
DEFINE sTpoCte 			CHAR(1);

DEFINE sAP_paterno     CHAR(26);
DEFINE sAP_materno     CHAR(26);
DEFINE sAP_nombre1     CHAR(26);
DEFINE sAP_nombre2     CHAR(26);
DEFINE sAP_fecha_nac   CHAR(10);
DEFINE sAP_rfc         CHAR(13);
DEFINE sAP_dia          CHAR(2);
DEFINE sAP_mes          CHAR(2);
DEFINE sAP_year         CHAR(4);
DEFINE sAP_fecnac       CHAR(10);

DEFINE o_telefono1      CHAR(13);
DEFINE o_telefono2      CHAR(13);
DEFINE o_telefono3      CHAR(13);
DEFINE o_extension      CHAR(5);
DEFINE vTipoTel         SMALLINT;
DEFINE vCanal           SMALLINT;
DEFINE v_CodRetTel      CHAR(5);

DEFINE sDesc		    CHAR(50);
DEFINE vctaclabe 		CHAR(18);
DEFINE vcuenta      	CHAR(20);

DEFINE cCodRetLN	    CHAR(6);
DEFINE sFechaLN         CHAR(10);
DEFINE lenScve_elector  CHAR(18);
DEFINE subScve_elector  CHAR(2);
DEFINE iTotal 			INTEGER;
DEFINE icontar			SMALLINT;
DEFINE vsMensaje 		CHAR(6);
DEFINE vsNumSolicitud   CHAR(10);
DEFINE vns_token		CHAR(10);

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

LET sseccion         = "";
LET sgrupo           = "";
LET spregunta        = "";
LET selemento        = 0;
LET sdescripcion     = "";
LET sparametro_sp    = "";
LET scampo           = "";
LET sclave           = "";
LET sdescrip_clave   = "";

LET sid                = 0;
LET snumcte            = "";
LET scte_coppel        = "";
LET snumcte_coppel     = "";
LET sapell_paterno     = "";
LET sapell_materno     = "";
LET snombre1           = "";
LET snombre2           = "";
LET sfecha_nac         = "";
LET srfc               = "";
LET ssexo              = "";
LET scalle             = "";
LET scolonia           = "";
LET sdeleg_mpo         = "";
LET sedo               = "";
LET scod_postal        = "";
LET sdomicilio_actual  = "";
LET sdomicilio_alta    = "";
LET scve_elector       = "";
LET scurp              = "";
LET sfecha_registro    = "";
LET sestado            = "";
LET smunicipio         = "";
LET sseccion           = "";
LET slocalidad         = "";
LET semision           = "";
LET svigencia          = "";
LET socr               = "";
LET snivel_ingresos    = "";
LET sedo_civil         = "";
LET stpo_edo_civil     = "";
LET smeses_edo_civil   = "";
LET stipo_residencia   = "";
LET stiempo_domicilio  = "";
LET sactividad         = "";
LET ssubactividad      = "";
LET sempresa           = "";
LET stel_trabajo       = "";
LET stiempo_trabajo    = "";
LET stiempo_trab_ant   = "";
LET sedad              = "";
LET spers_dependen     = "";
LET scomp_ingresos     = "";
LET sescolaridad       = "";
LET spers_domicilio    = "";
LET spais_nacimiento   = "";
LET spers_trabajan     = "";
LET sproducto          = "";
LET stelefono_casa     = "";
LET stelefono          = "";
LET scarrier           = "";
LET semail             = "";
LET snum_tdc_coppel    = "";
LET sstatus_tdc_coppel = "";
LET snum_prestamo      = "";
LET sstatus_prestamo   = "";
LET snum_tdc_bcoppel   = "";
LET sstatus_tdc_bcoppel = "";
LET ssituacion_esp     = "";
LET scausa             = "";
LET sfolio             = "";
LET sgeolocalizacion   = "";
LET sfirma_bc        = "";
LET sfotografias       = "";
LET sprocesado_trans   = "";
LET sfolio_procesado   = "";
LET sstatus_solicitud  = "";
LET sfecha_insert      = "";
LET svt_empresa        = "";
LET svt_numcte         = "";
LET svt_ejecutivo      = "";
LET sejecutivo         = "";
LET svt_fecha_hoy      = "";
LET svt_elemento       = 0;
LET svt_descrip        = "";

LET ssvt_seccion       = "";
LET svt_grupo          = "";
LET svt_folio          = "";
LET ssvt_elemento      = 0;
LET svt_cod_ret        = "";
LET svt_clave          = "";

LET ssCodRet           = "000000";
LET ssMensaje          = " ";
LET sivt_empresa       = "";
LET sivt_secuencia     = 0;
LET sivt_descripcion   = "";
LET siivt_secuencia    = 4;

LET svt_campo1         = "";
LET svt_campo2         = "";
LET svt_campo3         = "";
LET svt_producto       = "";
LET svt_empresa        = "001";
LET svt_mensaje        = "En este acto otorgo expresamente mi consentimiento para que EL RESPONSABLE pueda utilizar mis datos personales exclusivamente para los fines que se encuentran asentados en el Aviso de Privacidad.";
LET svt_dia            = "";
LET svt_mes            = "";
LET svt_year           = "";
LET svt_solic1         = "";
LET svt_solic2         = "";
LET svt_solic3         = "";
LET svt_sucursal       = "5003";

LET ssvt_Pais          = "";
LET ssvt_sEdo          = "";
LET ssvt_sCiudad       = "";
LET ssvt_sCP           = "";
LET ssvt_sNumCiudad    = "";
LET ssvt_sColonia      = "";
LET ssvt_sMpo          = "";
LET vt_fech_hora = current hour to fraction;
LET sSPosc1            = '';
LET sSPosc2            = '';
LET sSPosc3            = '';
LET sSPosc4            = '';
LET sSPosc5            = '';
LET sTpoCte			   = '';

LET sAP_paterno        = '';
LET sAP_materno        = '';
LET sAP_nombre1        = '';
LET sAP_nombre2        = '';
LET sAP_fecha_nac      = '';
LET sAP_rfc            = '';
LET sAP_dia            = '';
LET sAP_mes            = '';
LET sAP_year           = '';
LET sAP_fecnac         = '';

LET o_telefono1        ='';
LET o_telefono2        ='';
LET o_telefono3        ='';
LET o_extension        ='';
LET vTipoTel           =0;
LET vCanal             =1;
LET v_CodRetTel        ='';

LET sDesc              ='';
LET vctaclabe 		= "";
LET vcuenta 		= '';
	
LET cCodRetLN           ='';   
LET sFechaLN            ='';   
LET lenScve_elector     = "";
LET subScve_elector     = "";
LET iTotal = 0;
LET icontar = 0;
LET vsNumSolicitud = '0000000000';

BEGIN
ON EXCEPTION SET iSqlErr
	IF iSqlErr <> 0 THEN
	   RETURN iSqlErr, snumcte;
        END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/aw/out/sp_alta_ctebpi.out';
--TRACE ON;

SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} fecha_hoy INTO svt_fecha_hoy
FROM bdinteg:si_fechas
WHERE empresa = '001';


		
	FOREACH 
		--Arma Cursor Principal de bpi_cliente
		SELECT id, numcte, cte_coppel, numcte_coppel, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, rfc,
			  sexo, ap_calle, colonia, deleg_mpo, edo, cod_postal, domicilio_actual, domicilio_alta, cve_elector, curp,
			  fecha_registro, estado, municipio, seccion, localidad, emision, vigencia, ocr, nivel_ingresos, edo_civil,
			  tpo_edo_civil, meses_edo_civil, tipo_residencia , tiempo_domicilio , actividad, subactividad, empresa, tel_trabajo,
			  tiempo_trabajo, tiempo_trab_ant, edad, pers_dependen, comp_ingresos, escolaridad, pers_domicilio,pers_trabajan, producto,
			  telefono_casa, telefono, carrier, email, num_tdc_coppel, status_tdc_coppel, num_prestamo, status_prestamo, num_tdc_bcoppel,
			  status_tdc_bcoppel, situacion_esp, causa, folio, geolocalizacion, firma_bc, fotografias, procesado_trans, folio_procesado,
			  status_solicitud,ejecutivo,fecha_insert, ap_apell_paterno, ap_apell_materno, ap_nombre1, ap_nombre2, ap_fecha_nac,pais_nac

		INTO sid, snumcte, scte_coppel, snumcte_coppel, sapell_paterno, sapell_materno, snombre1, snombre2, sfecha_nac, srfc,
			ssexo, scalle, scolonia, sdeleg_mpo, sedo, scod_postal, sdomicilio_actual, sdomicilio_alta, scve_elector, scurp,
			sfecha_registro, sestado, smunicipio, sseccion, slocalidad, semision, svigencia, socr, snivel_ingresos, sedo_civil,
			stpo_edo_civil, smeses_edo_civil, stipo_residencia, stiempo_domicilio, sactividad, ssubactividad, sempresa, stel_trabajo,
			stiempo_trabajo, stiempo_trab_ant, sedad, spers_dependen, scomp_ingresos, sescolaridad, spers_domicilio,spers_trabajan, sproducto,
			stelefono_casa, stelefono, scarrier, semail, snum_tdc_coppel, sstatus_tdc_coppel, snum_prestamo, sstatus_prestamo, snum_tdc_bcoppel,
			sstatus_tdc_bcoppel, ssituacion_esp, scausa, sfolio, sgeolocalizacion, sfirma_bc, sfotografias, sprocesado_trans, sfolio_procesado,
			sstatus_solicitud,sejecutivo,sfecha_insert, sAP_paterno, sAP_materno, sAP_nombre1, sAP_nombre2, sAP_fecha_nac,spais_nacimiento
		FROM bpi_cliente
		WHERE folio_procesado = '0'
		
		LET icontar = icontar + 1;
		
		LET pFolio = TRIM(sfolio);  
		
		LET sAP_paterno      = TRIM(sAP_paterno);
		LET sAP_materno      = TRIM(sAP_materno);
		LET sAP_nombre1      = TRIM(sAP_nombre1);
		LET sAP_nombre2      = TRIM(sAP_nombre2);
		LET ssexo            = TRIM(ssexo);
		LET snumcte          = TRIM(snumcte);
		LET scve_elector     = TRIM(scve_elector);

		 --Valida formato de la fecha de nacimiento
		LET svt_dia = "";
		LET svt_mes = "";
		LET svt_year = "";
		LET svt_dia = sfecha_nac[1,2];
		LET svt_mes = sfecha_nac[4,5];
		LET svt_year = sfecha_nac[7,10];

		IF LENGTH(svt_year)<=2 THEN
			LET svt_year="19"||svt_year;
		END IF;
		LET sfecha_nac = TRIM(svt_mes)||''||TRIM(svt_dia)||''||TRIM(svt_year);

		IF ssexo="H" THEN
			LET ssexo="M";
		ELIF ssexo="M" THEN
			LET ssexo="F";
		END IF;

	
        ----------------------------------------------------------                     
		--OBTENIENDO LOS DATOS DEL RFC MODIFICADO Y COMPARANDO CON EL RFC ACTUAL
		LET sAP_dia = "";
		LET sAP_mes = "";
		LET sAP_year = "";
		LET sAP_dia = sAP_fecha_nac[1,2];
		LET sAP_mes = sAP_fecha_nac[4,5];
		LET sAP_year = sAP_fecha_nac[7,10];
		
		
		IF LENGTH(sAP_year)<=2 THEN
			LET sAP_year="19"||sAP_year;
		END IF;
		LET sAP_fecnac = TRIM(sAP_mes)||''||TRIM(sAP_dia)||''||TRIM(sAP_year);

		CALL sp_calcularrfc(sAP_paterno, sAP_materno, sAP_nombre1||' '||sAP_nombre2, TO_DATE(sAP_fecnac, '%m%d%Y'))
		RETURNING sRetCod, sAP_rfc;
		
		LET sAP_rfc = trim(sAP_rfc);

		IF sRetCod = '00000' THEN
			UPDATE bpi_cliente SET ap_rfc=sAP_rfc WHERE folio=pFolio; 
			 
		END IF;
		
		
        --COMPARANDO RFC ORIGINAL CONTRA RFC NUEVO, SI LOS RFC'S SON DISTINTOS...
		IF srfc<>sAP_rfc THEN
			--SE BUSCA QUE NO EXISTA EL RFC MODIFICADO EN LA TABLA DE CLIENTES
			select FIRST 1 1 INTO iTotal FROM si_cliente where rfc=sAP_rfc;
			
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				--EN CASO DE EXISTIR, SE TOMA EL CLIENTE MODIFICADO Y SE ACTUALIZA LA TABLA DE SOLICITUD MOVIL CON ESE DATO
				
				LET snumcte=(select numcte FROM si_cliente where rfc=sAP_rfc);
				LET snumcte=trim(snumcte);
				
				UPDATE bpi_cliente SET ap_rfc=sAP_rfc WHERE folio=pFolio; 

				LET lenScve_elector = LENGTH(scve_elector);
				LET subScve_elector = SUBSTR(TRIM(scve_elector),13,2);
				
				IF lenScve_elector =18 THEN
					IF subScve_elector NOT IN('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
						LET scve_elector='';
					ELSE
						LET scve_elector=substr(scve_elector,13,2); 
						 
					END IF;
				END IF;
			ELSE 
				--EN CASO DE QUE NO EXISTA EL RFC MODIFICADO, SE ACTUALIZAN LAS VARIABLES DE NOMBRES Y FECHA DE NACIMIENTO 
				--CON LOS DATOS DE LOS CAMPOS MODIFICADOS
				LET sapell_paterno= sAP_paterno;
				LET sapell_materno= sAP_materno;
				LET snombre1= sAP_nombre1;
				LET snombre2= sAP_nombre2;
				LET srfc= sAP_rfc;
				LET sfecha_nac= sAP_fecnac;
			END IF;
		END IF;
		
        IF snumcte IS NULL OR snumcte = "" THEN

			IF LENGTH(spers_domicilio)<=2 THEN
			   LET spers_domicilio="0"||spers_domicilio;
			END IF;
			
            ---Ejecuta la Rutina de ALTA de Clientes
			LET lenScve_elector = LENGTH(scve_elector);
			LET subScve_elector = SUBSTR(TRIM(scve_elector),13,2);
				
			IF lenScve_elector = 18 THEN
				IF subScve_elector NOT IN('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
					LET scve_elector='';
				ELSE
					LET scve_elector=substr(scve_elector,13,2);									
										
				END IF;
			END IF;
			
			IF ssexo="X" THEN
			
				CALL ctemoral(svt_empresa,"A",snumcte,"AL",svt_sucursal,sejecutivo,"02","2", snombre2,srfc,							  								
							  TO_DATE(sfecha_nac, '%m%d%Y'), "1", sapell_materno, snombre1 , stel_trabajo,"","999", "036", "", sejecutivo, TO_DATE(sfecha_nac, '%m%d%Y'), scurp)
				RETURNING sRetCod,svt_numcte;
							
			ELSE
								
				CALL ctefisico(svt_empresa,"A",snumcte,svt_sucursal,sejecutivo,"01","2",sapell_paterno,sapell_materno,snombre1,snombre2,srfc,
							  "32","000"," ","000","000","1"," ",snumcte_coppel,"01"," "," ","0000000",
							  sfecha_nac,scve_elector,"001"," ",sedo_civil," ",sactividad,ssexo,scurp,"A",socr," ",0," ",semail," "," ",
							 sescolaridad,stipo_residencia,0," ",0," "," "," ",sejecutivo," ",spers_domicilio,spais_nacimiento)
				RETURNING sRetCod,svt_numcte;

			END IF;	
			
            --Valida el Codigode Retorno de esta Ejecucion
			IF (sRetCod != "000") AND (sRetCod != "104") AND (sRetCod != "106") AND (sRetCod != "118")  THEN
				LET snumcte = svt_numcte;
				
				
				LET sCodRet = "00001";
				--Actualiza el status_valua por el folio
				UPDATE bpi_cliente
				SET(status_valua)=(2)
				WHERE folio = pFolio; 

				RETURN sCodRet, NVL(snumcte,'') WITH RESUME;
                
			ELSE
				LET snumcte = svt_numcte;
				IF (sRetCod = "104") OR (sRetCod = "106") OR (sRetCod = "118") THEN
					LET snumcte = (select numcte from si_cliente where rfc=srfc);
					LET snumcte = trim(snumcte);
					LET svt_numcte=snumcte;
					LET lenScve_elector = LENGTH(scve_elector);
					LET subScve_elector = SUBSTR(TRIM(scve_elector),13,2);
				
						IF lenScve_elector =18 THEN
							IF subScve_elector NOT IN('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33') THEN
								LET scve_elector='';
							ELSE
								LET scve_elector=substr(scve_elector,13,2);									
					
							END IF;
						END IF;

				END IF;
				---Actualiza el Numero de Cliente
				UPDATE bpi_cliente SET(numcte)=(svt_numcte)
				WHERE folio_procesado = "0"
				AND folio = pFolio;
			END IF;
        ELSE
			LET lenScve_elector = LENGTH(scve_elector);
			LET subScve_elector = SUBSTR(TRIM(scve_elector),13,2);
				
			
			
				UPDATE bpi_cliente
				SET(numcte)=(svt_numcte)
				WHERE folio_procesado = "0"
				AND folio = pFolio;
			
					   
				LET sRetCod = "000";
	
		END IF;
	
		--Validando Codigo Postal
		CALL sp_valida_numero(scod_postal)
		RETURNING sRetCod, sSPosc1, sSPosc2, sSPosc3, sSPosc4, sSPosc5;

		IF sRetCod<>"00000" THEN			
			SELECT cp INTO scod_postal FROM si_ptf WHERE id_ptf='0010' AND tipo = 'S';
		END IF;

		--Se ejecuta la Actualizacion de la Direccion Actual.
		CALL sp_act_dirmovil(scod_postal,snumcte)
		RETURNING sRetCod,ssvt_Pais,ssvt_sEdo,ssvt_sCiudad,ssvt_sCP,ssvt_sNumCiudad,ssvt_sColonia,ssvt_sMpo;

		IF sRetCod != "00000" THEN
			
			LET sCodRet = "00016";
			--Actualiza el status_valua por el folio

			UPDATE bpi_cliente
			SET(status_valua)=(2)
			WHERE folio = pFolio;

			RETURN sCodRet, NVL(snumcte,'') WITH RESUME;
            
		END IF;

		
		---Ejecuta la Rutina de ALTA de Direcciones
		SELECT tipo_cliente  INTO sTpoCte FROM bdinteg:si_cliente 
		WHERE numcte=snumcte;
		
		
		IF sTpoCte ="2" THEN	 
			CALL direcciones(svt_empresa,"A",snumcte,0,"1",scalle," ",ssvt_sMpo," ",ssvt_Pais,ssvt_sEdo,ssvt_sCiudad,scod_postal,"1",
			stelefono_casa,"2",stelefono,"3",stel_trabajo," "," "," "," ",ssvt_sNumCiudad," "," "," ",
			134176,ssvt_sColonia," ","N",0,0,0,0,0,0,0," ",sejecutivo,svt_fecha_hoy,svt_sucursal)
			RETURNING sRetCod;

			IF sRetCod != "000" THEN
			
				LET sCodRet = "00003";
				--Actualiza el status_valua por el folio
				UPDATE bpi_cliente
				SET(status_valua)=(2)
				WHERE folio = pFolio;

				RETURN sCodRet, NVL(snumcte,'') WITH RESUME;
                
			END IF;
		ELSE
			-- // VALIDA LA INFORMACION DE LOS TELEFONOS DEL CLIENTE
			SELECT telefono
			INTO o_telefono1
			FROM "informix".si_telefonos_actual
			WHERE numcte = snumcte
			AND tipo_tel = 1;

			IF o_telefono1 is null THEN
				LET o_telefono1 = ' ';
			END IF;

			IF o_telefono1 <> stelefono_casa THEN
				IF svt_sucursal = '5002' THEN
					LET vCanal = 12;
				END IF;

				IF ( ( stelefono_casa is not null AND stelefono_casa <> '' ) AND ( stelefono_casa is not null AND stelefono_casa <> '' ) ) THEN
					LET vTipoTel = 1;
					CALL "informix".sp_registra_telefonos(svt_empresa, snumcte, stelefono_casa, vTipoTel, '', 0, vCanal, sejecutivo)
					RETURNING v_CodRetTel;
				END IF;
			END IF;

			SELECT telefono
			INTO o_telefono2
			FROM "informix".si_telefonos_actual
			WHERE numcte = snumcte
			AND tipo_tel = 2;

			IF o_telefono2 is null THEN
				LET o_telefono2 = ' ';
			END IF;

			IF o_telefono2 <> stelefono THEN
				IF svt_sucursal = '5002' THEN
					LET vCanal = 12;
				END IF;

				IF ( ( stelefono is not null AND stelefono <> '' ) AND ( stelefono is not null AND stelefono <> '' ) ) THEN
					LET vTipoTel = 2;
					CALL "informix".sp_registra_telefonos(svt_empresa, snumcte, stelefono, vTipoTel, '', scarrier, vCanal, sejecutivo)
					RETURNING v_CodRetTel;
				END IF;
			END IF;

			SELECT telefono, extension
			INTO o_telefono3, o_extension
			FROM "informix".si_telefonos_actual
			WHERE numcte = snumcte
			AND tipo_tel = 3;

			IF o_telefono3 is null THEN
				LET o_telefono3 = ' ';
			END IF;

			IF o_telefono3 <> stel_trabajo THEN
				IF svt_sucursal = '5002' THEN
					LET vCanal = 12;
				END IF;

				IF ( ( stel_trabajo is not null AND stel_trabajo <> '' ) AND ( stel_trabajo is not null AND stel_trabajo <> '' ) ) THEN
					LET vTipoTel = 3;
					CALL "informix".sp_registra_telefonos(svt_empresa, snumcte, stel_trabajo, vTipoTel, o_extension, 0, vCanal, sejecutivo)
					RETURNING v_CodRetTel;
				END IF;
			END IF;
		END IF;
			
		--valida la ejecucion de los Ingresos por la nueva Solicitud
		LET sRetCod = "000";
		CALL sp_ingresos("A",svt_empresa,snumcte,0,"T",sempresa,"0",0,"","",snivel_ingresos,sejecutivo,svt_fecha_hoy,"0",0,sactividad,ssubactividad,0,0,0,0)
		RETURNING sRetCod;

		LET sRetCod = "000";		
		
		LET svt_sucursal="0131";
		
        IF snumcte IS NOT NULL AND snumcte <> "" THEN
		
			---Ejecuta la Rutina de ALTA de Cuenta
			SELECT tpo_persona  INTO sstatus_tdc_coppel FROM bdinteg:si_cliente 
			WHERE numcte=snumcte;
			
			
			IF sstatus_tdc_coppel ="02" THEN	 
				
				CALL bdicheq:cuenta1(svt_empresa,sejecutivo,'0002','1600',snumcte,
				'01','1','3','001',sejecutivo,'1','           ',0  ,'','','','','','',0,'N','05','05','01','01','01','01','01','',0.00)
				RETURNING sRetCod, vcuenta, vctaclabe;
			ELSE
				CALL bdicheq:cuenta1(svt_empresa,sejecutivo,'0002','1400',snumcte,
				'01','1','3','001',sejecutivo,'1','           ',0  ,'','','','','','',0,'N','05','05','01','01','01','01','01','',0.00)
				RETURNING sRetCod, vcuenta, vctaclabe;
				
			END IF;
			
			IF sRetCod= '000' THEN
				
				LET svt_sucursal="5003";
			
				CALL sp_acivarserviciobpi ('1', svt_empresa, snumcte, '10', '10198V138501', svt_sucursal, sejecutivo, '127.0.0.1', '2')
				RETURNING sRetCod, vsMensaje;

			
				
				IF(sRetCod='00000')THEN
				
					IF sstatus_tdc_coppel ="02" THEN	 
							CALL bdibei:sp_senet_altaservicioempresanet( snumcte, "30", sejecutivo, "4", svt_sucursal )
							RETURNING ssCodRet, vsMensaje;
							CALL bdibei:sp_administradorespm( snumcte, "017523360", "A", "1234567891234", "REPRESENTANTE1", "LEGAL1", "PRUEBA1", "", "1")
							RETURNING ssCodRet, vsMensaje,snumcte, vsNumSolicitud;

							
					ELSE

					
						LET vns_token = 'M0002D' || sid;
						
						INSERT INTO bdinteg:"informix".si_bpitoken(empresa, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro, tipo_token)
							 VALUES(svt_empresa, snumcte, vns_token, svt_sucursal, '10198V138501', 140, CURRENT, CURRENT, '2');
						
						INSERT INTO bdibpi:"informix".bpi_tokensolicitud (solicitud, numcte, id_status, sucursal, f_solicitud, sec_domicilio, f_atencion, usr_solicita, empresa, tipo, folio_suc)
						 VALUES ((SELECT LPAD(CAST(NVL(MAX(Trim(solicitud) + 1),0000000001)  AS INTEGER), 10, '0') FROM bdibpi:"informix".bpi_tokensolicitud), snumcte, 330, svt_sucursal, '1900-01-01 12:00:00', '', '1900-01-01 12:00:00', sejecutivo, svt_empresa, '8','SINCOMIS03142801');
						
						LET vsNumSolicitud = (SELECT LPAD(CAST(MAX(Trim(solicitud)) AS INTEGER), 10, '0') FROM bdibpi:"informix".bpi_tokensolicitud  WHERE numcte = snumcte);
						
						
						--Valida mensaje de privacidad
						CALL sp_insert_autor_privacidad(svt_empresa, snumcte, svt_sucursal, "1" , svt_mensaje)
						RETURNING ssCodRet;
						
						LET vns_token = 'BCPL12' || sid;
						
						CALL bdibpi:"informix".sp_registra_servicio_bex(1,snumcte,stelefono,vcuenta,'21963105237A14BA399CDEB3FD5E4D9D794362CB63BEB7216E1BE449C7073D520AD2A2DB461FD83D7B1F80B533C7EE2C9B7CABD94DA2FDBFD6A4BBD3C6559643','',vns_token,vns_token,'Dalvik/2.1.0 (Android Build/O11019)','Android BCPPEL','Dalvik/2.1.0 (Android Build/O11019)','','')
						RETURNING sRetCod,vsMensaje;
						
						CALL bdibpi:"informix".sp_actualizacion_servicio_bpi(stelefono,snumcte,vns_token,vns_token,'Android BCPPEL' ,'1')
						RETURNING sRetCod,vsMensaje;
					
				
					END IF;
					
				END IF;
				
				

			END IF;
			
			UPDATE bpi_cliente SET(solicitud)=(vsNumSolicitud), cuenta=vcuenta	
			WHERE folio = pFolio; 
			
		END IF;
		

		LET vt_fech_hora = "";
		SELECT DBINFO('utc_to_datetime',sh_curtime) INTO vt_fech_hora
		FROM sysmaster:"informix".sysshmvals;

		UPDATE bpi_cliente
		SET(fecha_profin)=(vt_fech_hora), folio_procesado = '1'
		WHERE folio = pFolio; 
		
		RETURN sCodRet, snumcte WITH RESUME;
		
	END FOREACH; 

	IF (icontar = 0) THEN
		LET sCodRet = '00001';
		RETURN sCodRet, snumcte;
	END IF;	
	
	--RETURN sCodRet, snumcte WITH RESUME;
	
END
END PROCEDURE
DOCUMENT
"SPL para el alta 100 Clientes para pruebas de operaciÃ³n",
"base de datos: bdinteg",
"AVF 20211014-Se agrega el cteMoral"
;

CREATE PROCEDURE "informix".sp_biobex_rostro
(
    pnum_serial        	INTEGER,
    pempresa           	VARCHAR(3),
    psucursal          	VARCHAR(4),
    pnumcte            	VARCHAR(20),
    psecuencia         	INTEGER,
    pestado            	VARCHAR(1),
    prmapa             	CHAR(9000),
    prmapa2            	CHAR(9000),
    prmapa3            	CHAR(9000),
    pusuario           	VARCHAR(8),
    ptemplate_procesado	VARCHAR(1),
    pmac               	VARCHAR(17),
    pip                	VARCHAR(15),
    pfecha_alta        	VARCHAR(20),
    pusuario_camb      	VARCHAR(8),
    pfecha_camb        	VARCHAR(20),
    pfech_ult_camb     	VARCHAR(60),
	pOp1				VARCHAR(20),
	pOp2				VARCHAR(20),
	pOp3				VARCHAR(20)
)

	RETURNING CHAR(5), VARCHAR(200), VARCHAR(20), VARCHAR(4), VARCHAR(200),VARCHAR(200), VARCHAR(200);

	
	--SP BIOMETRIAS ROSTROS BEX BDINTEG
	
	-- Definicion de variables --
	
	DEFINE cCodRet          	CHAR(5);
    DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr 			INTEGER;
    DEFINE cInfoErr         	CHAR(100);
	DEFINE cMensaje				VARCHAR(200); 
	DEFINE cOp1					VARCHAR(200); 
	DEFINE cOp2					VARCHAR(200); 
	DEFINE cOp3					VARCHAR(200);
	
	DEFINE cConteo  			INTEGER;	
	
    DEFINE cnum_serial        	INTEGER;
    DEFINE cempresa           	VARCHAR(3);
    DEFINE csucursal          	VARCHAR(4);
    DEFINE cnumcte            	VARCHAR(20);
    DEFINE csecuencia         	INTEGER;
    DEFINE cestado            	VARCHAR(1);
    DEFINE crmapa             	CHAR(9000);
    DEFINE crmapa2            	CHAR(9000);
    DEFINE crmapa3            	CHAR(9000);
    DEFINE cusuario           	VARCHAR(8);
    DEFINE ctemplate_procesado	VARCHAR(1);
    DEFINE cmac               	VARCHAR(17);
    DEFINE cip                	VARCHAR(15);
    DEFINE cfecha_alta        	DATE;
    DEFINE cusuario_camb      	VARCHAR(8);
    DEFINE cfecha_camb        	DATE;
    DEFINE cfech_ult_camb     	DATETIME YEAR to SECOND;
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_biobex_rostro.out';
	--TRACE ON; 
	--SET DEBUG FILE TO '/INFORMIXTMP/HMLG/sp_biobex_rostro.out';
	--TRACE ON;
	
	
	LET cCodRet='00009';
    LET iSqlErr='';
	LET iIsamErr=0;
    LET cInfoErr='';
	LET cMensaje=''; 
	LET cOp1=''; 
	LET cOp2=''; 
	LET cOp3='';
	
	LET cConteo = 0;
	
    LET cnum_serial = 0;
    LET cempresa='';
    LET csucursal='';
    LET cnumcte='';
    LET csecuencia= 0;
    LET cestado='';
    LET crmapa='';
    LET crmapa2='';
    LET crmapa3 ='';
    LET cusuario='';
    LET ctemplate_procesado='';
    LET cmac='';
    LET cip='';
    LET cfecha_alta= MDY('01','01','1900');
    LET cusuario_camb='';
    LET cfecha_camb= MDY('01','01','1900');
    LET cfech_ult_camb = MDY('01','01','1900');
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envÃ­o codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_biobex_rostro_sitesp");
								
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP BDD "||cCodRet||"|"||cnumcte||"|"||csucursal;

                RETURN cCodRet, cMensaje, cnumcte, csucursal, cOp1,cOp2, cOp3;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		-- CAMPOS REQUERIDOS TABLA bdinteg:si_cte_rostro --> empresa,estado,num_serial,numcte,secuencia, sucursal
		
		--IF (pempresa <> '' OR pempresa IS NOT NULL) AND (pnumcte <> '' OR pnumcte IS NOT NULL) AND (psucursal <> '' OR psucursal IS NOT NULL) THEN
		
		
		IF  (pnumcte IS NULL OR pnumcte = '') OR (psucursal IS NULL OR psucursal = '') OR (pempresa IS NULL OR pempresa = '') OR (pusuario IS NULL OR pusuario = '') THEN 
			
			LET cCodRet = "00010";
			LET cMensaje = "Datos Obligatorios no Ingresados";
				
		ELSE
			LET cnum_serial = pnum_serial;
			LET cempresa = pempresa;
			LET csucursal = psucursal;
			LET cnumcte = pnumcte;
			LET csecuencia = psecuencia;
			LET cestado = pestado;
			LET crmapa= prmapa;
			LET crmapa2 = prmapa2;
			LET crmapa3 = prmapa3;
			LET cusuario = pusuario;
			LET ctemplate_procesado = ptemplate_procesado;
			LET cmac = pmac;
			LET cip = pip;
			--LET cfecha_alta = pfecha_alta;
			LET cusuario_camb = pusuario_camb;
			--LET cfecha_camb = pfecha_camb;
			--LET cfech_ult_camb = pfech_ult_camb;
			
			LET cMensaje = cusuario||psucursal;
			
			
			EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,cempresa,cnumcte,'P',115,'1','S',csucursal,cusuario,cMensaje,NULL,NULL) INTO cCodRet,cOp1,cOp2,cOp3;
			
			-- sp_insertasitesp RETURN cCodRet, sPonderacion,cSituacionCte,sCausaCte;
			
			IF  cCodRet = "00000" THEN
				LET cMensaje = "Ejecucion Exitosa";
		
			ELSE
				LET cMensaje = "Error de sp_insertasitesp";
			END IF;
				
		END IF;
			
		--LET cCodRet = "00000";
		--LET cMensaje = "Ejecucion Exitosa_D";
	
		RETURN cCodRet, cMensaje, cnumcte, csucursal, cOp1,cOp2, cOp3;
	END;
END PROCEDURE;