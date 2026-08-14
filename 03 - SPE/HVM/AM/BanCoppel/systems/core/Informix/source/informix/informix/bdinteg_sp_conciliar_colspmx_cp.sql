CREATE PROCEDURE "informix".sp_conciliar_colspmx_cp(p_NumEstado INTEGER,
                                                p_Usuario   CHAR(8))
RETURNING CHAR(5) AS Cod_Ret;
--Macf 2010-08-27 v 1.1
--DECLARACIONES
DEFINE v_cod_ret				CHAR(5);
DEFINE iSqlErr					INTEGER;
DEFINE iSamErr					INTEGER;
DEFINE s_DescCiudad				CHAR(100);
DEFINE p_FechaHoy				DATE;
DEFINE i_CveEstado				INTEGER;
DEFINE i_CiudadCoppel			INTEGER;
DEFINE s_Asenta					CHAR(60);
DEFINE i_NumColonia				INTEGER;
DEFINE s_CodigoPostal			CHAR(5);
DEFINE s_TipoAsenta				CHAR(25);
DEFINE s_Municipio				CHAR(40);
DEFINE i_NvaColonia				INTEGER;
DEFINE cEmpresa                 CHAR(3);
DEFINE iNumCol1                 INTEGER;
DEFINE iNumCol2                 INTEGER;
DEFINE cBanCons                 CHAR(1);
DEFINE cEdo1                    CHAR(2);
DEFINE cEdo2                    CHAR(2);
DEFINE cCd1                     CHAR(3);
DEFINE cCd2                     CHAR(3);
DEFINE cPais1                   CHAR(3);
DEFINE cPais2                   CHAR(3);
DEFINE cCod1                    CHAR(5);
DEFINE cCod2                    CHAR(5);
DEFINE cCdCoppel1               INTEGER;
DEFINE cCdCoppel2               INTEGER;
DEFINE iRegistros               INTEGER;
DEFINE parEstado1				SMALLINT;
DEFINE parEstado2				SMALLINT;
DEFINE cNombreProceso           CHAR(30);
DEFINE vMensaje                 CHAR(80);
DEFINE i_CP_Catzonas        INTEGER;


--INICIALIZACIONES
LET v_cod_ret				    = "00000";
LET iSqlErr					    = 0;
LET iSamErr					    = 0;
LET s_DescCiudad			    = "";
LET p_FechaHoy				    = DATE(1);
LET i_CveEstado				    = 0;
LET i_CiudadCoppel			    = 0;
LET s_Asenta				    = "";
LET i_NumColonia			    = 0;
LET s_CodigoPostal			    = "";
LET s_TipoAsenta			    = "";
LET s_Municipio				    = "";
LET i_NvaColonia			    = 0;
LET cEmpresa                    = "001";
LET iNumCol1                    = 0;
LET iNumCol2                    = 999999;
LET cBanCons                    = "";
LET cEdo1                       = "";
LET cEdo2                       = "ZZ";
LET cCd1                        = "";
LET cCd2                        = "ZZZ";
LET cPais1                      = "";
LET cPais2                      = "ZZZ";
LET cCod1                       = "";
LET cCod2                       = "ZZZZZ";
LET cCdCoppel1                  = 1;
LET cCdCoppel2                  = 999999;
LET iRegistros                  = 0;
LET parEstado1					= 0;
LET parEstado2					= 0;
LET cNombreProceso  = 'CONCILIAR COLS ACTUALIZAR CP';
LET vMensaje        = 'PROCESO INICIALIZADO';
LET i_CP_Catzonas = 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
---SET pdqpriority 20;

BEGIN

ON EXCEPTION SET iSqlErr, iSamErr
    LET v_cod_ret = iSqlErr;
    RETURN v_cod_ret;
END EXCEPTION;

--SET DEBUG FILE TO "/ids10_uc9/macf/conciliar_colspmx_cp.out";
--TRACE ON;

    --insertar control de procesos
    INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
    VALUES(cNombreProceso, v_cod_ret, vMensaje, iRegistros ,user, p_FechaHoy,
    (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));


--OBTIENE LA FECHA DEL SISTEMA
SELECT fecha_hoy
  INTO p_FechaHoy
  FROM si_fechas
 WHERE empresa = cEmpresa;

