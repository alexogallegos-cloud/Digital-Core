CREATE PROCEDURE "informix".sp_valida_respuesta_bc(pEmpresa CHAR(3),pFechaHoyAumlincred DATE)
RETURNING CHAR(6), 	 -- Codigo de Retorno
		  VARCHAR(255);  -- Descripcion del error

--------------------------------------------------------------------------------
-- Autor: Jesï¿½s Manuel Aguilar Heredia
-- Se valida la respuesta de buro de crï¿½dito para los clientes que  fueron prospectos a un incremento en su linea de crï¿½dito.
-- Fecha de Creaciï¿½n: Junio-2010
-- Proyecto: Aumento de lineas de credito folio 1159
--------------------------------------------------------------------------------
-- Autor: Jesï¿½s Manuel Aguilar Heredia
-- Modificaciï¿½n: Se modifica para contemplar los incrementos automaticos para clientes que tengan activa esta opcion, 
-- Fecha de modificaciï¿½n: 04-03-2011
-- Proyecto: 1229-IncrementosAutLinCredTDC
----------------------------------------------------------------------------------
-- Autor: Jesï¿½s Manuel Aguilar Heredia
-- Modificaciï¿½n: Se modifica para activar la opcion de envio a supervicion cac  a clientes que requieran ser consultados
-- Fecha de modificaciï¿½n: 28-09-2011
-- Proyecto: 1286-IncrementoLinCredSIF
----------------------------------------------------------------------------------
-- Autor: Josuï¿½ Remberto Zazueta Acosta
-- Modificaciï¿½n: Se borra cï¿½digo comentado,se agregan informix y bd a las tablas que no tenï¿½an, Se implementan reglas de informix
-- Fecha de modificaciï¿½n: 02/Octubre/2012
-- BD : bdicred
----------------------------------------------------------------------------------

--****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret      CHAR(5);
DEFINE cCodRet       CHAR(6); 
DEFINE vsqlerr       INTEGER;
DEFINE sql_err       SMALLINT;
DEFINE isam_err      SMALLINT;

DEFINE error_info    CHAR(100);
DEFINE s_califica    CHAR(1);
DEFINE s_compromisos DECIMAL(14,2);
DEFINE cDescripcion_status  CHAR(40);
DEFINE vStatus	     CHAR(2);
DEFINE cUser         CHAR(10);

DEFINE vStatusAnt    CHAR(2);
DEFINE vMensaje      VARCHAR(255);
DEFINE vCuantos      SMALLINT;
DEFINE vMoneda       CHAR(2);

DEFINE vMonto        DECIMAL(14,2);
DEFINE vMontoUdis    DECIMAL(14,2);
DEFINE vCodUdi       CHAR(2);
DEFINE vCodUs        CHAR(2);
DEFINE vClase        CHAR(1);

DEFINE vTpCambioUdi  DECIMAL(14,6);
DEFINE vTpCambioUs   DECIMAL(14,6);
DEFINE vMaxMtoUdi    DECIMAL(14,2);
DEFINE vTl11         CHAR(1);
DEFINE vTl16         DATE;
DEFINE vTl17         DATE;
DEFINE vfecha        DATE;
--DEFINE vFechaHoy     DATE;

DEFINE vTl26         CHAR(2);
DEFINE vTl27		CHAR(24);
DEFINE vTl30         CHAR(2);
define vRespuesta    INTEGER;
DEFINE cTpSolicitud     CHAR(1);
define vDescripcion_status char(40);
define i            integer;
define vmesescon    integer;
define vmescuenta   integer;
define v_sc01       varchar(04);
DEFINE sCommit                       SMALLINT;
DEFINE contador_commit               INTEGER;
DEFINE 	cNumcliente		 CHAR(20);
DEFINE 	cNumcred		     CHAR(20);
DEFINE cstatus           CHAR(2);
DEFINE vCausa			 CHAR(3);
DEFINE cComentario       CHAR(80);
DEFINE vSC01         CHAR(4);
DEFINE sLineaCreditoCAC      INTEGER;
DEFINE dLineaSugerida        DECIMAL(18,2);
DEFINE cIncreAuto CHAR(1);
DEFINE cSucursal CHAR(4);
DEFINE cPregunta CHAR(200);
DEFINE cMedioRes CHAR(1);
DEFINE cEjecutivo CHAR(10);
DEFINE cRespCte CHAR(1);
DEFINE s_flag_incremento SMALLINT;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret      = "00000";
LET cCodRet       = "000000";
LET vsqlerr       = 0;
LET s_califica    = "X";
LET s_compromisos = 0;

