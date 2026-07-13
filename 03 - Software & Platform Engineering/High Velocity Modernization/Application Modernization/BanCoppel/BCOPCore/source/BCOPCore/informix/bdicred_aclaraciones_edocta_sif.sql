CREATE PROCEDURE "informix".aclaraciones_edocta_sif(
                                pEmpresa CHAR(3),
                                pTarjeta CHAR(20),
                                pFechaEmision char(10))

RETURNING CHAR(5), DATE , CHAR(20),SMALLINT,SMALLINT,CHAR(10),CHAR(12),CHAR(12),CHAR(255), DECIMAL(14,2);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err             SMALLINT;
DEFINE sCodRet             CHAR(5);
DEFINE v_fecha_emision 	   DATE ;
DEFINE v_num_credito 	   CHAR(20);
DEFINE v_secuencia 		   SMALLINT;
DEFINE v_nlinea 		   SMALLINT;
DEFINE v_fecha_aclara 	   CHAR(10);
DEFINE v_descripcion 	   CHAR(255);
DEFINE v_importe 	       DECIMAL(14,2);
DEFINE v_Registros         SMALLINT;
DEFINE v_folio             CHAR(12);
DEFINE v_fecha_mov         CHAR(10);
DEFINE pNumRegistros       SMALLINT;
DEFINE pNumCredito         CHAR(20);


--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET sql_err   = 0;
LET sCodRet   = '000';
LET v_fecha_emision = " ";
LET v_num_credito 	= "";
LET v_secuencia 	= 0;
LET v_nlinea 		= 0;
LET v_fecha_aclara 	= "";
LET v_descripcion 	= "";
LET v_importe 		= 0;
LET v_Registros    	= 0;
LET v_folio         = "";
LET v_fecha_mov     = "";
LET pNumRegistros   = 0;
LET pNumCredito     = "";

--SET DEBUG FILE TO "aclaraciones_edocta.out";
--TRACE ON;

BEGIN

		ON EXCEPTION SET sql_err
      LET sCodRet = sql_err;
      RETURN sCodRet,NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
						NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
                        NVL(v_fecha_mov,""), NVL(v_descripcion,""),
						NVL(v_importe,0);
		END EXCEPTION ;


		SELECT num_credito INTO pNumCredito
		FROM sd_tarjeta
		WHERE empresa = pEmpresa AND num_tarjeta = pTarjeta and tipo_tarjeta = 'T';


  -------------------------------------------------------------
  --GENERACION ENCABEZADO EDO CUENTA
  -------------------------------------------------------------
	
	IF EXISTS (Select * from bdicred:sd_muestra_edocta where num_credito = pNumCredito and fecha_corte = pFechaEmision)
		THEN
			FOREACH
				SELECT	fecha_emision, num_credito,	secuencia,
						nlinea,	fecha_aclara, folio, fecha_movimiento,
						descripcion, importe
				INTO	v_fecha_emision, v_num_credito,	v_secuencia,
						v_nlinea, v_fecha_aclara, v_folio, v_fecha_mov,
						v_descripcion, v_importe

				 FROM sd_aclaraciones_edocta
				 WHERE fecha_emision = pFechaEmision AND num_credito = pNumCredito
				 ORDER BY secuencia,nlinea


				LET v_Registros = v_Registros + 1;
				IF v_Registros <= pNumRegistros THEN
						CONTINUE FOREACH;
				END IF

				IF v_num_credito IS NULL THEN
					LET sCodRet = "185";
			  RETURN sCodRet,  	NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
								NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
								NVL(v_fecha_mov,""), NVL(v_descripcion,""),
								NVL(v_importe,0);
				END IF

			  RETURN sCodRet,
								v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0),
								NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
								NVL(v_fecha_mov,""), NVL(v_descripcion,""),
								NVL(v_importe,0) WITH RESUME;

			END FOREACH
		ELSE
			FOREACH
				SELECT	fecha_emision, num_credito,	secuencia,
						nlinea,	fecha_aclara, folio, fecha_movimiento,
						descripcion, importe
				INTO	v_fecha_emision, v_num_credito,	v_secuencia,
						v_nlinea, v_fecha_aclara, v_folio, v_fecha_mov,
						v_descripcion, v_importe

				 --FROM sd_aclaraciones_edocta
				 FROM bdicred@pld_tcp:sd_aclaraciones_edocta
				 WHERE fecha_emision = pFechaEmision AND num_credito = pNumCredito
				 ORDER BY secuencia,nlinea


				LET v_Registros = v_Registros + 1;
				IF v_Registros <= pNumRegistros THEN
						CONTINUE FOREACH;
				END IF

				IF v_num_credito IS NULL THEN
					LET sCodRet = "185";
			  RETURN sCodRet,  	NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0),
								NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
								NVL(v_fecha_mov,""), NVL(v_descripcion,""),
								NVL(v_importe,0);
				END IF

			  RETURN sCodRet,
								v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0),
								NVL(v_nlinea,0), NVL(v_fecha_aclara,""), NVL(v_folio,""),
								NVL(v_fecha_mov,""), NVL(v_descripcion,""),
								NVL(v_importe,0) WITH RESUME;

			END FOREACH
		END IF;	
