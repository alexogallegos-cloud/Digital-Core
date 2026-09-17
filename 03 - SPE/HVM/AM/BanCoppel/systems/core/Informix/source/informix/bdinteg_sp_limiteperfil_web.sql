CREATE PROCEDURE "informix".sp_limiteperfil_web(pSucursal CHAR(4), pEjecutivo CHAR(8), pGerente CHAR(8))
	--DATOS A REGRESAR
	RETURNING  
	CHAR(5) AS cCodRet,
	INTEGER AS iLimite;
--========== DEFINIR VARIABLES =======
	DEFINE iSqlErr SMALLINT;
	DEFINE iSamErr SMALLINT;
	DEFINE cErrorInfo CHAR(40);
	DEFINE cCodRet CHAR(5);
	DEFINE iLimite INTEGER;
	DEFINE iGerente INTEGER;
	DEFINE cEjecutivo CHAR(8);
	DEFINE cHora1 CHAR(5);
	DEFINE cHora2 CHAR(5);
	DEFINE iNumCambios	INTEGER;
--============= INICIALIZA VARIABLES ============
	LET iSqlErr = 0;
	LET iSamErr = 0;
	LET cErrorInfo = '';
	LET cCodRet = '00000';
	LET iLimite = 0;
	LET iGerente = 0;
	LET cEjecutivo = '';
	LET cHora1 = '';
	LET cHora2 = '';
	LET iNumCambios = 0;
--============= TRAER CLIENTES ===================
BEGIN
	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		LET cCodRet = iSqlErr;
		RETURN  cCodRet,iLimite;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO "/informix/Acuellar/sp_limiteperfil.out";
	--TRACE ON;

	IF ( (NVL(pSucursal,'')) = '' OR (NVL(pEjecutivo,'')) = '' OR (NVL(pGerente,'')) = '' )  THEN
		LET cCodRet = '00001'; 
	ELSE
		-- Valida si un Ejecutivo ha dado de alta a mas de un gerente
		SELECT COUNT(c.cod_usuario) 
		INTO iLimite
		FROM bdinteg: "informix".si_cambio_perf_web c
		INNER JOIN bdinteg: "informix".si_fechas f ON c.fecha_cambio = f.fecha_Hoy
		WHERE c.sucursal = pSucursal AND c.password_ant = 'E' AND c.password_nuevo = 'A';
		--AND c.cod_usuario = pEjecutivo;

		select valor
		into iNumCambios
		from si_param
		where cod_param = '471';

		IF iLimite <= iNumCambios then	

			-- Ultimo cambio de promoto a gerente de un empleado
			SELECT c.cod_usuario, max(c.hora_cambio)
			into cEjecutivo, cHora1
			FROM bdinteg: "informix".si_cambio_perf_web c
			INNER JOIN bdinteg: "informix".si_fechas f ON c.fecha_cambio = f.fecha_Hoy
			WHERE c.sucursal = pSucursal AND c.password_ant = 'E' AND c.password_nuevo = 'A'
			and c.hora_cambio = 
			(select max(hora_cambio) FROM bdinteg: "informix".si_cambio_perf_web
			where password_ant = 'E' AND password_nuevo = 'A' and sucursal = c.sucursal
			and fecha_cambio = f.fecha_Hoy)
			and c.cod_usuario <> pGerente
			GROUP BY cod_usuario;

			-- Revisar si ese empleado ya no es gerente
			SELECT max(c.hora_cambio)
			into cHora2
			FROM bdinteg: "informix".si_cambio_perf_web c
			INNER JOIN bdinteg: "informix".si_fechas f ON c.fecha_cambio = f.fecha_Hoy
			WHERE c.sucursal = pSucursal AND c.cod_usuario = cEjecutivo;

			IF cHora1 = cHora2 then

				LET cCodRet = '00001'; 
				-- es el ultimo cambio NO se puede

			elif cHora1 < cHora2 then

				LET cCodRet = '00000'; 
				-- ya NO es gerente

			end if;

		else

			LET cCodRet = '00002';

		END IF;

	END IF;

	RETURN cCodRet,iLimite;

END;
END PROCEDURE
DOCUMENT
'Folio: 466 - RQM 08 030 Limitar OFI Cantidad de Veces que Asigna el Perfil de Gerente',
'Autor: 97893323 Judith Moreno',
'BD: bdinteg',
'Solicita: CUTBERTO GONZALEZ',
'Fecha: 20/08/2018',
'Descripcion: Se crea procedimiento para obtener la cantidad de cambios de perfil de cualquier perfil a Gerente';

CREATE PROCEDURE "informix".sp_desbctasfus_obtnombresupana(pNumEmpleado CHAR(20),pTipo CHAR(1))
RETURNING   CHAR(5)   AS CodigoRetorno, 
			CHAR(50)  AS NombreEmpleado; 


--DECLARACION DE VARIABLES
DEFINE cCodRet        CHAR(5);
DEFINE iSqlErr        INTEGER;
DEFINE iIsamErr       INTEGER;
DEFINE cNomEmpleado   CHAR(50);


--INICIALIZACION DE VARIABLES
LET cCodRet      = '00000';
LET iSqlErr      = 0;
LET iIsamErr     = 0 ;
LET cNomEmpleado = '';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN TRIM(cCodRet), TRIM(NVL(cNomEmpleado, ''));
        END IF;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO '/respaldosbd/sp_desbctasfus_obtNombreSupAna.out';
	--TRACE ON;

		IF NVL(pNumEmpleado, '') = '' THEN 
			LET cCodRet = '00001'; 
			RETURN TRIM(cCodRet), TRIM(NVL(cNomEmpleado, ''));
		END IF;
		
		/*IF pTipo = '1' THEN 
			--Supervisor
			SELECT first 1 a.nombre INTO cNomEmpleado
			FROM si_ejecut a,si_perfil_ejecut b
			WHERE a.ejecutivo = pNumEmpleado
			AND b.perfil = 1131;
			
			IF NVL(cNomEmpleado, '') = '' THEN 
				LET cCodRet = '00002';
			END IF;
		ELSE
			--Analista
			SELECT first 1 a.nombre INTO cNomEmpleado
			FROM si_ejecut a,si_perfil_ejecut b
			WHERE a.ejecutivo = pNumEmpleado
			AND b.perfil = 1131;
			
			IF NVL(cNomEmpleado, '') = '' THEN 
				LET cCodRet = '00003';
			END IF;
		END IF;*/
		
		SELECT first 1 a.nombre INTO cNomEmpleado
		FROM si_ejecut a
		WHERE a.ejecutivo = pNumEmpleado
		;
		
		RETURN TRIM(cCodRet), TRIM(NVL(cNomEmpleado, ''));
END;
END PROCEDURE
DOCUMENT
'REALIZÃ: Josue Zepeda',
'FECHA:   14/05/2013',
'DESCRIPCIÃN: ESTE PROCEDIMIENTO SE ENCARGA DE OBTENER EL NOMBRE DE EMPLEADOS,LOS CUALES SON REQUERIDOS PARA EL LLENADO DE LA PANTALLA DE DESBLOQUEO DE CLIENTES',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_insertarimgleerarchivo(pRutaCarga CHAR(100), pArchivoProcesar CHAR(100))
RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(50);
	DEFINE iSqlErr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cCmd CHAR(2000);
	DEFINE cScriptCarga CHAR(600);
	DEFINE cRutaInformix CHAR(100);
	--- DEFINE cNombreArchivoTmp CHAR(50);
	DEFINE ven_transacc SMALLINT;
	DEFINE bInTransaction BOOLEAN;
	DEFINE cCampos CHAR(1024);
	DEFINE cTablaDst CHAR(150);
	DEFINE cBaseDatos CHAR(50);
	DEFINE cUsrBin CHAR(15);
	
	LET cCodRet = '00000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
	LET iSqlErr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET cCmd = '';
	LET cScriptCarga = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cCampos = '';
	LET cTablaDst = 'si_ctanvl2_rutaimg';
	LET cBaseDatos = 'bdinteg';
	LET cUsrBin = '/usr/bin/';
	
	BEGIN		
	
    ON EXCEPTION SET iSqlErr, cIsamErr, cDescErr  
        SET DEBUG FILE TO '/tmp/mfinis/caratulasCuentaNivel2/sp_insertarimgleerarchivo.err';
        TRACE ON;
        LET cCodRet = iSqlErr;
        LET cCodRet2 = cIsamErr;
        LET cCodRet3 = cDescErr;
        IF iSqlErr <> 0 THEN
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;		
            END IF;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-668,-535,-255)			
        LET bInTransaction = 't';
        COMMIT WORK;
        BEGIN WORK;
    END EXCEPTION WITH RESUME;	
    
    --- SET DEBUG FILE TO '/tmp/mfinis/caratulasCuentaNivel2/sp_insertarimgleerarchivo.out';
    --- TRACE ON;
    
    DELETE FROM bdinteg:"informix".si_ctanvl2_rutaimg;
    
    BEGIN WORK;
    
    IF bInTransaction = 'f' THEN
        COMMIT WORK;
    END IF;
    
    LET ven_transacc = 1;	
    
    LET pRutaCarga = TRIM(pRutaCarga) || '/';
    
    -- // Se convierte el archivo de FORMATO UTF-8 a IBM-1252
    LET cCmd = "iconv -s -f UTF-8 -t IBM-1252 "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||" > "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv';
    SYSTEM TRIM(cCmd);
    
    LET cCmd = "/usr/bin/mv "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
    SYSTEM TRIM(cCmd);
    
    LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.iconv';
    SYSTEM TRIM(cCmd);
    
    -- // Se eliminan caracteres de retorno de carro (DOS)
    LET cCmd = '/usr/bin/tr "\r" " " < '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||' > '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr';
    SYSTEM TRIM(cCmd);
    
    LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'; /usr/bin/mv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
    SYSTEM TRIM(cCmd);
    
    -- // Se eliminan caracteres de tabuladores
    LET cCmd = '/usr/bin/tr "\t" " " < '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||' > '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr';
    SYSTEM TRIM(cCmd);
    
    LET cCmd = "/usr/bin/rm -rf "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'; /usr/bin/mv '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||'.tr '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
    SYSTEM TRIM(cCmd);
    
    LET cCampos = 'ruta';
            
    LET cScriptCarga = TRIM(cUsrBin)||"echo "||'"'||"LOAD FROM "||TRIM(pRutaCarga)||TRIM(pArchivoProcesar)||" DELIMITER '|' INSERT INTO "||TRIM(cBaseDatos)||":"||TRIM(cTablaDst)||"(";
    LET cScriptCarga = TRIM(cScriptCarga)||TRIM(cCampos)||");"||'"'||" > "||TRIM(pRutaCarga)||TRIM("data.sql");
    SYSTEM TRIM(cScriptCarga);
    
    LET cCmd = TRIM(cRutaInformix)||'dbaccess bdinteg < '||TRIM(pRutaCarga)||TRIM("data.sql");
    SYSTEM TRIM(cCmd);
    
    --- COMMIT WORK;
    
    -- // SE ELIMINA EL ARCHIVO SUBIDO
    --- LET cCmd = '/usr/bin/rm -rf '||TRIM(pRutaCarga)||TRIM(pArchivoProcesar);
    --- SYSTEM TRIM(cCmd);
    
    LET ven_transacc = 0;
    
    IF bInTransaction = 't' THEN
        BEGIN WORK;
    END IF;
    
    RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR:Daniel Reyes Guillen',
