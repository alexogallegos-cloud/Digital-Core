CREATE PROCEDURE "informix".sp_reportefoliosacl_pba_new(pfolios varchar(250))
							
							RETURNING 
							varchar(20) as Folio_csuac ,
							varchar(4)  as Producto,
							varchar(9)  as numero_cliente,
							varchar(20) as numero_cuenta,
							varchar(16) as numero_tarjeta,
							money(18,2) as importe_original,
							varchar(70) as ref_comercio,
							date 		as fecha_de_cargo,
							varchar(10) as mes_trx,
							varchar(10) as mes_afectacion_abono,
							varchar(4)  as giro_negocio,
							varchar(19) as id_comercio,
							varchar(40) as ciudad_comercio,
							varchar(2)  as metodo_captura,
							varchar(30) as estatus_tarjeta,
							date as Fecha_afectacion_abono,
							varchar(3)  as Evento_naturaleza,
							varchar(10)	as tipo_fraude,
							varchar(104) as nombre_cliente,
							varchar(30) as Ciudad_cliente,
							varchar(4)  as Estado_cliente,
							varchar(4)  as anio_trx,
							varchar(23) as referencia23,
							varchar(20) as Cuenta_contable,
							varchar(10) as Evento_fraude,
							varchar(10) as Solicitud_a_fraudes,
							varchar(10) as Dias_vencidos,
							varchar(10) as Analista,
							varchar(10) as Fecha_respuesta_PF
							

		
		DEFINE iSqlErr				INTEGER;
		DEFINE v_sCodRet			CHAR(5);
		DEFINE vfolio 				varchar(20);
		DEFINE vproducto 			varchar(4);
		DEFINE vcliente				varchar(9);
		DEFINE vnumero_cuenta		varchar(20);
		DEFINE vnumero_tarjeta		varchar(16);
		DEFINE vimporte_original	money(18,2);
		DEFINE vref_comercio		varchar(70);
		DEFINE vfecha_de_cargo		date;
		DEFINE vmes_trx				varchar(10);
		DEFINE vmes_afectacion		varchar(10);
		DEFINE vcodgironeg			varchar(4);
		DEFINE vidretailer			varchar(19);
		DEFINE vciudad_comercio		varchar(40);
		DEFINE vmetodocaptura		varchar(2);
		DEFINE vdescstatustarjeta	varchar(30);
		DEFINE vfecha_afectacion	date ;
		DEFINE vNaturaleza			varchar(3);
		DEFINE vtipo_fraude			varchar(10);
		DEFINE vnombre_cliente		varchar(104);
		DEFINE vnombreciudad		varchar(30);
		DEFINE vinicialestado		varchar(4);
		DEFINE vanio_trx			varchar(4);
		DEFINE vreferencia23		varchar(23);
		DEFINE vcuenta_contable		varchar(20);
		DEFINE vevento_fraude		varchar(10);
		DEFINE vsolicitud_fraude	varchar(10);
		DEFINE vdias_vencidos		varchar(10);
		DEFINE vanalista			varchar(10);
		DEFINE vfecha_respuesta		varchar(10);
		DEFINE vContadorReg			int;
		
		
		
		DEFINE lstCadena varchar(250);
		DEFINE lstDato varchar(20);
		DEFINE lnuPosComa int;
		
		
		--SET DEBUG FILE TO "/tmp/sp_reportefoliosacl.out";
		--TRACE ON;	

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;	
		 
		 BEGIN
			ON EXCEPTION
				SET iSqlErr
				
				IF vContadorReg=1 THEN
					drop table tmp_movimientos_acl;
					drop table tmp_folios_acl;
					drop table tmp_movimientos_inter;
				END IF;
				
				IF iSqlErr <> 0 THEN					
					LET v_sCodRet = iSqlErr;
					RETURN v_sCodRet, 0,'', '', '', '', '','', '', '', '', '','', '', '', '', '','', '', '', '', '','', '', '', '', '','','';
				END IF;
			END EXCEPTION;
			
			LET vContadorReg=0;
			
			LET lstCadena = pfolios;
						
									
			create temp table tmp_folios_acl
			(cFolio varchar(250)
			) with no log;
			
			
		WHILE  (LEN(lstCadena)> 0) LOOP			
				LET lnuPosComa = CHARINDEX(',',lstCadena ); -- Buscamos el caracter separador

				IF (lnuPosComa=0 ) then 
					LET lstDato = lstCadena;
					LET lstCadena = '';		
				ELSE
					LET lstDato = SUBSTR( lstCadena , 1  , lnuPosComa-1);
					LET lstCadena = SUBSTR( lstCadena , lnuPosComa + 1 , LEN(lstCadena));
				END	IF;
				
				--if LEN(lstCadena)> 0 then					
					insert into tmp_folios_acl values (lstDato);					
				--end if;
												
		END LOOP;
						
						
			select folio_csuac,fecha_consumo,fky_padre, fky_aclaracion, fky_solicitud_e_global, folio_suc, fky_tipo_catalogo_transaccion, ref_comercio,fechahora,fecha_afectacion,referencia23 
			from bdiaclaracion:acl_movimiento where folio_csuac in (select cfolio from tmp_folios_acl) and fky_padre is null
			and fecha_consumo is not null and fky_aclaracion is not null
			into temp tmp_movimientos_acl with no log;
			
			create unique index mov_folio_inx on tmp_movimientos_acl(folio_csuac);
			
			select secuenciaextendida,codgironeg, idretailer, infreceptor, metodocaptura, numtarjeta, fechahorainauth from 
			intercard:movimiento a left outer join tmp_movimientos_acl b on	a.secuenciaextendida = SUBSTR(b.folio_suc,2,length(b.folio_suc))
            and a.fechahorainauth=b.fecha_consumo
            where b.folio_suc is not null
					UNION
			select secuenciaextendida,codgironeg, idretailer, infreceptor, metodocaptura, numtarjeta, fechahorainauth from 
			intercard:movimientohistorico a left outer join tmp_movimientos_acl b on	a.secuenciaextendida = SUBSTR(b.folio_suc,2,length(b.folio_suc))
            and a.fechahorainauth=b.fecha_consumo
            where b.folio_suc is not null
			into temp tmp_movimientos_inter with no log;				
			
			create unique index mov_secu_inx on tmp_movimientos_inter(secuenciaextendida);
			
			
			LET vContadorReg = 1;
			

		FOREACH					 
				select '''' || NVL(folio,'') as Folio_csuac, NVL(producto,'') as Producto, cliente as numero_cliente,'''' || numero_cuenta as numero_cuenta,
				'''' || numero_tarjeta as numero_tarjeta, importe_original, ref_comercio, fecha_de_cargo, mes_trx, 
				mes_afectacion as mes_afectacion_abono, NVL(codgironeg,'') as giro_negocio, NVL(idretailer,'') as id_comercio , NVL(ciudad_comercio,'') as ciudad_comercio , 
				NVL(metodocaptura,'') as metodo_captura , NVL(descstatustarjeta,'') as estatus_tarjeta , NVL(fecha_afectacion,'') as Fecha_afectacion_abono, 
				NVL(naturaleza,'') as Evento_naturaleza , NVL(tipo_fraude,'') as tipo_fraude , nombre_cliente, nombreciudad as Ciudad_cliente, 
				inicialestado as Estado_cliente , anio_trx, '''' || referencia23 as referencia23, 
				NVL((
					Case when producto='TDC' and Naturaleza='POS' and tipo_fraude='CLONACION' then '1402 90 01 05 01 00' 
						 when producto='TDC' and Naturaleza='POS' and tipo_fraude='ARQC' then '1402 90 01 05 01 00' 
						 when producto='TDC' and Naturaleza='ATM' and tipo_fraude='CLONACION' then '1402 90 01 05 02 00' 
						 when producto='TDC' and Naturaleza='POS' and tipo_fraude='TNP' then '1402 90 01 05 03 00' 
						 when producto='TDD' and Naturaleza='POS' and tipo_fraude='CLONACION' then '1402 90 01 05 05 00' 
						 when producto='TDD' and Naturaleza='POS' and tipo_fraude='ARQC' then '1402 90 01 05 05 00' 
						 when producto='TDD' and Naturaleza='ATM' and tipo_fraude='CLONACION' then '1402 90 01 05 06 00' 
						 when producto='TDD' and Naturaleza='POS' and tipo_fraude='TNP' then '1402 90 01 05 08 00' end),'') as Cuenta_contable, 
						 ' ' as Evento_fraude, ' ' as Solicitud_a_fraudes, ' ' as Dias_vencidos, ' ' as Analista, ' ' as Fecha_respuesta_PF
								 into vfolio, vproducto, vcliente, vnumero_cuenta, vnumero_tarjeta, vimporte_original, vref_comercio, vfecha_de_cargo, 
								 vmes_trx, vmes_afectacion, vfecha_afectacion, vnaturaleza, vnombre_cliente, vnombreciudad, vinicialestado, vcodgironeg,  vidretailer, 
								 vciudad_comercio, vmetodocaptura, vdescstatustarjeta, vtipo_fraude, vanio_trx, vreferencia23, vcuenta_contable	, vevento_fraude, vsolicitud_fraude,
								 vdias_vencidos, vanalista, vfecha_respuesta
						 from ( 
						 select a.folio_csuac as folio, 
						 (case when left(e.numero_cuenta,1) in (6,7) then 'TDC' when left(e.numero_cuenta,1) in (1,2) then 'TDD' else '' end) as producto,
						 d.numcte as cliente, e.numero_cuenta as numero_cuenta, e.numero_tarjeta as numero_tarjeta, a.importeoriginal as importe_original, 
						 trim(i.ref_comercio) as ref_comercio, date(i.fechahora) as fecha_de_cargo, TO_CHAR(i.fechahora, '%b %y') as mes_trx, 
						 TO_CHAR(i.fecha_afectacion, '%b %y') as mes_afectacion, i.fecha_afectacion, 
						 (case when f.descripcion like '%ATM%' then 'ATM' else 'POS' end) as Naturaleza, 
						 trim(d.nombre1)||' '||trim(d.nombre2)||' '||trim(d.apell_paterno)||' '||trim(d.apell_materno) as nombre_cliente, 
						 v.nombreciudad, v.inicialestado, p.codgironeg, p.idretailer, SUBSTR(p.infreceptor,23,13) as ciudad_comercio, 
						 p.metodocaptura, s.descstatustarjeta, 
						 (case when p.metodocaptura='01' then 'TNP' when p.metodocaptura='90' then 'CLONACION' when p.metodocaptura='05' then 'ARQC' ELSE '' END) as tipo_fraude,
						 year(i.fechahora) as anio_trx, i.referencia23 
						 from  
						 bdiaclaracion:acl_estatus_aclaracion b, bdinteg:si_sucursales c,  
						 bdinteg:si_cliente d, bdinteg:si_direcciones w, bdinteg:si_catciudades v, bdiaclaracion:acl_producto e, 
						 bdiaclaracion:acl_tipo_evento f, bdiaclaracion:acl_estatus_corporativo g, 		 
						 tmp_movimientos_acl i 
						 left outer join bdiaclaracion:acl_tipo_catalogo_transaccion l on i.fky_tipo_catalogo_transaccion=l.pky_tipo_catalogo_transaccion 
						 left outer join tmp_movimientos_inter p on SUBSTR(i.folio_suc,2,length(i.folio_suc))=p.secuenciaextendida 
						 left outer join intercard:tarjeta t on p.numtarjeta=t.numtarjeta 
						 left outer join intercard:statustarjeta s on t.codstatustarjeta = s.codstatustarjeta 
						 left outer join bdiaclaracion:acl_solicitud_e_global m on i.fky_solicitud_e_global = m.pky_solicitud_e_global 
						 LEFT OUTER JOIN bdiaclaracion:acl_respuesta_e_global n ON m.fky_respuesta_e_global = n.pky_respuesta_e_global 
						 LEFT OUTER JOIN bdiaclaracion:acl_tipo_respuesta_e_global o ON n.fky_tipo_respuesta_e_global = o.pky_tipo_respuesta_e_global, bdiaclaracion:acl_aclaracion a 
						 left outer join bdiaclaracion:acl_usuario j on a.fky_usuario_analista = j.pky_usuario  
						 left outer join bdiaclaracion:acl_estatus_corporativo k on a.fky_estatus_corp_analisis = k.pky_estatus_corporativo 
						 where a.fky_estatus_aclaracion=b.pky_estatus_aclaracion   and a.fky_estatus_corp_general = g.pky_estatus_corporativo 
						 and a.num_sucursal=c.sucursal   and a.num_cliente=d.numcte  and e.pky_producto = a. fky_producto 
						 and a.pky_aclaracion = i.fky_aclaracion and a.fky_tipo_evento=f.pky_tipo_evento and d.numcte=w.numcte 
						 and w.ciudad=v.numerociudad and a.folio_csuac is not null and a.fky_estatus_aclaracion =2 						 
						 group by folio, producto, cliente, numero_cuenta, numero_tarjeta, importe_original, ref_comercio, fecha_de_cargo, mes_trx, mes_afectacion, fecha_afectacion, naturaleza, nombre_cliente, nombreciudad, inicialestado, codgironeg, idretailer, ciudad_comercio, metodocaptura, descstatustarjeta, tipo_fraude, anio_trx, referencia23 )
						 reporte 
							
				
				RETURN vfolio, vproducto, vcliente, vnumero_cuenta, vnumero_tarjeta, vimporte_original, vref_comercio, vfecha_de_cargo, vmes_trx, vmes_afectacion, 				vcodgironeg, vidretailer, vciudad_comercio, vmetodocaptura, vdescstatustarjeta, vfecha_afectacion, vnaturaleza, vtipo_fraude, vnombre_cliente, vnombreciudad, vinicialestado,vanio_trx, vreferencia23, vcuenta_contable, '', '', '', '', '' WITH RESUME;
		END FOREACH

		drop table tmp_movimientos_acl;
		drop table tmp_folios_acl;
		drop table tmp_movimientos_inter;


