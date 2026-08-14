CREATE PROCEDURE "informix".consctesfirxnumctaper2(pEmpresa CHAR(3), pNumeroCuenta CHAR(20), pNumeroCliente CHAR(20))
	-- DATOS A REGRESAR --
	RETURNING
	CHAR(5),     -- Codigo de retorno
	CHAR(20),    -- # Cliente
	CHAR(26),    -- Apellido paterno
	CHAR(26),    -- Apellido materno
	CHAR(26),    -- Nombre 1
	CHAR(26),    -- Nombre 2
	CHAR(13),    -- RFC
	CHAR(16),    -- # Tarjeta
	DATE,    	 --	Expiracion
	CHAR(4),     -- Producto tarjeta
	MONEY(14,2), -- Limite de retiro maximo por mes
	CHAR(1),     -- Status tarjeta
	CHAR(8),     -- Tipo de cliente
	CHAR(10),    -- Fecha de Nacimiento
	CHAR(4),     -- Producto de la cuenta
	CHAR(2);     -- Parentesco

	-- VARIABLES --
	DEFINE vCodRet  	CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE vTipCte  	CHAR(1);
	DEFINE vNumCte		CHAR(20);
	DEFINE vApePat  	CHAR(26);
	DEFINE vApeMat  	CHAR(26);
	DEFINE vNombre1 	CHAR(26);
	DEFINE vNombre2 	CHAR(26);
	DEFINE vRFC     	CHAR(13);
	DEFINE vNumTarj 	CHAR(16);
	DEFINE Vexpiracion  DATE;
	DEFINE Vprodtarjeta CHAR(4);
	DEFINE vLimTar  	MONEY(14,2);
	DEFINE vTipoCte 	CHAR(8);
	DEFINE vStatTjt 	CHAR(1);
	DEFINE vFechaNac 	CHAR(10);
	DEFINE vProductoCuenta CHAR(4);
	DEFINE vCantReg 	SMALLINT;
	DEFINE vParentesco 	CHAR(2);
	DEFINE vSecuencia 	CHAR(1);
	DEFINE vEmpresa 	CHAR(3);
	DEFINE vCuenta      CHAR(20);
	DEFINE vApellidos   CHAR(26);
	DEFINE vNombre      CHAR(26);
	DEFINE vReg_firma   CHAR(1);
	DEFINE vCont        INTEGER;
	DEFINE vTipo_firma  CHAR(2);
	DEFINE vCombinacion CHAR(2);
   --	DEFINE vFechaNac2 	DATE;
	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  		= "000";
	LET iSqlErr   		= 0;
	LET vCantReg 		= 0;
	LET vTipCte 		= "";
	LET vNumCte 		= "";
	LET vApePat 		= "";
	LET vApeMat 		= "";
	LET vNombre1 		= "";
	LET vNombre2 		= "";
	LET vRFC 			= "";
	LET vNumTarj 		= "";
	LET Vexpiracion 	= "";
	LET Vprodtarjeta 	= "";
	LET vLimTar 		= "";
	LET vTipoCte 		= "";
	LET vStatTjt 		= "";
	LET vFechaNac 		= "";
	LET vProductoCuenta = "";
	LET vParentesco 	= "";	
	LET vSecuencia  	= "";
	LET vEmpresa  	    = "";
	LET vCuenta		    = "";
	LET vApellidos      = '';
	LET vNombre         = '';
	LET vReg_firma      = '';
	LET vTipo_firma     = '';
	LET vCombinacion    = '';
	LET vCont           = 0;
	LET vTipo_firma     ='';
  --  LET vFechaNac2 = "";

	--SET DEBUG FILE TO "/ifxsif01/efv/incidencias/trace/ConsCtesFirXnumCtaPer.out";
	--TRACE ON;
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = iSqlErr;
				RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
						Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;


		-- CICLO PARA OBTENER A LOS FIRMANTES Y LAS TARJETAS DE DEBITO EN CASO DE QUE TENGAN --

		FOREACH
		
			SELECT DISTINCT si_cte.numcte, 
				si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 
				sc_fir.secuencia As tipo_cliente, si_pf.fecha_nac, sc_mcq.producto, sc_fir.parentesco
			INTO
                
				vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vTipoCte, vFechaNac, vProductoCuenta, vParentesco
			FROM
				bdicheq:"informix".sc_maechq sc_mcq,
				bdicheq:"informix".sc_firmantes AS sc_fir,
				bdinteg:"informix".si_cliente AS si_cte,
				bdinteg:"informix".si_ctepf AS si_pf
			WHERE sc_fir.empresa =  pEmpresa 
			  AND sc_fir.cuenta =  pNumeroCuenta 
			  -- AND sc_fir.numcte != pNumeroCliente 
			  AND sc_fir.numcte = si_cte.numcte 
			  AND si_cte.empresa = pEmpresa 
			  AND sc_fir.numcte = si_pf.numcte
			  AND sc_mcq.empresa = pEmpresa 
			  AND sc_mcq.cuenta = pNumeroCuenta
			  ORDER BY sc_fir.secuencia ASC



			IF vTipoCte = '1' THEN
				LET vTipoCte = 'Titular';
			ELSE
				LET vTipoCte = 'Firmante';
				
			END IF;

			-- OBTENER LA TARJETA DEL FIRMANTE --

			SELECT DISTINCT sc_tjt.expiracion, sc_tjt.prodtarjeta, sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
			INTO
				Vexpiracion, Vprodtarjeta, vNumTarj, vLimTar, vStatTjt
			FROM
				bdicheq:"informix".sc_tarjeta AS sc_tjt
			WHERE sc_tjt.empresa = pEmpresa 
			  AND sc_tjt.cuenta = pNumeroCuenta
			  AND sc_tjt.numcte = vNumCte
			  --AND sc_tjt.tipo_tarjeta = 'A'
			  --AND sc_tjt.status_tar = 'A' 
			  AND sc_tjt.status_tar IN ('A','C')
			  AND sc_tjt.secuencia = (
					SELECT MAX(secuencia) 
					  FROM bdicheq:sc_tarjeta 
					 WHERE sc_tjt.empresa = empresa 
					   AND sc_tjt.cuenta = cuenta 
					   AND sc_tjt.numcte = numcte );
					   --AND sc_tjt.tipo_tarjeta = 'A');

			IF vNumTarj IS NULL THEN
				LET vNumTarj = "Sin tarjeta";
				LET vLimTar = 0;
				LET vStatTjt = "";
			END IF

			

          --  LET vFechaNac= vFechaNac;
           -- LET vFechaNac = YEAR(vFechaNac) || '-' || LPAD ( MONTH(vFechaNac-2), 2, '0') || '-' || LPAD ( DAY (vFechaNac-2), 2, '0');
			LET vCantReg = vCantReg + 1;
			LET vCont = vCont +1;
			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
					Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco WITH RESUME;
		END FOREACH;

		-- Si no cuenta con algun registro de firmante inserta el registro del cliente
		IF vCont = '0' THEN
			
			select sc_mcq.cuenta, si_clt.numcte INTO vCuenta,vNumcte from bdinteg:si_cliente si_clt 
			inner join bdicheq:sc_maechq sc_mcq on si_clt.numcte = sc_mcq.num_cte where sc_mcq.cuenta = pNumeroCuenta;

            INSERT INTO bdicheq:"informix".sc_firmantes
            VALUES ('001',vCuenta,'1',vNumcte,vApellidos,vNombre,'A','A',vCombinacion,vParentesco);
            --VALUES (vEmpresa,vCuenta,vSecuencia,vNumcte,vApellidos,vNombre,vReg_firma,vTipo_firma,vCombinacion,vParentesco);


	            FOREACH
			
					SELECT DISTINCT si_cte.numcte, 
						si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 
						sc_fir.secuencia As tipo_cliente, si_pf.fecha_nac, sc_mcq.producto, sc_fir.parentesco
					INTO
		                
						vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vTipoCte, vFechaNac, vProductoCuenta, vParentesco
					FROM
						bdicheq:"informix".sc_maechq sc_mcq,
						bdicheq:"informix".sc_firmantes AS sc_fir,
						bdinteg:"informix".si_cliente AS si_cte,
						bdinteg:"informix".si_ctepf AS si_pf
					WHERE sc_fir.empresa =  pEmpresa 
					  AND sc_fir.cuenta =  pNumeroCuenta 
					  -- AND sc_fir.numcte != pNumeroCliente 
					  AND sc_fir.numcte = si_cte.numcte 
					  AND si_cte.empresa = pEmpresa 
					  AND sc_fir.numcte = si_pf.numcte
					  AND sc_mcq.empresa = pEmpresa 
					  AND sc_mcq.cuenta = pNumeroCuenta
					  ORDER BY sc_fir.secuencia ASC


					IF vTipoCte = '1' THEN
						LET vTipoCte = 'Titular';
					ELSE
						LET vTipoCte = 'Firmante';
						
					END IF;

					-- OBTENER LA TARJETA DEL FIRMANTE --

					SELECT DISTINCT sc_tjt.expiracion, sc_tjt.prodtarjeta, sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
					INTO
						Vexpiracion, Vprodtarjeta, vNumTarj, vLimTar, vStatTjt
					FROM
						bdicheq:"informix".sc_tarjeta AS sc_tjt
					WHERE sc_tjt.empresa = pEmpresa 
					  AND sc_tjt.cuenta = pNumeroCuenta
					  AND sc_tjt.numcte = vNumCte
					  --AND sc_tjt.tipo_tarjeta = 'A'
					  --AND sc_tjt.status_tar = 'A' 
					  AND sc_tjt.status_tar IN ('A','C')
					  AND sc_tjt.secuencia = (
							SELECT MAX(secuencia) 
							  FROM bdicheq:sc_tarjeta 
							 WHERE sc_tjt.empresa = empresa 
							   AND sc_tjt.cuenta = cuenta 
							   AND sc_tjt.numcte = numcte );
							   --AND sc_tjt.tipo_tarjeta = 'A');

					IF vNumTarj IS NULL THEN
						LET vNumTarj = "Sin tarjeta";
						LET vLimTar = 0;
						LET vStatTjt = "";
					END IF

					

		           --LET vFechaNac= vFechaNac;
		           --LET vFechaNac = YEAR(vFechaNac) || '-' || LPAD ( MONTH(vFechaNac-2), 2, '0') || '-' || LPAD ( DAY (vFechaNac-2), 2, '0');
					LET vCantReg = vCantReg + 1;
					
					RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
							Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco WITH RESUME;
			    END FOREACH;


		END IF;

		IF vCantReg = 0 THEN
			LET vCodRet  	 = "000";
			LET vNumCte  	 = "";
			LET vApePat  	 = "";
			LET vApeMat  	 = "";
			LET vNombre1 	 = "";
			LET vNombre2 	 = "";
			LET vRFC     	 = "";
			LET vNumTarj 	 = "";
			LET Vexpiracion  = "";
			LET Vprodtarjeta = "";
			LET vLimTar  	 = 0;
			LET vStatTjt 	 = "";
			LET vTipoCte 	 = "";
			LET vFechaNac 	 = "";
			LET vParentesco	 = "";
           -- LET vFechaNac=vFechaNac2;
            LET vFechaNac = YEAR(vFechaNac) || '-' || LPAD ( MONTH(vFechaNac-2), 2, '0') || '-' || LPAD ( DAY (vFechaNac-2), 2, '0');
			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
					Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco;
		
		END IF;
	
	END 
	
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se agrega filtro para obtener datos de tajertas Activas y canceladas',
'EJECUTADO O LLAMADO POR: AperTP.exe',
'AUTOR : Scarlett Mendoza',
'FECHA : 17/10/2017',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".gen_archsdos_mes() 
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
     
    DEFINE vcodret1         char(5);
    DEFINE vcodret2         char(5);
    DEFINE vcodret3         char(50);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;
    DEFINE desc_err         char(50);
    DEFINE vcontador1       integer;
    DEFINE vcontador2       integer;
    DEFINE ven_transacc     smallint;
    DEFINE vcomienza        smallint;
    DEFINE vsql             char(600);
    DEFINE vstmt            char(300);
    DEFINE vempresa         char(3);
    DEFINE vproceso         char(20);
    DEFINE vsistema         char(2);
    DEFINE vusuario         char(8);
    DEFINE vfecha_hoy       date;
    DEFINE vpri_dia_mes     date; 
    DEFINE vult_dia_mes_ant date;
    DEFINE vdia_fin_mes_ant char(2);
    DEFINE vmes             char(2);
    DEFINE vanio            char(4);
    DEFINE vaniomes         char(6);
    DEFINE vexiste          smallint;
    DEFINE vexistefin       smallint;
    DEFINE vcuentafin       char(20);
    DEFINE vcuenta          char(20);
    DEFINE vsucursal        char(4);
    DEFINE vsdo_mes_ant     decimal(14,2);
    DEFINE vint_mes_ant     decimal(14,2);
    DEFINE vcodretmes       char(5);
    DEFINE vcodretrim       char(5);
	
    LET vcodret1         = "000";               
    LET vcodret2         = '000';
    LET vcodret3         = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err          = 0;                   
    LET isam_err         = 0;
    LET desc_err         = '';
    LET vcontador1       = 0;                   
    LET vcontador2       = 0;
    LET ven_transacc     = 0;                   
    LET vcomienza        = -1;  
    LET vsql             = '';                  
    LET vstmt            = '';
    LET vempresa         = '001';
    LET vproceso         = 'sdoschqmes';
    LET vsistema         = '01';
    LET vusuario         = user;
    LET vfecha_hoy       = '';
    LET vpri_dia_mes     = '';
    LET vult_dia_mes_ant = '';
    LET vdia_fin_mes_ant = '';
    LET vmes             = '';                  
    LET vanio            = '';  
    LET vaniomes         = '';
    LET vexiste          = 0;                   
    LET vexistefin       = 0;       
    LET vcuentafin       = '';
    LET vcuenta          = '';                  
    LET vsucursal        = '';
    LET vsdo_mes_ant     = 0.00;
    LET vint_mes_ant     = 0.00;
    LET vcodretmes       = '';
    LET vcodretrim       = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_mes.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'C'||''','||
                       'codret        = '''||vcodret1||''','||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||vempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosmes.sql';
            SYSTEM vsql;
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosmes.sql';
            SYSTEM vstmt;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/gen_archsdos_mes.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy, pri_dia_mes
      INTO vfecha_hoy, vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = vempresa;
     
    LET vult_dia_mes_ant = vpri_dia_mes - 1 UNITS DAY;
    LET vdia_fin_mes_ant = LPAD(DAY(vult_dia_mes_ant), 2, '0');
    LET vanio = YEAR(vult_dia_mes_ant);
    LET vmes = LPAD(MONTH(vult_dia_mes_ant), 2, '0');
    LET vaniomes = vanio||vmes;
     	
    SELECT count(*)
      INTO vexiste
      FROM bdinteg:sx_contproc
     WHERE empresa = vempresa
       AND proceso = vproceso
       AND fecha   = vfecha_hoy
       AND sistema = vsistema;

    IF vexiste = 0 THEN
        LET vsql = 'echo "INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||vempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||vusuario||''', '||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horassdosmes.sql';
        SYSTEM vsql;
        
        LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosmes.sql';
        SYSTEM vstmt;
    ELSE
        SELECT count(*)
          INTO vexistefin
          FROM bdinteg:sx_contproc
         WHERE empresa     = vempresa
           AND proceso     = vproceso
           AND fecha       = vfecha_hoy
           AND sistema     = vsistema
           AND status_proc = "F";

        IF vexistefin = 0 THEN
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||vusuario||''','||
                       'status_proc   = '''||'I'||''','||
                       'codret        = '''||' '||''','||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||vempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horassdosmes.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosmes.sql';
            SYSTEM vstmt;
        ELSE
            LET vcodret1 = "958";
            LET vcodret2 = "958";
            
            SELECT descripcion
              INTO vcodret3
              FROM bdinteg:si_codret
             WHERE sistema = vsistema
               AND codigo_retorno = vcodret1;
            
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END IF;
	    
    SELECT valor
      INTO vcuentafin
      FROM sc_param
     WHERE empresa = vempresa
       AND codparam = 'CtaIniActuaSdosComp1';
       
    IF vdia_fin_mes_ant = '28' THEN
        FOREACH WITH HOLD
            SELECT {+INDEX(sc_sdodiarioc isdodiario)}
                   cuenta, sucursal, capvig28, intprovnp28
              INTO vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant
              FROM sc_sdodiarioc
             WHERE cuenta < vcuentafin
               AND aniomes = vaniomes
               AND statuscta28 IN('1','3','4','5','6','8')
               AND cuenta NOT LIKE '11%'
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET ven_transacc = 1; 
            END IF;
               
            CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant, vanio, vmes) 
            RETURNING vcodretmes;
            
            IF vmes = '03' OR  vmes ='06' OR  vmes ='09' OR vmes = '12' THEN
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodretrim;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
        END FOREACH;
    ELIF vdia_fin_mes_ant = '29' THEN
        FOREACH WITH HOLD
            SELECT {+INDEX(sc_sdodiarioc isdodiario)}
                   cuenta, sucursal, capvig29, intprovnp29
              INTO vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant
              FROM sc_sdodiarioc
             WHERE cuenta < vcuentafin
               AND aniomes = vaniomes
               AND statuscta29 IN('1','3','4','5','6','8')
               AND cuenta NOT LIKE '11%'
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET ven_transacc = 1; 
            END IF;
               
            CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant, vanio, vmes) 
            RETURNING vcodretmes;
            
            IF vmes = '03' OR  vmes ='06' OR  vmes ='09' OR vmes = '12' THEN
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodretrim;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
        END FOREACH;
    ELIF vdia_fin_mes_ant = '30' THEN
        FOREACH WITH HOLD
            SELECT {+INDEX(sc_sdodiarioc isdodiario)}
                   cuenta, sucursal, capvig30, intprovnp30
              INTO vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant
              FROM sc_sdodiarioc
             WHERE cuenta < vcuentafin
               AND aniomes = vaniomes
               AND statuscta30 IN('1','3','4','5','6','8')
               AND cuenta NOT LIKE '11%'
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET ven_transacc = 1; 
            END IF;
               
            CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant, vanio, vmes) 
            RETURNING vcodretmes;
            
            IF vmes = '03' OR  vmes ='06' OR  vmes ='09' OR vmes = '12' THEN
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodretrim;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
        END FOREACH;
    ELIF vdia_fin_mes_ant = '31' THEN
        FOREACH WITH HOLD
            SELECT {+INDEX(sc_sdodiarioc isdodiario)}
                   cuenta, sucursal, capvig31, intprovnp31
              INTO vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant
              FROM sc_sdodiarioc
             WHERE cuenta < vcuentafin
               AND aniomes = vaniomes
               AND statuscta31 IN('1','3','4','5','6','8')
               AND cuenta NOT LIKE '11%'
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET ven_transacc = 1; 
            END IF;
               
            CALL sp_actsdomensualc(vcuenta, vsucursal, vsdo_mes_ant, vint_mes_ant, vanio, vmes) 
            RETURNING vcodretmes;
            
            IF vmes = '03' OR  vmes ='06' OR  vmes ='09' OR vmes = '12' THEN
                CALL sp_actsdotrimestralc(vcuenta, vsucursal, vanio, vmes)
                RETURNING vcodretrim;
            END IF;
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;

            IF (vcontador2 >= 1000) THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
        END FOREACH;
    END IF;
            
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||vusuario||''','||
               'status_proc   = '''||'F'||''','||
               'codret        = '''||vcodret1||''','||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||vempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horassdosmes.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horassdosmes.sql';
    SYSTEM vstmt;
    
	END;
	
	   RETURN vcodret1, vcodret2, vcodret3, vcontador1;
    
END PROCEDURE;