'FECHA: 05/04/2021',
'MODULO: ',
'FUNCIONALIDAD: ',
'DESCRIPCION: Procedimiento que carga una tabla con un archivo de trabajo',
'BD: bdinteg',
'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 06/12/2021',
'MODULO: ',
'FUNCIONALIDAD: ',
'DESCRIPCION: Se comenta las lineas que eliminan el archivo de carga',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_valida_tel_diferentes(pEmpresa CHAR(3), pNumCte CHAR(20))
	RETURNING CHAR(5)	AS CodigoRetorno,
			  CHAR(13) 	AS TelCasa,
			  CHAR(13) 	AS Celular,
			  CHAR(5) 	AS Carrier,
			  CHAR(13) 	AS TelTrabajo,
			  CHAR(13) 	AS TelOtro,
			  CHAR(5) 	AS Extension,
			  CHAR(100)	AS CorreoElectronico;						  

	--DECLARACION DE VARIABLES
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr			INTEGER;	
	DEFINE cTelCasa			CHAR(13);
	DEFINE cCelular			CHAR(13);
	DEFINE cCarrier			CHAR(5);
	DEFINE cTelTrabajo		CHAR(13);
	DEFINE cTelOtro			CHAR(13);
	DEFINE cExtension		CHAR(5);
	DEFINE cCorreo			CHAR(100);
	DEFINE cTipoTel			CHAR(1);
	DEFINE cTelefonoComp	CHAR(13);
	DEFINE cTipoTelComp		CHAR(2);
	DEFINE cExtComp			CHAR(5);
	DEFINE cCarrierComp		CHAR(100);	
	DEFINE cValCasa			CHAR(1);
	DEFINE cValCelular		CHAR(1);	

	--INICIALIZACION DE VARIABLES
	LET cCodRet			= "00000";
	LET iSqlErr			= 0;
	LET cTelCasa		= "";
	LET cCelular		= "";
	LET cCarrier		= "";
	LET cTelTrabajo		= "";
	LET cTelOtro		= "";
	LET cExtension		= "";
	LET cCorreo			= "";
	LET cTelefonoComp	= "";
	LET cTipoTelComp	= "";
	LET cExtComp		= "";
	LET cCarrierComp	= "";
	LET cValCasa		= "";
	LET cValCelular		= "";

	--SET DEBUG FILE TO "/tmp/sp_valida_tel_diferentes.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cTelCasa, cCelular, cCarrier, cTelTrabajo, cTelOtro, cExtension, cCorreo;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--VERIFICAR QUE EXISTAN REGISTROS
		IF EXISTS(SELECT telefono FROM "informix".si_telefonos_actual WHERE empresa = pEmpresa AND numcte = pNumCte AND status_tel = 'A') THEN
			--SE OBTIENEN LOS TELEFONOS
			FOREACH
				SELECT telefono, tipo_tel, extension, carrier 
				INTO cTelefonoComp, cTipoTelComp, cExtComp, cCarrierComp 
				FROM "informix".si_telefonos_actual 
				WHERE empresa = pEmpresa AND numcte = pNumCte AND status_tel = 'A'
				
				IF cTipoTelComp = '1'  AND cTelefonoComp <> '' THEN --TELEFONO CASA
					LET cTelCasa = cTelefonoComp;
				ELIF cTipoTelComp = '2'  AND cTelefonoComp <> '' THEN --TELEFONO CELULAR
					LET cCelular = cTelefonoComp;
					LET cCarrier = cCarrierComp;
				ELIF cTipoTelComp = '3'  AND cTelefonoComp <> '' THEN --TELEFONO TRABAJO
					LET cTelTrabajo = cTelefonoComp;
					LET cExtension = cExtComp;
				ELIF cTipoTelComp = '4'  AND cTelefonoComp <> '' THEN	--TELEFONO OTRO
					LET cTelOtro = cTelefonoComp;
				END IF
			END FOREACH;
			
			IF cTelCasa <> '' THEN 	--COMPARA TELEFONO CASA
				IF cTelCasa = cCelular OR cTelCasa = cTelTrabajo THEN
					LET cCodRet = "00001";
				END IF
			END IF
			
			IF cCelular <> '' THEN 	--COMPARA TELEFONO CELULAR
				IF cCelular = cTelTrabajo THEN
					LET cCodRet = "00001";
				END IF
			END IF
			
			--VERIFICA QUE TELEFONO CASA Y CELULAR SEAN VALIDOS
			IF cCodRet <> '00001' then
				IF EXISTS (SELECT cofetel FROM "informix".si_telefonos_actual WHERE numcte = pNumCte AND tipo_tel in (1,2) AND cofetel = 'V') THEN
					LET cCodRet = "00000";
				ELSE
					LET cCodRet = "00001";
				END IF
			END IF
			
		END IF;
		
		--VERIFICAR QUE EXISTA CORREO
		IF EXISTS( SELECT correo_elec FROM "informix".si_correos WHERE empresa = pEmpresa AND numcte = pNumCte AND status_correo = 'A' AND tipo_correo = '1') THEN
			SELECT LIMIT 1 correo_elec 
			INTO cCorreo 
			FROM "informix".si_correos 
			WHERE empresa = pEmpresa AND numcte = pNumCte AND status_correo = 'A' AND tipo_correo = '1';
		END IF
		
		RETURN cCodRet, cTelCasa, cCelular, cCarrier, cTelTrabajo, cTelOtro, cExtension, cCorreo;
	END;
	
END PROCEDURE
DOCUMENT
'Autor: Claudio Almodovar',
'Fecha: 19/04/2013',
'BDD: bdinteg',
'Descripcion: Valida que los telÃ©fonos del cliente sean diferentes',
'			  00000 - Los telefonos son diferentes',
'			  00001 - Los telefonos se repiten o son invalidos';

CREATE PROCEDURE "informix".sp_conciliar_colonias_sepomex_cps(p_NumEstado INTEGER,
                                                p_Usuario   CHAR(8))
RETURNING CHAR(5) AS Cod_Ret;
---------------------------------------------------------------------------------------------------------------------------------
--DECLARACIONES
DEFINE v_cod_ret				CHAR(5);
DEFINE iSqlErr					INTEGER;
DEFINE iSamErr					INTEGER;
DEFINE s_DescCiudad				CHAR(100);
DEFINE p_FechaHoy				DATE;
DEFINE i_CveEstado				INTEGER;
DEFINE i_CiudadCoppel			INTEGER;
DEFINE s_BandExisteSimilar		CHAR(1);
DEFINE i_NumColoniasNvas		INTEGER;
DEFINE i_NumColoniasSim			INTEGER;
DEFINE i_CveEstadoAnte			INTEGER;
DEFINE s_DescColoniaBuscar		CHAR(100);
DEFINE s_Asenta					CHAR(60);
DEFINE i_NumColonia				INTEGER;
DEFINE s_CodigoPostal			CHAR(5);
DEFINE s_TipoAsenta				CHAR(25);
DEFINE s_Municipio				CHAR(40);
DEFINE s_MarcaUniHab			CHAR(1);
DEFINE i_NvaColonia				INTEGER;

DEFINE maxColonia               INTEGER;

DEFINE iCiudadAnte				INTEGER;
DEFINE cEmpresa                 CHAR(3);
DEFINE iNumCol1                 INTEGER;
DEFINE iNumCol2                 INTEGER;
DEFINE cBanCons                 CHAR(1);
DEFINE cEdo1                    CHAR(2);
DEFINE cEdo2                    CHAR(2);
DEFINE cCd1                     CHAR(3);
DEFINE cCd2                     CHAR(3);
DEFINE cPais1                   CHAR(3);
DEFINE cPais2                   CHAR(3);
DEFINE cCod1                    CHAR(5);
DEFINE cCod2                    CHAR(5);
DEFINE cCdCoppel1               INTEGER;
DEFINE cCdCoppel2               INTEGER;
DEFINE iRegistros               INTEGER;
DEFINE parEstado1				SMALLINT;
DEFINE parEstado2				SMALLINT;
DEFINE iIdRegistro				INTEGER;

DEFINE cPobZona					CHAR(27);
DEFINE cMunZona					CHAR(27);
DEFINE cNombreZona				CHAR(60);
DEFINE iCodPst					INTEGER;
DEFINE cCiudad					CHAR(100);
DEFINE cMunicipio				CHAR(40);
DEFINE iNumCiudad				INTEGER;
DEFINE cNomCol					CHAR(60);
DEFINE cNombreProceso           CHAR(30);
DEFINE vMensaje  	            CHAR(80);
DEFINE ERROR_INFO               VARCHAR(80);
DEFINE s_Municipio_corto        CHAR(27);
DEFINE s_Asenta_corto           CHAR(32);
DEFINE cCiudad_corto            CHAR(27);
DEFINE c_Cve_estado             CHAR(2);
DEFINE c_CodPst                 CHAR(5); 

DEFINE c_nomzona_spmx           CHAR(60);
DEFINE c_pobzona_spmx           CHAR(100);
DEFINE c_mnpio_spmx             CHAR(50);
DEFINE i_NumColonias_Upd        INTEGER;
DEFINE iResult_upd              INTEGER;
DEFINE cProceso                 CHAR(4);
DEFINE cMensaje                 CHAR(60);
DEFINE vcodret2                 CHAR(5); 
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--INICIALIZACIONES	
LET v_cod_ret				    = "00000";
LET iSqlErr					    = 0;
LET iSamErr					    = 0;
LET s_DescCiudad			    = "";
LET p_FechaHoy				    = DATE(1);
LET i_CveEstado				    = 0;
LET i_CiudadCoppel			    = 0;
LET s_BandExisteSimilar		    = "F";
LET i_NumColoniasNvas		    = 0;
LET i_NumColoniasSim		    = 0;
LET i_CveEstadoAnte			    = 0;
LET s_DescColoniaBuscar		    = "";
LET s_Asenta				    = "";
LET i_NumColonia			    = 0;
LET s_CodigoPostal			    = "";
LET s_TipoAsenta			    = "";
LET s_Municipio				    = "";
LET s_MarcaUniHab			    = "";
LET i_NvaColonia			    = 0;

LET maxColonia                  = 0;

LET iCiudadAnte				    = 0;
LET cEmpresa                    = "001";
LET iNumCol1                    = 0;
LET iNumCol2                    = 999999;
LET cBanCons                    = "";
LET cEdo1                       = "";
LET cEdo2                       = "ZZ";
LET cCd1                        = "";
LET cCd2                        = "ZZZ";
LET cPais1                      = "";
LET cPais2                      = "ZZZ";
LET cCod1                       = "";
LET cCod2                       = "ZZZZZ";
--LET cCdCoppel1                  = 0;
LET cCdCoppel1                  = 1;
LET cCdCoppel2                  = 999999;
LET iRegistros                  = 0;
LET parEstado1					= 0;
LET parEstado2				    = 0;

LET cPobZona					= "";
LET cMunZona					= "";
LET cNombreZona					= "";
LET iCodPst						= 0;
LET cCiudad						= "";
LET cMunicipio					= "";
LET iNumCiudad					= 0;
LET cNomCol						= "";
LET cNombreProceso              = 'CONCILIAR COLS SPMX';
LET vMensaje                    = ''; 
LET ERROR_INFO                  = '';
LET s_Municipio_corto           = '';
LET s_Asenta_corto              = '';
LET cCiudad_corto               = '';
LET c_Cve_estado                = '';
LET c_CodPst                    = '';
LET c_nomzona_spmx              = '';
LET c_pobzona_spmx              = ''; 
LET c_mnpio_spmx                = ''; 
LET i_NumColonias_Upd           = 0;
LET iResult_upd                 = 0;
LET cProceso                    = '0097';
LET cMensaje                    = '';
LET vcodret2                    = '';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--SET pdqpriority 20;

BEGIN

