CREATE PROCEDURE "informix".sp_portanom_consultacancelaciones(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaRegistro DATE, pCodigoOperacion INTEGER, pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(20) AS numero_cliente,
				CHAR(30) AS folio,
				CHAR(20) AS banco_ordenante,
				CHAR(30) AS estatus_respuesta,
				INTEGER AS no_registro,
				INTEGER AS total_registros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iNoRegistrosTmp INTEGER;
	DEFINE cNumeroCliente CHAR(20);
	DEFINE cFolio CHAR(30);
	DEFINE cBancoOrdenante CHAR(20);
	DEFINE cEstatusRespuesta CHAR(30);
	DEFINE iNoRegistro INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNoRegistros = 0;
	LET iNoRegistrosTmp = 0;
	LET cNumeroCliente = '';
	LET cFolio = '';
	LET cBancoOrdenante = '';
	LET cEstatusRespuesta = '';
	LET iNoRegistro = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumeroCliente, cFolio, cBancoOrdenante, cEstatusRespuesta, iNoRegistro, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_portanom_consultacancelaciones.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaRegistro IS NULL OR pCodigoOperacion IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumeroCliente, cFolio, cBancoOrdenante, cEstatusRespuesta, iNoRegistro, iNoRegistros;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumeroCliente, cFolio, cBancoOrdenante, cEstatusRespuesta, iNoRegistro, iNoRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumeroCliente, cFolio, cBancoOrdenante, cEstatusRespuesta, iNoRegistro, iNoRegistros;
		END IF;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT {+INDEX ("informix".sc_portacec_archivotemp_cancelaciones idx_serial)} SKIP pRegistros FIRST pRecuperacion folio_cancelacion, numcte, nombre_bco_ordenante
			INTO cFolio, cNumeroCliente, cBancoOrdenante
			FROM "informix".sc_portacec_archivotemp_cancelaciones
			
			LET iNoRegistrosTmp = iNoRegistrosTmp + 1;
			
			RETURN cCodRet, cNumeroCliente, cFolio, cBancoOrdenante, cEstatusRespuesta, iNoRegistrosTmp, iNoRegistrosTmp WITH RESUME;
		
		END FOREACH;
		
		IF iNoRegistrosTmp = 0 AND pRegistros = 0 THEN
			LET cCodRet = '01030';
			RETURN cCodRet, cNumeroCliente, cFolio, cBancoOrdenante, cEstatusRespuesta, iNoRegistro, iNoRegistros;
		ELIF iNoRegistrosTmp = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumeroCliente, cFolio, cBancoOrdenante, cEstatusRespuesta, iNoRegistro, iNoRegistros;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 25/10/2016',
'MODULO: Operaciones',
'FUNCIONALIDAD: Portabilidad de nÃÂ³mina - Solicitudes, Cancelaciones',
'DESCRIPCION: Consulta las solicitudes de portabilidad generadas en BanCoppel',
'AUTOR: Rodolfo Conde Flores',
'FECHA: 03/12/2019',
'DESCRIPCION: Se modifica SPL para optimizar consulta de datos a grid, se reemplaza la ejecuciÃÂ³n de SPL por consulta directa a tabla temporal',
'BD: bdicheq';

create procedure "informix".calc_isr( pempresa      char(3),
									  pcuenta       char(20),
									  pfecha_hoy    date,
									  ptasa_base    decimal(9,6),
									  pinteres      money(14,2),
									  psdo_promedio money(14,2),
									  pdias_pos     integer,
									  pfisica       char(1) )
returning char(5), money(14,2);

	define vcodret 			char(5);
    define vcodret2			char(5);
    define vcodret3			char(50);
    define vsql_err 		integer;
    define visam_err 		integer;
    define vdesc_err 		char(50);
	define vsecuencia 		char(6);
	define vtasa_isr 		decimal(9,6);
	define vrend_gravable	money(14,2);
	define vrend_exento		money(14,2);
	define vimp_isr			money(14,2);
	define vrend_neto		money(14,2);
	define vbase_exenta		money(14,2);
	define vbase_gravable 	money(14,2);
	define vsmdf 			money(10,2);
	define vnumsmdf 		smallint;
	define vanio 			integer;
	define vresiduo 		integer;
	define vaniobase 		integer;
	define vtasa_isr_tr 	decimal(9,6);
    
	--- set debug file to "/resplogifx/conciliachq/calc_isr.out";
	--- trace on;

	let vcodret        = '000';
    let vcodret2       = '';
    let vcodret3       = '';
    let vsql_err       = 0;
    let visam_err      = 0;
    let vdesc_err      = '';
    let vsecuencia     = '';
    let vtasa_isr      = 0;
	let vrend_gravable = 0;
	let vrend_exento   = 0;
	let vimp_isr       = 0;
	let vrend_neto     = 0;
    let vbase_exenta   = 0;
    let vbase_gravable = 0;
    let vsmdf          = 0;
    let vnumsmdf       = 0;
    let vanio          = 0;
    let vresiduo       = 0;
	let vaniobase      = 0;
    let vtasa_isr_tr   = 0;

	begin
	
	on exception set vsql_err, visam_err, vdesc_err
        set debug file to "/resplogifx/conciliachq/calc_isr.err";
        trace on;
		if vsql_err <> 0 then
			let vcodret  = vsql_err;
            let vcodret2 = visam_err;
            let vcodret3 = vdesc_err;
			return vcodret, vimp_isr;
		end if;
	end exception;

	let vsecuencia = year(pfecha_hoy)||lpad(month(pfecha_hoy),2,"0");
	let vanio = year(pfecha_hoy);
	let vresiduo = mod(vanio, 4);
   
	if vresiduo = 0 then
		let vaniobase = 366;
    else
        let vaniobase = 365;
	end if;

    set isolation to dirty read;
    set lock mode to wait 2;

	/* ##################################################
	select valor 
	  into vsmdf
      from sc_param
     where empresa = pempresa and codparam = "smdf";

    select valor 
	  into vnumsmdf
      from sc_param
     where empresa = pempresa and codparam = "numsmdf";

    let vbase_exenta = vsmdf * vaniobase * vnumsmdf;
    ################################################## */
   
	select valor 
	  into vbase_exenta
      from sc_param
	 where empresa = pempresa 
	   and codparam = "baseexenta"; 

	if vbase_exenta is null then
		let vbase_exenta = 0;
	end if;

	select valor 
      into vtasa_isr
      from bdinteg:si_fechavalor
     where empresa = pempresa 
	   and tasa = "I.S.R." 
	   and fecha in( select max(fecha) 
	                   from bdinteg:si_fechavalor
                      where empresa = pempresa 
		 			    and tasa = "I.S.R." );

    let vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobase ), 6 ); 
   
	if pfisica = "F" then
        let vbase_gravable = psdo_promedio - vbase_exenta;
        
		if vbase_gravable > 0 then
			let vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 );
		else
			let vimp_isr = 0;
		end if
	else
		let vimp_isr = trunc( ( psdo_promedio * vtasa_isr_tr ), 2 );
	end if;
	
	IF vimp_isr > pinteres THEN
	   LET vimp_isr = pinteres;
	END IF;
      
    --- let vrend_neto = psdo_promedio - vimp_isr;
	let vrend_neto = pinteres - vimp_isr;

	IF vimp_isr > 0 THEN
	   insert into sc_isr values( pempresa, pcuenta, vsecuencia, psdo_promedio, ptasa_base, pdias_pos,
				                  pinteres, vrend_gravable, vrend_exento, vimp_isr, vrend_neto, vtasa_isr);
	END IF
	
	return vcodret, vimp_isr;
	
	end;
	
