CREATE PROCEDURE "informix".sp_reportecargosreversoctasmasivocre(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionPadre char(10), pFechaInicio date, pFechaFin date, 
        pArchDescarga CHAR(150), pLote int, pUsuarioC char(8))
        returning CHAR(5) as codret;
        
        DEFINE cCodRet CHAR(5);
		DEFINE cCodRetSp CHAR(5);
        DEFINE iSqlErr INT;
        DEFINE iExiste INT;
        DEFINE cCmd1 CHAR(1600);
        DEFINE cCmd2 CHAR(1600);
        DEFINE cCmd3 CHAR(1600);
        DEFINE cCmd4 CHAR(1600);
        DEFINE cUser CHAR(8);
        
        LET cCodRet = '00000';
		LET cCodRetSp = '';
        LET iSqlErr = 0;
        LET iExiste = 0;
        LET cCmd1 = '';
        LET cCmd2 = '';
        LET cCmd3 = '';
        LET cCmd4 = '';
        LET cUser = pIdUsuario;
        
        BEGIN
        
			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet;
			END EXCEPTION;
			
			IF pIdUsuario = '' OR pIdFuncion = '' OR pFechaInicio = '' OR pFechaFin = '' OR pArchDescarga = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet;
			END IF;
			
			EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pIdUsuario, pIdFuncion) INTO cCodRet;
			IF cCodRet <> '00000' THEN
					RETURN cCodRet;
			END IF;
			
			LET cCmd1 = "select a.id_registro";
			LET cCmd2 = " from ((((((bdicnweb:sw_tr_cargamasiva_cargo_hist a LEFT JOIN bdicnweb:sw_tr_totales_masivo b ON b.id_lote = a.lote and b.id_funcion = a.id_funcion) LEFT JOIN bdinteg:si_cliente c ON c.numcte = a.numcte) LEFT JOIN bdicred:sd_maecred d ON d.num_credito = a.cuenta) LEFT JOIN bdinteg:si_sucursales e ON e.sucursal = d.sucursal) LEFT JOIN bdicred:sd_definicion f ON f.num_producto = d.num_producto) LEFT JOIN bdicred:sd_tipocartera g ON g.status_cred = d.status_cred) LEFT JOIN bdicred:sd_bitacora_cargos h ON h.folio = a.folio AND h.reverso = 'S' where a.id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(a.fecha_carga) between '"||pFechaInicio||"' AND '"||pFechaFin||"'";
			
			IF pLote IS NOT NULL THEN
					LET cCmd2 = " "||TRIM(cCmd2)||" AND a.lote = "||pLote;
			END IF;
			IF pUsuarioC <> '' THEN
					LET cCmd2 = " "||TRIM(cCmd2)||" AND a.usuario = '"||TRIM(pUsuarioC)||"'";
					LET cUser = pUsuarioC;
			END IF;
			IF pLote IS NULL OR pUsuarioC = '' THEN
					LET cCmd2 = " "||TRIM(cCmd2)||" AND lote in (select id_lote from bdicnweb:sw_tr_totales_masivo where id_funcion = '"||TRIM(pIdFuncionPadre)||"' and date(fecha_carga) between '"||pFechaInicio||"' and '"||pFechaFin||"' and usuario = '"||TRIM(cUser)||"')";
			END IF;
			
			PREPARE lotesQry FROM "select count(*) from ("||TRIM(TRIM(cCmd1)||cCmd2)||")";
			DECLARE lotesCur CURSOR FOR lotesQry;
			OPEN lotesCur;
			
			FETCH lotesCur INTO iExiste;
			
			CLOSE lotesCur;
			FREE lotesCur;
			FREE lotesQry;
			
			IF iExiste = 0 THEN
				LET cCodRet = '00151';
				RETURN cCodRet;
			END IF;
			
			LET cCmd1 = "select a.id_registro, a.lote, b.folio_grupo, a.numcte, nvl(trim(trim(trim(c.nombre1)||' '||trim(nombre2))||' '||trim(trim(apell_paterno)||' '||trim(apell_materno))),'') as nombre, a.cuenta, nvl(trim(trim(e.sucursal)||' '||trim(nombre)), '') as sucursal, nvl(trim(trim(f.num_producto)||' '||trim(f.nombre_prod)), '') as producto, nvl(trim(g.descripcion), '') as status, nvl((select fecha_cargo from bdicred:sd_bitacora_cargos aa where aa.num_credito = a.cuenta and aa.fecha_cargo = (select max(bb.fecha_cargo) from bdicred:sd_bitacora_cargos bb where bb.num_credito = aa.num_credito and bb.reverso = 'N') and aa.hora_cargo = (select max(cc.hora_cargo) from bdicred:sd_bitacora_cargos cc where cc.num_credito = aa.num_credito and fecha_cargo = (select max(bb.fecha_cargo) from bdicred:sd_bitacora_cargos bb where bb.num_credito = aa.num_credito and bb.reverso = 'N'))), '') as fecha_ult_mov, nvl(to_char(a.monto_importe, '#,###,###,###,##&.&&'), '') as monto_transaccion, trim(a.transaccion) as codigo_cargo, trim(a.descripcion1) as concepto_cargo, trim(a.resultado_reverso) as resultado, trim(a.codret_reverso) as codret, trim(a.comentario_reverso) as motivo_rechazo, trim(a.folio) as folio_operacion, nvl(to_char(date(a.fecha_reverso), '%d/%m/%Y'), '') as fecha_reverso, nvl(to_char(date(a.fecha_proceso), '%d/%m/%Y'), '') as fecha_operacion, nvl(to_char(h.cap_vig_ant, '#,###,###,###,##&.&&'), '') saldo_ante_reverso, nvl(to_char(h.cap_vig_pos, '#,###,###,###,##&.&&'), '') saldo_post_reverso, trim(a.descripcion2) as comentario";
			LET cCmd3 = "lote, folio_grupo, numcte, nombre, trim(cuenta), sucursal, producto, status, fecha_ult_mov, nvl(trim(to_char(monto_transaccion, '#,###,###,###,##&.&&')), '') as monto_transaccion, codigo_cargo, concepto_cargo, resultado, codret, motivo_rechazo, trim(folio_operacion), trim(fecha_reverso), fecha_operacion, trim(saldo_ante_reverso), trim(saldo_post_reverso), comentario";
			
			SYSTEM TRIM('/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(pArchDescarga)||' select '||TRIM(cCmd3)||' from ('||TRIM(TRIM(cCmd1)||cCmd2)||') order by id_registro;" | /ifxsif01/bin/dbaccess bdicnweb > /dev/null 2>&1');
			
			-- EjecuciÃ³n del SP para la carga de los encabezados
			EXECUTE PROCEDURE bdicnweb:"informix".sp_obtieneencabezadomasivo(pIdFuncionPadre, pArchDescarga) INTO cCodRetSp;
			IF cCodRetSp::INTEGER < 0 THEN
					RAISE EXCEPTION cCodRetSp::INTEGER, 0, '';
			END IF;
		
			RETURN cCodRet;
        END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 09/08/2013",
"DESCRIPCION: Generacion del reporte de las cuentas que fueron reversadas en el cargo masivo de la aplicacion CNWEB",
"FECHA: 15/01/2014",
"DESCRIPCION: Se agrega el procedimiento para agregar los encabezados al archivo final",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_sw_ro_consdireccion(pUsuario CHAR(8), pIdFunciON CHAR(10), pNumCliente CHAR(20), pTipoDirecciON INT)
	RETURNING CHAR(255) AS direccion,
		CHAR(15) AS tel_oficina
	DEFINE vcodret CHAR(5);
	DEFINE cnumcliente char (20);
	DEFINE vtipo_dir CHAR(1);
	DEFINE vsecuencia INT;
	DEFINE vcalle CHAR(40);
	DEFINE vnumeroextcalle  CHAR(10);
	DEFINE vnumerointcalle  CHAR(10);
	DEFINE vdepartamento  CHAR(6);
	DEFINE vcolonia CHAR(60);
	DEFINE vmunicipio CHAR(60);
	DEFINE vciudad CHAR(60);
	DEFINE vestado CHAR(30);
	DEFINE vpais CHAR(20);
	DEFINE vcod_postal CHAR(5);
	DEFINE vtelefono1 CHAR(13);
	DEFINE vtelefono2  CHAR(13);
	DEFINE vtelefono3  CHAR(13);
	DEFINE vextensiON CHAR(5);
	DEFINE vpuntocardinal  CHAR(1);
	DEFINE vmanzana CHAR(30);
	DEFINE votros  CHAR(30);
	DEFINE vandador CHAR(30);
	DEFINE vetapa CHAR(30);
	DEFINE vlote  CHAR(30);
	DEFINE ventrada  CHAR(30);
	DEFINE vedificio  CHAR(30);
	DEFINE ventre_calles CHAR(80);
	DEFINE vobservaciones CHAR(40);
	DEFINE ctipo_dom CHAR(15);
	DEFINE cDirecciON CHAR(255);
	DEFINE dfecha_insert DATE;
	LET cnumcliente= "";
	LET vtipo_dir = "";
	LET vsecuencia = 0 ;
	LET vcalle = "";
	LET vnumeroextcalle  = "";
	LET vnumerointcalle  = "";
	LET vdepartamento  = "";
	LET vcolonia = "";
	LET vmunicipio = "";
	LET vciudad = "";
	LET vestado = "";
	LET vpais = "";
	LET vcod_postal  = "";
	LET vtelefono1  = "";
	LET vtelefono2   = "";
	LET vtelefono3   = "";
	LET vextensiON  = "";
	LET vpuntocardinal   = "";
	LET vmanzana  = "";
	LET votros   = "";
	LET vandador  = "";
	LET vetapa  = "";
	LET vlote   = "";
	LET ventrada   = "";
	LET vedificio   = "";
	LET ventre_calles = "";
	LET vobservaciones = "";
	LET cDirecciON = '';
	LET dfecha_insert=TODAY;

	EXECUTE PROCEDURE bdinteg:sp_cnsif_consdirec(pusuario, pidfuncion, pnumcliente, '1', 
												ptipodireccion, '0', '25')
	INTO vcodret,cnumcliente,vtipo_dir,
			vsecuencia,vcalle,vnumeroextcalle,vnumerointcalle,
			vdepartamento,vcolonia,vmunicipio,vciudad,
			vestado,vpais,vcod_postal,vtelefono1,
			vtelefono2,vtelefono3,vextension,vpuntocardinal,
			vmanzana,votros,vandador,vetapa,
			vlote,ventrada,vedificio,vobservaciones,
			ventre_calles,ctipo_dom,dfecha_insert;
	IF TRIM(vcalle) <> '' AND vcalle is not null THEN
		LET cDirecciON = TRIM(cDireccion||'CALLE '||TRIM(vcalle));
	END IF;
	IF TRIM(vnumeroextcalle) <> '' AND vnumeroextcalle is not null THEN
		LET cDirecciON = TRIM(TRIM(cDireccion)||' NO. '||TRIM(vnumeroextcalle));
	END IF;
	IF vnumerointcalle <> '' AND vnumerointcalle is not null THEN
		LET cDirecciON = TRIM(TRIM(cDireccion)||' INT. '||TRIM(vnumerointcalle));
	END IF;
	IF TRIM(vedificio) <> '' AND vedificio is not null THEN
		LET cDirecciON = TRIM(TRIM(cDireccion)||', EDIF. '||TRIM(vedificio));
	END IF;
	IF TRIM(vdepartamento) <> '' AND vdepartamento is not null THEN
		LET cDirecciON = TRIM(TRIM(cDireccion)||', DEPTO. '||TRIM(vdepartamento));
	END IF;
	IF TRIM(vcolonia) <> '' AND vcolonia is not null THEN
		LET cDirecciON = TRIM(TRIM(cDireccion)||', COL. '||TRIM(vcolonia));
	END IF;
	IF TRIM(vmunicipio) <> '' AND vmunicipio is not null THEN
		LET cDirecciON = TRIM(TRIM(cDireccion)||', '||TRIM(vmunicipio));
	END IF;
	IF TRIM(vciudad) <> '' AND vciudad is not null THEN
		LET cDirecciON = TRIM(TRIM(cDireccion)||', '||TRIM(vciudad));
	END IF;
	IF TRIM(vestado) <> '' AND vestado is not null THEN
		LET cDirecciON = TRIM(TRIM(cDireccion)||', '||TRIM(vestado));
	END IF;
	IF TRIM(vcod_postal) <> '' AND vcod_postal is not null THEN
		LET cDirecciON = TRIM(TRIM(cDireccion)||', C.P. '||TRIM(vcod_postal));
	END IF;
	RETURN TRIM(cDireccion), vtelefono1;
END PROCEDURE;