ON EXCEPTION SET iSqlErr, iSamErr, ERROR_INFO
    LET v_cod_ret = iSqlErr;
	LET vMensaje  = iSamErr || '-' || ERROR_INFO;
	
	INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
              VALUES(cNombreProceso, v_cod_ret, vMensaje, 0 ,user, p_FechaHoy,
              (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
	
	CALL bdicobranza:sp_inserta_bitacora_cob(cEmpresa, cProceso, v_cod_ret, vMensaje, '02') RETURNING vcodret2;
	
    RETURN v_cod_ret;
END EXCEPTION;


 --SET DEBUG FILE TO "/informix/macf/sp_conciliar_colonias_sepomex_new.out";
 --TRACE ON;
   LET cMensaje = 'Proceso Inicia';
   CALL bdicobranza:sp_inserta_bitacora_cob(cEmpresa, cProceso, v_cod_ret, cMensaje, '01') RETURNING vcodret2;
 

--OBTIENE LA FECHA DEL SISTEMA
SELECT fecha_hoy
  INTO p_FechaHoy
  FROM si_fechas
 WHERE empresa = cEmpresa; 
 
 --LET p_FechaHoy = MDY('02','03','2022');   -- SOLO TEST MACF
 
--VALIDA QUE EL ESTADO NO ESTE VACIO
IF NVL(p_NumEstado,"") = "" OR NVL(p_Usuario,"") = "" THEN
    RETURN "00001";
END IF;
	
--INICIALIZA LA TABLA DE COLONIAS
-- TRUNCATE bdinteg:si_catsepomex_colonias;

--OPCION DE CONCILIACION POR MEDIO DE UN ESTADO
IF p_NumEstado > 0 THEN
   LET cBanCons = "E";
   LET cEdo1 = LPAD(p_NumEstado,2,"0");
ELSE 
	LET cEdo1 = LPAD(0,2,"0");
   LET cBanCons = "G";
END IF;

LET i_NumColoniasSim  = 0;
LET i_NumColoniasNvas = 0;

--OBTIENE LAS DISTINTAS CIUDADES PERTENECIENTES AL ESTADO DE SEPOMEX
-- PRIMER BLOQUE: PROCESAR LAS DE TAMAÑO DE COLS IGUAL AL DE SI_CAZONAS
FOREACH WITH HOLD
	SELECT estado 
	INTO parEstado1
	FROM si_estados
	WHERE estado = CASE WHEN cEdo1 > 0 THEN cEdo1
          ELSE estado END
	FOREACH WITH HOLD
	      SELECT a.ciudad_coppel ,  b.d_codigo     ,  b.d_tipo_asenta ,  b.d_mnpio    ,  b.d_asenta  ,  b.d_ciudad    ,  b.c_estado
	        INTO i_CiudadCoppel  ,  s_CodigoPostal ,  s_TipoAsenta    ,  s_Municipio  ,  s_Asenta    ,  s_DescCiudad  ,  c_Cve_estado 
	        FROM bdinteg:si_ciudades a, bdinteg:si_catsepomex b
	       WHERE a.ciudad   BETWEEN cCd1   AND cCd2
	         AND a.estado   BETWEEN parEstado1  AND parEstado1
	         AND a.pais     BETWEEN cPais1 AND cPais2
	         AND a.d_ciudad = b.d_ciudad
	         AND b.d_codigo BETWEEN cCod1  AND cCod2
	         AND b.c_estado = a.estado
			 AND a.elegir is null
	         --ORDER BY a.ciudad_coppel
	        ORDER BY b.c_estado, b.d_ciudad


	        LET s_DescCiudad = TRIM(s_DescCiudad);
	        LET s_Asenta     = TRIM(s_Asenta);
	        LET s_TipoAsenta = TRIM(s_TipoAsenta);
			--LET s_CodigoPostal = s_CodigoPostal::INTEGER;    -- QUITAR 02/02/2022
			LET s_Municipio = TRIM(s_Municipio);  
			
		        							 
			    SELECT FIRST 1 numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, 
				       nomzona_spmx, mnpio_spmx, pobzona_spmx, ROWID
				  INTO iNumCiudad, i_NumColonia, cNombreZona, cPobZona, cMunZona, iCodPst,
				       c_nomzona_spmx, c_mnpio_spmx, c_pobzona_spmx, iIdRegistro 
				  FROM bdinteg:si_catzonas
				  WHERE numerociudad  = i_CiudadCoppel 
	                AND numerocolonia BETWEEN iNumCol1 AND iNumCol2
	                AND mnpio_spmx = s_Municipio
	                AND nomzona_spmx = s_Asenta
					AND pobzona_spmx = s_DescCiudad;
					
					
				LET c_nomzona_spmx = TRIM(c_nomzona_spmx);
				LET c_mnpio_spmx = TRIM(c_mnpio_spmx);
				LET c_pobzona_spmx = TRIM(c_pobzona_spmx);
				  
	        --OBTIENE LA MARCA DE UNIDAD HABITACIONAL, LE PONE "S" CUANDO ES UNIDAD O CUNJUNTO HABITACIONAL EN CASO CONTRARIO DE PONE "N"
			     LET s_MarcaUniHab = DECODE(s_TipoAsenta,"UNIDAD HABITACIONAL","S","CONJUNTO HABITACIONAL","S","N");
				 LET cNombreZona = TRIM(cNombreZona);
				 
	            IF NVL(i_NumColonia,0) <> 0 THEN 
				
				    IF s_CodigoPostal <>  lpad(iCodPst,5,'0') THEN

					   begin;
					     UPDATE bdinteg:si_catzonas 
						    SET codigopostalzona = s_CodigoPostal,
						        f_modifica = p_FechaHoy
						  WHERE numerociudad = iNumCiudad
						    AND numerocolonia = i_NumColonia
						    AND nomzona_spmx =  c_nomzona_spmx
						    AND mnpio_spmx = c_mnpio_spmx
						    AND ROWID = iIdRegistro;
					   commit;
					   
					   LET iResult_upd = DBINFO("sqlca.sqlerrd2"); 
		
		               IF iResult_upd > 0 THEN
					      LET i_NumColonias_Upd = i_NumColonias_Upd +1;
					   END IF;
					   
					END IF;
					
				END IF;

	            LET s_DescCiudad 		 = "";
				LET i_CveEstado 		 = 0;
				LET i_CiudadCoppel		 = 0;
				LET s_CodigoPostal 		 = "";
				LET s_TipoAsenta 		 = "";
				LET s_Municipio			 = "";
				LET s_Asenta 			 = "";
				LET i_NumColonia 		 = 0;
				LET s_MarcaUniHab        = "";
				
					
					
	END FOREACH;
END FOREACH;
LET iRegistros = DBINFO("sqlca.sqlerrd2");

-- Indica que no hay registros con el filtro indicado.
IF iRegistros = 0 THEN
   LET v_cod_ret = "00002";
END IF;


 --->>  AGREGAR EN OTRO FOREACH LO QUE PUSE EN EL sp_conciliar_colonias_sepomex_09Dif_cdmx  PARA LAS ALCALDÍAS DE LA CDMX, YA QUE EN EL PRINCIPAL Y PRIMER FOREACH
 --->>  NO SE MATCHEAN LAS CIUDADES-ALCALDÍAS CON LA D_CIUDA DE SPMX PQ EN ESA TBL SOLO EXISTE LA D_CIUDAD: CIUDAD DE MEXICO
 LET cEdo1 = '09';
 
 IF cEdo1 = '09' THEN
   
	LET parEstado1 = cEdo1;
	
	FOREACH WITH HOLD
	      SELECT a.ciudad_coppel ,  b.d_codigo     ,  b.d_tipo_asenta ,  b.d_mnpio    ,  b.d_asenta  ,  b.d_ciudad    ,  b.c_estado
	        INTO i_CiudadCoppel  ,  s_CodigoPostal ,  s_TipoAsenta    ,  s_Municipio  ,  s_Asenta    ,  s_DescCiudad  ,  c_Cve_estado 
	        FROM bdinteg:si_ciudades a, bdinteg:si_catsepomex b
	       WHERE a.ciudad   BETWEEN cCd1   AND cCd2
	         AND a.estado   BETWEEN parEstado1  AND parEstado1
	         AND a.pais     BETWEEN cPais1 AND cPais2
	         AND a.d_ciudad = b.d_mnpio
	         AND b.d_codigo BETWEEN cCod1  AND cCod2
	         --AND b.d_ciudad = a.d_ciudad    -- comentado solo para procesar las alcaldías de CDMX
	         AND b.c_estado = a.estado
	         --AND b.estatus  = 2
	         AND a.ciudad_coppel BETWEEN cCdCoppel1 AND cCdCoppel2
			 AND a.elegir is null
			 AND a.ciudad_coppel <> 6564
	        --ORDER BY a.ciudad_coppel
	        ORDER BY b.c_estado, b.d_ciudad


			LET s_DescCiudad = TRIM(s_DescCiudad);
	        LET s_Asenta     = TRIM(s_Asenta);
	        LET s_TipoAsenta = TRIM(s_TipoAsenta);
			--LET s_CodigoPostal = s_CodigoPostal::INTEGER;    -- QUITAR 02/02/2022
			LET s_Municipio = TRIM(s_Municipio);
			
		        							 
			    SELECT FIRST 1 numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, 
				       nomzona_spmx, mnpio_spmx, pobzona_spmx, ROWID
				  INTO iNumCiudad, i_NumColonia, cNombreZona, cPobZona, cMunZona, iCodPst,
				       c_nomzona_spmx, c_mnpio_spmx, c_pobzona_spmx, iIdRegistro 
				  FROM bdinteg:si_catzonas
				  WHERE numerociudad  = i_CiudadCoppel 
	                AND numerocolonia BETWEEN iNumCol1 AND iNumCol2
	                AND mnpio_spmx = s_Municipio
	                AND nomzona_spmx = s_Asenta
					AND pobzona_spmx = s_DescCiudad;
					
					
				LET c_nomzona_spmx = TRIM(c_nomzona_spmx);
				LET c_mnpio_spmx = TRIM(c_mnpio_spmx);
				LET c_pobzona_spmx = TRIM(c_pobzona_spmx);
				  
	        --OBTIENE LA MARCA DE UNIDAD HABITACIONAL, LE PONE "S" CUANDO ES UNIDAD O CUNJUNTO HABITACIONAL EN CASO CONTRARIO DE PONE "N"
			     LET s_MarcaUniHab = DECODE(s_TipoAsenta,"UNIDAD HABITACIONAL","S","CONJUNTO HABITACIONAL","S","N");
				 LET cNombreZona = TRIM(cNombreZona);
				 
	            IF NVL(i_NumColonia,0) <> 0 THEN 
				
				    IF s_CodigoPostal <>  lpad(iCodPst,5,'0') THEN

					   begin;
					     UPDATE bdinteg:si_catzonas 
						    SET codigopostalzona = s_CodigoPostal,
						        f_modifica = p_FechaHoy
						  WHERE numerociudad = iNumCiudad
						    AND numerocolonia = i_NumColonia
						    AND nomzona_spmx =  c_nomzona_spmx
						    AND mnpio_spmx = c_mnpio_spmx
						    AND ROWID = iIdRegistro;
						commit;
						
					END IF;
					
					LET iResult_upd = DBINFO("sqlca.sqlerrd2"); 
		
		               IF iResult_upd > 0 THEN
					      LET i_NumColonias_Upd = i_NumColonias_Upd +1;
					   END IF;
					
				END IF;
				    

	                LET s_DescCiudad 		 = "";
					LET i_CveEstado 		 = 0;
					LET i_CiudadCoppel		 = 0;
					LET s_CodigoPostal 		 = "";
					LET s_TipoAsenta 		 = "";
					LET s_Municipio			 = "";
					LET s_Asenta 			 = "";
					LET i_NumColonia 		 = 0;
					LET s_MarcaUniHab        = "";
				
			 
    END FOREACH;		
 END IF;	

 LET iRegistros = DBINFO("sqlca.sqlerrd2");

-- Indica que no hay registros con el filtro indicado.
IF iRegistros = 0 THEN
   LET v_cod_ret = "00003";
END IF;
	
	   
	INSERT INTO si_bitacora_sepomex (proceso, estatus, cifra, estado, user_insert, fecha_insert) 
	 VALUES ("ACTUALIZA CPS COLONIAS", "CP UPDATED", i_NumColonias_Upd, cEdo1, p_Usuario, p_FechaHoy);	
	
	LET cMensaje = 'PROCESO EXITOSO';
	CALL bdicobranza:sp_inserta_bitacora_cob(cEmpresa, cProceso, v_cod_ret, cMensaje, '03') RETURNING vcodret2; 
	
    RETURN v_cod_ret;
END
END PROCEDURE
DOCUMENT
'Creación: Marco A. Campos',
'Descripcion: Actualizar los CPs de todas las colonias en base a Sepomex',
'Fecha: 2022-02-03',
'Version: 1.0',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultarclientebpi_web(pTipo CHAR(1), 
													pEmpresa CHAR(3), 
													pNumCte CHAR(20), 
													pCveOperacion CHAR (12))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5), -- Codigo de Retorno
	CHAR(10), -- Fecha Nacimiento
	CHAR(20), -- Numero de Cliente
	CHAR(26), -- Apellido Paterno
	CHAR(26), -- Apellido Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(4), -- Id Status
	CHAR(40), -- Descripcion Status
	CHAR(12), -- Folio Contrato
	CHAR(250), -- Descricion Validacion
	SMALLINT, --Tipo Servicio
	CHAR(6), --Status token
	CHAR(1); --Bandera Producto Basico

	--DEFINICION DE VARIABLES--
	DEFINE sql_err INT;
	DEFINE vCodRet CHAR(5);
	DEFINE vFechaNac CHAR(10);
	DEFINE vNumCte CHAR(20);
	DEFINE vApePat CHAR(26);
	DEFINE vApeMat CHAR(26);
	DEFINE vNombre1 CHAR(26);
	DEFINE vNombre2 CHAR(26);
	DEFINE vStatus SMALLINT;
	DEFINE vDescStatus CHAR(40);
	DEFINE vMensValid CHAR(250);
	DEFINE vTipoPersona CHAR(2);
	DEFINE vFolio CHAR(12);
	DEFINE vF_status DATE;
	DEFINE vF_registro DATE;
	DEFINE vFecha_Hoy DATE;
	DEFINE vTipoServicio SMALLINT;
	DEFINE vStatusToken	CHAR(6);
	DEFINE vIdStatusAnterior SMALLINT;
	DEFINE vPBasico CHAR(1);
    DEFINE vNumSerie CHAR(9);
    DEFINE vFechaStatus CHAR(10);
    DEFINE vStatusSol SMALLINT;
    DEFINE vNumSerieSol CHAR(10);

	--INICIALIZACION DE VARIABLES--
	LET sql_err = 0;
	LET vCodRet = '00000';
	LET vFechaNac = '01/01/1900';
	LET vNumCte = '';
	LET vApePat = '';
	LET vApeMat = '';
	LET vNombre1 = '';
	LET vNombre2 = '';
	LET vStatus = 0;
	LET vDescStatus = '';
	LET vMensValid = '';
	LET vTipoPersona = '';
	LET vFolio = '';
	LET vF_status  = '01/01/1900';
	LET vF_registro = '01/01/1900';
	LET vTipoServicio = 0;
	LET vStatusToken = '';
	LET vIdStatusAnterior = 0;
	LET vPBasico = '';
    LET vNumSerie='';
    LET vFechaStatus = '';
    LET vStatusSol = 0;
    LET vNumSerieSol =  '';

	--SET DEBUG FILE TO "/tmp/SP_ConsultarClienteBPI.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN vCodRet, vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vDescStatus, vFolio, vMensValid, vTipoServicio, vStatusToken, vPBasico;
			END IF;
		END EXCEPTION;

		SET ISOLATION DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCte and tpo_persona = '01') THEN
			--valida si el cliente tiene un producto basico
			IF (SELECT count(cuenta) FROM bdicheq:"informix".sc_maechq WHERE num_cte = pNumCte AND producto in ('1300','1400','1700')) <> 0 THEN
				LET vPBasico = 'S';
			ELIF (SELECT count(num_credito) FROM bdicred:"informix".sd_maecred WHERE numcte = pNumCte AND num_producto = '6600') <> 0 THEN
				LET vPBasico = 'S';
			ELSE
				LET vPBasico = 'N';
			END IF;

			IF pTipo = '1' THEN
				IF (SELECT count(id_status) FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte AND empresa = pEmpresa) = 0 OR
					(SELECT count (id_status) FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte AND id_status = '99') = 1 THEN --si no existe o tiene status cancelado 000

					SELECT bdi_sictepf.fecha_nac, bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2
					INTO vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2
					FROM bdinteg:"informix".si_cliente bdi_sicte, bdinteg:"informix".si_ctepf bdi_sictepf
					WHERE bdi_sicte.numcte = pNumCte
					AND bdi_sicte.empresa = pEmpresa
					AND bdi_sicte.tpo_persona = '01'
					AND bdi_sicte.numcte = bdi_sictepf.numcte;

					SELECT id_status, f_status::DATE, f_registro ::DATE INTO vStatus, vF_status, vF_registro FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte AND empresa = pEmpresa;
					SELECT fecha_hoy INTO vFecha_Hoy FROM  bdinteg: si_fechas;

					IF vStatus = '99' AND vF_status = vF_registro AND vF_status >=  vFecha_Hoy THEN --si cancelo antes de las 24 hrs
						LET vCodRet =  '00006';
						SELECT codigo INTO vMensValid FROM bdibpi:"informix".bpi_catmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = vStatus;
					ELSE

						EXECUTE PROCEDURE bdinteg:"informix".sp_ValidarProductoPermitido (pEmpresa, pNumCte, pCveOperacion) INTO vCodRet;
						IF vCodRet <> 0 THEN
							LET vCodRet =   '00003';
							LET vMensValid =  '130';
						END IF;
						---valida productos para serv avanzado para clientes sin servicio y ofrecer solo basico
						EXECUTE PROCEDURE bdinteg:"informix".sp_ValidarProductoPermitido (pEmpresa, pNumCte, '1018') INTO vCodRet;
						IF vCodRet <> 0 THEN
							LET vPBasico = 'B';
							LET vCodRet = '00000';
						END IF;
					END IF;
				ELIF (SELECT count(id_status) FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte) = 1 THEN --si  existe

					/*IF ((SELECT id_status FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte) = 10 OR (SELECT id_status FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte) = 30) AND
						((SELECT id_status FROM bdibpi:"informix".bpi_tokensolicitud WHERE numcte = pNumCte
							AND f_solicitud = (SELECT MAX(f_solicitud) FROM bdibpi:"informix".bpi_tokensolicitud WHERE numcte = pNumCte)) = 199) THEN
						LET vCodRet = '00008'; --DVRP 10/08/2011
					ELSE
					*/

					SELECT id_status INTO vStatus FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte;

					SELECT bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2,
						bdi_sibpi.id_status, bdi_sista.desc_status , bdi_sibpi.folio_contrato , bdi_sictepf.fecha_nac, bdi_sibpi.servicio
					INTO vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vDescStatus, vFolio, vFechaNac, vTipoServicio
					FROM bdinteg:"informix".si_cliente bdi_sicte, bdinteg:"informix".si_ctepf bdi_sictepf, bdinteg:"informix".si_bpiusuarios bdi_sibpi, bdinteg:"informix".si_bpistatus bdi_sista
					WHERE bdi_sicte.numcte = pNumCte
					AND bdi_sicte.empresa = pEmpresa
					AND bdi_sicte.tpo_persona = '01'
					AND bdi_sicte.numcte = bdi_sictepf.numcte
					AND bdi_sicte.numcte = bdi_sibpi.numcte
					AND bdi_sista.id_status = vStatus;

					SELECT f_registro ::DATE INTO vF_registro FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte;
					SELECT fecha_hoy INTO vFecha_Hoy FROM  bdinteg:"informix".si_fechas;

					SELECT (CAST (NVL(id_status_token, '') AS CHAR(6)))
					INTO vStatusToken
					FROM bdinteg:"informix".si_bpitoken
					WHERE num_cliente =  pNumCte
					AND empresa = pEmpresa
					AND f_registro = (SELECT max (f_registro) FROM bdinteg:"informix".si_bpitoken WHERE num_cliente =  pNumCte AND  empresa = pEmpresa);

					IF  NVL(vFechaNac,'') = '' THEN
						LET vFechaNac = '01/01/1900';
					END IF;
					LET vCodRet = '00005';

					IF  NVL(vStatusToken,'') = '' THEN
						LET vStatusToken = '';
					END IF;
					--aunque tenga servicio basico, se valida si tiene un producto permitido para servicio avanzado
					EXECUTE PROCEDURE bdinteg:"informix".sp_ValidarProductoPermitido (pEmpresa, pNumCte, '1018') INTO vCodRet;
					IF vCodRet <> 0 THEN
						LET vPBasico = 'B';
					END IF;
					LET vCodRet = '00005';

					--SI NO  EXISTE POSIBILIDAD DE CAMBIO
					IF (SELECT count(status_destino) FROM bdinteg:"informix".si_bpicatcambiostatus WHERE Proceso = pTipo AND status_origen = vStatus ) = 0  THEN
						LET vCodRet = '-0001';
						IF EXISTS (SELECT codigo FROM bdibpi:"informix".bpi_catmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = vStatus) THEN
							SELECT codigo INTO vMensValid FROM bdibpi:"informix".bpi_catmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = vStatus;
						ELSE
							LET vCodRet = '-0002';
							LET vMensValid = '131';
						END IF
					ELSE
						IF vF_registro >=  vFecha_Hoy THEN     --Activo Hoy
							LET vMensValid =  '151';
							LET vCodRet = '00007';
							--activo hoy
						ELIF EXISTS(SELECT numcliente FROM bdinteg:"informix".si_cambiostcte WHERE numcliente = pNumCte AND fecha_cambio ::DATE = vFecha_Hoy ) THEN
							SELECT MAX(id_statusanterior) INTO vIdStatusAnterior FROM bdinteg:"informix".si_cambiostcte WHERE numcliente = pNumCte AND fecha_cambio ::DATE = vFecha_Hoy;
							IF vIdStatusAnterior = 1 OR vIdStatusAnterior = 2 THEN
								LET vMensValid =  '129';
								LET vCodRet = '00007';
								--realizo cambio hoy
							END IF;
						END IF;
					END IF;
					--END IF;
				END IF;

			ELIF pTipo = '2' THEN
				IF (SELECT count(id_status) FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte ) > 0 THEN
					SELECT id_status INTO vStatus FROM bdinteg:"informix".si_bpiusuarios WHERE numcte = pNumCte;

					--DSB 08/10/2010
					SELECT  bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sictepf.fecha_nac,
						bdi_sibpi.id_status, bdi_sista.desc_status, bdi_sibpi.servicio
					INTO vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vFechaNac, vStatus, vDescStatus, vTipoServicio
					FROM bdinteg:"informix".si_cliente bdi_sicte, bdinteg:"informix".si_ctepf bdi_sictepf, bdinteg:"informix".si_bpiusuarios bdi_sibpi, bdinteg:"informix".si_bpistatus bdi_sista
					WHERE bdi_sicte.numcte = pNumCte
					AND bdi_sicte.empresa = pEmpresa
					AND bdi_sicte.tpo_persona = '01'
					AND bdi_sicte.numcte = bdi_sictepf.numcte
					AND bdi_sicte.numcte = bdi_sibpi.numcte
					AND bdi_sista.id_status = vStatus;

					EXECUTE PROCEDURE bdinteg:"informix".sp_obtener_num_serie_token(pNumCte)
					INTO vCodRet, vNumSerie;

					IF vCodRet ='000' THEN
						IF vNumSerie <> '' THEN
							SELECT id_status
							  INTO vStatusToken
							  FROM bdibpi:"informix".tkn_nseries
							 WHERE ns_token = vNumSerie;
						ELSE
							LET vStatusToken = "";
							LET vFolio = "";

							SELECT ns_token, id_status
							  INTO vNumSerieSol, vStatusSol
							  FROM bdibpi:"informix".bpi_tokensolicitud
							 WHERE numcte = pNumCte and f_solicitud = (SELECT MAX(f_solicitud) FROM bdibpi:"informix".bpi_tokensolicitud WHERE numcte = pNumCte);

							IF vStatusSol = 199 THEN
								LET vStatusSol ="";
								SELECT count(id_status_token)
								  INTO vStatusSol
								  FROM bdinteg:"informix".si_bpitokenhis
								 WHERE num_cliente = pNumCte AND ns_token =TRIM(vNumSerieSol)
								   AND id_status_token='199';

								IF vStatusSol > 0 THEN
									LET vFolio = "199";
								ELSE
									LET vFolio = vStatusSol;
								END IF;
							ELSE
								LET vFolio = vStatusSol;
							END IF;
						END IF;
					ELSE
						LET vStatusToken = "";
					END IF;

					---IF (SELECT count(status_destino) FROM si_bpicatcambiostatus WHERE Proceso = '02'  AND status_origen = '99') = 0 THEN  CHECAR
					IF vStatus = '99' THEN
						SELECT mensaje INTO vMensValid FROM bdinteg:"informix".si_bpicatmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = vStatus;
						LET vCodRet = '-0001';
					ELIF (SELECT count(status_destino) FROM bdinteg:"informix".si_bpicatcambiostatus WHERE Proceso = pTipo AND status_origen = vStatus ) = 0  THEN
						LET vCodRet = '-0001';
						IF EXISTS (SELECT mensaje FROM bdinteg:"informix".si_bpicatmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = vStatus) THEN
							SELECT mensaje INTO vMensValid FROM bdinteg:"informix".si_bpicatmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = vStatus;
						ELSE
							LET vCodRet = '-0002';
							LET vMensValid = 'El cliente tiene un estatus inválido para el servicio';
						END IF;
					END IF;
				ELSE
					SELECT  bdi_sictepf.fecha_nac, bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2
					INTO vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2
					FROM bdinteg:"informix".si_cliente bdi_sicte, bdinteg:"informix".si_ctepf bdi_sictepf
					WHERE bdi_sicte.numcte = pNumCte
					AND bdi_sicte.empresa = pEmpresa
					AND bdi_sicte.tpo_persona = '01'
					AND bdi_sicte.numcte = bdi_sictepf.numcte;
					--LET vMensValid =   'El Cliente no tiene activado el servicio';
					--IF (SELECT count(status_destino) FROM si_bpicatcambiostatus WHERE Proceso = '02' AND status_origen = vStatus) = 0 THEN
					SELECT mensaje INTO vMensValid FROM bdinteg:"informix".si_bpicatmensajes WHERE proceso = pTipo AND operacion = '1' AND status_servicio = vStatus;
					LET vCodRet = '004';
					--END IF;
				END IF;
			END IF;
		ELSE
			SELECT tpo_persona INTO vTipoPersona FROM bdinteg:"informix".si_cliente WHERE numcte = pNumcte;
			IF vTipoPersona = '02' THEN
				LET vCodRet = '00002';
				IF pTipo = '1' THEN
					LET vMensValid = '149';
				ELSE
					LET vMensValid = 'Cliente Moral, verifique';
				END IF;
			ELSE
				LET vCodRet =   '00001';
				IF pTipo = '1' THEN
					LET vMensValid = '150';
				ELSE
					LET vMensValid = 'Cliente no Existe';
				END IF;
			END IF;
		END IF;
		RETURN vCodRet, vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vDescStatus, vFolio, vMensValid, vTipoServicio, vStatusToken, vPBasico;
	END
