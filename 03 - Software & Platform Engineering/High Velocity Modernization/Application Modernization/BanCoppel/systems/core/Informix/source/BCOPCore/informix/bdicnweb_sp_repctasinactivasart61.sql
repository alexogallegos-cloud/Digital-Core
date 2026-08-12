CREATE PROCEDURE "informix".sp_repctasinactivasart61(pUsuario CHAR(8), pIdFuncion CHAR(10), pReporte CHAR(2), pRutaDescarga CHAR(100), pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60), pIdReporte CHAR(20))
RETURNING CHAR(5) AS codret;		

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCmd1 CHAR(3000);
	DEFINE cSql CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE iCont INTEGER;
    DEFINE sCommit SMALLINT;
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE dFechaConsulta DATE;
	DEFINE dFechaMax DATE;
	DEFINE dFechaMin DATE;
	DEFINE cReporte CHAR(100);
	DEFINE cRutaGral CHAR(100);
	DEFINE iNumRegistros INTEGER;
	DEFINE cNombreReporte CHAR(100);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(15);
	
	DEFINE cEstatus CHAR(1);
	DEFINE cDescEstatus CHAR(30);
	DEFINE cNum_cuenta CHAR(20);
	DEFINE cProducto CHAR(4);
	DEFINE cNum_cliente CHAR(20);
	DEFINE dFech_ult_dep DATE;
	DEFINE dFech_ult_ret DATE;
	DEFINE dFecha_inf DATE;
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cApell_paterno CHAR(26);
	DEFINE cApell_materno CHAR(26);
	DEFINE cSucursal CHAR(4);
	DEFINE cDescSucursal CHAR(40);
	DEFINE cEstado CHAR(2);
	DEFINE cDescEstado CHAR(30);
	DEFINE cDescProducto CHAR(30);
	DEFINE dFechaAlta DATE;
	DEFINE dFecha_ult_mov DATE;
	
	DEFINE cDescProducto_con CHAR(40);
	DEFINE cNom_cliente CHAR(107);
	DEFINE dFecha_con DATE;
	DEFINE cImporte_con CHAR(20);
	DEFINE cInteres_gen CHAR(16);
	
	DEFINE dFecha_des DATE;
	DEFINE cInteres_gen_des DECIMAL(14,2);
	DEFINE cPago_sdo_concentra DECIMAL(18,2);
	
	DEFINE dFecha_tra DATE;
	DEFINE cInteres_gen_can DECIMAL(14,2);
	DEFINE cSdo_trasp_beneficiencia DECIMAL(18,2);
	
	DEFINE v_producto CHAR(4);
	DEFINE v_nombre   CHAR(40);
	
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);
	DEFINE cStr9 CHAR(60);
	DEFINE cStr10 CHAR(60);
	DEFINE cStr11 CHAR(60);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCmd1 = '';
	LET cSql = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET iCont = 0;
    LET sCommit = 0;
	LET cRutaInformix = '/ifxsif01/bin/';
	--LET cRutaInformix = '/informix/bin/';
	LET cUsrBin = '/usr/bin/';
	LET dFechaConsulta = '';
	LET dFechaMax = '';
	LET dFechaMin = '';
	LET cReporte = '';
	LET cRutaGral = '';
	LET iNumRegistros = 0;
	LET cNombreReporte = '';
	LET cNombreReporteHist = '';
	LET cFechaHoraArchivo = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	
	LET cEstatus = '';
	LET cDescEstatus = '';
	LET cNum_cuenta = '';
	LET cProducto = '';
	LET cNum_cliente = '';
	LET dFech_ult_dep = '';
	LET dFech_ult_ret = '';
	LET dFecha_inf = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cApell_paterno = '';
	LET cApell_materno = '';
	LET cSucursal = '';
	LET cDescSucursal = '';
	LET cEstado = '';
	LET cDescEstado = '';
	LET cDescProducto = '';
	LET dFechaAlta = '';
	LET dFecha_ult_mov = '';
	
	LET cDescProducto_con = '';
	LET cNom_cliente = '';
	LET dFecha_con = '';
	LET cImporte_con = '';
	LET cInteres_gen = '';
	
	LET dFecha_des = '';
	LET cInteres_gen_des = 0.00;
	LET cPago_sdo_concentra = 0.00;
	
	LET dFecha_tra = '';
	LET cInteres_gen_can = 0.00;
	LET cSdo_trasp_beneficiencia = 0.00;
	
	LET dHoy = '';
	LET cStr7 = ''; 
	LET cStr8 = ''; 
	LET cStr9 = '';
	LET cStr10 = '';
	LET cStr11 = '';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
		
	BEGIN

		ON EXCEPTION SET iSqlErr
		
			SET DEBUG FILE TO '/resplogifx/conciliachq/sp_repctasinactivasart61.out';
			TRACE ON;
			
			LET cCodRet = iSqlErr;
						
			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			TRACE OFF;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_repctasinactivasart61.out';
		--SET DEBUG FILE TO '/informix/rsv/ART61/TASF/bdicnweb/sp_repctasinactivasart61.out';

		IF pUsuario = '' OR pIdFuncion = '' OR pReporte = '' OR pRutaDescarga = ''  OR pIdPlantilla = '' OR pTituloPlantilla = '' THEN
			LET cCodRet = '00003';			
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		LET cNombreReporte = TRIM(pIdReporte)||'_'||pUsuario||'_'||TO_CHAR(CURRENT,'%d%m%Y')||'.csv';
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	
		
		-- OBTIENE LA FECHA HOY Y DEFINE PERIODO DE CONSULTA
		SELECT fecha_hoy INTO dFechaConsulta FROM bdicheq:"informix".sc_fechas WHERE empresa = cEmpresa;		
		
		LET dFechaMax = LAST_DAY(dFechaConsulta - 1 UNITS MONTH);
		LET dFechaMin = TO_DATE(1||'/'||MONTH(dFechaMax)||'/'||YEAR(dFechaMax),'%d/%m/%Y');
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- CUENTAS INFORMADAS
		IF pReporte = '1' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctasinformadas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctasinformadas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'INFORMADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '5';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
			SELECT  inf.cuenta,inf.producto,inf.num_cte,inf.fech_ult_dep,inf.fech_ult_ret,inf.fecha_marc
			FROM    bdicheq:sc_ctasinformadas AS inf 
			WHERE   inf.fecha_marc BETWEEN dFechaMin AND dFechaMax
			INTO    TEMP tmp_infdas WITH NO LOG;
				
			CREATE INDEX idx_tmp_infdas 
            ON tmp_infdas (cuenta,fecha_marc);

			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH
			FOREACH WITH HOLD

			    SELECT a.cuenta,   a.producto, a.num_cte,    a.fech_ult_dep, a.fech_ult_ret, a.fecha_marc
				INTO   cNum_cuenta,cProducto,  cNum_cliente, dFech_ult_dep,  dFech_ult_ret,  dFecha_inf
				FROM   tmp_infdas as a, 
				       bdicheq:sc_ctasinformadas as b
                where  a.cuenta     = b.cuenta 
                and    a.fecha_marc = b.fecha_marc				
				AND    a.fecha_marc = (SELECT MIN(b.fecha_marc) 
				                          FROM   bdicheq:sc_ctasinformadas b 
			  	                          WHERE  b.cuenta = a.cuenta)
				
				SELECT nombre1,nombre2,apell_paterno,apell_materno
				INTO   cNombre1,cNombre2,cApell_paterno,cApell_materno
				FROM   bdinteg:"informix".si_cliente WHERE numcte = cNum_cliente;
				
				SELECT sucursal INTO cSucursal FROM bdicheq:"informix".sc_maechq WHERE cuenta = cNum_cuenta AND producto = cProducto;
				
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				SELECT fecha_alta INTO dFechaAlta FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;
								
				INSERT INTO bdicnweb:"informix".sw_det_ctasinformadas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(cProducto)||' '||TRIM(cDescProducto),cNum_cliente,TRIM(TRIM(cNombre1)||' '||TRIM(cNombre2))||' '||TRIM(cApell_paterno)||' '||TRIM(cApell_materno),
				TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),dFecha_inf,UPPER(cDescEstatus),CURRENT,pUsuario);
				
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF; 
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				
			END FOREACH;
			COMMIT WORK;			

			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
			
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf::CHAR(10),estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctasinformadas "||
			"WHERE usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
							
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		-- CUENTAS CONCENTRADAS
		ELIF pReporte = '2' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctasconcentradas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctasconcentradas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'CONCENTRADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '6';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
								
	       --OBTIENE EL PRODUCTO  5000 PARA LA CONCENTRACION  - RSV 
	       SELECT producto,   nombre
	         INTO v_producto, v_nombre
	         FROM bdicheq:sc_producto
	        WHERE producto = '5000'; 
									
			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH

			SELECT  b.cuenta,b.producto as nom_producto,b.num_cte,b.cliente,b.fech_ult_dep,
                    b.fech_ult_ret,b.fecha_concentra,b.sdo_concentrado,a.sucursal,
					a.producto,b.ints_prov_acum
            FROM    bdicheq:sc_maechq AS a,
                    bdicheq:sc_cuentas_concentradas as b
            WHERE   a.cuenta     = b.cuenta
            AND     a.status_cta = "6"
            and     a.sdo_actual = b.sdo_concentrado
            and     b.fecha_concentra BETWEEN dFechaMin AND dFechaMax
            and     b.fecha_pago_concentra IS NULL
            INTO    TEMP tmp_ctas_concentra WITH NO LOG;
			
			
			CREATE INDEX idx_tmp_ctas_concentra 
			ON tmp_ctas_concentra(cuenta);
			
		    SELECT  a.cuenta,a.nom_producto,a.num_cte,a.cliente,a.fech_ult_dep,a.fech_ult_ret,
				    a.fecha_concentra,a.sdo_concentrado,a.sucursal,a.producto,a.ints_prov_acum,c.fecha_marc	
			FROM    tmp_ctas_concentra AS a, 
					bdicheq:sc_ctasinformadas  AS c
			WHERE   a.cuenta = c.cuenta
			AND     c.fecha_marc = (SELECT MIN(d.fecha_marc) 
				                    FROM   bdicheq:sc_ctasinformadas d 
			  	                    WHERE  d.cuenta = a.cuenta)
			INTO TEMP tmp_ctas_concentra_fin WITH NO LOG;
						
			FOREACH WITH HOLD
					    
				SELECT cuenta,nom_producto,num_cte,cliente,fech_ult_dep,fech_ult_ret,fecha_concentra,sdo_concentrado,
				       sucursal,producto,ints_prov_acum,fecha_marc
				INTO   cNum_cuenta,cDescProducto_con,cNum_cliente,cNom_cliente,dFech_ult_dep,dFech_ult_ret,
				       dFecha_con,cImporte_con,cSucursal,cProducto,cInteres_gen,dFecha_inf
				FROM   tmp_ctas_concentra_fin
			
							
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				--SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				
				SELECT fecha_alta 
				INTO dFechaAlta
				FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
					
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;				
			
								
				INSERT INTO bdicnweb:"informix".sw_det_ctasconcentradas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,fecha_con,importe_con,interes_gen,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(v_producto)||' '||TRIM(v_nombre),cNum_cliente,cNom_cliente,TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),
				TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),dFecha_inf,TO_CHAR(dFecha_con, '%d/%m/%Y'),cImporte_con,NVL(cInteres_gen,0),UPPER(cDescEstatus),CURRENT,pUsuario);
				
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				LET cDescProducto_con = '';
				LET cNom_cliente = '';
				LET dFecha_con = '';
				LET cImporte_con = '';
				LET cInteres_gen = '';
				
			END FOREACH;
			COMMIT WORK;
			
			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
						
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','FECHA DE CONCENTRACION','IMPORTE CONCENTRADO','INTERES GENERADO','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT a.fecha_consulta,a.num_cuenta,a.producto,a.num_cliente,a.nom_cliente,a.sucursal,a.fecha_alta,a.fecha_ult_mov,a.fecha_inf::CHAR(10),a.fecha_con,a.importe_con,a.interes_gen,a.estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctasconcentradas as a, bdicheq:sc_maechq as b where a.num_cuenta = b.cuenta and a.fecha_inf = (select max(fecha_inf) from bdicnweb:sw_det_ctasconcentradas as c where c.num_cuenta = b.cuenta) "||
			"AND usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
			
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		-- CUENTAS DESCONCENTRADAS/ACTIVAS
		ELIF pReporte = '3' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctasdesconcentradas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctasdesconcentradas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'DESCONCENTRADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '1';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH
			FOREACH WITH HOLD
				
				SELECT con.cuenta,con.producto,con.num_cte,con.cliente,con.fech_ult_dep,con.fech_ult_ret,--con.fecha_concentra,
				(SELECT MAX(a.fecha_concentra) FROM bdicheq:"informix".sc_cuentas_concentradas a WHERE a.cuenta = con.cuenta AND a.fecha_pago_concentra BETWEEN dFechaMin AND dFechaMax),
				con.sdo_concentrado,con.int_sdo_concentra,con.fecha_pago_concentra,con.pago_sdo_concentra,mae.sucursal,mae.producto,inf.fecha_marc
				INTO cNum_cuenta,cDescProducto_con,cNum_cliente,cNom_cliente,dFech_ult_dep,dFech_ult_ret,dFecha_con,
				cImporte_con,cInteres_gen_des,dFecha_des,cPago_sdo_concentra,cSucursal,cProducto,dFecha_inf
				FROM bdicheq:"informix".sc_cuentas_concentradas AS con, 
				     bdicheq:"informix".sc_maechq AS mae,
					 bdicheq:"informix".sc_ctasinformadas as inf
			    WHERE con.cuenta = mae.cuenta
				AND   con.cuenta = inf.cuenta
                 --  AND con.num_cte = inf.num_cte
				AND   con.fecha_pago_concentra BETWEEN dFechaMin AND dFechaMax
				AND   inf.fecha_marc = (SELECT MIN(c.fecha_marc) 
				                        FROM   bdicheq:sc_ctasinformadas c 
			  	                        WHERE  c.cuenta = mae.cuenta)
			---	AND mae.status_cta = cEstatus
				---ORDER BY con.fecha_pago_concentra ASC
				
			--	FOREACH
			---		SELECT FIRST 1 fecha_marc 
			---		INTO dFecha_inf
			---		FROM bdicheq:"informix".sc_ctasinformadas 
			---		WHERE cuenta = cNum_cuenta ORDER BY fecha_marc DESC
			--	END FOREACH;
				
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				--SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				
				SELECT fecha_alta INTO dFechaAlta FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;	
								
				INSERT INTO bdicnweb:"informix".sw_det_ctasdesconcentradas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,fecha_con,importe_con,interes_gen,fecha_des,importe_des,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(cProducto)||' '||TRIM(cDescProducto_con),cNum_cliente,cNom_cliente,TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),
				dFecha_inf,TO_CHAR(dFecha_con, '%d/%m/%Y'),cImporte_con,cInteres_gen_des,TO_CHAR(dFecha_des, '%d/%m/%Y'),TRUNC(NVL(cInteres_gen_des,0) + NVL(cImporte_con,0),2),UPPER(cDescEstatus),CURRENT,pUsuario);
				 
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF; 
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				LET cDescProducto_con = '';
				LET cNom_cliente = '';
				LET dFecha_con = '';
				LET cImporte_con = '';
				LET cInteres_gen = '';
				LET dFecha_des = '';
				LET cInteres_gen_des = 0.00;
				LET cPago_sdo_concentra = 0.00;
				
			END FOREACH;
			COMMIT WORK;
			
			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
						
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','FECHA DE CONCENTRACION','IMPORTE CONCENTRADO','INTERES GENERADO','FECHA DESCONCENTRACION/ACTIVA','IMPORTE DESCONCENTRADO','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT a.fecha_consulta, a.num_cuenta,a.producto,a.num_cliente,a.nom_cliente,a.sucursal,a.fecha_alta,a.fecha_ult_mov,a.fecha_inf::CHAR(10),a.fecha_con,a.importe_con,a.interes_gen,a.fecha_des,a.importe_des,a.estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctasdesconcentradas as a, bdicheq:sc_maechq as b where a.num_cuenta = b.cuenta and a.fecha_inf = (select max(fecha_inf) from bdicnweb:sw_det_ctasdesconcentradas as c where c.num_cuenta = b.cuenta) "|| 
			"AND usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
			
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
		
		-- CUENTAS CANCELADAS
		ELIF pReporte = '4' THEN
			
			-- SE LIMPIA TABLA DE PASO POR USUARIO
			--DELETE FROM bdicnweb:"informix".sw_det_ctascanceladas WHERE usuario_insert = pUsuario;
			BEGIN;
				TRUNCATE TABLE bdicnweb:"informix".sw_det_ctascanceladas;
			COMMIT;
			
			-- SE DEFINE NOMENCLATURA DEL REPORTE
			LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
			LET cReporte = 'CANCELADA_'||TO_CHAR(CURRENT, '%d%m')||SUBSTR(TRIM(TO_CHAR(CURRENT, '%Y')),3,2)||'.txt';
			LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cReporte);
			
			LET cEstatus = '2';
			SELECT descripcion INTO cDescEstatus FROM bdicheq:"informix".sc_mae_estatus WHERE cod_estatus = cEstatus;
			
			
		  --OBTIENE EL PRODUCTO  5000 PARA LA CONCENTRACION 
	       SELECT producto,   nombre
	         INTO v_producto, v_nombre
	         FROM bdicheq:sc_producto
	        WHERE producto = '5000'; 
									
					
			BEGIN WORK;
			LET ven_transacc = 1;
			--FOREACH
			FOREACH WITH HOLD
				
				 SELECT con.cuenta,con.producto,con.num_cte,con.cliente,con.fech_ult_dep,con.fech_ult_ret,--con.fecha_concentra,
				(SELECT MAX(a.fecha_concentra) FROM bdicheq:"informix".sc_cuentas_concentradas a WHERE a.cuenta = con.cuenta AND a.fecha_trasp_benefic BETWEEN dFechaMin AND dFechaMax),
				con.sdo_concentrado,con.int_trasp_beneficiencia,con.fecha_trasp_benefic,con.sdo_trasp_beneficiencia,mae.sucursal,mae.producto,inf.fecha_marc
				INTO cNum_cuenta,cDescProducto_con,cNum_cliente,cNom_cliente,dFech_ult_dep,dFech_ult_ret,dFecha_con,
				cImporte_con,cInteres_gen_can,dFecha_tra,cSdo_trasp_beneficiencia,cSucursal,cProducto,dFecha_inf
				FROM bdicheq:"informix".sc_cuentas_concentradas AS con, 
				                   bdicheq:"informix".sc_maechq AS mae,
								   bdicheq:"informix".sc_ctasinformadas as inf
				WHERE con.cuenta  = mae.cuenta
				AND   con.cuenta  = inf.cuenta
                AND   con.num_cte = inf.num_cte			   
				AND   con.fecha_trasp_benefic BETWEEN dFechaMin AND dFechaMax
				AND   mae.motivo = '14'
				AND   mae.status_cta = cEstatus
				AND   inf.fecha_marc = (SELECT MIN(c.fecha_marc) 
				                        FROM   bdicheq:sc_ctasinformadas c 
			  	                        WHERE  c.cuenta = mae.cuenta)
				-- ORDER BY con.fecha_trasp_benefic ASC
				
				--FOREACH
				--	SELECT FIRST 1 fecha_marc 
				--	INTO dFecha_inf
				--	FROM bdicheq:"informix".sc_ctasinformadas 
				--	WHERE cuenta = cNum_cuenta ORDER BY fecha_marc DESC
				--END FOREACH;
				
				SELECT su.nombre,es.estado,es.nombre 
				INTO cDescSucursal,cEstado,cDescEstado
				FROM bdinteg:"informix".si_sucursales AS su, bdinteg:"informix".si_estados AS es
				WHERE su.estado = es.estado AND su.sucursal = cSucursal;
				
				--SELECT nombre INTO cDescProducto FROM bdicheq:"informix".sc_producto WHERE producto = cProducto;
				
				SELECT fecha_alta INTO dFechaAlta FROM bdicheq:"informix".sc_maenoc WHERE cuenta = cNum_cuenta;
				
				IF dFech_ult_dep > dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_dep;
				ELIF dFech_ult_dep < dFech_ult_ret THEN
					LET dFecha_ult_mov = dFech_ult_ret;
			    ELIF dFech_ult_dep = dFech_ult_ret THEN 
				    LET dFecha_ult_mov = dFech_ult_ret;
				END IF;	
								
				INSERT INTO bdicnweb:"informix".sw_det_ctascanceladas(fecha_consulta,num_cuenta,producto,num_cliente,nom_cliente,sucursal,fecha_alta,fecha_ult_mov,fecha_inf,fecha_con,importe_con,interes_gen,fecha_tras,importe_envben,estatus_act,fechahr_insert,usuario_insert)
				VALUES (TO_CHAR(dFechaConsulta, '%d/%m/%Y'),cNum_cuenta,TRIM(v_producto)||' '||TRIM(v_nombre),cNum_cliente,cNom_cliente,TRIM(cSucursal)||' '||TRIM(cDescSucursal)||', '||TRIM(cDescEstado),TO_CHAR(dFechaAlta, '%d/%m/%Y'),TO_CHAR(dFecha_ult_mov,'%d/%m/%Y'),
				dFecha_inf,TO_CHAR(dFecha_con, '%d/%m/%Y'),cImporte_con,cInteres_gen_can,TO_CHAR(dFecha_tra, '%d/%m/%Y'),NVL(cInteres_gen_can,0) + NVL(cSdo_trasp_beneficiencia,0),UPPER(cDescEstatus),CURRENT,pUsuario);
				
				LET iCont = iCont + 1;
				LET iNumRegistros = iNumRegistros + 1;
				
				IF iCont >= 5000 THEN
					LET iCont = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF;
				
				-- SE INICIALIZAN VARIABLES
				LET cNum_cuenta = '';
				LET cProducto = '';
				LET cNum_cliente = '';
				LET dFech_ult_dep = '';
				LET dFech_ult_ret = '';
				LET dFecha_inf = '';
				LET cNombre1 = '';
				LET cNombre2 = '';
				LET cApell_paterno = '';
				LET cApell_materno = '';
				LET cSucursal = '';
				LET cDescSucursal = '';
				LET cEstado = '';
				LET cDescEstado = '';
				LET cDescProducto = '';
				LET dFechaAlta = '';
				LET dFecha_ult_mov = '';
				LET cDescProducto_con = '';
				LET cNom_cliente = '';
				LET dFecha_con = '';
				LET cImporte_con = '';
				LET cInteres_gen = '';
				LET dFecha_des = '';
				LET cInteres_gen_des = 0.00;
				LET cPago_sdo_concentra = 0.00;
				LET dFecha_tra = '';
				LET cInteres_gen_can = 0.00;
				LET cSdo_trasp_beneficiencia = 0.00;
				
			END FOREACH;
			COMMIT WORK;
			
			IF iNumRegistros = 0 THEN
				LET cCodRet = '00017';
				LET ven_transacc = 0;
				IF bInTransaction = 't' THEN
					BEGIN WORK;
				END IF;
				RETURN cCodRet;
			END IF;
						
			LET cCmd1 = "";
			LET cCmd1 = "SELECT 'FECHA DE CONSULTA','NUMERO DE CUENTA','PRODUCTO','NUMERO DE CLIENTE','NOMBRE DEL CLIENTE','SUCURSAL APERTURA','FECHA ALTA','FECHA ULTIMO MOVIMIENTO','FECHA INFORMADA','FECHA DE CONCENTRACION','IMPORTE CONCENTRADO','INTERES GENERADO','FECHA TRASPASO','IMPORTE ENVIADO A LA BENEFICENCIA PUBLICA','ESTATUS ACTUAL' "||	
			"FROM systables WHERE tabid = 1 UNION ALL SELECT * FROM( "||
			"SELECT a.fecha_consulta,a.num_cuenta,a.producto,a.num_cliente,a.nom_cliente,a.sucursal,a.fecha_alta,a.fecha_ult_mov,a.fecha_inf::CHAR(10),a.fecha_con,a.importe_con,a.interes_gen,a.fecha_tras,a.importe_envben,a.estatus_act "||
			"FROM bdicnweb:""informix"".sw_det_ctascanceladas as a, bdicheq:sc_maechq as b where a.num_cuenta = b.cuenta and a.fecha_inf = (select max(fecha_inf) from bdicnweb:sw_det_ctascanceladas as c where c.num_cuenta = b.cuenta) "|| 
			"AND usuario_insert = '"|| pUsuario ||"' ORDER BY id_registro ASC)";
			
			SYSTEM TRIM(TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' '||TRIM(cCmd1)||';" | '||TRIM(cRutaInformix)||'dbaccess bdicnweb > /dev/null 2>&1');
			
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
		
		END IF;
		
		-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
		FOREACH
		
			SELECT nombre_reporte
			INTO cNombreReporteHist
			FROM bdicnweb:"informix".sw_ctrlgenreportesart61 
			WHERE usuario_insert = pUsuario --AND nombre_reporte = TRIM(cNombreReporte) 
			AND fecha_reporte < dFechaHoy
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreReporteHist);
			SYSTEM TRIM(cSql);
			
			DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesart61 WHERE nombre_reporte = TRIM(cNombreReporteHist);
			
		END FOREACH;
		
		DELETE FROM bdicnweb:"informix".sw_ctrlgenreportesart61 WHERE nombre_reporte = TRIM(cReporte);
		INSERT INTO bdicnweb:"informix".sw_ctrlgenreportesart61(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert)
		VALUES(TRIM(cReporte),dFechaHoy,dHoraHoy,pUsuario);		
		
		
		-- NOTIFICACION VIA CORREO ELECTRONICO
		LET cStr7 = 'GENERACION DEL ARCHIVO TXT';
		LET cStr8 = 'SOLICITUD DE CUENTAS INACTIVAS ART. 61';
		LET cStr9 = '000000000';
		LET cStr10 = 'MAIL_ART61';
		LET cStr11 = 'operaciones_art61@bancoppel.com';
		LET dHoy = CURRENT;
		
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
		'1', 
		'WEB_PLAGEN',
		TRIM(cStr10), 
		TRIM(cStr9),
		'',
		'', 
		'1', 
		'',
		'',
		'',
		'',
		'',
		TRIM(pTituloPlantilla),
		TRIM(cStr7),
		TRIM(cStr8),
		'',		
		'',
		TRIM(cStr11),
		'',
		'1',
		'0',
		'0',
		'0',
		'0',
		dHoy,
		''
		) INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCION DEL SP bdimnsj:"informix".sp_registra_evento, 
		END IF; 
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 23/05/2017',
'MODULO: DEBITO',
'FUNCIONALIDAD: REPORTE CUENTAS INACTIVAS (ART 61)',
'DESCRIPCION: SPL que genera reporte txt de las Cuentas Inactivas (Art 61)',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 02/06/2017',
'DESCRIPCION: Se actualiza para obtener campo saldo de la tabla bdicheq:sc_cuentas_concentradas.sdo_concentrado',
'en lugar de bdicheq:sc_maechq.imp_cgos_mes cuando las cuentas tienen estatus CANCELADO',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 11/07/2017',
'DESCRIPCION: Se modifica spl para la reasignacion de tablas utilizadas en la recuperacion del detalle de las fechas,',
'se reemplaza el NUMERO del estatus por su descripcion.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 21/01/2019',
'DESCRIPCION: Se modifica spl para establecer nuevas reglas de negocio solicitadas por el cliente.',
'BD: bdicnweb',
'AUTOR: Johnattan Esquivel Sanchez',
'FECHA: 17/07/2019',
'DESCRIPCION: Se modifica spl para control de tiemeout en SOC.',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 05/08/2019',
'DESCRIPCION:  Se modifica spl para activar y desactivar trace cuando ocurre un error no controlado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cg_actualizatransacciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdActualiza CHAR(1),
pSucursal CHAR(4), pFecha DATE, pFolio CHAR(8), pOperacion CHAR(4), pMonto MONEY(16,2))
		RETURNING CHAR(5) AS codret;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cTipoOperacion CHAR(25);
	DEFINE cDescActualiza CHAR(20);
	DEFINE iRecuperacion INTEGER;
	DEFINE cStatus CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cTipoOperacion = '';
	LET cDescActualiza = '';
	LET iRecuperacion = 0;	
	LET cStatus = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_actualizatransacciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdActualiza = '' OR pSucursal = '' OR pFecha IS NULL OR pFolio = '' OR pOperacion = '' OR pMonto IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--REVERSO
		IF pIdActualiza = '1' THEN
			
			UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '08' 
			WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
			
			UPDATE bdisuc:"informix".ss_operaciones SET reversado = '1' 
			WHERE sucursal = pSucursal AND fecha_operacion = pFecha AND folio_oper = pFolio;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = '00283';
				RETURN cCodRet;
			END IF;
			
			LET cDescActualiza = 'REVERSO';
			
		END IF;
		
		--CAMBIO ESTATUS
		IF pIdActualiza = '2' THEN
			
			SELECT status 
			INTO cStatus 
			FROM bdisuc:"informix".ss_mae_entradasalida WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
			IF cStatus = '08' THEN
				UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '01' 
				WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			
				UPDATE bdisuc:"informix".ss_operaciones SET reversado = '0' 
				WHERE sucursal = pSucursal AND fecha_operacion = pFecha AND folio_oper = pFolio;
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
				
			ELSE
				UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '11' 
				WHERE sucursal = pSucursal AND fecha_solicitud = pFecha AND folio_oper = pFolio;
			
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00283';
					RETURN cCodRet;
				END IF;
			END IF;
			
			LET cDescActualiza = 'CAMBIO ESTATUS';
			
		END IF;
		
		IF pOperacion IN ('0001','0010','0036') THEN
			LET cTipoOperacion = 'DOTACION';
		ELIF pOperacion IN ('0002','0041') THEN
			LET cTipoOperacion = 'CONCENTRACION';
		ELIF pOperacion = '0026' THEN
			LET cTipoOperacion = 'RECOLECCION';
		END IF;
		
		--SE REGISTRA EN BITÁCORA
		INSERT INTO bdisuc:"informix".ss_bitacora_reversoscg (fecha_modificacion,sucursal,folio_operacion,tipo_operacion,monto,usuario,reverso_cambio)
		VALUES(CURRENT,pSucursal,pFolio,cTipoOperacion,pMonto,pUsuario,cDescActualiza);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00282';
			RETURN cCodRet;
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de actualizar los campos correspondientes al reverso y cambio de estatus de las Operaciones de Caja General.',
'BD: bdicnweb','AUTOR: Veronica Sanchez',
'FECHA: 04/05/2023',
'DESCRIPCION: se modifica SPL para realizar la actualizacion del campo estatus a 01 en tabla ss_mae_entradasalida y campo reversado a 0 de la tabla ss_operaciones ',
' solo para las transacciones 0002, 0026, 0041 y se agrega transaccion 0041 para indicar el tipo de operacion - Concentracion',
'AUTOR: Veronica Sanchez',
'FECHA: 09/05/2023',
'DESCRIPCION: Se modifica SPL para realizar la actualizacion del campo estatus a 01 en tabla ss_mae_entradasalida y campo reversado a 0 de la tabla ss_operaciones ',
' solo para las transacciones 0001 y 0010';