--VALIDA QUE EL ESTADO NO ESTE VACIO
IF NVL(p_NumEstado,"") = "" OR NVL(p_Usuario,"") = "" THEN
    RETURN "00001";
END IF;

--OPCION DE CONCILIACION POR MEDIO DE UN ESTADO
IF p_NumEstado > 0 THEN
   LET cBanCons = "E";
   LET cEdo1 = LPAD(p_NumEstado,2,"0");
ELSE
	LET cEdo1 = LPAD(0,2,"0");
   LET cBanCons = "G";
END IF;

--OBTIENE LAS DISTINTAS CIUDADES PERTENECIENTES AL ESTADO DE SEPOMEX
FOREACH WITH HOLD
	SELECT estado
	INTO parEstado1
	FROM si_estados
	WHERE estado = CASE WHEN cEdo1 > 0 THEN cEdo1
          ELSE estado END
	FOREACH WITH HOLD
	      SELECT {+ INDEX (bdinteg:si_catsepomex sicatsepomex)} a.ciudad_coppel, b.d_codigo, b.d_tipo_asenta, b.d_mnpio, b.d_asenta, b.d_ciudad,  b.c_estado
	        INTO i_CiudadCoppel  ,  s_CodigoPostal ,  s_TipoAsenta    ,  s_Municipio  ,  s_Asenta    ,  s_DescCiudad  ,  i_CveEstado
	        FROM bdinteg:si_ciudades a, bdinteg:si_catsepomex b
	       WHERE a.ciudad   BETWEEN cCd1   AND cCd2
	         AND a.estado   BETWEEN parEstado1  AND parEstado1
	         AND a.pais     BETWEEN cPais1 AND cPais2
	         AND a.d_ciudad = b.d_ciudad
	         AND b.d_codigo BETWEEN cCod1  AND cCod2
	         AND b.d_ciudad = a.d_ciudad
	         AND b.c_estado = a.estado
	         --AND b.estatus  = 2
	         AND a.ciudad_coppel BETWEEN cCdCoppel1 AND cCdCoppel2
	     

	        LET s_DescCiudad = TRIM(s_DescCiudad);
	        LET s_Asenta     = TRIM(s_Asenta);
	        LET s_TipoAsenta = TRIM(s_TipoAsenta);
	        LET i_CveEstado  = LPAD(i_CveEstado,2,"0");
			    LET s_CodigoPostal = s_CodigoPostal::INTEGER;

	           --BUSCA LA COLONIA EN EL CATALOGO Y OBTIENE EL NUMERO DE COLONIA EN CASO AFIRMATIVO
	           --SELECT FIRST 1 numerocolonia
	        SELECT {+ INDEX (bdinteg:si_catzonas idx_catzonass)} FIRST 1 numerocolonia, codigopostalzona   
	          INTO i_NumColonia, i_CP_Catzonas
	          FROM bdinteg:si_catzonas
	         WHERE numerociudad  = i_CiudadCoppel
	           AND numerocolonia BETWEEN iNumCol1 AND iNumCol2
	           AND municipiozona = s_Municipio
	           AND nombrezona    = s_Asenta;

              IF s_CodigoPostal  <> i_CP_Catzonas THEN
                 UPDATE bdinteg:si_catzonas
                    SET codigopostalzona = s_CodigoPostal, usr_modifica = 'UPD_CPS'
                  WHERE numerociudad  = i_CiudadCoppel
                    AND numerocolonia = i_NumColonia;
              END IF;

          LET s_DescCiudad 		 = "";
					LET i_CveEstado 		 = 0;
					LET i_CiudadCoppel		 = 0;
					LET s_CodigoPostal 		 = "";
					LET s_TipoAsenta 		 = "";
					LET s_Municipio			 = "";
					LET s_Asenta 			 = "";
					LET i_NumColonia 		 = 0;
          
	END FOREACH;
END FOREACH;
LET iRegistros = DBINFO("sqlca.sqlerrd2");

-- Indica que no hay registros con el filtro indicado.
IF iRegistros = 0 THEN
   LET v_cod_ret = "00002";
END IF;

LET vMensaje = 'PROCESO EXITOSO';

        INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
        VALUES(cNombreProceso, v_cod_ret, vMensaje, iRegistros ,user, p_FechaHoy,
        (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));


    RETURN v_cod_ret;
END
END PROCEDURE;