END PROCEDURE
DOCUMENT
'Consulta el cliente para la Banca por Internet y si se pueden hacer cambios de estados',
'Autor :',
'Modificó : Dulce Ramírez',
'FECHA : 25/Mayo/2009',
'Modificó : Dulce Ramírez',
'FECHA : 13/Noviembre/2009',
'Descripcion: Se modifica para consultar el tipo de servicio y para validar si se pude hacer el cambio entre los servicios',
'Modificó : Iris Arias Zazueta',
'FECHA : 08/Octubre/2010',
'Descripcion: Se modifica para consultar el tipo de servicio',
'Modificó : Saúl Ivanhoe Valdespino Hernández',
'FECHA : 11/Octubre/2010',
'Descripcion: Se modifica para consultar el status del token para el Tipo de Consulta 2',
'Modificó : Saúl Ivanhoe Valdespino Hernández',
'FECHA : 06/Enero/2011',
'Descripcion: Se modifica para consultar la fecha de nacimiento y la tabla si_bpitokenhis para el Tipo de Consulta 2',
'Modificó : Saúl Ivanhoe Valdespino Hernández',
'FECHA : 25/Enero/2011',
'Descripcion: Se modifica para el Tipo de Consulta 2',
'BD: bdinteg',
'Modificó: Daniela Ramirez',
'FECHA: 10/08/2011',
'Descripcion: Validacion codret = 008 que el cliente tiene servicio de banca activo 10 o 30 y tiene solicitud de token reciente cancelada 199',
'BD: bdinteg',
'Modificó: Daniela Ramirez',
'FECHA: 30/11/2011',
'Descripcion: Se selecciona el MAX de la consulta a la tabla si_cambiostcte para tomar el mas estatus mas actual',
'BD: bdinteg',
'Se quita la validación del token cancelado en servicio básico',
'Fecha:15/07/2013',
'Bibiana Gaxiola Verdugo',
'Se agrega validación para traer el ultimo registro del historico',
'Fecha:12/09/2016',
'Alejandro Vazquez';

