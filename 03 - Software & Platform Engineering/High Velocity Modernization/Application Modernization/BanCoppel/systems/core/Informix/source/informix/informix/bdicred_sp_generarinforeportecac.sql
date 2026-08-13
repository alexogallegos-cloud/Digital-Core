CREATE PROCEDURE "informix".sp_generarinforeportecac(p_Empresa CHAR(3))
RETURNING CHAR(6)   AS retorno,
          CHAR(200) AS mensaje_ret;

-- CONTROL DE CAMBIOS:

-- Modificó: Viridiana Osobampo
-- Descripción: Se genera información respecto al número de solicitudes que se 
--              se encuentran en Catalogo en Estudio (CE) y su respectivo porcentaje.
-- Fecha modificación: 15-Sep-2010
-- Petición: RQM 09 154-2


	---DECLARACIONES
        DEFINE v_cod_ret            CHAR(6);
        DEFINE iSqlErr              INTEGER;
        DEFINE iSamErr              INTEGER;
        DEFINE cErrorInfo           CHAR(200);

	DEFINE Fecha			DATE;	
        DEFINE cMensaje                 CHAR(200);
        DEFINE sExiste                  SMALLINT;
        DEFINE cSolicitud               CHAR(20);
        DEFINE iRevision                INTEGER;
        DEFINE cStatusAnt               CHAR(2);
        DEFINE cStatusNvo               CHAR(2);
        DEFINE SolAnalizadasCAC         INTEGER;
        DEFINE SolAnalizadasMC          INTEGER;
        DEFINE SolRechazadasCAC         INTEGER;
        DEFINE SolRechazadasMC          INTEGER;
        DEFINE SolEstEE_CAC             INTEGER;
        DEFINE SolEstEE_MC              INTEGER;
        DEFINE SolAut_CAC               INTEGER;
        DEFINE SolAut_MC                INTEGER;
        DEFINE iRegistros               INTEGER;
        DEFINE dPorcSolRT_CAC           DECIMAL(5,2);
        DEFINE dPorcSolEE_CAC           DECIMAL(5,2);
        DEFINE dPorcSolAT_CAC           DECIMAL(5,2);
        DEFINE dPorcSolRT_MC            DECIMAL(5,2);
        DEFINE dPorcSolEE_MC            DECIMAL(5,2);
        DEFINE dPorcSolAT_MC            DECIMAL(5,2);        
        DEFINE iSolEnProceso_CAC        INTEGER;
        DEFINE iSolEnProceso_MC         INTEGER;
        DEFINE dPorcSolEnProc_CAC       DECIMAL(5,2);
        DEFINE dPorcSolEnProc_MC        DECIMAL(5,2);
        DEFINE cArea_CAC                CHAR(2);
        DEFINE cArea_MC                 CHAR(2);

        DEFINE SolCE_CAC                INTEGER;
        DEFINE SolCE_MC                 INTEGER;
        DEFINE dPorcSolCE_CAC           DECIMAL(5,2);
        DEFINE dPorcSolCE_MC            DECIMAL(5,2);

	
	---INICIALIZACIONES
	LET v_cod_ret               = '00000';
        LET iSqlErr                 = 0;
        LET iSamErr                 = 0;
        LET cErrorInfo              = "";
	LET Fecha                   = DATE(1);
        LET cMensaje                = "El proceso se realizó con éxito.";
        LET sExiste                 = 0;
        LET cSolicitud              = ""; 
        LET iRevision               = 0; 
        LET cStatusAnt              = "";
        LET cStatusNvo              = "";
        LET SolAnalizadasCAC        = 0;
        LET SolAnalizadasMC         = 0;
        LET SolRechazadasCAC        = 0;
        LET SolRechazadasMC         = 0;
        LET SolEstEE_CAC            = 0;
        LET SolEstEE_MC             = 0;
        LET SolAut_CAC              = 0;
        LET SolAut_MC               = 0;
        LET iRegistros              = 0;
        LET dPorcSolRT_CAC          = 0;
        LET dPorcSolEE_CAC          = 0;
        LET dPorcSolAT_CAC          = 0;
        LET dPorcSolRT_MC           = 0;
        LET dPorcSolEE_MC           = 0;
        LET dPorcSolAT_MC           = 0;
        LET iSolEnProceso_CAC       = 0;
        LET iSolEnProceso_MC        = 0;
        LET dPorcSolEnProc_CAC      = 0;
        LET dPorcSolEnProc_MC       = 0;
        LET cArea_CAC               = "01";
        LET cArea_MC                = "02";

        LET SolCE_CAC               = 0;
        LET SolCE_MC                = 0;
        LET dPorcSolCE_CAC          = 0;
        LET dPorcSolCE_MC           = 0;

