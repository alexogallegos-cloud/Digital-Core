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