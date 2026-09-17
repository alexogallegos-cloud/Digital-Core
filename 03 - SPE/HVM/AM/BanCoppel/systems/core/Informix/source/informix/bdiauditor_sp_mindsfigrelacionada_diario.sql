CREATE PROCEDURE "informix".sp_mindsfigrelacionada_diario()
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
DEFINE TIPO_PLANTILLA_FIGRELACIONADA	VARCHAR(50);

--VARIABLE LAYOUT FIGURA RELACIONADA
DEFINE v_idactividadeconomica	CHAR(10);
DEFINE v_idtipopersona			INTEGER;
DEFINE v_idsexo					CHAR(1);
DEFINE v_idparentesco			CHAR(20);
DEFINE v_idpaisnacimiento		CHAR(3);
DEFINE v_nic					CHAR(20);
DEFINE v_porcentaje				DECIMAL(14,2);
DEFINE v_nocuenta				CHAR(20);
DEFINE v_fechanacimiento		CHAR(10);
DEFINE v_nombre					CHAR(60);
DEFINE v_apaterno				CHAR(26);
DEFINE v_amaterno 				CHAR(26);
DEFINE v_idestado				CHAR(8);
DEFINE v_idestadonacimiento		INTEGER;
DEFINE v_idplaza				INTEGER;
DEFINE v_calle					CHAR(30);
DEFINE v_numeroext				CHAR(10);
DEFINE v_numeroint				CHAR(10);
DEFINE v_colonia				CHAR(32);
DEFINE v_cp						CHAR(5);
DEFINE v_nic_figura				CHAR(2);
DEFINE v_fecharegistro			CHAR(10);
DEFINE v_estatus				INTEGER;
DEFINE v_idestatuscargaminds	INTEGER;
DEFINE v_idtipofiguralegal		CHAR(1);
DEFINE v_idmunicipio 			CHAR(8);
DEFINE v_idnacionalidad			CHAR(3);
DEFINE v_rfc					CHAR(13);
DEFINE v_curp					CHAR(20);
DEFINE v_email					CHAR(50);
DEFINE v_idpaisnacionalidad		CHAR(3);
DEFINE v_trust_contribution		CHAR(1);
DEFINE v_fechaactualizacion		CHAR(10);
DEFINE v_idpaisasignacionfiscal	CHAR(3);
DEFINE v_id_act					INTEGER;
DEFINE v_id_subact  			INTEGER;
DEFINE v_id_secuencia			INTEGER;

--VARIABLES DE PASO
DEFINE temp_fechafechanacimiento DATE;
DEFINE temp_fecharegistro		DATE;
DEFINE nombrepf1 				CHAR(26);
DEFINE nombrepf2 				CHAR(26);
DEFINE nombrepm 				CHAR(60);
DEFINE v_fecha_hoy				DATE;
DEFINE v_fecha_ant				DATE;
DEFINE cDia		  				CHAR(2);
DEFINE cMes		  				CHAR(2);
DEFINE cAno		  				CHAR(4);
DEFINE cFecha  					CHAR(8);
DEFINE vconteo					INTEGER;
DEFINE v_estado					CHAR(2);
DEFINE v_clave_pais				CHAR(3);
DEFINE v_ciudad					CHAR(3);

--SE INICIALIZAN VARIABLES
LET v_idestatuscargaminds = 0;
LET vcommit = 0;
LET v_estatus = 1;
LET v_nic_figura = '01';
LET v_idtipofiguralegal = ' ';
LET v_idmunicipio = '99999999';
LET v_trust_contribution = '0';
LET cDia = '';
LET cMes = '';
LET cAno = '';
LET vconteo = 0;
LET v_idpaisasignacionfiscal = 'MX';


