CREATE PROCEDURE "informix".sp_perfisica_listanegra_exp( pRfc CHAR(13),
												pNombre1 CHAR(26),
												pNombre2 CHAR(26),
												pApellPaterno CHAR(26),
												pApellMaterno CHAR(26),
												pFechaNac CHAR(8) )
												
												
RETURNING CHAR(5) AS codRet,
		  CHAR(50) AS mensaje,
		  CHAR(1) AS listaNegra,
		  CHAR(1) AS TipoLista;
    
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iExisteRfc INTEGER;
	DEFINE iExisteLis CHAR(1);
	DEFINE iExisteLisW CHAR(1);
	DEFINE TipoLista CHAR(1);
	DEFINE Mensaje CHAR(50);
	DEFINE listaNegra CHAR(1);
	DEFINE rfcint CHAR(13);
	DEFINE nombre CHAR(26);
	DEFINE vnombre2 CHAR(26);
	DEFINE apellidopto CHAR(26);
	DEFINE apellidomto CHAR(26);
	DEFINE fechanac CHAR(8);
	DEFINE firstname CHAR(50);
	DEFINE lastname CHAR(80);
	DEFINE fechanacFor CHAR(8);
	DEFINE anio CHAR(4);
	DEFINE mes CHAR(2);
	DEFINE dia CHAR(2);
	DEFINE pAnio CHAR(4);
	DEFINE pMes CHAR(2);
	DEFINE pDia CHAR(2);
	DEFINE wNombre1 CHAR(26);
	DEFINE wNombre2 CHAR(26);
	DEFINE wApellPaterno CHAR(26);
	DEFINE wApellMaterno CHAR(26);
	DEFINE wlast_name CHAR(60);
	DEFINE wfirst_name CHAR(60);
	
	LET cCodRet = '000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iExisteLis = 0;
	LET iExisteLisW = 0;
	LET TipoLista = 0;
	LET Mensaje = 'Sin coincidencia';
	LET listaNegra = 0;
	LET rfcint = '';
	LET nombre = '';
	LET vnombre2 = '';
	LET apellidopto = '';
	LET apellidomto = '';
	LET fechanac = '';
	LET firstname = '';
	LET lastname = '';
	LET anio = '';
	LET mes = '';
	LET dia = '';
	LET pAnio = '';
	LET pMes = '';
	LET pDia = '';
	
	LET	pAnio = SUBSTR(pRfc,5,2);
	LET pMes = SUBSTR(pRfc,7,2);
	LET pDia = SUBSTR(pRfc,9,2);
	
	LET wNombre1 = TRIM(pNombre1);
	LET wNombre2 = TRIM(pNombre2);
	LET wApellPaterno = TRIM(pApellPaterno);
	LET wApellMaterno = TRIM(pApellMaterno);
	LET wlast_name = wApellPaterno||' '||wApellMaterno;
	LET wfirst_name = wNombre1||' '||wNombre2;
	
	BEGIN
	
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN 
            LET cCodRet = iSqlErr;
            RETURN cCodRet,mensaje,listaNegra,tipoLista;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO '/informix/jmss/sp_perfisica_listanegra.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --- VALIDACION DE CAMPOS REQUERIDOS
    IF (pRfc IS NULL OR pRfc = '') THEN 
		LET cCodRet = '110';
		LET mensaje = 'Parametro pRfc vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	IF (pNombre1 IS NULL OR pNombre1= '') THEN
		LET cCodRet = '110';
		LET mensaje = 'Parametro Nombre vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	IF (pApellPaterno IS NULL OR pApellPaterno = '') THEN
	    LET cCodRet = '110';
		LET mensaje = 'Parametro Apellido Paterno vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	IF (pFechaNac IS NULL OR pFechaNac = '') THEN
	    LET cCodRet = '110';
		LET mensaje = 'Parametro Fecha Nacimiento vacio';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
    END IF;
	
	LET fechanacFor = SUBSTR(pFechaNac,3,2) || SUBSTR(pFechaNac,1,2) || SUBSTR(pFechaNac,5,4);

    --- VALIDA EN LISTAS NEGRA INTERNA
    SELECT trim(rfc),trim(nombre1),trim(nombre2),trim(apell_paterno),trim(apell_materno),to_char(fecha_nac,"%d%m%Y")
	INTO rfcint,nombre,vnombre2,apellidopto,apellidomto,fechanac
    FROM bdiauditor:tbl_listainterna
    WHERE rfc = pRfc 
	AND nombre1 = pNombre1
	AND apell_paterno = pApellPaterno
	OR nombre1 = pNombre1
	AND nombre2 = pNombre2
	AND apell_paterno = pApellPaterno
	AND apell_materno = pApellMaterno
	and fecha_nac = fechanacFor
	OR nombre1 = pNombre1
	AND apell_paterno = pApellPaterno
	AND fecha_nac = fechanacFor;
		
	
    --- VALIDA EN LISTAS NEGRAS EXTERNA
	FOREACH 
		SELECT trim(first_name),trim(last_name),SUBSTR(dob,3,2),
		SUBSTR(dob,6,2),SUBSTR(dob,9,2)
		INTO firstname,lastname,anio,mes,dia
		FROM bdiauditor:tblpld_worldcheck_compara
			WHERE  last_name = wlast_name
			AND first_name = wfirst_name
			
		IF (dia = '00' OR dia = " " OR dia IS NULL) THEN
			CONTINUE FOREACH;
		ELSE
			EXIT FOREACH;
		END IF		
	END FOREACH
	
	IF rfcint in ('MAPJ900922FZ3','AECS890507ME7','AAMR9307132F7','MUSJ9202012Y8','VAVA8204115T4','REOI721227FGA') THEN
	LET rfcint = ' ';
	END IF;
	
	IF pNombre2 = '' and pApellMaterno = '' THEN
	--Checar claves 
		IF rfcint = pRfc and nombre = pNombre1 and apellidopto = pApellPaterno THEN
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF
	
	ELIF pNombre2 <> '' AND pApellMaterno = '' then
	--checar rfc hasta fechanacimiento omitir materno
		IF rfcint = pRfc and nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and fechanac = pFechaNac THEN
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF
	
	
	ELIF pApellMaterno <> '' and pNombre2 = '' then 
	--checar rfc hasta fechanacimiento omitir nombre2
		IF rfcint = pRfc and nombre = pNombre1 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and fechanac = pFechaNac THEN 
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF;
		
	else 
	--checar todos los campos 
		IF rfcint = pRfc and nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and 
			fechanac = pFechaNac THEN 
			LET listaNegra = 1;
			LET cCodRet = '111';
			LET tipoLista = 1;
			LET mensaje = 'Match RFC y Nombre (PF) Lista Interna';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF;
	END IF;
	
	
	IF rfcint = '' THEN
		IF pNombre2 = '' and pApellMaterno = '' THEN
			--Checar claves 
			IF nombre = pNombre1 and apellidopto = pApellPaterno THEN
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF
		
		ELIF pNombre2 <> '' AND pApellMaterno = '' then
			--checar rfc hasta fechanacimiento omitir materno
			IF  nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and fechanac = pFechaNac THEN
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF
		
		ELIF pApellMaterno <> '' and pNombre2 = '' then 
			--checar rfc hasta fechanacimiento omitir nombre2
			IF nombre = pNombre1 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and fechanac = pFechaNac THEN 
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF;
			
		else 
			--checar todos los campos 
			IF nombre = pNombre1 and vnombre2 = pNombre2 and apellidopto = pApellPaterno and apellidomto = pApellMaterno and 
				fechanac = pFechaNac THEN 
				LET listaNegra = 1;
				LET cCodRet = '112';
				LET tipoLista = 1;
				LET mensaje = 'Nombre y Fecha (PF) Lista Interna';
				RETURN cCodRet,mensaje,listaNegra,tipoLista;
			END IF;
		
		END IF;
	END IF;
	
	--- VALIDA SI SE ENCUENTRE DADO DE ALTA EN LAS LISTAS EXTERNA
    IF (firstname = trim(pNombre1) ||' '|| trim(pNombre2) and lastname = trim (pApellPaterno)||' '||trim (pApellMaterno)
		and anio = pAnio and pMes = mes and pDia = dia) THEN
		LET listaNegra = 1;
        LET cCodRet = '211';
		LET tipoLista = 2;
		LET mensaje = '	Match Nombre y Fecha (PF) Lista Externa';
		RETURN cCodRet,mensaje,listaNegra,tipoLista;
	ELSE
		IF firstname = trim(pNombre1) ||' '|| trim(pNombre2) and lastname = trim (pApellPaterno)||' '||trim (pApellMaterno) THEN
			LET listaNegra = 1;
			LET cCodRet = '212';
			LET tipoLista = 2;
			LET mensaje = '	Match Nombre (PF) Lista Externa';
			RETURN cCodRet,mensaje,listaNegra,tipoLista;
		END IF;
    END IF;
	
	RETURN cCodRet,mensaje,listaNegra,tipoLista;
	
	END;
	    