BEGIN

    ON EXCEPTION
        SET iSqlErr, iSamErr,cErrorInfo
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
            LET cMensaje = cErrorInfo;
        END IF;		
        RETURN v_cod_ret,cMensaje;		
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	 --SET DEBUG FILE TO "/tmp/hass/sp_generarinforeportecac.out";
	 --TRACE ON;

    IF NVL(p_Empresa,"") = "" THEN
        LET v_cod_ret = "000001";
        LET cMensaje = "Es necesario que se proporcione información de la empresa.";
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

	SELECT fecha_hoy
	INTO Fecha
	FROM bdicred: sd_fechas;


FOREACH

        SELECT s.num_solicitud, a.revision_cac, ae.status_ant, ae.status_nvo
          INTO cSolicitud, iRevision, cStatusAnt, cStatusNvo
          FROM bdisolic:ss_solicitudes s
        INNER JOIN bdisolic:"informix".ss_autorizacion a ON(a.num_solicitud = s.num_solicitud
                                                             AND a.empresa = s.empresa
                                                             AND a.status_solicitud = s.status_solicitud
                                                             AND a.fecha_entrada = (SELECT MAX(aut.fecha_entrada)
                                                                                      FROM bdisolic:ss_autorizacion aut
                                                                                     WHERE aut.empresa = s.empresa
                                                                                       AND aut.num_solicitud = s.num_solicitud
                                                                                       AND aut.status_solicitud = s.status_solicitud)
                                                             AND a.ejecutivo_auto = a.ejecutivo_auto
                                                             AND a.revision_cac IN (4,5))

        INNER JOIN bdisolic:"informix".ss_autorizacion_especial ae ON(ae.empresa = s.empresa
                                                                       AND ae.num_solicitud = s.num_solicitud
                                                                       AND ae.numcte = s.numcte
                                                                       AND ae.secuencia = (SELECT NVL(MAX(esp.secuencia),0)
                                                                                             FROM bdisolic:ss_autorizacion_especial esp
                                                                                            WHERE esp.empresa = s.empresa
                                                                                              AND esp.num_solicitud = s.num_solicitud
                                                                                              AND esp.numcte = s.numcte)
                                                                       AND ae.status_nvo = s.status_solicitud
                                                                       AND ae.fecha_modif = Fecha)


         IF iRevision = 4 THEN
            
            LET SolAnalizadasCAC = SolAnalizadasCAC + 1;

                IF cStatusNvo = "RT" THEN
                    LET SolRechazadasCAC = SolRechazadasCAC + 1;
                ELIF cStatusAnt = "RT" AND cStatusNvo = "EE" THEN
                    LET SolEstEE_CAC = SolEstEE_CAC + 1;
                ELIF cStatusAnt = "RT" AND cStatusNvo = "AT" THEN
                    LET SolAut_CAC = SolAut_CAC + 1;
                ELIF cStatusAnt = "CE" AND cStatusNvo = "CE" THEN
                    LET SolCE_CAC = SolCE_CAC + 1;
                END IF;            
            
         ELIF iRevision = 5 THEN

            LET SolAnalizadasMC = SolAnalizadasMC + 1;

                IF cStatusNvo = "RT" THEN
                    LET SolRechazadasMC = SolRechazadasMC + 1;
                ELIF cStatusAnt = "RT" AND cStatusNvo = "EE" THEN
                    LET SolEstEE_MC = SolEstEE_MC + 1;
                ELIF cStatusAnt = "RT" AND cStatusNvo = "AT" THEN
                    LET SolAut_MC = SolAut_MC + 1;
                ELIF cStatusAnt = "CE" AND cStatusNvo = "CE" THEN
                    LET SolCE_MC = SolCE_MC + 1;
                END IF; 

         END IF;
        