CREATE PROCEDURE "informix".sp_cg_detalletransacciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1),
pSucursal CHAR(4), pFecha DATE, pFolio CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
			DATE AS fecha_solicitud,
			CHAR(8) AS folio_oper,
			MONEY(16,2) AS monto,
			CHAR(4) AS sucursal,
			CHAR(4) AS cod_proveedor,
			CHAR(16) AS folio_servicio,
			CHAR(2) AS status,
			CHAR(4) AS operacion,
			CHAR(35) AS desc_operacion;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha_solicitud DATE;
	DEFINE cFolio_oper CHAR(8);
	DEFINE mMonto MONEY(16,2);
	DEFINE cSucursal CHAR(4);
	DEFINE cCod_proveedor CHAR(4);
	DEFINE cFolio_servicio CHAR(16);
	DEFINE cStatus CHAR(2);
	DEFINE cOperacion CHAR(4);
	DEFINE cDescOperacion CHAR(35);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha_solicitud = '';
	LET cFolio_oper = '';
	LET mMonto = 0.00;
	LET cSucursal = '';
	LET cCod_proveedor = '';
	LET cFolio_servicio = '';
	LET cStatus = '';
	LET cOperacion = '';
	LET cDescOperacion = '';
	LET iRecuperacion = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detalletransacciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pSucursal = '' OR pFecha IS NULL OR pFolio = '' OR 
		pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
		-- VALIDACIÓN DE LOS DATOS DE PAGINACION
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			
			SELECT SKIP pRegistros FIRST pRecuperacion 
			a.fecha_solicitud,a.folio_oper,a.monto,a.sucursal,a.cod_proveedor,a.folio_servicio,a.status,b.cod_trans,c.descripcion
			INTO dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion
			FROM bdisuc:"informix".ss_mae_entradasalida AS a, bdisuc:"informix".ss_operaciones AS b, bdisuc:"informix".ss_param_cajagen AS c
			WHERE a.folio_oper = b.folio_oper AND b.cod_trans = c.codigo 
			AND a.sucursal = pSucursal 
			AND a.fecha_solicitud = pFecha
			AND a.folio_oper = pFolio
			AND b.cod_trans IN ('0001','0002','0010','0026','0036','0041')
			ORDER BY a.folio_oper ASC
			
			--REVERSO
			IF pIdConsulta = '1' OR pIdConsulta = '2' THEN
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion WITH RESUME;
			END IF;
			
			--CAMBIO ESTATUS
			IF pIdConsulta = '2' THEN
				IF cOperacion IN ('0001','0010','0036') THEN
					LET iRecuperacion = iRecuperacion + 1;
					RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion WITH RESUME;
				END IF;
			END IF;
			
		END FOREACH;
		
		IF pRegistros = 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		ELIF pRegistros > 0 AND iRecuperacion = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha_solicitud,cFolio_oper,mMonto,cSucursal,cCod_proveedor,cFolio_servicio,cStatus,cOperacion,cDescOperacion;
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el detalle de las Operaciones de Caja General.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 04/05/2023',
'DESCRIPCION: Se modifica SPL para quitar validación de tipo operación en la opcion cambio de estatus para recuperar todosa los datos',
'AUTOR: Veronica Sanchez',
'FECHA: 09/05/2023',
'DESCRIPCION: Se modifica SPL para regresar validaciones de recuperación de información para la opción de Cambio de Estatus';