END PROCEDURE
DOCUMENT 'AUTOR: Martha Gabriela Angulo Zazueta',
'FECHA: 30/06/2021',
'DESCRIPCION: SPL encargado de validar si se encuentra registrado en listas negras',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_rpt_retirosatmextranjero()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;
		  
--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(100);	
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE v_fecha_ant				DATE;
DEFINE v_fecha_hoy 				DATE;
DEFINE v_fecha_ant_tc			DATE;
DEFINE vsql						CHAR(200);
DEFINE v_dolar        			MONEY(10,4);

-- LAYOUT REPORTE
DEFINE  vnumcte  				VARCHAR(10);
DEFINE	vnombre 				VARCHAR(50);
DEFINE	vcuenta 				VARCHAR(12);
DEFINE	vnum_tarjeta 			VARCHAR(16);
DEFINE	vfecha_nacimiento 		VARCHAR(10);
DEFINE	vedad 					SMALLINT;
DEFINE	vgenero 				VARCHAR(15);
DEFINE	vnacionalidad 			VARCHAR(15);
DEFINE	vestado_cliente 		VARCHAR(30);
DEFINE	vmunicipio_cliente 		VARCHAR(30);
DEFINE	vactividad_economica 	VARCHAR(120);
DEFINE	vfecha_aper_cuenta 		VARCHAR(10);
DEFINE	vsucursal_apertura 		VARCHAR(4);
DEFINE	vmunicipio_apertura 	VARCHAR(60);
DEFINE	vestado_apertura 		VARCHAR(30);
DEFINE	vnombre_beneficiario 	VARCHAR(250);
DEFINE	vparentesco_bene		VARCHAR(150);
DEFINE	vsaldo_cuenta 			MONEY(14,2);
DEFINE	vfecha_hora 			VARCHAR(20);
DEFINE	vmonto_usd 				MONEY(14,2);
DEFINE	vmonto_pesos 			MONEY(14,2);
DEFINE	vpais 					VARCHAR(20);
DEFINE	vnombre_atm 			VARCHAR(40);
DEFINE	vnumero_atm 			VARCHAR(16);

-- VARIABLES DE PASO
DEFINE vpaso 					INT;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vpfech_alt				DATE;
DEFINE vpfech_hora				DATETIME HOUR TO FRACTION(3);
DEFINE vpfecha_alta				DATE;
DEFINE vpnombre1				VARCHAR(20);
DEFINE vpnombre2				VARCHAR(20);
DEFINE vpapell_paterno			VARCHAR(20);
DEFINE vpapell_materno			VARCHAR(20);
DEFINE vpnombre1ben				VARCHAR(20);
DEFINE vpnombre2ben				VARCHAR(20);
DEFINE vpapell_paternoben		VARCHAR(20);
DEFINE vpapell_maternoben		VARCHAR(20);
DEFINE vpfecha_nac				DATE;
DEFINE vpmaxsecuenciadir		INT;
DEFINE vpmaxsecuenciaact		INT;
DEFINE vpmaxsecuenciben			SMALLINT;
DEFINE vpid_act					SMALLINT;
DEFINE vpid_subact				SMALLINT;
DEFINE vpsexo					CHAR(1);
DEFINE vrfc						VARCHAR(13);
DEFINE vpparen					CHAR(20);
DEFINE vpfolio_suc				CHAR(16);
DEFINE vppais 					VARCHAR(3);
DEFINE vppaiscount 				SMALLINT;
DEFINE vpcounben				SMALLINT;
DEFINE vpbensumporcentaje		SMALLINT;
DEFINE vpparentesco_bene		VARCHAR(20);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE NOMBRE_ARCHIVO			VARCHAR(50);
DEFINE cCodRetEdad              CHAR(5);
DEFINE cnomcteEdad              CHAR(104);
DEFINE vEdadCte	                SMALLINT;

--SE INICIALIZAN VARIABLES
LET vpaso = 0;