END;

END PROCEDURE DOCUMENT "Version 1.00.000",
'Version: 20130319.1100',
'Modificación : Validar que el crédito a consultar se encuentre en la tabla sd_muestra_edocta para la fecha de emisión que recibe cada sp al ser ejecutado, si existe buscar información en el servidor 51 sino en el 85',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 19 Marzo 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".mensajes_edocta_sif2(pEmpresa CHAR(3),pNumTarjeta CHAR(20),pEmision CHAR(8),pNumRegistros CHAR(1))
RETURNING CHAR(5), DATE ,CHAR(20),SMALLINT,	SMALLINT,CHAR(255),	CHAR(255);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE sql_err              SMALLINT;
DEFINE sCodRet              CHAR(5);
DEFINE v_fecha_emision 		DATE ;
DEFINE v_num_credito 		CHAR(20);
DEFINE v_secuencia 			SMALLINT;
DEFINE v_nlinea 			SMALLINT;
DEFINE v_si_paga 			CHAR(255);
DEFINE v_mensajes 			CHAR(255);
DEFINE v_credito_tar        CHAR(20);
DEFINE v_Registros          SMALLINT;
DEFINE v_edocta             SMALLINT;

LET sql_err          = 0;
LET sCodRet          = '000';
LET v_fecha_emision  = " ";
LET v_num_credito 	 = "";
LET v_secuencia 	 = 0;
LET v_nlinea 		 = 0;
LET v_si_paga 		 = "";
LET v_mensajes 		 = "";
LET v_Registros    	 = 0;
LET v_credito_tar    = 0;
LET v_edocta         = 0;

--SET DEBUG FILE TO "/pisa/leo/mensajes_edocta.out";
--TRACE ON;

