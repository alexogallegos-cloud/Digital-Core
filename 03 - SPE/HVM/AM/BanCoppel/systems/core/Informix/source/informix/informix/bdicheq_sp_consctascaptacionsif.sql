CREATE PROCEDURE "informix".sp_consctascaptacionsif( pModo     SMALLINT, 
                                                        pSucursal CHAR(4), 
                                                        pEstatus  SMALLINT, 
                                                        pFechaIni CHAR(10), 
                                                        pFechaFin CHAR(10) )
RETURNING CHAR(6)      AS CodigoRetorno,
          VARCHAR(107) AS Mensaje_Retorno,
          VARCHAR(20)  AS Cuenta,
          VARCHAR(20)  AS Cliente,
          CHAR(10)     AS Fecha_Alta,
          VARCHAR(107) AS Nom_cte,
          VARCHAR(40)  AS Producto,
          CHAR(9)      AS Estatus,
          VARCHAR(56)  AS Usuario,
          VARCHAR(50)  AS Nombre_sucursal;
    
    --- DEFINICION DE VARIABLES
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE vErrorInfo   VARCHAR(107);
    DEFINE cCodRet      CHAR(6);
    DEFINE cCodRet2     CHAR(6);
    DEFINE vMensaje     VARCHAR(107);
    
    DEFINE vCuenta      VARCHAR(20);
    DEFINE vCliente     VARCHAR(20);
    DEFINE cFecha_Alta  CHAR(10);
    DEFINE vNom_cte     VARCHAR(107);
    DEFINE vProducto    VARCHAR(40);
    DEFINE cEstatus     CHAR(9);
    DEFINE vUsuario     VARCHAR(56);
    DEFINE vSucursal    VARCHAR(50);
    
    DEFINE cAnio        CHAR(2);
    DEFINE cMes         CHAR(2);
    DEFINE cDia         CHAR(2);
    
    DEFINE cBegin       CHAR(1);
    DEFINE iRegistros   INTEGER;
    DEFINE cEstatusDin1 CHAR(1);
    DEFINE cEstatusDin2 CHAR(1);
    
    --- INICIALIZACION DE VARIABLES
    LET iSqlErr      = 0;
    LET iSamErr      = 0;
    LET vErrorInfo   = "";
    LET cCodRet      = "000000";
    LET cCodRet2     = "";
    LET vMensaje     = "EJECUCIÖN EXITOSA";
    
    LET vCuenta      = "";
    LET vCliente     = "";
    LET cFecha_Alta  = "";
    LET vNom_cte     = "";
    LET vProducto    = "";
    LET cEstatus     = "";
    LET vUsuario     = "";
    LET vSucursal    = "";
    
    LET cBegin       = "";
    LET	iRegistros   = 0;
    LET cEstatusDin1 = "";
    LET cEstatusDin2 = "";
    
    LET cAnio        = "";
    LET cMes         = "";
    LET cDia         = "";
    
    BEGIN
    
	ON EXCEPTION 
        SET iSqlErr, iSamErr, vErrorInfo
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consctascaptacionsif.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET vMensaje = vErrorInfo;		
            RETURN cCodRet, vMensaje, NVL(vCuenta,""), NVL(vCliente,""), NVL(cFecha_Alta,""), TRIM(NVL(vNom_cte,"")), 
                   TRIM(NVL(vProducto,"")), TRIM(NVL(cEstatus,"")), TRIM(NVL(vUsuario,"")), TRIM(NVL(vSucursal,""));
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consctascaptacionsif.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--- SE VALIDAN QUE NO ESTEN VACIOS LOS PARAMETROS DE ENTRADA
    IF NVL(pModo,0) NOT IN(0,1,2,3) OR NVL(pSucursal,"") = "" OR NVL(pEstatus,0) NOT IN(0,1,2)  OR NVL(pFechaIni,"") = "" OR NVL(pFechaFin,"") = "" THEN
        LET cCodRet = "000001";
        LET vMensaje = "ERROR EN LOS PARAMETROS DE ENTRADA";	
        RETURN cCodRet, vMensaje, NVL(vCuenta,""), NVL(vCliente,""), NVL(cFecha_Alta,""), TRIM(NVL(vNom_cte,"")),
               TRIM(NVL(vProducto,"")), TRIM(NVL(cEstatus,"")), TRIM(NVL(vUsuario,"")), TRIM(NVL(vSucursal,""));
	ELSE	
        --- SE CASTEAN LOS PARAMETROS DE LAS FECHAS INICIAL Y FINAL A DATE
        LET pFechaIni = pFechaIni::DATE;
        LET pFechaFin = pFechaFin::DATE;
        
        IF pSucursal <> "" THEN
            --- SE BUSCA LA SUCURSAL Y SE CONCATENA CON EL NÚMERO
            SELECT nombre 
              INTO vSucursal 
              FROM bdinteg:"informix".si_sucursales 
             WHERE sucursal = pSucursal;
            
            LET vSucursal = pSucursal||" - "||vSucursal;
        END IF;
    END IF;
	
    --- SE BORRA LA TABLA DE TRABAJO EN CASO DE QUE TENGA DATOS Y SE QUIERA REUTILIZAR "MODO = 0" - TODAS LOS PRODUCTOS
    IF NVL(pModo,0) = 0 THEN
        IF ( SELECT {+INDEX(sc_rptctascaptacionsif idx_rptctascaptacionsif_cta_falt)} COUNT(*) FROM sc_rptctascaptacionsif ) > 0 THEN
            TRUNCATE TABLE sc_rptctascaptacionsif;
        END IF;
    END IF;
    
    IF NVL(pModo,0) = 0 THEN	
        
        --- SE CONSULTAN TODAS LAS CUENTAS EFECTIVAS
        FOREACH
            SELECT {+INDEX(sc_producto idxscproductopba)}
                   a.cuenta, a.num_cte, b.fecha_alta, 
                   TRIM(d.nombre1)||" "||TRIM(d.nombre2)||" "||TRIM(d.apell_paterno)||" "||TRIM(d.apell_materno) AS nombre_cte,
                   c.nombre AS producto,
                   CASE WHEN a.status_cta = '1' THEN 'ACTIVA' 
                        WHEN a.status_cta = '2' THEN 'CANCELADA' 
                        WHEN a.status_cta = '3' THEN 'BLOQUEADA' 
                        WHEN a.status_cta = '4' THEN 'INACTIVA' 
                        WHEN a.status_cta = '5' THEN 'INFORMADA'
                        WHEN a.status_cta = '6' THEN 'CONCENTRADA' 
                        WHEN a.status_cta = '7' THEN 'TRASPASADA' 
                        WHEN a.status_cta = '8' THEN 'DESCONCENTRADA' 
                   END AS status,
                   f.ejecutivo||" - "|| f.nombre AS usuario_aper
              INTO vCuenta, vCliente, cFecha_Alta, vNom_cte, vProducto, cEstatus, vUsuario
              FROM sc_maechq a, 
                   sc_maenoc b,
                   sc_producto c,
                   bdinteg:si_cliente d,
                   bdinteg:si_tipper e,
                   bdinteg:si_ejecut f
             WHERE a.cuenta = b.cuenta
               AND a.producto = c.producto
               AND a.producto <> "1100"
               AND a.num_cte = d.numcte
               AND d.tpo_persona = e.tpo_persona
               AND b.ejecutivo = f.ejecutivo
               AND e.es_fisica = "S" 
               AND a.sucursal = pSucursal
               AND b.fecha_alta >= pFechaIni 
               AND b.fecha_alta <= pFechaFin 	
            
            INSERT INTO sc_rptctascaptacionsif (cuenta, cte, fecha_alta, nombre_cte, producto, status, usuario_aper) 
            VALUES (vCuenta, vCliente, cFecha_Alta, vNom_cte, vProducto, cEstatus, vUsuario);
        END FOREACH;

        --- SE CONSULTAN TODAS LAS CUENTAS DE INVERSIÓN CRECIENTE
        FOREACH
            SELECT {+INDEX(sc_producto idxscproductopba)}
                   a.cuenta , a.num_cte, a.fecultdep , 
                   TRIM(d.nombre1)||" "||TRIM(d.nombre2)||" "||TRIM(d.apell_paterno)||" "||TRIM(d.apell_materno) AS nombre_cte,
                   c.nombre AS producto,
                   CASE WHEN a.status_cta = '1' THEN 'ACTIVA' 
                        WHEN a.status_cta = '2' THEN 'CANCELADA' 
                        WHEN a.status_cta = '3' THEN 'BLOQUEADA' 
                        WHEN a.status_cta = '4' THEN 'INACTIVA' 
                        WHEN a.status_cta = '5' THEN 'INFORMADA'
                        WHEN a.status_cta = '6' THEN 'CONCENTRADA' 
                        WHEN a.status_cta = '7' THEN 'TRASPASADA' 
                        WHEN a.status_cta = '8' THEN 'DESCONCENTRADA' 
                   END AS status,
                   f.ejecutivo||" - "|| f.nombre AS usuario_aper
              INTO vCuenta, vCliente, cFecha_Alta, vNom_cte, vProducto, cEstatus, vUsuario
              FROM sc_maechq a, 
                   sc_maenoc b,
                   sc_producto c,
                   bdinteg:si_cliente d,
                   bdinteg:si_tipper e,
                   bdinteg:si_ejecut f
             WHERE a.cuenta = b.cuenta
               AND a.producto = c.producto
               AND a.producto = "1100"
               AND a.num_cte = d.numcte
               AND d.tpo_persona = e.tpo_persona
               AND b.ejecutivo = f.ejecutivo
               AND e.es_fisica = "S" 
               AND a.sucursal = pSucursal
               AND a.fecultdep >= pFechaIni 
               AND a.fecultdep <= pFechaFin 	
            
            INSERT INTO sc_rptctascaptacionsif (cuenta, cte, fecha_alta, nombre_cte, producto, status, usuario_aper) 
            VALUES (vCuenta, vCliente, cFecha_Alta, vNom_cte, vProducto, cEstatus, vUsuario);
        END FOREACH;

        --- SE CONSULTAN TODAS LAS CUENTAS DE PAGARE
        FOREACH
            SELECT {+INDEX(bdinvers:sv_instrum idx_instrum)} 
                   DISTINCT(a.cuenta), TRIM(a.num_cte) AS cte, a.fecha_alta, 
                   TRIM(d.nombre1)||" "||TRIM(d.nombre2)||" "||TRIM(d.apell_paterno)||" "||TRIM(d.apell_materno) AS nombre_cte,
                   TRIM(b.nombre) AS producto,
                   CASE WHEN a.status_cta = '1' THEN 'ACTIVA' 
                        WHEN a.status_cta = '2' THEN 'CANCELADA' 
                        WHEN a.status_cta = '4' THEN 'RENOVADA' 
                   END AS status,
                   f.ejecutivo||" - "|| f.nombre AS usuario_aper
              INTO vCuenta, vCliente, cFecha_Alta, vNom_cte, vProducto, cEstatus, vUsuario
              FROM bdinvers:sv_maeinv a,
                   bdinvers:sv_instrum b,
                   bdinteg:si_cliente d,
                   bdinteg:si_tipper e,
                   bdinteg:si_ejecut f
             WHERE  a.num_cte = d.numcte 
               AND a.cod_instrum = b.cod_instrum
               AND d.tpo_persona = e.tpo_persona
               AND a.promotor = f.ejecutivo
               AND e.es_fisica = "S" 
               AND a.sucursal = pSucursal
               AND a.fecha_alta >= pFechaIni 
               AND a.fecha_alta <= pFechaFin 				
            
            INSERT INTO sc_rptctascaptacionsif (cuenta, cte, fecha_alta, nombre_cte, producto, status, usuario_aper) 
            VALUES (vCuenta, vCliente, cFecha_Alta, vNom_cte, vProducto, cEstatus, vUsuario);
        END FOREACH;
        
        --- SE BARRE TODA LA TABLA PARA REGRESAR TODOS LOS DATOS OBTENIDOS
        FOREACH
            SELECT {+INDEX(sc_rptctascaptacionsif idx_rptctascaptacionsif_cta_falt)}
                   cuenta, cte, fecha_alta, nombre_cte, producto, status, usuario_aper 
              INTO vCuenta, vCliente, cFecha_Alta, vNom_cte, vProducto, cEstatus, vUsuario
              FROM sc_rptctascaptacionsif 
             ORDER BY cuenta, fecha_alta
            
            RETURN cCodRet, vMensaje, NVL(vCuenta,""), NVL(vCliente,""), NVL(cFecha_Alta,""), TRIM(NVL(vNom_cte,"")),
                   TRIM(NVL(vProducto,"")), TRIM(NVL(cEstatus,"")), TRIM(NVL(vUsuario,"")), TRIM(NVL(vSucursal,"")) WITH RESUME;
        END FOREACH;
        
        LET iRegistros = DBINFO("sqlca.sqlerrd2");
        
        IF iRegistros = 0 THEN
            LET cCodRet = "000002";
            LET vMensaje = "NO SE ENCONTRARON REGISTROS CON LA INFORMACIÓN PROPORCIONADA";
            RETURN cCodRet, vMensaje, NVL(vCuenta,""), NVL(vCliente,""), NVL(cFecha_Alta,""), TRIM(NVL(vNom_cte,"")), 
                   TRIM(NVL(vProducto,"")), TRIM(NVL(cEstatus,"")), TRIM(NVL(vUsuario,"")), TRIM(NVL(vSucursal,""));
        END IF;	
        
    ELIF NVL(pModo,0) = 1 THEN 
    
        --- SE CONSULTA SOLAMENTE TODAS LAS CUENTAS EFECTIVAS
        FOREACH
            SELECT {+INDEX(sc_producto idxscproductopba)}
                   a.cuenta , a.num_cte, b.fecha_alta, 
                   TRIM(d.nombre1)||" "||TRIM(d.nombre2)||" "||TRIM(d.apell_paterno)||" "||TRIM(d.apell_materno) AS nombre_cte,
                   c.nombre AS producto,
                   CASE WHEN a.status_cta = '1' THEN 'ACTIVA' 
                        WHEN a.status_cta = '2' THEN 'CANCELADA' 
                        WHEN a.status_cta = '3' THEN 'BLOQUEADA' 
                        WHEN a.status_cta = '4' THEN 'INACTIVA' 
                        WHEN a.status_cta = '5' THEN 'INFORMADA'
                        WHEN a.status_cta = '6' THEN 'CONCENTRADA' 
                        WHEN a.status_cta = '7' THEN 'TRASPASADA' 
                        WHEN a.status_cta = '8' THEN 'DESCONCENTRADA' 
                   END AS status,
                   f.ejecutivo||" - "|| f.nombre AS usuario_aper
              INTO vCuenta, vCliente, cFecha_Alta, vNom_cte, vProducto, cEstatus, vUsuario
              FROM sc_maechq a, 
                   sc_maenoc b,
                   sc_producto c,
                   bdinteg:si_cliente d,
                   bdinteg:si_tipper e,
                   bdinteg:si_ejecut f
             WHERE a.cuenta = b.cuenta
               AND a.producto = c.producto
               AND a.producto <> "1100"
               AND a.num_cte = d.numcte
               AND d.tpo_persona = e.tpo_persona
               AND b.ejecutivo = f.ejecutivo
               AND e.es_fisica = "S" 
               AND a.sucursal = pSucursal
               AND b.fecha_alta >= pFechaIni 
               AND b.fecha_alta <= pFechaFin 
             ORDER BY a.cuenta,b.fecha_alta
            
            RETURN cCodRet, vMensaje, NVL(vCuenta,""), NVL(vCliente,""), NVL(cFecha_Alta,""), TRIM(NVL(vNom_cte,"")),
                   TRIM(NVL(vProducto,"")), TRIM(NVL(cEstatus,"")), TRIM(NVL(vUsuario,"")), TRIM(NVL(vSucursal,"")) WITH RESUME;
        END FOREACH;
        
        LET iRegistros = DBINFO("sqlca.sqlerrd2");
        
        IF iRegistros = 0 THEN
            LET cCodRet = "000003";
            LET vMensaje = "NO SE ENCONTRARON REGISTROS CON LA INFORMACIÓN PROPORCIONADA";
            RETURN cCodRet, vMensaje, NVL(vCuenta,""), NVL(vCliente,""), NVL(cFecha_Alta,""), TRIM(NVL(vNom_cte,"")),
                   TRIM(NVL(vProducto,"")), TRIM(NVL(cEstatus,"")), TRIM(NVL(vUsuario,"")), TRIM(NVL(vSucursal,""));
        END IF;

    ELIF NVL(pModo,0) = 2 THEN 
        
        --- CUENTAS DE INVERSION CRECIENTE
        FOREACH
            SELECT {+INDEX(sc_producto idxscproductopba)}
                   a.cuenta , a.num_cte, a.fecultdep, 
                   TRIM(d.nombre1)||" "||TRIM(d.nombre2)||" "||TRIM(d.apell_paterno)||" "||TRIM(d.apell_materno) AS nombre_cte,
                   c.nombre AS producto,
                   CASE WHEN a.status_cta = '1' THEN 'ACTIVA' 
                        WHEN a.status_cta = '2' THEN 'CANCELADA' 
                        WHEN a.status_cta = '3' THEN 'BLOQUEADA' 
                        WHEN a.status_cta = '4' THEN 'INACTIVA' 
                        WHEN a.status_cta = '5' THEN 'INFORMADA'
                        WHEN a.status_cta = '6' THEN 'CONCENTRADA' 
                        WHEN a.status_cta = '7' THEN 'TRASPASADA' 
                        WHEN a.status_cta = '8' THEN 'DESCONCENTRADA' 
                   END AS status,
                   f.ejecutivo||" - "|| f.nombre AS usuario_aper
              INTO vCuenta, vCliente, cFecha_Alta, vNom_cte, vProducto, cEstatus, vUsuario
              FROM sc_maechq a, 
                   sc_maenoc b,
                   sc_producto c,
                   bdinteg:si_cliente d,
                   bdinteg:si_tipper e,
                   bdinteg:si_ejecut f
             WHERE a.cuenta = b.cuenta
               AND a.producto = c.producto
               AND a.producto = "1100"
               AND a.num_cte = d.numcte
               AND d.tpo_persona = e.tpo_persona
               AND b.ejecutivo = f.ejecutivo
               AND e.es_fisica = "S" 
               AND a.sucursal = pSucursal
               AND a.fecultdep >= pFechaIni 
               AND a.fecultdep <= pFechaFin 	 	
             ORDER BY a.cuenta, a.fecultdep
            
            RETURN cCodRet, vMensaje, NVL(vCuenta,""), NVL(vCliente,""), NVL(cFecha_Alta,""), TRIM(NVL(vNom_cte,"")),
                   TRIM(NVL(vProducto,"")), TRIM(NVL(cEstatus,"")), TRIM(NVL(vUsuario,"")), TRIM(NVL(vSucursal,"")) WITH RESUME;
        END FOREACH;
        
        LET iRegistros = DBINFO("sqlca.sqlerrd2");
        
        IF iRegistros = 0 THEN
            LET cCodRet = "000004";
            LET vMensaje = "NO SE ENCONTRARON REGISTROS CON LA INFORMACIÓN PROPORCIONADA";
            RETURN cCodRet, vMensaje, NVL(vCuenta,""), NVL(vCliente,""), NVL(cFecha_Alta,""), TRIM(NVL(vNom_cte,"")),
                   TRIM(NVL(vProducto,"")), TRIM(NVL(cEstatus,"")), TRIM(NVL(vUsuario,"")), TRIM(NVL(vSucursal,""));
        END IF;	
        
    ELIF NVL(pModo,0) = 3  THEN 
        
        --- TODAS LAS CUENTAS DE PAGARE
        FOREACH
            SELECT {+INDEX(bdinvers:sv_instrum idx_instrum)} 
                   DISTINCT(a.cuenta), TRIM(a.num_cte) AS cte, a.fecha_alta, 
                   TRIM(d.nombre1)||" "||TRIM(d.nombre2)||" "||TRIM(d.apell_paterno)||" "||TRIM(d.apell_materno) AS nombre_cte,
                   TRIM(b.nombre) AS producto,
                   CASE WHEN a.status_cta = '1' THEN 'ACTIVA' 
                        WHEN a.status_cta = '2' THEN 'CANCELADA' 
                        WHEN a.status_cta = '4' THEN 'RENOVADA' 
                   END AS status,
                   f.ejecutivo||" - "|| f.nombre AS usuario_aper
              INTO vCuenta, vCliente, cFecha_Alta, vNom_cte, vProducto, cEstatus, vUsuario
              FROM bdinvers:sv_maeinv a,
                   bdinvers:sv_instrum b,
                   bdinteg:si_cliente d,
                   bdinteg:si_tipper e,
                   bdinteg:si_ejecut f
             WHERE a.num_cte = d.numcte 
               AND a.cod_instrum = b.cod_instrum
               AND d.tpo_persona = e.tpo_persona
               AND a.promotor = f.ejecutivo
               AND e.es_fisica = "S" 
               AND a.sucursal = pSucursal
               AND a.fecha_alta >= pFechaIni 
               AND a.fecha_alta <= pFechaFin
             ORDER BY a.cuenta, a.fecha_alta
            
            RETURN cCodRet, vMensaje, NVL(vCuenta,""), NVL(vCliente,""), NVL(cFecha_Alta,""), TRIM(NVL(vNom_cte,"")),
                   TRIM(NVL(vProducto,"")), TRIM(NVL(cEstatus,"")), TRIM(NVL(vUsuario,"")), TRIM(NVL(vSucursal,"")) WITH RESUME;
        END FOREACH;
        
        LET iRegistros = DBINFO("sqlca.sqlerrd2");
        
        IF iRegistros = 0 THEN
            LET cCodRet = "000005";
            LET vMensaje = "NO SE ENCONTRARON REGISTROS CON LA INFORMACIÓN PROPORCIONADA";
            RETURN cCodRet, vMensaje, NVL(vCuenta,""), NVL(vCliente,""), NVL(cFecha_Alta,""), TRIM(NVL(vNom_cte,"")),
                   TRIM(NVL(vProducto,"")), TRIM(NVL(cEstatus,"")), TRIM(NVL(vUsuario,"")), TRIM(NVL(vSucursal,""));
        END IF;	
        
    END IF;
    
    END;
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: PROCEDIMIENTO QUE REGRESA LA INFORMACIÓN DE CUENTAS EFECTIVAS,INVERSIÓN CRECIENTE O PAGARÉ LAS QUE EXISTAN ',
'EN UN AÑO DE ACUERDO A LA FECHA HOY ACTIVAS, CANCELADAS O AMBAS',
'AUTOR :JOSUE REMBERTO ZAZUETA ACOSTA ',
'FECHA : 11 DE SEPTIEMBRE DE EL 2013',
'VERSION: 11092013.1820',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".bloqueoctas_tmp(pempresa char(3))