LET vStatus       = "";
LET vStatusAnt    = "";
LET vMontoUdis    = 0;
LET vTpCambioUs    = 0;
LET cTpSolicitud  = "";
let vDescripcion_status = "";
let v_sc01       = "";
--LET vFechaHoy     = DATE(1);
LET vClase       = "";
LET sCommit                 = 0;
LET contador_commit         = 0;
LET	cNumcliente	= "";
LET	cNumcred		= "";
LET	cstatus     = "";
LET	vCausa		= "";
LET	cComentario = "";
LET vSC01       = "";
LET cUser                    = USER;
LET sLineaCreditoCAC  = 0;
LET dLineaSugerida  		 = 0;
LET cIncreAuto  		 = "";
LET cSucursal  		 = "";
LET cPregunta  		 = "";
LET  cDescripcion_status   = "";
LET cMedioRes = "";
LET cEjecutivo = "";
LET cRespCte = "";
--SET DEBUG FILE TO "/informix/jesus/sp_valida_respuesta_bc_prueba.out";
--TRACE ON;
LET s_flag_incremento =0;

SELECT TRIM(valor)::integer
  INTO vmesescon
  FROM bdiburo:"informix".br_param
 WHERE cod_param = 12;

   IF vmesescon IS NULL THEN
      LET vmesescon=12;
   END IF;

      -- *****************************************

      --       Extrae Tipo de Cmabio Divisa      *
      -- *****************************************
SELECT TRIM(valor) 
  INTO vCodUdi
  FROM bdinteg:"informix".si_param
 WHERE cod_param = 16
   AND empresa = pEmpresa ;

SELECT TRIM(valor) 
  INTO vCodUs
  FROM bdinteg:"informix".si_param
 WHERE cod_param = 17 
   AND empresa = pEmpresa;

SELECT valor 
  INTO sLineaCreditoCAC
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '028'
   AND empresa = pEmpresa ;


      -- *****************************************
      -- Extrae Clase de Tipo de Cmabio para UDI *
      -- *****************************************
      SELECT TRIM(valor) INTO vClase
	    FROM bdicred:"informix".sd_param
       WHERE cod_param = "336"
	     AND empresa = pEmpresa ;

    EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, pFechaHoyAumlincred,vCodUdi,vClase,'0')
    INTO scod_ret,vTpCambioUdi;

    IF scod_ret<>'00000' THEN
      RETURN scod_ret, "NO SE ENCONTRO VALOR DE UDI";
    END IF;

    EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, pFechaHoyAumlincred,vCodUs,vClase,'1')
    INTO scod_ret,vTpCambioUs;

    IF scod_ret<>'00000' THEN
      RETURN scod_ret, "NO SE ENCONTRO VALOR DE USA";
    END IF;

SELECT valor 
  INTO vMaxMtoUdi
  FROM bdisolic:ss_param
 WHERE empresa = pEmpresa
   AND secuencia = "309";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
--      SET DEBUG FILE TO "CargoLineaCredito.err";
      LET scod_ret = sql_err;

      IF (sCommit = -1) THEN
          rollback work;
      END IF;

      RETURN scod_ret, vMensaje;
   END EXCEPTION;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

-- ***********************************************
-- Ini Caja Unica
-- ***********************************************

LET vMensaje      = "";
--se modifica la consulta principal para obtener el valor de la sucursal deonde se origino el credito y el valor que indica si tiene activo los incrementos automaticos.
FOREACH WITH HOLD
    SELECT {+INDEX(bdiburo:br_respuesta_bc idx_fhinsert_respuesta)} a.numcte, a.num_solicitud,b.ajuste_de_cuota,b.sucursal,a.institucion
		INTO cNumcliente, cNumcred ,cIncreAuto,cSucursal, vDescripcion_status
	FROM bdiburo:"informix".br_respuesta_bc a
    INNER JOIN bdisolic:"informix".ss_solicitudes b on b.empresa = '001' AND b.num_solicitud = a.num_solicitud 
	 WHERE a.institucion='BC' 
       AND a.fecha_insert = pFechaHoyAumlincred

    LET s_califica  = "X";
    LET vMensaje = cNumcred || ' VALIDA_RESPUESTA_BURï¿½';

 
	SELECT status,lincred_sugerida,flag_incremento_especial 
	INTO cstatus,dLineaSugerida,s_flag_incremento
	FROM bdicred:"informix".sd_bitacora_aumlincred 
	WHERE empresa = pEmpresa
	AND num_solicitud = cNumcred 
	AND status = "BC"
	AND fecha_insert = pFechaHoyAumlincred 
	AND origen = "C";
		
	IF cstatus = "RT" THEN
		CONTINUE FOREACH;	
	END IF;
	
