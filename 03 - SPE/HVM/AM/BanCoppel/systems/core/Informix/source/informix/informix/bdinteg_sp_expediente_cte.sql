CREATE PROCEDURE "informix".sp_expediente_cte(pEmpresa char(3), pNumcte CHAR(20), pCuenta CHAR(20), pTarjeta CHAR(20))

RETURNING 	CHAR(5)  AS Cod_Retorno,
			CHAR(20) AS Numero_Cliente,
			CHAR(107) AS Nombre,
			CHAR(13) AS RFC,
			CHAR(1)  AS Tipo_Cliente,
			CHAR(40) AS Desc_Tipo_Cliente,
			DATE     AS Fecha_Nacimiento,
			CHAR(1)  AS Cve_Sexo,
			CHAR(2)  AS Cve_Tipo_Persona,
			CHAR(20) AS Desc_Tipo_Persona,
			DATE     AS Fecha_Alta,
			CHAR(4)  AS Sucursal,
			CHAR(5)  AS Plaza,--se cambia por CP
			CHAR(5)  AS Cve_Situacion,
			CHAR(75) AS Desc_Situacion,
			CHAR(40) AS Calle,
			CHAR(80) AS Complemento,
			CHAR(40) AS EntreCalle,
			CHAR(10) AS Numero_Exterior_Calle,
			CHAR(10) AS Numero_Interior_Calle,
			CHAR(6)  AS Departamento,
			CHAR(60) AS Colonia,
			CHAR(60) AS Municipio,
			CHAR(60) AS Ciudad,
			CHAR(30) AS Estado,
			CHAR(13) AS Telefono_1,
			CHAR(13) AS Telefono_2,
			CHAR(13) AS Telefono_3,
			CHAR (5) AS Extension,
			CHAR(10) AS Reviso,
			CHAR (30) AS StatusRevision ,
			CHAR(250) AS observaciones,
            CHAR(35) AS CompDomi,
            CHAR(50) AS Identificacion,
            CHAR(30) AS OCR,
            CHAR(100)AS EMail;




---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);


DEFINE cNumcte 		CHAR(20);
DEFINE cNombreCte		CHAR(107);
DEFINE cRfc 			CHAR(13);
DEFINE cTipo_cliente	CHAR(1);
DEFINE cDtipoCliente	CHAR(40);
DEFINE dfecha_nac		DATE;
DEFINE cSexo 			CHAR(1);
DEFINE ctpo_persona 	CHAR(2);
DEFINE cDtipo_persona	CHAR(20);
DEFINE dfecha_alta		DATE;
DEFINE csucursal		CHAR(4);
DEFINE dPlaza_cte		CHAR(5);
DEFINE cClave_situ		CHAR(5);
DEFINE vcalle 			CHAR(40);
DEFINE vcomplemento		CHAR(80);
DEFINE vEntrecalle 		CHAR(40);
DEFINE vnumeroextcalle  CHAR(10);
DEFINE vnumerointcalle  CHAR(10);
DEFINE vdepartamento  	CHAR(6);
DEFINE vcolonia 		CHAR(60);
DEFINE vmunicipio 		CHAR(60);
DEFINE vciudad 			CHAR(60);
DEFINE vestado 			CHAR(30);
DEFINE vtelefono1 		CHAR(13);
DEFINE vtelefono2  		CHAR(13);
DEFINE vtelefono3  		CHAR(13);
DEFINE vextension 		CHAR(5);
DEFINE cCSitua_esp		CHAR(5);
DEFINE cSituacion_esp	CHAR(75);
DEFINE vCveEstado       CHAR(2);
DEFINE vnumcalle        INTEGER;
DEFINE vnumerocolonia   INT;
DEFINE vnumerociudad    SMALLINT ;
DEFINE vcvemunicipio    CHAR(5);
DEFINE cTel             CHAR(13);
DEFINE sTipoTel         SMALLINT;
DEFINE cReviso          CHAR(10);
DEFINE cStatusRevision  CHAR(30);
DEFINE cObservaciones   CHAR(250);
DEFINE iexiste_situacion SMALLINT;
DEFINE iBandera         SMALLINT;
DEFINE iDias            SMALLINT;
DEFINE dTFecha          DATE;
DEFINE dtFechaHoy       DATE;
DEFINE sCompDomi        CHAR(35);
DEFINE sIdentifi        CHAR(50);
DEFINE sOCR             CHAR(30);
DEFINE sMail            CHAR(100);


---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';


LET cNumcte = "";
LET cNombreCte = "";
LET cRfc 			= "";
LET cTipo_cliente	= "";
LET cDtipoCliente	= "";
LET dfecha_nac		= "";
LET cSexo 			= "";
LET ctpo_persona 	= "";
LET cDtipo_persona	= "";
LET dfecha_alta		= "";
LET csucursal		= "";
LET dPlaza_cte		= "";
LET cCSitua_esp	 = "";
LET cSituacion_esp = "";
LET vCveEstado = "";
LET vnumcalle  = 0;
LET vnumerocolonia = 0;
LET vnumerociudad = 0;
LET vcvemunicipio = "";
LET vcalle = "";
LET vcomplemento = "";
LET vEntrecalle = "";
LET vnumeroextcalle  = "";
LET vnumerointcalle  = "";
LET vdepartamento  = "";
LET vcolonia = "";
LET vmunicipio = "";
LET vciudad = "";
LET vestado = "";
LET vtelefono1  = "";
LET vtelefono2   = "";
LET vtelefono3   = "";
LET vextension  = "";
LET cTel  = "";
LET sTipoTel  = 0;
LET cReviso  = "";
LET cStatusRevision = "";
LET cObservaciones = "";
LET iexiste_situacion =  0;
LET iBandera =  0;
LET dTFecha =  '';
LET dtFechaHoy =  '';
LET iDias =  0;
LET sCompDomi ='';
LET sIdentifi ='';
LET sOCR      ='';
LET sMail     ='';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN 	cCodRet,cNumcte,cNombreCte,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
					cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cCSitua_esp, cSituacion_esp,
					vcalle,vcomplemento,vEntrecalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,vciudad,vestado,
					vtelefono1,vtelefono2,vtelefono3,vextension,cReviso,cStatusRevision,cObservaciones, sCompDomi, sIdentifi, sOCR, sMail;
       END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
    --SET ISOLATION TO COMMITTED READ LAST COMMITTED;


