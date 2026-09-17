CREATE PROCEDURE "informix".sp_rep_aumlincred
(
psempresa CHAR(3)
)

RETURNING CHAR(5) AS codretorno

--****************************************************************************************************
-- DESCRIPCION: Genera reporte de incrementos de linea de credito preautorizados por central.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 01/07/2011
-- BD: bdicred
-- SISTEMA : Aumlincred
--****************************************************************************************************
DEFINE vsnomreporte CHAR(33);
DEFINE vssql CHAR (6555) ;
DEFINE vssql1 CHAR (155);
DEFINE vssql2 CHAR (6000) ;
DEFINE vssql3 CHAR (400);
DEFINE vsrepositorio CHAR(90);
DEFINE vscodretorno CHAR(5);
DEFINE vsultimodiames CHAR(10);
DEFINE visqlerr INTEGER;
DEFINE vsSQLO CHAR (370);

LET vsnomreporte = "";
LET vsSQL = "";
LET vssql1 = "";
LET vssql2 = "";
LET vssql3 = "";
LET vsrepositorio = "";
LET vscodretorno = "";
LET vsultimodiames = "";
LET visqlerr = 0;
LET vsSQLO = '';

BEGIN

ON EXCEPTION SET visqlerr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF visqlerr <> 0 THEN
		RETURN visqlerr;
	END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/macf/sp_rep_aumlincred.trc';
--TRACE ON;


