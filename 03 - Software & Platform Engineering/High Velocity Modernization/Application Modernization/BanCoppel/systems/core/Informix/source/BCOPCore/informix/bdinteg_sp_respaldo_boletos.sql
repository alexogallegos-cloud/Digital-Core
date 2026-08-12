CREATE PROCEDURE "informix".sp_respaldo_boletos (pClaveSort CHAR(5), pdFechaRespaldo DATE)

    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,
              CHAR(1)  AS Reverso,
              CHAR(25) AS StorePro;              


   DEFINE v_codigo_retorno	CHAR(5);
   DEFINE v_mensaje	  	    CHAR(80);
   DEFINE v_reverso         CHAR(1);
   DEFINE v_store_pro       CHAR(25);

   DEFINE vi_valor      CHAR (50);

   DEFINE vsqlerr      INTEGER; 
   DEFINE pdrepositorio CHAR (60);
   

    DEFINE vsArchTemporal CHAR (15);
	DEFINE vsNomArchivo CHAR (40);
	DEFINE vsSQL CHAR (1100);
	DEFINE vsSQL1 CHAR (200);
	DEFINE vsSQL2 CHAR (700);
	DEFINE vsSQL3 CHAR (200);


       -- SET debug file TO "/ids10_1uc5/fmartinez_2/sorteo/batch_30nov/pba1/respalda_boletos.out";
       -- TRACE ON;

	
	LET vsArchTemporal = '';
	LET vsNomArchivo = '';
	LET vsSQL = '';
	LET vsSQL1 = '';
	LET vsSQL2 = '';
	LET vsSQL3 = '';



-- DECLARACION DE VARIABLES
             LET v_codigo_retorno = "00000";
             LET v_mensaje = "Proceso Inicia Correctamente...";
             LET v_reverso = '0';
             LET v_store_pro = 'sp_respaldo_boletos';
     
        	 LET vsNomArchivo = 'RESPALDOSORTEO_' || SUBSTRING (pdFechaRespaldo FROM 9 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 1 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 4 FOR 2) || '.unl' ;


            SET ISOLATION TO dirty READ;
            SET LOCK MODE TO wait 3;

 BEGIN
   ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exception, Verifique Datos SQL!";
            LET v_reverso = '1';         
            LET v_store_pro = 'sp_respalda_boletos';
         RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
        END IF;
   END EXCEPTION;
   
   /*VALIDA QUE LA BANDERA DEL CONCURSO 00002 SEA 2 Y ESTE ACTIVO EL SORTEO*/
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = pClaveSort AND pdFechaRespaldo BETWEEN  f_ini AND f_fin AND flag_sort = 2) THEN
        
		-- FMV 16-DIC-2010: La ruta del archivo serÃ¡ la misma
				 SELECT {+index (si_param 194_429)}  
						   valor
				   INTO vi_valor
				   FROM si_param
				   WHERE empresa = '001'
					 AND cod_param = '112';
					IF NOT EXISTS (SELECT {+index (si_param 194_429)} valor
									 FROM si_param
									WHERE empresa = '001' AND cod_param = '112')
					  THEN
							LET v_codigo_retorno = "00042";
							LET v_mensaje = "Error: No Existe ruta de deposito!";
						RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
					END IF;
					LET pdrepositorio = vi_valor;


		 
			LET vsArchTemporal = 'temporal.txt';
					LET vsNomArchivo = 'BACKUPSORTEO_' || SUBSTRING (pdFechaRespaldo FROM 9 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 1 FOR 2) || SUBSTRING (pdFechaRespaldo FROM 4 FOR 2) || '.txt' ;

					--GENERA EL ARCHIVO DE INTERCAMBIO
					LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(pdrepositorio) || '/' || TRIM(vsArchTemporal) || ' DELIMITER ' || '''|''';



					LET vsSQL2 = "SELECT {+ INDEX (bdinteg:si_boleto)idx_si_boleto_clte} * FROM bdinteg:si_boleto;";


					LET vsSQL3 = ' " > '|| TRIM(pdrepositorio) || '/control_reporte.sql';
					LET vsSQL1 = TRIM(vsSQL1);
					LET vsSQL3 = TRIM(vsSQL3);
					LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;

				   IF ( vsSQL <> '' ) THEN
						SYSTEM vsSQL ;
					--Permiso para la creacion de archivo.
						LET vsSQL = '' ;
						LET vsSQL = 'chmod 666 ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
						LET vsSQL = '' ;

						LET vsSQL = 'dbaccess BdInteg ' || TRIM(pdrepositorio) || '/control_reporte.sql' ;
						SYSTEM vsSQL ;
						--Borra el archivo de control.
						LET vsSQL = '' ;
						LET vsSQL = 'rm ' || TRIM(pdrepositorio) || '/control_reporte.sql';
						SYSTEM vsSQL ;

						--Elimina el caracter delimitador '?'.
						LET vsSQL = '' ;
						LET vsSQL =  "sed 's/|$//g' " || TRIM(pdrepositorio) || '/' || TRIM (vsArchTemporal) || " > " || TRIM(pdrepositorio) || '/' ||
						TRIM (vsNomArchivo);
						SYSTEM vsSQL;

						--Borra el archivo de control.
						LET vsSQL = '' ;
						LET vsSQL = 'rm ' || TRIM(pdrepositorio) || '/' || TRIM (vsArchTemporal);
						SYSTEM vsSQL ;

					LET v_codigo_retorno = "00000";
					LET v_mensaje = 'RESPALDO EN ' || TRIM (vsNomArchivo) || ' FINALIZADA OK';					LET v_reverso = '1';         
					LET v_store_pro = 'sp_respalda_boletos';
				   RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;

					END IF;
	ELSE
		LET v_codigo_retorno = "22222";
        LET v_mensaje = "Â¡EL SORTEO NAVIDEÃO NO ESTA ACTIVO!";
        LET v_reverso = '1';
        LET v_store_pro = v_store_pro;     
	
    END IF;
 END;   --begin        
      RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACIÃN: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 2, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG',
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACIÃN: 10 NOVIEMBRE 2016',
'OBJETIVO: EN LA LINEA 135 SE CAMBIA EL MENSAJES DE SALIDA',
'          PARA CUANDO SEA EXITOSA QUE CONTROL TOME LA ',
'          LINEA CORRECTA Y NO SE MUEVA CUANDO ESTE EL',
'          SORTEO ACTIVO Ã INACTIVO',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_actualiza_aprcf()
				returning CHAR(5) AS Cod_Retorno,INTEGER as Idreg;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE sRetCod          CHAR(5);
