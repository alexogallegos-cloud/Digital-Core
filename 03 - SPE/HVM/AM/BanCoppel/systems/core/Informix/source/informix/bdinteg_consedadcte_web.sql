CREATE PROCEDURE "informix".consedadcte_web(p_empresa     char(3),
                             p_numcte      char(20))
   RETURNING CHAR(5), CHAR(104), smallint;

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_numcte            CHAR(20);
   DEFINE v_nomcte            CHAR(104);

   DEFINE v_ano_cte           SMALLINT;
   DEFINE v_edad	          SMALLINT;
   DEFINE v_fecha_hoy         DATE; 


	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cod_ret = sql_err;
		RETURN  cod_ret,v_nomcte, v_edad;
	END EXCEPTION;


	LET cod_ret = '00000';
	LET p_mensaje = "Operacion Realizada Exitosamente";


	LET v_numcte = '';
	LET v_nomcte = '';
	LET v_ano_cte =0;
	LET v_edad = 0;
	LEt v_fecha_hoy = date(1);

	select fecha_hoy
	into v_fecha_hoy
	from bdinteg:si_fechas;

	SELECT NVL(trim(cli.apell_paterno),' ') || ' ' ||
          NVL(trim(cli.apell_materno),' ') || ' ' ||
          NVL(trim(cli.nombre1),' ') || ' ' ||
          NVL(trim(cli.nombre2),' ') nomcte,
		 case when month(fecha_nac) < month(v_fecha_hoy)
				then year(v_fecha_hoy) - year(fecha_nac)
				else case when month(fecha_nac) = month(v_fecha_hoy) and day(fecha_nac) <= day(v_fecha_hoy) 
					then year(v_fecha_hoy) - year(fecha_nac)
					else year(v_fecha_hoy) - year(fecha_nac) - 1 
     			end  
		 end edad
	INTO v_nomcte,v_edad
	FROM si_cliente cli,
          si_ctepf pf
    WHERE cli.empresa = p_empresa and
          pf.numcte = cli.numcte  AND
          cli.numcte =p_numcte;

    if v_nomcte is null then
		let cod_ret = "00104";
		RETURN  cod_ret,v_nomcte, v_edad;
    end if

    RETURN  cod_ret,v_nomcte, v_edad;

END PROCEDURE

DOCUMENT
'SPL Extrae la Edad del Cliente',
"MODIFICO : Victor Luna",
"FECHA : 12/Febrero/2007",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"MODIFICO : ",
"FECHA : 30/Marzo/2012",
"BD    : bdinteg",
"VER   : 1.2";