IF(psempresa = "001")THEN
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT pri_dia_mes - 1 INTO vsultimodiames FROM bdicred:"informix".sd_fechas;

	LET vsultimodiames = SUBSTRING(vsultimodiames FROM 4 FOR 2) || SUBSTRING(vsultimodiames FROM 1 FOR 2) || SUBSTRING(vsultimodiames FROM 7 FOR 4);
	LET vsrepositorio = "/resplogifx/archivoscartera/";
	LET vsnomreporte = "rep_incremento_linea_" || TRIM(vsultimodiames) || ".txt";
    --- numero de incrementos previos (SELECT COUNT(numcte) FROM bdicred:sd_bitacora_aumlincred WHERE empresa = '001' and num_solicitud = ba.num_solicitud AND status = 'AP')
	LET vsSQL1 = 'echo " set isolation to dirty read; UNLOAD TO ' || TRIM(vsrepositorio) || TRIM(vsnomreporte) || ' DELIMITER ' || '''|''';
	LET vsSQL2 = " SELECT TRIM(ba.numcte), TRIM(ba.num_solicitud), maes.monto_otorgado, round(((today - maec.fecha_apertura)/30),0), TRIM(ba.grado_riesgo), ba.monto_reserva, NVL(TO_CHAR(maeca.fecha_vencto, ""'""%d/%m/%Y""'""), ' '), ba.int_cred_ven, ba.porc_uso, ba.may_porc_uso6, "
	|| " ba.num_inc_prev, NVL(TRIM(ba.num_per_porutimay_806),'N/A'), NVL(TRIM(ba.num_per_porutimay_8012),'N/A'), TRIM(ba.sucursal), NVL(TO_CHAR(ba.fecha_insert, ""'""%d/%m/%Y""'""), ' '), TRIM(ba.status), ba.causa_status, ba.hora_status, "
	|| " ba.sucursal_at, ba.ejecutivo, NVL(ba.medio_res,'N/A'), NVL(TO_CHAR(ba.fecha_status, ""'""%d/%m/%Y""'"" ), ' '), ba.lincred_sugerida, ba.califica_buro, NVL((select evaluacion from bdisolic:ss_resumen_scoring where empresa = '001' and num_solicitud = ba.num_solicitud and seccion='1'), 'N/A'), ba.cte_noestit_v, ba.cte_noestit_p "
	|| " FROM bdicred:sd_bitacora_aumlincred AS ba, bdicred:sd_maesdos AS maes, bdicred:sd_maecred AS maec, bdicred:sd_maecredanexo AS maeca "
	|| " WHERE ba.empresa = '001' "
  || " AND ba.fecha_insert <= (SELECT fecha_hoy FROM bdicred:sd_fechas_aumlincred)"
	|| " AND ba.num_solicitud = maes.num_credito AND ba.num_solicitud = maec.num_credito AND ba.num_solicitud = maeca.num_credito AND ba.status IN('AT','IN') "
	|| " UNION ALL  "
	|| " SELECT TRIM(ba.numcte), TRIM(ba.num_solicitud), ba.lincred_actual, round(((today - maec.fecha_apertura)/30),0), TRIM(ba.grado_riesgo), ba.monto_reserva, NVL(TO_CHAR(maeca.fecha_vencto, ""'""%d/%m/%Y""'""), ' '), ba.int_cred_ven, ba.porc_uso, ba.may_porc_uso6, "
	|| " ba.num_inc_prev, TRIM(ba.num_per_porutimay_806), TRIM(ba.num_per_porutimay_8012), TRIM(ba.sucursal), NVL(TO_CHAR(ba.fecha_insert, ""'""%d/%m/%Y""'""), ' '), TRIM(ba.status), nvl(ba.causa_status,' '), ba.hora_status, "
  || " nvl(ba.sucursal_at,' '), nvl(ba.ejecutivo,' '), NVL(ba.medio_res,'N/A'), NVL(TO_CHAR(ba.fecha_status, ""'""%d/%m/%Y""'""), ' '), ba.lincred_sugerida, nvl(ba.califica_buro,' '), NVL((select evaluacion from bdisolic:ss_resumen_scoring where empresa = '001' and num_solicitud = ba.num_solicitud and seccion='1'), 'N/A'), ba.cte_noestit_v, ba.cte_noestit_p "
	|| " FROM bdicred:sd_bitacora_aumlincred AS ba, bdicred:sd_maesdos AS maes, bdicred:sd_maecred AS maec, bdicred:sd_maecredanexo AS maeca "
	|| " WHERE ba.empresa = '001' "
	|| " AND ba.fecha_insert = (SELECT fecha_hoy FROM bdicred:sd_fechas_aumlincred)"    
	|| " AND ba.num_solicitud = maes.num_credito AND ba.num_solicitud = maec.num_credito AND ba.num_solicitud = maeca.num_credito AND ba.status = 'AP' "
	|| " UNION ALL "
	|| " SELECT TRIM(ba.numcte), TRIM(ba.num_solicitud), maes.monto_otorgado, round(((today - maec.fecha_apertura)/30),0), TRIM(ba.grado_riesgo), ba.monto_reserva, NVL(TO_CHAR(maeca.fecha_vencto, ""'""%d/%m/%Y""'""), ' '), ba.int_cred_ven, ba.porc_uso, ba.may_porc_uso6, "
	|| " ba.num_inc_prev, TRIM(ba.num_per_porutimay_806), TRIM(ba.num_per_porutimay_8012), TRIM(ba.sucursal), NVL(TO_CHAR(ba.fecha_insert, ""'""%d/%m/%Y""'""), ' '), TRIM(ba.status), ba.causa_status,  ba.hora_status, "
	|| " ba.sucursal_at, ba.ejecutivo, NVL(ba.medio_res,'N/A'), NVL(TO_CHAR(ba.fecha_status, ""'""%d/%m/%Y""'""), ' '), 0.0 , ba.califica_buro, NVL((select evaluacion from bdisolic:ss_resumen_scoring where empresa = '001' and num_solicitud = ba.num_solicitud and seccion='1'), 'N/A'), ba.cte_noestit_v , ba.cte_noestit_p "
	|| " FROM bdicred:sd_bitacora_aumlincred AS ba, bdicred:sd_maesdos AS maes, bdicred:sd_maecred AS maec, bdicred:sd_maecredanexo AS maeca "
	|| " WHERE ba.empresa = '001' "
	|| " AND ba.fecha_insert = (SELECT fecha_hoy FROM bdicred:sd_fechas_aumlincred)"
	|| " AND ba.num_solicitud = maes.num_credito AND ba.num_solicitud = maec.num_credito AND ba.num_solicitud = maeca.num_credito AND ba.status = 'RT' "
	|| " UNION ALL "
	|| " SELECT TRIM(ba.numcte), TRIM(ba.num_solicitud), maes.monto_otorgado, round(((today - maec.fecha_apertura)/30),0) , TRIM(ba.grado_riesgo) , ba.monto_reserva , NVL(TO_CHAR(maeca.fecha_vencto, ""'""%d/%m/%Y""'""), ' ') , ba.int_cred_ven , ba.porc_uso , ba.may_porc_uso6, "
	|| " ba.num_inc_prev, TRIM(ba.num_per_porutimay_806) , TRIM(ba.num_per_porutimay_8012), TRIM(ba.sucursal), NVL(TO_CHAR(ba.fecha_insert, ""'""%d/%m/%Y""'""), ' '), TRIM(ba.status), ba.causa_status, ba.hora_status, "
	|| " ba.sucursal_at, ba.ejecutivo, NVL(ba.medio_res,'N/A'), NVL(TO_CHAR(ba.fecha_status, ""'""%d/%m/%Y""'""), ' '), 0.0 , ba.califica_buro , NVL((select evaluacion from bdisolic:ss_resumen_scoring where empresa = '001' and num_solicitud = ba.num_solicitud and seccion='1'), 'N/A') , ba.cte_noestit_v , ba.cte_noestit_p "
	|| " FROM bdicred:sd_bitacora_aumlincred_hist AS ba, bdicred:sd_maesdos AS maes, bdicred:sd_maecred AS maec, bdicred:sd_maecredanexo AS maeca "
	|| " WHERE ba.empresa = '001' "
	|| " AND ba.fecha_insert = (SELECT fecha_hoy FROM bdicred:sd_fechas_aumlincred)"
	|| " AND ba.num_solicitud = maes.num_credito AND ba.num_solicitud = maec.num_credito AND ba.num_solicitud = maeca.num_credito "; 
	LET vsSQL3 = ' " > '|| TRIM(vsrepositorio) || 'control_reporte.sql';
	LET vsSQL1 = TRIM(vsSQL1);
	LET vsSQL3 = TRIM(vsSQL3);
	LET vsSQL = trim(vsSQL1) || ' ' || trim(vsSQL2) || trim(vsSQL3);
	
  		
			IF ( vsSQL <> '' ) THEN 
				SYSTEM vsSQL ;
				--Permiso para la creacion de archivo.
				LET vsSQLO = '';
				LET vsSQLO = 'chmod 666 ' || TRIM(vsrepositorio) || 'control_reporte.sql';
				LET vsSQLO = TRIM(vsSQLO);
				LET vsSQLO = '';
				LET vsSQLO = 'dbaccess bdicred ' || TRIM(vsrepositorio) || 'control_reporte.sql';
				LET vsSQLO = TRIM(vsSQLO);
				SYSTEM vsSQLO;
	
				--Borra el archivo de control.
				LET vsSQL = '' ;
				LET vsSQL = 'rm ' || TRIM(vsrepositorio) || 'control_reporte.sql';
				SYSTEM vsSQL ;
	
				LET vsSQL = '' ;
				LET vsSQL = 'gzip ' || TRIM(vsrepositorio) || TRIM(vsnomreporte);
				SYSTEM vsSQL ;

				LET vscodretorno = '00000';
			
			ELSE -- CONSULTA VACIA
				LET vscodretorno = '00002';
			END IF;
	
