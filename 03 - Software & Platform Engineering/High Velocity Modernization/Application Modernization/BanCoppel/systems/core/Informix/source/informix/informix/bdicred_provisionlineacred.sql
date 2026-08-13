CREATE PROCEDURE "informix".provisionlineacred(pEmpresa      CHAR(3))
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
   DEFINE pparametro2	CHAR(3);


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

--   SET DEBUG FILE TO "provisionlinea.out";
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
   LET pparametro2	= '';

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

--lee fecha de proceso
      SELECT fecha_hoy, fecha_ant
        INTO FechaHoy, FechaAnt
        FROM sd_fechas
       WHERE empresa = pEmpresa;
	   

--      let FechaHoy = today;
--temporal solo para pruebas
--      let FechaHoy = today-1;--mdy('08','21','2011');
--temporal solo para pruebas

      IF FechaHoy IS NULL THEN
         LET CodRet = "110";
         RETURN CodRet;
      END IF;


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
						LET pparametro2 = '981';
                    ELSE
                        IF pcontador = pprocesos THEN
                            LET prango = trim(nvl(cred_ini,''))||'-'|| '999999999999';
                        ELSE    
                            LET prango = trim(nvl(cred_ini,''))||'-'|| trim(nvl(cred_fin,''));
                            LET cred_ini = cred_fin;
                        END IF;

                        LET pparametro = (pparametro::integer + 1)::varchar(3); 
						LET pparametro2 = (pparametro2::integer + 1)::varchar(3);  
                    END IF;

                        LET pcuenta_aux3 = pcuenta_aux3 + pcuenta;
                   
                       UPDATE bdicred:sd_param 
                          SET valor = prango
                        WHERE empresa = pEmpresa
                          AND cod_param = pparametro;
						
					--	Inserta parametros TRIAD					
						UPDATE bdicred:sd_param 
                          SET valor = prango
                        WHERE empresa = pEmpresa
                          AND cod_param = pparametro2;	  
						  
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

        update sd_fechas set ind_cierre = '0' where empresa = pEmpresa;

/*-- Se elimina esta parte para la generaciÃÂ³n de hilos por CTL-M
        LET cSql = '';
--executa procesos en segundo plano
        TRACE ON;

        -- Actualiza estatus del cierre a iniciado JOM
        update sd_fechas set ind_cierre = '0' where empresa = pEmpresa;

        LET cSQL = '/resplogifx/archivoscartera/cierre/eje_provisionlineacred_parte.sh';
        SYSTEM cSql;

        TRACE OFF;

   WHILE vconrador > 0

        TRACE ON;
        SELECT count(*)
          INTO vconrador
          FROM sd_maecred a, sd_maecredanexo b
         WHERE a.empresa = pEmpresa
           AND a.status_cred NOT IN ("FF", "CC", "FC","CV")
           AND NVL(id_unidad_prod,0) <> 1
           AND b.num_credito = a.num_credito
           AND b.empresa = a.empresa
           AND b.fecha_proceso = FechaHoy;
         
        TRACE OFF;
        IF vconrador > 0 THEN
            LET cSql = '';
    --se espera 10 minutos
            LET cSQL = 'sleep 300';
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
*/-- Se elimina esta parte para la generaciÃÂ³n de hilos por CTL-M

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

CREATE PROCEDURE  "informix".sp_obtenproductocredito()

RETURNING CHAR(6) AS Codigo_de_Retorno,
		  CHAR(6) AS Numero_de_Producto,
		  CHAR(50) AS Nombre_Producto,
		  CHAR(1) AS Tp_Solicitud

--definicion de variables
	DEFINE sql_err 			INTEGER;
	DEFINE cCodret 			CHAR(6);
	DEFINE cNum_Producto	CHAR(6);
	DEFINE cNombre_Producto	CHAR(50);
	DEFINE cTipo 			CHAR(1);
