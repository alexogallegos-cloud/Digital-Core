CREATE PROCEDURE "informix".sp_afore_ctes_cpl(pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd CHAR(3),
											  pcUsuario CHAR(8),
											  pcPassword CHAR(8),
											  pcIp_origen CHAR(15),
											  pcSession_id CHAR(30),
											  pcFecha_peticion CHAR(8),
											  pcHora_peticion CHAR(6),
											  aPaterno CHAR(40), 
											  aMaterno CHAR(40), 
											  sNombre1 CHAR(52), 
											  sNombre2 CHAR(52), 
											  cFecha_nacimiento DATE, 
											  cEntidad_nacimiento SMALLINT, 
											  cGenero CHAR(1))
											  

RETURNING  CHAR(5) AS cCodRet,CHAR(4) AS cOpcode,CHAR(100) AS cDescr_completa_mensaje,CHAR(8) AS cFecha_proceso,CHAR(6) AS cHora_proceso
,CHAR(4) AS cCodDoctoAnv,CHAR(4) AS iSecuenciaAnv,CHAR(4) AS cCodDoctoRev,CHAR(4) AS iSecuenciaRev
,CHAR(18) AS cCurp,CHAR(40) AS cApellPaterno,CHAR(40) AS cApellMaterno,CHAR(52) AS cNombre1,CHAR(52) AS cNombre2,CHAR(13) AS cRfc,DATE AS dFechaNac,SMALLINT AS cEntidadNac,CHAR(1) AS cSexo,SMALLINT AS cNacionalidad,CHAR(1) AS cEdoCivil,CHAR(20) AS cNumCteCpl,CHAR(20) AS cNumCte
,SMALLINT AS cEscolaridad,SMALLINT AS cProfesion,SMALLINT AS cActividad
,CHAR(10) AS cTel1,CHAR(10) AS cTel2,CHAR(50) AS cEmail
,CHAR(65) AS cCalle1,CHAR(15) AS cNumExt1,CHAR(15) AS cNumInt1,CHAR(5) AS cCodPostal1,INTEGER AS cColonia1,INTEGER AS iCiudad1,INTEGER AS cMunicipio1,INTEGER AS cEstado1,CHAR(3) AS cPais1
,CHAR(65) AS cCalle2,CHAR(15) AS cNumExt2,CHAR(15) AS cNumInt2,CHAR(5) AS cCodPostal2,INTEGER AS cColonia2,INTEGER AS iCiudad2,INTEGER AS cMunicipio2,INTEGER AS cEstado2,CHAR(3) AS cPais2
,CHAR(40) AS cApellPaternoRef1,CHAR(40) AS cApellMaternoRef1,CHAR(40) AS cNombresRef1,CHAR(40) AS cApellPaternoRef2,CHAR(40) AS cApellMaternoRef2,CHAR(40) AS cNombresRef2,CHAR(40) AS filler1,CHAR(40) AS filler2
,CHAR(1) AS cEfectivaAct, CHAR(1) AS cNomina, CHAR(1) AS divideCadena;

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE vsMensaje        CHAR(200);
DEFINE cCodRet 			CHAR(4);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(255);
DEFINE cDescr_completa_mensaje 	CHAR(80);
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE cCadena_ent		CHAR(100);
DEFINE cAgent_cd		CHAR(3);
DEFINE cUsuario			CHAR(8);
DEFINE cPassword		CHAR(8);
DEFINE cIp_origen		CHAR(15);
DEFINE cId_sesion_act	CHAR(30);
DEFINE cNombre_proceso	CHAR(17);
DEFINE cCod_retorno		CHAR(5);
DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;
DEFINE cEfectivaAct     CHAR(20);
DEFINE cNomina          CHAR(20);