BEGIN
	--CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = 'ERROR GENERANDO REPORTE: ' || TRIM(ERROR_INFO) || ', EN PASO: ' || vpaso;
		RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/ifxsif01/c90244910/ReporteATMInt/sp_rpt_retirosatmextranjero.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	--SET EXPLAIN ON;

	LET vpaso = 1;
	
	--FECHA DEL DIA ANTERIOR
	SELECT fecha_ant
	INTO v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET v_fecha_ant_tc = DATE(v_fecha_ant - 1 UNITS day);
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--FORMATO 'AAAAMMDD' FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET NOMBRE_ARCHIVO = 'rpt_retirosatmextranjero_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	TRUNCATE TABLE rpt_retirosatmextranjero_tmp;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD 
		-- RETIROS DE EFECTIVO INTERNACIONALES EN ATMS EN EL EXTRANJERO
		SELECT mov.cuenta, mov.num_tarjeta, mov.sdo_cuenta, mov.monto_tot, mov.fech_alt, 
		       mov.fech_hor, noc.fecha_alta, maechq.num_cte, maechq.sucursal, mov.folio_suc
		INTO   vcuenta, vnum_tarjeta, vsaldo_cuenta, vmonto_pesos, vpfech_alt, vpfech_hora, 
			   vpfecha_alta, vnumcte, vsucursal_apertura, vpfolio_suc 
		FROM bdicheq:sc_movhis mov
		JOIN bdicheq:sc_maechq maechq ON mov.cuenta = maechq.cuenta
		JOIN bdicheq:sc_maenoc noc ON maechq.cuenta = noc.cuenta
		WHERE mov.transacc = '0873' 
		AND mov.fech_alt = v_fecha_ant 
		AND mov.cancelad <> 'S'
		
		LET vfecha_hora = TRIM ( TRIM(TO_CHAR(vpfech_alt, "%d/%m/%Y")) || ' ' || TRIM(TO_CHAR(vpfech_hora, "%H:%M:%S")) );
		LET vfecha_aper_cuenta = TO_CHAR(vpfecha_alta, "%Y-%m-%d");
		
		LET vpaso = 5;
		-- DATOS DEL CLIENTE
		SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, ctpf.fecha_nac, ctpf.sexo,
		       TRIM(NVL(nac.descripcion,'')), cte.rfc
		INTO vpnombre1, vpnombre2, vpapell_paterno, vpapell_materno, vpfecha_nac, vpsexo, vnacionalidad,
		     vrfc
		FROM bdinteg:si_cliente cte
		LEFT JOIN bdinteg:si_ctepf ctpf ON cte.numcte = ctpf.numcte
		LEFT JOIN bdinteg:si_nacion nac ON ctpf.nacionalidad = nac.nacion
		WHERE cte.numcte = vnumcte;
		
		IF vpfecha_nac IS NOT NULL THEN
			LET vfecha_nacimiento = TO_CHAR(vpfecha_nac, "%Y-%m-%d");
		ELSE 
			LET vfecha_nacimiento = '';
		END IF;
		
		IF vpsexo IS NOT NULL AND vpsexo <> '' THEN	
			IF	vpsexo = 'M' THEN
				LET vgenero = 'MASCULINO';
			ELIF vpsexo = 'F' THEN
				LET vgenero = 'FEMENINO';
			ELSE
				LET vgenero = 'N/A';
			END IF;
		ELSE
			LET vgenero = '';
		END IF;
		
		LET vnombre = TRIM(NVL(vpnombre1, '')) || ' ' || TRIM(NVL(vpnombre2, '')) || ' ' || TRIM(NVL(vpapell_paterno, '')) || ' ' || TRIM(NVL(vpapell_materno, ''));
		
		--OBTENER EDAD DEL CLIENTE
		EXECUTE PROCEDURE bdinteg:"informix".consedadcte('001', vnumcte) INTO cCodRetEdad, cnomcteEdad, vEdadCte;
				
		IF cCodRetEdad = '000' AND cCodRetEdad IS NOT NULL THEN
			LET vedad = vEdadCte;
		ELSE
			LET vedad = NULL;
		END IF;
		
		LET vpaso = 6;
		-- DIRECCION DEL CLIENTE
		SELECT MAX(secuencia)
		INTO vpmaxsecuenciadir
		FROM bdinteg:si_direcciones_actual 
		WHERE numcte = vnumcte
		AND tipo_dir = '1';
		
		SELECT TRIM(NVL(est.nombre, '')), TRIM(NVL(ctz.municipiozona, ''))
		INTO vestado_cliente, vmunicipio_cliente 
		FROM bdinteg:si_direcciones_actual dir
		LEFT JOIN bdinteg:si_estados est ON dir.estado::INTEGER = est.estado::INTEGER
		LEFT JOIN bdinteg:si_catzonas ctz ON dir.numerociudad = ctz.numerociudad AND dir.numerocolonia = ctz.numerocolonia
		WHERE dir.numcte = vnumcte
		AND dir.tipo_dir = '1'
		AND dir.secuencia = vpmaxsecuenciadir;
		
		LET vpaso = 7;
		-- ACTIVIDAD ECONOMICA
		SELECT NVL(MAX(id_secuencia),0)
		INTO vpmaxsecuenciaact
		FROM bdinteg:si_bitacoraapertura
		WHERE rfc = vrfc
		AND numcte = vnumcte 
		AND id_pregunta = 6;
		
		SELECT NVL(id_act,0), NVL(id_subact,0)
		INTO vpid_act, vpid_subact
		FROM bdinteg:si_bitacoraapertura
		WHERE rfc = vrfc
		AND numcte = vnumcte 
		AND id_pregunta = 6
		AND id_secuencia = vpmaxsecuenciaact;
		
		SELECT TRIM(NVL(descrip, ''))
		INTO vactividad_economica
		FROM bdinteg:si_actsubact
		WHERE id_act = vpid_act
		AND id_subact = vpid_subact;
		
		IF vactividad_economica = '' OR vactividad_economica IS NULL THEN
			LET vactividad_economica = 'Otros Servicios';
		END IF;
		
		LET vpaso = 8;
		-- SUCURSAL APERTURA CUENTA
		SELECT TRIM(NVL(ciu.nombre,'')), TRIM(NVL(est.nombre,''))
		INTO vmunicipio_apertura, vestado_apertura
		FROM bdinteg:si_sucursales suc
		LEFT JOIN bdinteg:si_ciudades ciu ON ciu.ciudad = suc.ciudad AND ciu.estado = suc.estado
		LEFT JOIN bdinteg:si_estados est ON suc.estado = est.estado
		WHERE suc.sucursal = vsucursal_apertura;
		
		LET vpaso = 9;
		-- BENEFICIARIO
		
		SELECT SUM(porcentaje), COUNT(*)
		INTO vpbensumporcentaje, vpcounben
		FROM bdicheq:sc_beneficiario
		WHERE cuenta = vcuenta;
		
		IF vpcounben > 1 AND vpbensumporcentaje = 100 THEN
		-- CASO MULTIPLES BENEFICIARIOS
		
			LET vnombre_beneficiario = '';
			LET vparentesco_bene = '';
			
			FOREACH WITH HOLD
				SELECT TRIM(NVL(paren.descripcion, '')), ben.parentesco, cteben.nombre1, cteben.nombre2, cteben.apell_paterno, cteben.apell_materno
				INTO vpparentesco_bene, vpparen, vpnombre1ben, vpnombre2ben, vpapell_paternoben, vpapell_maternoben
				FROM bdicheq:sc_beneficiario ben
				LEFT JOIN bdinteg:si_parentesco paren ON ben.parentesco = paren.parentesco
				LEFT JOIN bdinteg:si_cliente cteben ON ben.numcte = cteben.numcte
				WHERE ben.cuenta = vcuenta
				
				IF vpparentesco_bene = '' AND vpparen IS NOT NULL THEN
					LET vparentesco_bene = vparentesco_bene || TRIM(vpparen) || ', ';
				ELSE
					LET vparentesco_bene = vparentesco_bene || vpparentesco_bene || ', ';
				END IF;
				
				LET vnombre_beneficiario = vnombre_beneficiario || TRIM(NVL(vpnombre1ben, '')) || ' ' || TRIM(NVL(vpnombre2ben, '')) || ' ' || TRIM(NVL(vpapell_paternoben, '')) || ' ' || TRIM(NVL(vpapell_maternoben, '')) || ', ';
				
			END FOREACH;
		
		ELSE
			SELECT NVL(MAX(secuencia),0)
			INTO vpmaxsecuenciben
			FROM bdicheq:sc_beneficiario
			WHERE empresa = '001'
			AND cuenta = vcuenta;
			
			SELECT TRIM(NVL(paren.descripcion, '')), ben.parentesco, cteben.nombre1, cteben.nombre2, cteben.apell_paterno, cteben.apell_materno
			INTO vparentesco_bene, vpparen, vpnombre1ben, vpnombre2ben, vpapell_paternoben, vpapell_maternoben
			FROM bdicheq:sc_beneficiario ben
			LEFT JOIN bdinteg:si_parentesco paren ON ben.parentesco = paren.parentesco
			LEFT JOIN bdinteg:si_cliente cteben ON ben.numcte = cteben.numcte
			WHERE ben.empresa = '001'
			AND ben.cuenta = vcuenta
			AND ben.secuencia = vpmaxsecuenciben;
			
			IF vparentesco_bene = '' AND vpparen IS NOT NULL THEN
				LET vparentesco_bene = TRIM(vpparen);
			END IF;
		
			LET vnombre_beneficiario = TRIM(NVL(vpnombre1ben, '')) || ' ' || TRIM(NVL(vpnombre2ben, '')) || ' ' || TRIM(NVL(vpapell_paternoben, '')) || ' ' || TRIM(NVL(vpapell_maternoben, ''));
			
		END IF;
		
		
		LET vpaso = 10;
		-- INFORMACION CAJERO
		SELECT TRIM(NVL(pais,'')), TRIM(NVL(infreceptor,'')), TRIM(NVL(idterminal,''))
		INTO vppais, vnombre_atm, vnumero_atm
		FROM intercard:movimiento
		WHERE numtarjeta = vnum_tarjeta
		AND secuenciaextendida = SUBSTR(vpfolio_suc, 2, 15);
		
		LET vpaso = 11;
		-- NOMBRE PAIS
		SELECT COUNT(*)
		INTO vppaiscount
		FROM bdinteg:si_paises
		WHERE clave_pais = vppais;
		
		IF vppaiscount = 1 THEN
			SELECT TRIM(NVL(nombre,''))
			INTO vpais
			FROM bdinteg:si_paises
			WHERE clave_pais = vppais;
		ELSE
			LET vpais =  vppais;
		END IF;
		
		LET vpaso = 12;
		-- MONTO DLS
		SELECT LIMIT 1 precio
		INTO v_dolar
		FROM bdiauditor:tipo_cambio  --- SINONIMO
		WHERE empresa = '001'
		AND fecha_tc = v_fecha_ant_tc;
		
		LET vmonto_usd = vmonto_pesos / v_dolar;
		
		LET vpaso = 13;
		INSERT INTO rpt_retirosatmextranjero_tmp(cuenta, num_tarjeta, saldo_cuenta, monto_pesos, fecha_hora, fecha_aper_cuenta,
												 numcte, nombre, fecha_nacimiento, genero, nacionalidad, estado_cliente , municipio_cliente,
												 actividad_economica, sucursal_apertura, municipio_apertura, estado_apertura, parentesco_beneficiario,
												 nombre_beneficiario, pais, nombre_atm, numero_atm, edad, monto_usd)
		VALUES(vcuenta, vnum_tarjeta, vsaldo_cuenta, vmonto_pesos, vfecha_hora, vfecha_aper_cuenta, vnumcte, vnombre, vfecha_nacimiento,
		       vgenero, vnacionalidad, vestado_cliente, vmunicipio_cliente, vactividad_economica, vsucursal_apertura, vmunicipio_apertura,
			   vestado_apertura, vparentesco_bene, vnombre_beneficiario, vpais, vnombre_atm, vnumero_atm, vedad, vmonto_usd);
	
	END FOREACH;
	
	LET vpaso = 14;
	-- SE CREA SCRIPT
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'.txt SELECT * FROM bdiauditor:rpt_retirosatmextranjero_tmp;">'||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 15;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	
	LET vpaso = 16;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	
	
	LET cod_ret = '00000';
	LET vmensaje = 'PROCESO EXITOSO';

	RETURN cod_ret, vmensaje;