RETURNING CHAR(5);

   DEFINE vcodret     	CHAR(5);
   DEFINE sql_err     	INTEGER;
   DEFINE vcuenta	CHAR(20);
   DEFINE vfecha	DATE;
   DEFINE vhora		CHAR(15);
   DEFINE vsql		CHAR(100);
   DEFINE vfolio	CHAR(20);

   LET    vcodret = "000";

   BEGIN

   ON EXCEPTION
       SET sql_err
       IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
           RETURN vcodret;
       END IF;
   END EXCEPTION;

   -- SET DEBUG FILE TO "./bloqueo_cta_tmp.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   SELECT fecha_hoy
     INTO vfecha
     FROM sc_fechas
    WHERE empresa = pempresa;

   LET vhora = current hour to fraction;

   LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
{
   
   CREATE TABLE "informix".cuentasbloq(cuenta CHAR(20));

   LET vsql = "";
   LET vsql = 'echo "LOAD FROM cuentasabloquear.txt INSERT INTO cuentasbloq" > ctas_bloq.sql';
   SYSTEM vsql;

   LET vsql = "";
   --LET vsql = "dbaccess bdicheq ctas_bloq.sql";
   LET vsql = "/ifxsif01/bin/dbaccess bdicheq ctas_bloq.sql";
   SYSTEM vsql;
   LET vsql = "";
   
}
   FOREACH
       SELECT UNIQUE cuenta
	 INTO vcuenta
         FROM cuentasbloq

       INSERT INTO sc_ctabloqueo VALUES(vcuenta, "09", 4, " ", " ", " ", " ");

       INSERT INTO sc_histbloq VALUES(pempresa, vcuenta, "B", "09", 4,
	                              0.00, "informix", vfecha,
				      current hour to fraction,
				      "1111", "B", vfolio, " ", " ", " ", " ", " ");

       UPDATE sc_maechq
  	  SET status_cta = "3",
	      motivo = "09"
	WHERE empresa = pempresa
	  AND cuenta = vcuenta;
   END FOREACH

   END;

   DROP TABLE "informix".cuentasbloq;

   RETURN vcodret;

END PROCEDURE;