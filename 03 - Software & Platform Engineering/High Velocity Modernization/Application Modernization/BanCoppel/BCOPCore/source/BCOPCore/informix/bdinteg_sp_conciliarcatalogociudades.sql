CREATE PROCEDURE "informix".sp_conciliarcatalogociudades()
RETURNING CHAR(6), CHAR(80);
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);

DEFINE vfechahoy                        DATE;
-----------------------------------------------------------
DEFINE vnumerociudad                    INTEGER;
DEFINE vnombreciudad                   CHAR(30);
DEFINE vinicialciudad                  CHAR(4);
DEFINE vnumeroestado                   INTEGER;
DEFINE vinicialestado                  CHAR(4);
DEFINE vsalariominimo                  INTEGER;
DEFINE vivaciudad                      INTEGER;
DEFINE vantiguedadciudad               DATE;
DEFINE vgerentezona                    INTEGER;
DEFINE vregioncobranzas                INTEGER;
DEFINE vunificaciudadescobranzas       INTEGER;
DEFINE vgerentecobranzas               INTEGER;
DEFINE vregionestadodecuenta           CHAR(1);
DEFINE vtipo_ciudad                    CHAR(1);
DEFINE vnumerociudadcoppel             INTEGER;
DEFINE vnombreciudadcoppel             CHAR(30);

DEFINE v_numerociudad                    INTEGER;
DEFINE v_nombreciudad                   CHAR(30);
DEFINE v_inicialciudad                  CHAR(4);
DEFINE v_numeroestado                   INTEGER;
DEFINE v_inicialestado                  CHAR(4);
DEFINE v_salariominimo                  INTEGER;
DEFINE v_ivaciudad                      INTEGER;
DEFINE v_antiguedadciudad               DATE;
DEFINE v_gerentezona                    INTEGER;
DEFINE v_regioncobranzas                INTEGER;
DEFINE v_unificaciudadescobranzas       INTEGER;
DEFINE v_gerentecobranzas               INTEGER;
DEFINE v_regionestadodecuenta           CHAR(1);
DEFINE v_tipo_ciudad                    CHAR(1);
DEFINE v_numerociudadcoppel             INTEGER;
DEFINE v_nombreciudadcoppel             CHAR(30);
DEFINE vEmpresa                         CHAR(3);
DEFINE vProceso                         CHAR(30);
DEFINE vProcesoinicio                   CHAR(30);


---------------------------------------------------------
LET vnumerociudad                    = 0;
LET vnombreciudad                   = '';
LET vinicialciudad                  = '';
LET vnumeroestado                   = 0;
LET vinicialestado                  = '';
LET vsalariominimo                  = 0;
LET vivaciudad                      = 0;
LET vantiguedadciudad               = '';
LET vgerentezona                    = 0;
LET vregioncobranzas                = 0;
LET vunificaciudadescobranzas       = 0;
LET vgerentecobranzas               = 0;
LET vregionestadodecuenta           = '';
LET vtipo_ciudad                    = '';
LET vnumerociudadcoppel             = 0;
LET vnombreciudadcoppel             = '';

LET v_numerociudad                    = 0;
LET v_nombreciudad                   = '';
LET v_inicialciudad                  = '';
LET v_numeroestado                   = 0;
LET v_inicialestado                  = '';
LET v_salariominimo                  = 0;
LET v_ivaciudad                      = 0;
LET v_antiguedadciudad               = '';
LET v_gerentezona                    = 0;
LET v_regioncobranzas                = 0;
LET v_unificaciudadescobranzas       = 0;
LET v_gerentecobranzas               = 0;
LET v_regionestadodecuenta           = '';
LET v_tipo_ciudad                    = '';
LET v_numerociudadcoppel             = 0;
LET v_nombreciudadcoppel             = '';
LET vEmpresa                         = '001';

------------------------------------------------------------
LET cCod_ret      = '00000';
LET sql_err       = 0;
LET cMensaje      = 'Proceso Exitoso';
LET vProceso      = '0200';
LET vProcesoinicio = 'PROCESO INICIALIZADO';

BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;

            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, '', '', '01') returning cCod_ret;
			    RETURN cCod_ret, cMensaje;
      --  RETURN cCod_ret;
        
	    END EXCEPTION;

