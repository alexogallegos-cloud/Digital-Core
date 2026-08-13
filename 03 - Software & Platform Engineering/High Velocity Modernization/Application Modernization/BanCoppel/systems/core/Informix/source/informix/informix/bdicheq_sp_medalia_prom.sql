CREATE PROCEDURE "informix".sp_medalia_prom( pEmpresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
       
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(80);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(80);
    DEFINE vComienza            INTEGER;
    DEFINE vEnTransacc          SMALLINT;
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vFechaHoy            DATE;
    DEFINE vfecha_ant           DATE;
    DEFINE vCuenta              CHAR(20);
	DEFINE vNumCliente          CHAR(20);
    DEFINE vNombreCliente       CHAR(120);
    DEFINE vsql                 CHAR(1200);
    DEFINE vstmt                CHAR(250);
    DEFINE vfecha               CHAR(10);
    DEFINE vSucursal            CHAR(4);
	DEFINE vSucursalMto			CHAR(4);
	DEFINE vnombre1             CHAR(30);
	DEFINE vnombre2             CHAR(30);
	DEFINE vapell_paterno       CHAR(30);
	DEFINE vapell_materno       CHAR(30);
    DEFINE vfecha_alta          DATE;
    DEFINE vtransacc            CHAR(4);
    DEFINE vnombre_suc          CHAR(40);
    DEFINE vfecha_nac           DATE;
    DEFINE vsexo                CHAR(1);
    DEFINE ves_fisica           CHAR(1);
    DEFINE vcorreo              CHAR(100);
    DEFINE vtel_casa            CHAR(13);
    DEFINE vtel_movil           CHAR(13);
    DEFINE vtpo_persona         CHAR(2);
    DEFINE vgenero              CHAR(10);
    DEFINE vfecha_mov           CHAR(10);
    DEFINE vedad                INTEGER;
    DEFINE vdigito_verif        INTEGER;
    DEFINE vfecha_insert        DATE;
    DEFINE vantiguedad          INTEGER;
    DEFINE vmora                CHAR(6);
    DEFINE vescolaridad         CHAR(20);
    DEFINE vingresos            INTEGER;
    DEFINE vsucursal_cte        CHAR(4);
    DEFINE vlinea_credito       INTEGER;
    DEFINE vdependientes        INTEGER;
    DEFINE cCalle               CHAR(40); 
    DEFINE cNumExt              CHAR(10); 
    DEFINE cNumInt              CHAR(10); 
    DEFINE cDepart              CHAR(10); 
    DEFINE cColonia             CHAR(40); 
    DEFINE cMunicipio           CHAR(30); 
    DEFINE cCiudad              CHAR(20); 
    DEFINE cCodPos              CHAR(5);
    DEFINE cEstado              CHAR(10); 
    DEFINE vDireccion           CHAR(200);
    DEFINE vgeneracion          CHAR(13);
    DEFINE vpromotor            CHAR(8);
	--DEFINE vnombre_promotor		varchar(100);
    DEFINE vtipo_pago           CHAR(20);
    DEFINE vnum_micro           INTEGER;
    DEFINE vpago_club           INTEGER;
    DEFINE vclub_protec         CHAR(2);
    DEFINE vno_productos        INTEGER;
    DEFINE vsit_especial        CHAR(4);
    DEFINE vpta_act_autor       DECIMAL(14,2);
    DEFINE vpoliza_cp           INTEGER;
    DEFINE vfecha_nac_cte       CHAR(10);
    DEFINE vcentro              INTEGER;
    DEFINE vtpo_canal           CHAR(30);
    DEFINE vtpo_sistema         CHAR(10);
    DEFINE vtpo_producto        CHAR(10);
    DEFINE vtpo_transacc        CHAR(80);
    DEFINE vsegmento            CHAR(80);
    DEFINE vtpo_autoriza        CHAR(20);
    DEFINE vedo_civil           CHAR(1);
    DEFINE vestado_civil        CHAR(15);
    DEFINE vproducto            CHAR(40);
	DEFINE vproductoc			CHAR(4);
    DEFINE vNoCteClub           CHAR(20);
    DEFINE vMontoClub           DECIMAL(14,2);
	DEFINE vId_estatus			VARCHAR(2);
	DEFINE vTransaccmov			VARCHAR(4);
	DEFINE vNumcta				VARCHAR(20);
	DEFINE vMonto_clie          DECIMAL(18,2);
	DEFINE vfecha_alta_club_prote DATE;
	DEFINE vmotivo_rechazo      CHAR(50);
	
	
    
    LET Sql_Err	          = 0;
    LET Isam_Err          = 0;
    LET Desc_Err          = '';
    LET vCodRet1          = '00000';
    LET vCodRet2          = '';
    LET vCodRet3          = '';
    LET vComienza         = -1;
    LET vEnTransacc       = 0;
    LET vContador1        = 0;
    LET vContador2        = 0;
    LET vFechaHoy         = '';
    LET vfecha_ant        = '';
    LET vCuenta           = '';   
    LET vNumCliente       = '';
    LET vsql              = '';
    LET vstmt             = '';
    LET vfecha            = '';
    LET vSucursal         = '';
	LET vSucursalMto	  = '';
    LET vnombre1          = '';
	LET vnombre2          = '';
	LET vapell_paterno    = '';
	LET vapell_materno    = '';
    LET vfecha_alta       = '';
    LET vtransacc         = '';
    LET vnombre_suc       = '';
    LET vfecha_nac        = '';
    LET vsexo             = '';
    LET ves_fisica        = '';
    LET vcorreo           = '';
    LET vtel_casa         = '';
    LET vtel_movil        = '';
    LET vtpo_persona      = '';
    LET vgenero           = '';
    LET vfecha_mov        = '';
    LET vedad             = 0;
    LET vdigito_verif     = 0;
    LET vfecha_insert     = '';
    LET vantiguedad       = 0;
    LET vmora             = 'null';
    LET vescolaridad      = 'null';
    LET vingresos         = 0;
    LET vsucursal_cte     = '';
    LET vlinea_credito    = 0;
    LET vdependientes     = 0;
    LET cCalle            = '';
    LET cNumExt           = '';
    LET cNumInt           = '';
    LET cDepart           = '';
    LET cColonia          = '';
    LET cMunicipio        = '';
    LET cCiudad           = '';
    LET cCodPos           = '';
    LET cEstado           = '';
    LET vDireccion        = '';
    LET vgeneracion       = 'null';
    LET vpromotor         = '';
	--LET vnombre_promotor  = '';
    LET vtipo_pago        = 'null';
    LET vnum_micro        = 0;
    LET vpago_club        = 0;
    LET vclub_protec      = '';
    LET vno_productos     = 0;
    LET vsit_especial     = 'null';
    LET vpta_act_autor    = 0;
    LET vpoliza_cp        = 0;
    LET vfecha_nac_cte    = '';
    LET vcentro           = 0;
    LET vtpo_canal        = 'PROMOTORIA';
    LET vtpo_sistema      = 'null';
    LET vtpo_producto     = 'null';
    LET vtpo_transacc     = '';
    LET vsegmento         = 'null';
    LET vtpo_autoriza     = 'null';
    LET vedo_civil        = '';
    LET vestado_civil     = '';
    LET vproducto         = '';
	LET vproductoc		  = '';
    LET vNoCteClub        = '';
    LET vMontoClub        = 0.00;
	LET vId_estatus  	  = '4';
	LET vTransaccmov      = '';
	LET vNumcta 		  = '';
	LET vMonto_clie       = 0.00;
	LET vfecha_alta_club_prote = '';
	LET vmotivo_rechazo   ='';
	
	BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
         IF Sql_Err <> 0 THEN
		 SET DEBUG FILE TO "/resplogifx/conciliachq/medalia/sp_medalia_prom.err";
         TRACE ON;
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            LET vCuenta = vCuenta;
            LET vNumCliente = vNumCliente;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
        END IF;
    END EXCEPTION;
    
     --SET DEBUG FILE TO "/home/c98789058/INCIDENCIA_MEDALIA_PROMOTORIA/sp_medalia_prom.out";
     --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, fecha_ant
      INTO vFechaHoy, vfecha_ant
      FROM sc_fechas
     WHERE empresa = pEmpresa;
	 
    --LET vFechaHoy = '29072023';
    --LET vfecha_ant = '28072023';

    TRUNCATE TABLE sc_medalia_ctes_prom;
	
	
	--Aplicamos estadisticas para que no despierten en la madrugada, este tema no lo atiende BD Centrales.
	UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:sc_medalia_ctes_prom;
	
	
	--Apertura de cuentas captacion
    FOREACH cursor_cliente_1 WITH HOLD FOR
        SELECT UNIQUE mae.num_cte
          INTO vNumCliente
          FROM sc_maechq mae,
               sc_maenoc noc,
               bdinteg:si_cliente cte,
               bdinteg:si_tipper tip
         WHERE mae.cuenta = noc.cuenta
           AND noc.fecha_alta = vfecha_ant
           AND cte.numcte = mae.num_cte
           AND tip.tpo_persona = cte.tpo_persona
           AND tip.tpo_persona = '01'
		union all
		select unique num_cte 
			  from bdinvers:sv_maeinv inv
              inner join bdinteg:si_cliente cli on (inv.empresa = cli.empresa and inv.num_cte = cli.numcte and cli.tpo_persona = '01')
			 where inv.empresa = pEmpresa  
        and inv.fecha_alta = vfecha_ant
			   and inv.status_cta = '1'
           
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
			COMMIT WORK;
            LET vEnTransacc = 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
        SELECT TRIM(NVL(cte.nombre1,'')), TRIM(NVL(cte.nombre2,'')), TRIM(NVL(cte.apell_paterno,'')), TRIM(NVL(cte.apell_materno,'')), cte.fecha_insert, cte.sucursal,
               cpf.fecha_nac, cpf.sexo, cpf.estado_civil, tip.es_fisica, TRIM(NVL(mail.correo_elec,'')), TRIM(NVL(tel1.telefono,'')), TRIM(NVL(tel2.telefono,''))
          INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vfecha_insert, vsucursal_cte, vfecha_nac, vsexo, vedo_civil, ves_fisica, vcorreo, vtel_casa, vtel_movil
          FROM bdinteg:si_cliente cte
         INNER JOIN bdinteg:si_ctepf cpf ON ( cpf.numcte = cte.numcte )
         INNER JOIN bdinteg:si_tipper tip ON ( tip.tpo_persona = cte.tpo_persona )
          LEFT OUTER JOIN bdinteg:si_correos mail ON ( mail.numcte = cte.numcte AND mail.tipo_correo = 1 AND mail.status_correo = 'A' AND mail.secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cte.numcte AND tipo_correo = 1 AND status_correo = 'A') )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = cte.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = 'A' AND tel1.cofetel = 'V' )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = cte.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = 'A' AND tel2.cofetel = 'V' )
         WHERE cte.numcte = vNumCliente;
         
        IF ( vtel_movil is null OR vtel_movil = '' ) THEN
            CONTINUE FOREACH;
        END IF;
        
        SELECT calle.nombrecalle, dir.numeroextcalle, dir.numerointcalle, dir.departamento, zona.nombrezona, zona.municipiozona, ciu.nombreciudad, dir.cod_postal, edo.nombre    
          INTO cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cCodPos, cEstado
          FROM bdinteg:si_direcciones_actual dir
          LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
          LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
          LEFT OUTER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado )
         WHERE dir.numcte = vNumCliente
           AND dir.tipo_dir = '1';

		LET vDireccion = TRIM(NVL(cCalle,''))||' '||TRIM(NVL(cNumExt,''))||' '||TRIM(NVL(cNumInt,''))||' '||TRIM(NVL(cDepart,''))||' '||TRIM(NVL(cColonia,''))||' '||TRIM(NVL(cMunicipio,''))||' '||TRIM(NVL(cCiudad,''))||' '||TRIM(NVL(cCodPos,''))||' '||TRIM(NVL(cEstado,''));
        LET vDireccion = TRIM(vDireccion);
        
        IF ves_fisica = 'S' THEN
            LET vtpo_persona = 'PF';
        ELSE
            LET vtpo_persona = 'PM';
        END IF;
        
        IF vsexo = 'F' THEN
           LET vgenero = 'FEMENINO';
        ELSE
           LET vgenero = 'MASCULINO';
        END IF;
        
        IF vedo_civil = 'D' THEN
            LET vestado_civil = 'DIVORCIADO';
        ELIF vedo_civil = 'S' THEN
            LET vestado_civil = 'SOLTERO';
        ELIF vedo_civil = 'U' THEN
            LET vestado_civil = 'UNION LIBRE';
        ELIF vedo_civil = 'C' THEN
            LET vestado_civil = 'CASADO';
        ELIF vedo_civil = 'V' THEN
            LET vestado_civil = 'VIUDO';
        ELSE
            LET vestado_civil = 'SIN DESCRIPCION';
        END IF;
        
        LET vNombreCliente = TRIM(vnombre1)||' '||TRIM(vnombre2);
        LET vNombreCliente = TRIM(vNombreCliente);
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','A'),'Ã¡','a');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','E'),'Ã©','e');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','I'),'Ã­','i');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','O'),'Ã³','o');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','U'),'Ãº','u');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','N'),'Ã±','n');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','A'),'Ã¡','a');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','E'),'Ã©','e');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','I'),'Ã­','i');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','O'),'Ã³','o');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','U'),'Ãº','u');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','N'),'Ã±','n');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','A'),'Ã¡','a');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','E'),'Ã©','e');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','I'),'Ã­','i');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','O'),'Ã³','o');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','U'),'Ãº','u');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','N'),'Ã±','n');
        LET vfecha_nac_cte = TO_CHAR(vfecha_nac, '%d/%m/%Y');
        LET vedad = ROUND(((vfecha_ant - vfecha_nac) / 365), 0);
        LET vantiguedad = ROUND(((vfecha_ant - vfecha_insert) / 365), 0);
        
		--select unique club.numcte,club.monto_mes,club.num_cta,mov.transacc
		select first 1 club.numcte,club.monto_mes,club.num_cta,mov.transacc
		INTO vNoCteClub, vMontoClub,vNumcta,vTransaccmov
		from bdinteg:si_club_proteccion club,
			 bdisac:sac_movimientoshistorial sac, 
			 bdicheq:sc_movdia_concil mov
		where club.aceptada='1'
		and club.numcte= vNumCliente
		and trim(club.numcte_coppel) = trim(sac.referencia1)
		and sac.fecha_pago = mov.fech_alt 
		and sac.folio_suc = mov.folio_suc 
		and mov.fech_alt = vfecha_ant
		and mov.transacc in ('1303','1363')
		--and (mov.transacc = '1303' or mov.transacc ='1363')
		and mov.cancelad <> 'S';
       

		/*--query original
        select unique club.numcte, club.monto_mes
		INTO vNoCteClub, vMontoClub,vTransaccmov
		from bdinteg:si_club_proteccion club,
			 bdisac:sac_movimientoshistorial sac, 
			 bdicheq:sc_movdia_concil mov
		where club.aceptada='1'
		and club.numcte= vNumCliente
		and trim(club.numcte_coppel) = trim(sac.referencia1)
		and sac.fecha_pago = mov.fech_alt 
		and sac.folio_suc = mov.folio_suc 
		and mov.fech_alt = vfecha_ant
		and mov.transacc in ('1303','1363')
		and mov.cancelad <> 'S';
        UNION ALL
		Select '' cte, monto_tot from bdicheq:sc_movdia_concil mov
		where fech_alt = '20230525'
		and mov.cancelad <> 'S'
		and mov.transacc ='0283';*/
		
		 --query de bÃºsqueda
		 /*select unique club.numcte, club.monto_mes,club.num_cta,mov.transacc 
			--INTO vNoCteClub, vMontoClub,vTransaccmov
			from bdinteg:si_club_proteccion club,
			bdisac:sac_movimientoshistorial sac, 
			bdicheq:sc_movdia_concil mov
			where club.aceptada='1'
			--and club.numcte= vNumCliente
			and trim(club.numcte_coppel) = trim(sac.referencia1)
			and sac.fecha_pago = mov.fech_alt 
			and sac.folio_suc = mov.folio_suc 
			and mov.fech_alt = '05042023'
			and mov.transacc in ('1303','1363')
			and mov.cancelad <> 'S'
			UNION ALL
			Select '' cte, mov.monto_tot,mov.cuenta,mov.transacc  from bdicheq:sc_movdia_concil mov
			where fech_alt ='05042023'
			and mov.cancelad <> 'S'
			and mov.transacc ='0283'
		 */
		 
		 
        IF vNoCteClub is not null AND vNoCteClub <> '' THEN
            --LET vclub_protec = 'SI';
            LET vpago_club = vMontoClub;
        ELSE
            LET vclub_protec = 'NO';
            LET vpago_club = 0;
        END IF;
        
		
		
		FOREACH cursor_cliente_1_1 WITH HOLD FOR
            SELECT mae.cuenta, mae.sucursal, noc.fecha_alta, noc.ejecutivo, TRIM(suc.nombre), TRIM(pro.nombre)
              INTO vCuenta, vSucursal, vfecha_alta, vpromotor, vnombre_suc, vproducto
              FROM sc_maechq mae,
                   sc_maenoc noc,
                   sc_producto pro,
                   bdinteg:si_sucursales suc
             WHERE mae.cuenta = noc.cuenta
               AND noc.fecha_alta = vfecha_ant
               AND pro.producto = mae.producto
               AND suc.sucursal = mae.sucursal
			   and suc.tpo_sucursal = 'S'
               AND mae.num_cte = vNumCliente
			union all
			select inv.cuenta,inv.sucursal,inv.fecha_alta,inv.promotor,TRIM(suc.nombre),inv.cod_instrum
			  from bdinvers:sv_maeinv inv
              INNER JOIN bdinteg:si_sucursales suc ON (suc.sucursal = inv.sucursal and suc.tpo_sucursal = 'S')
			 where inv.empresa = pEmpresa 
                and inv.fecha_alta = vfecha_ant
                and inv.num_cte = vNumCliente
			   and inv.status_cta = '1'
               
            LET vtpo_transacc = 'APERTURA DE '||TRIM(vproducto);
			
			IF vpromotor = 'informix' THEN
				CONTINUE FOREACH;
			END IF;
			
			IF vproducto = '3000' THEN
				LET vtpo_transacc = 'Apertura de Pagares';
			end if;
			
            LET vfecha_mov = TO_CHAR(vfecha_alta, '%d/%m/%Y');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','A'),'Ã¡','a');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','E'),'Ã©','e');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','I'),'Ã­','i');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','O'),'Ã³','o');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','U'),'Ãº','u');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','N'),'Ã±','n');
			/*--Obtener nombre del promotor
			select nombre 
				into vnombre_promotor
			  from bdinteg:si_ejecut
			 where empresa = '001'
			   and ejecutivo = vpromotor;
			   
			LET vnombre_promotor = TRIM(vnombre_promotor);*/
			
			
			--Validamos si adquiriÃ³ el club de proteccion en el mismo dÃ­a del proceso de este archivo csv
			SELECT MAX(fecha_alta),motivo_rechazo
			INTO vfecha_alta_club_prote,vmotivo_rechazo
			FROM bdinteg:si_club_proteccion
			where numcte = vNumCliente
			and aceptada = '1'
			AND motivo_rechazo =''
			GROUP BY 2;
			
			IF vfecha_alta_club_prote = vfecha_ant AND vmotivo_rechazo ='' THEN
				 LET vclub_protec = 'SI';
			ELSE 
				 LET vclub_protec = 'NO';
			END IF;
			
			IF vclub_protec = '0' OR vclub_protec ='' THEN
				LET vclub_protec ='NO';
			END IF;

            
            IF ( ( vSucursal is not null AND vSucursal <> '' AND LENGTH(vSucursal) = 4 ) AND ( vnombre_suc is not null AND vnombre_suc <> '' AND vnombre_suc <> ' ' ) ) THEN
                INSERT INTO sc_medalia_ctes_prom
                ( fecha_insert, sucursal, nombre_suc, numcte, nombre_cte, digito_verif, apell_paterno, apell_materno, correo, tel_movil, tel_casa,
                  edad, antiguedad, mora, escolaridad, ingresos, edo_civil, genero, sucursal_cte, linea_credito, dependientes, cod_postal, colonia, domicilio,
                  generacion, fecha_mov, promotor, tipo_pago, num_micro, pago_club, club_protec, no_productos, sit_especial, pta_act_autor, poliza_cp, fecha_nac,
                  centro, tpo_canal, tpo_sistema, tpo_producto, tpo_transacc, segmento, tpo_persona,
                  producto1, producto2, producto3, producto4, producto5, producto6, producto7, producto8, producto9, 
                  producto10, producto11, producto12, producto13, producto14, producto15, producto16, producto17, producto18, 
                  producto19, producto20, producto21, producto22, producto23, producto24, producto25, producto26, tpo_autoriza )
                VALUES
                ( vFechaHoy, vSucursal, vnombre_suc, vNumCliente, vNombreCliente, vdigito_verif, vapell_paterno, vapell_materno, vcorreo, vtel_movil, vtel_casa, 
                  vedad, vantiguedad, vmora, vescolaridad, vingresos, vestado_civil, vgenero, vsucursal_cte, vlinea_credito, vdependientes, cCodPos, cColonia, vDireccion,
                  vgeneracion, vfecha_mov, vpromotor, vtipo_pago, vnum_micro, vpago_club, vclub_protec, vno_productos, vsit_especial, vpta_act_autor, vpoliza_cp, vfecha_nac_cte,
                  vcentro, vtpo_canal, vtpo_sistema, vtpo_producto, vtpo_transacc, vsegmento, vtpo_persona,
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null',
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', vtpo_autoriza );
            END IF;
            
            LET vContador2 = vContador2 + 1;
            
            IF vContador2 >= 500 THEN
                LET vContador2 = 0;
                BEGIN WORK;
				COMMIT WORK;
                
            END IF;
        END FOREACH;
    END FOREACH;
  
	LET vComienza = -1;
	LET vEnTransacc = 0;
    LET vContador1 = 0;
    LET vContador2 = 0;
	--transaccion 0283
	FOREACH cursor_cliente_2 WITH HOLD FOR
        Select unique mae.num_cte,mov.monto_tot,mov.cuenta,mov.transacc
		INTO vNumCliente,vMonto_clie, vNumcta,vTransaccmov
		from bdicheq:sc_movdia_concil mov, bdicheq:sc_maechq mae
		where mov.empresa='001'
		and mov.cuenta=mae.cuenta
		and mov.fech_alt = vfecha_ant
		and mov.cancelad <> 'S'
		and mov.transacc ='0283'
           
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
			COMMIT WORK;
            LET vEnTransacc = 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
        SELECT TRIM(NVL(cte.nombre1,'')), TRIM(NVL(cte.nombre2,'')), TRIM(NVL(cte.apell_paterno,'')), TRIM(NVL(cte.apell_materno,'')), cte.fecha_insert, cte.sucursal,
               cpf.fecha_nac, cpf.sexo, cpf.estado_civil, tip.es_fisica, TRIM(NVL(mail.correo_elec,'')), TRIM(NVL(tel1.telefono,'')), TRIM(NVL(tel2.telefono,''))
          INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vfecha_insert, vsucursal_cte, vfecha_nac, vsexo, vedo_civil, ves_fisica, vcorreo, vtel_casa, vtel_movil
          FROM bdinteg:si_cliente cte
         INNER JOIN bdinteg:si_ctepf cpf ON ( cpf.numcte = cte.numcte )
         INNER JOIN bdinteg:si_tipper tip ON ( tip.tpo_persona = cte.tpo_persona )
          LEFT OUTER JOIN bdinteg:si_correos mail ON ( mail.numcte = cte.numcte AND mail.tipo_correo = 1 AND mail.status_correo = 'A' AND mail.secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cte.numcte AND tipo_correo = 1 AND status_correo = 'A') )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = cte.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = 'A' AND tel1.cofetel = 'V' )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = cte.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = 'A' AND tel2.cofetel = 'V' )
         WHERE cte.numcte = vNumCliente;
         
        IF ( vtel_movil is null OR vtel_movil = '' ) THEN
            CONTINUE FOREACH;
        END IF;
        
        SELECT calle.nombrecalle, dir.numeroextcalle, dir.numerointcalle, dir.departamento, zona.nombrezona, zona.municipiozona, ciu.nombreciudad, dir.cod_postal, edo.nombre    
          INTO cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cCodPos, cEstado
          FROM bdinteg:si_direcciones_actual dir
          LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
          LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
          LEFT OUTER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado )
         WHERE dir.numcte = vNumCliente
           AND dir.tipo_dir = '1';

		LET vDireccion = TRIM(NVL(cCalle,''))||' '||TRIM(NVL(cNumExt,''))||' '||TRIM(NVL(cNumInt,''))||' '||TRIM(NVL(cDepart,''))||' '||TRIM(NVL(cColonia,''))||' '||TRIM(NVL(cMunicipio,''))||' '||TRIM(NVL(cCiudad,''))||' '||TRIM(NVL(cCodPos,''))||' '||TRIM(NVL(cEstado,''));
        LET vDireccion = TRIM(vDireccion);
        
        IF ves_fisica = 'S' THEN
            LET vtpo_persona = 'PF';
        ELSE
            LET vtpo_persona = 'PM';
        END IF;
        
        IF vsexo = 'F' THEN
           LET vgenero = 'FEMENINO';
        ELSE
           LET vgenero = 'MASCULINO';
        END IF;
        
        IF vedo_civil = 'D' THEN
            LET vestado_civil = 'DIVORCIADO';
        ELIF vedo_civil = 'S' THEN
            LET vestado_civil = 'SOLTERO';
        ELIF vedo_civil = 'U' THEN
            LET vestado_civil = 'UNION LIBRE';
        ELIF vedo_civil = 'C' THEN
            LET vestado_civil = 'CASADO';
        ELIF vedo_civil = 'V' THEN
            LET vestado_civil = 'VIUDO';
        ELSE
            LET vestado_civil = 'SIN DESCRIPCION';
        END IF;
        
        LET vNombreCliente = TRIM(vnombre1)||' '||TRIM(vnombre2);
        LET vNombreCliente = TRIM(vNombreCliente);
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','A'),'Ã¡','a');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','E'),'Ã©','e');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','I'),'Ã­','i');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','O'),'Ã³','o');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','U'),'Ãº','u');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','N'),'Ã±','n');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','A'),'Ã¡','a');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','E'),'Ã©','e');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','I'),'Ã­','i');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','O'),'Ã³','o');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','U'),'Ãº','u');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','N'),'Ã±','n');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','A'),'Ã¡','a');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','E'),'Ã©','e');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','I'),'Ã­','i');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','O'),'Ã³','o');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','U'),'Ãº','u');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','N'),'Ã±','n');
        LET vfecha_nac_cte = TO_CHAR(vfecha_nac, '%d/%m/%Y');
        LET vedad = ROUND(((vfecha_ant - vfecha_nac) / 365), 0);
        LET vantiguedad = ROUND(((vfecha_ant - vfecha_insert) / 365), 0);
        
		
		--select unique club.numcte,club.monto_mes
		select FIRST 1 club.numcte,club.monto_mes
		INTO vNoCteClub, vMontoClub
		from bdinteg:si_club_proteccion club
		where club.empresa='001'
		and club.numcte = vNumCliente
		and club.aceptada='1';
		/*select unique club.numcte,club.monto_mes,club.num_cta,mov.transacc
		INTO vNoCteClub, vMontoClub,vNumcta,vTransaccmov
		from bdinteg:si_club_proteccion club,
			 bdisac:sac_movimientoshistorial sac, 
			 bdicheq:sc_movdia_concil mov
		where club.aceptada='1'
		and club.numcte= vNumCliente
		and trim(club.numcte_coppel) = trim(sac.referencia1)
		and sac.fecha_pago = mov.fech_alt 
		and sac.folio_suc = mov.folio_suc 
		and mov.fech_alt = vfecha_ant
		and mov.transacc in ('1303','1363')
		and mov.cancelad <> 'S'*/
        --UNION 
		--Select '', mov.monto_tot,mov.cuenta,mov.transacc from bdicheq:sc_movdia_concil mov
		--where mov.fech_alt = vfecha_ant
		--and mov.cancelad <> 'S'
		--and mov.producto <> ''
		--and mov.transacc ='0283';
	 
        IF vNoCteClub is not null AND vNoCteClub <> '' THEN
            --LET vclub_protec = 'SI';
            LET vpago_club = vMontoClub;
        ELSE
            LET vclub_protec = 'NO';
            LET vpago_club = 0;
        END IF;
        
		
        FOREACH cursor_cliente_2_1 WITH HOLD FOR
            SELECT mae.cuenta, mae.sucursal, noc.fecha_alta, noc.ejecutivo, TRIM(suc.nombre), TRIM(pro.nombre)
              INTO vCuenta, vSucursal, vfecha_alta, vpromotor, vnombre_suc, vproducto
              FROM sc_maechq mae,
                   sc_maenoc noc,
                   sc_producto pro,
                   bdinteg:si_sucursales suc
             WHERE mae.cuenta = noc.cuenta
               AND noc.fecha_alta = vfecha_ant
               AND pro.producto = mae.producto
               AND suc.sucursal = mae.sucursal
			   and suc.tpo_sucursal = 'S'
               AND mae.num_cte = vNumCliente
			union all
			select inv.cuenta,inv.sucursal,inv.fecha_alta,inv.promotor,TRIM(suc.nombre),inv.cod_instrum
			  from bdinvers:sv_maeinv inv
              INNER JOIN bdinteg:si_sucursales suc ON (suc.sucursal = inv.sucursal and suc.tpo_sucursal = 'S')
			 where inv.empresa = pEmpresa 
                and inv.fecha_alta = vfecha_ant
                and inv.num_cte = vNumCliente
			   and inv.status_cta = '1'

			
			IF vTransaccmov = '0283' THEN
				LET vtpo_transacc = 'TRANSFERENCIA PRESTAMOS COPPEL';
			end if;
			
			
            LET vfecha_mov = TO_CHAR(vfecha_alta, '%d/%m/%Y');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','A'),'Ã¡','a');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','E'),'Ã©','e');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','I'),'Ã­','i');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','O'),'Ã³','o');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','U'),'Ãº','u');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','N'),'Ã±','n');
			/*--Obtener nombre del promotor
			select nombre 
				into vnombre_promotor
			  from bdinteg:si_ejecut
			 where empresa = '001'
			   and ejecutivo = vpromotor;
			   
			LET vnombre_promotor = TRIM(vnombre_promotor);*/
			
			--Validamos si adquiriÃ³ el club de proteccion en el mismo dÃ­a del proceso de este archivo csv
			SELECT MAX(fecha_alta),motivo_rechazo
			INTO vfecha_alta_club_prote,vmotivo_rechazo
			FROM bdinteg:si_club_proteccion
			where numcte = vNumCliente
			and aceptada = '1'
			AND motivo_rechazo =''
			GROUP BY 2;
			
			IF vfecha_alta_club_prote = vfecha_ant AND vmotivo_rechazo ='' THEN
				 LET vclub_protec = 'SI';
			ELSE 
				 LET vclub_protec = 'NO';
			END IF;
			
			IF vclub_protec = '0' OR vclub_protec ='' THEN
				LET vclub_protec ='NO';
			END IF;
			
			
            
            IF ( ( vSucursal is not null AND vSucursal <> '' AND LENGTH(vSucursal) = 4 ) AND ( vnombre_suc is not null AND vnombre_suc <> '' AND vnombre_suc <> ' ' ) ) THEN
                INSERT INTO sc_medalia_ctes_prom
                ( fecha_insert, sucursal, nombre_suc, numcte, nombre_cte, digito_verif, apell_paterno, apell_materno, correo, tel_movil, tel_casa,
                  edad, antiguedad, mora, escolaridad, ingresos, edo_civil, genero, sucursal_cte, linea_credito, dependientes, cod_postal, colonia, domicilio,
                  generacion, fecha_mov, promotor, tipo_pago, num_micro, pago_club, club_protec, no_productos, sit_especial, pta_act_autor, poliza_cp, fecha_nac,
                  centro, tpo_canal, tpo_sistema, tpo_producto, tpo_transacc, segmento, tpo_persona,
                  producto1, producto2, producto3, producto4, producto5, producto6, producto7, producto8, producto9, 
                  producto10, producto11, producto12, producto13, producto14, producto15, producto16, producto17, producto18, 
                  producto19, producto20, producto21, producto22, producto23, producto24, producto25, producto26, tpo_autoriza )
                VALUES
                ( vFechaHoy, vSucursal, vnombre_suc, vNumCliente, vNombreCliente, vdigito_verif, vapell_paterno, vapell_materno, vcorreo, vtel_movil, vtel_casa, 
                  vedad, vantiguedad, vmora, vescolaridad, vingresos, vestado_civil, vgenero, vsucursal_cte, vlinea_credito, vdependientes, cCodPos, cColonia, vDireccion,
                  vgeneracion, vfecha_mov, vpromotor, vtipo_pago, vnum_micro, vpago_club, vclub_protec, vno_productos, vsit_especial, vpta_act_autor, vpoliza_cp, vfecha_nac_cte,
                  vcentro, vtpo_canal, vtpo_sistema, vtpo_producto, vtpo_transacc, vsegmento, vtpo_persona,
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null',
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', vtpo_autoriza );
            END IF;
            
            LET vContador2 = vContador2 + 1;
            
            IF vContador2 >= 500 THEN
                LET vContador2 = 0;
                BEGIN WORK;
				COMMIT WORK;
                
            END IF;
        END FOREACH;
    END FOREACH;
 
	LET vComienza= -1;
	LET vEnTransacc = 0;
    LET vContador1 = 0;
    LET vContador2 = 0;
    --Aperturas colocacion revolvente y no revolvente
	FOREACH cursor_cliente_3 WITH HOLD FOR
        /*SELECT UNIQUE mae.numcte
          INTO vNumCliente
          FROM bdicred:sd_maecred mae
          inner join bdinteg:si_cliente cte on (mae.empresa = cte.empresa and mae.numcte = cte.numcte and cte.tpo_persona='01')
         WHERE mae.empresa = '001'
           AND mae.fecha_apertura = vfecha_ant
		union all
		SELECT UNIQUE mae.numcte
          FROM bdicred:sd_maecredcrd mae
          inner join bdinteg:si_cliente cte on (mae.empresa = cte.empresa and mae.numcte = cte.numcte and cte.tpo_persona='01')
         WHERE mae.empresa = pEmpresa
           AND mae.fecha_apertura = vfecha_ant
		union all
		select UNIQUE mae.numcte 
		from bdicred:bitacora_activacion act
        inner join bdicred:sd_tarjeta tar on (act.numtarjeta = tar.num_tarjeta and tar.status_tar = 'A')
        inner join bdicred:sd_maecred mae on (mae.empresa = '001' and tar.num_credito = mae.num_credito)
		where date(act.fecha_asigna) = vfecha_ant
		union all
        select UNIQUE mae.num_cte
        from intercard:tarjeta tar
        inner join bdicheq:sc_tarjeta a on (a.num_tarjeta = tar.numtarjeta and a.status_tar = 'A')
        inner join sc_maechq mae on (a.cuenta = mae.cuenta)
        inner join sc_maenoc noc on (mae.cuenta = noc.cuenta) 
        where date(tar.fechaasignacion) = vfecha_ant*/
		
		-------------------------
		SELECT UNIQUE mae.numcte
          INTO vNumCliente
          FROM bdicred:sd_maecred mae
          inner join bdinteg:si_cliente cte on (mae.empresa = cte.empresa and mae.numcte = cte.numcte and cte.tpo_persona='01')
         WHERE mae.empresa = '001'
           AND mae.fecha_apertura = vfecha_ant
		union all
		SELECT UNIQUE mae.numcte
          FROM bdicred:sd_maecredcrd mae
          inner join bdinteg:si_cliente cte on (mae.empresa = cte.empresa and mae.numcte = cte.numcte and cte.tpo_persona='01')
         WHERE mae.empresa = pEmpresa
           AND mae.fecha_apertura = vfecha_ant
		/*union all
		select UNIQUE mae.numcte 
		from bdicred:bitacora_activacion act
        inner join bdicred:sd_tarjeta tar on (act.numtarjeta = tar.num_tarjeta and tar.status_tar = 'A')
        inner join bdicred:sd_maecred mae on (mae.empresa = '001' and tar.num_credito = mae.num_credito)
		where date(act.fecha_asigna) = vfecha_ant*/
		union all
        select UNIQUE mae.num_cte
        from intercard:tarjeta tar
        inner join bdicheq:sc_tarjeta a on (a.num_tarjeta = tar.numtarjeta) --and a.status_tar = 'A')
        inner join sc_maechq mae on (a.cuenta = mae.cuenta)
        --inner join sc_maenoc noc on (mae.cuenta = noc.cuenta) 
        where date(tar.fechaasignacion) = vfecha_ant
		AND tar.codstatustarjeta = 'ACT'
		AND tar.codstatusasignada = 'SIA'
		AND tar.titular = ''
		--------------------------
		
           
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
			COMMIT WORK;
            LET vEnTransacc = 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
        SELECT TRIM(NVL(cte.nombre1,'')), TRIM(NVL(cte.nombre2,'')), TRIM(NVL(cte.apell_paterno,'')), TRIM(NVL(cte.apell_materno,'')), cte.fecha_insert, cte.sucursal,
               cpf.fecha_nac, cpf.sexo, cpf.estado_civil, tip.es_fisica, TRIM(NVL(mail.correo_elec,'')), TRIM(NVL(tel1.telefono,'')), TRIM(NVL(tel2.telefono,''))
          INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vfecha_insert, vsucursal_cte, vfecha_nac, vsexo, vedo_civil, ves_fisica, vcorreo, vtel_casa, vtel_movil
          FROM bdinteg:si_cliente cte
         INNER JOIN bdinteg:si_ctepf cpf ON ( cpf.numcte = cte.numcte )
         INNER JOIN bdinteg:si_tipper tip ON ( tip.tpo_persona = cte.tpo_persona )
          LEFT OUTER JOIN bdinteg:si_correos mail ON ( mail.numcte = cte.numcte AND mail.tipo_correo = 1 AND mail.status_correo = 'A' AND mail.secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cte.numcte AND tipo_correo = 1 AND status_correo = 'A' ) )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = cte.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = 'A' AND tel1.cofetel = 'V' )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = cte.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = 'A' AND tel2.cofetel = 'V' )
         WHERE cte.numcte = vNumCliente;
         
        IF ( vtel_movil is null OR vtel_movil = '' ) THEN
            CONTINUE FOREACH;
        END IF;
        
        SELECT calle.nombrecalle, dir.numeroextcalle, dir.numerointcalle, dir.departamento, zona.nombrezona, zona.municipiozona, ciu.nombreciudad, dir.cod_postal, edo.nombre    
          INTO cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cCodPos, cEstado
          FROM bdinteg:si_direcciones_actual dir
          LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
          LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
          LEFT OUTER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado )
         WHERE dir.numcte = vNumCliente
           AND dir.tipo_dir = '1';

		LET vDireccion = TRIM(NVL(cCalle,''))||' '||TRIM(NVL(cNumExt,''))||' '||TRIM(NVL(cNumInt,''))||' '||TRIM(NVL(cDepart,''))||' '||TRIM(NVL(cColonia,''))||' '||TRIM(NVL(cMunicipio,''))||' '||TRIM(NVL(cCiudad,''))||' '||TRIM(NVL(cCodPos,''))||' '||TRIM(NVL(cEstado,''));
        LET vDireccion = TRIM(vDireccion);
        
        IF ves_fisica = 'S' THEN
            LET vtpo_persona = 'PF';
        ELSE
            LET vtpo_persona = 'PM';
        END IF;
        
        IF vsexo = 'F' THEN
           LET vgenero = 'FEMENINO';
        ELSE
           LET vgenero = 'MASCULINO';
        END IF;
        
        IF vedo_civil = 'D' THEN
            LET vestado_civil = 'DIVORCIADO';
        ELIF vedo_civil = 'S' THEN
            LET vestado_civil = 'SOLTERO';
        ELIF vedo_civil = 'U' THEN
            LET vestado_civil = 'UNION LIBRE';
        ELIF vedo_civil = 'C' THEN
            LET vestado_civil = 'CASADO';
        ELIF vedo_civil = 'V' THEN
            LET vestado_civil = 'VIUDO';
        ELSE
            LET vestado_civil = 'SIN DESCRIPCION';
        END IF;
        
        LET vNombreCliente = TRIM(vnombre1)||' '||TRIM(vnombre2);
        LET vNombreCliente = TRIM(vNombreCliente);
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','A'),'Ã¡','a');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','E'),'Ã©','e');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','I'),'Ã­','i');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','O'),'Ã³','o');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','U'),'Ãº','u');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','N'),'Ã±','n');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','A'),'Ã¡','a');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','E'),'Ã©','e');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','I'),'Ã­','i');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','O'),'Ã³','o');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','U'),'Ãº','u');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','N'),'Ã±','n');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','A'),'Ã¡','a');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','E'),'Ã©','e');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','I'),'Ã­','i');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','O'),'Ã³','o');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','U'),'Ãº','u');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','N'),'Ã±','n');
        LET vfecha_nac_cte = TO_CHAR(vfecha_nac, '%d/%m/%Y');
        LET vedad = ROUND(((vfecha_ant - vfecha_nac) / 365), 0);
        LET vantiguedad = ROUND(((vfecha_ant - vfecha_insert) / 365), 0);
        
		
		--select unique club.numcte, club.monto_mes,club.num_cta,mov.transacc 
		select first 1 club.numcte, club.monto_mes,club.num_cta,mov.transacc 
		INTO vNoCteClub, vMontoClub,vNumcta,vTransaccmov
		from bdinteg:si_club_proteccion club,
			 bdisac:sac_movimientoshistorial sac, 
			 bdicheq:sc_movdia_concil mov
		where club.aceptada='1'
		and club.numcte= vNumCliente
		and trim(club.numcte_coppel) = trim(sac.referencia1)
		and sac.fecha_pago = mov.fech_alt 
		and sac.folio_suc = mov.folio_suc 
		and mov.fech_alt = vfecha_ant
		and mov.transacc in ('1303','1363')
		and mov.cancelad <> 'S';

			
        /*select unique club.numcte, club.monto_mes
		INTO vNoCteClub, vMontoClub,vTransaccmov
		from bdinteg:si_club_proteccion club,
			 bdisac:sac_movimientoshistorial sac, 
			 bdicheq:sc_movdia_concil mov
		where club.aceptada='1'
		and club.numcte= vNumCliente
		and trim(club.numcte_coppel) = trim(sac.referencia1)
		and sac.fecha_pago = mov.fech_alt 
		and sac.folio_suc = mov.folio_suc 
		and mov.fech_alt = vfecha_ant
		and mov.transacc in ('1303','1363','0283')
		and mov.cancelad <> 'S';*/
		
		  
        IF vNoCteClub is not null AND vNoCteClub <> '' THEN
            --LET vclub_protec = 'SI';
            LET vpago_club = vMontoClub;
        ELSE
            LET vclub_protec = 'NO';
            LET vpago_club = 0;
        END IF;
        

		
        FOREACH cursor_cliente_3_1 WITH HOLD FOR
            SELECT mae.num_credito, mae.sucursal, mae.fecha_apertura, mae.ejecutivo, TRIM(suc.nombre), TRIM(mae.num_producto)
              INTO vCuenta, vSucursal, vfecha_alta, vpromotor, vnombre_suc, vproductoc
              FROM bdicred:sd_maecred mae
              INNER JOIN bdinteg:si_sucursales suc ON (suc.sucursal = mae.sucursal and suc.tpo_sucursal = 'S')
             WHERE mae.empresa = pEmpresa
               AND mae.fecha_apertura = vfecha_ant
               AND mae.numcte = vNumCliente
			union all
			SELECT mae.num_credito, mae.sucursal, mae.fecha_apertura, mae.ejecutivo, TRIM(suc.nombre), TRIM(mae.num_producto)
              FROM bdicred:sd_maecredcrd mae
              INNER JOIN bdinteg:si_sucursales suc ON (suc.sucursal = mae.sucursal and suc.tpo_sucursal = 'S')
             WHERE mae.empresa = pEmpresa
               AND mae.fecha_apertura = vfecha_ant
               AND mae.numcte = vNumCliente
			union all
			select mae.num_credito,act.suc_activa,date(act.fecha_asigna),act.no_empleado_asigna,TRIM(suc.nombre), 'actc'
			from bdicred:bitacora_activacion act
			inner join bdicred:sd_tarjeta tar on (act.numtarjeta = tar.num_tarjeta and tar.status_tar = 'A')
			inner join bdicred:sd_maecred mae on (mae.empresa = pEmpresa and tar.num_credito = mae.num_credito)
			inner join bdinteg:si_sucursales suc on (act.suc_activa = suc.sucursal and suc.tpo_sucursal = 'S')
			where date(act.fecha_asigna) = vfecha_ant
			and mae.numcte = vNumCliente
			union all
			select mae.cuenta,mae.sucursal,date(tar.fechaasignacion),tar.usuarioultmodif,TRIM(suc.nombre), 'actc' 
			from intercard:tarjeta tar
			inner join bdicheq:sc_tarjeta a on (a.num_tarjeta = tar.numtarjeta and a.status_tar = 'A')
			inner join sc_maechq mae on (a.cuenta = mae.cuenta)
			inner join sc_maenoc noc on (mae.cuenta = noc.cuenta) 
			inner join bdinteg:si_sucursales suc on (mae.sucursal = suc.sucursal and suc.tpo_sucursal = 'S')
			where date(tar.fechaasignacion) = vfecha_ant
			and mae.num_cte = vNumCliente
			  
			IF vpromotor = 'informix' THEN
				CONTINUE FOREACH;
			END IF;
            
			IF vproductoc = '6011' THEN
				LET vtpo_transacc = 'Reestructura TDC Visa';
			end if;
			IF vproductoc in ('6300','7600','7700','6800') THEN
				LET vtpo_transacc = 'Asignacion de prestamos, personal y digital';
			end if;
			IF vproductoc in ('6001','7000','8100') THEN
				LET vtpo_transacc = 'Asignacion de creditos, TDCV y TDCC';
			end if;
			IF vproductoc = '7800' THEN
				LET vtpo_transacc = 'Anticipo de Nomina';
			end if;
			IF vproductoc = 'actc' THEN
				LET vtpo_transacc = 'Asignacion de plasticos, debito y credito';
			end if;

            LET vfecha_mov = TO_CHAR(vfecha_alta, '%d/%m/%Y');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','A'),'Ã¡','a');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','E'),'Ã©','e');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','I'),'Ã­','i');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','O'),'Ã³','o');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','U'),'Ãº','u');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','N'),'Ã±','n');
			/*--Obtener nombre del promotor
			select nombre 
				into vnombre_promotor
			  from bdinteg:si_ejecut
			 where empresa = '001'
			   and ejecutivo = vpromotor;
			   
			LET vnombre_promotor = TRIM(vnombre_promotor);*/
			
			--Validamos si adquiriÃ³ el club de proteccion en el mismo dÃ­a del proceso de este archivo csv
			SELECT MAX(fecha_alta),motivo_rechazo
			INTO vfecha_alta_club_prote,vmotivo_rechazo
			FROM bdinteg:si_club_proteccion
			where numcte = vNumCliente
			and aceptada = '1'
			AND motivo_rechazo =''
			GROUP BY 2;
			
			IF vfecha_alta_club_prote = vfecha_ant AND vmotivo_rechazo ='' THEN
				 LET vclub_protec = 'SI';
			ELSE 
				 LET vclub_protec = 'NO';
			END IF;
			
			IF vclub_protec = '0' OR vclub_protec ='' THEN
				LET vclub_protec ='NO';
			END IF;
			
            
            IF ( ( vSucursal is not null AND vSucursal <> '' AND LENGTH(vSucursal) = 4 ) AND ( vnombre_suc is not null AND vnombre_suc <> '' AND vnombre_suc <> ' ' ) ) THEN
                INSERT INTO sc_medalia_ctes_prom
                ( fecha_insert, sucursal, nombre_suc, numcte, nombre_cte, digito_verif, apell_paterno, apell_materno, correo, tel_movil, tel_casa,
                  edad, antiguedad, mora, escolaridad, ingresos, edo_civil, genero, sucursal_cte, linea_credito, dependientes, cod_postal, colonia, domicilio,
                  generacion, fecha_mov, promotor, tipo_pago, num_micro, pago_club, club_protec, no_productos, sit_especial, pta_act_autor, poliza_cp, fecha_nac,
                  centro, tpo_canal, tpo_sistema, tpo_producto, tpo_transacc, segmento, tpo_persona,
                  producto1, producto2, producto3, producto4, producto5, producto6, producto7, producto8, producto9, 
                  producto10, producto11, producto12, producto13, producto14, producto15, producto16, producto17, producto18, 
                  producto19, producto20, producto21, producto22, producto23, producto24, producto25, producto26, tpo_autoriza )
                VALUES
                ( vFechaHoy, vSucursal, vnombre_suc, vNumCliente, vNombreCliente, vdigito_verif, vapell_paterno, vapell_materno, vcorreo, vtel_movil, vtel_casa, 
                  vedad, vantiguedad, vmora, vescolaridad, vingresos, vestado_civil, vgenero, vsucursal_cte, vlinea_credito, vdependientes, cCodPos, cColonia, vDireccion,
                  vgeneracion, vfecha_mov, vpromotor, vtipo_pago, vnum_micro, vpago_club, vclub_protec, vno_productos, vsit_especial, vpta_act_autor, vpoliza_cp, vfecha_nac_cte,
                  vcentro, vtpo_canal, vtpo_sistema, vtpo_producto, vtpo_transacc, vsegmento, vtpo_persona,
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null',
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', vtpo_autoriza );
            END IF;
            
            LET vContador2 = vContador2 + 1;
            
            IF vContador2 >= 500 THEN
                LET vContador2 = 0;
                BEGIN WORK;
				COMMIT WORK;
                
            END IF;
        END FOREACH;
    END FOREACH;
	
	LET vComienza= -1;
	LET vEnTransacc = 0;
    LET vContador1 = 0;
    LET vContador2 = 0;
	-- Clientes
	FOREACH cursor_cliente_4 WITH HOLD FOR
        -------------------------------------------------------------------------------------
		SELECT UNIQUE cte.numcte
			INTO vNumCliente
			FROM bdinteg:si_cliente cte
			--WHERE --cte.empresa = '001'--
			--WHERE  cte.tpo_persona='01'
			--WHERE cte.tipo_cliente is not null
			--AND cte.empresa = '001'
			--AND cte.numcte <> ''
			--and (cte.fecha_insert = vfecha_ant or cte.fecha_alta = vfecha_ant)
			WHERE  cte.fecha_insert = vfecha_ant 
			--and cte.sucursal <> ''
			UNION ALL
			select UNIQUE cte2.numcte
			FROM bdinteg:si_cliente cte2
			WHERE cte2.numcte <> ''
			AND cte2.fecha_alta = vfecha_ant
			--AND cte2.tpo_persona = '01'
			--and cte.numcte <> ''
			--and cte.fecha_insert = vfecha_ant 
			--
			--
			/*union all 
			SELECT UNIQUE cte.numcte
			FROM bdinteg:si_cliente cte
			WHERE cte.empresa = pEmpresa
			and cte.tpo_persona='01'
			and cte.fecha_insert <> cte.fecha_alta
			AND cte.fecha_alta = vfecha_ant  */
			union all
			select UNIQUE bpi.numcte
			FROM bdinteg:si_bpiusuarios  bpi --, bdinteg:si_cliente cte 
			inner join bdinteg:si_cliente cte 
			on (bpi.numcte = cte.numcte and cte.tpo_persona='01' )
			--WHERE bpi.empresa='001'
			WHERE   bpi.numcte is not null 
			AND  bpi.id_status <> '04'
			AND date(bpi.f_unico_reg) = vfecha_ant
		-------------------------------------------------------------------------------------
	 
		/*union all
		select UNIQUE bpi.numcte
				FROM bdinteg:si_bpiusuarios  bpi
				inner join bdinteg:si_cliente cte 
				on (bpi.numcte = cte.numcte and cte.tpo_persona='01')
				--WHERE bpi.empresa='001'
				WHERE bpi.numcte is not null
				 AND  bpi.id_status = '20' --NOT IN ('0','1','2','3','4')
				 AND date(bpi.f_unico_reg) = vfecha_ant
		/*union all
		select UNIQUE bpi.numcte
				FROM bdinteg:si_bpiusuarios  bpi
				inner join bdinteg:si_cliente cte 
				on (bpi.numcte = cte.numcte and cte.tpo_persona='01')
				--WHERE bpi.empresa='001'
				WHERE bpi.numcte is not null
				 AND  bpi.id_status = '30' --NOT IN ('0','1','2','3','4')
				 AND date(bpi.f_unico_reg) = vfecha_ant
		union all
		select UNIQUE bpi.numcte
				FROM bdinteg:si_bpiusuarios  bpi
				inner join bdinteg:si_cliente cte 
				on (bpi.numcte = cte.numcte and cte.tpo_persona='01')
				--WHERE bpi.empresa='001'
				WHERE bpi.numcte is not null
				 AND  bpi.id_status = '90' --NOT IN ('0','1','2','3','4')
				 AND date(bpi.f_unico_reg) = vfecha_ant
		union all
		select UNIQUE bpi.numcte
				FROM bdinteg:si_bpiusuarios  bpi
				inner join bdinteg:si_cliente cte 
				on (bpi.numcte = cte.numcte and cte.tpo_persona='01')
				--WHERE bpi.empresa='001'
				WHERE bpi.numcte is not null
				 AND  bpi.id_status = '95' --NOT IN ('0','1','2','3','4')
				 AND date(bpi.f_unico_reg) = vfecha_ant*/
				 
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
			COMMIT WORK;
            LET vEnTransacc = 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
        SELECT TRIM(NVL(cte.nombre1,'')), TRIM(NVL(cte.nombre2,'')), TRIM(NVL(cte.apell_paterno,'')), TRIM(NVL(cte.apell_materno,'')), cte.fecha_insert, cte.sucursal,
               cpf.fecha_nac, cpf.sexo, cpf.estado_civil, tip.es_fisica, TRIM(NVL(mail.correo_elec,'')), TRIM(NVL(tel1.telefono,'')), TRIM(NVL(tel2.telefono,''))
          INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vfecha_insert, vsucursal_cte, vfecha_nac, vsexo, vedo_civil, ves_fisica, vcorreo, vtel_casa, vtel_movil
          FROM bdinteg:si_cliente cte
         INNER JOIN bdinteg:si_ctepf cpf ON ( cpf.numcte = cte.numcte )
         INNER JOIN bdinteg:si_tipper tip ON ( tip.tpo_persona = cte.tpo_persona )
          LEFT OUTER JOIN bdinteg:si_correos mail ON ( mail.numcte = cte.numcte AND mail.tipo_correo = 1 AND mail.status_correo = 'A' AND mail.secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cte.numcte AND tipo_correo = 1 AND status_correo = 'A' ) )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = cte.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = 'A' AND tel1.cofetel = 'V' )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = cte.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = 'A' AND tel2.cofetel = 'V' )
         WHERE cte.numcte = vNumCliente;
         
        IF ( vtel_movil is null OR vtel_movil = '' ) THEN
            CONTINUE FOREACH;
        END IF;
        
        SELECT calle.nombrecalle, dir.numeroextcalle, dir.numerointcalle, dir.departamento, zona.nombrezona, zona.municipiozona, ciu.nombreciudad, dir.cod_postal, edo.nombre    
          INTO cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cCodPos, cEstado
          FROM bdinteg:si_direcciones_actual dir
          LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
          LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
          LEFT OUTER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado )
         WHERE dir.numcte = vNumCliente
           AND dir.tipo_dir = '1';

		LET vDireccion = TRIM(NVL(cCalle,''))||' '||TRIM(NVL(cNumExt,''))||' '||TRIM(NVL(cNumInt,''))||' '||TRIM(NVL(cDepart,''))||' '||TRIM(NVL(cColonia,''))||' '||TRIM(NVL(cMunicipio,''))||' '||TRIM(NVL(cCiudad,''))||' '||TRIM(NVL(cCodPos,''))||' '||TRIM(NVL(cEstado,''));
        LET vDireccion = TRIM(vDireccion);
        
        IF ves_fisica = 'S' THEN
            LET vtpo_persona = 'PF';
        ELSE
            LET vtpo_persona = 'PM';
        END IF;
        
        IF vsexo = 'F' THEN
           LET vgenero = 'FEMENINO';
        ELSE
           LET vgenero = 'MASCULINO';
        END IF;
        
        IF vedo_civil = 'D' THEN
            LET vestado_civil = 'DIVORCIADO';
        ELIF vedo_civil = 'S' THEN
            LET vestado_civil = 'SOLTERO';
        ELIF vedo_civil = 'U' THEN
            LET vestado_civil = 'UNION LIBRE';
        ELIF vedo_civil = 'C' THEN
            LET vestado_civil = 'CASADO';
        ELIF vedo_civil = 'V' THEN
            LET vestado_civil = 'VIUDO';
        ELSE
            LET vestado_civil = 'SIN DESCRIPCION';
        END IF;
        
        LET vNombreCliente = TRIM(vnombre1)||' '||TRIM(vnombre2);
        LET vNombreCliente = TRIM(vNombreCliente);
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','A'),'Ã¡','a');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','E'),'Ã©','e');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','I'),'Ã­','i');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','O'),'Ã³','o');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','U'),'Ãº','u');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','N'),'Ã±','n');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','A'),'Ã¡','a');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','E'),'Ã©','e');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','I'),'Ã­','i');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','O'),'Ã³','o');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','U'),'Ãº','u');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','N'),'Ã±','n');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','A'),'Ã¡','a');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','E'),'Ã©','e');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','I'),'Ã­','i');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','O'),'Ã³','o');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','U'),'Ãº','u');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','N'),'Ã±','n');
        LET vfecha_nac_cte = TO_CHAR(vfecha_nac, '%d/%m/%Y');
        LET vedad = ROUND(((vfecha_ant - vfecha_nac) / 365), 0);
        LET vantiguedad = ROUND(((vfecha_ant - vfecha_insert) / 365), 0);
        
		
		select first 1 club.numcte, club.monto_mes,club.num_cta,mov.transacc 
		INTO vNoCteClub, vMontoClub,vNumcta,vTransaccmov
		from bdinteg:si_club_proteccion club,
			 bdisac:sac_movimientoshistorial sac, 
			 bdicheq:sc_movdia_concil mov
		where club.aceptada='1'
		and club.numcte= vNumCliente
		and trim(club.numcte_coppel) = trim(sac.referencia1)
		and sac.fecha_pago = mov.fech_alt 
		and sac.folio_suc = mov.folio_suc 
		and mov.fech_alt = vfecha_ant
		and mov.transacc in ('1303','1363')
		and mov.cancelad <> 'S';
		
		
        /*select unique club.numcte, club.monto_mes,mov.transacc
		INTO vNoCteClub, vMontoClub,vTransaccmov
		from bdinteg:si_club_proteccion club,
			 bdisac:sac_movimientoshistorial sac, 
			 bdicheq:sc_movdia_concil mov
		where club.aceptada='1'
		and club.numcte= vNumCliente
		and trim(club.numcte_coppel) = trim(sac.referencia1)
		and sac.fecha_pago = mov.fech_alt 
		and sac.folio_suc = mov.folio_suc 
		and mov.fech_alt = vfecha_ant
		and mov.transacc in ('1303','1363','0283') 
		and mov.cancelad <> 'S';*/
           
        IF vNoCteClub is not null AND vNoCteClub <> '' THEN
            --LET vclub_protec = 'SI';
            LET vpago_club = vMontoClub;
        ELSE
            LET vclub_protec = 'NO';
            LET vpago_club = 0;
        END IF;
		
		
        FOREACH cursor_cliente_4_1 WITH HOLD FOR
            SELECT cte.numcte, cte.sucursal, cte.fecha_insert, cte.ejecutivo, TRIM(suc.nombre), '0001'
              INTO vCuenta, vSucursal, vfecha_alta, vpromotor, vnombre_suc, vproductoc
              FROM bdinteg:si_cliente cte
              INNER JOIN bdinteg:si_sucursales suc ON (suc.sucursal = cte.sucursal and suc.tpo_sucursal = 'S')
             WHERE cte.empresa = pEmpresa
               AND cte.fecha_insert = vfecha_ant
               AND cte.numcte = vNumCliente
			union all
			SELECT cte.numcte, cte.sucursal, cte.fecha_alta, cte.ejecutivo, TRIM(suc.nombre), '0002'
              FROM bdinteg:si_cliente cte
              INNER JOIN bdinteg:si_sucursales suc ON (suc.sucursal = cte.sucursal and suc.tpo_sucursal = 'S')
             WHERE cte.empresa = pEmpresa
				and cte.fecha_alta <> cte.fecha_insert
               AND cte.fecha_alta = vfecha_ant
			   AND cte.numcte = vNumCliente
			union all
			select bpi.numcte,bpi.suc_registro,date(bpi.f_unico_reg),bpi.num_empleado, TRIM(suc.nombre), '0003'
				FROM bdinteg:si_bpiusuarios bpi
				INNER JOIN bdinteg:si_sucursales suc ON (suc.sucursal = bpi.suc_registro and suc.tpo_sucursal = 'S')
				WHERE bpi.empresa='001'
				AND bpi.numcte = vNumCliente
				AND date(bpi.f_unico_reg) = vfecha_ant
				AND  bpi.id_status NOT IN ('0','1','2','3','4')
				
			IF vpromotor = 'informix' THEN
				CONTINUE FOREACH;
			END IF;
			
			select sucursal
			  into vSucursalMto
			 from bdinteg:si_ejecut
			where empresa = pEmpresa
			and ejecutivo = vpromotor;
			           
			IF vproductoc = '0001' THEN
				LET vtpo_transacc = 'Alta clientes nuevos';
			end if;
			IF vproductoc = '0002' THEN
				LET vSucursal = vSucursalMto;
				LET vtpo_transacc = 'Mantenimiento de datos del cliente';
			end if;
			IF vproductoc = '0003' THEN
				LET vtpo_transacc = 'Alta Banca por internet, Express';
			end if;

            LET vfecha_mov = TO_CHAR(vfecha_alta, '%d/%m/%Y');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','A'),'Ã¡','a');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','E'),'Ã©','e');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','I'),'Ã­','i');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','O'),'Ã³','o');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','U'),'Ãº','u');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','N'),'Ã±','n');			
			/*--Obtener nombre del promotor
			select nombre 
				into vnombre_promotor
			  from bdinteg:si_ejecut
			 where empresa = '001'
			   and ejecutivo = vpromotor;
			
			   
			LET vnombre_promotor = TRIM(vnombre_promotor);*/
			
			--Validamos si adquiriÃ³ el club de proteccion en el mismo dÃ­a del proceso de este archivo csv
			SELECT MAX(fecha_alta),motivo_rechazo
			INTO vfecha_alta_club_prote,vmotivo_rechazo
			FROM bdinteg:si_club_proteccion
			where numcte = vNumCliente
			and aceptada = '1'
			AND motivo_rechazo =''
			GROUP BY 2;
			
			IF vfecha_alta_club_prote = vfecha_ant AND vmotivo_rechazo ='' THEN
				 LET vclub_protec = 'SI';
			ELSE 
				 LET vclub_protec = 'NO';
			END IF;
			
			IF vclub_protec = '0' OR vclub_protec ='' THEN
				LET vclub_protec ='NO';
			END IF;
			
			
            --IF ( ( vSucursal is not null AND vSucursal <> '' AND LENGTH(vSucursal) = 4 ) AND ( vnombre_suc is not null AND vnombre_suc <> '' AND vnombre_suc <> ' ' )  THEN
            IF ( ( vSucursal is not null AND vSucursal <> '' AND LENGTH(vSucursal) = 4 ) AND ( vnombre_suc is not null AND vnombre_suc <> '' AND vnombre_suc <> ' ' )  AND (vtpo_persona='PF')) THEN
                INSERT INTO sc_medalia_ctes_prom
                ( fecha_insert, sucursal, nombre_suc, numcte, nombre_cte, digito_verif, apell_paterno, apell_materno, correo, tel_movil, tel_casa,
                  edad, antiguedad, mora, escolaridad, ingresos, edo_civil, genero, sucursal_cte, linea_credito, dependientes, cod_postal, colonia, domicilio,
                  generacion, fecha_mov, promotor, tipo_pago, num_micro, pago_club, club_protec, no_productos, sit_especial, pta_act_autor, poliza_cp, fecha_nac,
                  centro, tpo_canal, tpo_sistema, tpo_producto, tpo_transacc, segmento, tpo_persona,
                  producto1, producto2, producto3, producto4, producto5, producto6, producto7, producto8, producto9, 
                  producto10, producto11, producto12, producto13, producto14, producto15, producto16, producto17, producto18, 
                  producto19, producto20, producto21, producto22, producto23, producto24, producto25, producto26, tpo_autoriza )
                VALUES
                ( vFechaHoy, vSucursal, vnombre_suc, vNumCliente, vNombreCliente, vdigito_verif, vapell_paterno, vapell_materno, vcorreo, vtel_movil, vtel_casa, 
                  vedad, vantiguedad, vmora, vescolaridad, vingresos, vestado_civil, vgenero, vsucursal_cte, vlinea_credito, vdependientes, cCodPos, cColonia, vDireccion,
                  vgeneracion, vfecha_mov, vpromotor, vtipo_pago, vnum_micro, vpago_club, vclub_protec, vno_productos, vsit_especial, vpta_act_autor, vpoliza_cp, vfecha_nac_cte,
                  vcentro, vtpo_canal, vtpo_sistema, vtpo_producto, vtpo_transacc, vsegmento, vtpo_persona,
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null',
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', vtpo_autoriza );
            END IF;
            
            LET vContador2 = vContador2 + 1;
            
            IF vContador2 >= 500 THEN
                LET vContador2 = 0;
                BEGIN WORK;
				COMMIT WORK;
                
            END IF;
        END FOREACH;
    END FOREACH;
	
	LET vComienza= -1;
	LET vEnTransacc = 0;
    LET vContador1 = 0;
    LET vContador2 = 0;
	--Solicitudes Colocacion
	FOREACH cursor_cliente_5 WITH HOLD FOR
        SELECT UNIQUE sol.numcte
          INTO vNumCliente
          FROM bdisolic:ss_solicitudes sol
          inner join bdinteg:si_cliente cte on (sol.empresa = cte.empresa and sol.numcte = cte.numcte and cte.tpo_persona='01')
         WHERE sol.empresa = pEmpresa
           AND sol.fecha_insert = vfecha_ant
           
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
			COMMIT WORK;
            LET vEnTransacc = 1;
        END IF;
        
        LET vContador1 = vContador1 + 1;
        
        SELECT TRIM(NVL(cte.nombre1,'')), TRIM(NVL(cte.nombre2,'')), TRIM(NVL(cte.apell_paterno,'')), TRIM(NVL(cte.apell_materno,'')), cte.fecha_insert, cte.sucursal,
               cpf.fecha_nac, cpf.sexo, cpf.estado_civil, tip.es_fisica, TRIM(NVL(mail.correo_elec,'')), TRIM(NVL(tel1.telefono,'')), TRIM(NVL(tel2.telefono,''))
          INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vfecha_insert, vsucursal_cte, vfecha_nac, vsexo, vedo_civil, ves_fisica, vcorreo, vtel_casa, vtel_movil
          FROM bdinteg:si_cliente cte
         INNER JOIN bdinteg:si_ctepf cpf ON ( cpf.numcte = cte.numcte )
         INNER JOIN bdinteg:si_tipper tip ON ( tip.tpo_persona = cte.tpo_persona )
          LEFT OUTER JOIN bdinteg:si_correos mail ON ( mail.numcte = cte.numcte AND mail.tipo_correo = 1 AND mail.status_correo = 'A' AND mail.secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cte.numcte AND tipo_correo = 1 AND status_correo = 'A' ) )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = cte.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = 'A' AND tel1.cofetel = 'V' )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = cte.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = 'A' AND tel2.cofetel = 'V' )
         WHERE cte.numcte = vNumCliente;
         
        IF ( vtel_movil is null OR vtel_movil = '' ) THEN
            CONTINUE FOREACH;
        END IF;
        
        SELECT calle.nombrecalle, dir.numeroextcalle, dir.numerointcalle, dir.departamento, zona.nombrezona, zona.municipiozona, ciu.nombreciudad, dir.cod_postal, edo.nombre    
          INTO cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cCodPos, cEstado
          FROM bdinteg:si_direcciones_actual dir
          LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
          LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
          LEFT OUTER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado )
         WHERE dir.numcte = vNumCliente
           AND dir.tipo_dir = '1';

		LET vDireccion = TRIM(NVL(cCalle,''))||' '||TRIM(NVL(cNumExt,''))||' '||TRIM(NVL(cNumInt,''))||' '||TRIM(NVL(cDepart,''))||' '||TRIM(NVL(cColonia,''))||' '||TRIM(NVL(cMunicipio,''))||' '||TRIM(NVL(cCiudad,''))||' '||TRIM(NVL(cCodPos,''))||' '||TRIM(NVL(cEstado,''));
        LET vDireccion = TRIM(vDireccion);
        
        IF ves_fisica = 'S' THEN
            LET vtpo_persona = 'PF';
        ELSE
            LET vtpo_persona = 'PM';
        END IF;
        
        IF vsexo = 'F' THEN
           LET vgenero = 'FEMENINO';
        ELSE
           LET vgenero = 'MASCULINO';
        END IF;
        
        IF vedo_civil = 'D' THEN
            LET vestado_civil = 'DIVORCIADO';
        ELIF vedo_civil = 'S' THEN
            LET vestado_civil = 'SOLTERO';
        ELIF vedo_civil = 'U' THEN
            LET vestado_civil = 'UNION LIBRE';
        ELIF vedo_civil = 'C' THEN
            LET vestado_civil = 'CASADO';
        ELIF vedo_civil = 'V' THEN
            LET vestado_civil = 'VIUDO';
        ELSE
            LET vestado_civil = 'SIN DESCRIPCION';
        END IF;
        
        LET vNombreCliente = TRIM(vnombre1)||' '||TRIM(vnombre2);
        LET vNombreCliente = TRIM(vNombreCliente);
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','A'),'Ã¡','a');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','E'),'Ã©','e');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','I'),'Ã­','i');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','O'),'Ã³','o');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','U'),'Ãº','u');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','N'),'Ã±','n');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','A'),'Ã¡','a');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','E'),'Ã©','e');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','I'),'Ã­','i');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','O'),'Ã³','o');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','U'),'Ãº','u');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','N'),'Ã±','n');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','A'),'Ã¡','a');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','E'),'Ã©','e');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','I'),'Ã­','i');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','O'),'Ã³','o');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','U'),'Ãº','u');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','N'),'Ã±','n');
        LET vfecha_nac_cte = TO_CHAR(vfecha_nac, '%d/%m/%Y');
        LET vedad = ROUND(((vfecha_ant - vfecha_nac) / 365), 0);
        LET vantiguedad = ROUND(((vfecha_ant - vfecha_insert) / 365), 0);
        
		select first 1 club.numcte, club.monto_mes,club.num_cta,mov.transacc 
		INTO vNoCteClub, vMontoClub,vNumcta,vTransaccmov
		from bdinteg:si_club_proteccion club,
			 bdisac:sac_movimientoshistorial sac, 
			 bdicheq:sc_movdia_concil mov
		where club.aceptada='1'
		and club.numcte= vNumCliente
		and trim(club.numcte_coppel) = trim(sac.referencia1)
		and sac.fecha_pago = mov.fech_alt 
		and sac.folio_suc = mov.folio_suc 
		and mov.fech_alt = vfecha_ant
		and mov.transacc in ('1303','1363')
		and mov.cancelad <> 'S';
	
        /*select unique club.numcte, club.monto_mes
		INTO vNoCteClub, vMontoClub
		from bdinteg:si_club_proteccion club,
			 bdisac:sac_movimientoshistorial sac, 
			 bdicheq:sc_movdia_concil mov
		where club.aceptada='1'
		and club.numcte= vNumCliente
		and trim(club.numcte_coppel) = trim(sac.referencia1)
		and sac.fecha_pago = mov.fech_alt 
		and sac.folio_suc = mov.folio_suc 
		and mov.fech_alt = vfecha_ant
		and mov.transacc in ('1303','1363','0283') 
		and mov.cancelad <> 'S';*/
           
        IF vNoCteClub is not null AND vNoCteClub <> '' THEN
            --LET vclub_protec = 'SI';
            LET vpago_club = vMontoClub;
        ELSE
            LET vclub_protec = 'NO';
            LET vpago_club = 0;
        END IF;

        FOREACH cursor_cliente_5_1 WITH HOLD FOR
            SELECT sol.num_solicitud, sol.sucursal, sol.fecha_insert, sol.user_insert, TRIM(suc.nombre), TRIM(sol.num_producto)
              INTO vCuenta, vSucursal, vfecha_alta, vpromotor, vnombre_suc, vproductoc
              FROM bdisolic:ss_solicitudes sol
              INNER JOIN bdinteg:si_sucursales suc ON (suc.sucursal = sol.sucursal and suc.tpo_sucursal = 'S')
             WHERE sol.empresa = pEmpresa
               AND sol.fecha_insert = vfecha_ant
               AND sol.numcte = vNumCliente
			   
			IF vpromotor = 'informix' THEN
				CONTINUE FOREACH;
			END IF;
            
			IF vproductoc = '6500' THEN
				LET vtpo_transacc = 'Solicitud de Credito Coppel';
			end if;
			IF vproductoc in ('6300','7600','7700','6800') THEN
				LET vtpo_transacc = 'Solicitud de prestamo personal, Digital';
			end if;
			IF vproductoc in ('6001','7000','8100') THEN
				LET vtpo_transacc = 'Solicitud de TDC Visa, Garantizada, Oro, Platino';
			end if;
			IF vproductoc = '6400' THEN
				LET vtpo_transacc = 'Solicitud prestamo directo Nomina';
			end if;

            LET vfecha_mov = TO_CHAR(vfecha_alta, '%d/%m/%Y');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','A'),'Ã¡','a');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','E'),'Ã©','e');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','I'),'Ã­','i');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','O'),'Ã³','o');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','U'),'Ãº','u');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','N'),'Ã±','n');		
			/*--Obtener nombre del promotor
			select nombre 
				into vnombre_promotor
			  from bdinteg:si_ejecut
			 where empresa = '001'
			   and ejecutivo = vpromotor;
			   
			LET vnombre_promotor = TRIM(vnombre_promotor);*/
			
			
			--Validamos si adquiriÃ³ el club de proteccion en el mismo dÃ­a del proceso de este archivo csv
			SELECT MAX(fecha_alta),motivo_rechazo
			INTO vfecha_alta_club_prote,vmotivo_rechazo
			FROM bdinteg:si_club_proteccion
			where numcte = vNumCliente
			and aceptada = '1'
			AND motivo_rechazo =''
			GROUP BY 2;
			
			IF vfecha_alta_club_prote = vfecha_ant AND vmotivo_rechazo ='' THEN
				 LET vclub_protec = 'SI';
			ELSE 
				 LET vclub_protec = 'NO';
			END IF;
			
			IF vclub_protec = '0' OR vclub_protec ='' THEN
				LET vclub_protec ='NO';
			END IF;
			
            
            IF ( ( vSucursal is not null AND vSucursal <> '' AND LENGTH(vSucursal) = 4 ) AND ( vnombre_suc is not null AND vnombre_suc <> '' AND vnombre_suc <> ' ' ) ) THEN
                INSERT INTO sc_medalia_ctes_prom
                ( fecha_insert, sucursal, nombre_suc, numcte, nombre_cte, digito_verif, apell_paterno, apell_materno, correo, tel_movil, tel_casa,
                  edad, antiguedad, mora, escolaridad, ingresos, edo_civil, genero, sucursal_cte, linea_credito, dependientes, cod_postal, colonia, domicilio,
                  generacion, fecha_mov, promotor, tipo_pago, num_micro, pago_club, club_protec, no_productos, sit_especial, pta_act_autor, poliza_cp, fecha_nac,
                  centro, tpo_canal, tpo_sistema, tpo_producto, tpo_transacc, segmento, tpo_persona,
                  producto1, producto2, producto3, producto4, producto5, producto6, producto7, producto8, producto9, 
                  producto10, producto11, producto12, producto13, producto14, producto15, producto16, producto17, producto18, 
                  producto19, producto20, producto21, producto22, producto23, producto24, producto25, producto26, tpo_autoriza )
                VALUES
                ( vFechaHoy, vSucursal, vnombre_suc, vNumCliente, vNombreCliente, vdigito_verif, vapell_paterno, vapell_materno, vcorreo, vtel_movil, vtel_casa, 
                  vedad, vantiguedad, vmora, vescolaridad, vingresos, vestado_civil, vgenero, vsucursal_cte, vlinea_credito, vdependientes, cCodPos, cColonia, vDireccion,
                  vgeneracion, vfecha_mov, vpromotor, vtipo_pago, vnum_micro, vpago_club, vclub_protec, vno_productos, vsit_especial, vpta_act_autor, vpoliza_cp, vfecha_nac_cte,
                  vcentro, vtpo_canal, vtpo_sistema, vtpo_producto, vtpo_transacc, vsegmento, vtpo_persona,
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null',
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', vtpo_autoriza );
            END IF;
            
            LET vContador2 = vContador2 + 1;
            
            IF vContador2 >= 500 THEN
                LET vContador2 = 0;
                BEGIN WORK;
				COMMIT WORK;
                
            END IF;
        END FOREACH;
    END FOREACH;
	
	
	LET vComienza= -1;
	LET vEnTransacc = 0;
    LET vContador1 = 0;
    LET vContador2 = 0;
	--bloqueos y cancelacion de cuentas
	FOREACH cursor_cliente_6 WITH HOLD FOR
        SELECT  UNIQUE b.num_cte
          INTO vNumCliente
          	from bdicheq:sc_histbloq a
			inner join bdicheq:sc_maechq b on (a.cuenta = b.cuenta)
			where a.empresa = pEmpresa
			and a.fecha = vfecha_ant
		union all 
		SELECT UNIQUE b.num_cte
             from bdicheq:sc_ctacancelada can
			inner join bdicheq:sc_maechq b on (can.cuenta = b.cuenta)
			where can.empresa = pEmpresa
			and can.fecha_cancelacion = vfecha_ant 
		union all
		select UNIQUE can.num_cte
				from bdicred:sd_cred_can can
				--where can.empresa = pEmpresa
				where can.motivo_can <> ''
				and can.tipo_can <> ''
				and can.fecha_can = vfecha_ant
		/*select UNIQUE can.num_cte
				from bdicred:sd_cred_can can
				where can.empresa = pEmpresa 
				and can.fecha_can = vfecha_ant
		*/		 
       IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
			COMMIT WORK;
            LET vEnTransacc = 1;
        END IF;

        LET vContador1 = vContador1 + 1;
        
        SELECT TRIM(NVL(cte.nombre1,'')), TRIM(NVL(cte.nombre2,'')), TRIM(NVL(cte.apell_paterno,'')), TRIM(NVL(cte.apell_materno,'')), cte.fecha_insert, cte.sucursal,
               cpf.fecha_nac, cpf.sexo, cpf.estado_civil, tip.es_fisica, TRIM(NVL(mail.correo_elec,'')), TRIM(NVL(tel1.telefono,'')), TRIM(NVL(tel2.telefono,''))
          INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vfecha_insert, vsucursal_cte, vfecha_nac, vsexo, vedo_civil, ves_fisica, vcorreo, vtel_casa, vtel_movil
          FROM bdinteg:si_cliente cte
         INNER JOIN bdinteg:si_ctepf cpf ON ( cpf.numcte = cte.numcte )
         INNER JOIN bdinteg:si_tipper tip ON ( tip.tpo_persona = cte.tpo_persona )
          LEFT OUTER JOIN bdinteg:si_correos mail ON ( mail.numcte = cte.numcte AND mail.tipo_correo = 1 AND mail.status_correo = 'A' AND mail.secuencia = ( SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cte.numcte AND tipo_correo = 1 AND status_correo = 'A' ) )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = cte.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = 'A' AND tel1.cofetel = 'V' )
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = cte.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = 'A' AND tel2.cofetel = 'V' )
         WHERE cte.numcte = vNumCliente;
         
        IF ( vtel_movil is null OR vtel_movil = '' ) THEN
            CONTINUE FOREACH;
        END IF;
        
        SELECT calle.nombrecalle, dir.numeroextcalle, dir.numerointcalle, dir.departamento, zona.nombrezona, zona.municipiozona, ciu.nombreciudad, dir.cod_postal, edo.nombre    
          INTO cCalle, cNumExt, cNumInt, cDepart, cColonia, cMunicipio, cCiudad, cCodPos, cEstado
          FROM bdinteg:si_direcciones_actual dir
          LEFT OUTER JOIN bdinteg:si_catcalles calle ON (calle.numerocalle = dir.numerocalle)
          LEFT OUTER JOIN bdinteg:si_catzonas zona   ON (zona.numerociudad = dir.numerociudad AND zona.numerocolonia = dir.numerocolonia)
          LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
          LEFT OUTER JOIN bdinteg:si_estados edo ON ( edo.estado = dir.estado )
         WHERE dir.numcte = vNumCliente
           AND dir.tipo_dir = '1';

		LET vDireccion = TRIM(NVL(cCalle,''))||' '||TRIM(NVL(cNumExt,''))||' '||TRIM(NVL(cNumInt,''))||' '||TRIM(NVL(cDepart,''))||' '||TRIM(NVL(cColonia,''))||' '||TRIM(NVL(cMunicipio,''))||' '||TRIM(NVL(cCiudad,''))||' '||TRIM(NVL(cCodPos,''))||' '||TRIM(NVL(cEstado,''));
        LET vDireccion = TRIM(vDireccion);
        
        IF ves_fisica = 'S' THEN
            LET vtpo_persona = 'PF';
        ELSE
            LET vtpo_persona = 'PM';
        END IF;
        
        IF vsexo = 'F' THEN
           LET vgenero = 'FEMENINO';
        ELSE
           LET vgenero = 'MASCULINO';
        END IF;
        
        IF vedo_civil = 'D' THEN
            LET vestado_civil = 'DIVORCIADO';
        ELIF vedo_civil = 'S' THEN
            LET vestado_civil = 'SOLTERO';
        ELIF vedo_civil = 'U' THEN
            LET vestado_civil = 'UNION LIBRE';
        ELIF vedo_civil = 'C' THEN
            LET vestado_civil = 'CASADO';
        ELIF vedo_civil = 'V' THEN
            LET vestado_civil = 'VIUDO';
        ELSE
            LET vestado_civil = 'SIN DESCRIPCION';
        END IF;
        
        LET vNombreCliente = TRIM(vnombre1)||' '||TRIM(vnombre2);
        LET vNombreCliente = TRIM(vNombreCliente);
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','A'),'Ã¡','a');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','E'),'Ã©','e');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','I'),'Ã­','i');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','O'),'Ã³','o');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','U'),'Ãº','u');
		LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','N'),'Ã±','n');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','A'),'Ã¡','a');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','E'),'Ã©','e');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','I'),'Ã­','i');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','O'),'Ã³','o');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','U'),'Ãº','u');
		LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','N'),'Ã±','n');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','A'),'Ã¡','a');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','E'),'Ã©','e');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','I'),'Ã­','i');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','O'),'Ã³','o');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','U'),'Ãº','u');
		LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','N'),'Ã±','n');
        LET vfecha_nac_cte = TO_CHAR(vfecha_nac, '%d/%m/%Y');
        LET vedad = ROUND(((vfecha_ant - vfecha_nac) / 365), 0);
        LET vantiguedad = ROUND(((vfecha_ant - vfecha_insert) / 365), 0);
        
		select first 1 club.numcte, club.monto_mes,club.num_cta,mov.transacc 
		INTO vNoCteClub, vMontoClub,vNumcta,vTransaccmov
		from bdinteg:si_club_proteccion club,
			 bdisac:sac_movimientoshistorial sac, 
			 bdicheq:sc_movdia_concil mov
		where club.aceptada='1'
		and club.numcte= vNumCliente
		and trim(club.numcte_coppel) = trim(sac.referencia1)
		and sac.fecha_pago = mov.fech_alt 
		and sac.folio_suc = mov.folio_suc 
		and mov.fech_alt = vfecha_ant
		and mov.transacc in ('1303','1363')
		and mov.cancelad <> 'S';
			
        /*select unique club.numcte, club.monto_mes
		INTO vNoCteClub, vMontoClub
		from bdinteg:si_club_proteccion club,
			 bdisac:sac_movimientoshistorial sac, 
			 bdicheq:sc_movdia_concil mov
		where club.aceptada='1'
		and club.numcte= vNumCliente
		and trim(club.numcte_coppel) = trim(sac.referencia1)
		and sac.fecha_pago = mov.fech_alt 
		and sac.folio_suc = mov.folio_suc 
		and mov.fech_alt = vfecha_ant
		and mov.transacc in ('1303','1363','0283') 
		and mov.cancelad <> 'S';*/
           
        IF vNoCteClub is not null AND vNoCteClub <> '' THEN
            --LET vclub_protec = 'SI';
            LET vpago_club = vMontoClub;
        ELSE
            LET vclub_protec = 'NO';
            LET vpago_club = 0;
        END IF;
		        
        FOREACH cursor_cliente_6_1 WITH HOLD FOR
            select a.cuenta, b.sucursal, a.fecha, mae.ejecutivo,TRIM(suc.nombre), 'blob'
			INTO vCuenta, vSucursal, vfecha_alta, vpromotor, vnombre_suc, vproductoc
			from bdicheq:sc_histbloq a
			inner join bdicheq:sc_maechq b on (a.cuenta = b.cuenta)
			inner join bdicheq:sc_maenoc mae on (a.cuenta = mae.cuenta)
			inner join bdinteg:si_sucursales suc on (b.sucursal = suc.sucursal and suc.tpo_sucursal = 'S')
			where a.empresa = pEmpresa
			and a.fecha = vfecha_ant
			and b.num_cte = vNumCliente
			union all
			select can.cuenta,can.sucursal,can.fecha_cancelacion, can.promotor_cancelo,TRIM(suc.nombre), 'bloc'
			from bdicheq:sc_ctacancelada can
			inner join bdicheq:sc_maechq b on (can.cuenta = b.cuenta)
			inner join bdinteg:si_sucursales suc on (can.sucursal = suc.sucursal and suc.tpo_sucursal = 'S')
			where can.empresa = pEmpresa
			and can.fecha_cancelacion = vfecha_ant
			and b.num_cte = vNumCliente
			union all
			select can.num_credito,can.sucursal,can.fecha_can,can.ejecutivo,TRIM(suc.nombre), 'bloc'
			from bdicred:sd_cred_can can
			inner join bdinteg:si_sucursales suc on (can.sucursal = suc.sucursal and suc.tpo_sucursal = 'S')
			where can.empresa = '001' 
			and can.fecha_can = vfecha_ant
			and can.num_cte = vNumCliente
			
			IF vpromotor = 'informix' THEN
				CONTINUE FOREACH;
			END IF;
			
			IF vproductoc = 'blob' THEN
				LET vtpo_transacc = 'Bloqueo y desbloqueo de cuentas de captacion y colocacion';
			end if;
			IF vproductoc = 'bloc' THEN
				LET vtpo_transacc = 'Cancelacion de cuentas de captacion y de credito';
			end if;

            LET vfecha_mov = TO_CHAR(vfecha_alta, '%d/%m/%Y');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','A'),'Ã¡','a');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','E'),'Ã©','e');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','I'),'Ã­','i');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','O'),'Ã³','o');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','U'),'Ãº','u');
			LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','N'),'Ã±','n');	
			/*--Obtener nombre del promotor
			select nombre 
				into vnombre_promotor
			  from bdinteg:si_ejecut
			 where empresa = '001'
			   and ejecutivo = vpromotor;
			   
			LET vnombre_promotor = TRIM(vnombre_promotor);*/
			
			
			--Validamos si adquiriÃ³ el club de proteccion en el mismo dÃ­a del proceso de este archivo csv
			SELECT MAX(fecha_alta),motivo_rechazo
			INTO vfecha_alta_club_prote,vmotivo_rechazo
			FROM bdinteg:si_club_proteccion
			where numcte = vNumCliente
			and aceptada = '1'
			AND motivo_rechazo =''
			GROUP BY 2;
			
			IF vfecha_alta_club_prote = vfecha_ant AND vmotivo_rechazo ='' THEN
				 LET vclub_protec = 'SI';
			ELSE 
				 LET vclub_protec = 'NO';
			END IF;
			
			IF vclub_protec = '0' OR vclub_protec ='' THEN
				LET vclub_protec ='NO';
			END IF;
            
            IF ( ( vSucursal is not null AND vSucursal <> '' AND LENGTH(vSucursal) = 4 ) AND ( vnombre_suc is not null AND vnombre_suc <> '' AND vnombre_suc <> ' ' ) ) THEN
                INSERT INTO sc_medalia_ctes_prom
                ( fecha_insert, sucursal, nombre_suc, numcte, nombre_cte, digito_verif, apell_paterno, apell_materno, correo, tel_movil, tel_casa,
                  edad, antiguedad, mora, escolaridad, ingresos, edo_civil, genero, sucursal_cte, linea_credito, dependientes, cod_postal, colonia, domicilio,
                  generacion, fecha_mov, promotor, tipo_pago, num_micro, pago_club, club_protec, no_productos, sit_especial, pta_act_autor, poliza_cp, fecha_nac,
                  centro, tpo_canal, tpo_sistema, tpo_producto, tpo_transacc, segmento, tpo_persona,
                  producto1, producto2, producto3, producto4, producto5, producto6, producto7, producto8, producto9, 
                  producto10, producto11, producto12, producto13, producto14, producto15, producto16, producto17, producto18, 
                  producto19, producto20, producto21, producto22, producto23, producto24, producto25, producto26, tpo_autoriza )
                VALUES
                ( vFechaHoy, vSucursal, vnombre_suc, vNumCliente, vNombreCliente, vdigito_verif, vapell_paterno, vapell_materno, vcorreo, vtel_movil, vtel_casa, 
                  vedad, vantiguedad, vmora, vescolaridad, vingresos, vestado_civil, vgenero, vsucursal_cte, vlinea_credito, vdependientes, cCodPos, cColonia, vDireccion,
                  vgeneracion, vfecha_mov, vpromotor, vtipo_pago, vnum_micro, vpago_club, vclub_protec, vno_productos, vsit_especial, vpta_act_autor, vpoliza_cp, vfecha_nac_cte,
                  vcentro, vtpo_canal, vtpo_sistema, vtpo_producto, vtpo_transacc, vsegmento, vtpo_persona,
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null',
                  'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', vtpo_autoriza );
            END IF;
            
            LET vContador2 = vContador2 + 1;
            
            IF vContador2 >= 500 THEN
                LET vContador2 = 0;
                BEGIN WORK;
				COMMIT WORK;
                
            END IF;
        END FOREACH;
    END FOREACH;
	
    IF vEnTransacc = 1 THEN
		BEGIN WORK;
        COMMIT WORK;
    END IF;
    
	LET vContador1 = 0;
	
		SELECT COUNT(*) 
		INTO vContador1
		FROM bdicheq:sc_medalia_ctes_prom;
	
	LET vContador1 = vContador1;
	
	
	
    LET vfecha = TO_CHAR(vfecha_ant, '%d_%m_%Y');
    
    LET vsql = '';
    LET vsql = 'echo "NUMERO_SUCURSAL|NOMBRE_SUCURSAL|NUMERO_CLIENTE|NOMBRE_CLIENTE|DIGITO_VERIFICADOR|APELLIDOPATERNO_CLIENTE|APELLIDOMATERNO_CLIENTE|CORREO_CLIENTE|TELEFONOCEL_CLIENTE|TELEFONOFIJO_CLIENTE|'||
               'EDAD_CLIENTE|ANTIGUEDAD_CLIENTE|MORA DEL CLIENTE|ESCOLARIDAD_CLIENTE|INGRESOS_CLIENTE|ESTADOCIVIL_CLIENTE|GENERO_CLIENTE|SUCURSALORIGEN_CLIENTE|LINEACREDITO_CLIENTE|DEPENDIENTES_CLIENTE|CODIGOPOSTAL_CLIENTE|COLONIA_CLIENTE|DOMICILIO_CLIENTE|'||
               'GENERACION_CLIENTE|FECHA_TRANSACCION|NUMERO_PROMOTOR|TIPO_PAGO|NUMERO_MICRO|PAGO_CLUBPROTECCION|CLUB_PROTECCION|CANTIDAD_PRODUCTOS|SITUACION_ESPECIAL_CLIENTE|PLANTA ACTUAL VS AUTORIZADA|POLIZA_CP|FECHA_NACIMIENTO_CLIENTE|'||
               'CENTRO|TIPO_CANAL|TIPO_SISTEMA|TIPO_PRODUCTO|TIPO_TRANSACCION|SEGMENTO|TIPO_PERSONA|'||
               'PRODUCTO_1|PRODUCTO_2|PRODUCTO_3|PRODUCTO_4|PRODUCTO_5|PRODUCTO_6|PRODUCTO_7|PRODUCTO_8|PRODUCTO_9|'||
               'PRODUCTO_10|PRODUCTO_11|PRODUCTO_12|PRODUCTO_13|PRODUCTO_14|PRODUCTO_15|PRODUCTO_16|PRODUCTO_17|PRODUCTO_18|'||
               'PRODUCTO_19|PRODUCTO_20|PRODUCTO_21|PRODUCTO_22|PRODUCTO_23|PRODUCTO_24|PRODUCTO_25|PRODUCTO_26|TIPO_AUTORIZACION" > /resplogifx/conciliachq/originales/coppel_banco_prom_invitacion_'||vfecha||'.csv.enc';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/originales/coppel_banco_prom_invitacion_'||vfecha||'.csv.det '||
               'SELECT sucursal, REPLACE(REPLACE(trim(nombre_suc),''SUC '',''''),''SUC. '',''''), numcte, nombre_cte, digito_verif, apell_paterno, apell_materno, correo, tel_movil, tel_casa, '||
               'edad, antiguedad, mora, escolaridad, ingresos, edo_civil, genero, sucursal_cte, linea_credito, dependientes, cod_postal, colonia, domicilio, '||
               'generacion, fecha_mov, promotor, tipo_pago, num_micro, pago_club, club_protec, no_productos, sit_especial, pta_act_autor, poliza_cp, fecha_nac, '||
               'centro, tpo_canal, tpo_sistema, tpo_producto, tpo_transacc, segmento, tpo_persona, '||
               'producto1, producto2, producto3, producto4, producto5, producto6, producto7, producto8, producto9, '||
               'producto10, producto11, producto12, producto13, producto14, producto15, producto16, producto17, producto18, '||
               'producto19, producto20, producto21, producto22, producto23, producto24, producto25, producto26, tpo_autoriza '||
               'FROM sc_medalia_ctes_prom WHERE fecha_insert = '''||vFechaHoy||''' " > /resplogifx/conciliachq/medalia/prom_medalia.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '';
    LET vstmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/medalia/prom_medalia.sql"; 
    SYSTEM vstmt;
    LET vstmt = '';
    
    LET vsql = '';
    LET vsql = 'cat /resplogifx/conciliachq/originales/coppel_banco_prom_invitacion_'||vfecha||'.csv.enc /resplogifx/conciliachq/originales/coppel_banco_prom_invitacion_'||vfecha||'.csv.det > /resplogifx/conciliachq/originales/coppel_banco_prom_invitacion_'||vfecha||'.csv';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vsql = '';
    LET vsql = 'rm /resplogifx/conciliachq/originales/coppel_banco_prom_invitacion_'||vfecha||'.csv.enc';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vsql = '';
    LET vsql = 'rm /resplogifx/conciliachq/originales/coppel_banco_prom_invitacion_'||vfecha||'.csv.det';
    SYSTEM vsql;
    LET vsql = '';
	
	
    END; 
    
    RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
    
END PROCEDURE;