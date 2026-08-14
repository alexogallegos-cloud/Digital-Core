CREATE PROCEDURE "informix".sp_guardarpermisoscac
(
p_Empresa CHAR(3),
p_Area CHAR(2), 
p_Tipo_criterio CHAR(2), 
p_Valor DECIMAL(5,2), 
p_Valor2 DECIMAL(5,2), 
p_Condicion CHAR(3), 
p_Status CHAR(2), 
p_Causa CHAR(3),
p_Tipo CHAR(1)
)

-- Modificación: Se omite asignar una causa en blanco cuando el área a la cual se le guardarán los persmisos sea MC.
-- Autor Modificación: Viridiana Osobampo Aguilar
-- Fecha modificación:  24-01-2011

RETURNING
	CHAR(5) AS CODIGO_RETORNO,
        CHAR(200) AS MENSAJE_RET;

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE iSecuencia           INTEGER;
    DEFINE dMinEfic             DECIMAL(5,2);
    DEFINE dMaxEfic             DECIMAL(5,2);
    DEFINE dMinHist             DECIMAL(5,2);
    DEFINE dMaxHist             DECIMAL(5,2);
    DEFINE dMinScor             DECIMAL(5,2);
    DEFINE dMaxScor             DECIMAL(5,2);
    DEFINE sExiste              SMALLINT;
    DEFINE cMensaje             CHAR(200);


---INICIALIZACIONES
LET v_cod_ret = '00000';
LET iSecuencia		= 0;

LET dMinEfic            = -2;
LET dMaxEfic            = 101;
LET dMinHist            = -1;
LET dMaxHist            = 999;
LET dMinScor            = -1;
LET dMaxScor            = 999;
LET sExiste             = 0; 
LET cMensaje            = "";

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
        RETURN v_cod_ret,cMensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/hass/sp_guardarpermisoscac.out";
	--TRACE ON;
	
    IF NVL(p_Empresa,"") = "" THEN
        LET v_cod_ret = "000001";
        LET cMensaje  = "La información de empresa no es válida.";
        RETURN v_cod_ret,cMensaje;  
    END IF;
	
    SELECT COUNT(empresa)
     INTO sExiste
     FROM bdinteg:si_empresas
    WHERE empresa = p_Empresa;

    IF sExiste = 0 THEN
        LET v_cod_ret = "000002";
        LET cMensaje = "La empresa indicada no existe.";
        RETURN v_cod_ret,cMensaje;  
    END IF;

    IF NVL(p_Area,"") = "" THEN
        LET v_cod_ret = "000003";
        LET cMensaje = "Es necesario indicar el área que realiza el proceso.";
        RETURN v_cod_ret,cMensaje;
    END IF;

    IF p_Valor = 0 AND p_Valor2 <> 0 AND p_Condicion = "<" THEN
        LET p_Valor = DECODE(p_Tipo_criterio,"01",dMinEfic,"02",dMinHist,"03",dMinScor,p_valor);
    END IF;

    IF p_Valor <> 0 AND p_Valor2 = 0 AND p_Condicion = "=" THEN
        LET p_Valor2 = DECODE(p_Tipo_criterio,"01",dMaxEfic,"02",dMaxHist,"03",dMaxScor,p_valor2);
    END IF;

    IF p_Valor = 0 AND p_Valor2 = 0 AND p_Condicion = "TOD" THEN
        LET p_Valor  = DECODE(p_Tipo_criterio,"01",dMinEfic,"02",dMinHist,"03",dMinScor,p_valor);
        LET p_Valor2 = DECODE(p_Tipo_criterio,"01",dMaxEfic,"02",dMaxHist,"03",dMaxScor,p_valor2);
    END IF;

	IF p_Tipo = "9" THEN
		--- INICIALIZA LAS TABLAS DE PERMISOS PUNTUACIONES
		DELETE bdicred: sd_criterios_consulta_cac WHERE id_area = p_Area AND empresa = p_Empresa;
		--- INICIALIZA LAS TABLAS DE PERMISOS STATUS CAUSAS
		DELETE bdicred: sd_criterios_status_causa_cac WHERE id_area = p_Area AND empresa = p_Empresa;
	ELIF p_Tipo = "1" THEN
                SELECT COUNT(id_area )
                  INTO sExiste
                  FROM sd_criterios_consulta_cac 
                 WHERE empresa = p_Empresa 
                   AND id_area = p_Area 
                   AND tpo_criterio = p_Tipo_criterio 
                   AND condicion = p_Condicion;

		IF sExiste > 0 THEN
			LET v_cod_ret = "00004";
                        LET cMensaje = "La condición que se desea insertar ya existe para ese mismo criterio.";
			RETURN v_cod_ret,cMensaje;
		END IF
		
		INSERT INTO bdicred: sd_criterios_consulta_cac 
		(empresa, id_area, tpo_criterio, valor1, valor2, condicion, user_insert, fecha_insert) 
		VALUES (p_Empresa, p_Area, p_Tipo_criterio, p_Valor, p_Valor2, p_Condicion, USER, CURRENT);
		
	ELIF p_Tipo = "2" THEN

                INSERT INTO bdicred: sd_criterios_status_causa_cac 
                (empresa, id_area, status, causa, user_insert, fecha_insert) 
                VALUES (p_Empresa, p_Area, p_Status, p_Causa, USER, CURRENT);	
		
	END IF

	RETURN v_cod_ret,cMensaje;