/*
Creado por José Almeida
Fecha de creacion 22 de octubre de 2009
Deberá instalarse en BDINTEG
Se creo para el conciliamiento de datos
de las ciudades que existen en el catalogo de coppel
con los de bancoopel, aquellas ciudades que existen en
coppel y no bancoppel seran insertadas en el catalogo
y aquellas que tienen diferencia entre sus campos
*/
--Modificado por Marco A. Campos
--Fecha: 20100614
--Para que actualice en tabla si_catciudades


        --SET DEBUG FILE TO "/tmp/ALMEIDA/SP_ConciliarCatalogoCiudades.out";
        --TRACE ON;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, vProcesoinicio, '02') returning cCod_ret;
		    --RETURN cCod_ret, cMensaje;

        ---------------Obtenemos la fecha de Hoy-----------------
        SELECT fecha_hoy
        INTO   vfechahoy
        FROM   bdinteg:si_fechas;

        ---------------Borramos los datos de la tabla para insertar nuevos conciliados--------
        DELETE si_catciudades_bcpl_cpl;

        --------------Obtenemos los datos de las dos tablas y cuando no existan en bancoopel-----
        --------------se insertaran en el catalogo de bancoopel-----------------------------------
     FOREACH
        SELECT a.numerociudad,      a.nombreciudad,     a.inicialciudad,    a.numeroestado,     a.inicialestado,
               a.salariominimo,     a.ivaciudad,        a.antiguedadciudad, a.gerentezona,      a.regioncobranzas,
               a.unificaciudadescobranzas, a.gerentecobranzas,              a.regionestadodecuenta, a.tipo_ciudad,
               a.numerociudadcoppel,a.nombreciudadcoppel,b.numerociudad,    b.nombreciudad ,    b.inicialciudad,
               b.numeroestado,      b.inicialestado,    b.salariominimo,    b.ivaciudad,        b.antiguedadciudad,
               b.gerentezona,       b.regioncobranzas,  b.unificaciudadescobranzas,             b.gerentecobranzas,
               b.regionestadodecuenta, b.tipo_ciudad,   b.numerociudadcoppel, b.nombreciudadcoppel
        INTO   vnumerociudad,       vnombreciudad ,     vinicialciudad,     vnumeroestado,      vinicialestado,
               vsalariominimo,      vivaciudad,         vantiguedadciudad,  vgerentezona,       vregioncobranzas,
               vunificaciudadescobranzas, vgerentecobranzas,                vregionestadodecuenta, vtipo_ciudad,
               vnumerociudadcoppel, vnombreciudadcoppel,v_numerociudad,     v_nombreciudad ,    v_inicialciudad,
               v_numeroestado,      v_inicialestado,    v_salariominimo,    v_ivaciudad,        v_antiguedadciudad,
               v_gerentezona,       v_regioncobranzas,  v_unificaciudadescobranzas,             v_gerentecobranzas,
               v_regionestadodecuenta, v_tipo_ciudad,   v_numerociudadcoppel,v_nombreciudadcoppel

        FROM   BDINTEG:si_catciudades_coppel a
        LEFT OUTER JOIN BDINTEG:si_catciudades b ON (a.numerociudad = b.numerociudad)

        IF ( v_numerociudad IS NULL )  THEN
            --- INSERTA CIUDADES NUEVAS
            INSERT INTO BDINTEG:si_catciudades_bcpl_cpl
                        --(numerociudad, fecha_conciliacion, nombreciudad , inicialciudad, numeroestado,tipo_actualizacion)
                        (numerociudad, fecha_conciliacion, nombreciudad , tipo_actualizacion)
                 VALUES (vnumerociudad, vfechahoy, vnombreciudad , 'I' );

            INSERT INTO BDINTEG:informix.si_catciudades
                        (numerociudad,  nombreciudad, inicialciudad, numeroestado, inicialestado, salariominimo,
                         gerentezona,  regioncobranzas, ivaciudad,  antiguedadciudad, unificaciudadescobranzas, gerentecobranzas,
                         regionestadodecuenta, tipo_ciudad, numerociudadcoppel, nombreciudadcoppel, f_inserta)
                 VALUES(vnumerociudad,  vnombreciudad, vinicialciudad, vnumeroestado,  vinicialestado, vsalariominimo,
                        vgerentezona,   vregioncobranzas, vivaciudad,  vantiguedadciudad,   vunificaciudadescobranzas, vgerentecobranzas,
                        vregionestadodecuenta, vtipo_ciudad, vnumerociudadcoppel, vnombreciudadcoppel, vfechahoy);


            UPDATE     BDINTEG:si_catciudades_coppel
               SET b_conciliado = 'V'
             WHERE numerociudad = vnumerociudad;

            CONTINUE FOREACH;

        --D
        ELSE
          IF  ( (vnumeroestado <> v_numeroestado)
                   OR (vsalariominimo <> v_salariominimo )
                   OR (vivaciudad <> v_ivaciudad)
                   OR (vgerentezona <> v_gerentezona)
                   OR (vregioncobranzas <> v_regioncobranzas)
                   OR (vunificaciudadescobranzas <> v_unificaciudadescobranzas)
                   OR (vgerentecobranzas <> v_gerentecobranzas)
                   OR (vnumerociudadcoppel <> v_numerociudadcoppel)
                   OR (vinicialciudad <> v_inicialciudad)
                   OR (vinicialestado <> v_inicialestado)
                   OR (vantiguedadciudad <> v_antiguedadciudad)
                   OR (vregionestadodecuenta <> v_regionestadodecuenta)
                   OR (vtipo_ciudad <> v_tipo_ciudad)
                   OR (vnombreciudadcoppel = '') ) THEN

            INSERT INTO BDINTEG:si_catciudades_bcpl_cpl
                        --(numerociudad, fecha_conciliacion, nombreciudad , inicialciudad, tipo_actualizacion)
                        (numerociudad, fecha_conciliacion, nombreciudad , tipo_actualizacion)
                 VALUES (vnumerociudad, vfechahoy, vnombreciudad , 'M');

            --Actualizar en si_catciudades los valores comparados en el if
            UPDATE BDINTEG:si_catciudades
               SET salariominimo = vsalariominimo,
                   gerentezona = vgerentezona,
                   regioncobranzas = vregioncobranzas,
                   ivaciudad = vivaciudad,
                   antiguedadciudad = vantiguedadciudad,
                   unificaciudadescobranzas = vunificaciudadescobranzas,
                   gerentecobranzas = vgerentecobranzas,
                   regionestadodecuenta = vregionestadodecuenta,
                   tipo_ciudad = vtipo_ciudad,
                   numerociudadcoppel = numerociudadcoppel,
                   nombreciudadcoppel = vnombreciudadcoppel,
                   fechaultimaactualizacion = vfechahoy
             WHERE numerociudad = vnumerociudad
               and numeroestado = vnumeroestado;

             UPDATE BDINTEG:si_catciudades_coppel SET b_conciliado = 'V' WHERE numerociudad = vnumerociudad;
          END IF;
        end if;
 
      END FOREACH;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, '', '', '03') returning cCod_ret;
	  RETURN cCod_ret, cMensaje;
  --RETURN cCod_ret;

END;

END PROCEDURE;