--SET DEBUG FILE TO "/informix/jesus/sp_expediente_cte.out";
--TRACE ON;

IF NVL(pNumCte,'') = '' AND (NVL(pCuenta,'') = '' AND NVL(pTarjeta,'') = '') THEN
	LET cCodRet				= '00001';
		RETURN 	cCodRet,cNumcte,cNombreCte,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
				cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cCSitua_esp, cSituacion_esp,
				vcalle,vcomplemento,vEntrecalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,vciudad,vestado,
				vtelefono1,vtelefono2,vtelefono3,vextension,cReviso,cStatusRevision,cObservaciones, sCompDomi, sIdentifi, sOCR, sMail;

ELSE
	IF pCuenta <> '' THEN
		SELECT num_cte
		INTO pNumcte
		FROM bdicheq:"informix".sc_maechq
		WHERE cuenta = pCuenta;

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			SELECT numcte
			INTO pNumcte
			FROM bdicred:"informix".sd_maecred
			WHERE num_credito = pCuenta;

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				SELECT num_cte
				INTO pNumcte
				FROM bdinvers:"informix".sv_maeinv
				WHERE empresa = "001"
				AND cuenta = pCuenta
				AND secuencia IS NOT NULL;

				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					SELECT numcte
					INTO pNumcte
					FROM bdicred:"informix".sd_maecredcrd
					WHERE num_credito = pCuenta;

					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET cCodRet = '00002';
						RETURN 	cCodRet,cNumcte,cNombreCte,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
								cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cCSitua_esp, cSituacion_esp,
								vcalle,vcomplemento,vEntrecalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,vciudad,vestado,
								vtelefono1,vtelefono2,vtelefono3,vextension,cReviso,cStatusRevision,cObservaciones, sCompDomi, sIdentifi, sOCR, sMail;

					END IF;
				END IF;
			END IF;
		END IF;

	ELIF pTarjeta <> '' THEN

		SELECT numcte
		INTO pNumcte
		FROM bdicheq:"informix".sc_tarjeta
		WHERE empresa = "001"
		AND num_tarjeta = pTarjeta
		AND status_tar = "A";

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			SELECT numcte
			INTO pNumcte
			FROM bdicred:"informix".sd_tarjeta
			WHERE num_tarjeta = pTarjeta
			AND status_tar = "A";

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00003';
				RETURN 	cCodRet,cNumcte,cNombreCte,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
						cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cCSitua_esp, cSituacion_esp,
						vcalle,vcomplemento,vEntrecalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,vciudad,vestado,
						vtelefono1,vtelefono2,vtelefono3,vextension,cReviso,cStatusRevision,cObservaciones, sCompDomi, sIdentifi, sOCR, sMail;

			END IF;

		END IF;
	END IF;