end procedure 

document "Version 1.00.001";

create procedure "informix".calc_isr_proy( pempresa      char(3),
                                           pcuenta       char(20),
                                           pfecha_hoy    date,
                                           ptasa_base    decimal(9,6),
                                           pinteres      money(14,2),
                                           psdo_promedio money(14,2),
                                           pdias_pos     integer,
                                           pfisica       char(1) )
returning char(5), money(14,2), decimal(9,6);
    
    define vcodret          char(5);
    define vcodret2			char(5);
    define vcodret3			char(50);
    define vsql_err         integer;
    define visam_err 		integer;
    define vdesc_err 		char(50);
    define vsecuencia       char(6);
    define vtasa_isr        decimal(9,6);
    define vrend_gravable   money(14,2);
    define vrend_exento     money(14,2);
    define vimp_isr         money(14,2);
    define vrend_neto       money(14,2);
    define vbase_exenta     money(14,2);
    define vbase_gravable   money(14,2);
    define vsmdf            money(10,2);
    define vnumsmdf         smallint;
    define vanio            integer;
    define vresiduo         integer;
    define vaniobase        integer;
    define vtasa_isr_tr 	decimal(9,6);
    
    --- set debug file to "calcisr_proy.out";
    --- trace on;
    
    let vcodret        = '000';
    let vcodret2       = '';
    let vcodret3       = '';
    let vsql_err       = 0;
    let visam_err      = 0;
    let vdesc_err      = '';
    let vsecuencia     = '';
    let vtasa_isr      = 0;
    let vrend_gravable = 0;
    let vrend_exento   = 0;
    let vimp_isr       = 0;
    let vrend_neto     = 0;
    let vbase_exenta   = 0;
    let vbase_gravable = 0;
    let vsmdf          = 0;
    let vnumsmdf       = 0;
    let vanio          = 0;
    let vresiduo       = 0;
    let vaniobase      = 0;
    let vtasa_isr_tr   = 0;
    
    begin
    
    on exception set vsql_err, visam_err, vdesc_err
        if vsql_err <> 0 then
            let vcodret = vsql_err;
            let vcodret2 = visam_err;
            let vcodret3 = vdesc_err;
            return vcodret, vimp_isr, vtasa_isr;
        end if;
    end exception;
    
    let vsecuencia = year(pfecha_hoy)||lpad(month(pfecha_hoy),2,"0");
    let vanio = year(pfecha_hoy);
    let vresiduo = mod(vanio, 4);
    
    if vresiduo = 0 then
        let vaniobase = 366;
    else
        let vaniobase = 365;
    end if
    
    /* ################################################
    --- diciembre/2017  
    select valor 
      into vsmdf
      from sc_param
     where empresa = pempresa 
       and codparam = "smdf";
    
    select valor 
      into vnumsmdf
      from sc_param
     where empresa = pempresa 
       and codparam = "numsmdf";
    
    let vbase_exenta = vsmdf * vaniobase * vnumsmdf;
    ################################################ */
    
    select valor 
      into vbase_exenta
      from sc_param
     where empresa = pempresa 
       and codparam = "baseexenta"; 
    
    if vbase_exenta is null then
        let vbase_exenta = 0;
    end if
    
    select valor 
      into vtasa_isr
      from bdinteg:si_fechavalor
     where empresa = pempresa 
       and tasa = "I.S.R." 
       and fecha in( select max(fecha) 
                       from bdinteg:si_fechavalor
                      where empresa = pempresa 
                        and tasa = "I.S.R." );
    
    let vbase_gravable = psdo_promedio - vbase_exenta;
    
    if vbase_gravable > 0 then
        let vtasa_isr_tr = trunc( ( ( ( vtasa_isr / 100 ) * pdias_pos ) / vaniobase ), 6); 
        let vimp_isr = trunc( ( vbase_gravable * vtasa_isr_tr ), 2 );
    else
        let vimp_isr = 0;
    end if
    
	IF vimp_isr > pinteres THEN
	   LET vimp_isr = pinteres;
	END IF;
	
    --- let vrend_neto = psdo_promedio - vimp_isr;
    let vrend_neto = pinteres - vimp_isr;
    
    return vcodret, vimp_isr, vtasa_isr;
    
    end;
    