CREATE PROCEDURE "informix".sp_cg_detalletransacciones_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1),
pSucursal CHAR(4), pFecha DATE, pFolio CHAR(8))
		RETURNING CHAR(5) AS codret,
			INTEGER AS no_registros;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cFolio_oper CHAR(8);
	DEFINE cOperacion CHAR(4);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cFolio_oper = '';
	LET cOperacion = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cg_detalletransacciones_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdConsulta = '' OR pSucursal = '' OR pFecha IS NULL OR pFolio = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iNoRegistros;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT a.folio_oper,b.cod_trans
			INTO cFolio_oper,cOperacion
			FROM bdisuc:"informix".ss_mae_entradasalida AS a, bdisuc:"informix".ss_operaciones AS b, bdisuc:"informix".ss_param_cajagen AS c
			WHERE a.folio_oper = b.folio_oper AND b.cod_trans = c.codigo 
			AND a.sucursal = pSucursal 
			AND a.fecha_solicitud = pFecha
			AND a.folio_oper = pFolio
			AND b.cod_trans IN ('0001','0002','0010','0026','0036','0041')
			ORDER BY a.folio_oper ASC
			
			--REVERSO 
			IF pIdConsulta = '1' OR pIdConsulta = '2' THEN
				LET iNoRegistros = iNoRegistros + 1;
			END IF;
			
			--CAMBIO ESTATUS
			IF pIdConsulta = '2' THEN
				IF cOperacion IN ('0001','0010','0036') THEN
					LET iNoRegistros = iNoRegistros + 1;
				END IF;
			END IF;
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,iNoRegistros;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 29/04/2020',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: REVERSO DE OPERACIONES CAJA GENERAL',
'DESCRIPCION: SPL encargado de consultar el número total de las Operaciones de Caja General.',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 04/05/2023',
'DESCRIPCION: Se modifica SPL para quitar validación de tipo operación en la opcion cambio de estatus para recuperar todosa los datos',
'AUTOR: Veronica Sanchez',
'FECHA: 09/05/2023',
'DESCRIPCION: Se modifica SPL para regresar validaciones de recuperación de información para la opción de Cambio de Estatus';