CREATE PROCEDURE "informix".sp_relacionbancoppelcoppel(cEmpresa CHAR(3), cNumCte CHAR(20), cNumSolicitudP CHAR(20))
RETURNING
	CHAR(6)     AS Retorno ,           -- Codigo de Retorno
	CHAR(20)    AS ClienteBanco,       -- Nro de Cliente
	CHAR(20)    AS ClienteCoppel       -- Nro de Cliente

	-- DEFINICION DE VARIABLES
	DEFINE cCodRetorno		CHAR(6);
	DEFINE cNumcteCoppel	CHAR(20);
	DEFINE cNumcteBanco		CHAR(20);
	DEFINE cNumSolicitud	CHAR(20);
	DEFINE iSqlErr			INTEGER;

	DEFINE cTicket				   	CHAR(20); 
	DEFINE cEdo_proceso			   	CHAR(4); 
	DEFINE cNum_men				   	CHAR(3); 
    DEFINE cEmpresaHuella           CHAR(3);

	--INICIALIZACION DE VARIABLES
	LET cCodRetorno		= "000000";
	LET cNumcteCoppel	= "";
	LET cNumcteBanco	= "";
	LET cNumSolicitud	= "";
	LET iSqlErr			= 0;

	LET cEdo_proceso	   		=""; 
	LET cNum_men		   		=""; 
	LET cTicket			   		=""; 
    LET cEmpresaHuella          ="";
	
	--SET DEBUG FILE TO "/tmp/Victor/sp_relacionbancoppelcoppel.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','';
			END IF;
		END EXCEPTION;
		
		--dsb-30/07/2013
		IF NVL(cNumSolicitudP, '') <> '' THEN
			SELECT num_solicitud
			INTO cNumSolicitud
			FROM bdisolic:"informix".ss_solicitudes 
			WHERE num_producto = '6500'
			AND num_solicitud = cNumSolicitudP AND numcte = cNumcte;
			IF NVL(cNumSolicitud, '') = '' THEN
				LET cCodRetorno = '000002';
				RETURN  cCodRetorno,cNumcteBanco,cNumcteCoppel;
			END IF;
		END IF;
		IF NVL(cEmpresa,'') = '' THEN
			LET cCodRetorno = '000001';
			RETURN  cCodRetorno,cNumcteBanco,cNumcteCoppel;
		ELSE
			--Verificar si no cuenta con una relacion coppel en la tabla si_relacion_ctebcplcpl
			SELECT cliente, numcte_banco
			INTO cNumcteCoppel, cNumcteBanco
			FROM bdinteg:"informix".si_relacion_ctebcplcpl 
			WHERE  empresa = cEmpresa AND numcte_banco = cNumCte AND tipo_relacion <> 0;
			
			IF NVL(cNumcteBanco,'') <> '' THEN
				--OBTENER LA SOLICITUD DE PRODUCTO 6500
				IF EXISTS(SELECT 1 FROM bdisolic:"informix".ss_solicitudes 
				WHERE num_producto = '6500' AND status_solicitud = 'AT' AND numcte = cNumCte) THEN
					SELECT num_solicitud 
					INTO cNumSolicitud
					FROM bdisolic:"informix".ss_solicitudes 
					WHERE num_producto = '6500' AND status_solicitud = 'AT'
					AND numcte = cNumCte;
					
					UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "RT"
					WHERE empresa = cEmpresa
					AND num_solicitud = cNumSolicitud;

					INSERT INTO bdisolic:"informix".ss_autorizacion
					(empresa, ejecutivo_auto, num_solicitud, status_solicitud,causa_solicitud,
					comentario, fecha_entrada, fecha_salida)
					VALUES
					(cEmpresa, "sistema", cNumSolicitud, "RT", "RCL",
					"Rechazo Cliente ya Cuenta con Crédito Coppel", CURRENT, CURRENT);
					
					--dsb-30/05/2013
					UPDATE bdisolic:"informix".ss_resum_scor_fin SET situacion_especial = 'P', causa_situacion = '27',  evalua_cc = null, motivo_cc = null
					WHERE empresa = cEmpresa AND num_solicitud = cNumSolicitud;

                    RETURN  cCodRetorno,cNumcteBanco,cNumcteCoppel;
				END IF;
            ELSE
                SELECT ticket 
                INTO cTicket
                FROM bdinteg:"informix".si_huella_linea  -- SE OBTIENE EL TICKET CON EL NUM. DE CLIENTE
                WHERE numcte = cNumCte;

                IF NVL(cTicket,"") = '' THEN -- SI NO SE ENCUENTRA EN LA si_huella_linea SE BUSCA EN si_huella_linea_hist
                    SELECT ticket 
                    INTO cTicket
                    FROM bdinteg:"informix".si_huella_linea_hist a   
                    WHERE numcte = cNumCte
                        AND fecha_consulta = (SELECT MAX(fecha_consulta)
                                              FROM bdinteg:"informix".si_huella_linea_hist b 
                                              WHERE   numcte = cNumCte)
                        AND secuencia = (SELECT MAX(secuencia)
                                         FROM bdinteg:"informix".si_huella_linea_hist c 
                                         WHERE  numcte = cNumCte);
                END IF;

                IF NVL(cTicket,"") <> "" THEN   -- CON EL TICKET SE VALIDA QUE LA HUELLA NO CORRESPONDA A EMPLEADOS 
                     SELECT LIMIT 1 estado_proceso, num_mensaje, empresa, trim(cast(cliente as char(20)))
                     INTO cEdo_proceso, cNum_men, cEmpresaHuella, cNumcteCoppel
                     FROM bdinteg:"informix".si_huella_linea_resultado 
                     WHERE ticket = cTicket
                         AND estado_proceso = '2'
                         AND empresa IN (0,1,2,3,4)
                         AND num_mensaje = "602";
						 
						 IF nvl(cNumcteCoppel,'') = '' THEN
							 SELECT LIMIT 1 estado_proceso, num_mensaje, empresa, trim(cast(cliente as char(20)))
							 INTO cEdo_proceso, cNum_men, cEmpresaHuella, cNumcteCoppel
							 FROM bdinteg:"informix".si_huella_linea_resultado_hist 
							 WHERE ticket = cTicket
								 AND estado_proceso = '2'
								 AND empresa IN (0,1,2,3,4)
								 AND num_mensaje = "602";
						 END IF
                    IF 	NVL(cEdo_proceso,"") <> "" AND NVL(cNum_men,"") <> ""  AND 	NVL(cEmpresaHuella,"") <> "" THEN

                        IF EXISTS(SELECT 1 FROM bdisolic:"informix".ss_solicitudes 
                        WHERE num_producto = '6500' AND status_solicitud = 'AT' AND numcte = cNumCte) THEN
                            SELECT num_solicitud 
                            INTO cNumSolicitud
                            FROM bdisolic:"informix".ss_solicitudes 
                            WHERE num_producto = '6500' AND status_solicitud = 'AT'
                            AND numcte = cNumCte;

                            IF cEmpresaHuella = 4 THEN
                                -- SE ACTUALIZA EL ESTADO DE LA SOLICITUD
                                EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol
                                ('001', 'sistema',cNumSolicitud, 'RT','RCL', 'Rechazo Cliente ya Cuenta con Crédito Coppel')
                                INTO cCodRetorno;	

                                -- OCURRIÓ UN ERROR AL EJECUTAR EL PROCEDIMIENTO SP_ACTUALIZA_STATUS_SOL
                                IF cCodRetorno <> '000000' THEN
                                    LET cCodRetorno = '000004';
                                    RETURN  cCodRetorno,cNumcteBanco,cNumcteCoppel;
                                END IF;

                                -- ACTUALIZA LA SITUACION ESPECIAL Y SU CAUSA DE LA SOLICITUD COPPEL 6500
                                UPDATE bdisolic:"informix".ss_resum_scor_fin
                                SET situacion_especial = 'P',
                                    causa_situacion = 27,
                                    evalua_cc = null,
                                    motivo_cc = null
                                WHERE empresa = cEmpresa  
                                    AND num_solicitud = cNumSolicitud;
                            ELSE
                                -- SE ACTUALIZA EL ESTADO DE LA SOLICITUD
                                EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol
								('001', 'sistema',cNumSolicitud, 'CN','CGC', 'Cancelado por ser empleado de Grupo Coppel')
                                /**('001', 'sistema',cNumSolicitud, 'RT','RGC', 'Rechazo por ser Empleado del Grupo Coppel')**/
                                INTO cCodRetorno;	

                                -- OCURRIÓ UN ERROR AL EJECUTAR EL PROCEDIMIENTO SP_ACTUALIZA_STATUS_SOL
                                IF cCodRetorno <> '000000' THEN
                                    LET cCodRetorno= '000004';
                                    RETURN cCodRetorno,cNumcteBanco,cNumcteCoppel;
                                END IF;

                                -- SI LA SOL. ES DE COPPEL SE ACTUALIZA
                                -- LA SITUACION ESPECIAL Y SU CAUSA
                                    UPDATE bdisolic:"informix".ss_resum_scor_fin
                                    SET situacion_especial = 'P',
                                        causa_situacion = 23
                                    WHERE empresa = cEmpresa  
                                        AND num_solicitud = cNumSolicitud;						
                            END IF

                            LET cNumcteBanco = cNumCte;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
        RETURN  cCodRetorno,NVL(cNumcteBanco,''), NVL(cNumcteCoppel,'');
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento que busca la relacion de los clientes Banco con clientes Coppel, y en caso de encontrarla rechaza su solicitud',
'AUTOR : Victor Hugo Nuñez',
'FECHA : 02/05/2013',
'SOLICITO: Rodolfo Gomez',
'BD: bdinteg',
'Modificacion: Se valida los casos de desrelacion por parte de mesa de control y se actualiza el estatus de la solicitud a rechazado correctamente',
'AUTOR : Victor Hugo Nuñez',
'FECHA : 20/05/2013',
'SOLICITO: Rodolfo Gomez',
'Modificacion: Se añade actualizacion al estatus de la solicitud para marcarla con situacion especial en ss_resum_scor_fin',
'AUTOR : Victor Hugo Nuñez',
'FECHA : 30/05/2013',
'SOLICITO: Rodolfo Gomez',
'BD: bdinteg',
'Modificacion: Se añade validacion por el numero de solicitud y por numero de producto',
'AUTOR : Victor Hugo Nuñez',
'FECHA : 30/07/2013',
'SOLICITO: Rodolfo Gomez',
'BD: bdinteg',
'Modificacion: Se aÃ±ade cambio al estatus de RT a CN y causas RCB/RGC a CCB/CGC',
'AUTOR : Brando D. Garcia Lemus',
'FECHA : 06/05/2021',
'SOLICITO: Abraham Narvaez.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_relacionbancoppelcoppel_web(cEmpresa CHAR(3), cNumCte CHAR(20), cNumSolicitudP CHAR(20))
RETURNING
	CHAR(5)     AS Retorno ,           -- Codigo de Retorno
	CHAR(20)    AS ClienteBanco,       -- Nro de Cliente
	CHAR(20)    AS ClienteCoppel       -- Nro de Cliente

	-- DEFINICION DE VARIABLES
	DEFINE cCodRetorno		CHAR(5);
	DEFINE cNumcteCoppel	CHAR(20);
	DEFINE cNumcteBanco		CHAR(20);
	DEFINE cNumSolicitud	CHAR(20);
	DEFINE iSqlErr			INTEGER;

	DEFINE cTicket				   	CHAR(20); 
	DEFINE cEdo_proceso			   	CHAR(4); 
	DEFINE cNum_men				   	CHAR(3); 
    DEFINE cEmpresaHuella           CHAR(3);

	--INICIALIZACION DE VARIABLES
	LET cCodRetorno		= "00000";
	LET cNumcteCoppel	= "";
	LET cNumcteBanco	= "";
	LET cNumSolicitud	= "";
	LET iSqlErr			= 0;

	LET cEdo_proceso	   		=""; 
	LET cNum_men		   		=""; 
	LET cTicket			   		=""; 
    LET cEmpresaHuella          ="";
	
	--SET DEBUG FILE TO "/tmp/Victor/sp_relacionbancoppelcoppel.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','';
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--dsb-30/07/2013
		IF NVL(cNumSolicitudP, '') <> '' THEN
			SELECT num_solicitud
			INTO cNumSolicitud
			FROM bdisolic:"informix".ss_solicitudes 
			WHERE num_producto = '6500'
			AND num_solicitud = cNumSolicitudP AND numcte = cNumcte;
			IF NVL(cNumSolicitud, '') = '' THEN
				LET cCodRetorno = '00002';
				RETURN  cCodRetorno,cNumcteBanco,cNumcteCoppel;
			END IF;
		END IF;
		IF NVL(cEmpresa,'') = '' THEN
			LET cCodRetorno = '00001';
			RETURN  cCodRetorno,cNumcteBanco,cNumcteCoppel;
		ELSE
			--Verificar si no cuenta con una relacion coppel en la tabla si_relacion_ctebcplcpl
			SELECT cliente, numcte_banco
			INTO cNumcteCoppel, cNumcteBanco
			FROM bdinteg:"informix".si_relacion_ctebcplcpl 
			WHERE  empresa = cEmpresa AND numcte_banco = cNumCte AND tipo_relacion <> 0;
			
			IF NVL(cNumcteBanco,'') <> '' THEN
				--OBTENER LA SOLICITUD DE PRODUCTO 6500
				IF(SELECT count(num_solicitud) FROM bdisolic:"informix".ss_solicitudes 
				WHERE num_producto = '6500' AND status_solicitud = 'AT' AND empresa = cEmpresa AND numcte = cNumCte) > 0 THEN
					SELECT num_solicitud 
					INTO cNumSolicitud
					FROM bdisolic:"informix".ss_solicitudes 
					WHERE num_producto = '6500' AND status_solicitud = 'AT'
					AND numcte = cNumCte;
					
					UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "RT"
					WHERE empresa = cEmpresa
					AND num_solicitud = cNumSolicitud;

					INSERT INTO bdisolic:"informix".ss_autorizacion
					(empresa, ejecutivo_auto, num_solicitud, status_solicitud,causa_solicitud,
					comentario, fecha_entrada, fecha_salida)
					VALUES
					(cEmpresa, "sistema", cNumSolicitud, "RT", "RCL",
					"Rechazo Cliente ya Cuenta con CrÃ©dito Coppel", CURRENT, CURRENT);
					
					--dsb-30/05/2013
					UPDATE bdisolic:"informix".ss_resum_scor_fin SET situacion_especial = 'P', causa_situacion = '27',  evalua_cc = null, motivo_cc = null
					WHERE empresa = cEmpresa AND num_solicitud = cNumSolicitud;

                    RETURN  cCodRetorno,cNumcteBanco,cNumcteCoppel;
				END IF;
            ELSE
                SELECT ticket 
                INTO cTicket
                FROM bdinteg:"informix".si_huella_linea  -- SE OBTIENE EL TICKET CON EL NUM. DE CLIENTE
                WHERE numcte = cNumCte;

                IF NVL(cTicket,"") = '' THEN -- SI NO SE ENCUENTRA EN LA si_huella_linea SE BUSCA EN si_huella_linea_hist
                    SELECT ticket 
                    INTO cTicket
                    FROM bdinteg:"informix".si_huella_linea_hist a   
                    WHERE numcte = cNumCte
                        AND fecha_consulta = (SELECT MAX(fecha_consulta)
                                              FROM bdinteg:"informix".si_huella_linea_hist b 
                                              WHERE   numcte = cNumCte)
                        AND secuencia = (SELECT MAX(secuencia)
                                         FROM bdinteg:"informix".si_huella_linea_hist c 
                                         WHERE  numcte = cNumCte);
                END IF;

                IF NVL(cTicket,"") <> "" THEN   -- CON EL TICKET SE VALIDA QUE LA HUELLA NO CORRESPONDA A EMPLEADOS 
                     SELECT LIMIT 1 estado_proceso, num_mensaje, empresa, trim(cast(cliente as char(20)))
                     INTO cEdo_proceso, cNum_men, cEmpresaHuella, cNumcteCoppel
                     FROM bdinteg:"informix".si_huella_linea_resultado 
                     WHERE ticket = cTicket
                         AND estado_proceso = '2'
                         AND empresa IN (0,1,2,3,4)
                         AND num_mensaje = "602";
						 
						 IF nvl(cNumcteCoppel,'') = '' THEN
							 SELECT LIMIT 1 estado_proceso, num_mensaje, empresa, trim(cast(cliente as char(20)))
							 INTO cEdo_proceso, cNum_men, cEmpresaHuella, cNumcteCoppel
							 FROM bdinteg:"informix".si_huella_linea_resultado_hist 
							 WHERE ticket = cTicket
								 AND estado_proceso = '2'
								 AND empresa IN (0,1,2,3,4)
								 AND num_mensaje = "602";
						 END IF
                    IF 	NVL(cEdo_proceso,"") <> "" AND NVL(cNum_men,"") <> ""  AND 	NVL(cEmpresaHuella,"") <> "" THEN

                        IF(SELECT count(1) FROM bdisolic:"informix".ss_solicitudes 
                        WHERE num_producto = '6500' AND status_solicitud = 'AT' AND numcte = cNumCte) > 0 THEN
                            SELECT num_solicitud 
                            INTO cNumSolicitud
                            FROM bdisolic:"informix".ss_solicitudes 
                            WHERE num_producto = '6500' AND status_solicitud = 'AT'
                            AND numcte = cNumCte;

                            IF cEmpresaHuella = 4 THEN
                                -- SE ACTUALIZA EL ESTADO DE LA SOLICITUD
                                EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol
                                ('001', 'sistema',cNumSolicitud, 'RT','RCL', 'Rechazo Cliente ya Cuenta con CrÃ©dito Coppel')
                                INTO cCodRetorno;	

                                -- OCURRIO UN ERROR AL EJECUTAR EL PROCEDIMIENTO SP_ACTUALIZA_STATUS_SOL
                                IF cCodRetorno <> '00000' THEN
                                    LET cCodRetorno = '00004';
                                    RETURN  cCodRetorno,cNumcteBanco,cNumcteCoppel;
                                END IF;

                                -- ACTUALIZA LA SITUACION ESPECIAL Y SU CAUSA DE LA SOLICITUD COPPEL 6500
                                UPDATE bdisolic:"informix".ss_resum_scor_fin
                                SET situacion_especial = 'P',
                                    causa_situacion = 27,
                                    evalua_cc = null,
                                    motivo_cc = null
                                WHERE empresa = cEmpresa  
                                    AND num_solicitud = cNumSolicitud;
                            ELSE
                                -- SE ACTUALIZA EL ESTADO DE LA SOLICITUD
                                EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol
                                ('001', 'sistema',cNumSolicitud, 'CN','CGC', 'Cancelado por ser empleado de Grupo Coppel')
                                /**('001', 'sistema',cNumSolicitud, 'RT','RGC', 'Rechazo por ser Empleado del Grupo Coppel')**/
                                INTO cCodRetorno;	

                                -- OCURRIO UN ERROR AL EJECUTAR EL PROCEDIMIENTO SP_ACTUALIZA_STATUS_SOL
                                IF cCodRetorno <> '00000' THEN
                                    LET cCodRetorno= '00004';
                                    RETURN cCodRetorno,cNumcteBanco,cNumcteCoppel;
                                END IF;

                                -- SI LA SOL. ES DE COPPEL SE ACTUALIZA
                                -- LA SITUACION ESPECIAL Y SU CAUSA
                                    UPDATE bdisolic:"informix".ss_resum_scor_fin
                                    SET situacion_especial = 'P',
                                        causa_situacion = 23
                                    WHERE empresa = cEmpresa  
                                        AND num_solicitud = cNumSolicitud;						
                            END IF

                            LET cNumcteBanco = cNumCte;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
        RETURN  cCodRetorno,NVL(cNumcteBanco,''), NVL(cNumcteCoppel,'');
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento que busca la relacion de los clientes Banco con clientes Coppel, y en caso de encontrarla rechaza su solicitud',
'AUTOR : Victor Hugo NuÃ±ez',
'FECHA : 02/05/2013',
'SOLICITO: Rodolfo Gomez',
'BD: bdinteg',
'Modificacion: Se valida los casos de desrelacion por parte de mesa de control y se actualiza el estatus de la solicitud a rechazado correctamente',
'AUTOR : Victor Hugo NuÃ±ez',
'FECHA : 20/05/2013',
'SOLICITO: Rodolfo Gomez',
'Modificacion: Se aÃ±ade actualizacion al estatus de la solicitud para marcarla con situacion especial en ss_resum_scor_fin',
'AUTOR : Victor Hugo NuÃ±ez',
'FECHA : 30/05/2013',
'SOLICITO: Rodolfo Gomez',
'BD: bdinteg',
'Modificacion: Se aÃ±de validacion por el numero de solicitud y por numero de producto',
'AUTOR : Victor Hugo NuÃ±ez',
'FECHA : 30/07/2013',
'SOLICITO: Rodolfo Gomez',
'BD: bdinteg',
'Modificacion: Se aÃ±ade cambio al estatus de RT a CN y causas RCB/RGC a CCB/CGC',
'AUTOR : Brando D. Garcia Lemus',
'FECHA : 06/05/2021',
'SOLICITO: Abraham Narvaez.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_conciliarcatalogozonas()

