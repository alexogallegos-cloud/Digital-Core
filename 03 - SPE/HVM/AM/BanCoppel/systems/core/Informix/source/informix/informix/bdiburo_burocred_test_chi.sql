CREATE PROCEDURE "informix".burocred_test_chi (
    pApePaterno CHAR(26)	, pApeMaterno CHAR(26)	, pPrimerNom CHAR(26)	, pSegundoNom CHAR(26)	, pFecNac CHAR(10), 
    pRFC CHAR(13)			, pTipoRes CHAR(1)		, pEdoCivil CHAR(1) 	, pSexo CHAR(1)			, pDependientes CHAR(2),
    pDireccion1 CHAR(40)	, pDireccion2 CHAR(40)	, pColonia CHAR(40) 	, pDelegacion CHAR(40)	, pCiudad CHAR(40), 
    pEstado CHAR(4)			, pCodigoPostal CHAR(5)	, pTipoDomicilio CHAR(1), pFolio CHAR(25)		, pProducto CHAR(2),
	pStatus CHAR(2)
) RETURNING CHAR(5) AS codret;

---------------DECLARACION DE VARIABLES
	DEFINE vregistro CHAR(255);
	DEFINE vregistro1 CHAR(255);
	DEFINE vregistro2 CHAR(255);
	DEFINE vcliente CHAR(20);
	DEFINE vlen INTEGER;
	DEFINE vpos CHAR(2);
	DEFINE vpo1 CHAR(5);
	DEFINE vdia CHAR(2);
	DEFINE vmes CHAR(2);
	DEFINE vanio CHAR(4);
	-- Variables para ver si se va a Buro o no --
	DEFINE vf1mes DATE;
	DEFINE vstatus CHAR(2);
	DEFINE vcodret CHAR(5);
	DEFINE vecampo1 CHAR(4);
	DEFINE vecampo2 CHAR(2);
	DEFINE vecampo3 CHAR(25);
	DEFINE vecampo4 CHAR(3);
	DEFINE vecampo5 CHAR(2);
	DEFINE vecampo6 CHAR(4);
	DEFINE vecampo7 CHAR(10);
	DEFINE vecampo8 CHAR(8);
	DEFINE vecampo9 CHAR(1);
	DEFINE vecampo10 CHAR(2);
	DEFINE vecampo11 CHAR(2);
	DEFINE vecampo12 CHAR(9);
	DEFINE vecampo13 CHAR(2);
	DEFINE vecampo14 CHAR(2);
	DEFINE vecampo15 CHAR(1);
	DEFINE vecampo16 CHAR(4);
	DEFINE vecampo17 CHAR(7);
	DEFINE vexiste INTEGER;
	DEFINE vcodini INTEGER;
	DEFINE vcodfin INTEGER;
	-- Datos del Cliente --
	DEFINE vdcampo1 CHAR(2);
	DEFINE vdcampo2 CHAR(26);
	DEFINE vdcampo3 CHAR(26);
	DEFINE vdcampo4 CHAR(26);
	DEFINE vdcampo5 CHAR(26);
	DEFINE vdcampo6 CHAR(10);
	DEFINE vdcampo7 CHAR(13);
	DEFINE vdcampo8 CHAR(2);
	DEFINE vdcampo9 CHAR(1);
	DEFINE vdcampo10 CHAR(1);
	DEFINE vdcampo11 CHAR(1);
	DEFINE vdcampo12 CHAR(2);
	DEFINE vscampo1 CHAR(2);
	DEFINE vscampo2 CHAR(40);
	DEFINE vscampo3 CHAR(40);
	DEFINE vscampo4 CHAR(40);
	DEFINE vscampo5 CHAR(40);
	DEFINE vscampo6 CHAR(40);
	DEFINE vscampo7 CHAR(4);
	DEFINE vscampo8 CHAR(5);
	DEFINE vscampo8a INTEGER;
	DEFINE vscampo9 CHAR(1);
	DEFINE vexiste1 SMALLINT;
	DEFINE vquita CHAR(40);
	DEFINE vespacio CHAR(1);
	DEFINE vmanzana SMALLINT;
	DEFINE vandador SMALLINT;
	DEFINE vlote SMALLINT;
	DEFINE vedificio SMALLINT;
	DEFINE ventrada SMALLINT;
	DEFINE vsecuencia SMALLINT;
	DEFINE vcomentario CHAR(80);
	DEFINE vhora DATETIME HOUR TO fraction(3);
	DEFINE vfecha DATE;
	DEFINE status_1 CHAR(2);	DEFINE status_2 CHAR(2);	DEFINE producto_sol CHAR(20);
	DEFINE siglas_producto CHAR(2);
	DEFINE cResultado CHAR(6);
	DEFINE cMensajeRes CHAR(8);
	DEFINE iSql_err INTEGER;
	DEFINE vnumerocalle INTEGER;
	DEFINE iFlag2credito SMALLINT;
	DEFINE valida_hit CHAR(1);
	---------------INICIALIZACION DE VARIABLES
	LET vhora = extend(CURRENT, HOUR TO fraction(3));
	LET vregistro = "";
	LET vregistro1 = "";
	LET vregistro2 = "";
	LET vcliente = "";
	LET vlen = 0;
	LET vpos = "";
	LET vdia = "";
	LET vmes = "";
	LET vanio = "";
	LET vf1mes = "";
	LET vstatus = "";
	LET vcodret = "000";
	LET status_1 = "00";
	LET status_2 = "00";
	LET producto_sol = "";
	LET siglas_producto = "";
	LET cResultado = "";
	LET cMensajeRes = "";
	LET iSql_err = 0;
	LET vpo1 = "";
	LET vecampo1 = "";
	LET vecampo2 = "";
	LET vecampo3 = "";
	LET vecampo4 = "";
	LET vecampo5 = "";
	LET vecampo6 = "";
	LET vecampo7 = "";
	LET vecampo8 = "";
	LET vecampo9 = "";
	LET vecampo10 = "";
	LET vecampo11 = "";
	LET vecampo12 = "";
	LET vecampo13 = "";
	LET vecampo14 = "";
	LET vecampo15 = "";
	LET vecampo16 = "";
	LET vecampo17 = "";
	LET vexiste = 0;
	LET vcodini = 0;
	LET vcodfin = 0;
	LET vdcampo1 = "";
	LET vdcampo2 = "";
	LET vdcampo3 = "";
	LET vdcampo4 = "";
	LET vdcampo5 = "";
	LET vdcampo6 = "";
	LET vdcampo7 = "";
	LET vdcampo8 = "";
	LET vdcampo9 = "";
	LET vdcampo10 = "";
	LET vdcampo11 = "";
	LET vdcampo12 = "";
	LET vscampo1 = "";
	LET vscampo2 = "";
	LET vscampo3 = "";
	LET vscampo4 = "";
	LET vscampo5 = "";
	LET vscampo6 = "";
	LET vscampo7 = "";
	LET vscampo8 = "";
	LET vscampo8a = 0;
	LET vscampo9 = "";
	LET vexiste1 = 0;
	LET vquita = "";
	LET vespacio = "";
	LET vmanzana = 0;
	LET vandador = 0;
	LET vlote = 0;
	LET vedificio = 0;
	LET ventrada = 0;
	LET vsecuencia = 0;
	LET vcomentario = "";
	LET vnumerocalle = 0;
	LET iFlag2credito = 0;
	LET valida_hit = "";
	
	BEGIN
		--CONTROL DE ERRORES--
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN 
				LET vcodret = iSql_err;
				RETURN vcodret;
			END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/informix/jesus/burocred.out';
		--  TRACE ON;
		
		--SET DEBUG FILE TO '/informix/autenticador/burocred_test.out';   
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT fecha_hoy
		INTO vfecha
		FROM bdicred: "informix".sd_fechas;
		
		LET vstatus = 'BC';
		
		SELECT TRIM(valor)
		INTO vecampo7
		FROM "informix".br_param
		WHERE cod_param = 124;
		
		SELECT TRIM(valor)
		INTO vecampo8
		FROM "informix".br_param
		WHERE cod_param = 125;
		
		-- Declaracion de Constantes para Generacion de Registros desea ver que significa cada campo
		-- Favor de consultar el manual -->
		LET vecampo1 = "INTL";
		LET vecampo2 = "11";
		--- COLOCACION DE NUMERO DE SOLICITUD
		LET vecampo3 = pFolio || "     ";
		LET vecampo4 = "001";
		LET vecampo5 = "MX";
		LET vecampo6 = "0000";
		--LET vecampo7    = "";
		--LET vecampo8    = "";
		LET vecampo9 = "I";
		LET vecampo10 = "";
		LET vecampo11 = "MX";
		LET vecampo12 = "0";		LET vecampo13 = "SP";
		LET vecampo14 = "03";
		LET vecampo15 = " ";
		LET vecampo16 = "    ";
		LET vecampo17 = "0000000";
		LET vexiste = 0;
		LET vcomentario = "";
		
		SELECT TRIM(valor)
		INTO vecampo4
		FROM "informix".br_param
		WHERE cod_param = 126;
		
		--IPCB falto asignacion de valor CC
		LET siglas_producto = 'CC';
		LET vecampo10 = siglas_producto; --CC;
		LET status_2 = pStatus; --BC;
		--IPCB Falto completado de 0 en el campo 12
		LET vecampo12 = LPAD(round(vecampo12, 0), 9, "0");
		LET vregistro = vecampo1 || vecampo2 || vecampo3 || vecampo4 || vecampo5 || 
			vecampo6 || vecampo7 || vecampo8 || vecampo9 || vecampo10 || 
			vecampo11 || vecampo12 || vecampo13 || vecampo14 || vecampo15 || 
			vecampo16 || vecampo17;
		-- Datos del Cliente --
		LET vdcampo1 = "PN";		LET vdcampo2 = pApePaterno;		LET vdcampo3 = pApeMaterno;		LET vdcampo4 = pPrimerNom;		LET vdcampo5 = pSegundoNom;		LET vdcampo6 = pFecNac;		LET vdcampo7 = pRFC;		LET vdcampo8 = "MX";		LET vdcampo9 = pTipoRes;		LET vdcampo10 = pEdoCivil;		LET vdcampo11 = pSexo;		LET vdcampo12 = pDependientes;			-- Direccion del Cliente --
		LET vscampo1 = "PA";		LET vscampo2 = pDireccion1;		LET vscampo3 = pDireccion2;		LET vscampo4 = pColonia;		LET vscampo5 = pDelegacion;		LET vscampo6 = pCiudad;		LET vscampo7 = pEstado;		LET vscampo8 = pCodigoPostal;		LET vscampo9 = pTipoDomicilio;		
		-- Cambia las Ã?Â? de los Nombres y Apellidos --
		IF vdcampo2 IS NULL THEN 
			LET vdcampo2 = "";
			LET vcomentario = "Apellido paterno nulo";
		END IF;
		
		IF vdcampo3 IS NULL THEN 
			LET vdcampo3 = "NO PROPORCIONADO";
		END IF;
		
		IF vdcampo4 IS NULL THEN 
			LET vdcampo4 = "";
			LET vcomentario = TRIM(vcomentario) || " Sin nombre";
		END IF;
		
		IF vdcampo5 IS NULL THEN 
			LET vdcampo5 = "";
		END IF;
		
		IF vdcampo6 IS NULL THEN 
			LET vdcampo6 = "";
		END IF;
		
		IF vdcampo7 IS NULL THEN 
			LET vdcampo7 = "";
		END IF;
		
		IF vdcampo9 IS NULL THEN 
			LET vdcampo9 = "";
		END IF;
		
		IF vdcampo10 IS NULL THEN 
			LET vdcampo10 = "";
		END IF;
		
		IF vdcampo11 IS NULL THEN 
			LET vdcampo11 = "";
		END IF;
		
		IF vdcampo12 IS NULL THEN 
			LET vdcampo12 = "0";
		END IF;
		
		LET vexiste = LENGTH(vdcampo2);
		LET vexiste1 = 0;
		LET vquita = "";
		LET vespacio = " ";
		
		WHILE vexiste1 < vexiste
			IF vdcampo2 [1,1] = "~"
				OR vdcampo2 [1,1] = " "
				OR vdcampo2 [1,1] = "."
				OR vdcampo2 [1,1] = "-" THEN 
				LET vespacio = "F";
			ELSE
				IF vespacio = "F" THEN
					IF vdcampo2 [1,1] = "#"
						OR vdcampo2 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || " Ã?";
					ELSE
						LET vquita = TRIM(vquita) || " " || vdcampo2 [1,1];
					END IF 
					
					LET vespacio = "";
				ELSE
					IF vdcampo2 [1,1] = "#"
						OR vdcampo2 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || "Ã?";
					ELSE
						LET vquita = TRIM(vquita) || vdcampo2 [1,1];
					END IF 
				END IF 
			END IF;
			
			LET vdcampo2 = vdcampo2 [2,26];
			LET vexiste1 = vexiste1 + 1;
		END WHILE;
		
		LET vdcampo2 = TRIM(vquita);
		LET vexiste = LENGTH(vdcampo3);
		--- CAMBIO DE APELLIDO MATERNO
		IF vexiste = 0 THEN LET vdcampo3 = "NO PROPORCIONADO";
			LET vexiste = LENGTH(vdcampo3);
		END IF 
		
		LET vexiste1 = 0;
		LET vquita = "";
		LET vespacio = " ";
		
		WHILE vexiste1 < vexiste
			IF vdcampo3 [1,1] = "~"
				OR vdcampo3 [1,1] = " "
				OR vdcampo3 [1,1] = "."
				OR vdcampo3 [1,1] = "-" THEN 
				LET vespacio = "F";
			ELSE 
				IF vespacio = "F" THEN
					IF vdcampo3 [1,1] = "#"
						OR vdcampo3 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || " Ã?";
					ELSE
						LET vquita = TRIM(vquita) || " " || vdcampo3 [1,1];
					END IF 
					LET vespacio = "";
				ELSE
					IF vdcampo3 [1,1] = "#"
						OR vdcampo3 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || "Ã?";
					ELSE
						LET vquita = TRIM(vquita) || vdcampo3 [1,1];
					END IF 
				END IF 
			END IF;
			
			LET vdcampo3 = vdcampo3 [2,26];
			LET vexiste1 = vexiste1 + 1;
		END WHILE;
		
		LET vdcampo3 = TRIM(vquita);
		LET vexiste = LENGTH(vdcampo4);
		LET vexiste1 = 0;
		LET vquita = "";
		LET vespacio = " ";
		
		WHILE vexiste1 < vexiste
			IF vdcampo4 [1,1] = "~"
				OR vdcampo4 [1,1] = " "
				OR vdcampo4 [1,1] = "."
				OR vdcampo4 [1,1] = "-" THEN 
				LET vespacio = "F";
			ELSE
				IF vespacio = "F" THEN
					IF vdcampo4 [1,1] = "#"
						OR vdcampo4 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || " Ã?";
					ELSE
						LET vquita = TRIM(vquita) || " " || vdcampo4 [1,1];
					END IF 
					LET vespacio = "";
				ELSE
					IF vdcampo4 [1,1] = "#"
						OR vdcampo4 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || "Ã?";
					ELSE
					LET vquita = TRIM(vquita) || vdcampo4 [1,1];
					END IF 
				END IF 
			END IF;
		
			LET vdcampo4 = vdcampo4 [2,26];
			LET vexiste1 = vexiste1 + 1;
		END WHILE;
		
		LET vdcampo4 = TRIM(vquita);
		LET vexiste = LENGTH(vdcampo5);
		LET vexiste1 = 0;
		LET vquita = "";
		LET vespacio = " ";
		
		WHILE vexiste1 < vexiste
			IF vdcampo5 [1,1] = "~"
				OR vdcampo5 [1,1] = " "
				OR vdcampo5 [1,1] = "."
				OR vdcampo5 [1,1] = "-" THEN 
				LET vespacio = "F";
			ELSE
				IF vespacio = "F" THEN
					IF vdcampo5 [1,1] = "#"
						OR vdcampo5 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || " Ã?";
					ELSE
						LET vquita = TRIM(vquita) || " " || vdcampo5 [1,1];
					END IF 
					LET vespacio = "";
				ELSE 
					IF vdcampo5 [1,1] = "#"
						OR vdcampo5 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || "Ã?";
					ELSE
						LET vquita = TRIM(vquita) || vdcampo5 [1,1];
					END IF 
				END IF 
			END IF;
			
			LET vdcampo5 = vdcampo5 [2,26];
			LET vexiste1 = vexiste1 + 1;
		END WHILE ;
		
		LET vdcampo5 = TRIM(vquita);
		
		IF vdcampo9 = "P"
			OR vdcampo9 = "G" THEN 
			LET vdcampo9 = "1";
		ELSE
			IF vdcampo9 = "R" THEN 
				LET vdcampo9 = "2";
			ELSE
				IF vdcampo9 = "F"
					OR vdcampo9 = "H" THEN 
					LET vdcampo9 = "3";
				ELSE
					LET vdcampo9 = "";
				END IF 
			END IF 
		END IF 
					
		IF vdcampo10 = "D" THEN 
			LET vdcampo10 = "D";
		ELSE
			IF vdcampo10 = "U" THEN 
				LET vdcampo10 = "F";
			ELSE
				IF vdcampo10 = "C" THEN 
					LET vdcampo10 = "M";
				ELSE
					IF vdcampo10 = "S" THEN 
						LET vdcampo10 = "S";
					ELSE
						IF vdcampo10 = "V" THEN 
							LET vdcampo10 = "W";
						END IF 
					END IF 
				END IF 
			END IF 
		END IF 
		-- Carga los datos de la Direccion del Cliente --
		--SELECT MAX(secuencia) INTO vsecuencia
		--  FROM bdinteg:"informix".si_direcciones
		--           WHERE  numcte=vcliente AND tipo_dir='1';
		--SELECT TRIM(f.nombrecalle),
		--     REPLACE(NVL(TRIM(a.numeroextcalle)," ")||" "||NVL(TRIM(a.numerointcalle)," "),'	',''),--Se quitan los tabuladores INC 21 119
		--     TRIM(g.nombrezona), 
		-- TRIM(g.municipiozona), TRIM(c.estado), lpad(TRIM(a.cod_postal),5,"0"), a.tipo_dir,
		--     manzana,andador,lote,edificio,entrada,codini,codfin, nvl(a.numerocalle,0)
		-- INTO   vscampo2, vscampo3, vscampo4,
		--        vscampo6, vscampo7,vscampo8,vscampo9,
		--        vmanzana,vandador,vlote,vedificio,ventrada,vcodini,vcodfin, vnumerocalle
		-- FROM  bdinteg:"informix".si_direcciones_actual as a,
		--           bdisolic:"informix".ss_circulo_edos as c,
		--           bdinteg:"informix".si_catcalles f,
		--           bdinteg:"informix".si_catzonas g
		-- WHERE  a.numcte=vcliente AND a.tipo_dir = '1' 
		--   AND c.clave = a.estado 
		--   AND g.numerociudad = a.numerociudad
		--   AND g.numerocolonia = a.numerocolonia
		--   AND f.numerocalle = a.numerocalle;	
		--	IF (vscampo2 is null or vnumerocalle = 0) and (SELECT COUNT(num_solicitud) 					
		--		FROM bdisolic:"informix".ss_solicitudes_movil							
		--			WHERE 	empresa  = pEmpresa 
		--			AND  num_solicitud = pSolicitud
		--			AND status <> '3' ) > 0 THEN				
		--          SELECT TRIM(a.calle),
		--          REPLACE(NVL(TRIM(a.numeroextcalle)," ")||" "||NVL(TRIM(a.numerointcalle)," "),'	',''),--Se quitan los tabuladores INC 21 119
		--          TRIM(g.nombrezona), 
		--          TRIM(g.municipiozona), TRIM(c.estado), lpad(TRIM(a.cod_postal),5,"0"), a.tipo_dir,
		--          manzana,andador,lote,edificio,entrada,codini,codfin 
		--          INTO   vscampo2, vscampo3, vscampo4,
		--          vscampo6, vscampo7,vscampo8,vscampo9,
		--          vmanzana,vandador,vlote,vedificio,ventrada,vcodini,vcodfin
		--          FROM  bdinteg:"informix".si_direcciones_actual as a,
		--               bdisolic:"informix".ss_circulo_edos as c,					 
		--               bdinteg:"informix".si_catzonas g
		--          WHERE  a.numcte=vcliente AND a.tipo_dir = '1' 
		--          AND c.clave = a.estado 
		--          AND g.numerociudad = a.numerociudad
		--          AND g.numerocolonia = a.numerocolonia;								
		--	END IF;		
		--LET vscampo2=pDireccion1; --Direccion Linea 1 PA--
		--LET vscampo3=pDireccion2; --Direccion Linea 2 00--
		--LET vscampo4=pColonia; --Colonia o Poblacion 01--
		--LET vscampo5=pDelegacion; --Delegacion o Municipio 02--
		--LET vscampo6=pCiudad; --Nombre Ciudad 03--
		--LET vscampo7=pEstado; --Estado 04--
		--LET vscampo8=pCodigoPostal; --Codigo Postal 05--
		--LET vscampo9=pTipoDomicilio; --Tipo de Domicilio 10--
		
		IF vscampo2 IS NULL THEN 
			LET vscampo2 = "";
			LET vcomentario = TRIM(vcomentario) || " Sin calle ";
		END IF;
		
		IF vscampo3 IS NULL THEN LET vscampo3 = "";END
			IF;
				IF vscampo4 IS NULL THEN LET vscampo4 = "";END
					IF;
						IF vscampo5 IS NULL THEN LET vscampo5 = "";END
							IF;
								IF vscampo6 IS NULL THEN LET vscampo6 = "";
									LET vcomentario = TRIM(vcomentario) || " Sin localidad ";
		END IF;
			
		IF vscampo7 IS NULL THEN 
			LET vscampo7 = "";
			LET vcomentario = TRIM(vcomentario) || " Sin estado ";
		END IF;
		
		IF vscampo8 IS NULL THEN 
			LET vscampo8 = "";
			LET vcomentario = TRIM(vcomentario) || " Sin codigo postal ";
		END IF;
		
		IF vscampo9 IS NULL THEN 
			LET vscampo9 = "";
		END IF;
		
		LET vscampo2 = TRIM(vscampo2) || " " || TRIM(vscampo3);
		LET vexiste = LENGTH(vscampo2);
		
		IF vexiste < 26 THEN 
			LET vscampo3 = "";
			IF vmanzana > 0 THEN 
				LET vscampo3 = "mza " || vmanzana;
			END IF 
			
			IF vandador > 0 THEN 
				LET vscampo3 = TRIM(vscampo3) || "AND " || vandador;
			END IF 
			
			IF vlote > 0 THEN 
				LET vscampo3 = TRIM(vscampo3) || "lt " || vlote;
			END IF 
			
			IF vedificio > 0 THEN 
				LET vscampo3 = TRIM(vscampo3) || "ed " || vedificio;
			END IF 
			
			IF ventrada > 0 THEN 
				LET vscampo3 = TRIM(vscampo3) || "ent " || ventrada;
			END IF 
			
			LET vscampo2 = TRIM(vscampo2) || ' ' || TRIM(vscampo3);
		END IF 
		
		LET vscampo2 = TRIM(vscampo2);
		LET vexiste = LENGTH(vscampo2);
		LET vexiste1 = 0;
		LET vquita = "";
		LET vespacio = " ";
		
		WHILE vexiste1 < vexiste
			IF vscampo2 [1,1] = "~"
				OR vscampo2 [1,1] = " "
				OR vscampo2 [1,1] = "."
				OR vscampo2 [1,1] = "-" THEN 
				LET vespacio = "F";
			ELSE
				IF vespacio = "F" THEN
					IF vscampo2 [1,1] = "#"
						OR vscampo2 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || " Ã?";
					ELSE
						LET vquita = TRIM(vquita) || " " || vscampo2 [1,1];
					END IF 
					LET vespacio = "";
				ELSE
					IF vscampo2 [1,1] = "#"
						OR vscampo2 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || "Ã?";
					ELSE
						LET vquita = TRIM(vquita) || vscampo2 [1,1];
					END IF 
				END IF 
			END IF;
			LET vscampo2 = vscampo2 [2,26];
			LET vexiste1 = vexiste1 + 1;
		END WHILE;
		
		LET vscampo2 = TRIM(vquita);
		
		IF vscampo9 = "1" THEN 
			LET vscampo9 = "H";ELSE
			IF vscampo9 = "2" THEN 
				LET vscampo9 = "B";
			ELSE
				LET vscampo9 = "H";
			END IF 
		END IF 
		
		LET vregistro = TRIM(vregistro) || vdcampo1;
		LET vlen = LENGTH(vdcampo2);
		LET vpos = LPAD(vlen, 2, "0");
		LET vregistro = TRIM(vregistro) || vpos || vdcampo2;
		LET vlen = LENGTH(vdcampo3);
		LET vpos = LPAD(vlen, 2, "0");
		LET vregistro = TRIM(vregistro) || "00" || vpos || vdcampo3;
		LET vlen = LENGTH(vdcampo4);
		LET vpos = LPAD(vlen, 2, "0");
		LET vregistro = TRIM(vregistro) || "02" || vpos || vdcampo4;
		LET vlen = LENGTH(vdcampo5);
		LET vpos = LPAD(vlen, 2, "0");
		
		IF vlen > 0 THEN 
			LET vregistro = TRIM(vregistro) || "03" || vpos || vdcampo5;
		END IF 
		
		LET vlen = LENGTH(vdcampo6);
		
		IF vlen > 0 THEN 
			LET vdia = vdcampo6 [4,5];
			LET vdia = LPAD(vdia, 2, "0");
			LET vmes = vdcampo6 [1,2];
			LET vmes = LPAD(vmes, 2, "0");
			LET vanio = vdcampo6 [7,10];
			LET vdcampo6 = vdia || vmes || vanio;
			LET vlen = LENGTH(vdcampo6);
			LET vpos = LPAD(vlen, 2, "0");
			LET vregistro = TRIM(vregistro) || "04" || vpos || vdcampo6;
		END IF;
		
		LET vlen = LENGTH(vdcampo7);
		
		IF vlen > 0 THEN LET vpos = LPAD(vlen, 2, "0");
			LET vregistro = TRIM(vregistro) || "05" || vpos || vdcampo7;
		END IF;
		
		LET vlen = LENGTH(vdcampo8);
		LET vpos = LPAD(vlen, 2, "0");
		LET vregistro = TRIM(vregistro) || "08" || vpos || vdcampo8;
		--- Este es el campo correspondiente a la residencia
		IF vdcampo9 = "1"
			OR vdcampo9 = "2"
			OR vdcampo9 = "3" THEN 
			LET vlen = LENGTH(vdcampo9);
			LET vpos = LPAD(vlen, 2, "0");
			LET vregistro = TRIM(vregistro) || "09" || vpos || vdcampo9;
		END IF 
		
		LET vlen = LENGTH(vdcampo10);
		
		IF vlen > 0 THEN 
			LET vpos = LPAD(vlen, 2, "0");
			LET vregistro = TRIM(vregistro) || "11" || vpos || vdcampo10;
		END IF 
		
		LET vlen = LENGTH(vdcampo11);
		
		IF vlen > 0 THEN 
			LET vpos = LPAD(vlen, 2, "0");
			LET vregistro = TRIM(vregistro) || "12" || vpos || vdcampo11;
		END IF 
			
		IF TRIM(vdcampo12) != "0" THEN
			IF LENGTH(TRIM(vdcampo12)) < 2 THEN 
				LET vdcampo12 = "0" || TRIM(vdcampo12);
			END IF 
			
			LET vlen = LENGTH(vdcampo12);
			LET vpos = LPAD(vlen, 2, "0");
			LET vregistro = TRIM(vregistro) || "17" || vpos || vdcampo12;
		ELSE
			LET vregistro = TRIM(vregistro) || "170201";
		END IF 
		
		LET vregistro = TRIM(vregistro) || vscampo1;
		LET vlen = LENGTH(vscampo2);
		LET vpos = LPAD(vlen, 2, "0");
		LET vregistro1 = vpos || vscampo2;
		LET vscampo3 = "";
		LET vexiste = LENGTH(vscampo3);
		LET vexiste1 = 0;
		LET vquita = "";
		LET vespacio = " ";
		
		WHILE vexiste1 < vexiste
			IF vscampo3 [1,1] = "~"
				OR vscampo3 [1,1] = " "
				OR vscampo3 [1,1] = "."
				OR vscampo3 [1,1] = "-" THEN 
				LET vespacio = "F";
			ELSE
				IF vespacio = "F" THEN
					IF vscampo3 [1,1] = "#"
						OR vscampo3 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || " Ã?";
					ELSE
						LET vquita = TRIM(vquita) || " " || vscampo3 [1,1];
					END IF 
					
					LET vespacio = "";
				ELSE 
					IF vscampo3 [1,1] = "#"
							OR vscampo3 [1,1] = "Â¥" THEN 
							LET vquita = TRIM(vquita) || "Ã?";
						ELSE
							LET vquita = TRIM(vquita) || vscampo3 [1,1];
						END IF 
					END IF 
				END IF;
				
			LET vscampo3 = vscampo3 [2,26];
			LET vexiste1 = vexiste1 + 1;
		END WHILE;
		
		LET vscampo3 = TRIM(vquita);
		LET vlen = LENGTH(vscampo3);
		LET vpos = LPAD(vlen, 2, "0");
		--LET vregistro1='00'||vpos|| vscampo3;
		LET vexiste = LENGTH(vscampo4);
		LET vexiste1 = 0;
		LET vquita = "";
		LET vespacio = " ";
		
		WHILE vexiste1 < vexiste
			IF vscampo4 [1,1] = "~"
				OR vscampo4 [1,1] = " "
				OR vscampo4 [1,1] = "."
				OR vscampo4 [1,1] = "-" THEN 
				LET vespacio = "F";ELSE
				IF vespacio = "F" THEN
					IF vscampo4 [1,1] = "#"
						OR vscampo4 [1,1] = "Â¥" THEN 
							LET vquita = TRIM(vquita) || " Ã?";
						ELSE
							LET vquita = TRIM(vquita) || " " || vscampo4 [1,1];
					END IF 
					LET vespacio = "";
				ELSE 
					IF vscampo4 [1,1] = "#"
						OR vscampo4 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || "Ã?";
					ELSE
						LET vquita = TRIM(vquita) || vscampo4 [1,1];
					END IF 
				END IF 
			END IF;
			
			LET vscampo4 = vscampo4 [2,26];
			LET vexiste1 = vexiste1 + 1;
		END WHILE;
		
		LET vscampo4 = TRIM(vquita);
		LET vlen = LENGTH(vscampo4);
		LET vpos = LPAD(vlen, 2, "0");
		
		IF vlen > 0 THEN 
			LET vregistro1 = TRIM(vregistro1) || "01" || vpos || vscampo4;
		END IF 
	{
		LET vexiste = LENGTH(vscampo5);
		LET vexiste1 = 0;
		LET vquita = "";
		LET vespacio = " ";
		
		WHILE vexiste1 < vexiste
			IF vscampo5 [1,1] = "~"
				OR vscampo5 [1,1] = " "
				OR vscampo5 [1,1] = "." THEN 
				LET vespacio = "F";
			ELSE
				IF vespacio = "F" THEN
					IF vscampo5 [1,1] = "#"
						OR vscampo5 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || " Ã? ";
						LET vespacio = "";
					ELSE
						LET vquita = TRIM(vquita) || " " || vscampo5 [1,1];
						LET vespacio = "";
					END IF
				ELSE 
					IF vscampo5 [1,1] = "#"
						OR vscampo5 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || "Ã?";
					ELSE
						LET vquita = TRIM(vquita) || vscmpo5 [1,1];
					END IF 
				END IF 
			END IF;
			
			LET vscampo5 = vscampo5 [2,26];
			LET vexiste1 = vexiste1 + 1;
		END WHILE;
		
		LET vscampo5 = TRIM(vquita);
		LET vlen = LENGTH(vscampo5);
		LET vpos = LPAD(vlen, 2, '0');
		LET vregistro1 = TRIM(vregistro1) || '02' || vpos || vscampo5;
	} 
		LET vexiste = LENGTH(vscampo6);
		LET vexiste1 = 0;
		LET vquita = "";
		LET vespacio = " ";
		
		WHILE vexiste1 < vexiste
			IF vscampo6 [1,1] = "~"
				OR vscampo6 [1,1] = " "
				OR vscampo6 [1,1] = "."
				OR vscampo6 [1,1] = "-" THEN 
					LET vespacio = "F";
					LET vexiste1 = vexiste1 + 1;
					LET vscampo6 = vscampo6 [2,26];
			ELSE
				IF vespacio = "F" THEN
					IF vscampo6 [1,22] = "MUNICIPIO DE ( OTROS )" THEN 
						LET vquita = TRIM(vquita);
						LET vexiste1 = vexiste1 + 22;
						LET vscampo6 = vscampo6 [23,26];
					ELSE
						IF vscampo6 [1,12] = "MUNICIPIO DE" THEN 
							LET vquita = TRIM(vquita);
							LET vexiste1 = vexiste1 + 12;
							LET vscampo6 = vscampo6 [13,26];
						ELSE
							IF vscampo6 [1,1] = "#"
								OR vscampo6 [1,1] = "Â¥" THEN 
								LET vquita = TRIM(vquita) || " Ã?";
							ELSE
								LET vquita = TRIM(vquita) || " " || vscampo6 [1,1];
							END IF 
							LET vespacio = "";
							LET vexiste1 = vexiste1 + 1;
							LET vscampo6 = vscampo6 [2,26];
						END IF;
					END IF;
				ELSE
					IF vscampo6 [1,1] = "#"
						OR vscampo6 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || "Ã?";
					ELSE
						LET vquita = TRIM(vquita) || vscampo6 [1,1];
					END IF 
					LET vexiste1 = vexiste1 + 1;
					LET vscampo6 = vscampo6 [2,26];
				END IF 
			END IF;
		END WHILE;
		
		LET vscampo6 = TRIM(vquita);
		LET vlen = LENGTH(vscampo6);
		LET vpos = LPAD(vlen, 2, '0');
		LET vregistro1 = TRIM(vregistro1) || "03" || vpos || vscampo6;
		LET vexiste = LENGTH(vscampo7);
		LET vexiste1 = 0;
		LET vquita = "";
		LET vespacio = " ";
		
		WHILE vexiste1 < vexiste
			IF vscampo7 [1,1] = "~"
				OR vscampo7 [1,1] = " "
				OR vscampo7 [1,1] = "."
				OR vscampo7 [1,1] = "-" THEN 
				LET vespacio = "F";
			ELSE
				IF vespacio = "F" THEN
					IF vscampo7 [1,1] = "#"
						OR vscampo7 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || " Ã?";
						LET vespacio = "";
					ELSE
						LET vquita = TRIM(vquita) || " " || vscampo7 [1,1];
						LET vespacio = "";
					END IF 
				ELSE
					IF vscampo7 [1,1] = "#"
						OR vscampo7 [1,1] = "Â¥" THEN 
						LET vquita = TRIM(vquita) || vscampo7 [1,1];
					ELSE
						LET vquita = TRIM(vquita) || vscampo7 [1,1];
					END IF 
				END IF 
			END IF;
		
			LET vscampo7 = vscampo7 [2,4];
			LET vexiste1 = vexiste1 + 1;
		END WHILE;
		
		LET vscampo7 = TRIM(vquita);
		LET vlen = LENGTH(vscampo7);
		LET vpos = LPAD(vlen, 2, "0");
		LET vregistro1 = TRIM(vregistro1) || "04" || vpos || vscampo7;
	{
		IF vscampo8 [1,1] = 1
			OR vscampo8 [1,1] = 2
			OR vscampo8 [1,1] = 3
			OR vscampo8 [1,1] = 4
			OR vscampo8 [1,1] = 5
			OR vscampo8 [1,1] = 6
			OR vscampo8 [1,1] = 7
			OR vscampo8 [1,1] = 8
			OR vscampo8 [1,1] = 9 THEN 
			LET vscampo8a = vscampo8 [1,1] * 10000;
		ELSE
			LET vscampo8a = 0;
		END IF 
			
		IF vscampo8 [2,2] = 1
			OR vscampo8 [2,2] = 2
			OR vscampo8 [2,2] = 3
			OR vscampo8 [2,2] = 4
			OR vscampo8 [2,2] = 5
			OR vscampo8 [2,2] = 6
			OR vscampo8 [2,2] = 7
			OR vscampo8 [2,2] = 8
			OR vscampo8 [2,2] = 9 THEN 
			LET vscampo8a = vscampo8a + vscampo8 [2,2] * 1000;
		ELSE
			LET vscampo8a = vscampo8a + 0;
		END IF 
		
		IF vscampo8 [3,3] = 1
			OR vscampo8 [3,3] = 2
			OR vscampo8 [3,3] = 3
			OR vscampo8 [3,3] = 4
			OR vscampo8 [3,3] = 5
			OR vscampo8 [3,3] = 6
			OR vscampo8 [3,3] = 7
			OR vscampo8 [3,3] = 8
			OR vscampo8 [3,3] = 9 THEN 
			LET vscampo8a = vscampo8a + vscampo8 [3,3] * 100;
		ELSE
			LET vscampo8a = vscampo8a + 0;
		END IF 
		
		IF vscampo8 [4,4] = 1
			OR vscampo8 [4,4] = 2
			OR vscampo8 [4,4] = 3
			OR vscampo8 [4,4] = 4
			OR vscampo8 [4,4] = 5
			OR vscampo8 [4,4] = 6
			OR vscampo8 [4,4] = 7
			OR vscampo8 [4,4] = 8
			OR vscampo8 [4,4] = 9 THEN 
			LET vscampo8a = vscampo8a + vscampo8 [4,4] * 10;
		ELSE
			LET vscampo8a = vscampo8a + 0;
		END IF 
		
		IF vscampo8 [5,5] = 1
			OR vscampo8 [5,5] = 2
			OR vscampo8 [5,5] = 3
			OR vscampo8 [5,5] = 4
			OR vscampo8 [5,5] = 5
			OR vscampo8 [5,5] = 6
			OR vscampo8 [5,5] = 7
			OR vscampo8 [5,5] = 8
			OR vscampo8 [5,5] = 9 THEN 
			LET vscampo8a = vscampo8a + vscampo8 [5,5];
		ELSE
			LET vscampo8a = vscampo8a + 0;
		END IF 
		
		IF vscampo8a < vcodini
			OR vscampo8a > vcodfin THEN 
			LET vscampo8 = LPAD(round(vcodini), 5, "0");
		END IF 
	} 
		LET vlen = LENGTH(vscampo8);
		LET vpos = LPAD(vlen, 2, "0");
		LET vregistro2 = '05' || vpos || vscampo8;
		LET vlen = LENGTH(vscampo9);
		LET vpos = LPAD(vlen, 2, '0');
		LET vregistro2 = TRIM(vregistro2) || '10' || vpos || vscampo9;
		-- Marca el FIN de Trailer -->
		LET vlen = LENGTH(vregistro) + LENGTH(vregistro1) + LENGTH(vregistro2);
		LET vlen = TRUNC(vlen + 15);
		LET vpo1 = LPAD(vlen, 5, '0');
		LET vregistro2 = TRIM(vregistro2) || 'ES05' || vpo1 || '0002**';

		IF LENGTH(NVL(vcomentario, "")) = 0 THEN
			INSERT INTO "informix".br_traslado (
				institucion
				,numcte
				,num_solicitud
				,envio
				,envio1
				,envio2
				,STATUS
				,fecha_insert
				)
			VALUES (
				status_2
				,pFolio
				,pFolio
				,vregistro
				,vregistro1
				,vregistro2
				,0
				,vfecha
				);
				--ELSE
				--INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
				-- VALUES(status_2,pFolio,pFolio,vregistro,vregistro1,vregistro2,3,vfecha);
				--INSERT INTO "informix".br_auditor VALUES(status_2,pFolio,vfecha,vhora,vcomentario);
			END
		IF;
		
		LET vexiste1 = 0;
		LET vexiste = 10;
		
		RETURN vcodret;
	END;
END PROCEDURE;