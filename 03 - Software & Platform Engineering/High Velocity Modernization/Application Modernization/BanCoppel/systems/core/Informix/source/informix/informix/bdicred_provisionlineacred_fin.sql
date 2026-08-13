CREATE PROCEDURE "informix".provisionlineacred_fin(pEmpresa      CHAR(3))
    RETURNING CHAR(5);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE CodRet     CHAR(5);
   DEFINE sql_err    SMALLINT;
   DEFINE isam_err   SMALLINT;
   DEFINE error_info CHAR(40);
   DEFINE vMensaje   VARCHAR(200,1);

   DEFINE FechaHoy   DATE;
   DEFINE FechaAnt   DATE;

   DEFINE vStProc    CHAR(1);
   DEFINE vErrores   INTEGER;
   DEFINE rLog       SMALLINT;
   DEFINE cSql       CHAR(200);
   DEFINE vconrador  integer;
   DEFINE pprocesos     SMALLINT;
   DEFINE pcuenta       INTEGER;
   DEFINE pcuenta_aux3  INTEGER;
   DEFINE pcontador     SMALLINT;
   DEFINE cred_ini      CHAR(20);
   DEFINE cred_fin      CHAR(20);
   DEFINE prango        CHAR(50);
   DEFINE pparametro    CHAR(3);


   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      LET vMensaje = isam_err;
      CALL log_cierre (pEmpresa, '', CodRet, FechaHoy,
                       TRIM(error_info))
      RETURNING rLog;

      IF rLog > 0 THEN
          UPDATE sd_contproc
             SET status_proc = 'C',
                 hora_fin    = CURRENT,
                 cod_ret     = CodRet,
                 mensaje     = vMensaje
           WHERE empresa     = pEmpresa
            AND proceso     = 'CierreCred'
            AND fecha       = FechaHoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = 'C',
                 hora_fin    = CURRENT,
                 codret      = CodRet
           WHERE empresa = pEmpresa
            AND proceso  = 'CierreCred'
            AND fecha    = FechaHoy;

          RETURN CodRet;
      END IF

      RETURN CodRet;

   END EXCEPTION WITH RESUME;


  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

--   SET DEBUG FILE TO "provisionlinea_fin.out";
--   TRACE ON;
--temporal solo para pruebas   TRACE OFF;

   SET ISOLATION TO DIRTY READ;

   LET CodRet     = '000';
   LET sql_err    = 0;
   LET isam_err   = 0;
   LET error_info = '';
   LET FechaHoy   = null;
   LET FechaAnt   = null;
   LET vMensaje   = "";
   LET vStProc    = "";
   LET vErrores   = 0;
   LET rLog       = 0;
   LET vconrador  = 1;
   LET pprocesos    = 0;
   LET pcuenta      = 0;
   LET pcuenta_aux3 = 0;
   LET pcontador    = 0;
   LET cred_ini     = ''; 
   LET cred_fin     = '';
   LET prango       = '';
   LET pparametro   = '';

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

--lee fecha de proceso
      SELECT fecha_hoy, fecha_ant
        INTO FechaHoy, FechaAnt
        FROM sd_fechas
       WHERE empresa = pEmpresa;
	   
--temporal solo para pruebas
    --let FechaHoy =  mdy('02','06','2018');--today-1;
--temporal solo para pruebas

--      let FechaHoy = mdy('08','21','2011');
  
      IF FechaHoy IS NULL THEN
         LET CodRet = "110";
         RETURN CodRet;
      END IF;