RETURNING CHAR(6), CHAR(80);
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                     	CHAR(6);
DEFINE cMensaje                     	CHAR(80);
DEFINE vfechahoy                        DATE;
-----------------------------------------------------------
DEFINE vnumerociudad                    INTEGER;
DEFINE vnumerocolonia                   INTEGER;
DEFINE vnombrezona                      CHAR(32);
DEFINE vpoblacionzona                   CHAR(27);
DEFINE vmunicipiozona                   CHAR(27);
DEFINE vcodigopostalzona                INTEGER;  
DEFINE vsupervisorzona                  INTEGER;
DEFINE vchoferzona                      INTEGER;
DEFINE vjefegrupozona                   INTEGER;
DEFINE vgerentezona                     INTEGER;
DEFINE vabogadozona                     INTEGER;
DEFINE vcentro                          INTEGER;
DEFINE vciudadcobranzas                 INTEGER;
DEFINE vnumerocobranzas                 INTEGER;
DEFINE vnumerociudadcoppel              INTEGER;
DEFINE vnumerocoloniacoppel             INTEGER;
DEFINE vnombrezonacoppel                CHAR(32);

DEFINE v_numerociudad                    INTEGER;
DEFINE v_numerocolonia                   INTEGER;
DEFINE v_nombrezona                      CHAR(32);
DEFINE v_poblacionzona                   CHAR(27);
DEFINE v_municipiozona                   CHAR(27);
DEFINE v_codigopostalzona                INTEGER;  
DEFINE v_supervisorzona                  INTEGER;
DEFINE v_choferzona                      INTEGER;
DEFINE v_jefegrupozona                   INTEGER;
DEFINE v_gerentezona                     INTEGER;
DEFINE v_abogadozona                     INTEGER;
DEFINE v_centro                          INTEGER;
DEFINE v_ciudadcobranzas                 INTEGER;
DEFINE v_numerocobranzas                 INTEGER;
DEFINE v_numerociudadcoppel              INTEGER;
DEFINE v_numerocoloniacoppel             INTEGER;
DEFINE v_nombrezonacoppel                CHAR(32);