END;
END PROCEDURE
DOCUMENT 
'AUTOR: Fernando Torres Soto',
'FECHA: 18/05/2023',
'DESCRIPCION: Genera reporte de clientes que retiran efectivo de ATMs en el extranjero',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_carga_geolocalizacion()
RETURNING CHAR(5) AS CodRet,
          CHAR(180) AS mensaje;

-- DeclaraciÃ³n de variables
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(250);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CTA 		VARCHAR(50);
DEFINE vconteo					INTEGER;
DEFINE v_fecha_oper 			DATE;
DEFINE v_folio 					CHAR(40);
DEFINE v_latitud 				CHAR(100);
DEFINE v_longitud 				CHAR(100);
DEFINE v_version 				CHAR(10);
DEFINE v_version_b 				CHAR(10);
DEFINE v_folio_suc 				CHAR(40); 
DEFINE v_referencia_23 			CHAR(23);
DEFINE vcount 					INTEGER;
DEFINE v_idoperacion 			CHAR(4);
DEFINE v_idregistro 			CHAR(7);

--VARIABLES DE PASO
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_menos_uno		DATE;
DEFINE v_fecha_str 				CHAR(10);


--SE INICIALIZAN VARIABLES
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_carga_geolocalizacion en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CTA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_carga_geolocalizacion');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
    --SET DEBUG FILE TO "/informix/c90307913/sp_carga_geolocalizacion.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA Y LA FECHA DEL DIA MENOS 1 DIA
	SELECT fecha_hoy, fecha_ant
	INTO v_fecha_hoy, v_fecha_menos_uno
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_menos_uno), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_menos_uno), 2, '0');
	LET cAno = YEAR(v_fecha_menos_uno);
	
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CTA	 = 'CargaGeoLocalizacion_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".bi_geolocalizacion_paso;
	COMMIT;
	
	
	LET vpaso = 4;
		
	
	LET vcount = 1;

	FOREACH WITH HOLD
		SELECT id_operacion, fecha_oper, folio, latitud, longitud, version, folio_suc, referencia_23, version_b
		INTO v_idoperacion, v_fecha_oper, v_folio, v_latitud, v_longitud, v_version, v_folio_suc, v_referencia_23, v_version_b
		FROM bdibpi:bi_geolocalizacion
		WHERE fecha_oper = v_fecha_menos_uno
		
		LET vpaso = 5;
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF

		LET v_idregistro = LPAD(vcount, 7, '0');

		INSERT INTO "informix".bi_geolocalizacion_paso (id_registro, id_operacion, fecha_oper, folio, latitud, longitud, version, version_b, folio_suc, referencia_23, fecha_registro)	
		VALUES(v_idregistro, v_idoperacion, v_fecha_oper, v_folio, v_latitud, v_longitud, v_version, v_version_b, v_folio_suc, v_referencia_23, v_fecha_menos_uno);
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;
		END IF

		LET vcount =  vcount + 1;
	
	END FOREACH
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF


	LET vpaso = 6;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'.txt select * from bdiauditor:bi_geolocalizacion_paso;">'||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 7;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 8;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 9;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CTA);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_carga_geolocalizacion');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE

DOCUMENT 'AUTOR: Jose Alejandro Jauregui Baez',
'FECHA: 18/09/2023',
'DESCRIPCION: GeneraciÃ³n de informaciÃ³n geolocalizacion para sistemas MINDS PLD',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_rpt_retirosatmextranjero_cred()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;
		  
--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(100);	
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE v_fecha_ant				DATE;
DEFINE v_fecha_ant_tc			DATE;
DEFINE vsql						CHAR(250);
DEFINE v_dolar        			MONEY(10,4);

-- LAYOUT REPORTE
DEFINE  vnumcte  				VARCHAR(10);
DEFINE	vnombre 				VARCHAR(50);
DEFINE	vcuenta 				VARCHAR(12);
DEFINE	vnum_tarjeta 			VARCHAR(16);
DEFINE	vfecha_nacimiento 		VARCHAR(10);
DEFINE	vedad 					SMALLINT;
DEFINE	vgenero 				VARCHAR(15);
DEFINE	vnacionalidad 			VARCHAR(15);
DEFINE	vestado_cliente 		VARCHAR(30);
DEFINE	vmunicipio_cliente 		VARCHAR(30);
DEFINE	vactividad_economica 	VARCHAR(120);
DEFINE	vfecha_aper_cuenta 		VARCHAR(10);
DEFINE	vsucursal_apertura 		VARCHAR(4);
DEFINE	vmunicipio_apertura 	VARCHAR(60);
DEFINE	vestado_apertura 		VARCHAR(30);
DEFINE	vfecha_hora 			VARCHAR(20);
DEFINE	vmonto_usd 				MONEY(14,2);
DEFINE	vmonto_pesos 			MONEY(14,2);
DEFINE	vpais 					VARCHAR(20);
DEFINE	vnombre_atm 			VARCHAR(40);
DEFINE	vnumero_atm 			VARCHAR(16);

-- VARIABLES DE PASO
DEFINE vpaso 					INT;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vpfech_alt				DATE;
DEFINE vpfech_hora				DATETIME HOUR TO FRACTION(3);
DEFINE vpfecha_mov				DATE;
DEFINE vpnombre1				VARCHAR(20);
DEFINE vpnombre2				VARCHAR(20);
DEFINE vpapell_paterno			VARCHAR(20);
DEFINE vpapell_materno			VARCHAR(20);
DEFINE vpnombre1ben				VARCHAR(20);
DEFINE vpnombre2ben				VARCHAR(20);
DEFINE vpapell_paternoben		VARCHAR(20);
DEFINE vpapell_maternoben		VARCHAR(20);
DEFINE vpfecha_nac				DATE;
DEFINE vpmaxsecuenciadir		INT;
DEFINE vpmaxsecuenciaact		INT;
DEFINE vpmaxsecuenciben			SMALLINT;
DEFINE vpid_act					SMALLINT;
DEFINE vpid_subact				SMALLINT;
DEFINE vpsexo					CHAR(1);
DEFINE vrfc						VARCHAR(13);
DEFINE vpfolio_suc				CHAR(16);
DEFINE vppais 					VARCHAR(3);
DEFINE vppaiscount 				SMALLINT;
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE NOMBRE_ARCHIVO			VARCHAR(100);
DEFINE cCodRetEdad              CHAR(5);
DEFINE cnomcteEdad              CHAR(104);
DEFINE vEdadCte	                SMALLINT;

--SE INICIALIZAN VARIABLES
LET vpaso = 0;