--Se cancelan las solicitudes cuya respuesta de Burï¿½ hayan sido por error
    IF cNumcliente IS NULL THEN
		LET s_califica = "1";
		LET vMensaje = 'SOLICITUD CON ERROR EN BURï¿½ DE CRï¿½DITO';

		LET cstatus     = "CN";
		LET vCausa      = "CEV";
		LET cComentario = "CANCELADO POR EVENTUALIDADES";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

       CONTINUE FOREACH;
	END IF


    IF (sCommit = 0) THEN
        BEGIN WORK;
        LET contador_commit = 0;
        LET sCommit = -1;
    END IF; 

     LET contador_commit = contador_commit  + 1;

     IF (contador_commit >= 7000) THEN
        COMMIT WORK;
--        UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_bitacora_aumlincred;
        LET contador_commit = 0;
        BEGIN WORK;
     END IF;


	 
	 
	 
	  EXECUTE PROCEDURE bdisolic:"informix".cal_circulocredito_cjunk(pEmpresa,cNumcliente,cNumcred)
                INTO cCodRet, S_califica, S_compromisos, cDescripcion_status;

		IF cstatus = "BC" AND S_califica ='1' THEN	
            LET cstatus = 'RT';
   			LET vCausa  = "RBC";
		ELIF cstatus = "CC"  AND S_califica ='1'  THEN			
            LET cstatus = 'RT';
  			LET vCausa  = "RCC";  
		ELIF cstatus IN ("BC","CC") AND  S_califica IN ('X','0') THEN		
            LET cstatus = 'AT';
   			LET vCausa  = '';	
		ELSE 
			LET cstatus = 'RT';
   			LET vCausa  = "RBC";
		END IF;    

	 
--Determina si la solicitud se va al CAC para anï¿½lisis o se autoriza
--temporalmente se autorizan todas las solicitudes hasta que se genere la pantalla de determinaciï¿½n de lï¿½nea del CAC
   IF cstatus = 'AT' THEN
		
	   IF (dLineaSugerida > sLineaCreditoCAC) THEN --se compara en pesos y no en salarios mï¿½nimos
		  LET cstatus     = "AC";     
		  LET vCausa      = "";
		  LET cComentario = "En anï¿½lisis por el CAC";	
	   ELSE
		  LET cstatus     = "AT";
		  LET vCausa      = "";
		  LET cComentario = "Requiere Autorizaciï¿½n del cliente para su aplicaciï¿½n";
	   END IF;
   END IF;
	

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

	--se agrega validacion para ver si el cliente cuenta con incrementos automaticos, si es asi se manda llamar al procedimiento sp_registrarrespuestacte para simular la respuesta de autorizacion del cliente.
	IF cIncreAuto ='S' AND  cstatus= "AT" AND NVL(s_flag_incremento, 0) != 1 THEN
	
		LET vMensaje= "Autorizo expresamente a BanCoppel a incrementar mi linea de crï¿½dito a $" ||dLineaSugerida|| ", asï¿½ mismo, acepto las nuevas condiciones y tï¿½rminos aplicables a partir de esta fecha.";
		LET cMedioRes = 'P';
		LET cEjecutivo = 'sistema';
		LET cRespCte = '1';
		LET cstatus     = "AP";
		LET vCausa      = "";
	
	INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cEjecutivo, today, pFechaHoyAumlincred, 0);


	END IF; 
	
	
	
		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
		SET califica_buro = s_califica,
			status        = cstatus,
			mensaje       = vMensaje,
			causa_status  = vCausa,
			fecha_status  = today,
			hora_status   = current,
			resp_cte = cRespCte,
			ejecutivo = cEjecutivo, 
			sucursal_at = cSucursal, 
			medio_res = cMedioRes
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 
	
	IF cIncreAuto ='S' AND  cstatus= "AP"  THEN
	
	EXECUTE PROCEDURE bdicred:"informix".sp_grabarincrementolincred(pEmpresa, cNumcred) INTO scod_ret, vMensaje;
		IF scod_ret <> "00000" THEN
			LET scod_ret = "00001";
			LET vMensaje = "Error al realizar incremento automï¿½tico de lï¿½nea para el crï¿½dito  " || cNumcred;			
			RETURN scod_ret, vMensaje;
		END IF;	

	END IF; 
	
		
	LET cstatus     = "";
	LET vCausa      = "";
	LET cComentario = "";
    LET vMensaje    = "";
    LET dLineaSugerida = 0;
	LET cMedioRes = "";
	LET cEjecutivo = "";
	LET cRespCte = "";
	
END FOREACH;

  IF sCommit = -1 THEN
     COMMIT WORK;
  END IF;
  LET sCommit = 0;

  LET vMensaje     = "Se realizï¿½ la consulta correctamente";

END
    LET cCodRet = "000000";
    RETURN cCodRet, vMensaje;
END PROCEDURE;