DEFINE vdia                             DATE;
DEFINE vHora                            CHAR(8);
DEFINE vEmpresa                         CHAR(3);
DEFINE vProceso                         CHAR(30);
DEFINE vProcesoinicio                   CHAR(30);
DEFINE cUSRCOPPEL                       CHAR(10);

DEFINE vErroneas						INTEGER;
DEFINE vTotalzonasrelacionadas          INTEGER;
DEFINE vTotalRegBcpl					INTEGER;
DEFINE vTotalRegCop 					INTEGER;
DEFINE csql                 			CHAR(500);
DEFINE vTotalRegErr						INTEGER;
DEFINE vTotalRegDup						INTEGER;
DEFINE vTotalRegIns						INTEGER;
DEFINE vTotalRegMod						INTEGER;
DEFINE vRuta							CHAR(100);
DEFINE iResult_upd                      INTEGER;

---------------------------------------------------------
LET vnumerociudad                    = 0;
LET vnumerocolonia                   = 0;
LET vnombrezona                      = '';
LET vpoblacionzona                   = '';
LET vmunicipiozona                   = '';
LET vcodigopostalzona                = 0;  
LET vsupervisorzona                  = 0;
LET vchoferzona                      = 0;
LET vjefegrupozona                   = 0;
LET vgerentezona                     = 0;
LET vabogadozona                     = 0;
LET vcentro                          = 0;
LET vciudadcobranzas                 = 0;
LET vnumerocobranzas                 = 0;
LET vnumerociudadcoppel              = 0;
LET vnumerocoloniacoppel             = 0;
LET vnombrezonacoppel                = '';

LET v_numerociudad                    = 0;
LET v_numerocolonia                   = 0;
LET v_nombrezona                      = '';
LET v_poblacionzona                   = '';
LET v_municipiozona                   = '';
LET v_codigopostalzona                = 0;  
LET v_supervisorzona                  = 0;
LET v_choferzona                      = 0;
LET v_jefegrupozona                   = 0;
LET v_gerentezona                     = 0;
LET v_abogadozona                     = 0;
LET v_centro                          = 0;
LET v_ciudadcobranzas                 = 0;
LET v_numerocobranzas                 = 0;
LET v_numerociudadcoppel              = 0;
LET v_numerocoloniacoppel             = 0;
LET v_nombrezonacoppel                = '';
LET vEmpresa                          = '001';
LET cUSRCOPPEL                        = 'SYSCARTERA';
LET iResult_upd                       = 0;
-----------------------------------------------------------
LET cCod_ret      	= '00000';
LET sql_err       	= 0;
LET cMensaje     	= 'Proceso Exitoso';
LET vProceso      	= 'sp_conciliarcatalogozonas';
LET vProcesoinicio 	= 'PROCESO INICIALIZADO';
-----------------------------------------------------------
    BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
           
            INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
            VALUES (vProceso, cCod_ret, cMensaje, user, vdia, vHora, null); 
          
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------       
--Creado por José Almeida
--Fecha de creacion 22 de octubre de 2009
--Deberá instalarse en BDINTEG
--Se creo para el conciliamiento de datos de las zonas que existen en el catalogo de coppelcon los de bancoopel, aquellas zonas que existen en
--coppel y no bancoppel seran insertadas en el catalogo y aquellas que tienen diferencia entre sus campos
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Modificado por Marco A. Campos 
--Fecha: 20100614
--Para que actualice en tabla si_catzonas         
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Modificado por Marco A. Campos el 20110328
--Se modifica la estructura de tabla si_catzonas_bcpl_cpl y se guarda la fecha inserción o fecha modificación en si_catzonas, dependiendo del caso.
--Modificado por Marco A. Campos el 20110407
--Agregar dato para usr_modifica (SYSCARTERA) en si_catzonas. 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Modificado por Abrham Lopez L.
--Fecha 24-04-2012
--Se le metio validación para que no inserte ciudades en cero.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Modificado por Abrham Lopez L.
--Fecha 25-07-2012
--Se modifica para generar archivo de cifras control y archivo de detallescon zonas Erroneas, Duplicadas, Modificadas y Insertadas
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
     --SET DEBUG FILE TO "/informix/ALL/SP_ConciliarCatalogoZonas.out";
     --TRACE ON;
       
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
	   
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
        
        INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
        VALUES (vProceso,'11111' , vProcesoinicio, user, vdia, vHora, null); 
       
        ---------------Obtenemos la fecha de Hoy-----------------
        SELECT prox_fecha--fecha_hoy 
        INTO   vfechahoy
        FROM   bdinteg:si_fechas WHERE empresa = '001';        
		
		--LET vfechahoy = mdy('02','04','2022');   --- SOLO TEST MACF

        ---------------Borramos los datos de la tabla para insertar nuevos conciliados--------
        --DELETE si_catzonas_bcpl_cpl; ALL se inive esta opcion en este sp para ponerlo en el sp_importarcatalogozonas
        
        UPDATE statistics medium FOR TABLE bdinteg:"informix".si_catzonas_coppel;
        --------------Obtenemos los datos de las dos tablas y cuando no existan en bancoopel-----
        --------------se insertaran en el catalogo de bancoopel-----------------------------------       
         FOREACH
			SELECT  a.numerociudad,a.numerocolonia,a.nombrezona,a.poblacionzona,a.municipiozona,a.codigopostalzona
				   ,a.supervisorzona,a.choferzona,a.jefegrupozona,a.gerentezona,a.abogadozona,a.centro,a.ciudadcobranzas,a.numerocobranzas,a.numerociudadcoppel
				   ,a.numerocoloniacoppel,a.nombrezonacoppel,
					b.numerociudad,b.numerocolonia,b.nombrezona,b.poblacionzona,b.municipiozona,b.codigopostalzona
				   ,b.supervisorzona,b.choferzona,b.jefegrupozona,b.gerentezona,b.abogadozona,b.centro,b.ciudadcobranzas,b.numerocobranzas,b.numerociudadcoppel
				   ,b.numerocoloniacoppel,b.nombrezonacoppel
			 INTO   vnumerociudad,vnumerocolonia,vnombrezona,vpoblacionzona,vmunicipiozona,vcodigopostalzona
				   ,vsupervisorzona,vchoferzona,vjefegrupozona,vgerentezona,vabogadozona,vcentro,vciudadcobranzas,vnumerocobranzas,vnumerociudadcoppel
				   ,vnumerocoloniacoppel,vnombrezonacoppel,
					v_numerociudad,v_numerocolonia,v_nombrezona,v_poblacionzona,v_municipiozona,v_codigopostalzona
				   ,v_supervisorzona,v_choferzona,v_jefegrupozona,v_gerentezona,v_abogadozona,v_centro,v_ciudadcobranzas,v_numerocobranzas,v_numerociudadcoppel
				   ,v_numerocoloniacoppel,v_nombrezonacoppel
			  FROM  bdinteg:si_catzonas_coppel a
			  LEFT OUTER JOIN bdinteg:si_catzonas b ON (a.numerociudad = b.numerociudad AND a.numerocolonia = b.numerocolonia) 
	
		            
                              --IF ( v_numerociudad IS NULL )  THEN
							  
	--A.L.L. SE MODIFICA VALIDACION PARA QUE NO PERMITA INSERTAR CIUDADES IGUAL A CERO.
		IF ( NVL(v_numerociudad,'') ='' )  AND (Nvl(vnumerociudad,0) <> 0) THEN 
                    
          INSERT INTO BDINTEG:si_catzonas_bcpl_cpl(numerociudad, fecha_conciliacion, numerocolonia, numerociudadcoppel, numerocoloniacoppel,nombrezonacoppel,tipo_actualizacion)                                         
                                           VALUES (vnumerociudad, vfechaHoy, vnumerocolonia, vnumerociudadcoppel, vnumerocoloniacoppel, vnombrezonacoppel, 'I' );
                                                   
          INSERT INTO BDINTEG:si_catzonas(numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, supervisorzona, choferzona, 
										  jefegrupozona, gerentezona, abogadozona, centro,ciudadcobranzas, numerocobranzas, f_inserta, usr_modifica, numerociudadcoppel,
										  numerocoloniacoppel,nombrezonacoppel)
                                   VALUES (vnumerociudad, vnumerocolonia, vnombrezona, vpoblacionzona, vmunicipiozona, vcodigopostalzona, vsupervisorzona, vchoferzona,
										  vjefegrupozona, vgerentezona, vabogadozona, vcentro, vciudadcobranzas, vnumerocobranzas, vfechahoy,cUSRCOPPEL, vnumerociudadcoppel,
										  vnumerocoloniacoppel, vnombrezonacoppel);

		  UPDATE BDINTEG:si_catzonas_coppel SET b_conciliado = 'V' WHERE numerociudad = vnumerociudad  AND numerocolonia = vnumerocolonia;             