BEGIN
    ON EXCEPTION SET sql_err
    LET sCodRet = sql_err;
    RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
    END EXCEPTION ;

    LET v_fecha_emision = MDY(SUBSTR(pEmision,1,2),SUBSTR(pEmision,3,2),SUBSTR(pEmision,5,4));
    
		SELECT num_credito 
          INTO v_credito_tar
		  FROM sd_tarjeta
		 WHERE empresa = pEmpresa 
           AND num_tarjeta = pNumTarjeta 
           AND tipo_tarjeta = 'T';
		   
	IF EXISTS (Select * from bdicred:sd_muestra_edocta where num_credito = v_credito_tar and fecha_corte = v_fecha_emision)
		THEN  
		   IF v_fecha_emision <= MDY('02','20','2010') THEN

				FOREACH 
					SELECT 	fecha_emision,	num_credito, secuencia,
							nlinea,	si_paga, mensajes
					  INTO 	v_fecha_emision, v_num_credito,	v_secuencia,
							v_nlinea, v_si_paga, v_mensajes
					  FROM sd_mensajes_edocta
					 WHERE fecha_emision = v_fecha_emision AND num_credito = v_credito_tar
				  ORDER BY secuencia,nlinea

					LET v_Registros = v_Registros + 1;
					IF v_Registros <= pNumRegistros THEN
							CONTINUE FOREACH;
					END IF

					IF v_num_credito IS NULL THEN
						LET sCodRet = "185";
						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
					END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;

				END FOREACH

		   ELSE
				IF EXISTS(SELECT * FROM sd_encabezado_edocta where fecha_emision = v_fecha_emision and num_tarjeta = pNumTarjeta) THEN

					FOREACH 

						SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
						  FROM sd_mensajes_edocta a
			   LEFT OUTER JOIN sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
						 WHERE a.fecha_emision = v_fecha_emision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = v_credito_tar
					 UNION ALL
						SELECT fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
						  INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
						  FROM sd_mensajes_edocta a
						 WHERE a.fecha_emision = v_fecha_emision and num_credito = v_credito_tar
					  ORDER BY 2,3,4

						LET v_Registros = v_Registros + 1;

						IF v_Registros <= pNumRegistros THEN
								CONTINUE FOREACH;
						END IF

						IF v_num_credito IS NULL THEN
							LET sCodRet = "185";

						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
						END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;
					END FOREACH

				 ELSE

					FOREACH 
						SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
						  FROM bdicred:sd_mensajes_edocta_hist a
			   LEFT OUTER JOIN sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
						 WHERE a.fecha_emision = v_fecha_emision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = v_credito_tar
					 UNION ALL
						SELECT fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
						  INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
						  FROM bdicred:sd_mensajes_edocta_hist a
						 WHERE a.fecha_emision = v_fecha_emision and num_credito = v_credito_tar
					  ORDER BY 2,3,4

						LET v_Registros = v_Registros + 1;

						IF v_Registros <= pNumRegistros THEN
								CONTINUE FOREACH;
						END IF

						IF v_num_credito IS NULL THEN
							LET sCodRet = "185";

						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
						END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;
					END FOREACH

				 END IF;
		   END IF;
		ELSE
			IF v_fecha_emision <= MDY('02','20','2010') THEN

				FOREACH 
					SELECT 	fecha_emision,	num_credito, secuencia,
							nlinea,	si_paga, mensajes
					  INTO 	v_fecha_emision, v_num_credito,	v_secuencia,
							v_nlinea, v_si_paga, v_mensajes
					  FROM bdicred@pld_tcp:sd_mensajes_edocta
					 WHERE fecha_emision = v_fecha_emision AND num_credito = v_credito_tar
				  ORDER BY secuencia,nlinea

					LET v_Registros = v_Registros + 1;
					IF v_Registros <= pNumRegistros THEN
							CONTINUE FOREACH;
					END IF

					IF v_num_credito IS NULL THEN
						LET sCodRet = "185";
						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
					END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;

				END FOREACH

		   ELSE
				IF EXISTS(SELECT * FROM bdicred@pld_tcp:sd_encabezado_edocta where fecha_emision = v_fecha_emision and num_tarjeta = pNumTarjeta) THEN

					FOREACH 

						SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
						  FROM bdicred@pld_tcp:sd_mensajes_edocta a
			   LEFT OUTER JOIN bdicred@pld_tcp:sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
						 WHERE a.fecha_emision = v_fecha_emision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = v_credito_tar
					 UNION ALL
						SELECT fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
						  INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
						  FROM bdicred@pld_tcp:sd_mensajes_edocta a
						 WHERE a.fecha_emision = v_fecha_emision and num_credito = v_credito_tar
					  ORDER BY 2,3,4

						LET v_Registros = v_Registros + 1;

						IF v_Registros <= pNumRegistros THEN
								CONTINUE FOREACH;
						END IF

						IF v_num_credito IS NULL THEN
							LET sCodRet = "185";

						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
						END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;
					END FOREACH

				 ELSE

					FOREACH 
						SELECT a.fecha_emision, a.num_credito,  b.secuencia, b.nlinea, '', b.mensaje
						  FROM bdicred:sd_mensajes_edocta_hist a
			   LEFT OUTER JOIN bdicred@pld_tcp:sd_mensajes_mensual_edocta b on a.fecha_emision = b.fecha_emision
						 WHERE a.fecha_emision = v_fecha_emision and a.secuencia = 2 and a.nlinea = 1 and a.num_credito = v_credito_tar
					 UNION ALL
						SELECT fecha_emision, num_credito,  secuencia, nlinea, nvl(si_paga,''), mensajes
						  INTO 	v_fecha_emision, v_num_credito,	v_secuencia, v_nlinea, v_si_paga, v_mensajes
						  FROM bdicred:sd_mensajes_edocta_hist a
						 WHERE a.fecha_emision = v_fecha_emision and num_credito = v_credito_tar
					  ORDER BY 2,3,4

						LET v_Registros = v_Registros + 1;

						IF v_Registros <= pNumRegistros THEN
								CONTINUE FOREACH;
						END IF

						IF v_num_credito IS NULL THEN
							LET sCodRet = "185";

						RETURN sCodRet, NVL(v_fecha_emision,date(1)), NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"");
						END IF

						RETURN sCodRet, v_fecha_emision, NVL(v_num_credito,""), NVL(v_secuencia,0), NVL(v_nlinea,0), NVL(v_si_paga,""), NVL(v_mensajes,"")
						WITH RESUME;
					END FOREACH

				 END IF;
		   END IF;
	END IF;