BEGIN
	--CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = 'ERROR GENERANDO REPORTE: ' || TRIM(ERROR_INFO) || ', EN PASO: ' || vpaso;
		RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/ifxsif01/c90307913/sp_rpt_retirosatmextranjero_cred.out';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	--SET EXPLAIN ON;

	LET vpaso = 1;
	
	--FECHA DEL DIA ANTERIOR
	SELECT fecha_ant
	INTO v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET v_fecha_ant_tc = DATE(v_fecha_ant - 1 UNITS day);
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--FORMATO 'AAAAMMDD' FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET NOMBRE_ARCHIVO = 'rpt_retirosatmextranjero_cred_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	TRUNCATE TABLE rpt_retirosatmextranjero_cred_tmp;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD 
		-- RETIROS DE EFECTIVO INTERNACIONALES EN ATMS EN EL EXTRANJERO
		SELECT  mov.num_credito, mov.nro_tarjeta, mov.monto, mov.fecha_mov, mov.hora_mov, maecred.numcte, maecred.sucursal, mov.folio_suc
  		INTO   vcuenta, vnum_tarjeta, vmonto_pesos, vpfecha_mov, vpfech_hora, vnumcte, vsucursal_apertura, vpfolio_suc 
        FROM bdicred:sd_movhis mov
        JOIN bdicred:sd_maecred maecred ON mov.num_credito = maecred.num_credito
        JOIN bdicred:sd_maecredanexo crd ON maecred.num_credito = crd.num_credito
        WHERE mov.codigo_fun = '002'
		AND mov.codigo_ref = 42 
        AND mov.fecha_mov = v_fecha_ant
        AND mov.reversado <> 'S'
		
		LET vfecha_hora = TRIM ( TRIM(TO_CHAR(vpfecha_mov, "%d/%m/%Y")) || ' ' || TRIM(TO_CHAR(vpfech_hora, "%H:%M:%S")) );
		LET vfecha_aper_cuenta = TO_CHAR(vpfecha_mov, "%Y-%m-%d");
		
		LET vpaso = 5;
		-- DATOS DEL CLIENTE
		SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, ctpf.fecha_nac, ctpf.sexo,
		       TRIM(NVL(nac.descripcion,'')), cte.rfc
		INTO vpnombre1, vpnombre2, vpapell_paterno, vpapell_materno, vpfecha_nac, vpsexo, vnacionalidad,
		     vrfc
		FROM bdinteg:si_cliente cte
		LEFT JOIN bdinteg:si_ctepf ctpf ON cte.numcte = ctpf.numcte
		LEFT JOIN bdinteg:si_nacion nac ON ctpf.nacionalidad = nac.nacion
		WHERE cte.numcte = vnumcte;
		
		IF vpfecha_nac IS NOT NULL THEN
			LET vfecha_nacimiento = TO_CHAR(vpfecha_nac, "%Y-%m-%d");
		ELSE 
			LET vfecha_nacimiento = '';
		END IF;
		
		IF vpsexo IS NOT NULL AND vpsexo <> '' THEN	
			IF	vpsexo = 'M' THEN
				LET vgenero = 'MASCULINO';
			ELIF vpsexo = 'F' THEN
				LET vgenero = 'FEMENINO';
			ELSE
				LET vgenero = 'N/A';
			END IF;
		ELSE
			LET vgenero = '';
		END IF;
		
		LET vnombre = TRIM(NVL(vpnombre1, '')) || ' ' || TRIM(NVL(vpnombre2, '')) || ' ' || TRIM(NVL(vpapell_paterno, '')) || ' ' || TRIM(NVL(vpapell_materno, ''));
		
		--OBTENER EDAD DEL CLIENTE
		EXECUTE PROCEDURE bdinteg:"informix".consedadcte('001', vnumcte) INTO cCodRetEdad, cnomcteEdad, vEdadCte;
				
		IF cCodRetEdad = '000' AND cCodRetEdad IS NOT NULL THEN
			LET vedad = vEdadCte;
		ELSE
			LET vedad = NULL;
		END IF;
		
		LET vpaso = 6;
		-- DIRECCION DEL CLIENTE
		SELECT MAX(secuencia)
		INTO vpmaxsecuenciadir
		FROM bdinteg:si_direcciones_actual 
		WHERE numcte = vnumcte
		AND tipo_dir = '1';
		
		SELECT TRIM(NVL(est.nombre, '')), TRIM(NVL(ctz.municipiozona, ''))
		INTO vestado_cliente, vmunicipio_cliente 
		FROM bdinteg:si_direcciones_actual dir
		LEFT JOIN bdinteg:si_estados est ON dir.estado::INTEGER = est.estado::INTEGER
		LEFT JOIN bdinteg:si_catzonas ctz ON dir.numerociudad = ctz.numerociudad AND dir.numerocolonia = ctz.numerocolonia
		WHERE dir.numcte = vnumcte
		AND dir.tipo_dir = '1'
		AND dir.secuencia = vpmaxsecuenciadir;
		
		LET vpaso = 7;
		-- ACTIVIDAD ECONOMICA
		SELECT NVL(MAX(id_secuencia),0)
		INTO vpmaxsecuenciaact
		FROM bdinteg:si_bitacoraapertura
		WHERE rfc = vrfc
		AND numcte = vnumcte 
		AND id_pregunta = 6;
		
		SELECT NVL(id_act,0), NVL(id_subact,0)
		INTO vpid_act, vpid_subact
		FROM bdinteg:si_bitacoraapertura
		WHERE rfc = vrfc
		AND numcte = vnumcte 
		AND id_pregunta = 6
		AND id_secuencia = vpmaxsecuenciaact;
		
		SELECT TRIM(NVL(descrip, ''))
		INTO vactividad_economica
		FROM bdinteg:si_actsubact
		WHERE id_act = vpid_act
		AND id_subact = vpid_subact;
		
		IF vactividad_economica = '' OR vactividad_economica IS NULL THEN
			LET vactividad_economica = 'Otros Servicios';
		END IF;
		
		LET vpaso = 8;
		-- SUCURSAL APERTURA CUENTA
		SELECT TRIM(NVL(ciu.nombre,'')), TRIM(NVL(est.nombre,''))
		INTO vmunicipio_apertura, vestado_apertura
		FROM bdinteg:si_sucursales suc
		LEFT JOIN bdinteg:si_ciudades ciu ON ciu.ciudad = suc.ciudad AND ciu.estado = suc.estado
		LEFT JOIN bdinteg:si_estados est ON suc.estado = est.estado
		WHERE suc.sucursal = vsucursal_apertura;
		
		LET vpaso = 9;
		-- INFORMACION CAJERO
		SELECT TRIM(NVL(pais,'')), TRIM(NVL(infreceptor,'')), TRIM(NVL(idterminal,''))
		INTO vppais, vnombre_atm, vnumero_atm
		FROM intercard:movimiento
		WHERE numtarjeta = vnum_tarjeta
		AND secuenciaextendida = SUBSTR(vpfolio_suc, 2, 15);
		
		LET vpaso = 10;
		-- NOMBRE PAIS
		SELECT COUNT(*)
		INTO vppaiscount
		FROM bdinteg:si_paises
		WHERE clave_pais = vppais;
		
		IF vppaiscount = 1 THEN
			SELECT TRIM(NVL(nombre,''))
			INTO vpais
			FROM bdinteg:si_paises
			WHERE clave_pais = vppais;
		ELSE
			LET vpais =  vppais;
		END IF;
		
		LET vpaso = 11;
		-- MONTO DLS
		SELECT LIMIT 1 precio
		INTO v_dolar
		FROM bdiauditor:tipo_cambio  --- SINONIMO
		WHERE empresa = '001'
		AND fecha_tc = v_fecha_ant_tc;
		
		LET vmonto_usd = vmonto_pesos / v_dolar;
		
		LET vpaso = 12;
		INSERT INTO rpt_retirosatmextranjero_cred_tmp(cuenta, num_tarjeta, monto_pesos, monto_usd, fecha_hora, fecha_aper_cuenta,
												 numcte, nombre, fecha_nacimiento, genero, nacionalidad, estado_cliente , municipio_cliente,
												 actividad_economica, sucursal_apertura, municipio_apertura, estado_apertura,
												 pais, nombre_atm, numero_atm, edad)
		VALUES(vcuenta, vnum_tarjeta, vmonto_pesos, vmonto_usd, vfecha_hora, vfecha_aper_cuenta, vnumcte, vnombre, vfecha_nacimiento,
		       vgenero, vnacionalidad, vestado_cliente, vmunicipio_cliente, vactividad_economica, vsucursal_apertura, vmunicipio_apertura,
			   vestado_apertura, vpais, vnombre_atm, vnumero_atm, vedad);
	
	END FOREACH;
	
	LET vpaso = 13;
	-- SE CREA SCRIPT
	LET vsql = '';
	LET vsql = 'echo "UNLOAD TO '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'.txt SELECT * FROM bdiauditor:rpt_retirosatmextranjero_cred_tmp;">'||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 14;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	
	LET vpaso = 15;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||TRIM(RUTA_DESTINO)||TRIM(NOMBRE_ARCHIVO)||'_01.sql';
	system vsql;
	
	
	LET cod_ret = '00000';
	LET vmensaje = 'PROCESO EXITOSO';

	RETURN cod_ret, vmensaje;
END;
END PROCEDURE
DOCUMENT 
'AUTOR: Jose Alejandro Jauregui Baez',
'FECHA: 17/10/2023',
'DESCRIPCION: Genera reporte de clientes que retiran efectivo de ATMs en el extranjero de credito',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_carga_geolocalizacion_bpi()
RETURNING CHAR(5) AS CodRet,
          CHAR(180) AS mensaje;

-- DeclaraciÃ³n de variables
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(250);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CTA 		VARCHAR(80);

--VARIABLES TABLA
DEFINE vconteo					INTEGER;
DEFINE vcount 					INTEGER;
DEFINE v_id_operacion 			CHAR(4);
DEFINE v_fecha_oper 			DATE;
DEFINE v_folio 					CHAR(16);
DEFINE v_cuenta_origen 			CHAR(12);
DEFINE v_destino 				CHAR(18);
DEFINE v_ipusuario 				CHAR(15);
DEFINE v_latitud 				CHAR(100);
DEFINE v_longitud 				CHAR(100);
DEFINE v_version 				CHAR(10);
DEFINE v_referencia_23 			CHAR(23);
DEFINE v_cve_geo 				CHAR(1);
DEFINE v_version_a 				CHAR(10);
DEFINE v_version_b 				CHAR(10);
DEFINE v_idregistro 			CHAR(7);

--VARIABLES DE PASO
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_menos_uno		DATE;


