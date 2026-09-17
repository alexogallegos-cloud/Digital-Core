CREATE PROCEDURE "informix".sp_portanom_cargaarchivo_cont(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaRegistro DATE, pRutaArchivo CHAR(50), pArchivo CHAR(50), pCodigoOperacion CHAR(2), pTotalSolicitudes INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(35) AS archivo_respuestas,
				CHAR(50) AS ruta_deposito_archivo_central;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cArchivoRespuestas CHAR(35);
	DEFINE cRutaCentralRespuesta CHAR(50);
	DEFINE bInTransaction BOOLEAN;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cArchivoRespuestas = '';
	LET cRutaCentralRespuesta = '';
	LET bInTransaction = 'f';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			IF bInTransaction = 't' THEN
				BEGIN WORK;
			END IF;
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaction = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_portanom_cargaarchivo_cont.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pArchivo = '' OR pCodigoOperacion = '' OR pTotalSolicitudes IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END IF;
		
		IF pCodigoOperacion NOT IN ('20', '21') THEN
			LET cCodRet = '00102';
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END IF;
		
		IF pCodigoOperacion = '20' AND pFechaRegistro IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		ELIF pCodigoOperacion = '21' AND pFechaRegistro IS NULL THEN
			LET pFechaRegistro = CURRENT;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
		END IF;
		
		BEGIN WORK;
		IF bInTransaction = 'f' THEN
			COMMIT WORK;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_cargarchivoportab_cont(pFechaRegistro, TRIM(pArchivo), pCodigoOperacion, pTotalSolicitudes)
		INTO cCodRetSp, cArchivoRespuestas, cRutaCentralRespuesta;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:'informix'.sp_cargarchivoportab_cont";
		ELIF iCodRetSp = 191 THEN
			LET cCodRet = '00553';
		ELIF iCodRetSp = 175 THEN -- EXISTE UN TIPO DE REGISTRO QUE NO ES AUTORIZADO
			LET cCodRet = '00687';
		ELIF iCodRetSp = 176 THEN
			LET cCodRet = '00086';
		ELIF iCodRetSp = 177 THEN
			LET cCodRet = '00656';
		ELIF iCodRetSp = 178 THEN
			LET cCodRet = '00657';
		ELIF iCodRetSp = 179 THEN
			LET cCodRet = '00658';
		ELIF iCodRetSp = 180 THEN
			LET cCodRet = '00659';
		ELIF iCodRetSp = 181 THEN -- LA SECUENCIA EN EL DETALLE NO ES CORRECTA
			LET cCodRet = '00688';
		ELIF iCodRetSp = 182 THEN
			LET cCodRet = '00483';
		ELIF iCodRetSp = 200 THEN
			LET cCodRet = '00009';
		ELIF iCodRetSp = 201 THEN
			LET cCodRet = '00104';
		ELIF iCodRetSp = 202 THEN
			LET cCodRet = '00104';
		ELIF iCodRetSp = 203 THEN
			LET cCodRet = '00690';
		ELIF iCodRetSp = 204 THEN
			LET cCodRet = '00691';
		ELIF iCodRetSp = 205 THEN
			LET cCodRet = '00692';
		ELIF iCodRetSp = 333 THEN
			LET cCodRet = '00492';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, cArchivoRespuestas, cRutaCentralRespuesta;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 30/11/2017',
'MODULO: Operaciones',
'FUNCIONALIDAD: Portabilidad de nomina - Solicitudes',
'DESCRIPCION: Realiza el vaciado de la informaciÃ³n a un archivo',
'BD: bdicheq';

create procedure "informix".liberasalret_esp(pempresa char(3))
returning char(5);
    
    -- **********************************************************
    -- *        Programa que libera los cheques retenidos       *
    -- *            Autor : Cristian Campos diaz                *
    -- *            Fecha : 06/Septiembre/2007                  *
    -- *            Ver.  : 1.0                                 *
    -- **********************************************************

    define vdias_ret            integer;
    define vmonto               money(14,2);
    define vfecha_alta          date;
    define vnum_chq             integer;
    define vtransacc            char(4);
    define vmonto_ori           money(14,2);
    define vnumero              char(4);
    define vfecha_hoy           date;
    define vfecha_ant           date;
    define vcuenta              char(20);
    define vcancelado           char(1);
    define vcodret              char(5);
    define vcodret2             char(5);
    define vcodret3             char(50);
    define vsqlerr              integer;
    define visamerr             integer;
    define vdescerr             char(50);
    define vRetenido            DECIMAL(14,2);
    define vabierto             CHAR(1);
    define vcomienza            INTEGER;
    define vmincta              char(20);
    define vmaxcta              char(20);
    define vfolio_suc           char(16);

    let vcodret   = "000";
    let vcodret2  = "000";
    let vcodret3  = "";
    let vsqlerr   = 0;
    let visamerr  = 0;
    let vdescerr  = "";
    let vRetenido = 0;
    let vabierto  = "0";
    let vcomienza = -1;
    let vfolio_suc = '';

    --- set debug file to "liberatranret.out";
    --- trace on;
    
    BEGIN

    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "liberatranret.err";
        trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            if vabierto = "1" then
                ROLLBACK WORK;
            end if;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    select fecha_hoy, fecha_ant
      into vfecha_hoy, vfecha_ant 
      from sc_fechas  
     where empresa = pempresa;
     
    select min(cuenta), max(cuenta)
      into vmincta, vmaxcta
      from sc_docret;
    
    foreach principal with hold for
        select numero
          into vnumero
          from bdinteg:si_transacc
         where empresa = pempresa
           and sistema = "01"
           and numero like "08%"
           and tipo_tran in ("20","21","22")
           and naturaleza = "C"
         order by numero
        
        foreach with hold
            select {+INDEX(sc_docret idx_docret2)}
                   cuenta, transacc, dias_ret, monto, fecha_alta, cancelado, num_chq, monto_ori, folio_suc
              into vcuenta, vtransacc, vdias_ret, vmonto, vfecha_alta, vcancelado, vnum_chq, vmonto_ori, vfolio_suc
              from sc_docret
             where cuenta between vmincta and vmaxcta
               and transacc = vnumero
               and cancelado = 'P'
               and (vfecha_hoy - fecha_alta) >= dias_ret 
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET vabierto = "1";
            END IF;
            
            SELECT sdo_retenido
              INTO vRetenido
              FROM sc_maechq
             where empresa = pempresa
               and cuenta = vcuenta;

            LET vRetenido = vRetenido - vmonto;	

            IF vRetenido >= 0 THEN
                update sc_maechq
                   set sdo_retenido = sdo_retenido - vmonto
                 where empresa = pempresa
                   and cuenta = vcuenta;
            END IF
            
            update sc_docret
               set cancelado = "L",
                   dias_ret = 0
             where cuenta = vcuenta
               and transacc = vtransacc
               and cancelado = 'P'
               and fecha_alta = vfecha_alta
               and num_chq = vnum_chq
               and monto_ori = vmonto_ori
               and folio_suc = vfolio_suc;
               
            IF vabierto = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            END IF;

        end foreach;

    end foreach;
    
    IF vabierto = 1 THEN
        COMMIT WORK;
    END IF;
    
    return vcodret;

    END;

end procedure;