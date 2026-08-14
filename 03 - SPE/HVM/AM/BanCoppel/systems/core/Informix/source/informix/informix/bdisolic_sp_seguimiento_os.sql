CREATE PROCEDURE "informix".sp_seguimiento_os()
       RETURNING CHAR(5), CHAR(80);

DEFINE  vCodRet                 CHAR(5);
DEFINE  vMensaje                CHAR(80);
DEFINE  SQL_ERR                 INTEGER;
DEFINE  ISAM_ERR                INTEGER;
DEFINE  ERROR_INFO              VARCHAR(80);
DEFINE  v_credito_bancoppel     CHAR(20);
DEFINE  v_fecha_solic           DATE;
DEFINE  v_numcte                CHAR(20);
DEFINE  v_fecha_nacimiento      DATE;
DEFINE  v_folio                 INTEGER;
DEFINE  v_fecha_sol_os          DATE;
DEFINE  v_sucursal              CHAR(4);
DEFINE  v_cliente               CHAR(110);
DEFINE  v_calle                 CHAR(30);
DEFINE  v_noext                 CHAR(10);
DEFINE  v_noint                 CHAR(10);
DEFINE  v_complemento           CHAR(80);
DEFINE  v_colonia               CHAR(32);
DEFINE  v_ciudad                CHAR(27);                
DEFINE  v_telefono_particular   CHAR(13);
DEFINE  v_folio_os_coppel       CHAR(13);
DEFINE  v_dias_transcurridos    INTEGER;
DEFINE  v_estado                CHAR(7);
DEFINE  v_fecha_hoy             DATE;

    LET vCodRet          = "00000";
    LET vMensaje         = "EJECUCION EXITOSA";

BEGIN

  ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET vCodRet  = SQL_ERR;
     LET vMensaje  = ERROR_INFO;
     RETURN vCodRet, vMensaje;
  END EXCEPTION;

--------------------------------------------------------------------------
--se borra cb_info_administrativa datos antiguos
--------------------------------------------------------------------------
    truncate bdisolic:ss_estatus_enviada_os;
----------------------------------------------

    SELECT fecha_hoy
    INTO v_fecha_hoy
    FROM bdinteg:si_fechas;

        --se obtiene la informacion
		SET ISOLATION TO dirty READ;

FOREACH

    SELECT  a.num_solicitud
            ,a.fecha_insert
            ,a.numcte
            ,b.fechanacimiento
            ,b.folio
            ,b.fechamovto
    INTO v_credito_bancoppel, v_fecha_solic, v_numcte, v_fecha_nacimiento
         ,v_folio, v_fecha_sol_os 
    FROM    bdisolic:ss_solicitudes a
            ,bdisolic:ss_osclientesupervisar b
    WHERE b.empresa = a.empresa
        AND b.num_solicitud = a.num_solicitud 
        AND a.empresa = '001' 
        AND a.tipo_solicitud = 'T' 
        AND a.status_solicitud = 'OS'
    
    SELECT e.sucursal
            ,trim(e.nombre1) || ' ' || trim(e.nombre2) || ' '|| trim(e.apell_paterno) || ' '|| trim(e.apell_materno)
            ,s.nombrecalle
            ,d.numeroextcalle
            ,d.numerointcalle
            ,d.observaciones
            ,NVL(lpad(d.numerocolonia, 3, '0') || ' ' || trim(z.nombrezona),'') as zona
            ,NVL(t.numerociudad || '-' || trim(t.inicialciudad),'') as ciudad
            ,d.telefono1
            ,NVL(t.numeroestado || '-' || trim(t.inicialestado),'') as estado
    INTO v_sucursal, v_cliente, v_calle, v_noext
         ,v_noint, v_complemento, v_colonia, v_ciudad, v_telefono_particular, v_estado
    FROM bdinteg:si_direcciones d
                ,bdinteg:si_cliente e
                ,bdinteg:si_catzonas z
                ,bdinteg:si_catcalles s
                ,bdinteg:si_catciudades t
    WHERE d.numcte = e.numcte
        AND d.numerociudad = z.numerociudad
        AND d.numerocolonia = z.numerocolonia
        AND d.numerocalle = s.numerocalle
        AND t.numerociudad = z.numerociudad
        AND e.empresa = '001'
        AND d.tipo_dir = '1'
        AND d.secuencia = ( select max(p.secuencia) from bdinteg:si_direcciones p
                        where p.numcte = d.numcte
                          and p.tipo_dir = '1')
        AND d.numcte = v_numcte;

        LET v_folio_os_coppel= v_sucursal || '-' || v_folio;
        LET v_dias_transcurridos= v_fecha_hoy - v_fecha_sol_os;

---------------SE INCERTAN DATOS GENERADOS----------------------------------------------------------

        INSERT INTO bdisolic:ss_estatus_enviada_os (sucursal, num_solicitud, fecha_solicitud, cliente, fecha_nacimiento,
                                                    folio_os_coppel, fecha_solicitud_os, dias_transcurridos, calle, num_exterior,
                                                    num_interior, complemento, colonia, ciudad, estado, telefono)
        VALUES(v_sucursal, v_credito_bancoppel, v_fecha_solic, v_cliente, v_fecha_nacimiento, v_folio_os_coppel, v_fecha_sol_os,
                v_dias_transcurridos, v_calle, v_noext, v_noint, v_complemento, v_colonia, v_ciudad, v_estado, v_telefono_particular);

END FOREACH;

END
RETURN vCodRet, vMensaje;

END PROCEDURE;