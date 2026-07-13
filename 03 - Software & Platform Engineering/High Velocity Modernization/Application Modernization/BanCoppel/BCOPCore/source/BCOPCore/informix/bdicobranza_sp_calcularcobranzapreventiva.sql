CREATE PROCEDURE "informix".sp_calcularcobranzapreventiva()
RETURNING  CHAR(6), CHAR(80);
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cMensaje 		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE vtFechaUltPago                   DATE;
DEFINE vtFechaCorte                     DATE;
DEFINE vtFechaLimite                    DATE;
------------------------------------------------------------
DEFINE vdia						        DATE;
DEFINE vdia2                            DATE;
DEFINE vhora						    CHAR(8);
------------------------------------------------------------
DEFINE vnumcte                          CHAR(20);
DEFINE vnum_credito                     CHAR(20);
DEFINE vCiudad                          CHAR(20);
DEFINE vEstado                          CHAR(20);
DEFINE vNombre                          CHAR(110);
DEFINE vSexo                            CHAR(1);
DEFINE vEstado_Civil                    CHAR(2);
DEFINE vTelefono_Casa                   CHAR(13);
DEFINE vTelefono_Celular                CHAR(13);
DEFINE vSaldo_total                     DECIMAL(18,2);
DEFINE vPago_Minimo_Total               DECIMAL(18,2);
DEFINE vvencido                         INTEGER;
------------------------------------------------------------
DEFINE vsituacion                   CHAR(1);
DEFINE vcausa                       SMALLINT;
DEFINE vinstruccion                 CHAR(1);
DEFINE monto_ini                    DECIMAL(18,2);
DEFINE monto_fin                    DECIMAL(18,2);


--SET DEBUG FILE TO "/tmp/SP_CalcularCobranzaPreventiva.out";
--TRACE ON;

------------------------------------------------------------
LET vtFechaLimite =  MDY(month(current),16,year(current));
LET vtFechaCorte  = (vtFechaLimite - 1 UNITS MONTH)::DATE;
LET vtFechaCorte  = MDY(month(vtFechaCorte),20,year(vtFechaCorte));



LET vtFechaCorte    = vtFechaCorte;
LET vtFechaLimite   = vtFechaLimite;


------------------------------------------------------------
LET vnumcte                          = '';
LET vnum_credito                     = '';
LET vCiudad                          = '';
LET vEstado                          = '';
LET vNombre                          = '';
LET vSexo                            = '';
LET vEstado_Civil                    = '';
LET vTelefono_Casa                   = '';
LET vTelefono_Celular                = '';
LET vSaldo_total                     = 0;
LET vPago_Minimo_Total               = 0;
LET vvencido                         = 0;
------------------------------------------------------------

LET cCod_ret      = '000000';
LET sql_err       = 0;
LET isam_err      = 0;
LET error_info    = '';
LET cMensaje      = 'PROCESO EXITOSO';
------------------------------------------------------------

--Creado: José de Jesús Almeida Inzunza
--Fecha: 29 de septiembre de 2009
--Crear en BDICOBRANZA

--Se crea con el objetivo de obtener los clientes con 0 pagos
--vencidos que pasaran a 1, y a los clientes con 1 pago vencido
--que pasaran a 2 con el proposito de despues descargar los
--datos de la tabla en un archivo para su explotacion

--Modificado: José de Jesús Almeida
--Fecha: 26 de enero de 2010
--Se modifica para que no elimine los datos de la ultima ejecucion de
--la tabla cb_info_preventiva

--Modifico: Adilene Lara
--Fecha: 04-03-2010
--Se modifica para guardar la situacion especial y causa correspondiente al cliente.
--Se modifica para que solamente genere informacion de clientes con 0 pagos vencidos

      BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;

            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
	        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora FROM sysmaster:sysshmvals;

            INSERT INTO cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
            VALUES('Cobranza Preventiva', cCod_ret, cMensaje, USER, vdia, vhora);

			RETURN cCod_ret, cMensaje;

	    END EXCEPTION;

      SELECT numerico
      INTO  monto_ini
      FROM bdicobranza:cb_param_campanias where cod_param= 4;

      SELECT numerico
      INTO  monto_fin
      FROM bdicobranza:cb_param_campanias where cod_param= 3;

         SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
	     SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora FROM sysmaster:sysshmvals;

         INSERT INTO cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
         VALUES('Cobranza Preventiva', '11111', 'PROCESO INICIALIZADO', USER, vdia, vhora);


-----------Si existe se elimina la los datos en tabla-------------------------------


    SELECT MAX(fecha_ejecucion) INTO vdia2 FROM bdicobranza:cb_info_preventiva;

    IF(vdia2 = vdia ) THEN

    DELETE bdicobranza:cb_info_preventiva WHERE fecha_ejecucion = vdia2;

    ELSE

    DELETE bdicobranza:cb_info_preventiva WHERE fecha_ejecucion < vdia2;

    END IF;
---------------------------------------------------------------------------------