END;

END PROCEDURE DOCUMENT "Version 1.00.000",
'Version: 20130321.1130',
'Modificación : Validar que el crédito a consultar se encuentre en la tabla sd_muestra_edocta para la fecha de emisión que recibe cada sp al ser ejecutado, si existe buscar información en el servidor 51 sino en el 85',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 21 Marzo 2013',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_calcularvencidodiarioestadocuenta(pempresa CHAR(3), pfechainicial DATE, pfechafinal DATE, pnumcredito CHAR(12),pUsuario CHAR(8))
RETURNING CHAR (5), DATE, MONEY (16,2);


--VARIABLES
DEFINE vcodret             CHAR(6);
DEFINE v_dFecha            DATE;
DEFINE v_mCapitalVencido   MONEY (16,2);
DEFINE vsqlerr             INTEGER;
DEFINE v_mAbono            MONEY (16,2);
DEFINE v_mCargo            MONEY (16,2);
DEFINE v_cNumCredito       CHAR(12);


--SET DEBUG FILE TO '/respaldosbd/sp_CalcularVencidoDiarioEstadoCuenta.out';
--TRACE ON;

--VALIDA PARÁMETROS
IF  pEmpresa = '' OR  pEmpresa IS NULL OR pFechaInicial = '' OR pFechaInicial IS NULL OR pFechaFinal = '' OR pFechaFinal IS NULL OR pNumCredito = '' OR pNumCredito IS NULL THEN
      LET vcodret = '001';   --Paràmetros inválidos
      RETURN vcodret, v_dFecha, v_mCapitalVencido;
END IF;