END
END PROCEDURE

--DROP PROCEDURE "informix".sp_reportefoliosacl_pba_new(varchar);
;


grant  execute on function "informix".sp_reporteaclarareciensucursal (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteaclarareciensucursal (date,date) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reporteaclarareciensucursal (date,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reporteaclarareciensucursal (date,date) to "sysaclara" as "informix";
grant  execute on function "informix".sp_reporteaclarareciensucursal (date,date) to "public" as "informix";
grant  execute on function "informix".sp_reporteaclarareciensucursal (date,date) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproducto (integer,date,date,lvarchar,lvarchar) to "sysaclara" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproducto (integer,date,date,lvarchar,lvarchar) to "public" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproducto (integer,date,date,lvarchar,lvarchar) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproducto (integer,date,date,lvarchar,lvarchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproducto (integer,date,date,lvarchar,lvarchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproducto (integer,date,date,lvarchar,lvarchar) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproductografica (integer,date,date,lvarchar,lvarchar) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproductografica (integer,date,date,lvarchar,lvarchar) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproductografica (integer,date,date,lvarchar,lvarchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproductografica (integer,date,date,lvarchar,lvarchar) to "sysaclara" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproductografica (integer,date,date,lvarchar,lvarchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportedictaminadaxproductografica (integer,date,date,lvarchar,lvarchar) to "public" as "informix";
grant  execute on function "informix".sp_reportehoyayer (date,date) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportehoyayer (date,date) to "sysaclara" as "informix";
grant  execute on function "informix".sp_reportehoyayer (date,date) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportehoyayer (date,date) to "public" as "informix";
grant  execute on function "informix".sp_reportehoyayer (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportehoyayer (date,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportehoyayerremanente (date,date) to "public" as "informix";
grant  execute on function "informix".sp_reportehoyayerremanente (date,date) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportehoyayerremanente (date,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportehoyayerremanente (date,date) to "sysaclara" as "informix";
grant  execute on function "informix".sp_reportehoyayerremanente (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportehoyayerremanente (date,date) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportesingredicta (date,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportesingredicta (date,date) to "public" as "informix";
grant  execute on function "informix".sp_reportesingredicta (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportesingredicta (date,date) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportesingredicta (date,date) to "sysaclara" as "informix";
grant  execute on function "informix".sp_reportesingredicta (date,date) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportetopaclarareci (date,date) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportetopaclarareci (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportetopaclarareci (date,date) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportetopaclarareci (date,date) to "public" as "informix";
grant  execute on function "informix".sp_reportetopaclarareci (date,date) to "sysaclara" as "informix";
grant  execute on function "informix".sp_reportetopaclarareci (date,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportetotalaclararecixmesxprod (date,date,lvarchar) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportetotalaclararecixmesxprod (date,date,lvarchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportetotalaclararecixmesxprod (date,date,lvarchar) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportetotalaclararecixmesxprod (date,date,lvarchar) to "public" as "informix";
grant  execute on function "informix".sp_reportetotalaclararecixmesxprod (date,date,lvarchar) to "sysaclara" as "informix";
grant  execute on function "informix".sp_reportetotalaclararecixmesxprod (date,date,lvarchar) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportetopaclaraciones (date,date,integer,char) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportetopaclaraciones (date,date,integer,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportetopaclaraciones (date,date,integer,char) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reportetopaclaraciones (date,date,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_reportetopaclaraciones (date,date,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_detalleeglobal (date,date,char,char) to "public" as "informix";
grant  execute on function "informix".sp_detalleeglobal (date,date,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_detalleeglobal (date,date,char,char) to "ifxprod" as "informix";
grant  execute on function "informix".sp_detalleeglobal (date,date,char,char) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_detalleeglobal (date,date,char,char) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_obten_transaccion_afectacion (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obten_transaccion_afectacion (char) to "public" as "informix";
grant  execute on function "informix".sp_obten_transaccion_afectacion (char) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_obten_transaccion_afectacion (char) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_detalleeglobal_pba (date,date,char,char) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_detalleeglobal_pba (date,date,char,char) to "public" as "informix";
grant  execute on function "informix".sp_detalleeglobal_pba (date,date,char,char) to "all_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_detalleeglobal_pba (date,date,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reinicia_secuencia_folio () to "public" as "informix";
grant  execute on function "informix".sp_reinicia_secuencia_folio () to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_monto_movimiento (char,integer,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_monto_movimiento (char,integer,money) to "public" as "informix";
grant  execute on function "informix".sp_actualiza_tipo_transaccion_movimiento (char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_actualiza_tipo_transaccion_movimiento (char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteaclaraestatusintento_listado (date,date) to "public" as "informix";
grant  execute on function "informix".sp_reporteaclaraestatusintento_listado (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_productos_catalogo (char,char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_productos_catalogo (char,char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_inserta_tipo_movimiento (char,integer,integer,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_inserta_tipo_movimiento (char,integer,integer,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_top20acl () to "ifxprod" as "informix";
grant  execute on function "informix".sp_top20acl () to "public" as "informix";
grant  execute on function "informix".sp_top20acl () to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_recuperacion (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_recuperacion (varchar) to "public" as "informix";
grant  execute on function "informix".sp_actualiza_estatus_acl_eglobal_respondida (varchar) to "public" as "informix";
grant  execute on function "informix".sp_actualiza_estatus_acl_eglobal_respondida (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualiza_folio_error_cierre (integer) to "public" as "informix";
grant  execute on function "informix".sp_actualiza_folio_error_cierre (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_busqueda_sucursal_parapdf (char) to "public" as "informix";
grant  execute on function "informix".sp_busqueda_sucursal_parapdf (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteavisoimpsuc (integer,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteavisoimpsuc (integer,date,date) to "public" as "informix";
grant  execute on function "informix".sp_gerente_promotor_suc (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_gerente_promotor_suc (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_busca_aclaraciones_gerente (char) to "public" as "informix";
grant  execute on function "informix".sp_busca_aclaraciones_gerente (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_aclaraciones_promotor (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_aclaraciones_promotor (char) to "public" as "informix";
grant  execute on function "informix".sp_buscaempleadohuella (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscaempleadohuella (char,char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_datos_sucursal_numero (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_datos_sucursal_numero (char,char) to "public" as "informix";
grant  execute on function "informix".sp_busqueda_nombres_de_sucursales (char) to "public" as "informix";
grant  execute on function "informix".sp_busqueda_nombres_de_sucursales (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_cargo_recurrente (char,char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_cargo_recurrente (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_area_externa (date,date,integer) to "public" as "informix";
grant  execute on function "informix".sp_reporte_area_externa (date,date,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscaempleadohuella_alta (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscaempleadohuella_alta (char,char) to "public" as "informix";
grant  execute on function "informix".sp_acl_consulta_ciudades (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_acl_consulta_ciudades (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_cat_motivo_bloqueo_deb () to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_cat_motivo_bloqueo_deb () to "public" as "informix";
grant  execute on function "informix".sp_consulta_cat_motivo_bloqueo_crd () to "public" as "informix";
grant  execute on function "informix".sp_consulta_cat_motivo_bloqueo_crd () to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_cat_tipo_bloqueo_deb () to "public" as "informix";
grant  execute on function "informix".sp_consulta_cat_tipo_bloqueo_deb () to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_cat_tipo_bloqueo_crd () to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_cat_tipo_bloqueo_crd () to "public" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta (char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta (char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_bloqueocuenta_cred (char,char,integer,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_bloqueocuenta_cred (char,char,integer,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_bloqueo_cta_debito (char,money,char,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bloqueo_cta_debito (char,money,char,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_concentrado_robo_identidad (varchar,varchar,varchar,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_concentrado_robo_identidad (varchar,varchar,varchar,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta_transfer (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta_transfer (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta_inv_crec (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta_inv_crec (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta_pagare (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta_pagare (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta_cred_otros (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta_cred_otros (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_monitor_alerta_aclaraciones () to "public" as "informix";
grant  execute on function "informix".sp_monitor_alerta_aclaraciones () to "c90306542" as "informix";
grant  execute on function "informix".sp_crea_seq_folio_eglobal_atm () to "c90306542" as "informix";
grant  execute on function "informix".sp_crea_seq_folio_eglobal_atm () to "public" as "informix";
grant  execute on function "informix".sp_consulta_secuencia_eglobal_atm () to "public" as "informix";
grant  execute on function "informix".sp_consulta_secuencia_eglobal_atm () to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_beneficiarios_por_cuenta (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_beneficiarios_por_cuenta (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_documentos_faltantes (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_documentos_faltantes (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_pagares_cliente (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_pagares_cliente (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_pagares_cliente_fallecido (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_pagares_cliente_fallecido (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_deb_cheq_cliente (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_deb_cheq_cliente (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_deb_cheq_cliente_1 (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_deb_cheq_cliente_1 (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_deb_cheq_cliente_2 (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_deb_cheq_cliente_2 (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_deb_cheq_cliente_3 (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_deb_cheq_cliente_3 (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_pcuenta_deb_cte_fallecido (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_pcuenta_deb_cte_fallecido (char,char) to "public" as "informix";
grant  execute on function "informix".sp_fal_cancelacion_cuenta_debito (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_fal_cancelacion_cuenta_debito (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_consulta_ciudades (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_consulta_ciudades (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_cuenta_debito (integer,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_cuenta_debito (integer,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_fal_marcajesitesp (char,smallint,char,char) to "public" as "informix";
grant  execute on function "informix".sp_fal_marcajesitesp (char,smallint,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_obten_secuencia_folio () to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_obten_secuencia_folio () to "public" as "informix";
grant  execute on function "informix".sp_fal_rep_pagare_vencimiento (integer,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_rep_pagare_vencimiento (integer,date,date) to "public" as "informix";
grant  execute on function "informix".sp_fal_relacion_cance_creditos_reporte (integer,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_relacion_cance_creditos_reporte (integer,date,date) to "public" as "informix";
grant  execute on function "informix".sp_fal_rep_baja_clientes_fallecidos (date,date) to "public" as "informix";
grant  execute on function "informix".sp_fal_rep_baja_clientes_fallecidos (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_beneficiarios_pagares_por_cuenta (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_beneficiarios_pagares_por_cuenta (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_obtener_beneficiario_por_cuentas (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_obtener_beneficiario_por_cuentas (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_cuenta_pagare_cambio_inst (integer,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_cuenta_pagare_cambio_inst (integer,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_valida_cierre_folio (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_valida_cierre_folio (integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_cancelacion_cuenta_credito (integer,char,char,char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_cancelacion_cuenta_credito (integer,char,char,char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_vencimiento_pagare (integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_vencimiento_pagare (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_cuenta_pagare (integer,char,char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_cuenta_pagare (integer,char,char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_cons_servicios (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_cons_servicios (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_cons_servicios_1 (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_cons_servicios_1 (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_cons_servicios_2 (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_cons_servicios_2 (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_cons_servicios_3 (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_cons_servicios_3 (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_cons_servicios_4 (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_cons_servicios_4 (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_reinicia_secuencia_folio () to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_reinicia_secuencia_folio () to "public" as "informix";
grant  execute on function "informix".sp_fal_asignar_analista_credito (integer,integer,char,char,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_fal_asignar_analista_credito (integer,integer,char,char,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_asignar_analista (integer,integer,char,char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_asignar_analista (integer,integer,char,char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_traspaso_cuentas_inversion (char,char,integer,money,money) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_traspaso_cuentas_inversion (char,char,integer,money,money) to "public" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_cuenta_inversion_corporativo (integer,char,char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_cuenta_inversion_corporativo (integer,char,char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_obten_datos_cliente_solicitud (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_obten_datos_cliente_solicitud (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_debito_corporativo (integer,char,char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_debito_corporativo (integer,char,char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_cuenta_inversion (integer,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_liquidacion_cuenta_inversion (integer,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_fal_actualiza_estatus_cuenta (char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_actualiza_estatus_cuenta (char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_consulta_direccion_cte (char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_direccion_cte (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_nombre_core (char) to "public" as "informix";
grant  execute on function "informix".sp_busca_nombre_core (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_saldos_deb_cre_cliente (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_saldos_deb_cre_cliente (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_creditos_cat (char,char,integer,integer,char,integer,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_creditos_cat (char,char,integer,integer,char,integer,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_cancelacion_cuentas_manual (char,char,char,char,integer,integer,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_cancelacion_cuentas_manual (char,char,char,char,integer,integer,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_buscarclientespornumero (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_buscarclientespornumero (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_buscarclientesportelefonotransfer (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_buscarclientesportelefonotransfer (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_productos_deb_cte_fallecido (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_productos_deb_cte_fallecido (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_productos_deb_cte_fallecido_1 (char) to "public" as "informix";
grant  execute on function "informix".sp_fal_busca_productos_deb_cte_fallecido_1 (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_mueve_aclaraciones_historico_pendiente () to "c90306542" as "informix";
grant  execute on function "informix".sp_mueve_aclaraciones_historico_pendiente () to "public" as "informix";
grant  execute on function "informix".sp_bitacorasistema (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bitacorasistema (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validafuncionalidades (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validafuncionalidades (char) to "public" as "informix";
grant  execute on function "informix".sp_intento_solicitud_aclaracion (integer,char,date) to "public" as "informix";
grant  execute on function "informix".sp_intento_solicitud_aclaracion (integer,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_obten_dias_permitidos (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obten_dias_permitidos (integer) to "public" as "informix";
grant  execute on function "informix".sp_buscarclientespornombreyfecha (char,char,char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscarclientespornombreyfecha (char,char,char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_ins_recuperacion_saldos (integer,varchar,money,money,money,money,money,money,money,money,money,money,money,money,date,datetime,datetime,datetime,datetime,smallint,smallint,smallint,smallint,smallint,smallint,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_ins_recuperacion_saldos (integer,varchar,money,money,money,money,money,money,money,money,money,money,money,money,date,datetime,datetime,datetime,datetime,smallint,smallint,smallint,smallint,smallint,smallint,integer) to "public" as "informix";
grant  execute on function "informix".sp_cargoxajuste_debcred (char,char,char,char,decimal,integer,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_cargoxajuste_debcred (char,char,char,char,decimal,integer,smallint) to "public" as "informix";
grant  execute on function "informix".sp_consulta_aclaraciones_producto_cliente_2 (integer,integer,integer,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_aclaraciones_producto_cliente_2 (integer,integer,integer,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_aplica_cierre_preventivo () to "c90306542" as "informix";
grant  execute on function "informix".sp_aplica_cierre_preventivo () to "public" as "informix";
grant  execute on function "informix".sp_numaclaracion (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_numaclaracion (char) to "public" as "informix";
grant  execute on function "informix".sp_registra_documento_en_bitacora (integer,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_registra_documento_en_bitacora (integer,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_inserta_movimiento (char,money,char,char,integer,integer,integer,integer,char,char,char,money,char,smallint,smallint,smallint,integer,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_inserta_movimiento (char,money,char,char,integer,integer,integer,integer,char,char,char,money,char,smallint,smallint,smallint,integer,varchar) to "public" as "informix";
grant  execute on function "informix".sp_reporte_mensual_acl () to "public" as "informix";
grant  execute on function "informix".sp_reporte_mensual_acl () to "c90306542" as "informix";
grant  execute on function "informix".sp_documentos_faltantes (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_documentos_faltantes (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reverso_estatus_preingreso () to "c90306542" as "informix";
grant  execute on function "informix".sp_reverso_estatus_preingreso () to "public" as "informix";
grant  execute on function "informix".sp_recuperacion_saldos () to "c90306542" as "informix";
grant  execute on function "informix".sp_recuperacion_saldos () to "public" as "informix";
grant  execute on function "informix".sp_cierres_masivos () to "public" as "informix";
grant  execute on function "informix".sp_cierres_masivos () to "c90306542" as "informix";
grant  execute on function "informix".sp_registra_notificacion (char,char,char,char,integer,integer,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_registra_notificacion (char,char,char,char,integer,integer,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_crea_folio_aclaracion (char) to "public" as "informix";
grant  execute on function "informix".sp_crea_folio_aclaracion (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obten_cat_tipo_flujo () to "public" as "informix";
grant  execute on function "informix".sp_obten_cat_tipo_flujo () to "c90306542" as "informix";
grant  execute on function "informix".sp_registra_comentario_cliente (integer,lvarchar) to "public" as "informix";
grant  execute on function "informix".sp_registra_comentario_cliente (integer,lvarchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_relaciona_folioacl_idacl (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_relaciona_folioacl_idacl (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_buscarorigen_por_flujo (integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscarorigen_por_flujo (integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_busca_acls_por_folioaclaracion (varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_acls_por_folioaclaracion (varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_obtiene_periodo_vigencia_preingreso (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obtiene_periodo_vigencia_preingreso (integer) to "public" as "informix";
grant  execute on function "informix".sp_obten_estatus_canales (integer,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_obten_estatus_canales (integer,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscarevento_por_flujo (integer,integer,integer,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscarevento_por_flujo (integer,integer,integer,smallint) to "public" as "informix";
grant  execute on function "informix".sp_obten_origen_automatico (char,char,integer,char,char,date,char) to "public" as "informix";
grant  execute on function "informix".sp_obten_origen_automatico (char,char,integer,char,char,date,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_credito_his_canales (char,date,date,integer,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_credito_his_canales (char,date,date,integer,money,char) to "public" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_credito_dia_canales (char,date,date,integer,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_credito_dia_canales (char,date,date,integer,money,char) to "public" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_cheques_dia_canales (char,date,date,integer,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_cheques_dia_canales (char,date,date,integer,money,char) to "public" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_cheques_his_canales (char,date,date,integer,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_cheques_his_canales (char,date,date,integer,money,char) to "public" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_cheques_his_old_canales (char,date,date,integer,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_cheques_his_old_canales (char,date,date,integer,money,char) to "public" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_creditocrd_his_canales (char,date,date,integer,money,char) to "public" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_creditocrd_his_canales (char,date,date,integer,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_inversion_dia_canales (char,date,date,integer,money,char) to "public" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_inversion_dia_canales (char,date,date,integer,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_inversion_his_canales (char,date,date,integer,money,char) to "public" as "informix";
grant  execute on function "informix".sp_buscar_movimientos_inversion_his_canales (char,date,date,integer,money,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cuestionario_telefonico2 (char) to "public" as "informix";
grant  execute on function "informix".sp_cuestionario_telefonico2 (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_actualizacion_r27 () to "public" as "informix";
grant  execute on function "informix".sp_actualizacion_r27 () to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_datos_3410pbahtm (char) to "public" as "informix";
grant  execute on function "informix".sp_busca_datos_3410pbahtm (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_datos_3410_mx (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_datos_3410_mx (char) to "public" as "informix";
grant  execute on function "informix".sp_mueve_aclaraciones_historico () to "public" as "informix";
grant  execute on function "informix".sp_mueve_aclaraciones_historico () to "c90306542" as "informix";
grant  execute on function "informix".sp_obten_estatus_canales_sms (integer,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obten_estatus_canales_sms (integer,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_consulta_aclaracion_sms (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_aclaracion_sms (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_buscarorigen (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscarorigen (integer) to "public" as "informix";
grant  execute on function "informix".sp_cat_statustarjeta () to "c90306542" as "informix";
grant  execute on function "informix".sp_cat_statustarjeta () to "public" as "informix";
grant  execute on function "informix".sp_busca_producto_deb_cheq_cliente (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_busca_producto_deb_cheq_cliente (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_deb_cheq_cuenta (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_deb_cheq_cuenta (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_busca_producto_transfer_cliente (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_busca_producto_transfer_cliente (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_transfer_cuenta (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_transfer_cuenta (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_busca_producto_transfer_tarjeta (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_busca_producto_transfer_tarjeta (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_transfer_telefono (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_transfer_telefono (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_busca_producto_deb_cheq_tarjeta (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_deb_cheq_tarjeta (char) to "public" as "informix";
grant  execute on function "informix".sp_cuestionario_telefonico (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cuestionario_telefonico (char) to "public" as "informix";
grant  execute on function "informix".sp_upd_debrecuperacion (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_upd_debrecuperacion (char) to "public" as "informix";
grant  execute on function "informix".sp_bloqueodesbloqueo_cuentas_por_recuperacion_creddeb (char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_bloqueodesbloqueo_cuentas_por_recuperacion_creddeb (char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_aplicar_cancelacion_por_recuperacion_creddeb (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_aplicar_cancelacion_por_recuperacion_creddeb (char,char) to "public" as "informix";
grant  execute on function "informix".sp_busca_datos_3410 (char) to "sysrpa4" as "informix";
grant  execute on function "informix".sp_busca_datos_3410 (char) to "sysrpa" as "informix";
grant  execute on function "informix".sp_busca_datos_3410 (char) to "sysrpa3" as "informix";
grant  execute on function "informix".sp_busca_datos_3410 (char) to "sysrpa2" as "informix";
grant  execute on function "informix".sp_busca_datos_3410 (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_datos_3410 (char) to "public" as "informix";
grant  execute on function "informix".sp_busca_datos_3410 (char) to "sysrpa1" as "informix";
grant  execute on function "informix".sp_consulta_saldo_cuentas (char,char) to "public" as "informix";
grant  execute on function "informix".sp_consulta_saldo_cuentas (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_aplica_cierre_masivo (char,char,integer,char,char,varchar,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_aplica_cierre_masivo (char,char,integer,char,char,varchar,integer) to "public" as "informix";
grant  execute on function "informix".sp_busca_aclaraciones_canales (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_aclaraciones_canales (char) to "public" as "informix";
grant  execute on function "informix".sp_documentos_faltantes_canales (integer,char) to "public" as "informix";
grant  execute on function "informix".sp_documentos_faltantes_canales (integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_dg_docsrequeridos_acl (char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_dg_docsrequeridos_acl (char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_busca_acl_por_folio_canales (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_acl_por_folio_canales (char,char) to "public" as "informix";
grant  execute on function "informix".sp_reporte_acl_aud () to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_acl_aud () to "public" as "informix";
grant  execute on function "informix".sp_controlador_r27 () to "c90306542" as "informix";
grant  execute on function "informix".sp_controlador_r27 () to "public" as "informix";
grant  execute on function "informix".sp_acl_obtenerlogpreguntas (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_acl_obtenerlogpreguntas (char,char) to "public" as "informix";
grant  execute on function "informix".sp_acl_obtenernombreestados () to "c90306542" as "informix";
grant  execute on function "informix".sp_acl_obtenernombreestados () to "public" as "informix";
grant  execute on function "informix".sp_acl_actualizaempaclaracion (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_acl_actualizaempaclaracion (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_acl_obtenerpreguntasiniciosesion (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_acl_obtenerpreguntasiniciosesion (char,char) to "public" as "informix";
grant  execute on function "informix".sp_obten_datos_adicionales_movimiento (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_obten_datos_adicionales_movimiento (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_acl_validarnumerorespuestas (char) to "public" as "informix";
grant  execute on function "informix".sp_acl_validarnumerorespuestas (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_acl_validarpreguntasautenticacion (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_acl_validarpreguntasautenticacion (char) to "public" as "informix";
grant  execute on function "informix".sp_acl_insertalog (char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_acl_insertalog (char,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_busca_producto_cred_cliente_crd (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_cred_cuenta_crd (char,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_cred_tarjeta_crd (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_prod_cred (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_cred_cliente (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_prod_cred_1 (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_busca_producto_cred_cliente_1 (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_aclaraciones_producto_cliente (integer,integer,integer,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_inserta_comentario (char,lvarchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscarevento (integer,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscarevento (integer,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_busca_cte_domiciliacion (char,char,char,char,char,char,char,char,char,char,char,integer,char,char,char,date,date,money,lvarchar,char,integer,char,char,integer,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_registra_cte_domiciliacion (char,char,char,char,char,char,integer,integer,char,char,integer,integer,char,char,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_cred_cliente (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_cred_tarjeta (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscarclientesportarjeta (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta_cred (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_consulta_estatus_cuenta_cred (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_validapassword (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validapassword (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_obten_datos_analisis (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_obten_datos_analisis (char) to "public" as "informix";
grant  execute on function "informix".sp_busca_datos_3410_fda (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_datos_3410_fda (char) to "SysRPA5" as "informix";
grant  execute on function "informix".sp_busca_datos_3410_fda (char) to "public" as "informix";
grant  execute on function "informix".sp_busca_datos_3410_fda (char) to "sysrpa5" as "informix";
grant  execute on function "informix".sp_busquedamovstrans (integer,integer,date,date,char,char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_busquedamovstrans (integer,integer,date,date,char,char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "sysrpa5" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "sys_rpa_2" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "sysrpa2" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "sysrpa3" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "sys_rpa_1" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "sysrpa4" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "sysrpa1" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "csys_rpa" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "sys_rpa_3" as "informix";
grant  execute on function "informix".sp_consulta_tipo_movimiento (char,char,integer) to "sysrpa" as "informix";
grant  execute on function "informix".sp_obten_secuencia_folio () to "public" as "informix";
grant  execute on function "informix".sp_obten_secuencia_folio () to "c90306542" as "informix";
grant  execute on function "informix".sp_cierres_masivos_afectacion () to "public" as "informix";
grant  execute on function "informix".sp_cierres_masivos_afectacion () to "c90306542" as "informix";
grant  execute on function "informix".sp_validafuncionalidades2 (char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_fal_obtener_saldo_debito (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_fal_obtener_saldo_debito (char,char) to "public" as "informix";
grant  execute on function "informix".sp_informacion_cuenta (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_informacion_cuenta (char) to "public" as "informix";
grant  execute on function "informix".sp_desbloqueo_cuentas_aclaraciones_sin_saldo (char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_desbloqueo_cuentas_aclaraciones_sin_saldo (char,integer) to "public" as "informix";
grant  execute on function "informix".sp_reporte_diario_cat () to "public" as "informix";
grant  execute on function "informix".sp_reporte_diario_cat () to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_busca_producto (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_acl_validarpreguntasiniciosesion (char) to "public" as "informix";
grant  execute on function "informix".sp_acl_validarpreguntasiniciosesion (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_aplica_validacion_msi (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_busca_producto_cred_cuenta (char,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_evidencias_3410 () to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_evidencias_3410 () to "public" as "informix";
grant  execute on function "informix".sp_reporte_regulatorio_r27 (date,date) to "select_role_bdiaclaracion" as "informix";
grant  execute on function "informix".sp_reporte_regulatorio_r27 (date,date) to "public" as "informix";
grant  execute on function "informix".sp_reporte_regulatorio_r27 (date,date) to "ifxprod" as "informix";
grant  execute on function "informix".sp_reporte_regulatorio_r27 (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteaclaranoprocedentesinsaldo (char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_reporteaclaranoprocedentesinsaldo (char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteaclaracomisionnoprocedentenoaplicada (date,date,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporteaclaracomisionnoprocedentenoaplicada (date,date,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_bloqueo_recuperacion (varchar,char) to "public" as "informix";
grant  execute on function "informix".sp_bloqueo_recuperacion (varchar,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_buscaqueda_folio_csuac (integer,char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_buscaqueda_folio_csuac (integer,char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_aclaracion_filtros_preingreso (char,char,char,char,char,char,char,integer,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_consulta_aclaracion_filtros_preingreso (char,char,char,char,char,char,char,integer,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_detalle_aclaracion_canales (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_detalle_aclaracion_canales (integer) to "public" as "informix";
grant  execute on function "informix".sp_integracion_cta (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_integracion_cta (date,date) to "public" as "informix";
grant  execute on function "informix".sp_integracion_cuenta (date,date) to "public" as "informix";
grant  execute on function "informix".sp_integracion_cuenta (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_acl_regulatorio27 (date,date) to "public" as "informix";
grant  execute on function "informix".sp_acl_regulatorio27 (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_verifica_aclaracion (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportediarioacl () to "c90306542" as "informix";
grant  execute on function "informix".sp_reportediarioacl () to "ifxprod" as "informix";
grant  execute on function "informix".sp_reportefoliosacl_pbabis (varchar) to "public" as "informix";
grant  execute on function "informix".sp_reportefoliosacl_pbabis (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_upd_credrecuperacion (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_upd_credrecuperacion (char) to "public" as "informix";
grant  execute on function "informix".sp_reportefoliosacl_pba (varchar) to "public" as "informix";
grant  execute on function "informix".sp_reportefoliosacl_pba (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportefoliosacl_pba1 (varchar) to "public" as "informix";
grant  execute on function "informix".sp_reportefoliosacl_pba1 (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportefoliosacl (varchar) to "public" as "informix";
grant  execute on function "informix".sp_reportefoliosacl (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_reporte_alta_folio_transfer (date,date) to "public" as "informix";
grant  execute on function "informix".sp_reporte_alta_folio_transfer (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_acl_regulatorio27_mx (date,date) to "public" as "informix";
grant  execute on function "informix".sp_acl_regulatorio27_mx (date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportecontrolderecuperacionespendientes (char,char,integer,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportecontrolderecuperacionespendientes (char,char,integer,integer) to "public" as "informix";
grant  execute on function "informix".sp_reportefoliosacl_pba_new (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportefoliosacl_pba_new (varchar) to "public" as "informix";
revoke  execute on function "informix".sp_busca_producto_cred_cliente_crd (char,integer) from public as "informix";
revoke  execute on function "informix".sp_busca_producto_cred_cuenta_crd (char,integer,char) from public as "informix";
revoke  execute on function "informix".sp_busca_producto_cred_tarjeta_crd (char,char) from public as "informix";
revoke  execute on function "informix".sp_fal_busca_prod_cred (char) from public as "informix";
revoke  execute on function "informix".sp_fal_busca_producto_cred_cliente (char,integer) from public as "informix";
revoke  execute on function "informix".sp_fal_busca_prod_cred_1 (char) from public as "informix";
revoke  execute on function "informix".sp_fal_busca_producto_cred_cliente_1 (char,integer) from public as "informix";
revoke  execute on function "informix".sp_consulta_aclaraciones_producto_cliente (integer,integer,integer,integer,integer) from public as "informix";
revoke  execute on function "informix".sp_inserta_comentario (char,lvarchar,char) from public as "informix";
revoke  execute on function "informix".sp_busca_cte_domiciliacion (char,char,char,char,char,char,char,char,char,char,char,integer,char,char,char,date,date,money,lvarchar,char,integer,char,char,integer,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_registra_cte_domiciliacion (char,char,char,char,char,char,integer,integer,char,char,integer,integer,char,char,char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_busca_producto_cred_cliente (char,integer) from public as "informix";
revoke  execute on function "informix".sp_busca_producto_cred_tarjeta (char,char) from public as "informix";
revoke  execute on function "informix".sp_buscarclientesportarjeta (char) from public as "informix";
revoke  execute on function "informix".sp_consulta_hash () from public as "informix";
revoke  execute on function "informix".sp_bitacora_siem (char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_change_password (char,char,char) from public as "informix";
revoke  execute on function "informix".sp_acl_busca_datos_3410_fda (char) from public as "informix";
revoke  execute on function "informix".sp_acl_consultadevolucion (char) from public as "informix";
revoke  execute on function "informix".sp_acl_consultafectacion (char) from public as "informix";
revoke  execute on function "informix".sp_acl_valida_dfa_devo (char,char,char,money) from public as "informix";
revoke  execute on function "informix".sp_acl_reporte_log () from public as "informix";
revoke  execute on function "informix".sp_acl_consultatipoeventosabono (integer) from public as "informix";
revoke  execute on function "informix".sp_acl_asosacionorigentransaccion (integer) from public as "informix";
revoke  execute on function "informix".sp_acl_consulta_ciudad_estado_formobjeccion (char) from public as "informix";
revoke  execute on function "informix".sp_acl_consulta_perfil_usuario (char) from public as "informix";
revoke  execute on function "informix".sp_registra_notificacion2 (char,char,char,char,integer,integer,char,integer) from public as "informix";
revoke  execute on function "informix".sp_reporte_atm_acl_extra () from public as "informix";
revoke  execute on function "informix".sp_reportediarioacl_2day () from public as "informix";
revoke  execute on function "informix".sp_reportediarioacl_paralelo_2day (smallint,smallint) from public as "informix";
revoke  execute on function "informix".sp_acl_busca_cliente_sv (char) from public as "informix";
revoke  execute on function "informix".sp_acl_montototal_sv (char) from public as "informix";
revoke  execute on function "informix".sp_acl_transacc_movs_origen (integer) from public as "informix";
revoke  execute on function "informix".sp_aplica_credito_smartvista (char,char,char,char,char,char) from public as "informix";
revoke  execute on function "informix".sp_aplica_validacion_msi (char,char) from public as "informix";
revoke  execute on function "informix".sp_busca_producto_cred_cuenta (char,integer,char) from public as "informix";
revoke  execute on function "informix".sp_consulta_prod_sv (char) from public as "informix";
revoke  execute on function "informix".sp_sv_aprovisionamiento_aclaraciones () from public as "informix";
revoke  execute on function "informix".sp_acl_es_cliente_sv (char,char,char) from public as "informix";
revoke  execute on function "informix".sp_acl_validacion_abonoinmediato (char) from public as "informix";
revoke  execute on function "informix".sp_aplica_cierre_masivo (char,char,integer,char,char,varchar,integer,char) from public as "informix";
revoke  execute on function "informix".sp_eliminacion_puntos_coppel () from public as "informix";
revoke  execute on function "informix".sp_evidencias_3410 (char) from public as "informix";
revoke  execute on function "informix".sp_verifica_aclaracion (char) from public as "informix";
revoke  execute on function "informix".sp_reportediarioacl () from public as "informix";
revoke  execute on function "informix".sp_reportediarioacl_paralelo (smallint,smallint) from public as "informix";

revoke usage on language SPL from public ;

grant usage on language SPL to public ;

grant usage on language SPL to ifxcons ;

grant usage on language SPL to ifxdesaa ;

grant usage on language SPL to ifxprod ;

grant usage on language SPL to ifxconsacc ;

grant usage on language SPL to ifxsopsuc ;


grant select on "informix".secuencia_folio_csuac to "ifxcons" as "informix";
grant select on "informix".secuencia_folio_csuac to "ifxconsacc" as "informix";
grant select on "informix".secuencia_folio_csuac to "ifxdesaa" as "informix";
grant alter on "informix".secuencia_folio_csuac to "ifxdesaa" as "informix";
grant select on "informix".secuencia_folio_csuac to "ifxprod" as "informix";
grant alter on "informix".secuencia_folio_csuac to "ifxprod" as "informix";
grant select on "informix".secuencia_folio_csuac to "public" as "informix";
grant select on "informix".secuencia_folio_csuac to "sysctrlinfo" as "informix";
grant select on "informix".tipo_accion_seq to "ifxcons" as "informix";
grant select on "informix".tipo_accion_seq to "ifxconsacc" as "informix";
grant select on "informix".tipo_accion_seq to "ifxdesaa" as "informix";
grant alter on "informix".tipo_accion_seq to "ifxdesaa" as "informix";
grant select on "informix".tipo_accion_seq to "ifxprod" as "informix";
grant alter on "informix".tipo_accion_seq to "ifxprod" as "informix";
grant select on "informix".tipo_accion_seq to "public" as "informix";
grant select on "informix".tipo_accion_seq to "sysctrlinfo" as "informix";
grant select on "informix".resolucion_seq to "ifxcons" as "informix";
grant select on "informix".resolucion_seq to "ifxconsacc" as "informix";
grant select on "informix".resolucion_seq to "ifxdesaa" as "informix";
grant alter on "informix".resolucion_seq to "ifxdesaa" as "informix";
grant select on "informix".resolucion_seq to "ifxprod" as "informix";
grant alter on "informix".resolucion_seq to "ifxprod" as "informix";
grant select on "informix".resolucion_seq to "public" as "informix";
grant select on "informix".resolucion_seq to "sysctrlinfo" as "informix";
grant select on "informix".tipo_estatus_corp_seq to "ifxcons" as "informix";
grant select on "informix".tipo_estatus_corp_seq to "ifxconsacc" as "informix";
grant select on "informix".tipo_estatus_corp_seq to "ifxdesaa" as "informix";
grant alter on "informix".tipo_estatus_corp_seq to "ifxdesaa" as "informix";
grant select on "informix".tipo_estatus_corp_seq to "ifxprod" as "informix";
grant alter on "informix".tipo_estatus_corp_seq to "ifxprod" as "informix";
grant select on "informix".tipo_estatus_corp_seq to "public" as "informix";
grant select on "informix".tipo_estatus_corp_seq to "sysctrlinfo" as "informix";
grant select on "informix".estatus_corporativo_seq to "ifxcons" as "informix";
grant select on "informix".estatus_corporativo_seq to "ifxconsacc" as "informix";
grant select on "informix".estatus_corporativo_seq to "ifxdesaa" as "informix";
grant alter on "informix".estatus_corporativo_seq to "ifxdesaa" as "informix";
grant select on "informix".estatus_corporativo_seq to "ifxprod" as "informix";
grant alter on "informix".estatus_corporativo_seq to "ifxprod" as "informix";
grant select on "informix".estatus_corporativo_seq to "public" as "informix";
grant select on "informix".estatus_corporativo_seq to "sysctrlinfo" as "informix";
grant select on "informix".estatus_aclaracion_seq to "ifxcons" as "informix";
grant select on "informix".estatus_aclaracion_seq to "ifxconsacc" as "informix";
grant select on "informix".estatus_aclaracion_seq to "ifxdesaa" as "informix";
grant alter on "informix".estatus_aclaracion_seq to "ifxdesaa" as "informix";
grant select on "informix".estatus_aclaracion_seq to "ifxprod" as "informix";
grant alter on "informix".estatus_aclaracion_seq to "ifxprod" as "informix";
grant select on "informix".estatus_aclaracion_seq to "public" as "informix";
grant select on "informix".estatus_aclaracion_seq to "sysctrlinfo" as "informix";
grant select on "informix".area_seq to "ifxcons" as "informix";
grant select on "informix".area_seq to "ifxconsacc" as "informix";
grant select on "informix".area_seq to "ifxdesaa" as "informix";
grant alter on "informix".area_seq to "ifxdesaa" as "informix";
grant select on "informix".area_seq to "ifxprod" as "informix";
grant alter on "informix".area_seq to "ifxprod" as "informix";
grant select on "informix".area_seq to "public" as "informix";
grant select on "informix".area_seq to "sysctrlinfo" as "informix";
grant select on "informix".tipo_producto_seq to "ifxcons" as "informix";
grant select on "informix".tipo_producto_seq to "ifxconsacc" as "informix";
grant select on "informix".tipo_producto_seq to "ifxdesaa" as "informix";
grant alter on "informix".tipo_producto_seq to "ifxdesaa" as "informix";
grant select on "informix".tipo_producto_seq to "ifxprod" as "informix";
grant alter on "informix".tipo_producto_seq to "ifxprod" as "informix";
grant select on "informix".tipo_producto_seq to "public" as "informix";
grant select on "informix".tipo_producto_seq to "sysctrlinfo" as "informix";
grant select on "informix".producto_seq to "ifxcons" as "informix";
grant select on "informix".producto_seq to "ifxconsacc" as "informix";
grant select on "informix".producto_seq to "ifxdesaa" as "informix";
grant alter on "informix".producto_seq to "ifxdesaa" as "informix";
grant select on "informix".producto_seq to "ifxprod" as "informix";
grant alter on "informix".producto_seq to "ifxprod" as "informix";
grant select on "informix".producto_seq to "public" as "informix";
grant select on "informix".producto_seq to "sysctrlinfo" as "informix";
grant select on "informix".tipo_transaccion_seq to "ifxcons" as "informix";
grant select on "informix".tipo_transaccion_seq to "ifxconsacc" as "informix";
grant select on "informix".tipo_transaccion_seq to "ifxdesaa" as "informix";
grant alter on "informix".tipo_transaccion_seq to "ifxdesaa" as "informix";
grant select on "informix".tipo_transaccion_seq to "ifxprod" as "informix";
grant alter on "informix".tipo_transaccion_seq to "ifxprod" as "informix";
grant select on "informix".tipo_transaccion_seq to "public" as "informix";
grant select on "informix".tipo_transaccion_seq to "sysctrlinfo" as "informix";
grant select on "informix".origen_evento_seq to "ifxcons" as "informix";
grant select on "informix".origen_evento_seq to "ifxconsacc" as "informix";
grant select on "informix".origen_evento_seq to "ifxdesaa" as "informix";
grant alter on "informix".origen_evento_seq to "ifxdesaa" as "informix";
grant select on "informix".origen_evento_seq to "ifxprod" as "informix";
grant alter on "informix".origen_evento_seq to "ifxprod" as "informix";
grant select on "informix".origen_evento_seq to "public" as "informix";
grant select on "informix".origen_evento_seq to "sysctrlinfo" as "informix";
grant select on "informix".tipo_evento_seq to "ifxcons" as "informix";
grant select on "informix".tipo_evento_seq to "ifxconsacc" as "informix";
grant select on "informix".tipo_evento_seq to "ifxdesaa" as "informix";
grant alter on "informix".tipo_evento_seq to "ifxdesaa" as "informix";
grant select on "informix".tipo_evento_seq to "ifxprod" as "informix";
grant alter on "informix".tipo_evento_seq to "ifxprod" as "informix";
grant select on "informix".tipo_evento_seq to "public" as "informix";
grant select on "informix".tipo_evento_seq to "sysctrlinfo" as "informix";
grant select on "informix".regla_negocio_seq to "ifxcons" as "informix";
grant select on "informix".regla_negocio_seq to "ifxconsacc" as "informix";
grant select on "informix".regla_negocio_seq to "ifxdesaa" as "informix";
grant alter on "informix".regla_negocio_seq to "ifxdesaa" as "informix";
grant select on "informix".regla_negocio_seq to "ifxprod" as "informix";
grant alter on "informix".regla_negocio_seq to "ifxprod" as "informix";
grant select on "informix".regla_negocio_seq to "public" as "informix";
grant select on "informix".regla_negocio_seq to "sysctrlinfo" as "informix";
grant select on "informix".costo_aclaracion_seq to "ifxcons" as "informix";
grant select on "informix".costo_aclaracion_seq to "ifxconsacc" as "informix";
grant select on "informix".costo_aclaracion_seq to "ifxdesaa" as "informix";
grant alter on "informix".costo_aclaracion_seq to "ifxdesaa" as "informix";
grant select on "informix".costo_aclaracion_seq to "ifxprod" as "informix";
grant alter on "informix".costo_aclaracion_seq to "ifxprod" as "informix";
grant select on "informix".costo_aclaracion_seq to "public" as "informix";
grant select on "informix".costo_aclaracion_seq to "sysctrlinfo" as "informix";
grant select on "informix".usuario_seq to "ifxcons" as "informix";
grant select on "informix".usuario_seq to "ifxconsacc" as "informix";
grant select on "informix".usuario_seq to "ifxdesaa" as "informix";
grant alter on "informix".usuario_seq to "ifxdesaa" as "informix";
grant select on "informix".usuario_seq to "ifxprod" as "informix";
grant alter on "informix".usuario_seq to "ifxprod" as "informix";
grant select on "informix".usuario_seq to "public" as "informix";
grant select on "informix".usuario_seq to "sysctrlinfo" as "informix";
grant select on "informix".aclaracion_seq to "ifxcons" as "informix";
grant select on "informix".aclaracion_seq to "ifxconsacc" as "informix";
grant select on "informix".aclaracion_seq to "ifxdesaa" as "informix";
grant alter on "informix".aclaracion_seq to "ifxdesaa" as "informix";
grant select on "informix".aclaracion_seq to "ifxprod" as "informix";
grant alter on "informix".aclaracion_seq to "ifxprod" as "informix";
grant select on "informix".aclaracion_seq to "public" as "informix";
grant select on "informix".aclaracion_seq to "sysctrlinfo" as "informix";
grant select on "informix".rango_importe_seq to "ifxcons" as "informix";
grant select on "informix".rango_importe_seq to "ifxconsacc" as "informix";
grant select on "informix".rango_importe_seq to "ifxdesaa" as "informix";
grant alter on "informix".rango_importe_seq to "ifxdesaa" as "informix";
grant select on "informix".rango_importe_seq to "ifxprod" as "informix";
grant alter on "informix".rango_importe_seq to "ifxprod" as "informix";
grant select on "informix".rango_importe_seq to "public" as "informix";
grant select on "informix".rango_importe_seq to "sysctrlinfo" as "informix";
grant select on "informix".afectacion_seq to "ifxcons" as "informix";
grant select on "informix".afectacion_seq to "ifxconsacc" as "informix";
grant select on "informix".afectacion_seq to "ifxdesaa" as "informix";
grant alter on "informix".afectacion_seq to "ifxdesaa" as "informix";
grant select on "informix".afectacion_seq to "ifxprod" as "informix";
grant alter on "informix".afectacion_seq to "ifxprod" as "informix";
grant select on "informix".afectacion_seq to "public" as "informix";
grant select on "informix".afectacion_seq to "sysctrlinfo" as "informix";
grant select on "informix".codigo_error_afectacion_seq to "ifxcons" as "informix";
grant select on "informix".codigo_error_afectacion_seq to "ifxconsacc" as "informix";
grant select on "informix".codigo_error_afectacion_seq to "ifxdesaa" as "informix";
grant alter on "informix".codigo_error_afectacion_seq to "ifxdesaa" as "informix";
grant select on "informix".codigo_error_afectacion_seq to "ifxprod" as "informix";
grant alter on "informix".codigo_error_afectacion_seq to "ifxprod" as "informix";
grant select on "informix".codigo_error_afectacion_seq to "public" as "informix";
grant select on "informix".codigo_error_afectacion_seq to "sysctrlinfo" as "informix";
grant select on "informix".tipo_doc_matriz_seq to "ifxcons" as "informix";
grant select on "informix".tipo_doc_matriz_seq to "ifxconsacc" as "informix";
grant select on "informix".tipo_doc_matriz_seq to "ifxdesaa" as "informix";
grant alter on "informix".tipo_doc_matriz_seq to "ifxdesaa" as "informix";
grant select on "informix".tipo_doc_matriz_seq to "ifxprod" as "informix";
grant alter on "informix".tipo_doc_matriz_seq to "ifxprod" as "informix";
grant select on "informix".tipo_doc_matriz_seq to "public" as "informix";
grant select on "informix".tipo_doc_matriz_seq to "sysctrlinfo" as "informix";
grant select on "informix".documento_seq to "ifxcons" as "informix";
grant select on "informix".documento_seq to "ifxconsacc" as "informix";
grant select on "informix".documento_seq to "ifxdesaa" as "informix";
grant alter on "informix".documento_seq to "ifxdesaa" as "informix";
grant select on "informix".documento_seq to "ifxprod" as "informix";
grant alter on "informix".documento_seq to "ifxprod" as "informix";
grant select on "informix".documento_seq to "public" as "informix";
grant select on "informix".documento_seq to "sysctrlinfo" as "informix";
grant select on "informix".entrada_bitacora_seq to "ifxcons" as "informix";
grant select on "informix".entrada_bitacora_seq to "ifxconsacc" as "informix";
grant select on "informix".entrada_bitacora_seq to "ifxdesaa" as "informix";
grant alter on "informix".entrada_bitacora_seq to "ifxdesaa" as "informix";
grant select on "informix".entrada_bitacora_seq to "ifxprod" as "informix";
grant alter on "informix".entrada_bitacora_seq to "ifxprod" as "informix";
grant select on "informix".entrada_bitacora_seq to "public" as "informix";
grant select on "informix".entrada_bitacora_seq to "sysctrlinfo" as "informix";
grant select on "informix".especialidad_seq to "ifxcons" as "informix";
grant select on "informix".especialidad_seq to "ifxconsacc" as "informix";
grant select on "informix".especialidad_seq to "ifxdesaa" as "informix";
grant alter on "informix".especialidad_seq to "ifxdesaa" as "informix";
grant select on "informix".especialidad_seq to "ifxprod" as "informix";
grant alter on "informix".especialidad_seq to "ifxprod" as "informix";
grant select on "informix".especialidad_seq to "public" as "informix";
grant select on "informix".especialidad_seq to "sysctrlinfo" as "informix";
grant select on "informix".tipo_respuesta_e_global_seq to "ifxcons" as "informix";
grant select on "informix".tipo_respuesta_e_global_seq to "ifxconsacc" as "informix";
grant select on "informix".tipo_respuesta_e_global_seq to "ifxdesaa" as "informix";
grant alter on "informix".tipo_respuesta_e_global_seq to "ifxdesaa" as "informix";
grant select on "informix".tipo_respuesta_e_global_seq to "ifxprod" as "informix";
grant alter on "informix".tipo_respuesta_e_global_seq to "ifxprod" as "informix";
grant select on "informix".tipo_respuesta_e_global_seq to "public" as "informix";
grant select on "informix".tipo_respuesta_e_global_seq to "sysctrlinfo" as "informix";
grant select on "informix".respuesta_e_global_seq to "ifxcons" as "informix";
grant select on "informix".respuesta_e_global_seq to "ifxconsacc" as "informix";
grant select on "informix".respuesta_e_global_seq to "ifxdesaa" as "informix";
grant alter on "informix".respuesta_e_global_seq to "ifxdesaa" as "informix";
grant select on "informix".respuesta_e_global_seq to "ifxprod" as "informix";
grant alter on "informix".respuesta_e_global_seq to "ifxprod" as "informix";
grant select on "informix".respuesta_e_global_seq to "public" as "informix";
grant select on "informix".respuesta_e_global_seq to "sysctrlinfo" as "informix";
grant select on "informix".solicitud_e_global_seq to "ifxcons" as "informix";
grant select on "informix".solicitud_e_global_seq to "ifxconsacc" as "informix";
grant select on "informix".solicitud_e_global_seq to "ifxdesaa" as "informix";
grant alter on "informix".solicitud_e_global_seq to "ifxdesaa" as "informix";
grant select on "informix".solicitud_e_global_seq to "ifxprod" as "informix";
grant alter on "informix".solicitud_e_global_seq to "ifxprod" as "informix";
grant select on "informix".solicitud_e_global_seq to "public" as "informix";
grant select on "informix".solicitud_e_global_seq to "sysctrlinfo" as "informix";
grant select on "informix".tipo_movimiento_seq to "ifxcons" as "informix";
grant select on "informix".tipo_movimiento_seq to "ifxconsacc" as "informix";
grant select on "informix".tipo_movimiento_seq to "ifxdesaa" as "informix";
grant alter on "informix".tipo_movimiento_seq to "ifxdesaa" as "informix";
grant select on "informix".tipo_movimiento_seq to "ifxprod" as "informix";
grant alter on "informix".tipo_movimiento_seq to "ifxprod" as "informix";
grant select on "informix".tipo_movimiento_seq to "public" as "informix";
grant select on "informix".tipo_movimiento_seq to "sysctrlinfo" as "informix";
grant select on "informix".movimiento_seq to "ifxcons" as "informix";
grant select on "informix".movimiento_seq to "ifxconsacc" as "informix";
grant select on "informix".movimiento_seq to "ifxdesaa" as "informix";
grant alter on "informix".movimiento_seq to "ifxdesaa" as "informix";
grant select on "informix".movimiento_seq to "ifxprod" as "informix";
grant alter on "informix".movimiento_seq to "ifxprod" as "informix";
grant select on "informix".movimiento_seq to "public" as "informix";
grant select on "informix".movimiento_seq to "sysctrlinfo" as "informix";
grant select on "informix".origen_permiso_seq to "ifxcons" as "informix";
grant select on "informix".origen_permiso_seq to "ifxconsacc" as "informix";
grant select on "informix".origen_permiso_seq to "ifxdesaa" as "informix";
grant alter on "informix".origen_permiso_seq to "ifxdesaa" as "informix";
grant select on "informix".origen_permiso_seq to "ifxprod" as "informix";
grant alter on "informix".origen_permiso_seq to "ifxprod" as "informix";
grant select on "informix".origen_permiso_seq to "public" as "informix";
grant select on "informix".origen_permiso_seq to "sysctrlinfo" as "informix";
grant select on "informix".perfil_seq to "ifxcons" as "informix";
grant select on "informix".perfil_seq to "ifxconsacc" as "informix";
grant select on "informix".perfil_seq to "ifxdesaa" as "informix";
grant alter on "informix".perfil_seq to "ifxdesaa" as "informix";
grant select on "informix".perfil_seq to "ifxprod" as "informix";
grant alter on "informix".perfil_seq to "ifxprod" as "informix";
grant select on "informix".perfil_seq to "public" as "informix";
grant select on "informix".perfil_seq to "sysctrlinfo" as "informix";
grant select on "informix".permiso_seq to "ifxcons" as "informix";
grant select on "informix".permiso_seq to "ifxconsacc" as "informix";
grant select on "informix".permiso_seq to "ifxdesaa" as "informix";
grant alter on "informix".permiso_seq to "ifxdesaa" as "informix";
grant select on "informix".permiso_seq to "ifxprod" as "informix";
grant alter on "informix".permiso_seq to "ifxprod" as "informix";
grant select on "informix".permiso_seq to "public" as "informix";
grant select on "informix".permiso_seq to "sysctrlinfo" as "informix";
grant select on "informix".pregunta_seq to "ifxcons" as "informix";
grant select on "informix".pregunta_seq to "ifxconsacc" as "informix";
grant select on "informix".pregunta_seq to "ifxdesaa" as "informix";
grant alter on "informix".pregunta_seq to "ifxdesaa" as "informix";
grant select on "informix".pregunta_seq to "ifxprod" as "informix";
grant alter on "informix".pregunta_seq to "ifxprod" as "informix";
grant select on "informix".pregunta_seq to "public" as "informix";
grant select on "informix".pregunta_seq to "sysctrlinfo" as "informix";
grant select on "informix".rango_resolucion_seq to "ifxcons" as "informix";
grant select on "informix".rango_resolucion_seq to "ifxconsacc" as "informix";
grant select on "informix".rango_resolucion_seq to "ifxdesaa" as "informix";
grant alter on "informix".rango_resolucion_seq to "ifxdesaa" as "informix";
grant select on "informix".rango_resolucion_seq to "ifxprod" as "informix";
grant alter on "informix".rango_resolucion_seq to "ifxprod" as "informix";
grant select on "informix".rango_resolucion_seq to "public" as "informix";
grant select on "informix".rango_resolucion_seq to "sysctrlinfo" as "informix";
grant select on "informix".sesion_usuario_seq to "ifxcons" as "informix";
grant select on "informix".sesion_usuario_seq to "ifxconsacc" as "informix";
grant select on "informix".sesion_usuario_seq to "ifxdesaa" as "informix";
grant alter on "informix".sesion_usuario_seq to "ifxdesaa" as "informix";
grant select on "informix".sesion_usuario_seq to "ifxprod" as "informix";
grant alter on "informix".sesion_usuario_seq to "ifxprod" as "informix";
grant select on "informix".sesion_usuario_seq to "public" as "informix";
grant select on "informix".sesion_usuario_seq to "sysctrlinfo" as "informix";
grant select on "informix".sistema_bitacora_seq to "ifxcons" as "informix";
grant select on "informix".sistema_bitacora_seq to "ifxconsacc" as "informix";
grant select on "informix".sistema_bitacora_seq to "ifxdesaa" as "informix";
grant alter on "informix".sistema_bitacora_seq to "ifxdesaa" as "informix";
grant select on "informix".sistema_bitacora_seq to "ifxprod" as "informix";
grant alter on "informix".sistema_bitacora_seq to "ifxprod" as "informix";
grant select on "informix".sistema_bitacora_seq to "public" as "informix";
grant select on "informix".sistema_bitacora_seq to "sysctrlinfo" as "informix";
grant select on "informix".tipo_documento_seq to "ifxcons" as "informix";
grant select on "informix".tipo_documento_seq to "ifxconsacc" as "informix";
grant select on "informix".tipo_documento_seq to "ifxdesaa" as "informix";
grant alter on "informix".tipo_documento_seq to "ifxdesaa" as "informix";
grant select on "informix".tipo_documento_seq to "ifxprod" as "informix";
grant alter on "informix".tipo_documento_seq to "ifxprod" as "informix";
grant select on "informix".tipo_documento_seq to "public" as "informix";
grant select on "informix".tipo_documento_seq to "sysctrlinfo" as "informix";
grant select on "informix".tipo_codigo_resolucion_seq to "ifxcons" as "informix";
grant select on "informix".tipo_codigo_resolucion_seq to "ifxconsacc" as "informix";
grant select on "informix".tipo_codigo_resolucion_seq to "ifxdesaa" as "informix";
grant alter on "informix".tipo_codigo_resolucion_seq to "ifxdesaa" as "informix";
grant select on "informix".tipo_codigo_resolucion_seq to "ifxprod" as "informix";
grant alter on "informix".tipo_codigo_resolucion_seq to "ifxprod" as "informix";
grant select on "informix".tipo_codigo_resolucion_seq to "public" as "informix";
grant select on "informix".tipo_codigo_resolucion_seq to "sysctrlinfo" as "informix";
grant select on "informix".tipo_catalogo_transaccion_seq to "ifxcons" as "informix";
grant select on "informix".tipo_catalogo_transaccion_seq to "ifxconsacc" as "informix";
grant select on "informix".tipo_catalogo_transaccion_seq to "ifxdesaa" as "informix";
grant alter on "informix".tipo_catalogo_transaccion_seq to "ifxdesaa" as "informix";
grant select on "informix".tipo_catalogo_transaccion_seq to "ifxprod" as "informix";
grant alter on "informix".tipo_catalogo_transaccion_seq to "ifxprod" as "informix";
grant select on "informix".tipo_catalogo_transaccion_seq to "public" as "informix";
grant select on "informix".tipo_catalogo_transaccion_seq to "sysctrlinfo" as "informix";
grant select on "informix".mensaje_seq to "ifxcons" as "informix";
grant select on "informix".mensaje_seq to "ifxconsacc" as "informix";
grant select on "informix".mensaje_seq to "ifxdesaa" as "informix";
grant alter on "informix".mensaje_seq to "ifxdesaa" as "informix";
grant select on "informix".mensaje_seq to "ifxprod" as "informix";
grant alter on "informix".mensaje_seq to "ifxprod" as "informix";
grant select on "informix".mensaje_seq to "public" as "informix";
grant select on "informix".mensaje_seq to "sysctrlinfo" as "informix";
grant select on "informix".codigo_error_seq to "ifxcons" as "informix";
grant select on "informix".codigo_error_seq to "ifxconsacc" as "informix";
grant select on "informix".codigo_error_seq to "ifxdesaa" as "informix";
grant alter on "informix".codigo_error_seq to "ifxdesaa" as "informix";
grant select on "informix".codigo_error_seq to "ifxprod" as "informix";
grant alter on "informix".codigo_error_seq to "ifxprod" as "informix";
grant select on "informix".codigo_error_seq to "public" as "informix";
grant select on "informix".codigo_error_seq to "sysctrlinfo" as "informix";
grant select on "informix".configuracion_monitoreo_seq to "ifxcons" as "informix";
grant select on "informix".configuracion_monitoreo_seq to "ifxconsacc" as "informix";
grant select on "informix".configuracion_monitoreo_seq to "ifxdesaa" as "informix";
grant alter on "informix".configuracion_monitoreo_seq to "ifxdesaa" as "informix";
grant select on "informix".configuracion_monitoreo_seq to "ifxprod" as "informix";
grant alter on "informix".configuracion_monitoreo_seq to "ifxprod" as "informix";
grant select on "informix".configuracion_monitoreo_seq to "public" as "informix";
grant select on "informix".configuracion_monitoreo_seq to "sysctrlinfo" as "informix";
grant select on "informix".correo_seq to "ifxcons" as "informix";
grant select on "informix".correo_seq to "ifxconsacc" as "informix";
grant select on "informix".correo_seq to "ifxdesaa" as "informix";
grant alter on "informix".correo_seq to "ifxdesaa" as "informix";
grant select on "informix".correo_seq to "ifxprod" as "informix";
grant alter on "informix".correo_seq to "ifxprod" as "informix";
grant select on "informix".correo_seq to "public" as "informix";
grant select on "informix".correo_seq to "sysctrlinfo" as "informix";
grant select on "informix".monitoreo_cron_seq to "ifxcons" as "informix";
grant select on "informix".monitoreo_cron_seq to "ifxconsacc" as "informix";
grant select on "informix".monitoreo_cron_seq to "ifxdesaa" as "informix";
grant alter on "informix".monitoreo_cron_seq to "ifxdesaa" as "informix";
grant select on "informix".monitoreo_cron_seq to "ifxprod" as "informix";
grant alter on "informix".monitoreo_cron_seq to "ifxprod" as "informix";
grant select on "informix".monitoreo_cron_seq to "public" as "informix";
grant select on "informix".monitoreo_cron_seq to "sysctrlinfo" as "informix";
grant select on "informix".monitoreo_hibernate_seq to "ifxcons" as "informix";
grant select on "informix".monitoreo_hibernate_seq to "ifxconsacc" as "informix";
grant select on "informix".monitoreo_hibernate_seq to "ifxdesaa" as "informix";
grant alter on "informix".monitoreo_hibernate_seq to "ifxdesaa" as "informix";
grant select on "informix".monitoreo_hibernate_seq to "ifxprod" as "informix";
grant alter on "informix".monitoreo_hibernate_seq to "ifxprod" as "informix";
grant select on "informix".monitoreo_hibernate_seq to "public" as "informix";
grant select on "informix".monitoreo_hibernate_seq to "sysctrlinfo" as "informix";
grant select on "informix".monitoreo_sesion_seq to "ifxcons" as "informix";
grant select on "informix".monitoreo_sesion_seq to "ifxconsacc" as "informix";
grant select on "informix".monitoreo_sesion_seq to "ifxdesaa" as "informix";
grant alter on "informix".monitoreo_sesion_seq to "ifxdesaa" as "informix";
grant select on "informix".monitoreo_sesion_seq to "ifxprod" as "informix";
grant alter on "informix".monitoreo_sesion_seq to "ifxprod" as "informix";
grant select on "informix".monitoreo_sesion_seq to "public" as "informix";
grant select on "informix".monitoreo_sesion_seq to "sysctrlinfo" as "informix";
grant select on "informix".monitoreo_tomcat_seq to "ifxcons" as "informix";
grant select on "informix".monitoreo_tomcat_seq to "ifxconsacc" as "informix";
grant select on "informix".monitoreo_tomcat_seq to "ifxdesaa" as "informix";
grant alter on "informix".monitoreo_tomcat_seq to "ifxdesaa" as "informix";
grant select on "informix".monitoreo_tomcat_seq to "ifxprod" as "informix";
grant alter on "informix".monitoreo_tomcat_seq to "ifxprod" as "informix";
grant select on "informix".monitoreo_tomcat_seq to "public" as "informix";
grant select on "informix".monitoreo_tomcat_seq to "sysctrlinfo" as "informix";
grant select on "informix".notificacion_det_seq to "ifxcons" as "informix";
grant select on "informix".notificacion_det_seq to "ifxconsacc" as "informix";
grant select on "informix".notificacion_det_seq to "ifxdesaa" as "informix";
grant alter on "informix".notificacion_det_seq to "ifxdesaa" as "informix";
grant select on "informix".notificacion_det_seq to "ifxprod" as "informix";
grant alter on "informix".notificacion_det_seq to "ifxprod" as "informix";
grant select on "informix".notificacion_det_seq to "public" as "informix";
grant select on "informix".notificacion_det_seq to "sysctrlinfo" as "informix";
grant select on "informix".transacciones_seq to "ifxcons" as "informix";
grant select on "informix".transacciones_seq to "ifxconsacc" as "informix";
grant select on "informix".transacciones_seq to "ifxdesaa" as "informix";
grant alter on "informix".transacciones_seq to "ifxdesaa" as "informix";
grant select on "informix".transacciones_seq to "ifxprod" as "informix";
grant alter on "informix".transacciones_seq to "ifxprod" as "informix";
grant select on "informix".transacciones_seq to "public" as "informix";
grant select on "informix".transacciones_seq to "sysctrlinfo" as "informix";
grant select on "informix".recuperacion_saldos_seq to "ifxcons" as "informix";
grant select on "informix".recuperacion_saldos_seq to "ifxconsacc" as "informix";
grant select on "informix".recuperacion_saldos_seq to "ifxdesaa" as "informix";
grant alter on "informix".recuperacion_saldos_seq to "ifxdesaa" as "informix";
grant select on "informix".recuperacion_saldos_seq to "ifxprod" as "informix";
grant alter on "informix".recuperacion_saldos_seq to "ifxprod" as "informix";
grant select on "informix".recuperacion_saldos_seq to "public" as "informix";
grant select on "informix".recuperacion_saldos_seq to "sysctrlinfo" as "informix";
grant select on "informix".estatus_ingreso_seq to "ifxcons" as "informix";
grant select on "informix".estatus_ingreso_seq to "ifxconsacc" as "informix";
grant select on "informix".estatus_ingreso_seq to "ifxdesaa" as "informix";
grant alter on "informix".estatus_ingreso_seq to "ifxdesaa" as "informix";
grant select on "informix".estatus_ingreso_seq to "ifxprod" as "informix";
grant alter on "informix".estatus_ingreso_seq to "ifxprod" as "informix";
grant select on "informix".estatus_ingreso_seq to "public" as "informix";
grant select on "informix".estatus_ingreso_seq to "sysctrlinfo" as "informix";
grant select on "informix".control_aclaracion_tel_seq to "ifxcons" as "informix";
grant select on "informix".control_aclaracion_tel_seq to "ifxconsacc" as "informix";
grant select on "informix".control_aclaracion_tel_seq to "ifxdesaa" as "informix";
grant alter on "informix".control_aclaracion_tel_seq to "ifxdesaa" as "informix";
grant select on "informix".control_aclaracion_tel_seq to "ifxprod" as "informix";
grant alter on "informix".control_aclaracion_tel_seq to "ifxprod" as "informix";
grant select on "informix".control_aclaracion_tel_seq to "public" as "informix";
grant select on "informix".control_aclaracion_tel_seq to "sysctrlinfo" as "informix";
grant select on "informix".control_digitalizacion_doc_seq to "ifxcons" as "informix";
grant select on "informix".control_digitalizacion_doc_seq to "ifxconsacc" as "informix";
grant select on "informix".control_digitalizacion_doc_seq to "ifxdesaa" as "informix";
grant alter on "informix".control_digitalizacion_doc_seq to "ifxdesaa" as "informix";
grant select on "informix".control_digitalizacion_doc_seq to "ifxprod" as "informix";
grant alter on "informix".control_digitalizacion_doc_seq to "ifxprod" as "informix";
grant select on "informix".control_digitalizacion_doc_seq to "public" as "informix";
grant select on "informix".control_digitalizacion_doc_seq to "sysctrlinfo" as "informix";
grant select on "informix".concentrado_robo_seq to "ifxcons" as "informix";
grant select on "informix".concentrado_robo_seq to "ifxconsacc" as "informix";
grant select on "informix".concentrado_robo_seq to "ifxdesaa" as "informix";
grant alter on "informix".concentrado_robo_seq to "ifxdesaa" as "informix";
grant select on "informix".concentrado_robo_seq to "ifxprod" as "informix";
grant alter on "informix".concentrado_robo_seq to "ifxprod" as "informix";
grant select on "informix".concentrado_robo_seq to "public" as "informix";
grant select on "informix".concentrado_robo_seq to "sysctrlinfo" as "informix";
grant select on "informix".secuencia_folio_eglobal_atm_seq to "ifxcons" as "informix";
grant select on "informix".secuencia_folio_eglobal_atm_seq to "ifxconsacc" as "informix";
grant select on "informix".secuencia_folio_eglobal_atm_seq to "ifxdesaa" as "informix";
grant alter on "informix".secuencia_folio_eglobal_atm_seq to "ifxdesaa" as "informix";
grant select on "informix".secuencia_folio_eglobal_atm_seq to "ifxprod" as "informix";
grant alter on "informix".secuencia_folio_eglobal_atm_seq to "ifxprod" as "informix";
grant select on "informix".secuencia_folio_eglobal_atm_seq to "public" as "informix";
grant select on "informix".secuencia_folio_eglobal_atm_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_accion_seq to "ifxcons" as "informix";
grant select on "informix".cat_accion_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_accion_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_accion_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_accion_seq to "ifxprod" as "informix";
grant alter on "informix".cat_accion_seq to "ifxprod" as "informix";
grant select on "informix".cat_accion_seq to "public" as "informix";
grant select on "informix".cat_accion_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_tipo_aviso_seq to "ifxcons" as "informix";
grant select on "informix".cat_tipo_aviso_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_tipo_aviso_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_tipo_aviso_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_tipo_aviso_seq to "ifxprod" as "informix";
grant alter on "informix".cat_tipo_aviso_seq to "ifxprod" as "informix";
grant select on "informix".cat_tipo_aviso_seq to "public" as "informix";
grant select on "informix".cat_tipo_aviso_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_tipo_beneficiario_seq to "ifxcons" as "informix";
grant select on "informix".cat_tipo_beneficiario_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_tipo_beneficiario_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_tipo_beneficiario_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_tipo_beneficiario_seq to "ifxprod" as "informix";
grant alter on "informix".cat_tipo_beneficiario_seq to "ifxprod" as "informix";
grant select on "informix".cat_tipo_beneficiario_seq to "public" as "informix";
grant select on "informix".cat_tipo_beneficiario_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_tipo_documento_seq to "ifxcons" as "informix";
grant select on "informix".cat_tipo_documento_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_tipo_documento_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_tipo_documento_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_tipo_documento_seq to "ifxprod" as "informix";
grant alter on "informix".cat_tipo_documento_seq to "ifxprod" as "informix";
grant select on "informix".cat_tipo_documento_seq to "public" as "informix";
grant select on "informix".cat_tipo_documento_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_estatus_corporativo_seq to "ifxcons" as "informix";
grant select on "informix".cat_estatus_corporativo_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_estatus_corporativo_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_estatus_corporativo_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_estatus_corporativo_seq to "ifxprod" as "informix";
grant alter on "informix".cat_estatus_corporativo_seq to "ifxprod" as "informix";
grant select on "informix".cat_estatus_corporativo_seq to "public" as "informix";
grant select on "informix".cat_estatus_corporativo_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_estatus_general_seq to "ifxcons" as "informix";
grant select on "informix".cat_estatus_general_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_estatus_general_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_estatus_general_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_estatus_general_seq to "ifxprod" as "informix";
grant alter on "informix".cat_estatus_general_seq to "ifxprod" as "informix";
grant select on "informix".cat_estatus_general_seq to "public" as "informix";
grant select on "informix".cat_estatus_general_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_estatus_sucursal_seq to "ifxcons" as "informix";
grant select on "informix".cat_estatus_sucursal_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_estatus_sucursal_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_estatus_sucursal_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_estatus_sucursal_seq to "ifxprod" as "informix";
grant alter on "informix".cat_estatus_sucursal_seq to "ifxprod" as "informix";
grant select on "informix".cat_estatus_sucursal_seq to "public" as "informix";
grant select on "informix".cat_estatus_sucursal_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_estatus_cuenta_seq to "ifxcons" as "informix";
grant select on "informix".cat_estatus_cuenta_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_estatus_cuenta_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_estatus_cuenta_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_estatus_cuenta_seq to "ifxprod" as "informix";
grant alter on "informix".cat_estatus_cuenta_seq to "ifxprod" as "informix";
grant select on "informix".cat_estatus_cuenta_seq to "public" as "informix";
grant select on "informix".cat_estatus_cuenta_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_evento_seq to "ifxcons" as "informix";
grant select on "informix".cat_evento_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_evento_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_evento_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_evento_seq to "ifxprod" as "informix";
grant alter on "informix".cat_evento_seq to "ifxprod" as "informix";
grant select on "informix".cat_evento_seq to "public" as "informix";
grant select on "informix".cat_evento_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_identificacion_seq to "ifxcons" as "informix";
grant select on "informix".cat_identificacion_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_identificacion_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_identificacion_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_identificacion_seq to "ifxprod" as "informix";
grant alter on "informix".cat_identificacion_seq to "ifxprod" as "informix";
grant select on "informix".cat_identificacion_seq to "public" as "informix";
grant select on "informix".cat_identificacion_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_lugar_deceso_seq to "ifxcons" as "informix";
grant select on "informix".cat_lugar_deceso_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_lugar_deceso_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_lugar_deceso_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_lugar_deceso_seq to "ifxprod" as "informix";
grant alter on "informix".cat_lugar_deceso_seq to "ifxprod" as "informix";
grant select on "informix".cat_lugar_deceso_seq to "public" as "informix";
grant select on "informix".cat_lugar_deceso_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_parentesco_seq to "ifxcons" as "informix";
grant select on "informix".cat_parentesco_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_parentesco_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_parentesco_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_parentesco_seq to "ifxprod" as "informix";
grant alter on "informix".cat_parentesco_seq to "ifxprod" as "informix";
grant select on "informix".cat_parentesco_seq to "public" as "informix";
grant select on "informix".cat_parentesco_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_grupo_documento_seq to "ifxcons" as "informix";
grant select on "informix".cat_grupo_documento_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_grupo_documento_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_grupo_documento_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_grupo_documento_seq to "ifxprod" as "informix";
grant alter on "informix".cat_grupo_documento_seq to "ifxprod" as "informix";
grant select on "informix".cat_grupo_documento_seq to "public" as "informix";
grant select on "informix".cat_grupo_documento_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_grupo_tipo_beneficiario_seq to "ifxcons" as "informix";
grant select on "informix".cat_grupo_tipo_beneficiario_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_grupo_tipo_beneficiario_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_grupo_tipo_beneficiario_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_grupo_tipo_beneficiario_seq to "ifxprod" as "informix";
grant alter on "informix".cat_grupo_tipo_beneficiario_seq to "ifxprod" as "informix";
grant select on "informix".cat_grupo_tipo_beneficiario_seq to "public" as "informix";
grant select on "informix".cat_grupo_tipo_beneficiario_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_reporte_seq to "ifxcons" as "informix";
grant select on "informix".cat_reporte_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_reporte_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_reporte_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_reporte_seq to "ifxprod" as "informix";
grant alter on "informix".cat_reporte_seq to "ifxprod" as "informix";
grant select on "informix".cat_reporte_seq to "public" as "informix";
grant select on "informix".cat_reporte_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_resolucion_seq to "ifxcons" as "informix";
grant select on "informix".cat_resolucion_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_resolucion_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_resolucion_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_resolucion_seq to "ifxprod" as "informix";
grant alter on "informix".cat_resolucion_seq to "ifxprod" as "informix";
grant select on "informix".cat_resolucion_seq to "public" as "informix";
grant select on "informix".cat_resolucion_seq to "sysctrlinfo" as "informix";
grant select on "informix".solicitud_seq to "ifxcons" as "informix";
grant select on "informix".solicitud_seq to "ifxconsacc" as "informix";
grant select on "informix".solicitud_seq to "ifxdesaa" as "informix";
grant alter on "informix".solicitud_seq to "ifxdesaa" as "informix";
grant select on "informix".solicitud_seq to "ifxprod" as "informix";
grant alter on "informix".solicitud_seq to "ifxprod" as "informix";
grant select on "informix".solicitud_seq to "public" as "informix";
grant select on "informix".solicitud_seq to "sysctrlinfo" as "informix";
grant select on "informix".control_tramite_seq to "ifxcons" as "informix";
grant select on "informix".control_tramite_seq to "ifxconsacc" as "informix";
grant select on "informix".control_tramite_seq to "ifxdesaa" as "informix";
grant alter on "informix".control_tramite_seq to "ifxdesaa" as "informix";
grant select on "informix".control_tramite_seq to "ifxprod" as "informix";
grant alter on "informix".control_tramite_seq to "ifxprod" as "informix";
grant select on "informix".control_tramite_seq to "public" as "informix";
grant select on "informix".control_tramite_seq to "sysctrlinfo" as "informix";
grant select on "informix".fal_documento_seq to "ifxcons" as "informix";
grant select on "informix".fal_documento_seq to "ifxconsacc" as "informix";
grant select on "informix".fal_documento_seq to "ifxdesaa" as "informix";
grant alter on "informix".fal_documento_seq to "ifxdesaa" as "informix";
grant select on "informix".fal_documento_seq to "ifxprod" as "informix";
grant alter on "informix".fal_documento_seq to "ifxprod" as "informix";
grant select on "informix".fal_documento_seq to "public" as "informix";
grant select on "informix".fal_documento_seq to "sysctrlinfo" as "informix";
grant select on "informix".aviso_seq to "ifxcons" as "informix";
grant select on "informix".aviso_seq to "ifxconsacc" as "informix";
grant select on "informix".aviso_seq to "ifxdesaa" as "informix";
grant alter on "informix".aviso_seq to "ifxdesaa" as "informix";
grant select on "informix".aviso_seq to "ifxprod" as "informix";
grant alter on "informix".aviso_seq to "ifxprod" as "informix";
grant select on "informix".aviso_seq to "public" as "informix";
grant select on "informix".aviso_seq to "sysctrlinfo" as "informix";
grant select on "informix".control_digitaliza_doc_seq to "ifxcons" as "informix";
grant select on "informix".control_digitaliza_doc_seq to "ifxconsacc" as "informix";
grant select on "informix".control_digitaliza_doc_seq to "ifxdesaa" as "informix";
grant alter on "informix".control_digitaliza_doc_seq to "ifxdesaa" as "informix";
grant select on "informix".control_digitaliza_doc_seq to "ifxprod" as "informix";
grant alter on "informix".control_digitaliza_doc_seq to "ifxprod" as "informix";
grant select on "informix".control_digitaliza_doc_seq to "public" as "informix";
grant select on "informix".control_digitaliza_doc_seq to "sysctrlinfo" as "informix";
grant select on "informix".beneficiario_seq to "ifxcons" as "informix";
grant select on "informix".beneficiario_seq to "ifxconsacc" as "informix";
grant select on "informix".beneficiario_seq to "ifxdesaa" as "informix";
grant alter on "informix".beneficiario_seq to "ifxdesaa" as "informix";
grant select on "informix".beneficiario_seq to "ifxprod" as "informix";
grant alter on "informix".beneficiario_seq to "ifxprod" as "informix";
grant select on "informix".beneficiario_seq to "public" as "informix";
grant select on "informix".beneficiario_seq to "sysctrlinfo" as "informix";
grant select on "informix".fal_historico_solicitud_seq to "ifxcons" as "informix";
grant select on "informix".fal_historico_solicitud_seq to "ifxconsacc" as "informix";
grant select on "informix".fal_historico_solicitud_seq to "ifxdesaa" as "informix";
grant alter on "informix".fal_historico_solicitud_seq to "ifxdesaa" as "informix";
grant select on "informix".fal_historico_solicitud_seq to "ifxprod" as "informix";
grant alter on "informix".fal_historico_solicitud_seq to "ifxprod" as "informix";
grant select on "informix".fal_historico_solicitud_seq to "public" as "informix";
grant select on "informix".fal_historico_solicitud_seq to "sysctrlinfo" as "informix";
grant select on "informix".fal_notificacion_detalle_seq to "ifxcons" as "informix";
grant select on "informix".fal_notificacion_detalle_seq to "ifxconsacc" as "informix";
grant select on "informix".fal_notificacion_detalle_seq to "ifxdesaa" as "informix";
grant alter on "informix".fal_notificacion_detalle_seq to "ifxdesaa" as "informix";
grant select on "informix".fal_notificacion_detalle_seq to "ifxprod" as "informix";
grant alter on "informix".fal_notificacion_detalle_seq to "ifxprod" as "informix";
grant select on "informix".fal_notificacion_detalle_seq to "public" as "informix";
grant select on "informix".fal_notificacion_detalle_seq to "sysctrlinfo" as "informix";
grant select on "informix".fal_regla_negocio_seq to "ifxcons" as "informix";
grant select on "informix".fal_regla_negocio_seq to "ifxconsacc" as "informix";
grant select on "informix".fal_regla_negocio_seq to "ifxdesaa" as "informix";
grant alter on "informix".fal_regla_negocio_seq to "ifxdesaa" as "informix";
grant select on "informix".fal_regla_negocio_seq to "ifxprod" as "informix";
grant alter on "informix".fal_regla_negocio_seq to "ifxprod" as "informix";
grant select on "informix".fal_regla_negocio_seq to "public" as "informix";
grant select on "informix".fal_regla_negocio_seq to "sysctrlinfo" as "informix";
grant select on "informix".fal_rango_importe_seq to "ifxcons" as "informix";
grant select on "informix".fal_rango_importe_seq to "ifxconsacc" as "informix";
grant select on "informix".fal_rango_importe_seq to "ifxdesaa" as "informix";
grant alter on "informix".fal_rango_importe_seq to "ifxdesaa" as "informix";
grant select on "informix".fal_rango_importe_seq to "ifxprod" as "informix";
grant alter on "informix".fal_rango_importe_seq to "ifxprod" as "informix";
grant select on "informix".fal_rango_importe_seq to "public" as "informix";
grant select on "informix".fal_rango_importe_seq to "sysctrlinfo" as "informix";
grant select on "informix".fal_rango_importe_accion_seq to "ifxcons" as "informix";
grant select on "informix".fal_rango_importe_accion_seq to "ifxconsacc" as "informix";
grant select on "informix".fal_rango_importe_accion_seq to "ifxdesaa" as "informix";
grant alter on "informix".fal_rango_importe_accion_seq to "ifxdesaa" as "informix";
grant select on "informix".fal_rango_importe_accion_seq to "ifxprod" as "informix";
grant alter on "informix".fal_rango_importe_accion_seq to "ifxprod" as "informix";
grant select on "informix".fal_rango_importe_accion_seq to "public" as "informix";
grant select on "informix".fal_rango_importe_accion_seq to "sysctrlinfo" as "informix";
grant select on "informix".saldo_anterior_seq to "ifxcons" as "informix";
grant select on "informix".saldo_anterior_seq to "ifxconsacc" as "informix";
grant select on "informix".saldo_anterior_seq to "ifxdesaa" as "informix";
grant alter on "informix".saldo_anterior_seq to "ifxdesaa" as "informix";
grant select on "informix".saldo_anterior_seq to "ifxprod" as "informix";
grant alter on "informix".saldo_anterior_seq to "ifxprod" as "informix";
grant select on "informix".saldo_anterior_seq to "public" as "informix";
grant select on "informix".saldo_anterior_seq to "sysctrlinfo" as "informix";
grant select on "informix".fal_solicitud_area_externa_seq to "ifxcons" as "informix";
grant select on "informix".fal_solicitud_area_externa_seq to "ifxconsacc" as "informix";
grant select on "informix".fal_solicitud_area_externa_seq to "ifxdesaa" as "informix";
grant alter on "informix".fal_solicitud_area_externa_seq to "ifxdesaa" as "informix";
grant select on "informix".fal_solicitud_area_externa_seq to "ifxprod" as "informix";
grant alter on "informix".fal_solicitud_area_externa_seq to "ifxprod" as "informix";
grant select on "informix".fal_solicitud_area_externa_seq to "public" as "informix";
grant select on "informix".fal_solicitud_area_externa_seq to "sysctrlinfo" as "informix";
grant select on "informix".solicitud_consecutivo_seq to "ifxcons" as "informix";
grant select on "informix".solicitud_consecutivo_seq to "ifxconsacc" as "informix";
grant select on "informix".solicitud_consecutivo_seq to "ifxdesaa" as "informix";
grant alter on "informix".solicitud_consecutivo_seq to "ifxdesaa" as "informix";
grant select on "informix".solicitud_consecutivo_seq to "ifxprod" as "informix";
grant alter on "informix".solicitud_consecutivo_seq to "ifxprod" as "informix";
grant select on "informix".solicitud_consecutivo_seq to "public" as "informix";
grant select on "informix".solicitud_consecutivo_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_tipo_tramite_seq to "ifxcons" as "informix";
grant select on "informix".cat_tipo_tramite_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_tipo_tramite_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_tipo_tramite_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_tipo_tramite_seq to "ifxprod" as "informix";
grant alter on "informix".cat_tipo_tramite_seq to "ifxprod" as "informix";
grant select on "informix".cat_tipo_tramite_seq to "public" as "informix";
grant select on "informix".cat_tipo_tramite_seq to "sysctrlinfo" as "informix";
grant select on "informix".cat_origen_evento_seq to "ifxcons" as "informix";
grant select on "informix".cat_origen_evento_seq to "ifxconsacc" as "informix";
grant select on "informix".cat_origen_evento_seq to "ifxdesaa" as "informix";
grant alter on "informix".cat_origen_evento_seq to "ifxdesaa" as "informix";
grant select on "informix".cat_origen_evento_seq to "ifxprod" as "informix";
grant alter on "informix".cat_origen_evento_seq to "ifxprod" as "informix";
grant select on "informix".cat_origen_evento_seq to "public" as "informix";
grant select on "informix".cat_origen_evento_seq to "sysctrlinfo" as "informix";
grant select on "informix".fal_resolucion_seq to "ifxcons" as "informix";
grant select on "informix".fal_resolucion_seq to "ifxconsacc" as "informix";
grant select on "informix".fal_resolucion_seq to "ifxdesaa" as "informix";
grant alter on "informix".fal_resolucion_seq to "ifxdesaa" as "informix";
grant select on "informix".fal_resolucion_seq to "ifxprod" as "informix";
grant alter on "informix".fal_resolucion_seq to "ifxprod" as "informix";
grant select on "informix".fal_resolucion_seq to "public" as "informix";
grant select on "informix".fal_resolucion_seq to "sysctrlinfo" as "informix";
grant select on "informix".bitacora_control_cancelacion_cuenta_seq to "ifxcons" as "informix";
grant select on "informix".bitacora_control_cancelacion_cuenta_seq to "ifxconsacc" as "informix";
grant select on "informix".bitacora_control_cancelacion_cuenta_seq to "ifxdesaa" as "informix";
grant alter on "informix".bitacora_control_cancelacion_cuenta_seq to "ifxdesaa" as "informix";
grant select on "informix".bitacora_control_cancelacion_cuenta_seq to "ifxprod" as "informix";
grant alter on "informix".bitacora_control_cancelacion_cuenta_seq to "ifxprod" as "informix";
grant select on "informix".bitacora_control_cancelacion_cuenta_seq to "public" as "informix";
grant select on "informix".bitacora_control_cancelacion_cuenta_seq to "sysctrlinfo" as "informix";
grant select on "informix".control_cuentas_pendientes_cancelar_seq to "ifxcons" as "informix";
grant select on "informix".control_cuentas_pendientes_cancelar_seq to "ifxconsacc" as "informix";
grant select on "informix".control_cuentas_pendientes_cancelar_seq to "ifxdesaa" as "informix";
grant alter on "informix".control_cuentas_pendientes_cancelar_seq to "ifxdesaa" as "informix";
grant select on "informix".control_cuentas_pendientes_cancelar_seq to "ifxprod" as "informix";
grant alter on "informix".control_cuentas_pendientes_cancelar_seq to "ifxprod" as "informix";
grant select on "informix".control_cuentas_pendientes_cancelar_seq to "public" as "informix";
grant select on "informix".control_cuentas_pendientes_cancelar_seq to "sysctrlinfo" as "informix";
grant select on "informix".control_documentos_digitales_seq to "ifxcons" as "informix";
grant select on "informix".control_documentos_digitales_seq to "ifxconsacc" as "informix";
grant select on "informix".control_documentos_digitales_seq to "ifxdesaa" as "informix";
grant alter on "informix".control_documentos_digitales_seq to "ifxdesaa" as "informix";
grant select on "informix".control_documentos_digitales_seq to "ifxprod" as "informix";
grant alter on "informix".control_documentos_digitales_seq to "ifxprod" as "informix";
grant select on "informix".control_documentos_digitales_seq to "public" as "informix";
grant select on "informix".control_documentos_digitales_seq to "sysctrlinfo" as "informix";
create index "informix".idx_tabla_cierre_preventivo_afectac on 
    "informix".tabla_cierre_preventivo_afectac (codigo_resolucion,
    folio_csuac,procedente) using btree  in datos00;