--definicion de Variables de consulta de informacion
DEFINE cNombre CHAR(40);
DEFINE iBan INTEGER;
DEFINE cMultiImg CHAR(1);
DEFINE cCurp CHAR(18);
DEFINE cApellPaterno CHAR(26);
DEFINE cApellMaterno CHAR(26);
DEFINE cNombre1 CHAR(26);
DEFINE cNombre2 CHAR(26);
DEFINE cNombres	CHAR(52);
DEFINE cRfc CHAR(13);
DEFINE dFechaNac DATE;
DEFINE cEntidadNac CHAR(2);
DEFINE cSexo CHAR(1);
DEFINE cNacionalidad CHAR(3);
DEFINE cEdoCivil CHAR(2);
DEFINE cNumCte CHAR(20);
DEFINE cEscolaridad CHAR(2);
DEFINE cProfesion CHAR(4);
DEFINE cActividad CHAR(30);
DEFINE cTel1 CHAR(10);
DEFINE cTel2 CHAR(10);
DEFINE cEmail CHAR(100);
DEFINE cCalle1 CHAR(30);
DEFINE cNumExt1 CHAR(10);
DEFINE cNumInt1 CHAR(10);
DEFINE cCodPostal1 CHAR(5);
DEFINE cColonia1 CHAR(32);
DEFINE cMunicipio1 CHAR(5);
DEFINE iCiudad1	SMALLINT;
DEFINE cEstado1 CHAR(2);
DEFINE cPais1 CHAR(3);
DEFINE cCalle2 CHAR(30);
DEFINE cNumExt2 CHAR(10);
DEFINE cNumInt2 CHAR(10);
DEFINE cCodPostal2 CHAR(5);
DEFINE cColonia2 CHAR(32);
DEFINE cMunicipio2 CHAR(5);
DEFINE iCiudad2	SMALLINT;
DEFINE cEstado2 CHAR(2);
DEFINE cPais2 CHAR(3);
DEFINE cApellPaternoRef1 CHAR(26);
DEFINE cApellMaternoRef1 CHAR(26);
DEFINE cNombresRef1 CHAR(52);
DEFINE cNombre1Ref1 CHAR(26);
DEFINE cNombre2Ref1 CHAR(26);
DEFINE cApellPaternoRef2 CHAR(26);
DEFINE cApellMaternoRef2 CHAR(26);
DEFINE cNombre1Ref2 CHAR(26);
DEFINE cNombre2Ref2 CHAR(26);
DEFINE cNombresRef2 CHAR(52);
DEFINE cNomBene1 CHAR(40);
DEFINE cNomBene2 CHAR(40);
DEFINE cCodDoctoAnv CHAR(4);
DEFINE iSecuenciaAnv CHAR(4);
DEFINE cCodDoctoRev CHAR(4);
DEFINE iSecuenciaRev CHAR(4);
DEFINE cPuesto INTEGER;
DEFINE cSubPuesto INTEGER;
DEFINE cCodDocto CHAR(4);
DEFINE iSecuencia SMALLINT;
DEFINE cDescrip2 CHAR(30);
DEFINE sFlag INTEGER;
DEFINE rfc CHAR(13);
DEFINE filler1 CHAR(40);
DEFINE filler2 CHAR(40);
DEFINE divideCadena CHAR(1);
DEFINE cNumCteCoppel CHAR(20);
DEFINE numCuentaCte CHAR(20);
DEFINE cApellPaternoBen CHAR(40);
DEFINE cApellMaternoBen CHAR(40);
DEFINE cNombre1Ben CHAR(40);
DEFINE cNombre2Ben CHAR(40);
DEFINE cCuentaClientes INTEGER;



--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCodRet = '0000';
LET cOpcode = '0000';
LET cDescr_mensaje = 'Consulta Exitosa.';
LET cDescr_completa_mensaje = 'Consulta Exitosa.';


LET cFecha_proceso = trim(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));

LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = '';
LET cAgent_cd = '';
LET cUsuario = '';
LET cPassword = '';
LET cIp_origen = '';
LET cId_sesion_act = '';
LET cNombre_proceso = 'sp_ws_afore_cctes';
LET cCod_retorno  = '';
LET cFecha_dia    = '';
LET dtFecha_dia   = CURRENT::DATE;
LET vsMensaje     = '';