/*-- Se elimina esta parte para la generaciÃ³n de hilos por CTL-M
-- INI    REALIZA SEGMENTACION DE CREDITOS
           SELECT nvl(valor::integer,0)
             INTO pprocesos
             FROM bdicred:sd_param
            WHERE cod_param = '950';

            SELECT ROUND(COUNT(*) / pprocesos,0)
              INTO pcuenta
              FROM bdicred:sd_maecredanexo 
             WHERE empresa = pEmpresa 
               AND fecha_proceso = FechaHoy;

               LET pcuenta_aux3 = pcuenta;

              FOR pcontador = 1 TO  pprocesos
                   FOREACH
                       SELECT SKIP pcuenta_aux3 FIRST 1 nvl(num_credito,'')
                         INTO cred_fin
                         FROM bdicred:sd_maecredanexo 
                        WHERE empresa = pEmpresa
                          AND fecha_proceso = FechaHoy
                          ORDER BY num_credito
                   END FOREACH
       
                    IF pcontador = 1 THEN
                        LET prango = '000000000000'||'-'|| trim(nvl(cred_fin,''));
                        LET cred_ini = cred_fin;
                        LET pparametro = '951';
                    ELSE
                        IF pcontador = pprocesos THEN
                            LET prango = trim(nvl(cred_ini,''))||'-'|| '999999999999';
                        ELSE    
                            LET prango = trim(nvl(cred_ini,''))||'-'|| trim(nvl(cred_fin,''));
                            LET cred_ini = cred_fin;
                        END IF;

                        LET pparametro = (pparametro::integer + 1)::varchar(3); 
                    END IF;

                        LET pcuenta_aux3 = pcuenta_aux3 + pcuenta;
                   
                       UPDATE bdicred:sd_param 
                          SET valor = prango
                        WHERE empresa = pEmpresa
                          AND cod_param = pparametro;
               END FOR;              
-- FIN    REALIZA SEGMENTACION DE CREDITOS

-- Pregunta por Control de procesos
    SELECT status_proc INTO vStProc
      FROM sd_contproc
     WHERE empresa = pEmpresa
       AND proceso = "CierreCred"
       AND fecha = FechaHoy;

        IF vStProc IS NULL THEN
            INSERT INTO sd_contproc (empresa, proceso, fecha, status_proc, ejecutivo,hora_inicio, hora_fin, cod_ret, mensaje)
            VALUES (pEmpresa, 'CierreCred', FechaHoy, 'I', USER,CURRENT, NULL, NULL, NULL);

            INSERT INTO bdinteg:sx_contproc (empresa, proceso, fecha, sistema, status_proc,ejecutivo, hora_ini, hora_fin, codret)
            VALUES (pEmpresa, 'CierreCred', FechaHoy, '06', 'I',USER, CURRENT, NULL, '000');

            SELECT COUNT(*)
              INTO vErrores
              FROM sd_valcierre;

            IF vErrores > 0 THEN
               INSERT INTO sd_valcierrehist
               SELECT FechaAnt, * 
                 FROM sd_valcierre;
            END IF

            TRUNCATE sd_valcierre;
        ELIF vStProc = "F" THEN
            RETURN CodRet;
        END IF;

        LET cSql = '';
--executa procesos en segundo plano
     --   TRACE ON;

        -- Actualiza estatus del cierre a iniciado JOM
        update sd_fechas set ind_cierre = '0' where empresa = pEmpresa;

        LET cSQL = '/resplogifx/archivoscartera/cierre/eje_provisionlineacred_fin_parte.sh';
        SYSTEM cSql;

*/-- Se elimina esta parte para la generaciÃ³n de hilos por CTL-M
--temporal solo para pruebas        TRACE OFF;

   WHILE vconrador > 0

--temporal solo para pruebas        TRACE ON;
        SELECT count(*)
          INTO vconrador
          FROM sd_maecred a, sd_maecredanexo b
         WHERE a.empresa = pEmpresa
           AND a.status_cred NOT IN ("FF", "CC", "FC","CV","FI")
           AND NVL(id_unidad_prod,0) <> 1
           AND b.num_credito = a.num_credito
           AND b.empresa = a.empresa
		   AND a.num_producto <> '7800'
           AND b.fecha_proceso = FechaHoy;

--temporal solo para pruebas        TRACE OFF;
        IF vconrador > 0 THEN
            LET cSql = '';
    --se espera 10 minutos
--            LET cSQL = 'sleep 90';
			LET cSQL = 'sleep 300';