BEGIN
   ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret, v_dFecha, v_mCapitalVencido;

        END IF;
    END EXCEPTION;

    -- Inicializa Variables
    LET vcodret = '000000';
    --LET v_dFecha = '01-01-1900';
    LET v_mCapitalVencido = 0;
    lET v_mAbono = 0;
    lET v_cNumCredito = '';
    LET v_dFecha = pFechaInicial -1 UNITS DAY ;
    LET  v_mCargo = 0;
	
    --IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'tmpsd_movhiscredito') THEN
         --DROP TABLE tmpsd_movhiscredito;
    --END IF;

    --CREATE TABLE tmpsd_movhiscredito (fecha_mov DATE, naturaleza CHAR(1), monto MONEY);
	
	DELETE FROM bdicred:tmpsd_movhiscredito WHERE usuario = pUsuario;
		
		INSERT INTO tmpsd_movhiscredito (fecha_mov, monto, naturaleza, num_credito, usuario)
		SELECT a.fecha_mov, a.monto, b.naturaleza, a.num_credito, pUsuario
	    FROM sd_movhis a , sd_afectavencidosimulador b
	    WHERE a.empresa = pEmpresa
	    AND a.num_credito = pNumCredito
	    AND a.codigo_fun IN (SELECT b.codigo_fun FROM sd_afectavencidosimulador)
	    AND a.codigo_ref IN (SELECT b.codigo_ref FROM sd_afectavencidosimulador)
	    AND a.fecha_mov BETWEEN pFechaInicial AND pFechaFinal
	    AND a.reversado <> 'S';

    FOREACH

        SELECT  num_credito
        INTO  v_cNumCredito
        FROM  bdicred@pld_tcp:sd_detalle_edocta
        WHERE num_credito = pNumCredito
        AND fecha_emision  =  pFechaFinal

        WHILE v_dFecha <= pFechaFinal

            IF  v_dFecha = pFechaInicial -1 UNITS DAY  THEN   --Para obtener el capital vencido del mes inmediato anterior

                --IF EXISTS (SELECT  capital_ven_tc  FROM sd_encabezado2_edocta WHERE num_credito = pNumCredito AND fecha_emision  =  pFechaInicial - 1 UNITS DAY) THEN
                    SELECT  NVL(capital_ven_tc,0)
                    INTO  v_mCapitalVencido
                    FROM  bdicred@pld_tcp:sd_encabezado2_edocta
                    WHERE num_credito = pNumCredito
                    AND fecha_emision  =  pFechaInicial - 1 UNITS DAY;

                    IF v_mCapitalVencido = "" OR v_mCapitalVencido IS NULL THEN
                        LET v_mCapitalVencido = 0.00;
                    END IF
                --ELSE
                --    LET vcodret = '002';   --No existe estado de cuenta para esa fecha
                --    RETURN vcodret, v_dFecha, v_mCapitalVencido;
                --END IF;

            ELSE      --Para obtener el capital vencido de los dias del periodo

                SELECT NVL(SUM(abono), 0), NVL(SUM(cargo),0)
                INTO v_mAbono, v_mCargo
                FROM TABLE(MULTISET(
                    SELECT
                    CASE WHEN naturaleza = 'C' THEN monto END AS cargo,
                    CASE WHEN naturaleza = 'A' THEN monto END AS abono
                    FROM bdicred:tmpsd_movhiscredito
                    WHERE fecha_mov = v_dFecha
		    AND usuario= pUsuario));

            END IF;

            LET v_mCapitalVencido = v_mCapitalVencido - v_mAbono  + v_mCargo ;
            RETURN vcodret, v_dFecha, v_mCapitalVencido

            WITH RESUME;

            LET v_dFecha =  v_dFecha + 1 UNITS DAY;

        END WHILE;
    END FOREACH;

    --IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'tmpsd_movhiscredito') THEN
        --DROP TABLE tmpsd_movhiscredito;
    --END IF;