BEGIN
    
    --CONTROL DE ERRORES
    ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        IF 	vcommit <> 0 THEN
			COMMIT WORK;
		END IF
		LET cod_ret  = SQL_ERR;
        LET vmensaje  = TRIM(ERROR_INFO)||' sp_mindsfigrelacionada_diario en el paso '||vpaso;
		INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,errorproceso,rutina)
		VALUES (v_fecha_hoy,'ERROR EN EL PROCESO PARA GENERAR EL: '||TIPO_PLANTILLA_FIGRELACIONADA,vconteo,vconteo,0,0,cod_ret||' '||vmensaje,'sp_mindsfigrelacionada_diario');
        RETURN cod_ret, vmensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/jarias/sp_mindsfigrelacionada_diario.out';
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
	LET RUTA_DESTINO	 			  = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA_FIGRELACIONADA = 'CargaFigRelMinds_'||TRIM(cFecha);
	
	LET vpaso = 3;
	
	---Borrado de la tabla de paso
	BEGIN;
		TRUNCATE TABLE "informix".tbl_figrelacionada_minds;
	COMMIT;
	
	LET vpaso = 4;
	
	FOREACH WITH HOLD--SOLO BENEFICIARIOS
		SELECT ben.parentesco,ben.numcte,ben.porcentaje,ben.cuenta,noc.fecha_alta
		INTO v_idparentesco,v_nic,v_porcentaje,v_nocuenta,temp_fecharegistro
		FROM bdicheq:sc_beneficiario ben, bdicheq:sc_maenoc noc, bdinteg:si_cliente cli
		WHERE ben.cuenta = noc.cuenta 
		AND ben.numcte = cli.numcte
		AND cli.tipo_cliente = '1'
		AND noc.fecha_alta = v_fecha_ant
		
		LET vpaso = 5;
		
		IF 	vcommit = 0 THEN
			BEGIN WORK;
		END IF
		
		LET vpaso = 6;
		
		SELECT tpo_persona,nombre1,nombre2,razon_social,apell_paterno,apell_materno,rfc
		INTO v_idtipopersona,nombrepf1,nombrepf2,nombrepm,v_apaterno,v_amaterno,v_rfc
		FROM bdinteg:si_cliente 
		WHERE numcte = v_nic;
		
		IF v_idtipopersona IN(1,3) THEN --PERSONA FISICA
			
			LET vpaso = 7;
			
			
			SELECT fecha_nac,sexo,lugar_nac,nacionalidad,curp,id_pais
			INTO temp_fechafechanacimiento,v_idsexo,v_estado,v_idnacionalidad,v_curp,v_clave_pais
			FROM bdinteg:si_ctepf 
			WHERE numcte = v_nic;
			
			IF v_idsexo = 'F' THEN
				LET v_idsexo = '2';
			ELIF v_idsexo = 'M' THEN
				LET v_idsexo = '1';
			END IF
						
			-- ACTIVIDAD ECONOMICA
			SELECT MAX(id_secuencia)
			INTO v_id_secuencia
			FROM bdinteg:si_bitacoraapertura
			WHERE numcte = v_nic
			AND id_pregunta = 6;
			
			IF v_id_secuencia IS NULL THEN
				LET v_id_secuencia = 0;
			END IF
			
			SELECT FIRST 1 id_act, id_subact
			INTO v_id_act, v_id_subact
			FROM bdinteg:si_bitacoraapertura
			WHERE numcte = v_nic
			AND id_pregunta = 6
			AND id_secuencia = v_id_secuencia;
			
			SELECT idcnbv
			INTO v_idactividadeconomica
			FROM bdinteg:si_actsubact
			WHERE id_act = v_id_act
			AND id_subact = v_id_subact;
			
			IF (v_idactividadeconomica = '0000000') OR (v_idactividadeconomica IS NULL) OR (v_idactividadeconomica = '') THEN
			LET v_idactividadeconomica = '9999999';
		END IF
			
			LET vpaso = 8;
			
			SELECT estado 
			INTO v_idestadonacimiento
			FROM bdinteg:si_estados
			WHERE estado = v_estado;
			
			IF (v_idestadonacimiento < 1) OR (v_idestadonacimiento > 32) OR (v_idestadonacimiento IS NULL) THEN
				LET v_idestadonacimiento = 99999999;
			END IF
			
			LET v_nombre = TRIM(nombrepf1) || " " || TRIM(nombrepf2);
			LET v_fechanacimiento = to_char(temp_fechafechanacimiento, '%Y-%m-%d');
			
			IF (v_idparentesco IS NULL or v_idparentesco = '0' or v_idparentesco = '01' or v_idparentesco = 'S' 
			or v_idparentesco = 'O' or v_idparentesco = 'M' or v_idparentesco = 'K' or v_idparentesco = '') THEN
			LET v_idparentesco = '1';
		    ELIF (v_idparentesco = 'A' ) THEN
		    	LET v_idparentesco = '2';
		    ELIF (v_idparentesco = 'B' ) THEN
		    	LET v_idparentesco = '11';
		    ELIF (v_idparentesco = 'C' ) THEN
		    	LET v_idparentesco = '12';
		    ELIF (v_idparentesco = 'E' ) THEN
		    	LET v_idparentesco = '10';
		    ELIF (v_idparentesco = 'H' ) THEN
		    	LET v_idparentesco = '6';
		    ELIF (v_idparentesco = 'I' ) THEN
		    	LET v_idparentesco = '13';
		    ELIF (v_idparentesco = 'J' ) THEN
		    	LET v_idparentesco = '5';
		    ELIF (v_idparentesco = 'N' ) THEN
		    	LET v_idparentesco = '7';
		    ELIF (v_idparentesco = 'R' ) THEN
		    	LET v_idparentesco = '9';
		    ELIF (v_idparentesco = 'T' ) THEN
		    	LET v_idparentesco = '8';
		    ELIF (v_idparentesco = 'U' ) THEN
		    	LET v_idparentesco = '14';
		    ELIF (v_idparentesco = 'P' and v_idsexo = '1' ) THEN
		    	LET v_idparentesco = '3';
		    ELIF (v_idparentesco = 'P' and v_idsexo = '2' ) THEN
		    	LET v_idparentesco = '4';
		    END IF
			
			LET vpaso = 9;
			
			SELECT clave_pais
			INTO v_idpaisnacimiento
			FROM bdinteg:si_paises
			WHERE clave_pais = v_clave_pais;
			
			IF (v_idpaisnacimiento IS NULL) OR (v_idpaisnacimiento = '') THEN
				LET v_idpaisnacimiento = 'ZZ';
			END IF
			
			LET v_idpaisnacionalidad = v_idpaisnacimiento;			
			LET vpaso = 10;
			
			SELECT FIRST 1 {+INDEX(bdinteg:si_correos idx_corr_cte_cons)} correo_elec
			INTO v_email
			FROM bdinteg:si_correos
			WHERE status_correo = 'A' 
			AND tipo_correo = '1'
			AND numcte = v_nic;
			
			LET vpaso = 11;
			
		ELIF v_idtipopersona IN(2,4,5) THEN --PERSONA MORAL
			
			LET vpaso = 12;
			
			SELECT fecha_constitct,nacionalidad,emailpm
			INTO temp_fechafechanacimiento,v_idnacionalidad,v_email
			FROM bdinteg:si_ctepm 
			WHERE numcte = v_nic;
			
			LET v_nombre = TRIM(nombrepm);
			LET v_apaterno = NULL;
			LET v_amaterno = NULL;
			LET v_fechanacimiento = to_char(temp_fechafechanacimiento, '%Y-%m-%d');
			LET v_idsexo = '3';
			LET v_idpaisnacimiento = 'ZZ';
			LET v_idpaisnacionalidad = 'ZZ';
			LET v_idestadonacimiento = 99999999;
			LET v_curp = NULL;
			
			LET vpaso = 13;
			
		END IF
		
		LET vpaso = 14;
		
		IF v_fechanacimiento < '1900-01-01' THEN
			LET v_fechanacimiento = '1900-01-01';
		END IF
		
		IF v_idnacionalidad = '001' THEN
			LET v_idnacionalidad = '1';		ELSE
			LET v_idnacionalidad = '2';		END IF
		
		LET v_fechaactualizacion = to_char(temp_fecharegistro, '%Y-%m-%d');
		LET v_fecharegistro = to_char(temp_fecharegistro, '%Y-%m-%d');
		
		LET vpaso = 15;
		
		SELECT FIRST 1 sda.ciudad,scc.nombrecalle, sda.numeroextcalle, sda.numerointcalle,scz.nombrezona,sda.cod_postal,sda.estado
		INTO v_ciudad,v_calle,v_numeroext,v_numeroint,v_colonia,v_cp,v_estado
		FROM bdinteg:si_direcciones_actual sda, 
			bdinteg:si_catzonas scz, 
			bdinteg:si_catcalles scc
		WHERE sda.numcte = v_nic
		AND sda.numerocolonia = scz.numerocolonia
		AND sda.numerociudad = scz.numerociudad 
		AND sda.numerocalle = scc.numerocalle
		AND sda.tipo_dir = '1';
		
		LET vpaso = 16;
		
		SELECT estado 
		INTO v_idestado
		FROM bdinteg:si_estados 
		WHERE estado = v_estado;
		
		IF (v_idestado < 1) OR (v_idestado > 32) OR (v_idestado IS NULL) THEN
			LET v_idestado = 99999999;
		END IF
		
		LET vpaso = 17;
		
		SELECT localidad_banxico 
		INTO v_idplaza
		FROM bdinteg:si_ciudades 
		WHERE ciudad = v_ciudad AND estado = v_estado;
		
		-- MAPEO DE PLAZAS QUE NO SE ENCUENTRAN EN EL CATALOGO DE MINDS
		-- CUMPLIMIENTO PROPORCIONO EL SIGUIENTE MAPEO
		IF (v_idplaza = 48407017) THEN 
			LET v_idplaza = 717009; 
		ELIF (v_idplaza = 48415013) THEN
			LET v_idplaza = 1738007; 
		ELIF (v_idplaza = 48415106) THEN
			LET v_idplaza = 1808002; 
		ELIF (v_idplaza = 48415109) THEN
			LET v_idplaza = 1811008; 
		ELIF (v_idplaza = 48415120) THEN
			LET v_idplaza = 1811008; 
		ELIF (v_idplaza = 48419048) THEN
			LET v_idplaza = 2349009; 
		ELIF (v_idplaza = 48421094) THEN
			LET v_idplaza = 3094009; 
		ELIF (v_idplaza = 48426029) THEN
			LET v_idplaza = 3799003; 
		ELIF (v_idplaza = 0) OR (v_idplaza IS NULL) OR (v_idplaza = '') THEN
			LET v_idplaza = 99999999;
		END IF
		
		IF (v_cp = '') OR (v_cp IS NULL) OR (v_cp IN ('0','00','00000','CP563','MZ69','O','S-CP4')) THEN
			LET v_cp = '99999';
		END IF
		
		LET vpaso = 18;
		
		LET v_nombre 	= REPLACE(v_nombre,'|','');
		LET v_apaterno 	= REPLACE(v_apaterno,'|','');
		LET v_amaterno 	= REPLACE(v_amaterno,'|','');
		LET v_rfc 		= REPLACE(v_rfc,'|','');
		LET v_curp 		= REPLACE(v_curp,'|','');
		LET v_calle 	= REPLACE(v_calle,'|','');
		LET v_numeroext = REPLACE(v_numeroext,'|','');
		LET v_numeroint = REPLACE(v_numeroint,'|','');
		LET v_colonia 	= REPLACE(v_colonia,'|','');
		LET v_cp 		= REPLACE(v_cp,'|','');
		LET v_email 	= REPLACE(v_email,'|','');
		LET vconteo = vconteo + 1;
		
		LET vpaso = 19;
		
		IF v_idtipopersona = 1 THEN -- PERSONA FISICA
			LET v_idtipopersona = 2;
		ELIF v_idtipopersona IN (2, 4, 5) THEN -- PERSONA MORAL
			LET v_idtipopersona = 1;
		END IF
		
		LET vpaso = 20;
		
		INSERT INTO "informix".tbl_figrelacionada_minds (idregistro,idactividadeconomica,idtipopersona,idsexo,idtipofiguralegal,idparentesco,idpais,idpaisnacimiento,idestado,idestadonacimiento,idmunicipio,idplaza,idnacionalidad,nic,nombre,apellidopaterno,apellidomaterno,fechanacimiento,rfc,curp,calle,
														numeroext,numeroint,colonia,cp,email,porcentaje,estatus,idpaisnacionalidad,trust_contribution,fechaactualizacion,idestatuscargaminds,nocuenta,nic_figura,idpaisasignacionfiscal,fecharegistro)
		VALUES (vconteo,v_idactividadeconomica,v_idtipopersona,v_idsexo,v_idtipofiguralegal,v_idparentesco,v_idpaisnacimiento,v_idpaisnacimiento,v_idestado,v_idestadonacimiento,v_idmunicipio,v_idplaza,v_idnacionalidad,v_nic,v_nombre,v_apaterno,v_amaterno,v_fechanacimiento,v_rfc,v_curp,v_calle,
				v_numeroext,v_numeroint,v_colonia,v_cp,v_email,v_porcentaje,v_estatus,v_idpaisnacionalidad,v_trust_contribution,v_fechaactualizacion,v_idestatuscargaminds,v_nocuenta,v_nic_figura,v_idpaisasignacionfiscal,v_fecharegistro);	
		
		LET vpaso = 20;
		
		LET vcommit = vcommit + 1;
		IF 	vcommit = 1000 THEN
			COMMIT WORK;
			LET vcommit = 0;			
		END IF
	END FOREACH
	
	LET vpaso = 21;
	
	IF 	vcommit <> 0 THEN
		COMMIT WORK;
		LET vcommit = 0;
	END IF
	
	LET vpaso = 22;	
	--SE PREPARA LA RUTA DEL SCRIPT PARA LA DESCARGA DE CUENTAS
	LET vsql = 'echo "UNLOAD TO '||RUTA_DESTINO||TIPO_PLANTILLA_FIGRELACIONADA||'.txt select * FROM bdiauditor:tbl_figrelacionada_minds;">'||RUTA_DESTINO||TIPO_PLANTILLA_FIGRELACIONADA||'_01.sql'; 
	system vsql;
	LET vsql = '';
	
	LET vpaso = 23;
	--SE EJECUTA EL SCRIPT
	LET vsql = 'chmod 777 '||RUTA_DESTINO||TIPO_PLANTILLA_FIGRELACIONADA||'_01.sql';
	system vsql;
	LET vsql = '';
	LET vsql = 'dbaccess bdiauditor '||RUTA_DESTINO||TIPO_PLANTILLA_FIGRELACIONADA||'_01.sql';
	system vsql;
	
	LET vpaso = 24;
	--SE BORRA EL SCRIPT
	LET vsql = '';
	LET vsql = 'rm '||RUTA_DESTINO||TIPO_PLANTILLA_FIGRELACIONADA||'_01.sql';
	system vsql;
	
	LET vpaso = 25;
	LET cod_ret = '000000';
    LET vmensaje = 'PROCESO EXITOSO, SE HA GENERADO EL ARCHIVO: '||TRIM(TIPO_PLANTILLA_FIGRELACIONADA);
	
	INSERT INTO "informix".tbl_logextraccion_minds(fechaejecucion,proceso,numregistros,regnuevos,regactualizados,regbaja,rutina)
	VALUES (v_fecha_hoy,vmensaje,vconteo,vconteo,0,0,'sp_mindsfigrelacionada_diario');
	
	RETURN cod_ret, vmensaje;
	
END;
END PROCEDURE;