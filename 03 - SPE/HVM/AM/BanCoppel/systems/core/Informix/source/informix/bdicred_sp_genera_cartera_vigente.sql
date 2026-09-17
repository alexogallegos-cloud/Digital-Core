CREATE PROCEDURE "informix".sp_genera_cartera_vigente()

--DATOS A REGRESAR
   RETURNING
    CHAR(5);

--DEFINICION DE VARIABLES

    DEFINE vSqlErr                SMALLINT;
    DEFINE vSql                   CHAR(500);
    DEFINE v_directorio           CHAR(35);
    DEFINE vCodret                CHAR(5);
    DEFINE vNum_cte               CHAR(20);
    DEFINE vNum_credito           CHAR(20);
    DEFINE vNum_tarjeta           CHAR(20);
    DEFINE vNombre                CHAR(104);
    DEFINE vSexo                  CHAR(1);
    DEFINE vEstado_civil          CHAR(2);
    DEFINE vTelefono1             CHAR(13);
    DEFINE vTelefono2             CHAR(13);
    DEFINE vTelefono3             CHAR(13);
    DEFINE vExtension             CHAR(5);
    DEFINE vCiudad                CHAR(7);
    DEFINE vEstado                CHAR(7);
    DEFINE vNombre_ref            CHAR(104);
    DEFINE vTelefono_ref          CHAR(13);
    DEFINE vCapital_total         DECIMAL(14,2);
    DEFINE vCapital_vigente       DECIMAL(14,2);
    DEFINE vTransitorio           DECIMAL(14,2);
    DEFINE vSdo_vdo_trasp         DECIMAL(14,2);
    DEFINE vSdo_vdo_trasp_no_exig DECIMAL(14,2);
    DEFINE vInteres               DECIMAL(14,2);
    DEFINE vIva_interes           DECIMAL(14,2);
    DEFINE vMoratorios            DECIMAL(14,2);
    DEFINE vIva_mora              DECIMAL(14,2);
    DEFINE vSaldo_total           DECIMAL(14,2);
    DEFINE vPago_minimo_total     DECIMAL(14,2);
    DEFINE vFecha_ult_pago        DATE;
    DEFINE vMonto_ult_pago        DECIMAL(14,2);
    DEFINE vPagos_vencidos        INTEGER;
    DEFINE vTel_trabajo_adi       CHAR(13);
    DEFINE vTel_ext_adi           CHAR(13);

--INICIALIZACION DE VARIABLES

    LET vSqlErr = 0;
    LET vSql = "";
    LET v_directorio  = "";
    LET vCodret = '000';
    LET vNum_cte="";
    LET vNum_credito="";
    LET vNum_tarjeta="";
    LET vNombre="";
    LET vSexo="";
    LET vEstado_civil="";
    LET vTelefono1="";
    LET vTelefono2="";
    LET vTelefono3="";
    LET vExtension="";
    LET vCiudad="";
    LET vEstado="";
    LET vNombre_ref="";
    LET vTelefono_ref="";
    LET vCapital_total=0;
    LET vCapital_vigente=0;
    LET vTransitorio=0;
    LET vSdo_vdo_trasp=0;
    LET vSdo_vdo_trasp_no_exig=0;
    LET vInteres=0;
    LET vIva_interes=0;
    LET vMoratorios=0;
    LET vIva_mora=0;
    LET vSaldo_total=0;
    LET vPago_minimo_total=0;
    LET vFecha_ult_pago="";
    LET vMonto_ult_pago=0;
    LET vPagos_vencidos=0;
    LET vTel_trabajo_adi="";
    LET vTel_ext_adi="";