END IF;

	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;
	--consulta todos

	SELECT valor
	INTO iDias
	FROM bdicred:"informix".sd_param
	WHERE empresa = pEmpresa
	AND cod_param ='086';

	LET dtFechaHoy = dtFechaHoy - iDias;

	---Consulta por cliente
	IF NVL(pNumcte,"") <> "" THEN--va consultar todos los estatus

			SELECT cte.numcte,TRIM(cte.nombre1)||" "||TRIM(cte.nombre2)||" "||TRIM(cte.apell_paterno)||" "||TRIM(cte.apell_materno),
			CASE WHEN NVL(cte.rfc_alterno,'') = '' THEN cte.rfc ELSE cte.rfc_alterno END,
			cte.tipo_cliente,TP.descripcion , pf.fecha_nac,pf.sexo,cte.tpo_persona,te.descripcion,cte.fecha_alta,
			cte.sucursal
			INTO cNumcte,cNombreCte,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,cDtipo_persona, dfecha_alta,csucursal
			FROM bdinteg:"informix".si_cliente cte
			INNER JOIN bdinteg:"informix".si_ctepf pf  ON (cte.empresa= pf.empresa and cte.numcte =pf.numcte )
			LEFT JOIN si_tipocte tp ON tp.tipo_cliente = cte.tipo_cliente
			LEFT JOIN si_tipper te ON te.tpo_persona = cte.tpo_persona
			LEFT JOIN si_sucursales su	ON su.sucursal = cte.sucursal
			WHERE cte.empresa =pEmpresa
			AND cte.numcte = pNumcte
			AND cte.tipo_cliente = 1;

			IF NVL(cNumcte,"") <>  "" THEN
				SELECT NVL(COUNT(numcte),0) INTO iexiste_situacion  FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumcte;



				IF iexiste_situacion = 1 THEN
					SELECT sc.situacion||sc.causa,cs.descripcion
					INTO cCSitua_esp, cSituacion_esp
					FROM bdisitesp:se_ctessitespcte sc
					LEFT JOIN bdisitesp:se_catsitesp cs
					ON cs.situacion = sc.situacion and cs.causa = sc.causa
					WHERE sc.numcte = cNumcte;

				ELIF (SELECT NVL(COUNT(numcte),0)  FROM bdisitesp:se_ctessitespcred WHERE numcte = cNumcte) = 1 THEN

					SELECT sc.situacion||sc.causa,cs.descripcion
					INTO cCSitua_esp, cSituacion_esp
					FROM bdisitesp:se_ctessitespcred sc
					LEFT JOIN bdisitesp:se_catsitesp cs
					ON cs.situacion = sc.situacion and cs.causa = sc.causa
					WHERE sc.numcte = cNumcte;
				END IF


			FOREACH WITH HOLD
				SELECT LIMIT 1 gerente, DECODE(status_revision,0,"Sin Revisar",1,"Status OK",2,"Pendiente de Corregir"),observaciones,fecha_insert
				INTO cReviso,cStatusRevision,cObservaciones, dTFecha
				FROM bdinteg:"informix".si_reporte_expediente
				WHERE empresa = pEmpresa
				AND numcte = cNumcte
				ORDER BY fecha_insert DESC

				IF dTFecha < dtFechaHoy THEN
					LET cReviso     = '';
					LET cStatusRevision = '';
				END IF;
				EXIT FOREACH;
			END FOREACH;

			SELECT 	 numeroextcalle, numerointcalle,departamento,
				 numerocalle,numerociudad,numerocolonia,
				estado,municipio,cod_postal,entre_calles,observaciones
			INTO       vnumeroextcalle, vnumerointcalle, vdepartamento,
				vnumcalle,vnumerociudad,vnumerocolonia,
				vCveEstado,vcvemunicipio,dPlaza_cte,vEntrecalle,vcomplemento
			FROM si_direcciones_actual
			WHERE numcte = cNumcte
			AND tipo_dir = '1';



			FOREACH
				SELECT telefono,tipo_tel
					INTO cTel,sTipoTel
				FROM bdinteg:"informix".si_telefonos_actual a
				WHERE a.empresa = '001'
				AND a.numcte = cNumcte
				AND a.tipo_tel IN (1,2,3)
				AND a.status_tel = 'A'

				IF sTipoTel = 1 THEN
					LET vtelefono1 =cTel;
				ELIF sTipoTel = 2 THEN
					LET vtelefono2 = cTel;
				ELIF sTipoTel = 3 THEN
					LET vtelefono3 = cTel;
				END IF;
			END FOREACH;


			SELECT TRIM(nombre)
			INTO vestado
			FROM bdinteg:si_estados
			WHERE estado = vCveEstado;

			SELECT TRIM(nombreciudad)
			INTO vciudad
			FROM bdinteg:si_catciudades
			WHERE numerociudad = vnumerociudad;

			SELECT TRIM(nombrezona)
			INTO vcolonia
			FROM bdinteg:si_catzonas
			WHERE numerociudad = vnumerociudad
			AND numerocolonia = vnumerocolonia;

			SELECT TRIM(nombrecalle)
			INTO vcalle
			FROM bdinteg:si_catcalles
			WHERE numerocalle = vnumcalle;

			IF TRIM(vcvemunicipio) ='00000' THEN
				LET vcvemunicipio  = "";
				SELECT TRIM(municipiozona)
				  INTO vmunicipio
				  FROM bdinteg:si_catzonas
				 WHERE numerociudad = vnumerociudad
				   and numerocolonia  = vnumerocolonia;
			ELSE
				LET vmunicipio = vciudad;
			END IF;



            --OBTIENE COMPROBANTE DE DOMICILIO
              FOREACH
               select limit 1 descripcion INTO sCompDomi
               from bdidigital@coppelimg_tcp:dg_expediente dge
               inner join bdidigital@coppelimg_tcp:dg_tipodocumento td
               on dge.cod_docto=td.cod_docto
               where dge.cliente=cNumcte 
               and td.cod_grupo='002'
               order by dge.fecha_alta desc
              END FOREACH;

            --OBTIENE TIPO DE IDENTIFICACION Y NUMERO (OCR)
                select ti.descripcion, cf.numidentifi INTO sIdentifi, sOCR
                from si_ctepf cf
                inner join si_tipoidentif ti
                on cf.codidentifi=ti.codidentif
                where numcte=cNumcte;

            --OBTIENE EMAIL
               FOREACH
                select limit 1 correo_elec INTO sMail from bdinteg:si_correos where numcte=cNumcte order by secuencia desc
              END FOREACH;



					LET iBandera = 1;
			 RETURN 	cCodRet,NVL(cNumcte,""),NVL(cNombreCte,""),NVL(cRfc,""),NVL(cTipo_cliente,""),NVL(cDtipoCliente,""),NVL(dfecha_nac,""),NVL(cSexo,""), NVL(ctpo_persona,""),
						NVL(cDtipo_persona,""),NVL( dfecha_alta,""),NVL(csucursal,""),NVL(dPlaza_cte,""),NVL(cCSitua_esp,""), NVL(cSituacion_esp,""),
						NVL(vcalle,""),NVL(vcomplemento,""),NVL(vEntrecalle,""),NVL(vnumeroextcalle,""),NVL(vnumerointcalle,""),NVL(vdepartamento,""),NVL(vcolonia,""),NVL(vmunicipio,""),NVL(vciudad,""),NVL(vestado,""),
						NVL(vtelefono1,""),NVL(vtelefono2,""),NVL(vtelefono3,""),NVL(vextension,""),NVL(cReviso,""),NVL(cStatusRevision,""),NVL(cObservaciones,""), sCompDomi, sIdentifi, sOCR, sMail;


			END IF;

	END IF;

	IF iBandera = 0 THEN
		LET cCodRet				= '00004';
		 RETURN 	cCodRet,cNumcte,cNombreCte,cRfc,cTipo_cliente,cDtipoCliente,dfecha_nac,cSexo, ctpo_persona,
					cDtipo_persona, dfecha_alta,csucursal,dPlaza_cte,cCSitua_esp, cSituacion_esp,
					vcalle,vcomplemento,vEntrecalle,vnumeroextcalle,vnumerointcalle,vdepartamento,vcolonia,vmunicipio,vciudad,vestado,
					vtelefono1,vtelefono2,vtelefono3,vextension,cReviso,cStatusRevision,cObservaciones, sCompDomi, sIdentifi, sOCR, sMail;
	END IF;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para consultar clientes para realizar la validaciones de expediente',
'AUTOR: Jesus Manuel Aguilar Heredia',
'FECHA: 06 mayo 2014',
'VERSION: 201405061209',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_desfusion_ctesprincipal(pFecha DATE)
--RETORNOS-
RETURNING
CHAR(6)	AS codret,
CHAR(50)	AS detalle_ret,
CHAR(20)	AS cliente_tit,
CHAR(20)	AS cliente_tras;