--temporal solo para pruebas            LET cSQL = 'sleep 300';
            SYSTEM cSql;
        END IF;
   END WHILE;
   
   --update statistics medium for table sd_movdia;

    IF CodRet <> "000" THEN
            UPDATE sd_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   cod_ret     = CodRet,
                   mensaje     = vMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'CierreCred'
               AND fecha       = FechaHoy;

            UPDATE bdinteg:sx_contproc
               SET status_proc = 'C',
                   hora_fin    = CURRENT,
                   codret      = CodRet
             WHERE empresa = pEmpresa
               AND proceso  = 'CierreCred'
               AND fecha    = FechaHoy;

    ELSE
          LET vMensaje = "Proceso Concluido";
            UPDATE sd_contproc
               SET status_proc = 'F',
                   hora_fin    = CURRENT,
                   cod_ret     = CodRet,
                   mensaje     = vMensaje
             WHERE empresa     = pEmpresa
               AND proceso     = 'CierreCred'
               AND fecha       = FechaHoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = 'F',
                 hora_fin    = CURRENT,
                 codret      = CodRet
           WHERE empresa = pEmpresa
            AND proceso  = 'CierreCred'
            AND fecha    = FechaHoy;

        -- Actualiza estatus del cierre a finalizado JOM
          update sd_fechas set ind_cierre = '1' where empresa = pEmpresa;

          LET cSql = '';
    END IF;

   RETURN CodRet;

END PROCEDURE
DOCUMENT
'Procedimiento para la provision y traspaso a cartera ',
'vencida para creditos tipo tarjeta',
'AUTOR : Antonio Ruiz',
'FECHA : 30/Diciembre/2006',
'VERSION: 1.00.006',
'BD    : BDICRED'
;

CREATE PROCEDURE "informix".consnomtitcred(pEmpresa char(3), pTarjeta char(20))

--DATOS A REGRESAR---

RETURNING

char(5), --Codigo de Retorno
char(20), --Numero Cliente
char(20), --Numero Cuenta
char(26), --Apellido Paterno
char(26), --Apellido Materno
char(26), --Nombre1
char(26), --Nombre2
char(13),  --RFC
decimal(18, 2) --Monto Linea de Credito

--DEFINICION DE VARIABLES--

DEFINE Vcod_Ret         char(5);
DEFINE Vnumcte          char(20);
DEFINE Vnumcta          char(20);
DEFINE VaPaterno        char(26);
DEFINE vaMaterno        char(26);
DEFINE vNombre1         char(26);
DEFINE VNombre2         char(26);
DEFINE Vrfc             char(13);
DEFINE VmtoLineaCred decimal(18, 2);
DEFINE vCantReg smallint;
DEFINE vNumProd char(4);

--INICIALIZACION DE VARIABLES--

LET Vcod_Ret ="000";
LET Vnumcte= "";
LET Vnumcta= "";
LET VaPaterno = "";
LET vaMaterno = "";
LET vNombre1= "";
LET VNombre2 = "";
LET Vrfc = "";
LET VmtoLineaCred = "";
LET vCantReg = 0;
LET vNumProd = "";

   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;

        SELECT
                b.num_producto,b.numcte, c.num_credito, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.rfc, d.monto_otorgado
        INTO
                vNumProd,Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, VmtoLineaCred
        FROM
                bdinteg:si_cliente a, bdicred:sd_maecred b, bdicred:sd_tarjeta c, bdicred:sd_maesdos d
        WHERE
                a.empresa = pEmpresa AND c.num_credito = b.num_credito and b.numcte = a.numcte and c.num_tarjeta=pTarjeta and c.num_credito = d.num_credito;



        if vNumProd = "6600" then
            LET Vcod_Ret = "135";
            LET Vnumcte = "";
            LET Vnumcta = "";
            LET VaPaterno = "";
            LET vaMaterno  = "";
            LET vNombre1  = "";
            LET VNombre2 = "";
            LET vNombre2 = "";
            LET Vrfc     = "";
            LET VmtoLineaCred = "";
            RETURN Vcod_Ret, Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, VmtoLineaCred;
        end if;


        if Vnumcte <> "" and Vnumcta <> ""  and Vrfc <> "" then
                let vCantReg = vCantReg +1;
                RETURN Vcod_Ret, Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, VmtoLineaCred;

        end if


        IF vCantReg = 0 THEN
                LET Vcod_Ret = "224";
                LET Vnumcte = "";
                LET Vnumcta = "";
                LET VaPaterno = "";
                LET vaMaterno  = "";
                LET vNombre1  = "";
                LET VNombre2 = "";
                LET vNombre2 = "";
                LET Vrfc     = "";
                LET VmtoLineaCred = "";
                RETURN Vcod_Ret, Vnumcte, Vnumcta, VaPaterno, vaMaterno, vNombre1, VNombre2, Vrfc, VmtoLineaCred;
        end if

END PROCEDURE


;