CREATE PROCEDURE "informix".sp_consultas_cac_central_total2(pEmpresa CHAR(3),pSucursal CHAR(4), pFechaInicial DATE, pFechaFinal DATE, pNumSol CHAR(20), pBanCac CHAR(1), pCac_Opt1_1 DECIMAL(5,2), pCac_Opt3_1 INTEGER, pArea CHAR(2), pStatus CHAR(2), pCausa CHAR(3), pProducto CHAR(4), pUsuario CHAR(10))
RETURNING
          CHAR(6),          -- Codigo de Retorno
          INTEGER           -- Total de Registros

DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);
DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;
DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);
DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);
DEFINE cFecha                  CHAR(10);
DEFINE cCausa				   CHAR(3);
DEFINE dECValor1			   DECIMAL(5,2);
DEFINE dECValor2			   DECIMAL(5,2);
DEFINE dMACValor1			   DECIMAL(5,2);
DEFINE dMACValor2			   DECIMAL(5,2);
DEFINE dPSValor1			   DECIMAL(5,2);
DEFINE dPSValor2			   DECIMAL(5,2);

DEFINE iMeseshist              INTEGER;
DEFINE cProducto               CHAR(4);
DEFINE iNumRegistros    	   INTEGER;


LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;

LET cNombreCte                 = '';
LET cRFC                       = '';

LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;

LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';

LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';

LET cFecha                     = '';
LET cCausa					   = '';
LET dECValor1				   = 0.0;
LET dECValor2				   = 0.0;
LET dMACValor1				   = 0.0;
LET dMACValor2				   = 0.0;
LET dPSValor1				   = 0.0;
LET dPSValor2				   = 0.0;
LET iMeseshist                 = 0;
LET cProducto                  = "";
LET iNumRegistros         	   = 0;

-- ** HISTORIAL DE CAMBIOS ** --
--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.
-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la seleccion principal los 3 tipos de consulta
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
--
--Autor Mohamed Carreon
--07/06/ 2010
--Comentarios: se agrego la causa del status y los filtros para los criterios del cac y mc.
--Autor: Viridiana Osobampo Aguilar
--24/01/ 2011
--Comentarios: Se modifica para que la validacion de eficiencia, meses de historia y puntuacion scoring
--                        solo se realice cuando se trate de una consulta por CAC o MC.

--AUTOR: L. Montserrat LeÃ³n Amador
--FECHA: 19/09/2019
--DESCRIPCION: Se modifica SPL para implementar la eliminaciÃ³n de registros de la tabla paso1 (que ahora es fÃ­sica) a partir del indice id_registro.

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, iNumRegistros;
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!