end procedure

DOCUMENT
    'Esta funcion se encarga de realizar la proyeccion del cobro por isr que se realizaria a una cta',
    'AUTOR : Antonio Ruiz Mtz ',
    'FECHA : 27/09/2007',
    'VERSION : 1.00.000',
    'BD : bdicheq ';

CREATE PROCEDURE "informix".sp_cifra_archivo_medalia( pCodigo CHAR(20) ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3	        CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr	        CHAR(150);
    DEFINE vUsuario         CHAR(20);
    DEFINE vLLave           CHAR(200);
    DEFINE vNomarch         CHAR(100);
    DEFINE vRutaOrigen      CHAR(100);
    DEFINE vRutaDestino     CHAR(100);
    DEFINE vNomarchSalida   CHAR(100);
    DEFINE vRutaOriginales  CHAR(100);
    DEFINE vNomarch_salida  CHAR(100);
    
    
    LET cCodRet         = '';
    LET cCodRet2        = 0;
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = '';
    LET vUsuario        = '';
    LET vLLave          = '';
    LET vNomarch        = '';
    LET vRutaOrigen     = '';
    LET vRutaDestino    = '';
    LET vNomarchSalida  = '';
    LET vRutaOriginales = '';
    LET vNomarch_salida = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_medalia.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cifra_archivo_masttro.out";
    --- TRACE ON;
    
    FOREACH
        SELECT TRIM(usuario), TRIM(llave), TRIM(nomarch), TRIM(ruta_origen), TRIM(nomarch_salida), TRIM(ruta_destino), TRIM(ruta_originales)
          INTO vUsuario, vLLave, vNomarch, vRutaOrigen, vNomarch_salida, vRutaDestino, vRutaOriginales    
          FROM bdinteg:si_configura_pgp_chq
         WHERE codigo = pCodigo
         ORDER BY secuencia
        
        IF vUsuario <> user THEN
            LET cCodRet = '200';
            RETURN cCodRet;
        END IF;
        
        SYSTEM 'echo "export PATH=/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/'||TRIM(vUsuario)||'/bin:/usr/bin/X11:/sbin:.:/opt/pgp/bin:/informix/bin" > '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        SYSTEM 'echo "export HOME=/home/'||TRIM(vUsuario)||'" >> '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        
        SYSTEM 'echo "/opt/pgp/bin/pgp --encrypt -i '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' -r '||''''||TRIM(vLLave)||''''||' '||TRIM(vRutaDestino)||TRIM(vNomarch_salida)||'" >> '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        
        SYSTEM '/usr/bin/chmod 777 '||TRIM(vRutaOrigen)||'blinda_medalia.sh';   
        SYSTEM '/usr/bin/sh '||TRIM(vRutaOrigen)||'blinda_medalia.sh';
        
        SYSTEM '/usr/bin/mv '||TRIM(vRutaOrigen)||TRIM(vNomarch)||' '||vRutaOriginales; 
        SYSTEM '/usr/bin/mv '||TRIM(vRutaOriginales)||TRIM(vNomarch)||'pgp'||' '||vRutaDestino; 
    END FOREACH;
    
    LET cCodRet = '00000';
    
    RETURN cCodRet;
    
    END;
    
END PROCEDURE;