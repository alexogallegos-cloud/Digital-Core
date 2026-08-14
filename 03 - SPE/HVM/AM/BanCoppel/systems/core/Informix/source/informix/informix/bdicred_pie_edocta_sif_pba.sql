CREATE PROCEDURE "informix".pie_edocta_sif_pba(pEmpresa CHAR(3),pTarjeta CHAR(20),pFechaEmision char(10))
       RETURNING CHAR(5),DATE ,DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2),CHAR(3),DECIMAL(14,2),DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err              SMALLINT;
DEFINE sCodRet              CHAR(5);
DEFINE v_fecha_emision 	    DATE ;
DEFINE v_num_credito 	    CHAR(20);
DEFINE v_tasa_mensual 	    DECIMAL(14,2);
DEFINE v_tasa_anual 	    DECIMAL(14,2);
DEFINE v_cat 			    DECIMAL(14,2);
DEFINE v_saldo_promedio     DECIMAL(14,2);
DEFINE v_dias_periodo 	    CHAR(3);
DEFINE v_tasa_mora 		    DECIMAL(14,2);
DEFINE v_tasa_mensual_mora 	DECIMAL(14,2);
DEFINE pNumCredito          CHAR(20);


--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   = 0;
LET sCodRet   = '000';
LET v_fecha_emision 		= " ";
LET v_num_credito 			= "";
LET v_tasa_mensual 			= 0;
LET v_tasa_anual 			= 0;
LET v_cat 					= 0;
LET v_saldo_promedio 		= 0;
LET v_dias_periodo 			= "";
LET v_tasa_mora 			= 0;
LET v_tasa_mensual_mora     = 0;
LET pNumCredito         = "";

--SET DEBUG FILE TO "pie_edocta.out";
--TRACE ON;

BEGIN
  	  ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet, 
				NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""),	NVL(v_tasa_mensual,""),
				NVL(v_tasa_anual,""),	     NVL(v_cat,""),			NVL(v_saldo_promedio,""),
				NVL(v_dias_periodo,""),	     NVL(v_tasa_mora,0),	NVL(v_tasa_mensual_mora,0);
     END EXCEPTION ;


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------

		SELECT num_credito INTO pNumCredito
		FROM sd_tarjeta
		WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta and tipo_tarjeta = 'T';
	
	IF EXISTS (Select * from bdicred:sd_muestra_edocta where num_credito = pNumCredito and fecha_corte = pFechaEmision)
		THEN
			SELECT 	fecha_emision, num_credito, tasa_mensual, tasa_anual, cat, saldo_promedio,
					dias_periodo, tasa_mora, tasa_mensual_mora 
			  INTO 	v_fecha_emision, v_num_credito,	v_tasa_mensual, v_tasa_anual, v_cat, v_saldo_promedio,
					v_dias_periodo,	v_tasa_mora, v_tasa_mensual_mora
			  FROM  sd_pie_edocta
			 WHERE fecha_emision = pFechaEmision 
			   AND num_credito = pNumCredito;

			IF v_num_credito IS NULL THEN
				LET sCodRet = "185";
			  RETURN sCodRet, 
						NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""),	NVL(v_tasa_mensual,""),
						NVL(v_tasa_anual,""),	     NVL(v_cat,""),			NVL(v_saldo_promedio,""),
						NVL(v_dias_periodo,""),	     NVL(v_tasa_mora,0),	NVL(v_tasa_mensual_mora,0);
			END IF
		ELSE
			SELECT 	fecha_emision, num_credito, tasa_mensual, tasa_anual, cat, saldo_promedio,
					dias_periodo, tasa_mora, tasa_mensual_mora 
			  INTO 	v_fecha_emision, v_num_credito,	v_tasa_mensual, v_tasa_anual, v_cat, v_saldo_promedio,
					v_dias_periodo,	v_tasa_mora, v_tasa_mensual_mora
			  FROM  bdicred@pld_tcp:sd_pie_edocta
			 WHERE fecha_emision = pFechaEmision 
			   AND num_credito = pNumCredito;

			IF v_num_credito IS NULL THEN
				LET sCodRet = "185";
			  RETURN sCodRet, 
						NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""),	NVL(v_tasa_mensual,""),
						NVL(v_tasa_anual,""),	     NVL(v_cat,""),			NVL(v_saldo_promedio,""),
						NVL(v_dias_periodo,""),	     NVL(v_tasa_mora,0),	NVL(v_tasa_mensual_mora,0);
			END IF
	END IF;	
  RETURN sCodRet, 
				v_fecha_emision,         NVL(v_num_credito,""),	NVL(v_tasa_mensual,""),
				NVL(v_tasa_anual,""),	 NVL(v_cat,""),			NVL(v_saldo_promedio,""),
				NVL(v_dias_periodo,""),	 NVL(v_tasa_mora,0),	NVL(v_tasa_mensual_mora,0);

END;

END PROCEDURE DOCUMENT "Version 1.00.000",
'Version: 20130319.1100',
'Modificación : Validar que el crédito a consultar se encuentre en la tabla sd_muestra_edocta para la fecha de emisión que recibe cada sp al ser ejecutado, si existe buscar información en el servidor 51 sino en el 85',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 19 Marzo 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_mueve_movdiacrd(pEmpresa char(3))
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
    DEFINE pfecha       date; 
    DEFINE vrowid       integer;   
    DEFINE vnumcredito  CHAR(20);
    DEFINE vhora_mov    DATETIME HOUR to FRACTION(3);
    DEFINE vsucursal    CHAR(4);

    LET pfecha       = DATE(1);
    LET vrowid       = 0;   
    LET vnumcredito  = "";
    LET vhora_mov    = "";
    LET vsucursal    = "";
	LET credcontproc = "";
    LET intecontproc = "";

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET cMensaje="Iniciando Traslado Movtos_crd";
   LET cCodRet='000';
 --SET DEBUG FILE TO "/tmp/sp_mueve_movdia.out";
 --TRACE ON;

   set isolation to dirty read;
   set lock mode to wait 3;

        SELECT fecha_hoy  
        INTO pfecha
        FROM bdicred:sd_fechas;


        SELECT proceso  
        INTO intecontproc
        FROM bdinteg:sx_contproc
        WHERE fecha= pfecha and proceso ='Trasl_Diacrd';

        SELECT proceso  
        INTO credcontproc
        FROM bdicred:sd_contproc
        WHERE fecha= pfecha and proceso ='Trasl_Diacrd';

    IF (intecontproc = ' ' OR intecontproc  IS NULL)  AND (credcontproc = ' ' OR credcontproc  IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
      VALUES ('001','Trasl_Diacrd',pfecha,'06','I','informix',CURRENT,CURRENT,'000');

      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001','Trasl_Diacrd',pfecha,'I','informix',CURRENT,CURRENT,'000',cMensaje);
    else
   	LET cMensaje="YA EJECUTADO ANTERIORMENTE";
    LET cCodRet ='009';  --FMV 12ago13: Ya se ejecuto traslado diario
 	RETURN cCodRet,cMensaje;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SELECT * FROM bdicred:sd_movdiacrd
     WHERE empresa = pEmpresa 
	   AND fecha_mov = pfecha
      INTO temp movdiacrd1 WITH NO LOG;


    CREATE INDEX idxmovdiacrd1 on movdiacrd1(empresa, secuencia, fecha_mov, hora_mov, sucursal, num_credito);
    CREATE INDEX idxmovdiacrd2 on movdiacrd1(num_credito,secuencia);

   FOREACH WITH HOLD
        SELECT secuencia, hora_mov, sucursal, num_credito
          INTO vrowid ,vhora_mov,vsucursal,vnumcredito
          FROM movdiacrd1


           BEGIN WORK;
              INSERT INTO bdicred:sd_movhiscrd
              SELECT * FROM movdiacrd1 WHERE num_credito = vnumcredito AND secuencia = vrowid;

              DELETE FROM bdicred:sd_movdiacrd WHERE secuencia = vrowid
                                                AND  fecha_mov = pfecha
                                                AND  hora_mov = vhora_mov
                                                AND  sucursal = vsucursal
                                                AND  num_credito = vnumcredito;
           COMMIT WORK;

        LET vrowid     = 0;
        LET vhora_mov  = "";
        LET vsucursal  = "";
        LET vnumcredito = "";
        
   END FOREACH;
   
    IF cCodRet <> '000' THEN
            LET cMensaje = "Fallo proceso, validar bitacoras";
            LET cCodRet =  cCodRet;
            UPDATE sd_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   cod_ret     = cCodRet,
                   mensaje     = cMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'Trasl_Diacrd'
               AND fecha       = pfecha;

            UPDATE bdinteg:sx_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   codret      = cCodRet
             WHERE empresa = pEmpresa
               AND proceso  = 'Trasl_Diacrd'
               AND fecha    = pfecha;
            RETURN cCodRet,cMensaje;
    ELSE
          LET cMensaje = "Proceso Concluido Correctamente";
            UPDATE sd_contproc
               SET status_proc = 'F',
                   hora_fin    = CURRENT,
                   cod_ret     = cCodRet,
                   mensaje     = cMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'Trasl_Diacrd'
               AND fecha       = pfecha;

          UPDATE bdinteg:sx_contproc
             SET status_proc = 'F',
                 hora_fin    = CURRENT,
                 codret      = cCodRet
           WHERE empresa = pEmpresa
            AND proceso  = 'Trasl_Diacrd'
            AND fecha    = pfecha;
    END IF 

  END; 

  DROP TABLE movdiacrd1;

 RETURN cCodRet,cMensaje;

END PROCEDURE;