END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramírez.',
'DESCRIPCION: Se encarga de obtener el capital vencido en un periodo determinado para un número de crédito',
'EJECUTADO O LLAMADO POR:',
'simtdc.exe',
'FECHA : Septiembre de 2009',
'VERSION: 20090910',
'BD    : bdicred',
'FECHA MODIFICACIÓN: 25/03/2010',
'MODIFICACIÓN: Se modifica, para cuando el cliente no tenga registro en el mes inmediato anterior, el',
'              capital vencido tome valor de 0.00, y continue el proceso. Ya que anteriormente terminaba ',
'AUTOR MODIFICACIÓN: Cristian Valentina Aguilar',
'FECHA MODIFICACION: 12/04/2010',
'MODIFICACION: Se le comenta la variable inicializada  v_dFecha devido a que marcaba un error',
'AUTOR MODIFICACION: Jose Angel Rodriguez Rodriguez',
'FECHA MODIFICACION: 20/04/2010',
'MODIFICACION: Se le agrego parametro al sp y se comenta la variable donde preguntaba si existia la tabla temporal y se le quita donde crea esta misma,',
'              tambien se le agrega un delete para borrar los registros del cliente que esten en dada sucursal y se borran por medio',
'              de la consulta donde se le agrega el usuario de la sucurusal',
'AUTOR MODIFICACION: Jose Angel Rodriguez Rodriguez';

CREATE PROCEDURE "informix".sp_parametroscredito_pba (pEmpresa CHAR(3), pNumEmpleado CHAR(8))

RETURNING
        CHAR( 5) AS RETORNO,            -- CODIGO DE RETORNO
        CHAR( 2) AS LONGITUDCLIENTE,    -- LONGITUD DEL CLIENTE
        CHAR( 2) AS CODMONNAC,          -- CODIGO DE LA MONEDA NACIONAL
       CHAR(100) AS CODPATHREP,         -- VALOR PATH DEL REPORTE
        CHAR(45) AS NOMUSUARIO,         -- NOMBRE DEL USUARIO
        CHAR(30) AS NOMEMPRESA,         -- NOMBRE DE LA EMPRESA   
            DATE AS FECHAHOY,           -- FECHA HOY
        CHAR( 2) AS SISTEMA,            -- CODIGO DEL SISTEMA
        CHAR(11) AS LONGITUDCTA,        -- LONGITUD DE LA CUENTA
            DATE AS FECHAANT,           -- FECHA ANTERIOR
            DATE AS PROXFECHA,          -- FECHA PROXIMA
            DATE AS PRIDIAMES,          -- PRIMER DIA DEL MES
            DATE AS PRIMHABMES,         -- PRIMER DIA HABIL MES
            DATE AS ULTDIAMES,          -- ULTIMO DIA DEL MES
            DATE AS ULTHABMES;          -- ULTIMO DIA HABIL DEL MES
    
  --DECLARACION DE VARIABLES
    DEFINE iSqlErr              INTEGER;
    DEFINE cCodRet              CHAR(5);
    DEFINE cLongitudCliente     CHAR(2);
    DEFINE cCodMonNac           CHAR(2);
    DEFINE cPathRep             CHAR(100);
    DEFINE cNombreUsuario       CHAR(45);
    DEFINE cNombreEmpresa       CHAR(30);
    DEFINE dFecha_Hoy           DATE;
    DEFINE cSistema             CHAR(2);
    DEFINE cLongCta             CHAR(11);
    DEFINE dFecha_ant           DATE;
    DEFINE dProx_fecha          DATE;
    DEFINE dPri_dia_mes         DATE;
    DEFINE dPri_hab_mes         DATE;
    DEFINE dUlt_dia_mes         DATE;
    DEFINE dUlt_hab_mes         DATE;
    
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
  --INICIALIZAR VARIABLES
    LET cCodRet 		  	= '00000';
    LET cLongitudCliente	= '';
    LET cCodMonNac			= '';
    LET cPathRep			= '';
    LET cNombreUsuario		= '';
    LET cNombreEmpresa 		= '';
    LET dFecha_Hoy 			= DATE(1);
    LET cSistema 			= '';
    LET cLongCta			= '';
    LET dFecha_ant			= DATE(1);
    LET dProx_fecha 		= DATE(1);
    LET dPri_dia_mes		= DATE(1);
    LET dPri_hab_mes		= DATE(1);
    LET dUlt_dia_mes		= DATE(1);
    LET dUlt_hab_mes		= DATE(1);
    
    --SET DEBUG FILE TO "/home/sysifx/vlv/sp_parametroscredito.out";
	--TRACE ON;
    