--DECLARACION DE VARIABLES--
DEFINE iSql_err			INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE cDescErr     	CHAR(50);
DEFINE cDetalleErr     	CHAR(50);
DEFINE cCodret		CHAR(6);
DEFINE cCteTit		CHAR(20);
DEFINE cCteTras		CHAR(20);
DEFINE cEstatus		SMALLINT;
DEFINE cProceso		CHAR(30);
DEFINE cUsuario		CHAR(8);
DEFINE dFechaActual	DATE;
DEFINE cRetornoCtesCap	CHAR(6);
DEFINE cRetornoCtesCred	CHAR(6);
DEFINE cRetornoCtesDig	CHAR(6);
DEFINE iTransaccion 	INTEGER;
DEFINE iContador		INTEGER;
DEFINE iExiste 		INTEGER;
DEFINE cDetalleMov	CHAR(200);
DEFINE cBandVal		CHAR(1);
DEFINE sFin			SMALLINT;
DEFINE sIni			SMALLINT;
DEFINE cNumcteInco	CHAR(20);
DEFINE cCodigoDig		CHAR(5);
DEFINE cSecuencia		CHAR(5);
DEFINE cSecActual		CHAR(5);
DEFINE cFecha		CHAR(12);
DEFINE cCuenta 		CHAR(20);
DEFINE cProducto		CHAR(5);
DEFINE cTramaDetalle	CHAR(200);
DEFINE cIdentificador	CHAR(1);
DEFINE cTabla			CHAR(25);
DEFINE cTabla1			CHAR(25);
DEFINE cTabla2			CHAR(25);
DEFINE cRetornoLog      CHAR(6);


