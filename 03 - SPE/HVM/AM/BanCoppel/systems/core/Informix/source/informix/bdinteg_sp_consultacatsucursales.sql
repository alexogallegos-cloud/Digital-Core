CREATE PROCEDURE "informix".sp_consultacatsucursales(pDesde INTEGER, pHasta INTEGER)
RETURNING CHAR(6), CHAR(80), CHAR(2), CHAR(3), CHAR(4), CHAR(40), CHAR(81), CHAR(14), CHAR(14);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err                      INTEGER;
DEFINE isam_err                     INTEGER;
DEFINE error_info                   CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);

DEFINE v_estado         CHAR(2);
DEFINE v_ciudad         CHAR(3);
DEFINE v_sucursal      CHAR(4);
DEFINE v_nombre      CHAR(40);
DEFINE v_direccion     CHAR(81);
DEFINE v_telefono1       CHAR(14);
DEFINE v_telefono2       CHAR(14);

------------------------------------------------------------

-- Creado: Walber Castro
-- Fecha: 28 de mayo de 2010
-- Crear en BDINTEG
-- Se crea con el objetivo de consultar el catalogo de sucursales.
LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cMensaje  = 'Proceso Exitoso';

LET v_estado = '';
LET v_ciudad = '';
LET v_sucursal  ='';
LET v_nombre = '';
LET v_direccion = '';
LET v_telefono1 = '';
LET v_telefono2 = '';

      BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
          LET cCod_ret = sql_err;
            LET cMensaje = error_info;
      RETURN cCod_ret, cMensaje, v_estado, v_ciudad, v_sucursal, v_nombre, v_direccion, v_telefono1, v_telefono2;
      END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_consultacatsucursales.out";
--TRACE ON;
    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

foreach
    /*SELECT SKIP pDesde FIRST pHasta NVL(estado,''), NVL(ciudad,''), NVL(sucursal,''), TRIM(NVL(nombre,'')), TRIM(NVL(direccion1,'')) || ' ' ||  TRIM(NVL(direccion2,'')), TRIM(NVL(telefono1,'')), TRIM( NVL(telefono2,'')) 
   INTO v_estado, v_ciudad, v_sucursal, v_nombre, v_direccion, v_telefono1, v_telefono2
    FROM bdinteg:si_sucursales ORDER BY estado, ciudad, sucursal*/

    SELECT SKIP pDesde FIRST pHasta NVL(ptf.cve_estado,''), NVL(ptf.cve_ciudad,''), NVL(id_ptf,''), TRIM(NVL(suc.nombre,'')), TRIM(NVL(ptf.calle||' NUM '||ptf.num_ext,'')) || ' ' ||  TRIM(NVL('COL '||loc.desc_colonia||' C.P. '||loc.cp,'')), TRIM(NVL(tel1,'')), TRIM( NVL(tel2,'')) 
           INTO v_estado, v_ciudad, v_sucursal, v_nombre, v_direccion, v_telefono1, v_telefono2
    FROM bdinteg:si_ptf ptf 
    INNER JOIN bdinteg:si_sucursales suc ON (ptf.id_ptf =  suc.sucursal AND ptf.tipo = suc.tipo)
    LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND 
                                                          loc.cp = loc.cp AND
                                                          loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
    WHERE ptf.tipo <> 'C'
    ORDER BY ptf.cve_estado, ptf.cve_ciudad, ptf.id_ptf

    RETURN cCod_ret, cMensaje, v_estado, v_ciudad, v_sucursal, v_nombre, v_direccion, v_telefono1, v_telefono2 WITH RESUME;
    LET cCod_ret = '';
    LET cMensaje = '';
END foreach;

END;
END PROCEDURE;