BEGIN
	  --CREA EL CONTROL DE ERRORES
        ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN TRIM(cCodRet), TRIM(NVL(cLongitudCliente, '')), TRIM(NVL(cCodMonNac, '')), TRIM(NVL(cPathRep, '')), 
					   TRIM(NVL(cNombreUsuario, '')), TRIM(NVL(cNombreEmpresa, '')), NVL(dFecha_Hoy, DATE(1)), 
					   TRIM(NVL(cSistema, '')), cLongCta, NVL(dFecha_ant, DATE(1)), NVL(dProx_fecha, DATE(1)), 
					   NVL(dPri_dia_mes, DATE(1)), NVL(dPri_hab_mes, DATE(1)), NVL(dUlt_dia_mes, DATE(1)), NVL(dUlt_hab_mes, DATE(1));
			END IF;
		END EXCEPTION;        
	
	IF pEmpresa = '' AND pNumEmpleado = '' THEN
		LET cCodRet = '00001'; -- FALTAN PARAMETROS PARA SU EJECUCION.
		RETURN cCodRet, TRIM(cLongitudCliente), TRIM(cCodMonNac), TRIM(cPathRep), TRIM(cNombreUsuario), TRIM(cNombreEmpresa), 
			   dFecha_Hoy, TRIM(cSistema), TRIM(cLongCta), dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, 
			   dUlt_hab_mes;
	END IF
	
    -- OBTENGO EL VALOR LONGITUD DEL NUMERO DE CLIENTE		
	SELECT TRIM(valor)
	INTO cLongitudCliente 
	FROM bdinteg:"informix".si_param 
	WHERE empresa = pEmpresa AND descripcion = ('longitud cliente'); 
	
	IF cLongitudCliente IS NULL THEN
		LET cLongitudCliente = '';
	END IF
	
    -- OBTENGO EL VALOR CODIGO DE LA MONEDA NACIONAL
	SELECT TRIM(valor)
	INTO cCodMonNac 
	FROM bdinteg:"informix".si_param 
	WHERE empresa = pEmpresa AND descripcion = ('codigo mn');
	
	IF cCodMonNac IS NULL THEN
	   LET cCodMonNac = '';
	END IF
	
    -- OBTENGO EL VALOR PATH DE REPORTES
	SELECT NVL(TRIM(valor), '')
    INTO cPathRep
	FROM bdicred:"informix".sd_param 
	WHERE empresa = pEmpresa AND cod_param = '50';
	
	IF cPathRep IS NULL THEN
  	   LET cPathRep = '';
	END IF
	
	-- OBTENGO EL NOMBRE DEL USUARIO O EJECUTIVO
	SELECT NVL(nombre, '')
	INTO cNombreUsuario
	FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = pNumEmpleado;
	
	IF cNombreUsuario IS NULL THEN
	   LET cNombreUsuario = '';
	END IF
	
    -- OBTENGO EL NOMBRE DE LA EMPRESA
	SELECT NVL(razon_social, '')
	INTO cNombreEmpresa
	FROM bdinteg:"informix".si_empresas 
	WHERE empresa = pEmpresa;
	
	IF cNombreEmpresa IS NULL THEN
		LET cNombreEmpresa = '';
	END IF
    
	-- OBTIENE EL VALOR DE LA LONGITUD DE LA CUENTA.
	SELECT TRIM(NVL(valor, ''))
	INTO cLongCta
	FROM bdicred:"informix".sd_param 
	WHERE cod_param = '8';
	
	IF cLongCta IS NULL THEN
		LET cLongCta = '';
	END IF
	
    -- OBTENGO FECHA DE CREDITO PARA LA CAPTURA DE PARAMETROS
	SELECT fecha_hoy, fecha_ant, prox_fecha, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes  
	INTO dFecha_Hoy, dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, dUlt_hab_mes
	FROM bdicred:"informix".sd_fechas;
	
	IF dFecha_Hoy IS NULL THEN
		LET dFecha_Hoy   = DATE(1);
		LET dFecha_ant   = DATE(1);
		LET dProx_fecha  = DATE(1);
		LET dPri_dia_mes = DATE(1);
		LET dPri_hab_mes = DATE(1);
		LET dUlt_dia_mes = DATE(1);
		LET dUlt_hab_mes = DATE(1);
	END IF
	
    -- OBTENGO CODIGO DEL SISTEMA
	SELECT TRIM(NVL(sistema, ''))
	INTO cSistema
	FROM bdinteg:"informix".si_sistema 
	WHERE siglas = 'SD';
	
	IF cSistema IS NULL THEN
		LET cSistema = '';
	END IF
	
	RETURN cCodRet, TRIM(cLongitudCliente), TRIM(cCodMonNac), TRIM(cPathRep), TRIM(cNombreUsuario), TRIM(cNombreEmpresa), 
		   dFecha_Hoy, TRIM(cSistema), TRIM(cLongCta), dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes,
		   dUlt_hab_mes;	