--INICIALIZACION DE VARIABLES--
LET iSql_err		= 0;
LET iIsamErr    		= 0;
LET cDescErr    		= '';
LET cDetalleErr    	= '';
LET cCodret			= '000000';
LET cCteTit			= '';
LET cCteTras		= '';
LET cEstatus		= 0;
LET cProceso		= '';
LET cUsuario		= 'infdesf';
LET dFechaActual	= DATE(1);
LET cRetornoCtesCap		= '';
LET CRetornoCtesCred	= '';
LET cRetornoCtesDig		= '';
LET iTransaccion 		= 0;
LET iContador			= 0;
LET iExiste				= 0;
LET cDetalleMov			= '';
LET cBandVal			= '';
LET sFin				= 0;
LET sIni				= 0;
LET cNumcteInco			= '';
LET cCodigoDig		= '';
LET cSecuencia		= '';
LET cSecActual		= '';
LET cCuenta 		= '';
LET cProducto		= '';
LET cFecha			= '';
LET cTramaDetalle		= '';
LET cIdentificador	= '';
LET cTabla			= '';
LET cTabla1			= '';
LET cTabla2			= '';
LET cRetornoLog     = '';

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err , iIsamErr, cDescErr
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			LET cDetalleErr = cDescErr;
			RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), '','';
		END IF;
	END EXCEPTION;

 --SET DEBUG FILE TO '/informix/ALAN/Sps/Nuevacarpeta/sp_desfusion_ctesprincipal.out';
 --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT fecha_hoy
	INTO dFechaActual
	FROM "informix".si_fechas
	WHERE empresa = '001';

	IF 	NVL(pFecha,'') = '' OR pFecha > dFechaActual THEN
		LET cCodret = '000001'; --ERROR EN LOS PARAMETROS
		LET cDetalleErr = 'FECHA NO VALIDA';
		RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), '','';
	END IF;

	EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal','000000000','000000000','Inicia consulta de si_desfusionctes',cUsuario) INTO cRetornoLog;
	FOREACH WITH HOLD
		
		SELECT {+INDEX ("informix".si_desfusionctes idx_desfusion_cte)} cliente_tit, cliente_tras
		INTO cCteTit, cCteTras
		FROM "informix".si_desfusionctes
		WHERE cliente_tit = cliente_tit
		AND cliente_tras = cliente_tras
		AND estatus = 0
		AND fecha_insert >= pFecha

		BEGIN
			ON EXCEPTION SET iSql_err, iIsamErr, cDescErr
				IF iSql_err <> 0 THEN
					LET cCodret = iSql_err;
					LET cDetalleErr = cDescErr;
					IF iTransaccion = 1 THEN
						ROLLBACK WORK;
						LET cEstatus = 2;
						UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = TRIM(cDetalleErr), estatus = cEstatus, fecha = current
						WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
						LET iTransaccion = 0;
						RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
						END IF
				END IF;
				CONTINUE FOREACH;
			END EXCEPTION WITH RESUME;

			LET iContador = iContador + 1;

			IF iContador >= 1 THEN
				BEGIN WORK;
				LET iTransaccion = 1;
			END IF
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en si_cliente',cUsuario) INTO cRetornoLog;
			
			INSERT INTO "informix".si_cliente(empresa,numcte,status_cte,sucursal,ejecutivo,tpo_persona,tipo_cliente,apell_paterno,apell_materno,nombre1,nombre2,razon_social,
			rfc,sector,segmento,actividad_princ,grupo,subgrupo,residencia,fecha_alta,apell_casada,distrito,numcte_ref,string1,string2,numeric1,
			numeric2,money1,date1,puesto_ppes,familiar_ppes,actividad_esp,ejecut_autoriza,user_insert,fecha_insert,rfc_alterno, tpo_biometria,cliente_pros)
			SELECT empresa,numcte,status_cte,sucursal,ejecutivo,tpo_persona,tipo_cliente,apell_paterno,apell_materno,nombre1,nombre2,razon_social,
			rfc,sector,segmento,actividad_princ,grupo,subgrupo,residencia,fecha_alta,apell_casada,distrito,numcte_ref,string1,string2,numeric1,
			numeric2,money1,date1,puesto_ppes,familiar_ppes,actividad_esp,ejecut_autoriza,user_insert,fecha_insert,rfc_alterno,tpo_biometria,cliente_pros 
			FROM "informix".si_fuscliente WHERE  numcte = TRIM(cCteTras);
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en si_ctepf',cUsuario) INTO cRetornoLog;
			
			INSERT INTO "informix".si_ctepf (empresa, numcte, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil,
			regim_matrimonio, profesion, sexo, curp, codidentifi, numidentifi, no_imss, dependientes, tutor,
			nom_conyuge, seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta,
			actividadogiro, numeroife, numerotutor, numeroconyuge, string1, string2, numeric1, numeric2,
			money1, date1, user_insert, fecha_insert,sms_cel,hora_insert,validacurp,id_pais)
			SELECT FIRST 1 empresa, numcte, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion,
			sexo, curp, codidentifi, numidentifi, no_imss, dependientes, tutor, nom_conyuge, seguro_defunc, escolaridad,
			habita_en, anios_habita, nombre_prop, imp_hipo_renta, actividadogiro, numeroife, numerotutor, numeroconyuge,
			string1, string2, numeric1, numeric2, money1,date1, user_insert, fecha_insert, sms_cel, hora_insert,validacurp,id_pais
			FROM "informix".si_fusctepf
			WHERE numcte = TRIM(cCteTras);
			

			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en si_logdesfusion',cUsuario) INTO cRetornoLog;
			INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('CLIENTE','si_fuscliente',cCteTit,cCteTras,cCteTras,CURRENT HOUR TO FRACTION(4),cUsuario,CURRENT);

			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Ejecuta sp_desfusion_ctescap',cUsuario) INTO cRetornoLog;
			EXECUTE PROCEDURE "informix".sp_desfusion_ctescap(cCteTit, cCteTras, cUsuario) INTO cCodret, cDescErr;
			IF iTransaccion = 1 THEN
				IF cCodRet <> '000000' THEN	
					ROLLBACK WORK;
					LET cEstatus = 2;
					LET cDetalleErr = cDescErr;
					EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Actualiza en si_desfusionctes',cUsuario) INTO cRetornoLog;
					UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = TRIM(cDetalleErr), estatus = cEstatus, fecha = current
					WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
					LET iTransaccion = 0;
					RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
					CONTINUE FOREACH;
				ELSE
					EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Ejecuta sp_desfusion_ctescred',cUsuario) INTO cRetornoLog;
					EXECUTE PROCEDURE bdicred:"informix".sp_desfusion_ctescred(cCteTit, cCteTras, cUsuario) INTO cCodret, cDescErr;
					LET cIdentificador = '1';
					IF cCodRet <> '000000' THEN
						ROLLBACK WORK;
						LET cEstatus = 2;
						LET cDetalleErr = cDescErr;
						EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Actualiza en si_desfusionctes 2',cUsuario) INTO cRetornoLog;
						UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = TRIM(cDetalleErr), estatus = cEstatus, fecha = current
						WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
						LET iTransaccion = 0;
						RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
						CONTINUE FOREACH;
					END IF;
				END IF;
			END IF;
					
			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inicia consulta en log_fusionclientes',cUsuario) INTO cRetornoLog;
			FOREACH WITH HOLD

				SELECT detalle_mov
				INTO cDetalleMov
				FROM "informix".log_fusionclientes
				WHERE cliente_tras = cCteTras
				AND proceso = 'DG_EXPEDIENTE'
				AND detalle_mov LIKE '%IMAGEN ACTUALIZADA%'

				LET cBandVal = '1';
				LET sIni = 1;

				LET cNumcteInco = '';
				LET cCodigoDig = '';
				LET cSecuencia = '';
				LET cSecActual = '';
				LET sFin = 0;
				LET cTramaDetalle = '';

				--SE EXTRAE EL NUMERO DE CTE INCORRECTO DE LA TRAMA
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cNumcteInco = TRIM(SUBSTR(cDetalleMov,sIni,sFin - 1));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE EL CODIGO DE DIGITALIZACION
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cCodigoDig = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1 ;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE LA SECUENCIA QUE CONTABA CTE ANTES DE LA FUSION
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cSecuencia = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE LA SECUENTA ACTUAL DEL CTE
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cSecActual = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE
				
				LET cTramaDetalle = TRIM(cNumcteInco)||'|'||TRIM(cCodigoDig)||'|'||TRIM(cSecuencia)||'|'||TRIM(cSecActual)||'|';
				EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Ejecuta sp_desfusion_ctesdigital',cUsuario) INTO cRetornoLog;
				--EXECUTE PROCEDURE bdidigital@coppelimg_tcp:"informix".sp_desfusion_ctesdigital(TRIM(cCteTit), TRIM(cTramaDetalle), TRIM(cIdentificador)) INTO cCodret, cDescErr, cTabla, cTabla1, cTabla2;
				EXECUTE PROCEDURE bdinteg:sp_desfusion_ctesdigital(TRIM(cCteTit), TRIM(cTramaDetalle), TRIM(cIdentificador)) INTO cCodret, cDescErr, cTabla, cTabla1, cTabla2;
					IF iTransaccion = 1 THEN
						IF cCodRet <> '000000' THEN
							ROLLBACK WORK;
							LET cEstatus = 2;
							LET cDetalleErr = cDescErr;
							EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Actualiza en si_desfusionctes 3',cUsuario) INTO cRetornoLog;
							UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = TRIM(cDetalleErr), estatus = cEstatus, fecha = current
							WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
							LET iTransaccion = 0;
							RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
							CONTINUE FOREACH;
						ELSE
							IF cTabla = 'dg_expediente' THEN
								--LOG
								EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente',cUsuario) INTO cRetornoLog;
								INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
								VALUES('DG_EXPEDIENTE', 'dg_expediente', cCteTit, cCteTras, TRIM(cTramaDetalle)||'IMAGEN ACTUALIZADA', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
								IF cTabla1 = 'dg_expediente_img' THEN
									--LOG
									EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente_img',cUsuario) INTO cRetornoLog;
									INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
									VALUES('DG_EXPEDIENTE', 'dg_expediente_img', cCteTit, cCteTras, TRIM(cTramaDetalle)||'IMAGEN ACTUALIZADA', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
									IF cTabla1 = 'dg_expediente_img_his' THEN
										--LOG
										EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente_his',cUsuario) INTO cRetornoLog;
										INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
										VALUES('DG_EXPEDIENTE', 'dg_expediente_img_his', cCteTit, cCteTras, TRIM(cTramaDetalle)||'IMAGEN ACTUALIZADA', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
									END IF;
								END IF;		
							END IF;
						END IF;
					END IF;
					
			END FOREACH
			
			LET cIdentificador = '';
			LET cIdentificador = '2';
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inicia consulta log_fusionclientes:dg_expediente',cUsuario) INTO cRetornoLog;
			FOREACH WITH HOLD

				SELECT detalle_mov
				INTO cDetalleMov
				FROM "informix".log_fusionclientes
				WHERE cliente_tras = TRIM(cCteTras)
				AND proceso ='DG_EXPEDIENTE'
				AND detalle_mov
				LIKE '%DOCUMENTO ELIMINADO%'

				LET cBandVal = '1';
				LET sIni = 1;

				LET cNumcteInco = '';
				LET cCuenta = '';
				LET cProducto = '';
				LET cCodigoDig = '';
				LET cSecuencia = '';
				LET cFecha = '';
				LET sFin = 0;
				LET cTramaDetalle = '';

				--SE EXTRAE EL NUMERO DE CLIENTE INCORRECTO DE LA TRAMA.
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cNumcteInco = TRIM(SUBSTR(cDetalleMov,sIni,sFin - 1));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE EL NUMERO DE CUENTA DE LA TRAMA.
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cCuenta = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1 ;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE EL PRODUCTO DE LA TRAMA.
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cProducto = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE EL CODIGO DE DIGITALIZACION.
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cCodigoDig = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE SECUENCIA  DE LA TRAMA
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cSecuencia = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE
				
				LET cBandVal = '1';
				--SE EXTRAE FECHA  DE LA TRAMA
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cFecha = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cTramaDetalle = TRIM(cNumcteInco)||'|'||TRIM(cCuenta)||'|'||TRIM(cProducto)||'|'||TRIM(cCodigoDig)||'|'||TRIM(cSecuencia)||'|'||TRIM(cFecha)||'|';
				EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Ejecuta sp_desfusion_ctesdigital 2',cUsuario) INTO cRetornoLog;
				--EXECUTE PROCEDURE bdidigital@coppelimg_tcp:"informix".sp_desfusion_ctesdigital(cCteTit, cTramaDetalle, cIdentificador) INTO cCodret, cDescErr, cTabla, cTabla1, cTabla2;
				EXECUTE PROCEDURE bdinteg:sp_desfusion_ctesdigital(cCteTit, cTramaDetalle, cIdentificador) INTO cCodret, cDescErr, cTabla, cTabla1, cTabla2;
				IF iTransaccion = 1 THEN
					IF cCodRet <> '000000' THEN
						ROLLBACK WORK;
						LET cEstatus = 2;
						LET cDetalleErr = cDescErr;
						EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Actualiza en si_desfusionctes 3',cUsuario) INTO cRetornoLog;
						UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = TRIM(cDetalleErr), estatus = cEstatus, fecha = current
						WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
						LET iTransaccion = 0;
						RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
						CONTINUE FOREACH;
					ELSE
						IF cTabla = 'dg_expediente' THEN
							--LOG
							EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente 2',cUsuario) INTO cRetornoLog;
							INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
							VALUES('DG_EXPEDIENTE', 'dg_expediente', cCteTit, cCteTras, TRIM(cTramaDetalle)||'DOCUMENTO ELIMINADO', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
						
							IF cTabla1 = 'dg_expediente_img' THEN
								--LOG
								EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente_img 2',cUsuario) INTO cRetornoLog;
								INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
								VALUES('DG_EXPEDIENTE', 'dg_expediente_img', cCteTit, cCteTras, TRIM(cTramaDetalle)||'DOCUMENTO ELIMINADO', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
								
								IF cTabla2 = 'dg_expediente_img_his' THEN
									--LOG
									EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente_his 2',cUsuario) INTO cRetornoLog;
									INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
									VALUES('DG_EXPEDIENTE', 'dg_expediente_img_his', cCteTit, cCteTras, TRIM(cTramaDetalle)||'DOCUMENTO ELIMINADO', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
								END IF;	
							END IF;
						END IF;
					END IF;
				END IF;
					
			END FOREACH
				IF cCodRet = '000000' THEN
					LET cEstatus = 1;
					--SE CAMBIA ESTATUS A 1, SE INSERTA YA QUE FUE EXITOSO.
					EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Actualiza en si_desfusionctes: proceso exitoso',cUsuario) INTO cRetornoLog;
					UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = 'CLIENTE DESFUSIONADO', estatus = cEstatus, fecha = current
					WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
				END IF;

				IF iContador > 0 THEN
					COMMIT WORK;
					LET iContador =0;
					LET iTransaccion = 0;
				END IF;

			RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
		END;
	END FOREACH

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000002';
		LET cDetalleErr = 'REPOSITORIO SIN CLIENTES';
		RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), '','';
	END IF;

END;
END PROCEDURE
DOCUMENT
'--------------------------------------------------------------------------------------------------------------',
'Folio: 1399',
'Autor: 92893422',
'Fecha: 21/01/2014',
'Descripción: ',
'Sustento: Desfusion de Clientes v1.4.doc',
'Solicita: Armando Morales Barraza',
'----------------------------------------------',
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 27/ENE/2015',
'DESCRIPCION: Se modifica contemplar el nuevo campo tp_biometria de la tabla si_cliente',
'SUSTENTO: RQI 64 068',
'SOLICITA: Jose Angel Lopez Adams',
'----------------------------------------------',
'FECHA: 22/ENE/2016',
'DESCRIPCION: Se modifica para ejecutar el SP sp_desfusion_ctesdigital sobre la BD bdinteg de la instancia OLTP',
'SUSTENTO: RQI 64 141',
'SOLICITA: Jose Angel Lopez Adams',
'BD:BDINTEG';

CREATE PROCEDURE "informix".sp_cnsif_aclaraciones(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(12), cNUMTARJETA CHAR(16),dPERIODOI  DATE, dPERIODOF DATE,pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)     AS Cod_Retorno,
						  CHAR(11)    AS Ticket,
						  CHAR(50)    AS Evento,
						  CHAR(255)   AS Status,
						  MONEY(14,2) AS Importe,
						  MONEY(14,2) AS Abono,
						  DATE        AS Fecha_Captura,
						  DATE        AS Fecha_Solucion,
						  CHAR(04)    AS Sucursal,
						  CHAR(04)    AS Cve_Documento,
						  SMALLINT    AS Secuencia;
										
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
--VARIABLES
DEFINE cTicket	       CHAR(11);
DEFINE cEvento	       CHAR(50);
DEFINE cStatus	       CHAR(255);
DEFINE mImporte		   MONEY(14,2);
DEFINE mAbono		   MONEY(14,2);
DEFINE dFechaCaptura   DATE;
DEFINE dFechaSolucion  DATE;
DEFINE cSucursal       CHAR(04);
DEFINE cCveDoc	       CHAR(04);
DEFINE smallSecuencia  SMALLINT;

DEFINE iFkyCliente      INTEGER;
DEFINE iPkyProducto     INTEGER;
DEFINE iFkyTipoProd     INTEGER;
DEFINE iPkyTipoEvento   INTEGER;
DEFINE iFkyStatusAclara INTEGER;
DEFINE iPkyAclaracion   INTEGER;
DEFINE iPkySucursal     INTEGER;

DEFINE cNumCliente      CHAR(20);
DEFINE cGrupoDoc        CHAR(04);
DEFINE cCodDef          CHAR(04);


DEFINE iCont            INTEGER;

--INICIALIZA VARIABLES
LET  iexiste 		    = 0;
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	

LET cTicket             ="";
LET cEvento 			= "";
LET cStatus				= "";
LET mImporte			= 0;
LET mAbono		        = 0;
LET dFechaCaptura       = "";
LET dFechaSolucion  	= "";
LET cSucursal       	= "";
LET cCveDoc	       		= "";
LET smallSecuencia  	= 0;

LET iFkyCliente      = 0;
LET iPkyProducto     = 0;
LET iFkyTipoProd     = 0;
LET iPkyTipoEvento   = 0;
LET iFkyStatusAclara = 0;
LET iPkyAclaracion   = 0;
LET iPkySucursal     = 0;

LET cNumCliente      = '';
LET cGrupoDoc        = '';
LET cCodDef          = '';

LET iCont            = 0;



BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
		END IF;
	END EXCEPTION;
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_aclaraciones.out";
	--  TRACE ON;

SET LOCK MODE TO WAIT 3;

	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR (cNUMCUENTA   = '' AND cNUMTARJETA  = '') OR
		dPERIODOI    = ''   OR
		dPERIODOF    = ''   THEN 
		LET cCodRet = "00054";
		RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
	END IF;	
    
    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;					
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
        END IF;
    END IF;    
	--VALIDACION
	IF cNUMCUENTA <> '' THEN
        IF SUBSTR(cNUMCUENTA,1,1)='3' THEN    
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
            INTO
            cCodRet;
        ELIF SUBSTR(cNUMCUENTA,1,1)='6' THEN      
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
            INTO
            cCodRet;  
        ELSE
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'11','1')
            INTO
            cCodRet;
        END IF;
	ELSE
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMTARJETA,'11','3')
		INTO
		cCodRet;
	END IF
	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;					
	END IF;
	-- TERMINA VALIDACION		
	SET ISOLATION TO DIRTY READ;
    IF cNUMCUENTA<>'' THEN
        SELECT NVL(COUNT(num_cliente),0) into iexiste FROM bdiaclaracion:acl_producto WHERE numero_cuenta  = cNUMCUENTA;
	ELSE
        SELECT NVL(COUNT(num_cliente),0) into iexiste FROM bdiaclaracion:acl_producto WHERE numero_tarjeta = cNUMTARJETA;
    END IF;
	IF iexiste  = 0 THEN 
        LET cCodRet = "00058";
        RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
    END IF;

    IF cNUMCUENTA<>'' THEN
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT  
            num_cliente,pky_producto,fky_tipo_producto
            INTO 		
            cNumCliente,iPkyProducto,iFkyTipoProd
            FROM bdiaclaracion:acl_producto
            WHERE numero_cuenta = cNUMCUENTA

            SET ISOLATION TO DIRTY READ;
            FOREACH

                SELECT {+INDEX (bdiaclaracion:"informix".acl_aclaracion 132_91)} SKIP pNumRegistro FIRST pRecuperacion
                folio_csuac AS ticket,
                importereclamado AS importe, 
                CASE 
                WHEN fky_estatus_corp_general = 8 THEN importereclamado ELSE null END AS Abono,
                fechacaptura,
                CASE 
                WHEN fecha_dictamen IS NULL THEN null ELSE fecha_dictamen END AS fecha_solucion,
                fky_tipo_evento,
                fky_estatus_aclaracion,
                pky_aclaracion
                INTO
                cTicket,mImporte,mAbono,dFechaCaptura,dFechaSolucion,iPkyTipoEvento,iFkyStatusAclara,iPkyAclaracion
                FROM bdiaclaracion:acl_aclaracion
                WHERE num_cliente = cNumCliente
                AND fky_producto = iPkyProducto
                AND fecha_dictamen::DATE BETWEEN dPERIODOI AND dPERIODOF ORDER BY folio_csuac

                SELECT descripcion,grupo_doc
                INTO cEvento,cGrupoDoc
                FROM bdiaclaracion:acl_tipo_evento
                WHERE pky_tipo_evento = iPkyTipoEvento;


                SELECT FIRST 1 cod_definicion
                INTO cCodDef
                FROM bdidigital@coppelimg_tcp:dg_definicion
                WHERE cod_producto = cGrupoDoc;

                IF LENGTH(cCodDef) = 3 THEN
                    LET cCodDef = '0' || cCodDef;
                END IF

                SELECT descripcion AS Estatus
                INTO cStatus
                FROM bdiaclaracion:acl_estatus_aclaracion
                WHERE pky_estatus_aclaracion = iFkyStatusAclara;

                SELECT --+AVOID_FULL (bdiaclaracion:"informix".acl_movimiento)
				NVL(num_sucursal,'') INTO cSucursal FROM bdiaclaracion:acl_movimiento WHERE fky_aclaracion = iPkyAclaracion;

                SET ISOLATION TO DIRTY READ;
                SELECT cod_docto,secuencia 
                INTO cCveDoc,smallSecuencia
                FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                -- AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef
                AND secuencia =(SELECT max(secuencia) FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                --AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef);

                LET iCont=iCont+1;

                RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia With Resume;

            END FOREACH;
        END FOREACH;            
    ELSE
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT  
            num_cliente,pky_producto,fky_tipo_producto
            INTO 		
            cNumCliente,iPkyProducto,iFkyTipoProd
            FROM bdiaclaracion:acl_producto
            WHERE numero_tarjeta = cNUMTARJETA

            SET ISOLATION TO DIRTY READ;
            FOREACH

                SELECT {+INDEX (bdiaclaracion:"informix".acl_aclaracion 132_91)} SKIP pNumRegistro FIRST pRecuperacion
                folio_csuac AS ticket,
                importereclamado AS importe, 
                CASE 
                WHEN fky_estatus_corp_general = 8 THEN importereclamado ELSE null END AS Abono,
                fechacaptura,
                CASE 
                WHEN fecha_dictamen IS NULL THEN null ELSE fecha_dictamen END AS fecha_solucion,
                fky_tipo_evento,
                fky_estatus_aclaracion,
                pky_aclaracion
                INTO
                cTicket,mImporte,mAbono,dFechaCaptura,dFechaSolucion,iPkyTipoEvento,iFkyStatusAclara,iPkyAclaracion
                FROM bdiaclaracion:acl_aclaracion
                WHERE num_cliente = cNumCliente
                AND fky_producto = iPkyProducto
                AND fecha_dictamen::DATE BETWEEN dPERIODOI AND dPERIODOF ORDER BY folio_csuac

                SELECT descripcion,grupo_doc
                INTO cEvento,cGrupoDoc
                FROM bdiaclaracion:acl_tipo_evento
                WHERE pky_tipo_evento = iPkyTipoEvento;


                SELECT FIRST 1 cod_definicion
                INTO cCodDef
                FROM bdidigital@coppelimg_tcp:dg_definicion
                WHERE cod_producto = cGrupoDoc;

                IF LENGTH(cCodDef) = 3 THEN
                    LET cCodDef = '0' || cCodDef;
                END IF

                SELECT descripcion AS Estatus
                INTO cStatus
                FROM bdiaclaracion:acl_estatus_aclaracion
                WHERE pky_estatus_aclaracion = iFkyStatusAclara;

                SELECT --+AVOID_FULL (bdiaclaracion:"informix".acl_movimiento)
				NVL(num_sucursal,'') INTO cSucursal FROM bdiaclaracion:acl_movimiento WHERE fky_aclaracion = iPkyAclaracion;

                SET ISOLATION TO DIRTY READ;
                SELECT cod_docto,secuencia 
                INTO cCveDoc,smallSecuencia
                FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                --AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef
                AND secuencia =(SELECT max(secuencia) FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                --AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef);

                LET iCont=iCont+1;

                RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia With Resume;

            END FOREACH;
        END FOREACH;            
    END IF;
    IF iCont = 0 THEN
        IF pNumRegistro=0 THEN
            LET cCodRet = '00091'; 
        ELSE
            LET cCodRet = '1001'; 
        END IF;
        RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
    END IF 
END

END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de Aclaraciones asociadas a un Cliente. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el Número de Cuenta.",
"FECHA : 23-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".img_sol_rec_clientes(pempresa char(3))
RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_cliente char(9);
   DEFINE v_cod_docto char(4);
   DEFINE v_secuencia smallint;
   DEFINE sql_err,isam_err int; 
   define v_cuenta char(20);
   define v_producto char(04);
   define v_tipo_cliente char(01);
   --define v_contador smallint;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_cliente     = "";
   LET v_cod_docto    = "";
   LET v_secuencia = 0;
   let v_cuenta = "";
   let v_producto = "";
   let v_tipo_cliente = "";
   --let v_contador = 0;


BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;

--SET DEBUG FILE TO '/tmp/img_sol_rec_2';
--TRACE ON;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa is null THEN
    
       -- datos de entrada incompletos
       
       LET v_codret = 110; 
       RETURN v_codret; 
    END IF;

--------------------RGH

	

        FOREACH WITH HOLD

	    SELECT numcte, tipo_cliente
            INTO v_cliente, v_tipo_cliente
            FROM bdidigital@coppelimg_tcp:tmp_cliente 
            WHERE tipo_cliente <> '5'
	

            BEGIN WORK;

            FOREACH WITH HOLD
                SELECT cod_docto,secuencia, cuenta, producto
                INTO v_cod_docto, v_secuencia, v_cuenta, v_producto
                FROM bdidigital@coppelimg_tcp:dg_expediente 
                WHERE cliente = v_cliente
                --WHERE empresa = pempresa

		 --BEGIN WORK;

                    DELETE FROM bdidigital@coppelimg_tcp:dg_expediente_img
                    WHERE empresa = pempresa
                    AND cliente = v_cliente
                    AND cod_docto = v_cod_docto
                    AND secuencia = v_secuencia;

                    DELETE FROM bdidigital@coppelimg_tcp:dg_expediente
                    --WHERE empresa = pempresa
                    WHERE cliente = v_cliente
                    AND cod_docto = v_cod_docto
                    and cuenta = v_cuenta
                    AND producto = v_producto
                    AND secuencia = v_secuencia;
	            
		--COMMIT WORK;

            END FOREACH;

            update bdidigital@coppelimg_tcp:tmp_cliente
            set tipo_cliente = '5'
            where numcte = v_cliente;

            if (v_tipo_cliente = '1') then
                update bdinteg:si_cliente 
                set tipo_cliente = '2'
                where numcte = v_cliente;
            end if;

		COMMIT WORK;

		--LET v_contador = v_contador + 1;
	
		--IF (v_contador <= 100) THEN
			--CONTINUE FOREACH;
		--ELSE 
			--LET v_codret = '000';
			--RETURN v_codret;
		--END IF;
	

	    END FOREACH;


	

END;    

RETURN v_codret;

END PROCEDURE;