CREATE PROCEDURE "informix".constipydircliente_web(pEmpresa CHAR(3), pRFC CHAR(13), pOpcion INTEGER, cNumCliente CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
    CHAR(20); --Numero de Cliente

	--DEFINICION DE VARIABLES--
	DEFINE cCodRet		CHAR(5);
    DEFINE cTipCte      CHAR(1);
    DEFINE cDirExi      CHAR(1);
    DEFINE cNumCte      CHAR(20);
    DEFINE iSqlErr		INTEGER;
    
    LET iSqlErr         = 0;
    LET cNumCte         = "";
BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNumCte;
        END IF;
	END EXCEPTION;
    --Valida Direccion de los Beneficiarios
    IF pOpcion = 1 THEN
        IF cNumCliente = "" THEN
            SELECT numcte, tipo_cliente INTO cNumCte, cTipCte FROM bdinteg:si_cliente WHERE rfc = pRFC;
        ELSE
            SELECT tipo_cliente INTO cTipCte FROM bdinteg:si_cliente WHERE numcte = cNumCliente;
            LET cNumCte = cNumCliente;
        END IF
        SELECT NVL(COUNT(*),"0") INTO cDirExi FROM bdinteg:si_direcciones WHERE numcte = cNumCte;
        
        IF (cTipCte = "1") AND (cDirExi <> "0") OR (cTipCte = "2") AND (cDirExi <> "0") THEN 
            LET cCodRet = "00000";
            RETURN cCodRet, cNumCte;
        ELSE
            IF cTipCte = 1 THEN
                LET cCodRet = "00001";
                RETURN cCodRet, cNumCte;
            ELSE
                LET cCodRet = "00002";
                RETURN cCodRet, cNumCte;
            END IF; 
        END IF;
    ELSE --Obiene Numero del Cliente
        SELECT numcte INTO cNumCte FROM bdinteg:si_cliente WHERE rfc = pRFC;
        LET cCodRet = "00003";
        RETURN cCodRet, cNumCte;
    END IF
END
END PROCEDURE
DOCUMENT
'Modifico: Adrian Lara',
'Proyecto: BeneficiariosCONDUSEF',
'Solicito: Frank Gaxiola',
'Descripcion: Se crea procedimiento que valida si los clientes tipo 1 o 2 tiene direccion registrada',
'Fecha: 18/08/2010',
'Version: 20100824.1815',
'BD: bdinteg';

CREATE PROCEDURE "informix".consultaguardaconyuge_cjunk_web( cEmpresa CHAR(3),
                                                         cNumSolicitud CHAR(20),
                                                         cNumCte CHAR(20),
                                                         cNumCteConyuge CHAR(20),
                                                         cUsuario CHAR(8),
                                                         cTipoDirCon CHAR(1))
RETURNING char(5);

    DEFINE cCodRet char(5);
    DEFINE iSqlErr INTEGER;

    DEFINE sSucursal CHAR(4);
    DEFINE sApellPaterno CHAR(26);
    DEFINE sApellMaterno CHAR(26);
    DEFINE sNombre1 CHAR(26);
    DEFINE sNombre2 CHAR(26);
    DEFINE sRfc CHAR(13);
    DEFINE dFechaNac DATE;
    DEFINE sCurp CHAR(20);
    DEFINE sSexo CHAR(1);
    DEFINE sEstadoCivil CHAR(2);
    DEFINE sNacionalidad CHAR(3);
    DEFINE sNoFm CHAR(18);
    DEFINE sCodigoIden CHAR(2);
    DEFINE sNumIdenti CHAR(30);
    DEFINE sPersDomicilio CHAR(2);
    DEFINE sEmail CHAR(60);
    DEFINE sParentesco CHAR(2);
    DEFINE sApellCasada CHAR(26);
    DEFINE sNumcteRef CHAR(20);

    DEFINE pcalle char(40);
    DEFINE pcolonia char(60);
    DEFINE pmunicipio char(5);
    DEFINE pentre_calles char(40);
    DEFINE ppais char(3);
    DEFINE pentidad char(2);
    DEFINE plocalidad char(3);
    DEFINE pcodpostal char(5);
    DEFINE ptipotel1 char(1);
    DEFINE ptelefono1 char(13);
    DEFINE ptipotel2 char(1);
    DEFINE ptelefono2 char(13);
    DEFINE ptipotel3 char(1);
    DEFINE ptelefono3 char(13);
    DEFINE pextension char(5);
    DEFINE pestado_inegi char(2);
    DEFINE pmunicipio_inegi char(3);
    DEFINE plocalidad_inegi char(4);
    DEFINE pnociudad smallint;
    DEFINE pnoext char(10);
    DEFINE pnoint char(10);
    DEFINE pdepto char(6);
    DEFINE pnocalle integer;
    DEFINE pnocolonia integer;
    DEFINE ppuntocar char(1);
    DEFINE punihabi char(1);
    DEFINE pmanz smallint;
    DEFINE ppotros smallint;
    DEFINE pandador smallint;
    DEFINE petapa smallint;
    DEFINE plote smallint;
    DEFINE pedif smallint;
    DEFINE pentrada smallint;
    DEFINE pobserva char(80);
    DEFINE iSecuencia integer;
    DEFINE pCofeteltel1 char(1);
    DEFINE pCofeteltel2 char(1);
    DEFINE pCofeteltel3 char(1);
    DEFINE pApart_postal char (11);
    DEFINE dFechaHoy DATE;
    DEFINE wBegin CHAR(1);
	
	DEFINE sCodretorno2 char(5);
    
    LET cCodRet = "00000";
	
	LET sCodretorno2 = "00000";
    
	--Set debug file to '/tmp/actualizaguardaconyuge_cjunk.out';
    --trace on;
    
    -----------------------------------------
    --CREADO: Rodolfo Tortolero Varela
    --FECHA: 2011-06-10
    --FUNCIONALIDAD: Guarda la informaciÃ³n del conyuge como referencia agregandole el nÃºmero de solicitud que va relacionado.
    ----------------------------------------

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 10;

    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            ROLLBACK WORK;
            IF (wBegin = "S") THEN
                BEGIN WORK;
            END IF;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    ON EXCEPTION IN (-535)
        LET wBegin = "S";
        COMMIT WORK;
        BEGIN WORK;
    END EXCEPTION WITH RESUME;

    IF EXISTS( SELECT 1 
                 FROM "informix".si_refclientes a, 
                      "informix".si_refdirecciones b
                WHERE a.empresa = cEmpresa
                  AND a.num_solicitud = cNumSolicitud
                  AND a.numcte = cNumcte
                  AND a.numcte = b.numcte
                  AND a.secuencia = b.secuencia
                  --AND a.numcte_banco = cNumCteConyuge
                  AND a.parentesco = 'E') THEN
        
        --BEGIN WORK;
        EXECUTE PROCEDURE "informix".actualizaguardaconyuge_cjunk( cEmpresa, cNumSolicitud , cNumCte , cNumCteConyuge , cUsuario , cTipoDirCon) INTO sCodretorno2;
		--COMMIT WORK;
        
        LET cCodRet = "00001";        
        
    ELSE
        
        LET wBegin = "N";
        
        begin work;

        update "informix".si_param 
           set valor = cast(valor as integer) + 1 
         where empresa = cEmpresa 
           and cod_param = 121;
           
        SELECT cast(valor as integer) 
          INTO iSecuencia 
          FROM "informix".si_param 
         where empresa = cEmpresa 
           and cod_param = 121;

        commit work;

        if wBegin = 'S' THEN
            begin work;
        end if;

        --- SELECT MAX(secuencia) +1 INTO iSecuencia FROM si_refclientes;
        
        SELECT fecha_hoy 
          INTO dFechaHoy 
          FROM "informix".si_fechas;

        SELECT a.sucursal, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, a.rfc, a.string2, b.fecha_nac, b.curp, 
               b.sexo, b.estado_civil, b.nacionalidad, b.no_fm3, b.codidentifi, b.numidentifi, a.apell_casada, a.numcte_ref 
          INTO sSucursal, sApellPaterno, sApellMaterno, sNombre1, sNombre2, sRfc, sPersDomicilio, dFechaNac, sCurp, 
               sSexo, sEstadoCivil, sNacionalidad, sNoFm, sCodigoIden, sNumIdenti, sApellCasada, sNumcteRef
          FROM "informix".si_cliente a, 
               "informix".si_ctepf b
         WHERE a.numcte = b.numcte
           AND a.numcte = cNumCteConyuge;
           
        SELECT correo_elec
          INTO sEmail
          FROM "informix".si_correos
         WHERE numcte = cNumCteConyuge
           AND tipo_correo = 1
           AND status_correo = 'A';

        INSERT INTO "informix".si_refclientes 
        ( empresa, num_solicitud, numcte, sucursal, secuencia, apell_paterno, apell_materno, 
          nombre1, nombre2, rfc, fecha_nac, curp, sexo, estado_civil, nacionalidad, no_fm3, codidentifi, numidentifi, pers_domicilio, 
          email, parentesco, apellido_cas, numcte_ref, numcte_banco, user_insert, fecha_insert )
        VALUES 
        ( cEmpresa, cNumSolicitud, cNumCte, sSucursal, iSecuencia, sApellPaterno, sApellMaterno, sNombre1, sNombre2,
          sRfc, dFechaNac, sCurp, sSexo, sEstadoCivil, sNacionalidad, sNoFm, sCodigoIden, sNumIdenti, sPersDomicilio, 
          sEmail, 'E', sApellCasada, sNumcteRef, cNumCteConyuge, cUsuario, dFechaHoy );
        
        SELECT dir.calle, dir.colonia, dir.entre_calles, dir.pais, dir.estado, dir.ciudad, dir.municipio, dir.cod_postal, dir.apart_postal, 
               tel1.tipo_tel, tel1.telefono, tel2.tipo_tel, tel2.telefono, tel3.tipo_tel, tel3.telefono, tel3.extension, 
               dir.estado_inegi, dir.localidad_inegi, dir.numerociudad, dir.numeroextcalle, dir.numerointcalle, dir.departamento, 
               dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac, dir.manzana, dir.otros, dir.andador,
               dir.etapa, dir.lote, dir.edificio, dir.entrada, dir.observaciones, dir.ind_cofeteltel1, dir.ind_cofeteltel2, dir.ind_cofeteltel3
          INTO pcalle, pcolonia, pentre_calles, ppais, pentidad, plocalidad, pmunicipio, pcodpostal,  pApart_postal, ptipotel1, ptelefono1,
               ptipotel2, ptelefono2, ptipotel3, ptelefono3, pextension, pestado_inegi, plocalidad_inegi, pnociudad, pnoext, 
               pnoint, pdepto, pnocalle, pnocolonia, ppuntocar, punihabi, pmanz, ppotros, pandador, 
               petapa, plote, pedif, pentrada, pobserva, pCofeteltel1, pCofeteltel2, pCofeteltel3
          FROM "informix".si_direcciones_actual dir
          LEFT OUTER JOIN "informix".si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
          LEFT OUTER JOIN "informix".si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
          LEFT OUTER JOIN "informix".si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
         WHERE dir.numcte = cNumCteConyuge
          -- AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = cNumCteConyuge);
           --AND dir.tipo_dir = '1';
           AND dir.tipo_dir = cTipoDirCon;
         
        IF cTipoDirCon = '1' THEN
            LET ptipotel3 = '';
            LET ptelefono3 = '';
            LET pextension = '';
        ELSE
            LET ptipotel1 = '';
            LET ptelefono1 = '';
            LET ptipotel2 = '';
            LET ptelefono2 = '';
        END IF;
        
        INSERT INTO "informix".si_refdirecciones
        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, 
          municipio, cod_postal, apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, 
          estado_inegi, municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, 
          numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, 
          numcte_banco, user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3 )
        VALUES 
          ( cNumCte, iSecuencia, cTipoDirCon, pcalle, pcolonia, pentre_calles, ppais, pentidad, plocalidad, 
          pmunicipio, pcodpostal, pApart_postal, ptipotel1, ptelefono1, ptipotel2, ptelefono2, ptipotel3, ptelefono3, pextension, 
          pestado_inegi, '', plocalidad_inegi, pnociudad, pnoext, pnoint, pdepto, pnocalle, 
          pnocolonia, ppuntocar, punihabi, pmanz, ppotros, pandador, petapa, plote, pedif, pentrada, pobserva, 
          cNumCteConyuge, cUsuario, dFechaHoy, pCofeteltel1, pCofeteltel2, pCofeteltel3 );
          --( cNumCte, iSecuencia, '1', pcalle, pcolonia, pentre_calles, ppais, pentidad, plocalidad,         
    END IF;
    
    RETURN cCodRet;

    END;
    
END PROCEDURE
DOCUMENT
'DOCUMENTACION:',
' ModificaciÃ³n : Rodolfo Tortolero Varela',
'        Fecha : 19/06/2013',
'Funcionalidad : Se agrega parametro de entrada para identificar el tipo de direcciÃ³n(Casa o Trabajo) del cliente conyuge.';

CREATE PROCEDURE "informix".sp_actualiza_contadores_ivr_web(pEmpresa CHAR(3), pNumCte CHAR(20), pNumTel CHAR(13), pOpcion CHAR(1))

	RETURNING	CHAR(5) AS CodRet;
			
	DEFINE 	cCodRet		 CHAR(5);
	DEFINE	iSqlErr	 	 INTEGER;
	DEFINE	iContSMS	 SMALLINT;
	DEFINE	iContLlamada SMALLINT;
	DEFINE	iActSms		 SMALLINT;
	DEFINE	iActRpt		 SMALLINT;
	DEFINE iIntentosMax	 SMALLINT;	DEFINE iIntentos	 SMALLINT;
	LET	cCodRet		 = '00000';
	LET iSqlErr		 = 0;
	LET iContSMS	 = 0;
	LET iContLlamada = 0;
	LET iActSms 	 = 0;
	LET iActRpt 	 = 0; 
	LET iIntentosMax = 0;
	LET iIntentos	 = 0;

	BEGIN
		
		--CONTROL DE ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/sp_actualiza_contadores_ivr.out';
		--TRACE ON;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDA ERRORES DE LOS PARAMETROS
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pNumTel,'') = '' OR NVL(pOpcion,'') = '' THEN
			LET cCodRet='00001';
		ELSE
			IF pOpcion = 2 THEN
				--DSB-13/06/2016
				--OBTIENE EL NUMERO DE INTENTOS MAX EN LLAMADA
				SELECT CAST(TRIM(valor) AS SMALLINT) INTO iIntentosMax FROM "informix".si_param WHERE cod_param = 389;
				
				SELECT COUNT(numcte) INTO iIntentos FROM "informix".si_bitllamada_ivr 
				WHERE empresa = pEmpresa AND numcte = TRIM(pNumCte) AND numtel = pNumTel 
				AND fecha_insert > CURRENT YEAR TO DAY;
				
				IF iIntentos < iIntentosMax THEN
					UPDATE "informix".si_bit_intentos_ivr
					SET cont_sms = cont_sms + 1, cont_llamada = cont_llamada + 1,fecha_mov = CURRENT
					WHERE empresa = pEmpresa AND numcte = TRIM(pNumCte)
					AND numtel = pNumTel;
				ELSE
					LET cCodRet='00002';
				END IF;
			ELSE
				IF pOpcion = 1 THEN
					LET iActSms = 1;
				ELSE
					LET iActRpt = 1;
				END IF;
				
				IF EXISTS(SELECT numcte FROM "informix".si_bit_intentos_ivr WHERE empresa = pEmpresa AND numcte = TRIM(pNumCte) AND numtel = pNumTel) THEN
					
					UPDATE "informix".si_bit_intentos_ivr
					SET cont_sms = cont_sms + iActSms, cont_rpte = cont_rpte + iActRpt, fecha_mov = CURRENT
					WHERE empresa = pEmpresa AND numcte = pNumCte
					AND numtel = pNumTel;
					
				ELSE
					INSERT INTO "informix".si_bit_intentos_ivr (empresa,numcte,numtel,cont_sms,cont_llamada,fecha_insert,fecha_mov,cont_rpte) VALUES (pEmpresa,TRIM(pNumCte),pNumTel,iActSms,0,CURRENT,CURRENT,iActRpt);
				END IF;
			END IF;
		END IF;
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'AUTOR:	ERNESTO AGUILERA',
'FECHA:	28/DIC/2015',
'DESCRIPCION: Actualizar contadores de sms y llamada',
'BD: BDINTEG',
'MODIFICO:	VICTOR HUGO NUNEZ',
'FECHA:	13/06/2016',
'DESCRIPCION: Se modifica para poder validar la cantidad maxima de llamas a realizar por dia',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_bitacora_actividades_web( pcanal       CHAR(02),
                                                     ptransaccion CHAR(04),
                                                     psucursal    CHAR(04),
                                                     pusuario     CHAR(08),
                                                     pfolio_suc   CHAR(16),
                                                     pctataotro   CHAR(20) )