ELSE
	LET vscodretorno = '00001';
END IF;

RETURN vscodretorno;
END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Aumento Linea de Credito',
'Solicito: Ricardo Sanchez Sanchez',
'Descripcion: Genera reporte de incrementos de linea de credito preautorizados por central.',
'Fecha: 2011/07/04',
'Version: 20110704.1800',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_mueve_movdiacrd_fecha(pEmpresa char(3),pfecha date)
RETURNING char(6),char(80);

    DEFINE cCodRet      char(6);
    DEFINE cMensaje     char(80);
    DEFINE sql_err      integer;
    DEFINE isam_err     integer;
    DEFINE credcontproc char(10);
    DEFINE intecontproc char(10);
--    DEFINE pfecha       date; 
    DEFINE vrowid       integer;   
    DEFINE vnumcredito  CHAR(20);
    DEFINE vfolio_suc   CHAR(16);
    DEFINE vfecha_mov   DATE;
    DEFINE vhora_mov    DATETIME HOUR to FRACTION(3);
    DEFINE vsucursal    CHAR(4);


    LET vnumcredito  = "";
    LET vrowid       = 0;   
    LET vnumcredito  = "";
    LET vfolio_suc   = "";
    LET vfecha_mov   = DATE(1);
    LET vhora_mov    = "";
    LET vsucursal    = "";

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

   LET cMensaje="Iniciamos";
   LET cCodRet='000';
 --SET DEBUG FILE TO "/pisa/leo/sp_mueve_movdia.out";
 --TRACE ON;

   set isolation to dirty read;
   set lock mode to wait 3;


    SELECT * FROM bdicred:sd_movdiacrd
    WHERE empresa = pEmpresa AND fecha_mov = pfecha
    INTO temp movdiacrd1 WITH NO LOG;


    CREATE INDEX idxmovdiacrd1 on movdiacrd1(empresa, secuencia, fecha_mov, hora_mov, sucursal, num_credito);
    CREATE INDEX idxmovdiacrd2 on movdiacrd1(num_credito,secuencia);

   FOREACH WITH HOLD
        SELECT secuencia, fecha_mov, hora_mov, sucursal, num_credito
          INTO vrowid ,vfecha_mov,vhora_mov,vsucursal,vnumcredito
          FROM movdiacrd1


           BEGIN WORK;
              INSERT INTO bdicred:sd_movhiscrd
              SELECT * FROM bdicred:movdiacrd1 where num_credito = vnumcredito and  secuencia = vrowid;

              DELETE FROM bdicred:sd_movdiacrd WHERE secuencia = vrowid
                                                AND  fecha_mov = vfecha_mov
                                                AND  hora_mov = vhora_mov
                                                AND  sucursal = vsucursal
                                                AND  num_credito = vnumcredito;
           COMMIT WORK;

        LET vrowid     = 0;
        LET vfecha_mov = "";
        LET vhora_mov  = "";
        LET vsucursal  = "";
        LET vnumcredito = "";
        
   END FOREACH;
   
    IF cCodRet <> '000' THEN
            LET cMensaje = "Fallo proceso";
            LET cCodRet =  cCodRet;
 
    ELSE
          LET cMensaje = "Proceso Concluido"; 
    END IF; 
  END;

  DROP TABLE movdiacrd1;

 RETURN cCodRet,cMensaje;

END PROCEDURE;