--SET DEBUG FILE TO '/tmp/mfinis/sp_consultas_CAC_central.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizÃ³ la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor
           INTO cFecha
           FROM bdicred:"informix".sd_param
          WHERE cod_param='030';
     LET pFechaInicial=DATE(cFecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;

--IF pArea <> '' THEN
--- >>> POR CAC O MC <<< ---
---  OBTIENE LOS CRITERIOS DE EFICIENCIA COPPEL

  --  SELECT valor1,valor2
    --  INTO dECValor1,dECValor2
      --FROM bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "01";

---  OBTIENE LOS CRITERIOS DE MESES DE HISTORIA COPPEL
    --SELECT valor1,valor2
    --  INTO dMACValor1,dMACValor2
      --FROM  bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "02";

---  OBTIENE LOS CRITERIOS DE PUNTUACION DE SCORING
  --  SELECT valor1,valor2
      --INTO dPSValor1,dPSValor2
      --FROM  bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "03";
--END IF;
	
	-- SE LIMPIA TABLA POR USUARIO Y PROCESO
	SET LOCK MODE TO WAIT 3;
	DELETE FROM bdicnweb:"informix".paso1
	WHERE usuario = TRIM(pUsuario);

IF NVL(pNumSol,"")  <> "" THEN 
	FOREACH
		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- NÃºmero de Solicitud
				sol.numcte,                -- NÃºmero Cte
				sol.sucursal,              -- Sucursal
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.monto_solicitado,      -- Monto Solicitado
				sol.fecha_insert,          -- Fecha Insert
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima AutorizaciÃ³n
					 THEN NVL(aut.fecha_entrada,date(1))
					 ELSE NVL(esp.fecha_modif,date(1))
				END),
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de AutorizaciÃ³n
					 THEN NVL(aut.comentario,"")
					 ELSE NVL(esp.comentario,"")
				END),
				NVL(aut.revision_cac,0),
			aut.causa_solicitud,
			sol.num_producto
		   INTO cNumSolicitud,
				cNumCte,
				cSucursal,
				cStatusSol,
				cTipoSolicitud,
				dMontoSolicitado,
				dtFechaInsert,
				dtFechaModificacion,
				cComentarioAut,
				iRevisionCac,
				cCausa,
				cProducto
		  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON aut.num_solicitud= sol.num_solicitud
															  AND aut.empresa= sol.empresa
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.rowid=(SELECT MAX(aut_aux.rowid)
																					   FROM bdisolic:"informix".ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa
																					   AND aut_aux.num_solicitud= sol.num_solicitud
																					   AND aut_aux.status_solicitud= sol.status_solicitud)
															  AND aut.ejecutivo_auto= aut.ejecutivo_auto
															  AND aut.revision_cac = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
															  AND aut.status_solicitud = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)
															  AND aut.causa_solicitud = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa
																	   AND esp.num_solicitud= sol.num_solicitud
																	   AND esp.numcte=sol.numcte
																	   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0)
																							 FROM bdisolic:"informix".ss_autorizacion_especial AS esp_aux
																							WHERE esp_aux.empresa= sol.empresa
																							  AND esp_aux.num_solicitud= sol.num_solicitud
																							  AND esp_aux.numcte= sol.numcte)
																	   AND sol.status_solicitud= esp.status_nvo)
		  ---Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
		--LEFT OUTER JOIN bdicred:"informix".sd_criterios_status_causa_cac cri ON (aut.status_solicitud = cri.status AND aut.causa_solicitud = cri.causa AND cri.id_area = pArea)
		 WHERE sol.num_solicitud=  pNumSol
		   AND sol.empresa= pEmpresa
		   AND sol.status_solicitud = (CASE WHEN pBanCac = 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opciÃ³n de la consulta es CAC, si es asi tendrian que ser solo status "RT"
		   AND sol.status_solicitud NOT IN ("PC","AN")
--		   AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
		   AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
		   AND (sol.fecha_insert >= (CASE WHEN pFechaInicial IS NULL THEN sol.fecha_insert ELSE pFechaInicial END)
				AND  sol.fecha_insert <= (CASE WHEN pFechaFinal IS NULL THEN sol.fecha_insert ELSE pFechaFinal END))
			--AND NVL(cri.id_area,'') = DECODE(pArea,'',NVL(cri.id_area,''),pArea)
--			AND NVL(sol.num_producto,'') = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
			AND sol.num_producto = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
--			AND NVL(aut.status_solicitud,'') = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)			
--			AND NVL(aut.causa_solicitud,'') = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)

		-- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
		-- En caso contrario no se mostraria en la consulta.

		   IF cStatusSol IN ('CC','BC') THEN
				SELECT COUNT(*)
				  INTO iInfoBuro
				  FROM bdiburo:"informix".br_traslado AS tras
				  INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud = reg.num_solicitud)
				  WHERE tras.num_solicitud = cNumSolicitud;
				  
				IF NVL(iInfoBuro,0) = 0 THEN
					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras 
					INNER JOIN bdiburo:"informix".br_respuesta_aprocesar AS res ON (tras.num_solicitud = res.num_solicitud) 
					WHERE tras.num_solicitud = cNumSolicitud;
				  
					IF NVL(iInfoBuro,0) = 0 THEN
						SELECT COUNT(*)
						INTO iInfoBuro
						FROM bdiburo:"informix".br_traslado AS tras 
						INNER JOIN bdiburo:"informix".sb_regreso_2013 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud) 
						WHERE tras.num_solicitud = cNumSolicitud;

						IF NVL(iInfoBuro,0) = 0 THEN
						   CONTINUE FOREACH;
						END IF;

					END IF;
				END IF;

				 IF NVL(iInfoBuro,0) = 0 THEN

					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras
					INNER JOIN bdiburo:"informix".sb_regreso_2011 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud)
					WHERE tras.num_solicitud = cNumSolicitud;

					IF NVL(iInfoBuro,0) = 0 THEN
					   CONTINUE FOREACH;
					END IF;

				 END IF;

		   END IF;

		-- Se obtienen los datos de la informaciÃ³n crediticia en COPPEL/BANCOPPEL.

				   SELECT ef.situacion_pago,         -- Situacion Pago
						   ef.meses_historia          -- Meses Historia
					  INTO dSituacionPago,
						   iMesesHistoria
					  FROM bdisolic:"informix".ss_resum_scor_fin AS ef
					 WHERE ef.empresa= pEmpresa
					   AND ef.num_solicitud= cNumSolicitud;
					   
					   -- SE VALIDA QUE EL PRODUCTO NO SEA DE REESTRUCTURA DE TARJETAS DE CRÃDITO

					--  IF (dSituacionPago IS NULL AND iMesesHistoria IS NULL) AND NVL(cProducto,'') <> '6011' THEN
						--CONTINUE FOREACH;
					  --END IF;

					--IF NVL(pArea, "") <> "" THEN
						  --IF NOT ((dSituacionPago >= dECValor1 AND dSituacionPago <= dECValor2) AND
								   --(iMesesHistoria >= dMACValor1 AND iMesesHistoria <=dMACValor2)) AND NVL(cProducto,'') <> '6011' THEN

								--CONTINUE FOREACH;
					  --END IF;

					--END IF;
		-- Se obtiene las puntuaciones del scoring que se le realizÃ³ al cliente.
		SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
			   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
			   NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
			   COUNT(num_solicitud) AS cantidad
		  INTO dSeccion1,    
			   dSeccion2,
			   dSumaSecciones,
			   iCantidad
		  FROM bdisolic:"informix".ss_resumen_scoring
		 WHERE empresa= pEmpresa
		   AND num_solicitud = cNumSolicitud
		   AND seccion IN ('1','2');

		IF iCantidad <> 2 THEN

			   LET dSeccion1= 0;
			   LET dSeccion2= 0;
			   LET dSumaSecciones= 0;

			SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
				   COUNT(*) AS cuantos
			  INTO dSeccion1, icuantos
			  FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:"informix".ss_resum_scor_fin rsf
			 WHERE rsf.empresa = pEmpresa
			   AND rsf.num_solicitud = cNumSolicitud
			   AND rsf.empresa = sf.empresa
			   AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
			   AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
			   AND sf.min_mes_hist <= rsf.meses_historia
			   AND sf.max_mes_hist >= rsf.meses_historia
			   AND sf.min_porc_pago <= rsf.situacion_pago
			   AND sf.max_porc_pago >= rsf.situacion_pago;

		   FOREACH
				SELECT sg.empresa, sg.seccion,
					   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
				  INTO cEmpAux, iSecAux, dSeccionAux
				  FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg
				 WHERE sg.empresa = dc.empresa
				   AND sg.grupo = dc.grupo
				   AND sg.seccion = dc.seccion
				   AND dc.num_solicitud = cNumSolicitud
				   AND dc.seccion = '2'
				   AND dc.empresa = pEmpresa
			  GROUP BY sg.empresa, sg.seccion, sg.agrupar

				LET dSeccion2= dSeccion2 + dSeccionAux;
				LET dSumaSecciones= dSeccion1 + dSeccion2;
	   END FOREACH;

	   END IF;

	   --IF NVL(pArea,"") <> "" THEN
			--IF NOT (dSumaSecciones >= dPSValor1 AND dSumaSecciones <= dPSValor2) AND NVL(cProducto,'') <> '6011' THEN
					--CONTINUE FOREACH;
			--END IF;
	   --END IF;

	 -- Se obtiene el nombre del cliente
		SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
												  TRIM(nvl(a.nombre2,'')) ||' '||
												  TRIM(nvl(a.apell_paterno,'')) ||' '||
												  TRIM(nvl(a.apell_materno,'')),
												  TRIM(a.razon_social)),
			   rfc
		  INTO cNombreCte, cRFC
		  FROM bdinteg:"informix".si_cliente a
		 WHERE a.numcte = cNumCte;

			--RQM 08 008 JMAH
	IF TRIM(cStatusSol) = "AT"  THEN
		
		IF EXISTS (SELECT num_credito FROM bdisolic:"informix".ss_solautorizadasgte WHERE num_credito =cNumSolicitud) THEN
			LET cComentarioAut = "Solicitud Autorizada GTE"||"-"||TRIM(cComentarioAut);
		END IF	
	END IF
		INSERT INTO bdicnweb:"informix".paso1(num_solicitud, num_cte, nombre_cte, rfc, sucursal, fecha_solic, fecha_cambio_stsuts, importe_linea, eficiencia, historial, puntos_seccion, puntos_2da_seccion, status_solicitud, observaciones_ant, suma_secciones, causas_status, usuario) 
			VALUES(NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
			   NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,''), pUsuario);

	END FOREACH;