CONTINUE FOREACH;     
                              
	END IF;
          
          IF    (  (nvl(vcodigopostalzona,0) <> nvl(v_codigopostalzona,0))
                OR (nvl(vsupervisorzona,0) <> nvl(v_supervisorzona,0))    
                OR (nvl(vchoferzona,0) <> nvl(v_choferzona,0)) 
                OR (nvl(vjefegrupozona,0) <> nvl(v_jefegrupozona,0))
                OR (nvl(vgerentezona,0) <> nvl(v_gerentezona,0)) 
                OR (nvl(vabogadozona,0) <> nvl(v_abogadozona,0))
                OR (nvl(vcentro,0) <> nvl(v_centro,0))
                OR (nvl(vciudadcobranzas,0) <> nvl(v_ciudadcobranzas,0))
                OR (nvl(vnumerocobranzas,0) <> nvl(v_numerocobranzas,0))
                OR (nvl(vnumerociudadcoppel,0) <> nvl(v_numerociudadcoppel,0))
                OR (nvl(vnumerocoloniacoppel,0) <> nvl(v_numerocoloniacoppel,0))
                 ) THEN 
                                                                 
                INSERT INTO BDINTEG:si_catzonas_bcpl_cpl(numerociudad, fecha_conciliacion, numerocolonia, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel,tipo_actualizacion)                                         
                                                 VALUES (vnumerociudad, vfechaHoy, vnumerocolonia, vnumerociudadcoppel, vnumerocoloniacoppel, vnombrezonacoppel, 'M' );
     
                UPDATE BDINTEG:si_catzonas SET codigopostalzona = vcodigopostalzona, supervisorzona = vsupervisorzona, choferzona = vchoferzona,
                                               jefegrupozona = vjefegrupozona, gerentezona = vgerentezona, abogadozona = vabogadozona, centro = vcentro,
                                               ciudadcobranzas = vciudadcobranzas, numerocobranzas = vnumerocobranzas, numerociudadcoppel = vnumerociudadcoppel,
                                               numerocoloniacoppel = vnumerocoloniacoppel, nombrezonacoppel = vnombrezonacoppel, f_modifica = vfechaHoy,
                                               usr_modifica = cUSRCOPPEL WHERE numerociudad = vnumerociudad  AND numerocolonia = vnumerocolonia
											   AND (NVL(nomzona_spmx,'') = '' and nvl(mnpio_spmx,'') = '' and nvl(pobzona_spmx,'') = '');
                
                LET iResult_upd = DBINFO("sqlca.sqlerrd2"); 
		
		        IF iResult_upd = 0 THEN
				   -- Si no lo actualizó arriba por no encontrarlo, dejar que lo actualice menos el CP
				   UPDATE BDINTEG:si_catzonas SET supervisorzona = vsupervisorzona, choferzona = vchoferzona,
                                               jefegrupozona = vjefegrupozona, gerentezona = vgerentezona, abogadozona = vabogadozona, centro = vcentro,
                                               ciudadcobranzas = vciudadcobranzas, numerocobranzas = vnumerocobranzas, numerociudadcoppel = vnumerociudadcoppel,
                                               numerocoloniacoppel = vnumerocoloniacoppel, nombrezonacoppel = vnombrezonacoppel, f_modifica = vfechaHoy,
                                               usr_modifica = cUSRCOPPEL WHERE numerociudad = vnumerociudad  AND numerocolonia = vnumerocolonia;
				END IF;
				
				UPDATE BDINTEG:si_catzonas_coppel SET b_conciliado = 'V' WHERE numerociudad = vnumerociudad  AND numerocolonia = vnumerocolonia;
			--A.L.L. SE INSERTAN ZONAS RELACIONADAS EN LA TABLA si_catzonas_bcpl_cpl		
				IF (nvl(vnumerociudadcoppel,0) > 0
					and nvl(vnumerocoloniacoppel,0) > 0 
					and nvl(vnumerociudadcoppel,0) <> nvl(v_numerociudadcoppel,0)
					and nvl(vnumerocoloniacoppel,0) <> nvl(v_numerocoloniacoppel,0)) THEN
				
					INSERT INTO BDINTEG:si_catzonas_bcpl_cpl(numerociudad, fecha_conciliacion, numerocolonia, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel,tipo_actualizacion)                                         
													 VALUES (vnumerociudad, vfechaHoy, vnumerocolonia, vnumerociudadcoppel, vnumerocoloniacoppel, vnombrezonacoppel, 'R' );
			END IF;
             
      END IF;        
    END FOREACH;
   
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
		
---------------------------------A.L.L. GENERAMOS EL ARCHIVO DE CIFRAS CONTROL----------------------------------------------------------		
--A.L.L. SACAMOS EL TOTAL DE LAS DOS TABLAS PARA SUMAR Y QUE NOS DE EL TOTAL DE NUEROS DE REGISTROS RECIBIDOS

	--A.L.L. SACAMOS LA RUTA DONDE DEPOSITAREMOS EL ARCHIVO
		SELECT trim(valor) into vRuta
		  FROM bdinteg:si_param_dom
         WHERE empresa = '001' AND cod_param = 11;    --11;productivo,  24 pruevas
		 
		  --LET vRuta = '/ifxsif01/macf/';   -- SOLO TEST MACF
		 
	--A.L.L SACAMOS EL TOTAL DE ZONAS.
		SELECT COUNT(*)total
		INTO vTotalRegCop
		FROM bdinteg:si_catzonas_coppel;	
		
	--A.L.L. SACAMOS EL TOTAL DE ZONAS ERRONEAS Y DUPLICADAS
		SELECT COUNT(*)total 
		INTO vTotalRegBcpl
		FROM bdinteg:si_catzonas_bcpl_cpl 
		WHERE tipo_actualizacion  in ('E', 'D');
		
	--A.L.L. SACAMOS EL REGISTRO DE ZONAS ERRONEOS    
		SELECT count(*) E
		INTO vTotalRegErr
		FROM bdinteg:si_catzonas_bcpl_cpl
		WHERE tipo_actualizacion = 'E';
	--A.L.L. SACAMOS EL REGISTRO DE ZONAS DUPLICADAS    
		SELECT count(*) D
		INTO vTotalRegDup
		FROM bdinteg:si_catzonas_bcpl_cpl
		WHERE tipo_actualizacion = 'D';
	--A.L.L. SACAMOS EL REGISTRO DE ZONAS INSERTADAS    
		SELECT count(*) I
		INTO vTotalRegIns
		FROM bdinteg:si_catzonas_bcpl_cpl
		WHERE tipo_actualizacion = 'I';
	--A.L.L. SACAMOS EL REGISTRO DE ZONAS MODIFICADAS    
		SELECT count(*) M
		INTO vTotalRegMod
		FROM bdinteg:si_catzonas_bcpl_cpl
		WHERE tipo_actualizacion = 'M';
			
	--A.L.L. GENERAMOS EL ARCHIVO DE CIFRAS CONTROL	  
		LET cSql='';
		LET csql = 'echo "Fecha, Totalzonasrecibidas, Totalzonaserroneas, Totalzonasduplicadas, Totalzonasinsertadas, Totalzonasmodificadas, Totalzonasrelacionadas" >'||TRIM(vRuta)||'Cifrasrcatzonas'||LPAD(day(vfechaHoy),2,"0")||LPAD(MONTH(vfechaHoy),2,"0")||year(vfechaHoy)||'.txt';		 
		SYSTEM csql; 
	--A.L.L. SACAMOS LOS DATOS A INSERTAR EN EL ARCHIVO    
		LET csql = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vRuta)||'Cifrasrcatzonas_1.unl'|| ' DELIMITER ' || ''','''|| 
		' select '''||vfechaHoy||''',' ||(vTotalRegCop + vTotalRegBcpl)||','||vTotalRegErr||','||vTotalRegDup||','||vTotalRegIns||','||vTotalRegMod||','||'round(count(*))::integer total_rel from si_catzonas_bcpl_cpl where tipo_actualizacion = ''R'' ;'|| 
		' " > '''||TRIM(vRuta)||'''Cifrasrcatzonas_1.sql';
		SYSTEM csql;
		
		LET csql = '';
		LET csql= 'dbaccess bdinteg  '||TRIM(vRuta)||'Cifrasrcatzonas_1.sql';
		SYSTEM csql;
	--A.L.L. BORRAMOS ARCHIVOS YA NO NECSARIOS
		LET csql ='';
		LET csql ='rm  '||TRIM(vRuta)||'Cifrasrcatzonas_1.sql';
		SYSTEM csql;
		
		LET csql ='';
		LET csql = "sed 's/|$//g' "||TRIM(vRuta)||"Cifrasrcatzonas_1.unl >>"||TRIM(vRuta)||"Cifrasrcatzonas"||LPAD(day(vfechaHoy),2,"0")||LPAD(MONTH(vfechaHoy),2,"0")||year(vfechaHoy)||".txt";
		SYSTEM csql;
	--A.L.L. BORRAMOS ARCHIVOS YA NO NECSARIOS		
		LET csql ='rm  '||TRIM(vRuta)||'Cifrasrcatzonas_1.unl';
		SYSTEM csql; 	
		
------------------------------------------------A.L.L. GENERAMOS EL ARCHIVO DE ZONAS ERRONEAS Y DUPLICADAS-----------------------------------------------------------------

	--A.L.L. GENERAMOS EL ARCHIVO DE ZONAS ERRONEAS Y DUPLICADAS	  
		LET cSql='';
		LET csql = 'echo "numerociudad, numerocolonia, fecha_conciliacion, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel, tipo_actualizacion" >'||TRIM(vRuta)||'Detallercatzonas'||LPAD(day(vfechaHoy),2,"0")||LPAD(MONTH(vfechaHoy),2,"0")||year(vfechaHoy)||'.txt';
		SYSTEM csql; 
	--A.L.L. SACAMOS LOS DATOS A INSERTAR EN EL ARCHIVO	 
		LET csql = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vRuta)||'cifrasrcatzonas_1.unl'|| ' DELIMITER ' || '''|'''||
		' select numerociudad, numerocolonia, fecha_conciliacion, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel, tipo_actualizacion from si_catzonas_bcpl_cpl where tipo_actualizacion in (''E'',''D'',''I'',''M'',''R'') order by tipo_actualizacion; '||
		' " > '''||TRIM(vRuta)||'''cifrasrcatzonas_1.sql';
		SYSTEM csql;
		
		LET csql = '';
		LET csql= 'dbaccess bdinteg  '||TRIM(vRuta)||'cifrasrcatzonas_1.sql'; 
		SYSTEM csql;
	--A.L.L. BORRAMOS ARCHIVOS YA NO NECSARIOS
		LET csql ='';
		LET csql ='rm  '||TRIM(vRuta)||'cifrasrcatzonas_1.sql';
		SYSTEM csql;
	
		LET csql ='';                                                 
		LET csql = "sed 's/|$//g' "||TRIM(vRuta)||"cifrasrcatzonas_1.unl >>"||TRIM(vRuta)||"Detallercatzonas"||LPAD(day(vfechaHoy),2,"0")||LPAD(MONTH(vfechaHoy),2,"0")||year(vfechaHoy)||".txt";
		SYSTEM csql;
	--A.L.L. BORRAMOS ARCHIVOS YA NO NECSARIOS		
		LET csql ='rm  '||TRIM(vRuta)||'cifrasrcatzonas_1.unl';
		SYSTEM csql; 
       
        INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
            VALUES (vProceso, cCod_ret, cMensaje, user, vdia, vHora, null); 
           
                 RETURN cCod_ret, cMensaje;
        END;
        END PROCEDURE;