END
END PROCEDURE
DOCUMENT
'CREACION     : VALENTIN LÓPEZ VALENZUELA',
'DESCRIPCION  : OBTIENE PARAMETROS BASICOS PARA EL FUNCIONAMIENTO DEL MODULO DE CREDITO CON REGLAS DE PROGRAMACION',
'FECHA    	  : NOVIEMBRE 2010',
'BASE DE DATOS: BDICRED',
'VERSION  	  : 20111130.1529';

CREATE PROCEDURE "informix".sp_carga_ctes_dirty_behavior(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;


DEFINE vproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE dFechaAumLinCrd  DATE;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cParamNomArch    CHAR(100);
DEFINE cNomArchivo      CHAR(150);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(1500);


--SET DEBUG FILE TO "sp_carga_ctes_dirty_behavior.out";
--TRACE ON;

LET vproceso        = '0502';
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0); 
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArchEjecSql = '';
LET cSQL            = '';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, trim(cMensajeRet) || "-" || iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 10;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = pempresa;
    IF ( dFechaHoy IS NULL ) THEN
        LET cCodRet= '20013'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaAumLinCrd FROM bdicred:"informix".sd_fechas_aumlincred  WHERE empresa = pEmpresa;
    IF dFechaAumLinCrd IS NULL OR dFechaAumLinCrd = date(1) OR dFechaAumLinCrd = date(0) THEN
        LET dFechaAumLinCrd = dFechaHoy;
    END IF

    SELECT trim(valor) INTO cParamNomArch FROM bdicred:sd_param WHERE cod_param = 102;
    IF ( NVL(cParamNomArch, "") = "" ) THEN
        LET cCodRet= '104006';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT trim(valor) INTO cRutaArch  FROM bdicred:sd_param WHERE cod_param = 103;
    IF ( NVL(cRutaArch, "") = "" ) THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    LET cNomArchivo = trim(cParamNomArch) || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
    LET cNomArchEjecSql = 'Carga_Ctes_Dirty_Incr_lcr.sql';
    
    -- Realiza carga de archivo.
    LET cSQL = '';
    LET cSQL = ' echo " CREATE TEMP TABLE cred_tmp_behavior (num_credito CHAR(20), score CHAR(4)); '
            || ' LOAD FROM ' || TRIM(cRutaArch) || TRIM(cNomArchivo) 
            || ' INSERT INTO cred_tmp_behavior; '
            || ' INSERT INTO bdicred:sd_clientes_dirty_behavior ( fecha_reporte, num_credito,  score ) '
            || ' SELECT ''' || dFechaAumLinCrd || ''', num_credito, score FROM cred_tmp_behavior;  ">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql); 
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;