ELSE
	FOREACH
		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- NÃºmero de Solicitud
				sol.numcte,                -- NÃºmero Cte
				sol.sucursal,              -- Sucursal
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.monto_solicitado,      -- Monto Solicitado
				sol.fecha_insert,          -- Fecha Insert
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima AutorizaciÃ³n
					 THEN NVL(aut.fecha_entrada,date(1))
					 ELSE NVL(esp.fecha_modif,date(1))
				END),
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de AutorizaciÃ³n
					 THEN NVL(aut.comentario,"")
					 ELSE NVL(esp.comentario,"")
				END),
				NVL(aut.revision_cac,0),
			aut.causa_solicitud,
			sol.num_producto
		   INTO cNumSolicitud,
				cNumCte,
				cSucursal,
				cStatusSol,
				cTipoSolicitud,
				dMontoSolicitado,
				dtFechaInsert,
				dtFechaModificacion,
				cComentarioAut,
				iRevisionCac,
				cCausa,
				cProducto
		  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud
															  AND aut.empresa= sol.empresa
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.rowid=(SELECT MAX(aut_aux.rowid)
																					   FROM bdisolic:"informix".ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa
																					   AND aut_aux.num_solicitud= sol.num_solicitud
																					   AND aut_aux.status_solicitud= sol.status_solicitud)
															  AND aut.ejecutivo_auto= aut.ejecutivo_auto)
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa
																	   AND esp.num_solicitud= sol.num_solicitud
																	   AND esp.numcte=sol.numcte
																	   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0)
																							 FROM bdisolic:"informix".ss_autorizacion_especial AS esp_aux
																							WHERE esp_aux.empresa= sol.empresa
																							  AND esp_aux.num_solicitud= sol.num_solicitud
																							  AND esp_aux.numcte= sol.numcte)
																	   AND sol.status_solicitud= esp.status_nvo)
		  --Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
		--LEFT OUTER JOIN bdicred:"informix".sd_criterios_status_causa_cac cri ON (aut.status_solicitud = cri.status AND aut.causa_solicitud = cri.causa AND cri.id_area = pArea)
		 WHERE sol.num_solicitud=  sol.num_solicitud 
		   AND sol.empresa= pEmpresa
		   AND sol.status_solicitud = (CASE WHEN pBanCac = 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opciÃ³n de la consulta es CAC, si es asi tendrian que ser solo status "RT"
		   AND sol.status_solicitud NOT IN ("PC","AN")
		   AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
		   AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
		   AND (sol.fecha_insert >= pFechaInicial AND  sol.fecha_insert <= pFechaFinal )
			--AND NVL(cri.id_area,'') = DECODE(pArea,'',NVL(cri.id_area,''),pArea)

			AND NVL(sol.num_producto,'') = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
			AND NVL(aut.status_solicitud,'') = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)
			AND NVL(aut.causa_solicitud,'') = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)

		-- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
		-- En caso contrario no se mostraria en la consulta.

		   IF cStatusSol IN ('CC','BC') THEN
				SELECT COUNT(*)
				  INTO iInfoBuro
				  FROM bdiburo:"informix".br_traslado AS tras
				  INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud = reg.num_solicitud)
				  WHERE tras.num_solicitud = cNumSolicitud;

				IF NVL(iInfoBuro,0) = 0 THEN
					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras 
					INNER JOIN bdiburo:"informix".br_respuesta_aprocesar AS res ON (tras.num_solicitud = res.num_solicitud) 
					WHERE tras.num_solicitud = cNumSolicitud;
					
					IF NVL(iInfoBuro,0) = 0 THEN

						SELECT COUNT(*)
						INTO iInfoBuro
						FROM bdiburo:"informix".br_traslado AS tras 
						INNER JOIN bdiburo:"informix".sb_regreso_2013 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud) 
						WHERE tras.num_solicitud = cNumSolicitud;

						IF NVL(iInfoBuro,0) = 0 THEN
						   CONTINUE FOREACH;
						END IF;

					END IF;
				END IF;
				
				 IF NVL(iInfoBuro,0) = 0 THEN

					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras
					INNER JOIN bdiburo:"informix".sb_regreso_2011 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud)
					WHERE tras.num_solicitud = cNumSolicitud;

					IF NVL(iInfoBuro,0) = 0 THEN
					   CONTINUE FOREACH;
					END IF;

				 END IF;

		   END IF;

		-- Se obtienen los datos de la informaciÃ³n crediticia en COPPEL/BANCOPPEL.

				   SELECT ef.situacion_pago,         -- Situacion Pago
						   ef.meses_historia          -- Meses Historia
					  INTO dSituacionPago,
						   iMesesHistoria
					  FROM bdisolic:"informix".ss_resum_scor_fin AS ef
					 WHERE ef.empresa= pEmpresa
					   AND ef.num_solicitud= cNumSolicitud;
					   
					   -- SE VALIDA QUE EL PRODUCTO NO SEA DE REESTRUCTURA DE TARJETAS DE CRÃDITO

					 -- IF (dSituacionPago IS NULL AND iMesesHistoria IS NULL) AND NVL(cProducto,'') <> '6011' THEN
						--CONTINUE FOREACH;
					  --END IF;

					--IF NVL(pArea, "") <> "" THEN

						--  IF NOT ((dSituacionPago >= dECValor1 AND dSituacionPago <= dECValor2) AND
							--	   (iMesesHistoria >= dMACValor1 AND iMesesHistoria <=dMACValor2)) AND NVL(cProducto,'') <> '6011' THEN

								--CONTINUE FOREACH;
					  --END IF;

					--END IF;
		-- Se obtiene las puntuaciones del scoring que se le realizÃ³ al cliente.
		SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
			   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
			   NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
			   COUNT(num_solicitud) AS cantidad
		  INTO dSeccion1,    
			   dSeccion2,
			   dSumaSecciones,
			   iCantidad
		  FROM bdisolic:"informix".ss_resumen_scoring
		 WHERE empresa= pEmpresa
		   AND num_solicitud = cNumSolicitud
		   AND seccion IN ('1','2');

		IF iCantidad <> 2 THEN

			   LET dSeccion1= 0;
			   LET dSeccion2= 0;
			   LET dSumaSecciones= 0;

			SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
				   COUNT(*) AS cuantos
			  INTO dSeccion1, icuantos
			  FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:"informix".ss_resum_scor_fin rsf
			 WHERE rsf.empresa = pEmpresa
			   AND rsf.num_solicitud = cNumSolicitud
			   AND rsf.empresa = sf.empresa
			   AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
			   AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
			   AND sf.min_mes_hist <= rsf.meses_historia
			   AND sf.max_mes_hist >= rsf.meses_historia
			   AND sf.min_porc_pago <= rsf.situacion_pago
			   AND sf.max_porc_pago >= rsf.situacion_pago;

		   FOREACH
				SELECT sg.empresa, sg.seccion,
					   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
				  INTO cEmpAux, iSecAux, dSeccionAux
				  FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg
				 WHERE sg.empresa = dc.empresa
				   AND sg.grupo = dc.grupo
				   AND sg.seccion = dc.seccion
				   AND dc.num_solicitud = cNumSolicitud
				   AND dc.seccion = '2'
				   AND dc.empresa = pEmpresa
			  GROUP BY sg.empresa, sg.seccion, sg.agrupar

				LET dSeccion2= dSeccion2 + dSeccionAux;
				LET dSumaSecciones= dSeccion1 + dSeccion2;
	   END FOREACH;

	   END IF;

	   --IF NVL(pArea,"") <> "" THEN
		--	IF NOT (dSumaSecciones >= dPSValor1 AND dSumaSecciones <= dPSValor2) AND NVL(cProducto,'') <> '6011' THEN
					--CONTINUE FOREACH;
			--END IF;
	   ---END IF;

	 -- Se obtiene el nombre del cliente
		SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
												  TRIM(nvl(a.nombre2,'')) ||' '||
												  TRIM(nvl(a.apell_paterno,'')) ||' '||
												  TRIM(nvl(a.apell_materno,'')),
												  TRIM(a.razon_social)),
			   rfc
		  INTO cNombreCte, cRFC
		  FROM bdinteg:"informix".si_cliente a
		 WHERE a.numcte = cNumCte;

			--RQM 08 008 JMAH
	IF TRIM(cStatusSol) = "AT"  THEN
		
		IF EXISTS (SELECT num_credito FROM bdisolic:"informix".ss_solautorizadasgte WHERE num_credito =cNumSolicitud) THEN
			LET cComentarioAut = "Solicitud Autorizada GTE"||"-"||TRIM(cComentarioAut);
		END IF	
	END IF
	
		INSERT INTO bdicnweb:"informix".paso1(num_solicitud, num_cte, nombre_cte, rfc, sucursal, fecha_solic, fecha_cambio_stsuts, importe_linea, eficiencia, historial, puntos_seccion, puntos_2da_seccion, status_solicitud, observaciones_ant, suma_secciones, causas_status, usuario) 
			VALUES(NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
			   NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,''), pUsuario);

	END FOREACH;
END IF

	SELECT COUNT (*) 
	INTO iNumRegistros
	FROM bdicnweb:"informix".paso1 
	WHERE usuario = pUsuario;

	RETURN NVL(cCodRet,''), NVL(iNumRegistros,0);

END
END PROCEDURE;