END FOREACH;

LET iRegistros = DBINFO("sqlca.sqlerrd2");

IF iRegistros = 0 THEN
    LET v_cod_ret = "000003";
    LET cMensaje = "No se encontraron solicitudes atendidas por CAC y MC  el dia de hoy.";
    RETURN v_cod_ret, cMensaje;
END IF;

	IF NVL(SolAnalizadasCAC,0) > 0 THEN
		LET dPorcSolRT_CAC =  (SolRechazadasCAC * 100) / SolAnalizadasCAC;
		LET dPorcSolEE_CAC =  (SolEstEE_CAC * 100) / SolAnalizadasCAC;
		LET dPorcSolAT_CAC =  (SolAut_CAC * 100) / SolAnalizadasCAC;
		LET dPorcSolCE_CAC =  (SolCE_CAC * 100) / SolAnalizadasCAC;
	END IF;

    
	IF NVL(SolAnalizadasMC,0) > 0 THEN
		LET dPorcSolRT_MC = (SolRechazadasMC * 100) / SolAnalizadasMC;
	    LET dPorcSolEE_MC = (SolEstEE_MC * 100)/ SolAnalizadasMC;
	    LET dPorcSolAT_MC = (SolAut_MC * 100) / SolAnalizadasMC;
	    LET dPorcSolCE_MC = (SolCE_MC * 100) / SolAnalizadasMC;
	END IF;
    
    LET sExiste = 0;

    SELECT COUNT(area)
      INTO sExiste
      FROM bdicred: sd_cifras_operaciones
     WHERE empresa = p_Empresa 
       AND fecha = Fecha;

	--- BORRA LOS REGISTROS DE LA ANTERIOR CORRIDA DEL MISMO DIA

      IF sExiste > 0 THEN
           DELETE bdicred: sd_cifras_operaciones 
            WHERE empresa = p_Empresa 
              AND fecha = Fecha;
      END IF;


    --- INSERTA EL RESUMEN DE LAS SOLICITUDES ATENDIDAS POR EL CAC

    INSERT INTO sd_cifras_operaciones (empresa,area,fecha,solicitudes_analizadas,solicitudes_rechazadas,porcentaje_rechazadas,
			solicitudes_ee,porcentaje_ee,solicitudes_autorizadas,porcentaje_at,solicitudes_ce, porcentaje_ce,
                        solicitudes_en_proceso,porcentaje_en_proceso) 
         VALUES (p_Empresa,cArea_CAC, Fecha, SolAnalizadasCAC,SolRechazadasCAC,dPorcSolRT_CAC,
                 SolEstEE_CAC,dPorcSolEE_CAC,SolAut_CAC,dPorcSolAT_CAC,SolCE_CAC,dPorcSolCE_CAC,
                 iSolEnProceso_CAC,dPorcSolEnProc_CAC);

    --- INSERTA EL RESUMEN DE LAS SOLICITUDES ATENDIDAS POR MESA DE CONTROL
    INSERT INTO sd_cifras_operaciones (empresa,area,fecha,solicitudes_analizadas,solicitudes_rechazadas,porcentaje_rechazadas,
			solicitudes_ee,porcentaje_ee,solicitudes_autorizadas,porcentaje_at,solicitudes_ce, porcentaje_ce,
                        solicitudes_en_proceso,porcentaje_en_proceso) 
         VALUES(p_Empresa,cArea_MC, Fecha,SolAnalizadasMC,SolRechazadasMC,dPorcSolRT_MC,
                SolEstEE_MC,dPorcSolEE_MC,SolAut_MC,dPorcSolAT_MC,SolCE_MC,dPorcSolCE_MC,
                iSolEnProceso_MC,dPorcSolEnProc_MC);

RETURN v_cod_ret, cMensaje;

END 
END PROCEDURE
DOCUMENT
'Descripcion: Se crea procedimiento para generar información de reportes para CAC y MC',
'Fecha:07/ Junio/ 2010',
'BD: bdicred',
'Autor: Mohamed Hassan'
;

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