BEGIN

      ON EXCEPTION SET vSqlErr
		 IF vSqlErr <> 0 THEN
			LET vCodret = vSqlErr;
			RETURN vcodret;
		 END IF;
	  END EXCEPTION;
     --SET DEBUG FILE TO "generacarteravigente.out";
     --TRACE ON;

   IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_cartera' ) THEN
      DROP TABLE temp_cartera;
   END IF;

   IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_ultimo_pago' ) THEN
      DROP TABLE temp_ultimo_pago;
   END IF;

   IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_pagos_venc' ) THEN
      DROP TABLE temp_pagos_venc;
   END IF;

   IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_tel_trabajo' ) THEN
      DROP TABLE temp_tel_trabajo;
   END IF;

   IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'temp_cart' ) THEN
      DROP TABLE temp_cart;
   END IF;

   CREATE TABLE bdicred:temp_cart (num_cte CHAR(20),  num_credito CHAR(20), num_tarjeta CHAR(20), nombre  CHAR(104), sexo CHAR(1),
                                    estado_civil CHAR(2), telefono1 CHAR(13),  telefono2 CHAR(13), telefono3 CHAR(13), extension  CHAR(5),
                                    ciudad CHAR(7), estado CHAR(7), nombre_ref CHAR(104), telefono_ref CHAR(13), capital_total DECIMAL(14,2),
                                    capital_vigente DECIMAL(14,2), transitorio DECIMAL(14,2), sdo_vdo_trasp DECIMAL(14,2),
                                    sdo_vdo_trasp_no_exig DECIMAL(14,2), interes DECIMAL(14,2), iva_interes DECIMAL(14,2),
                                    moratorios DECIMAL(14,2), iva_mora DECIMAL(14,2), saldo_total DECIMAL(14,2), pago_minimo_total DECIMAL(14,2),
                                    fecha_ult_pago DATE, monto_ult_pago DECIMAL(14,2), pagos_vencidos INTEGER, tel_trabajo_adi CHAR(13),
                                    tel_ext_adi CHAR(13) );

   -- Generació® ¤e Reporte de Cartera (VIGENTE)

   --set isolation to dirty read; -- Limpia el area temporal

   -- Datos del Cliente y Saldos

   SELECT a.numcte,
       d.num_credito, -- Numero de Credito
       e.num_tarjeta, -- Numero de Tarjeta
       TRIM(a.nombre1) || " " || TRIM(a.nombre2) || " " ||
       TRIM(a.apell_paterno) || " " || TRIM(a.apell_materno) Nombre, -- Nombre completo
       -- a.nombre1, a.nombre2, a.apell_paterno, a.apell_materno,
       aa.sexo Sexo, -- Sexo
       aa.estado_civil Estado_Civil,
       --      case
       --         when aa.estado_civil = 'C' then 'CASADO(A)'
       --          when aa.estado_civil = 'S' then 'SOLTERO(A)'
       --          when aa.estado_civil = 'V' then 'VIUDO(A)'
       --          when aa.estado_civil = 'D' then 'DIVORCIADO(A)'
       --          when aa.estado_civil = 'U' then 'UNION LIBRE'
       --          else aa.estado_civil
       --       end, -- Estado civil
       --b.telefono1, b.telefono2, b.telefono3, b.extension,
       b.numerociudad || '-' || TRIM(j.inicialciudad) Ciudad, -- Clave ciudad
       j.numeroestado || '-' || TRIM(j.inicialestado) Estado, -- Clave estado
       --j.nombreciudad, -- Nombre ciudad
       i.nombre_ref,  -- Nombre Referencia
       i.telefono_ref, -- Telefono Referencia
       f.sdo_capital + f.monto_vencido + f.mto_venc_trasp + f.cap_tras_no_venci Capital_Total, -- Capital total
       f.sdo_capital Capital_Vigente, -- Capital Vigente
       f.monto_vencido transitorio, -- Capital Transitorio
       f.mto_venc_trasp  sdo_vdo_trasp,  -- Captital vencido Exigible
       f.cap_tras_no_venci sdo_vdo_trasp_no_exig, --Capital Vencido no Exigible
       f.sdo_no_exig Interes, -- Saldo interes
       f.sdo_no_exig * .15 Iva_Interes, -- Iva de saldo interes
       f.sdo_contab_mora Moratorios, -- Moratorios
       f.sdo_contab_mora * .15 Iva_Mora, -- Iva de Moratorios
       f.monto_vencido + f.mto_venc_trasp + f.cap_tras_no_venci +
       f.sdo_contab_mora + f.sdo_no_exig + (f.sdo_no_exig * .15) +
       (f.sdo_contab_mora * .15) +
       f.sdo_capital Saldo_total, -- Saldo Total
       f.monto_financiado Pago_Minimo_Total -- Pago Minimo
   FROM bdinteg:si_cliente a
     ,bdinteg:si_ctepf aa
     ,bdinteg:si_direcciones b
     ,bdicred:sd_maecred d
     ,bdicred:sd_tarjeta e
     ,bdicred:sd_maesdos f
     ,bdisolic:ss_refpersonales i
     ,bdinteg:si_catciudades j
   WHERE  a.empresa = '001'
   AND a.numcte = d.numcte
   AND a.numcte = aa.numcte     -- Se agrega estados civil y sexo
   AND b.tipo_dir = '1'
   AND b.secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_direcciones h
                                         WHERE tipo_dir = '1'
                                         AND h.numcte = a.numcte
                                         GROUP BY h.numcte)
   AND a.numcte = b.numcte
   AND d.num_credito = e.num_credito
   AND d.num_credito = f.num_credito
   AND d.num_credito = i.num_solicitud
   --IFRS AND d.status_cred = "AA" -- Estatus credito vigente
   AND d.status_cred IN ("AA","E1")
   AND (f.monto_vencido + f.mto_venc_trasp) = 0
   --and d.status_cred <> "AA" -- Estatus credito
   AND i.numcte_ref = "R1"
   --and d.num_credito = '600000006376'
   --INTO temp temp_cartera;
   INTO temp temp_cartera0;

   
    select  a.numcte,a.num_credito,a.num_tarjeta ,a.nombre ,a.sexo, a.estado_civil,tel.telefono telefono1,
	a.ciudad,a.estado,a.nombre_ref,
	a.telefono_ref,a.capital_total ,a.capital_vigente,a.transitorio,a.sdo_vdo_trasp,a.sdo_vdo_trasp_no_exig,a.interes,
	a.iva_interes,a.moratorios ,a.iva_mora,saldo_total,a.pago_minimo_total    
	from temp_cartera0 a
    left join bdinteg:si_telefonos_actual tel on (tel.numcte = a.numcte and  tel.tipo_tel = 1 and tel.cofetel ='V'
									and tel.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
														where numcte = tel.numcte and tipo_tel = 1 and cofetel ='V'))
	into temp temp_cartera1;
	
	 select a.numcte,a.num_credito,a.num_tarjeta ,a.nombre ,a.sexo, a.estado_civil,a.telefono1,tel.telefono telefono2,
	a.ciudad,a.estado,a.nombre_ref,
	a.telefono_ref,a.capital_total ,a.capital_vigente,a.transitorio,a.sdo_vdo_trasp,a.sdo_vdo_trasp_no_exig,a.interes,
	a.iva_interes,a.moratorios ,a.iva_mora,saldo_total,a.pago_minimo_total  
    from temp_cartera1 a
    left join bdinteg:si_telefonos_actual tel on (tel.numcte = a.numcte and  tel.tipo_tel = 2 and tel.cofetel ='V'
									and tel.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
														where numcte = tel.numcte and tipo_tel = 2 and cofetel ='V'))
	into temp temp_cartera2;
	
	select a.numcte,a.num_credito,a.num_tarjeta ,a.nombre ,a.sexo, a.estado_civil,a.telefono1,a.telefono2,tel.telefono telefono3, tel.extension,
	a.ciudad,a.estado,a.nombre_ref,
	a.telefono_ref,a.capital_total ,a.capital_vigente,a.transitorio,a.sdo_vdo_trasp,a.sdo_vdo_trasp_no_exig,a.interes,
	a.iva_interes,a.moratorios ,a.iva_mora,saldo_total,a.pago_minimo_total  
    from temp_cartera2 a
    left join bdinteg:si_telefonos_actual tel on (tel.numcte = a.numcte and tel.tipo_tel = 3 and tel.cofetel ='V'
										and tel.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = tel.numcte and tipo_tel = 3 and cofetel ='V'))
	into temp temp_cartera;
   
   CREATE INDEX ix_cartera ON temp_cartera(num_credito);

   --- Ultimo Movimiento

   SELECT a.num_credito, b.fecha_mov, b.monto
   FROM bdicred:sd_maecred a ,
               bdicred:sd_movhis b,
			   bdicred:sd_maesdos d
   WHERE a.empresa = '001'
   AND a.num_credito = b.num_credito
   AND a.num_credito = d.num_credito
   AND a.status_cred IN ("AA","E1") 
   AND (d.monto_vencido + d.mto_venc_trasp) = 0
   -- IFRS AND a.status_cred = "AA" -- Estatus credito
   --and a.status_cred <> "AA" -- Estatus credito
   AND b.codigo_fun in ("033", "334")
   AND b.codigo_ref = 1
   AND b.secuencia = (SELECT MAX(c.secuencia)
                                        FROM bdicred:sd_movhis c
                                        WHERE c.empresa = '001'
                                        AND a.num_credito = c.num_credito
                                        AND c.codigo_fun IN ("033", "334")
                                        --and c.codigo_fun = "002" DISPOSICIONES Y DESEMBOLSOS
                                        AND c.codigo_ref= 1
                                        --AND c.codigo_ref IN (30,37,38,39,50) FUNCIONES DE CARGO (COMPRA EN COMERCIO 37)
                                       GROUP BY a.num_credito)
   INTO temp temp_ultimo_pago;
   CREATE INDEX ix_ultimo_pago ON temp_ultimo_pago(num_credito);

   -- Cantidad de Vencidos

   SELECT a.num_credito, COUNT(*) pagos_venc
   FROM bdicred:sd_maecred a,
               bdicred:sd_amortiza_credito b,
			    bdicred:sd_maesdos d
   WHERE a.empresa = '001'
   AND a.num_credito = b.num_credito
   AND a.num_credito = d.num_credito
   AND  a.status_cred IN ("AA","E1")
   AND (d.monto_vencido + d.mto_venc_trasp) = 0
   --IFRS AND a.status_cred = "AA" -- Estatus credito
   --and a.status_cred <> "AA" -- Estatus credito
   AND b.capital_status NOT IN (1,5)
   AND b.fecha_cuota < current::date -- Informix
   --and b.fecha_cuota < "2007-11-20"
   --and a.num_credito = '600000022696'
   GROUP BY a.num_credito
   INTO temp temp_pagos_venc;
   CREATE INDEX ix_pag_ven ON temp_pagos_venc(num_credito);

   -- Telefono trabajo

   SELECT d.num_credito, b.telefono, b.extension
   FROM bdinteg:si_cliente a,
              -- bdinteg:si_direcciones b,
				bdinteg:si_telefonos_actual b,
   --   tmp_telmax c,
              bdicred:sd_maecred d,
              bdicred:sd_tarjeta e,
			  bdicred:sd_maesdos dos
   WHERE  a.empresa = '001'
   AND a.numcte = d.numcte
   AND b.tipo_tel = 3
   AND b.secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_telefonos_actual h
                                         WHERE tipo_tel = 3
                                         AND h.numcte = a.numcte and  b.cofetel ='V'
                                         AND h.telefono <> ''
                                         GROUP BY h.numcte)
   --and b.numcte = c.numcte
   AND a.numcte = b.numcte
   and b.cofetel ='V'
   AND d.num_credito = e.num_credito
   AND dos.num_credito = d.num_credito
   AND d.status_cred IN ("AA","E1")    
   AND (dos.monto_vencido + dos.mto_venc_trasp) = 0
   -- IFRS AND d.status_cred = "AA" -- Estatus credito
   --and d.status_cred <> "AA" -- Estatus credito
   --and d.num_credito = '600000341468'
   AND e.status_tar = 'A'
   AND e.tipo_tarjeta = 'T'
   INTO temp temp_tel_trabajo;
   CREATE INDEX ix_tel_tra ON temp_tel_trabajo(num_credito);

   --- Agrupa y realiza unload de la tabla
   FOREACH
       SELECT a.*,
          (SELECT NVL(b.fecha_mov, 0) fecha_ult_pago
            FROM temp_ultimo_pago b
            WHERE a.num_credito = b.num_credito),
          (SELECT NVL(c.monto, 0) monto_ult_pago
            FROM temp_ultimo_pago c
            WHERE a.num_credito = c.num_credito),
          (SELECT NVL(d.pagos_venc, 0) pagos_vencidos
            FROM temp_pagos_venc d
            WHERE a.num_credito = d.num_credito),
          (SELECT NVL(e.telefono, 0) tel_trabajo_adi
            FROM temp_tel_trabajo e
            WHERE a.num_credito = e.num_credito),
           (SELECT NVL(f.extension, 0) tel_ext_adi
             FROM temp_tel_trabajo f
             WHERE a.num_credito = f.num_credito)
            INTO vnum_cte, vnum_credito, vnum_tarjeta, vnombre, vsexo, vestado_civil, vtelefono1, vtelefono2, vtelefono3, vextension, vciudad,
            vestado, vnombre_ref, vtelefono_ref, vcapital_total, vcapital_vigente, vtransitorio, vsdo_vdo_trasp, vsdo_vdo_trasp_no_exig,
            vinteres, viva_interes, vmoratorios, viva_mora, vsaldo_total, vpago_minimo_total, vfecha_ult_pago, vmonto_ult_pago,
            vpagos_vencidos, vtel_trabajo_adi, vtel_ext_adi
            FROM temp_cartera a, temp_pagos_venc g -- into temp temp_cartera2;
            WHERE g.pagos_venc > 0
            AND a.saldo_total >= 100

            --unload to 'cartera_161207c.txt'
            --select * from temp_cartera2
            --where pagos_vencidos > 0
            --and Saldo_total >= 100;

            INSERT INTO temp_cart VALUES (vnum_cte,vnum_credito,vnum_tarjeta,vnombre,vsexo,vestado_civil,vtelefono1,vtelefono2,vtelefono3,
                                                                           vextension,vciudad,vestado,vnombre_ref,vtelefono_ref,vcapital_total,vcapital_vigente,vtransitorio,vsdo_vdo_trasp,
                                                                           vsdo_vdo_trasp_no_exig,vinteres,viva_interes,vmoratorios,viva_mora,vsaldo_total,vpago_minimo_total,
                                                                           vfecha_ult_pago,vmonto_ult_pago,vpagos_vencidos,vtel_trabajo_adi,vtel_ext_adi);
    END FOREACH;

    LET v_directorio   =  '/tmp/carteravigente' || current year to year || current month to month || current day to day || '.txt';
    LET vSql = '';

    LET  vSql = 'echo "UNLOAD TO '   || (v_directorio) ||
    ' SELECT * FROM bdicred:temp_cart" > /tmp/querycarvigente.sql';

    SYSTEM vSql;
    LET vSql = '';
    LET vSql = "dbaccess bdicred /tmp/querycarvigente.sql ";

    SYSTEM vSql;

    DROP TABLE bdicred:temp_cart;
    DROP TABLE bdicred:temp_cartera;
    DROP TABLE bdicred:temp_ultimo_pago;
    DROP TABLE bdicred:temp_pagos_venc;
    DROP TABLE bdicred:temp_tel_trabajo;

    RETURN vCodret;
END;
---Elaborado por : SaÃºl Ivanhoe / Sistemas Desarrollo Banco
END PROCEDURE;