--SE INICIALIZAN VARIABLES
LET vpaso = 0;
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_carga_geolocalizacion_bpi en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CTA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_carga_geolocalizacion_bpi');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
    --SET DEBUG FILE TO "/ifxsif01/c90307913/sp_carga_geolocalizacion_bpi.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA Y LA FECHA DEL DIA MENOS 1 DIA
	SELECT fecha_hoy, fecha_ant
	INTO v_fecha_hoy, v_fecha_menos_uno
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_menos_uno), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_menos_uno), 2, '0');
	LET cAno = YEAR(v_fecha_menos_uno);
	
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CTA	 = 'CargaGeoLocalizacion_bpi_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".bpi_geolocalizacion_paso;
	COMMIT;
	
	
	LET vpaso = 4;
		
	
	LET vcount = 1;

	FOREACH WITH HOLD
		SELECT  id_operacion,fecha_oper,folio,cuenta_origen,destino,ipusuario,latitud,longitud,version,referencia_23,cve_geo,version_a,version_b
		INTO v_id_operacion,v_fecha_oper,v_folio,v_cuenta_origen,v_destino,v_ipusuario,v_latitud,v_longitud,v_version,v_referencia_23,v_cve_geo,v_version_a,v_version_b
		FROM bdibpi:bpi_geolocalizacion
		WHERE fecha_oper >= v_fecha_menos_uno AND fecha_oper < v_fecha_hoy

		
		LET vpaso = 5;
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF

		LET v_idregistro = LPAD(vcount, 7, '0');
		
		INSERT INTO "informix".bpi_geolocalizacion_paso (id_registro,id_operacion,fecha_oper,folio,cuenta_origen,destino,ipusuario,latitud,longitud,version,referencia_23,cve_geo,version_a,version_b, fecha_registro)	
		VALUES(v_idregistro,v_id_operacion,v_fecha_oper,v_folio,v_cuenta_origen,v_destino,v_ipusuario,v_latitud,v_longitud,v_version,v_referencia_23,v_cve_geo,v_version_a,v_version_b, v_fecha_menos_uno);
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;
		END IF

		LET vcount =  vcount + 1;
	
	END FOREACH
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF


	LET vpaso = 6;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'.txt select * from bdiauditor:bpi_geolocalizacion_paso;">'||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 7;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 8;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 9;
	LET cod_ret = '000000';
    LET vmensaje = 'EXITO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CTA);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_carga_geolocalizacion_bpi');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE

DOCUMENT 'AUTOR: Jose Alejandro Jauregui Baez',
'FECHA: 09/01/2024',
'DESCRIPCION: GeneraciÃ³n de informaciÃ³n geolocalizacion para sistemas MINDS PLD',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_carga_geolocalizacion_bpi2()
RETURNING CHAR(5) AS CodRet,
          CHAR(180) AS mensaje;

-- DeclaraciÃ³n de variables
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(250);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CTA 		VARCHAR(80);

--VARIABLES TABLA
DEFINE vconteo					INTEGER;
DEFINE vcount 					INTEGER;
DEFINE v_id_operacion 			CHAR(4);
DEFINE v_fecha_oper 			DATE;
DEFINE v_folio 					CHAR(16);
DEFINE v_cuenta_origen 			CHAR(12);
DEFINE v_destino 				CHAR(18);
DEFINE v_ipusuario 				CHAR(15);
DEFINE v_latitud 				CHAR(100);
DEFINE v_longitud 				CHAR(100);
DEFINE v_version 				CHAR(10);
DEFINE v_referencia_23 			CHAR(23);
DEFINE v_cve_geo 				CHAR(1);
DEFINE v_version_a 				CHAR(10);
DEFINE v_version_b 				CHAR(10);
DEFINE v_idregistro 			CHAR(7);

--VARIABLES DE PASO
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_menos_uno		DATE;


--SE INICIALIZAN VARIABLES
LET vpaso = 0;
LET vcommit = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_carga_geolocalizacion_bpi2 en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CTA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_carga_geolocalizacion_bpi2');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
    --SET DEBUG FILE TO "/ifxsif01/c90307913/sp_carga_geolocalizacion_bpi2.out";
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA Y LA FECHA DEL DIA MENOS 1 DIA
	SELECT fecha_hoy, fecha_ant
	INTO v_fecha_hoy, v_fecha_menos_uno
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_menos_uno), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_menos_uno), 2, '0');
	LET cAno = YEAR(v_fecha_menos_uno);
	
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO	 	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CTA	 = 'CargaGeoLocalizacion_bpi2_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".bpi_geolocalizacion_paso;
	COMMIT;
	
	
	LET vpaso = 4;
		
	
	LET vcount = 1;

	FOREACH WITH HOLD
		SELECT  id_operacion,fecha_oper,folio,cuenta_origen,destino,ipusuario,latitud,longitud,version,referencia_23,cve_geo,version_a,version_b
		INTO v_id_operacion,v_fecha_oper,v_folio,v_cuenta_origen,v_destino,v_ipusuario,v_latitud,v_longitud,v_version,v_referencia_23,v_cve_geo,v_version_a,v_version_b
		FROM bdibpi:bpi_geolocalizacion
		WHERE fecha_oper >= v_fecha_menos_uno AND fecha_oper < v_fecha_hoy AND version_a IS NOT NULL AND referencia_23 IS NULL

		
		LET vpaso = 5;
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF

		LET v_idregistro = LPAD(vcount, 7, '0');
		
		INSERT INTO "informix".bpi_geolocalizacion_paso (id_registro,id_operacion,fecha_oper,folio,cuenta_origen,destino,ipusuario,latitud,longitud,version,referencia_23,cve_geo,version_a,version_b, fecha_registro)	
		VALUES(v_idregistro,v_id_operacion,v_fecha_oper,v_folio,v_cuenta_origen,v_destino,v_ipusuario,v_latitud,v_longitud,v_version,v_referencia_23,v_cve_geo,v_version_a,v_version_b, v_fecha_menos_uno);
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;
		END IF

		LET vcount =  vcount + 1;
	
	END FOREACH
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF


	LET vpaso = 6;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'.txt select * from bdiauditor:bpi_geolocalizacion_paso;">'||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 7;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 8;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CTA||'_01.sql';
	system vsql;
	
	LET vpaso = 9;
	LET cod_ret = '000000';
    LET vmensaje = 'EXITO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CTA);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_carga_geolocalizacion_bpi2');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE

DOCUMENT 'AUTOR: Jose Alejandro Jauregui Baez',
'FECHA: 09/01/2024',
'DESCRIPCION: GeneraciÃ³n de informaciÃ³n geolocalizacion para sistemas MINDS PLD',
'BD: bdiauditor';

CREATE PROCEDURE "informix".sp_mindscuentasrelacionadas_diario()
RETURNING CHAR(6) AS cod_ret,
		  CHAR(80) AS mensaje;

--DECLARACION DE VARIABLES		  
DEFINE cod_ret					CHAR(6);
DEFINE vmensaje					CHAR(80);	
DEFINE vpaso		    		INTEGER;
DEFINE vcommit					INTEGER;
DEFINE SQL_ERR          		INTEGER;
DEFINE ISAM_ERR         		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE vsql						CHAR(200);
DEFINE RUTA_DESTINO 			VARCHAR(80);
DEFINE TIPO_PLANTILLA_CUENTASRELACIONADAS	VARCHAR(50);

