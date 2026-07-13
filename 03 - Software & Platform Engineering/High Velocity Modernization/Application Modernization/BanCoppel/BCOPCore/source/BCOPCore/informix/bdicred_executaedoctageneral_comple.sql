CREATE PROCEDURE "informix".executaedoctageneral_comple(pempresa CHAR(3),pfechahoy DATE)
RETURNING CHAR(5);


--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE sql_err          INTEGER;
DEFINE v_cod_ret	    CHAR(5);
DEFINE v_corta_retorno          INTEGER;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);

DEFINE v_id_registro    CHAR(3);
DEFINE v_descripcion 	CHAR(50);

DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc
DEFINE v_texto		            VARCHAR(255);
DEFINE v_clave           		INTEGER;
DEFINE v_secuencia        		INTEGER;
DEFINE v_mensajes				VARCHAR(255);

DEFINE GLOBAL v_cat			    DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
DEFINE GLOBAL v_corta_linea_mensaje 	INTEGER  DEFAULT 0;
--------------------------------------------------------
--	INICIALIZACION VARIABLES
--------------------------------------------------------
LET sql_err          = "";
LET v_cod_ret	    = "000";

LET v_empresa        = "";
LET v_num_credito    = "";

LET v_id_registro    = "";
LET v_descripcion 	= "";

LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc
LET v_cat                   = 0; --- CAT
LET v_texto                 = "";
LET v_linea_auxiliar        =999999.00;
LET v_mensajes				= "";
LET v_corta_retorno 		= 0;
LET v_corta_linea_mensaje 	= 100;

--SET DEBUG FILE TO "ExecutaEdoCtaGeneral.out";
--TRACE ON;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;


        --------------------------------------------------------
	--SE OBTIENE FECHA HOY MENOS UN MES
	--------------------------------------------------------
	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
	INTO v_cod_ret,v_periodo_anterior,v_dias_periodo_tc;

	LET v_periodo_anterior = v_periodo_anterior + 1 UNITS DAY;

	SET ISOLATION TO DIRTY READ;

	--------------------------------------------------------
	--	GENERACION ENCABEZADO EDO CUENTA
	--------------------------------------------------------
  	LET v_id_registro = "000";
	--------------------------------------------------------
	--	GENERA VARIABLES GLOBALES
	-------------------------------------------------------
    ----VALOR DEL CAT

		LET v_cat = 89.90;

    -----MENSAJES DEL ESTADO DE CUENTA

        CREATE TEMP TABLE mensajes(
                clave     serial,
                secuencia integer,
                mensaje   char(101));

        LET v_clave=1;
            FOREACH            
                    SELECT REPLACE(mensajes,'{0}',TRIM(v_linea_auxiliar::VARCHAR(21))) INTO v_texto
                     FROM bdicred:sd_config_mensaje_edocta order by clave
                     
                     LET v_secuencia=1;

                FOREACH 
                     EXECUTE PROCEDURE corta_linea(TRIM(v_texto),v_corta_linea_mensaje) INTO v_mensajes, v_corta_retorno
                     insert into mensajes values (v_clave,v_secuencia,v_mensajes);
                     LET v_secuencia=v_secuencia+1;
                END FOREACH;

                LET v_clave = v_clave + 1;

            END FOREACH;


 	--------------------------------------------------------
	--	GENERA UNO A UNO LOS ESTADOS DE CUENTA
	-------------------------------------------------------
 FOREACH 
         select num_credito  
 		    INTO v_num_credito
           from bdicred:sd_maecred 
          where empresa = '001'
            and num_credito in
                ('600005593485',        
                '600012458037',        
                '600015456061',        
                '600016526557',        
                '600016526565',        
                '600016778067',        
                '600017795425',        
                '600018980828',        
                '600020453202')        
		EXECUTE PROCEDURE GeneraEstadosdeCuenta_comple
					(
					'001',
					v_num_credito,
					pfechahoy
					) INTO v_cod_ret;

      	IF v_cod_ret <> "000" THEN

      		SELECT descripcion  INTO v_descripcion
      		FROM bdinteg:si_codret
      		WHERE codigo_retorno = v_cod_ret
      		AND sistema  ="06";

      		INSERT INTO sd_valedocta
      			(
      			empresa,		num_credito,		cod_ret,
      			descripcion,	fecha_proc,			tipo
      			)
      		VALUES
      			(
      			v_empresa,		v_num_credito,		v_cod_ret,
      			v_descripcion,	pfechahoy,			"E"
      			);
           return "999";
		END IF
 	END FOREACH;

    DROP TABLE mensajes;
END;

	RETURN "000";

END PROCEDURE ;