END;

END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para almacenar los criterios de consulta definidos para',
			  'CAC y MC',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan'
;

CREATE PROCEDURE "informix".sp_valida_criterios_area(pEmpresa CHAR(3),
                                                     pIdArea  CHAR(2))
RETURNING CHAR(6)  AS resultado,
          CHAR(80) AS mensaje;
          
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(80);

DEFINE cEmpresa      CHAR(2);
DEFINE cIdArea       CHAR(2);

LET iSqlErr          = 0;
LET iIsamErr         = 0;
LET cErrorInfo       = "";
LET cCodRet          = "000000";
LET cMensajeRet      = "El area indicada si cuenta con criterios definidos";

LET cEmpresa         = "";
LET cIdArea          = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "/home/sysifx/paulq/sp_valida_criterios_area.out";
-- TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
  INTO cEmpresa
  FROM bdinteg:"informix".si_empresas
 WHERE empresa = pEmpresa;

IF cEmpresa IS NULL THEN
   LET cCodRet     = "000001";
   LET cMensajeRet = "La empresa indicada no es valida";
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT id_area
  INTO cIdArea 
  FROM "informix".sd_areas_cac
 WHERE id_area = pIdArea
   AND empresa = pEmpresa;

IF cIdArea IS NULL THEN 
   LET cCodRet     = "000002";
   LET cMensajeRet = "El area indicada no es valida";
   RETURN cCodRet, cMensajeRet;
END IF;

SELECT LIMIT 1 1
  INTO cIdArea
  FROM "informix".sd_criterios_consulta_cac
 WHERE id_area = pIdArea
   AND empresa = pEmpresa;

IF cIdArea IS NULL THEN 
   LET cCodRet     = "000003";
   LET cMensajeRet = "No hay criterios de consulta";
   RETURN cCodRet, cMensajeRet;
END IF;

RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para consultar',
'si el area de consulta tiene definido',
'sus criterios correspondientes',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 12/JULIO/2010',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_validarpermisousuariocac(p_Ejecutivo CHAR(8))
RETURNING
	CHAR(5); ---cod_ret

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	---INICIALIZACIONES
	LET v_cod_ret = '00000';

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
        RETURN v_cod_ret;
    END EXCEPTION;

	
	---SET DEBUG FILE TO "/tmp/has/sp_validarpermisousuariocac.out";
	---TRACE ON;

	IF p_Ejecutivo = "" OR p_Ejecutivo IS NULL THEN
		LET v_cod_ret = "00001";
		RETURN v_cod_ret;
	END IF
	
	IF NOT EXISTS(SELECT ejecutivo FROM bdinteg: si_perfil_ejecut WHERE ejecutivo = p_Ejecutivo AND sistema = "06")  THEN
		LET v_cod_ret = "00002";
		RETURN v_cod_ret;
	END IF
	
	IF NOT EXISTS(SELECT empleado FROM bdicred: sd_super_cancred WHERE empleado = p_Ejecutivo AND status = 1 AND aplicativo = "CCONCAC.EXE") THEN
		LET v_cod_ret = "00003";
		RETURN v_cod_ret;
	END IF
	

	RETURN v_cod_ret;
END;

END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para validar los permisos de usuarios',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan'
;

CREATE PROCEDURE "informix".sp_marca1()
RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_cuenta char(20);
   DEFINE sql_err,isam_err int; 

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_cuenta    = "";



BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;

--SET DEBUG FILE TO '/tmp/img_sol_rec';
--TRACE ON;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

        FOREACH WITH HOLD
            SELECT num_credito
            INTO v_cuenta
            FROM paso_cred_marca1

            BEGIN WORK;

            update bdicred:sd_encabezado_edocta set insertos = '100000000000000' where fecha_emision = today - 3 and num_credito = v_cuenta;

            COMMIT WORK;

        END FOREACH;
END;    

RETURN v_codret;

END PROCEDURE;