DEFINE Iid				INTEGER;
DEFINE IidErr			INTEGER;

--SISTEMA DE CUENTA 01 VARIABLES
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
LET Iid				   =0;
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
		SELECT {+INDEX (bdinteg:"informix".si_solicitud_movil idx_status_valua)} id,ap_apell_paterno,ap_apell_materno,ap_nombre1,ap_nombre2,ap_fecha_nac INTO Iid,sAP_paterno,sAP_materno,sAP_nombre1,sAP_nombre2,sAP_fecnac FROM si_solicitud_movil
		WHERE status_valua IS NOT NULL AND ap_rfc IS NULL AND ap_fecha_nac IS NOT NULL and length(ap_fecha_nac)=10

		 LET IidErr=Iid;
		 LET sAP_dia = "";
		 LET sAP_mes = "";
		 LET sAP_year = "";
		 LET sAP_dia = sAP_fecnac[1,2];
		 LET sAP_mes = sAP_fecnac[4,5];
		 LET sAP_year = sAP_fecnac[7,10];

		 IF LENGTH(sAP_year)<=2 THEN
			LET sAP_year="19"||sAP_year;
		 END IF;
		 LET sAP_fecnac ="";
		 LET sAP_rfc="";
		 LET sAP_fecnac = TRIM(sAP_mes)||''||TRIM(sAP_dia)||''||TRIM(sAP_year);

		 CALL sp_calcularrfc(sAP_paterno,sAP_materno,sAP_nombre1||' '||sAP_nombre2,sAP_fecnac)
		 RETURNING sRetCod, sAP_rfc;
		 IF sRetCod = '00000' THEN
			UPDATE "informix".si_solicitud_movil set ap_rfc=sAP_rfc where id=Iid;
		 END IF;
		LET sAP_paterno        = '';
		LET sAP_materno        = '';
		LET sAP_nombre1        = '';
		LET sAP_nombre2        = '';
		LET sAP_fecnac      = '';
	END FOREACH;


	RETURN cCodRet,IidErr;
END
END PROCEDURE;