--Inicializacion de Variables de consulta de informacion
LET cNombre = '';
LET iBan = 0;
LET cMultiImg = '';
LET cCodRet = '0000';
LET cCurp = '';
LET cApellPaterno = '';
LET cApellMaterno = '';
LET cNombre1 = '';
LET cNombre2 = '';
LET cNombres = '';
LET cRfc = '';
LET dFechaNac = DATE(1);
LET cEntidadNac = '';
LET cSexo = '';
LET cNacionalidad = '';
LET cEdoCivil = '';
LET cNumCte = '';
LET cEscolaridad = '';
LET cProfesion = '';
LET cActividad = '';
LET cTel1 = '';
LET cTel2 = '';
LET cEmail = '';
LET cCalle1 = '';
LET cNumExt1 = '';
LET cNumInt1 = '';
LET cCodPostal1 = '';
LET cColonia1 = '';
LET cMunicipio1 = '';
LET iCiudad1 = 0;
LET cEstado1 = '';
LET cPais1 = '';
LET cCalle2 = '';
LET cNumExt2 = '';
LET cNumInt2 = '';
LET cCodPostal2 = '';
LET cColonia2 = '';
LET cMunicipio2 = '';
LET iCiudad2 = 0;
LET cEstado2 = '';
LET cPais2 = '';
LET cApellPaternoRef1 = '';
LET cApellMaternoRef1 = '';
LET cNombre1Ref1 = '';
LET cNombre2Ref1 = '';
LET cNombresRef1 = '';
LET cApellPaternoRef2 = '';
LET cApellMaternoRef2 = '';
LET cNombre1Ref2 = '';
LET cNombre2Ref2 = '';
LET cNombresRef2 = '';
LET cNomBene1 = '';
LET cNomBene2 = '';
LET cCodDoctoAnv = '';
LET iSecuenciaAnv = 0;
LET cCodDoctoRev = '';
LET iSecuenciaRev = 0;
LET cPuesto = 0;
LET cSubPuesto = 0;
LET iSecuencia = 0;
LET cCodDocto = '';
LET cDescrip2 = '';
LET sFlag = 0;
LET filler1 = '';
LET filler2 = '';
LET cEfectivaAct = '';
LET cNomina = '';
LET divideCadena = '|';
LET cNumCteCoppel = '';
LET numCuentaCte = '';
LET cApellPaternoBen = '';
LET cApellMaternoBen = '';
LET cNombre1Ben = '';
LET cNombre2Ben = '';


BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError,vsMensaje
		
		IF iSqlErr <> 0 THEN
			
			INSERT INTO "informix".si_ws_afore_ctes(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,numcte_request,opcode,descr_message,date_process,time_process,curp,apellpaterno,apellmaterno,nombres,rfc,fechanac,entidadnac,sexo,nacionalidad,edocivil,numcte,escolaridad,profesion,actividad,tel1,tel2,email,calle1,numext1,numint1,codpostal1,colonia1,municipio1,ciudad1,estado1,pais1,calle2,numext2,numint2,codpostal2,colonia2,municipio2,ciudad2,estado2,pais2,apellpaternoref1,apellmaternoref1,nombresref1,apellpaternoref2,apellmaternoref2,nombresref2,coddoctoanv,secuenciaanv,coddoctorev,secuenciarev,datetimeinsert)
			VALUES (pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,'',cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cCurp,cApellPaterno,cApellMaterno,cNombres,cRfc,dFechaNac,cEntidadNac,cSexo,cNacionalidad,cEdoCivil,cNumCte,cEscolaridad,	cProfesion,cActividad,cTel1,cTel2,cEmail,cCalle1,cNumExt1,cNumInt1,	cCodPostal1,cColonia1,iCiudad1,cMunicipio1,cEstado1,cPais1,cCalle2,cNumExt2,cNumInt2,cCodPostal2,cColonia2,iCiudad2,cMunicipio2,cEstado2,cPais2,cApellPaternoRef1,cApellMaternoRef1,cNombresRef1,cApellPaternoRef2,cApellMaternoRef2,cNombresRef2,cCodDoctoAnv,iSecuenciaAnv,cCodDoctoRev,iSecuenciaRev,current);


			RETURN  LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,--Datos correspondientes a la busqueda
			NVL(cCodDoctoAnv , ''),NVL(iSecuenciaAnv,0),NVL(cCodDoctoRev , ''),NVL(iSecuenciaRev,0),--Datos correspondientes de la imagen
			NVL(cCurp , ''),NVL(cApellPaterno , ''),NVL(cApellMaterno , ''),NVL(cNombre1, ''),NVL(cNombre2, ''),NVL(cRfc , ''),NVL(dFechaNac, DATE(1)),NVL(cEntidadNac , ''),NVL(cSexo , ''),NVL(cNacionalidad , ''),NVL(cEdoCivil , ''),NVL(cNumCteCoppel,''),NVL(cNumCte , ''),--Datos correspondientes al cliente
			NVL(cEscolaridad , 0),NVL(cProfesion , 0),NVL(cActividad , 0),NVL(cTel1 , ''),NVL(cTel2 , ''),NVL(cEmail , ''),
			NVL(cCalle1 , ''),NVL(cNumExt1 , ''),NVL(cNumInt1 , ''),NVL(cCodPostal1 , ''),NVL(cColonia1 , 0),NVL(iCiudad1 , 0),NVL(cMunicipio1 , 0),NVL(cEstado1 , 0),NVL(cPais1 , ''),
			NVL(cCalle2 , ''),NVL(cNumExt2 , ''),NVL(cNumInt2 , ''),NVL(cCodPostal2 , ''),NVL(cColonia2 , 0),NVL(iCiudad2 , 0),NVL(cMunicipio2 , 0),NVL(cEstado2 , 0),NVL(cPais2 , ''),--Domicilio laboral 
			NVL(cApellPaternoRef1 , ''),NVL(cApellMaternoRef1 , ''),NVL(cNombresRef1, ''),NVL(cApellPaternoRef2 , ''),NVL(cApellMaternoRef2 , ''),NVL(cNombresRef2, ''),NVL(filler1, ''),NVL(filler2, ''),
			NVL(cEfectivaAct , '0'), NVL(cNomina, '0'), divideCadena  WITH RESUME;


		END IF;
	END EXCEPTION;
	ON EXCEPTION IN(-1213)--Valida si no existe el cliente
			LET cCodRet = '0007';
			LET cApellPaterno = aPaterno;
			LET cApellMaterno = aMaterno;
			LET cNombre1 = sNombre1;
			LET cNombre2 = sNombre2;
			LET cRfc = rfc;
			LET dFechaNac = cFecha_nacimiento;
			LET cEntidadNac = cEntidad_nacimiento;
			LET cSexo = cGenero;		
	END EXCEPTION WITH RESUME;

	--log
	--SET DEBUG FILE TO '/RESPALDOSNEW/enrique/sp_afore_ctes_cpl.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--Se valida que alguno de los parametros de entrada no venga nulo
	IF NVL(aPaterno, '') = '' OR NVL(sNombre1, '') = '' OR NVL(cFecha_nacimiento, '') = '' OR NVL(cEntidad_nacimiento, '') = '' OR NVL(cGenero, '') = '' THEN
		LET cCodRet = '9996';

	ELSE
		IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
				   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND  usuario=trim(pcusuario) AND activa = 'S' ) THEN

			--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
			SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
			INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
			FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario=trim(pcusuario) AND ip_origen=trim(pcIp_origen);

            SELECT fecha_hoy
            INTO dtFecha_dia
            FROM bdisac:"informix".sac_fechas
			where empresa = '001';

 			LET cFecha_dia = YEAR(dtFecha_dia) || LPAD(MONTH(dtFecha_dia),2,'0') || LPAD(DAY(dtFecha_dia),2,'0');
			
			IF cAgent_cd = pcAgent_cd THEN
				IF cUsuario = pcUsuario THEN
					IF cPassword = pcPassword THEN
						IF cIp_origen = pcIp_origen THEN
							IF cId_sesion_act = pcSession_id THEN
									--Se valida que la fecha sea correcta la del servidor
									IF pcFecha_peticion = cFecha_dia THEN
										
										SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
										INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
										FROM bdisac:"informix".sac_ws_catmensajes
										WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
										
										IF cOpcode IS NULL THEN
											LET cOpcode = cCodRet;
											LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
											LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
										END IF;
	
										EXECUTE PROCEDURE "informix".sp_calcularfc('001',aPaterno,aMaterno,sNombre1, sNombre2,cFecha_nacimiento) INTO cCodRet,cDescr_mensaje,rfc;	
										LET cCuentaClientes = 0;
										FOREACH	
											
											--Se obtienen datos personales del cliente
											SELECT pf.curp,cte.apell_paterno,cte.apell_materno,cte.nombre1,cte.nombre2,cte.rfc,pf.fecha_nac,pf.lugar_nac,pf.sexo,pf.nacionalidad,pf.estado_civil,
											cte.numcte,pf.escolaridad,pf.actividadogiro
											INTO cCurp,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cRfc,dFechaNac,cEntidadNac,cSexo,cNacionalidad,cEdoCivil,cNumCte,cEscolaridad,cActividad
											FROM bdinteg:"informix".si_cliente cte,bdinteg:"informix".si_ctepf pf
											WHERE pf.numcte = cte.numcte
											AND cte.rfc=rfc 
											AND pf.lugar_nac=cEntidad_nacimiento
											AND pf.fecha_nac=cFecha_nacimiento 
											AND pf.sexo=cGenero
											
												LET cCuentaClientes = cCuentaClientes + 1;
											
												--Obtiene el telefono celular del cliente
												SELECT FIRST 1 telefono
												INTO cTel1
												FROM bdinteg:"informix".si_telefonos_actual
												WHERE numcte = cNumCte
												AND tipo_tel = 2
												AND status_tel = 'A'
												AND secuencia IN(SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = cNumCte AND status_tel = 'A' AND tipo_tel = 2);
												
												--Obtiene el telefono fijo del cliente
												SELECT FIRST 1 telefono
												INTO cTel2
												FROM bdinteg:"informix".si_telefonos_actual
												WHERE numcte = cNumCte
												AND tipo_tel = 1
												AND status_tel = 'A'
												AND secuencia IN(SELECT MAX(secuencia) FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = cNumCte AND status_tel = 'A' AND tipo_tel = 1);
												
												--Obtiene el correo del cliente
												SELECT FIRST 1 NVL(correo_elec, ' ')
												INTO cEmail
												FROM bdinteg:"informix".si_correos
												WHERE empresa = '001'
												AND numcte = cNumCte
												AND status_correo = 'A'
												AND secuencia IN (SELECT MAX(secuencia) FROM bdinteg:"informix".si_correos WHERE empresa = '001' AND numcte = cNumCte AND status_correo = 'A');
												
												--Obtiene Ocupacion 
												SELECT FIRST 1 NVL(claveopcionpuesto,'')||NVL(clavesubopcionpuesto,'') INTO cProfesion 
												FROM bdinteg:"informix".si_ingresos 
												WHERE numcte = cNumCte 
												AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = cNumCte);
												
												--Obtiene direccion de la casa del cliente
												SELECT FIRST 1 ca.nombrecalle,dr.numeroextcalle,dr.numerointcalle,dr.cod_postal,zo.numerocolonia,dr.numerociudad,dr.municipio,dr.estado,dr.pais
												INTO cCalle1,cNumExt1,cNumInt1,cCodPostal1,cColonia1,iCiudad1,cMunicipio1,cEstado1,cPais1
												FROM bdinteg:"informix".si_direcciones_actual AS dr 
												INNER JOIN bdinteg:"informix".si_catcalles AS ca ON dr.numerocalle = ca.numerocalle
												INNER JOIN bdinteg:"informix".si_catzonas AS zo ON dr.numerociudad = zo.numerociudad AND dr.numerocolonia = zo.numerocolonia
												WHERE ca.numerocalle = dr.numerocalle
												AND dr.tipo_dir = 1
												AND dr.numcte = cNumCte;
												
												
												--Obtiene direccion del trabajo del cliente
												SELECT FIRST 1 ca.nombrecalle,dr.numeroextcalle,dr.numerointcalle,dr.cod_postal,zo.numerocolonia,dr.numerociudad,dr.municipio,dr.estado,dr.pais
												INTO cCalle2,cNumExt2,cNumInt2,cCodPostal2,cColonia2,iCiudad2,cMunicipio2,cEstado2,cPais2
												FROM bdinteg:"informix".si_direcciones_actual dr
												INNER JOIN bdinteg:"informix".si_catcalles AS ca ON dr.numerocalle = ca.numerocalle
												INNER JOIN bdinteg:"informix".si_catzonas AS zo ON dr.numerociudad = zo.numerociudad AND dr.numerocolonia = zo.numerocolonia
												WHERE ca.numerocalle = dr.numerocalle
												AND dr.tipo_dir = 2
												AND dr.numcte = cNumCte;
												
												
												--Obtiene referencia 1
												SELECT FIRST 1 apell_paterno,apell_materno,nombre1, nombre2
												INTO  cApellPaternoRef1,cApellMaternoRef1,cNombre1Ref1,cNombre2Ref1
												FROM bdinteg:"informix".si_refclientes
												WHERE numcte = cNumCte 
												AND secuencia = (SELECT NVL(MAX(secuencia),0) FROM bdinteg:"informix".si_refclientes WHERE numcte = cNumCte AND parentesco = 'E') 
												AND parentesco = 'E';
												
												
												IF dbinfo("sqlca.sqlerrd2") = 1 THEN
													--Se arma el campo nombres
													LET cNombresRef1 = TRIM(TRIM(NVL(cNombre1Ref1,'')) || " " || TRIM(NVL(cNombre2Ref1,'')));
												END IF;
												
												--Obtiene referencia 2
												SELECT FIRST 1 apell_paterno,apell_materno,nombre1, nombre2
												INTO cApellPaternoRef2,cApellMaternoRef2,cNombre1Ref2,cNombre2Ref2
												FROM bdinteg:"informix".si_refclientes
												WHERE empresa = '001' 
												AND numcte = cNumCte 
												AND secuencia = (SELECT NVL(MAX(secuencia), 0) FROM bdinteg:"informix".si_refclientes WHERE numcte = cNumCte AND parentesco <> 'E') 
												AND parentesco <> 'E';
												
												--Se obtiene el numero de cliente coppel
												SELECT FIRST 1 cliente INTO cNumCteCoppel FROM bdinteg:"informix".si_relacion_ctebcplcpl WHERE status='1' AND numcte_banco = cNumCte;
												
												--Valida si el cliente tiene alguna cuenta efectiva
												SELECT FIRST 1 a.cuenta INTO cEfectivaAct FROM bdicheq:"informix".sc_maechq a, bdinteg:"informix".si_producto b
												WHERE a.num_cte = cNumCte
												AND b.producto IN ('1500','1800','1900','2500','2400','2000')
												AND a.producto=b.producto
												AND a.status_cta  <>  '2'
												AND a.status_cta  <>  '5'
												AND a.status_cta  <>  '6'
												AND a.status_cta  <>  '7'
												AND a.status_cta  <>  '8';
												
												IF cEfectivaAct <> '' THEN
													LET cEfectivaAct = '1';
												END IF;
												
												--Valida si el cliente tiene una cuenta de nomina
												SELECT FIRST 1 a.cuenta INTO cNomina FROM bdicheq:"informix".sc_maechq a, bdinteg:"informix".si_producto b
												WHERE num_cte = cNumCte
												AND b.producto IN ('1300')
												AND a.producto=b.producto;
												
												IF cNomina <> '' THEN 
													LET cNomina = '1';
												END IF;
												
												IF dbinfo("sqlca.sqlerrd2") = 1 THEN
													--Se arma el campo nombres
													LET cNombresRef2 = TRIM(TRIM(NVL(cNombre1Ref2,'')) || " " || TRIM(NVL(cNombre2Ref2,'')));
												END IF;
												
												--Valida si existen referencias
												IF NVL(cNombre1Ref1 , '') = '' AND NVL(cNombre1Ref2 , '') = '' THEN
													--Obtiene beneficiarios en caso de no contar con referencias
													--Se obtiene el numero de cuenta del cliente
													SELECT FIRST 1  cuenta INTO numCuentaCte FROM bdicheq:"informix".sc_maechq WHERE num_cte = cNumCte AND status_cta='1';
													FOREACH
														SELECT LIMIT 2  b.apell_paterno,b.apell_materno,nombre1,nombre2 
														INTO cApellPaternoBen,cApellMaternoBen,cNombre1Ben,cNombre2Ben
														FROM bdicheq:"informix".sc_beneficiario a, bdinteg:"informix".si_cliente b
														WHERE a.cuenta = numCuentaCte AND a.numcte=b.numcte
														IF iBan = 0 THEN
															LET cApellPaternoRef1 = NVL(cApellPaternoBen,'');
															LET cApellMaternoRef1 = NVL(cApellMaternoBen,'');
															LET cNombresRef1 = TRIM(TRIM(NVL(cNombre1Ben,'')) || " " || TRIM(NVL(cNombre2Ben,'')));
															LET iBan = 1;
														ELSE
															LET cApellPaternoRef2 = NVL(cApellPaternoBen,'');
															LET cApellMaternoRef2 = NVL(cApellMaternoBen,'');
															LET cNombresRef2 = TRIM(TRIM(NVL(cNombre1Ben,'')) || " " || TRIM(NVL(cNombre2Ben,'')));
														END IF;
													END FOREACH;
													
												END IF;
												
												--Obtiene documento digitalizado  o el anverso en caso de contar con dos imagenes
												FOREACH SELECT limit 2 xp.cod_docto,xp.secuencia,xp.descrip2
													INTO cCodDocto,iSecuencia,cDescrip2
													FROM bdidigital@coppelimg_tcp:dg_expediente xp, bdidigital@coppelimg_tcp:dg_tipodocumento doc 
													WHERE xp.cliente = cNumCte    
													AND xp.cod_docto = doc.cod_docto 
													AND xp.cod_docto = '0001'
													AND doc.cod_grupo = '001' 
													AND xp.producto = '9999'
													AND xp.descrip2 IN ('','anverso','reverso')
													order by xp.secuencia DESC
													
													LET sFlag = sFlag +1;
													
													IF TRIM(NVL(cDescrip2,''))= 'anverso' or (sFlag = 2 AND TRIM(NVL(cDescrip2,''))= '') THEN 
														LET cCodDoctoAnv = cCodDocto;
														LET iSecuenciaAnv = iSecuencia;
													ELIF TRIM(NVL(cDescrip2,''))= 'reverso' or (sFlag = 1 AND TRIM(NVL(cDescrip2,''))= '') THEN
														LET cCodDoctoRev = cCodDocto;
														LET iSecuenciaRev = iSecuencia;				
													END IF
												END FOREACH;
												
												LET cCodRet = '0000';
												INSERT INTO "informix".si_ws_afore_ctes(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,numcte_request,opcode,descr_message,date_process,time_process,curp,apellpaterno,apellmaterno,nombres,rfc,fechanac,entidadnac,sexo,nacionalidad,edocivil,numcte,escolaridad,profesion,actividad,tel1,tel2,email,calle1,numext1,numint1,codpostal1,colonia1,municipio1,ciudad1,estado1,pais1,calle2,numext2,numint2,codpostal2,colonia2,municipio2,ciudad2,estado2,pais2,apellpaternoref1,apellmaternoref1,nombresref1,apellpaternoref2,apellmaternoref2,nombresref2,coddoctoanv,secuenciaanv,coddoctorev,secuenciarev,datetimeinsert)
												VALUES (pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,'',cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cCurp,cApellPaterno,cApellMaterno,cNombres,cRfc,dFechaNac,cEntidadNac,cSexo,cNacionalidad,cEdoCivil,cNumCte,cEscolaridad,	cProfesion,cActividad,cTel1,cTel2,cEmail,cCalle1,cNumExt1,cNumInt1,	cCodPostal1,cColonia1,iCiudad1,cMunicipio1,cEstado1,cPais1,cCalle2,cNumExt2,cNumInt2,cCodPostal2,cColonia2,iCiudad2,cMunicipio2,cEstado2,cPais2,cApellPaternoRef1,cApellMaternoRef1,cNombresRef1,cApellPaternoRef2,cApellMaternoRef2,cNombresRef2,cCodDoctoAnv,iSecuenciaAnv,cCodDoctoRev,iSecuenciaRev,current);
												
												RETURN  LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,--Datos correspondientes a la busqueda
												NVL(cCodDoctoAnv , ''),NVL(iSecuenciaAnv,0),NVL(cCodDoctoRev , ''),NVL(iSecuenciaRev,0),--Datos correspondientes de la imagen
												NVL(cCurp , ''),NVL(cApellPaterno , ''),NVL(cApellMaterno , ''),NVL(cNombre1, ''),NVL(cNombre2, ''),NVL(cRfc , ''),NVL(dFechaNac, DATE(1)),NVL(cEntidadNac , ''),NVL(cSexo , ''),NVL(cNacionalidad , ''),NVL(cEdoCivil , ''),NVL(cNumCteCoppel,''),NVL(cNumCte , ''),--Datos correspondientes al cliente
												NVL(cEscolaridad , 0),NVL(cProfesion , 0),NVL(cActividad , 0),NVL(cTel1 , ''),NVL(cTel2 , ''),NVL(cEmail , ''),
												NVL(cCalle1 , ''),NVL(cNumExt1 , ''),NVL(cNumInt1 , ''),NVL(cCodPostal1 , ''),NVL(cColonia1 , 0),NVL(iCiudad1 , 0),NVL(cMunicipio1 , 0),NVL(cEstado1 , 0),NVL(cPais1 , ''),
												NVL(cCalle2 , ''),NVL(cNumExt2 , ''),NVL(cNumInt2 , ''),NVL(cCodPostal2 , ''),NVL(cColonia2 , 0),NVL(iCiudad2 , 0),NVL(cMunicipio2 , 0),NVL(cEstado2 , 0),NVL(cPais2 , ''),--Domicilio laboral 
												NVL(cApellPaternoRef1 , ''),NVL(cApellMaternoRef1 , ''),NVL(cNombresRef1, ''),NVL(cApellPaternoRef2 , ''),NVL(cApellMaternoRef2 , ''),NVL(cNombresRef2, ''),NVL(filler1, ''),NVL(filler2, ''),
												NVL(cEfectivaAct , '0'), NVL(cNomina, '0'), divideCadena  WITH RESUME; 
												
											END FOREACH;
											
											IF cCuentaClientes = 0 THEN
												LET cCodRet = '0007';
												LET cApellPaterno = aPaterno;
												LET cApellMaterno = aMaterno;
												LET cNombre1 = sNombre1;
												LET cNombre2 = sNombre2;
												LET cRfc = rfc;
												LET dFechaNac = cFecha_nacimiento;
												LET cEntidadNac = cEntidad_nacimiento;
												LET cSexo = cGenero;
											END IF;		
											
									ELSE
										LET cCodRet = '9977';
									END IF;
							ELSE
								LET cCodRet = '9975';
							END IF;
						ELSE
							LET cCodRet = '9976';
						END IF;
					ELSE
						LET cCodRet = '9979';
					END IF;
				ELSE
					LET cCodRet = '9980';
				END IF;
			ELSE
				LET cCodRet = '9998';
			END IF;
		ELSE
			LET cCodRet = '9999';
		END IF;
	END IF;	
	IF cCodRet <> '0000' THEN	
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
		INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
		FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN
			LET cOpcode = cCodRet;
			LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
			LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
		END IF;
		
		INSERT INTO "informix".si_ws_afore_ctes(agent_cd,user_request,password,ip_origen,id_sesion,date_request,time_request,numcte_request,opcode,descr_message,date_process,time_process,curp,apellpaterno,apellmaterno,nombres,rfc,fechanac,entidadnac,sexo,nacionalidad,edocivil,numcte,escolaridad,profesion,actividad,tel1,tel2,email,calle1,numext1,numint1,codpostal1,colonia1,municipio1,ciudad1,estado1,pais1,calle2,numext2,numint2,codpostal2,colonia2,municipio2,ciudad2,estado2,pais2,apellpaternoref1,apellmaternoref1,nombresref1,apellpaternoref2,apellmaternoref2,nombresref2,coddoctoanv,secuenciaanv,coddoctorev,secuenciarev,datetimeinsert)
		VALUES (pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcSession_id,pcFecha_peticion,pcHora_peticion,'',cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cCurp,cApellPaterno,cApellMaterno,cNombres,cRfc,dFechaNac,cEntidadNac,cSexo,cNacionalidad,cEdoCivil,cNumCte,cEscolaridad,	cProfesion,cActividad,cTel1,cTel2,cEmail,cCalle1,cNumExt1,cNumInt1,	cCodPostal1,cColonia1,iCiudad1,cMunicipio1,cEstado1,cPais1,cCalle2,cNumExt2,cNumInt2,cCodPostal2,cColonia2,iCiudad2,cMunicipio2,cEstado2,cPais2,cApellPaternoRef1,cApellMaternoRef1,cNombresRef1,cApellPaternoRef2,cApellMaternoRef2,cNombresRef2,cCodDoctoAnv,iSecuenciaAnv,cCodDoctoRev,iSecuenciaRev,current);
		
		RETURN  LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,--Datos correspondientes a la busqueda
		NVL(cCodDoctoAnv , ''),NVL(iSecuenciaAnv,0),NVL(cCodDoctoRev , ''),NVL(iSecuenciaRev,0),--Datos correspondientes de la imagen
		NVL(cCurp , ''),NVL(cApellPaterno , ''),NVL(cApellMaterno , ''),NVL(cNombre1, ''),NVL(cNombre2, ''),NVL(cRfc , ''),NVL(dFechaNac, DATE(1)),NVL(cEntidadNac , ''),NVL(cSexo , ''),NVL(cNacionalidad , ''),NVL(cEdoCivil , ''),NVL(cNumCteCoppel,''),NVL(cNumCte , ''),--Datos correspondientes al cliente
		NVL(cEscolaridad , 0),NVL(cProfesion , 0),NVL(cActividad , 0),NVL(cTel1 , ''),NVL(cTel2 , ''),NVL(cEmail , ''),
		NVL(cCalle1 , ''),NVL(cNumExt1 , ''),NVL(cNumInt1 , ''),NVL(cCodPostal1 , ''),NVL(cColonia1 , 0),NVL(iCiudad1 , 0),NVL(cMunicipio1 , 0),NVL(cEstado1 , 0),NVL(cPais1 , ''),
		NVL(cCalle2 , ''),NVL(cNumExt2 , ''),NVL(cNumInt2 , ''),NVL(cCodPostal2 , ''),NVL(cColonia2 , 0),NVL(iCiudad2 , 0),NVL(cMunicipio2 , 0),NVL(cEstado2 , 0),NVL(cPais2 , ''),--Domicilio laboral 
		NVL(cApellPaternoRef1 , ''),NVL(cApellMaternoRef1 , ''),NVL(cNombresRef1, ''),NVL(cApellPaternoRef2 , ''),NVL(cApellMaternoRef2 , ''),NVL(cNombresRef2, ''),NVL(filler1, ''),NVL(filler2, ''),
		NVL(cEfectivaAct , '0'), NVL(cNomina, '0'), divideCadena  WITH RESUME;
	END IF;
	
END;
END PROCEDURE;