--Asignacion de variables
    LET sql_err 			= 0;
	LET cCodret				= "000000";
	LET cNum_Producto		= "";
	LET cNombre_Producto	= "";
	LET cTipo 				= "";
	BEGIN
			--Manejo de excepciones (errores)
			ON EXCEPTION SET sql_err
				IF sql_err <> 0 THEN
					let cCodret = sql_err;
					RETURN cCodret, "","","";
				END IF;
			END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

			--SET DEBUG FILE TO "/tmp/sp_ObtenProductoCredito.out";
			--TRACE ON;
			--Este Procedimiento se utiliza en CARATARJ.exe para Obtener los productos de crédito que se podrá imprimir la reimpresion
			FOREACH
				SELECT a.num_producto,a.nombre_prod,b.tp_solicitud  
				INTO cNum_Producto, cNombre_Producto, cTipo
				FROM bdicred:sd_definicion a 
				LEFT JOIN  bdisolic:ss_solic_producto b ON(a.num_producto = b.num_producto) 
				WHERE a.maneja_pago_sost = 'N'
				RETURN cCodret,cNum_Producto,cNombre_Producto,cTipo WITH RESUME;
			END FOREACH;
	END;

END PROCEDURE
DOCUMENT
'AUTOR      : Cristian Valentina Aguilar',
'DESCRIPCION: Es procedimiento obtiene los productos de credito manejados por el banco',
'FECHA      : 12-10-2009',
'VERSION    : 20091012.1745',
'BD         : BDICRED',
'AUTOR      : Noel Eleazar Gerardo Garcia',
'DESCRIPCION: Modificación se agrego el retorno del tipo de producto para la reeimpresion de caratula',
'FECHA      : 08-12-2009',
'VERSION    : 20091208.1617',
'BD         : BDICRED';

CREATE PROCEDURE "informix".libera_retenido_forzado()
RETURNING CHAR(5);       -- Codigo de Retorno

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

   DEFINE CodRet        CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE vFOlio	CHAR(16);
   DEFINE vFecha	DATE;
   DEFINE vDiasRet	SMALLINT;
   DEFINE vMonto	DECIMAL(14,2);
   DEFINE vMontoLib     DECIMAL(14,2);
   DEFINE vDIas		SMALLINT;
   DEFINE vNumCredito char(20);
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   ON EXCEPTION SET sql_err
      LET CodRet = sql_err;
      ROLLBACK WORK;
      RETURN CodRet;
   END EXCEPTION

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   LET CodRet    = '000';
   LET vFolio    = "??????";
   LET vFecha    = " ";
   LET vDiasRet  = 0;
   LET vMonto    = 0;
   LET vMontoLib = 0;
   LET vDias     = 0;
   LEt vNumCredito = '';

 -- **************************************************************************
 -- *                      PROGRAMA PRINCIPAL                                *
 -- **************************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	--SET DEBUG FILE TO "/informix/miguel/libera_retenido_forzado.out";
	--TRACE ON;
	
	FOREACH WITH HOLD
        SELECT a.folio_suc, a.fecha_hora, a.num_credito, a.monto
          into vFolio, vFecha, vNumCredito, vMontoLib
		  FROM bdicred:sd_retenidolibera a,
               bdicred:sd_maeretenido b
		 WHERE empresa = '001'
		   AND estatus in ("P","S")
           AND a.num_credito = b.num_credito
           AND a.folio_suc = b.folio_suc
       
		SELECT sdo_retenido INTO vMonto FROM bdicred:sd_maesdos WHERE num_credito = vNumCredito;
		
		IF vMontoLib<= vMonto THEN
           begin work;

                UPDATE bdicred:sd_maeretenido
                   SET estatus = "S"
                 WHERE empresa = '001'
                   AND num_credito = vNumCredito
                   AND folio_suc = vFolio
                   AND fecha = vFecha;
				
                UPDATE sd_maesdos 
					SET sdo_retenido  = sdo_retenido - vMontoLib 
				WHERE num_credito = vNumCredito;

            commit work;
		END IF;

	END FOREACH


	RETURN CodRet;

END PROCEDURE;