RETURNING CHAR(5);
    
	DEFINE vcodret1         	CHAR(5);
    DEFINE vcodret2         	CHAR(5);
    DEFINE vcodret3         	CHAR(50);
    DEFINE sql_err          	INTEGER;
    DEFINE isam_err         	INTEGER;
    DEFINE desc_err         	CHAR(50);
    DEFINE vcontador        	INTEGER;
    DEFINE ven_transacc     	SMALLINT; 
	DEFINE vsql             	CHAR(400);
    
	
    LET  vcodret1         		= '00000';
    LET  vcodret2         		= '000';
    LET  vcodret3         		= '';
    LET  sql_err	       		= 0 ;
    LET  isam_err         		= 0 ;
    LET  desc_err         		= '';
    LET  vcontador        		= 0 ;
    LET  ven_transacc     		= 0 ;
	LET  vsql             		= '';
    
	
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_bitacora_actividades.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
  
    --- SET DEBUG FILE TO "/informix/resplogifx/conciliachq/sp_bitacora_actividades.out";
    --- TRACE ON;
	
    IF ( ( SELECT COUNT(*) FROM si_bitacora_actividades WHERE folio_suc = pfolio_suc ) > 0 ) THEN
					SET ISOLATION TO DIRTY READ;
                   UPDATE si_bitacora_actividades 
                   SET valor = pctataotro ,
                   hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdinteg:si_fechas)
                   WHERE folio_suc = pfolio_suc;
        
        
    ELSE
					SET ISOLATION TO DIRTY READ; 
                   INSERT INTO si_bitacora_actividades  
				   VALUES (pcanal,ptransaccion,psucursal,pusuario,pfolio_suc,NULL, (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdinteg:si_fechas), NULL);
        
    END IF
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;