--VARIABLE LAYOUT cta relacionada
DEFINE  v_idregistro				INTEGER;
DEFINE 	v_nocuenta					CHAR(20);
DEFINE 	v_cuentarelacionada			CHAR(20);
DEFINE	v_titularcuenta				CHAR(104);
DEFINE  v_propositocuenta			CHAR(10);
DEFINE  v_idestatuscargaminds		INTEGER;
DEFINE  v_notransaccion				INTEGER;
DEFINE  v_montomensual				DECIMAL(14,2);
DEFINE	v_idrelacion				INTEGER;
DEFINE	v_rfc						CHAR(13);
DEFINE  v_esdeposito				INTEGER;
DEFINE  v_esretiro					INTEGER;
DEFINE  v_eraconocida				INTEGER;
DEFINE	v_tipopersonarel			CHAR(2);
DEFINE  v_fecharegistro 			CHAR(10);
DEFINE 	v_fechaactualizacion		CHAR(10);
DEFINE 	v_idtipocuenta              CHAR(1);


--VARIABLES DE PASO
DEFINE temp_fecharegistro		DATE;
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vconteo					INTEGER;
DEFINE nombrepf1 				CHAR(26);
DEFINE nombrepf2 				CHAR(26);
DEFINE v_apaterno				CHAR(26);
DEFINE v_amaterno 				CHAR(26);
DEFINE v_idsexo					CHAR(1);

--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET v_nocuenta = '';
LET v_cuentarelacionada= '';
LET v_propositocuenta = '5';
LET v_titularcuenta = null;
LET	v_rfc = '';
LET v_idrelacion = 0;
LET v_tipopersonarel = '';
LET v_esdeposito = 0;
LET v_esretiro = 0;
LET v_eraconocida = 0;
LET v_idregistro = 0;
LET v_notransaccion = 0;
LET v_montomensual = 0;
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;
LET v_idtipocuenta = '1';
LET v_idsexo = '';

BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindscuentasrelacionadas_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_CUENTASRELACIONADAS,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindscuentasrelacionadas_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindscuentasrelacionadas_diario.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vpaso = 1;
	
	--OBTIENE LA FECHA DEL DIA ANTERIOR DE LA FECHA ACTUAL
	SELECT fecha_hoy, fecha_ant 
	INTO v_fecha_hoy, v_fecha_ant
	FROM bdinteg:si_fechas;
	
	LET vpaso = 2;
	
	LET cDia = LPAD(DAY(v_fecha_ant), 2, '0');
	LET cMes = LPAD(MONTH(v_fecha_ant), 2, '0');
	LET cAno = YEAR(v_fecha_ant);
	--DA FORMATO 'AAAAMMDD' A LA FECHA
	LET cFecha = cAno||cMes||cDia;
	LET RUTA_DESTINO = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_CUENTASRELACIONADAS = 'CargaCtaRelMinds_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_cuentarelacionada_minds;
	COMMIT;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD
		SELECT se.numcte,se.cuenta,sd.nombre1,sd.nombre2,sd.apell_paterno,sd.apell_materno,se.tipo_relacion,sd.rfc,se.parentesco,se.fecha_insert
		INTO v_nocuenta,v_cuentarelacionada,nombrepf1,nombrepf2,v_apaterno,v_amaterno,v_idrelacion,v_rfc,v_tipopersonarel,temp_fecharegistro
		FROM bdinteg:si_cterelacionado se
		LEFT JOIN bdinteg:si_cliente sd ON se.numcte = sd.numcte
		WHERE sd.tipo_cliente = '1'
		AND se.fecha_insert = v_fecha_ant
        AND se.sistema<>'SV'
		
		LET vpaso = 5;
		
		SELECT sexo
		INTO v_idsexo
		FROM bdinteg:si_ctepf 
		where numcte = v_nocuenta;
		
		LET vpaso = 6;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		LET v_titularcuenta = TRIM(nombrepf1)||' '||TRIM(nombrepf2)||' '||TRIM(v_apaterno)||' '||TRIM(v_amaterno);
		LET v_fecharegistro = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET v_fechaactualizacion = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET vconteo = vconteo + 1;
		
		IF (v_tipopersonarel IS NULL or v_tipopersonarel = '0' or v_tipopersonarel = '01' or v_tipopersonarel = 'S' 
			or v_tipopersonarel = 'O' or v_tipopersonarel = 'M' or v_tipopersonarel = 'K' or v_tipopersonarel = '') THEN
			LET v_tipopersonarel = '1';
		ELIF (v_tipopersonarel = 'A' ) THEN
			LET v_tipopersonarel = '2';
		ELIF (v_tipopersonarel = 'B' ) THEN
			LET v_tipopersonarel = '11';
		ELIF (v_tipopersonarel = 'C' ) THEN
			LET v_tipopersonarel = '12';
		ELIF (v_tipopersonarel = 'E' ) THEN
			LET v_tipopersonarel = '10';
		ELIF (v_tipopersonarel = 'H' ) THEN
			LET v_tipopersonarel = '6';
		ELIF (v_tipopersonarel = 'I' ) THEN
			LET v_tipopersonarel = '13';
		ELIF (v_tipopersonarel = 'J' ) THEN
			LET v_tipopersonarel = '5';
		ELIF (v_tipopersonarel = 'N' ) THEN
			LET v_tipopersonarel = '7';
		ELIF (v_tipopersonarel = 'R' ) THEN
			LET v_tipopersonarel = '9';
		ELIF (v_tipopersonarel = 'T' ) THEN
			LET v_tipopersonarel = '8';
		ELIF (v_tipopersonarel = 'U' ) THEN
			LET v_tipopersonarel = '14';
		ELIF (v_tipopersonarel = 'P' and v_idsexo = 'M' ) THEN
			LET v_tipopersonarel = '3';
		ELIF (v_tipopersonarel = 'P' and v_idsexo = 'F' ) THEN
			LET v_tipopersonarel = '4';
		END IF
			
		LET vpaso = 7;
		
		INSERT INTO "informix".tbl_cuentarelacionada_minds(idregistro,idtipocuenta,nocuenta,cuentarelacionada,titularcuenta,propositocuenta,idestatuscargaminds,fechaactualizacion,notransaccion,montomensual,idrelacion,rfc,esdeposito,esretiro,eraconocida,tipopersonarel,fecharegistro)
		VALUES(vconteo,v_idtipocuenta,v_cuentarelacionada,v_cuentarelacionada,v_titularcuenta,V_propositocuenta,v_idestatuscargaminds,v_fechaactualizacion,v_notransaccion,v_montomensual,v_idrelacion,v_rfc,v_esdeposito,v_esretiro,v_eraconocida,v_tipopersonarel,v_fecharegistro);
		
		LET vpaso = 8;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
	END FOREACH
	
	LET vpaso = 9;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 10;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'.txt select * FROM bdiauditor:tbl_cuentarelacionada_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 11;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql';
	system vsql;
	
	LET vpaso = 12;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_CUENTASRELACIONADAS||'_01.sql';
	system vsql;
	
	LET vpaso = 13;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_CUENTASRELACIONADAS);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindscuentasrelacionadas_diario');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE;