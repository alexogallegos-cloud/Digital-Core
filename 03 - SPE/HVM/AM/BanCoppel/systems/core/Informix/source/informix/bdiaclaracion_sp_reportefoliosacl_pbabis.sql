CREATE PROCEDURE "informix".sp_reportefoliosacl_pbabis(pfolios varchar(250))
							
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
							date		as Fecha_afectacion_abono,
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
		DEFINE vfecha_afectacion	date;
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
		
		
		--SET DEBUG FILE TO "sp_reportefoliosacl.out";
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
						
						
			select fky_padre, fky_aclaracion, fky_solicitud_e_global, folio_suc, fky_tipo_catalogo_transaccion, ref_comercio,fechahora,fecha_afectacion,referencia23 
			from bdiaclaracion:acl_movimiento where folio_csuac in (select cfolio from tmp_folios_acl) and fky_padre is null
			into temp tmp_movimientos_acl with no log;
				
			select secuenciaextendida,codgironeg, idretailer, infreceptor, metodocaptura, numtarjeta from intercard:movimiento 
			where secuenciaextendida in (select SUBSTR(folio_suc,2,length(folio_suc)) from tmp_movimientos_acl where folio_suc is not null)
			into temp tmp_movimientos_inter with no log;
			
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
;