set isolation to dirty read;
SET OPTIMIZATION LOW;
FOREACH
select
a.numcte,                                                                                     -- Cliente
a.num_credito,                                                                                -- Numero de Credito
       e.numerociudad || '-' || trim(f.inicialciudad) Ciudad,                                 -- Clave ciudad
       f.numeroestado || '-' || trim(f.inicialestado) Estado,                                 -- Clave estado
       trim(c.nombre1) || " " || trim(c.nombre2) || " " ||
       trim(c.apell_paterno) || " " || trim(c.apell_materno) Nombre,                          -- Nombre
       d.sexo Sexo,                                                                           -- Sexo
       d.estado_civil Estado_Civil,                                                           -- Edo Civil
       e.telefono1 Telefono_Casa,                                                             -- Tel Casa
       e.telefono2 Telefono_Celular,                                                          -- Tel Cel

     (NVL (b.sdo_cap_insoluto,0) +
    (SELECT NVL(SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),0)+
            NVL(SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),0) +
            NVL(SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) -
                NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)+
            NVL((SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) -
                NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)) *
            (SELECT iva
                FROM bdinteg:"informix".si_sucursales
                WHERE sucursal = a.sucursal
                AND empresa  = a.empresa )),0)
    FROM bdicred:sd_amortiza_credito
    WHERE empresa     = a.empresa
    AND num_credito = a.num_credito
    AND capital_status IN ('2','7'))  + NVL(b.sdo_retenido,0))  Saldo_total,                   -- Saldo_total

    ((SELECT NVL (SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),0)
        FROM bdicred:sd_amortiza_credito
        WHERE empresa = '001'
        AND num_credito = a.num_credito
        --AND num_credito = '600000017738'
        AND capital_status IN ('2','7'))
        +
    (SELECT NVL (SUM(NVL(iva_debe,0) - NVL(iva_pagado,0)),0)
        FROM bdicred:sd_amortiza_credito
        WHERE empresa = '001'
        and num_credito = a.num_credito
        --AND num_credito = '600000017738'
        and capital_status IN ('2','7'))
         +
       (SELECT NVL ( (sum(nvl(mora_provi_ordi,0)) +
        sum(nvl(mora_provi_cope,0))) * (1 + nvl( h.iva,0)),0)
        FROM bdicred:sd_amortiza_credito
        WHERE empresa = '001'
        --AND num_credito = '600000017738')
        AND num_credito = a.num_credito)
         +
        nvl(b.monto_financiado,0)  ) Pago_Minimo_Total,                                                -- Pago Minimo

       0 vencido
       -- Vencido
       INTO    vnumcte, vnum_credito, vCiudad, vEstado, vNombre, vSexo, vEstado_Civil, vTelefono_Casa, vTelefono_Celular, vSaldo_total,
        vPago_Minimo_Total, vvencido
FROM bdicred:sd_maecred a
join bdicred:sd_maesdos b on (b.empresa = '001' and a.num_credito = b.num_credito)
join bdinteg:si_cliente c on (a.numcte = c.numcte)
join bdinteg:si_ctepf d on (a.numcte = d.numcte)
join bdinteg:si_direcciones e on (a.numcte = e.numcte and tipo_dir = '1'
        and e.secuencia = ( select max(secuencia) FROM bdinteg:si_direcciones
        where tipo_dir = '1' and a.numcte = numcte))
left outer join bdinteg:si_catciudades f on (e.numerociudad = f.numerociudad)
left outer join bdisolic:ss_refpersonales g on (a.empresa = g.empresa
            and a.num_credito = g.num_solicitud and a.numcte = g.numcte and g.numcte_ref = 'R1')
left outer join bdinteg:si_sucursales h on (h.sucursal = a.sucursal and h.empresa = '001')
where a.empresa = '001'
and a.status_cred in ('AA')
--and b.monto_financiado >= 100
and b.monto_financiado between monto_ini and monto_fin
and a.numcte not in (select numcliente FROM  bdicobranza:cb_compac)

          IF EXISTS (SELECT fecha_ult_pago
                    FROM   bdicred:sd_maecredanexo
                    WHERE  num_credito = vnum_credito
                    AND    fecha_ult_pago BETWEEN vtFechaCorte AND vtFechaLimite
                    AND    empresa  = '001') THEN

                   CONTINUE FOREACH;

          END IF;

                    LET vsituacion = NULL;
                    LET vcausa     = NULL;
                         SELECT  FIRST 1 situacion,  causa
                         INTO    vsituacion, vcausa
                         FROM    bdisitesp:se_ctessitespcte
                         WHERE   numcte = vnumcte;

                         LET vinstruccion = 1;

                    IF ((vsituacion IS NOT NULL) AND (vcausa IS NOT NULL)) THEN

                                SELECT FIRST 1 instruccion
                                INTO   vinstruccion
                                FROM   bdisitesp:se_situacionaccion
                                WHERE  situacion= vsituacion
                                AND    causa= vcausa
                                AND    idaccion = 9;

                    END IF;

                    IF (vinstruccion = 1) THEN

               INSERT INTO CB_INFO_PREVENTIVA
                (
                cliente          ,  credito     , Ciudad       , Estado          ,      Nombre,
                Sexo             ,  Estado_Civil, T_Casa       , T_Celular       , Saldo_tot,
                Pago_Min         ,  vencido     , fecha_ejecucion, causa, situacion
                )
                VALUES
               (
               vnumcte          , vnum_credito ,  vCiudad       , vEstado          ,   vNombre   ,
               vSexo            , vEstado_Civil,  vTelefono_Casa, vTelefono_Celular, vSaldo_total,
               vPago_Minimo_Total, vvencido, current, vcausa, vsituacion
               );
               END IF;

END FOREACH;

                SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
	            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora FROM sysmaster:sysshmvals;

                INSERT INTO cb_bitacora_cob(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert)
                VALUES('Cobranza Preventiva', cCod_ret, cMensaje, USER, vdia,  vhora);

	        	RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;