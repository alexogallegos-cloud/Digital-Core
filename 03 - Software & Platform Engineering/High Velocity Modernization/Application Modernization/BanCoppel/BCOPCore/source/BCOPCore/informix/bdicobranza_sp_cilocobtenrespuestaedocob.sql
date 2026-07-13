CREATE PROCEDURE "informix".sp_cilocobtenrespuestaedocob()
		RETURNING   CHAR(5) as Codigo,	--codret
					CHAR(75) as Descripcion;	---Declaracion de variables				
	DEFINE  cCodRet CHAR(5);
	DEFINE  cCodRet2 CHAR(5);
	DEFINE  iCont   INTEGER;
	DEFINE  iSqlErr INTEGER;
	DEFINE  cDescripcion CHAR(75);
	DEFINE  cNumcte CHAR(20);
	DEFINE  cUsuario CHAR(20);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSitEspecial CHAR(1);
	DEFINE sCausaSE SMALLINT;
	DEFINE cNumCredito  CHAR(20);
	DEFINE  cTipoMarca_loc CHAR(4); 
	DEFINE  cTipoMarca_tra CHAR(4);
	DEFINE  cTipoMarca_ref CHAR(4);
	DEFINE  vCausa SMALLINT;
	DEFINE  vSituacionEsp CHAR(1);

	--Se inicializan las variables

	LET cCodRet = '00000';
	LET cCodRet2 = '00000';
	LET iSqlErr = 0;
	LET icont=0;
	LET cDescripcion= 'PROCESO EXITOSO';
	LET cNumcte='';
	LET cUsuario='';
	LET cEmpresa='';
	LET cSitEspecial='';
	LET sCausaSE=0;
	LET cNumCredito='';
	LET cTipoMarca_loc =''; 
	LET cTipoMarca_tra ='';
	LET cTipoMarca_ref ='';
	LET vCausa=0;
	LET vSituacionEsp='';

	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_CiLocObtenRespuestaEdoCob.out';
	--TRACE ON;
	--------------------------------------------------------------------------	
	BEGIN
	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		LET cDescripcion='Error de Informix';
		RETURN cCodRet,cDescripcion;
	END EXCEPTION;		
	
	SET ISOLATION TO dirty READ; -- Lectura de tablas bloqueadas.
	--Se obtienen los valores que se encuentran parametrizados en la tabla cb_param que serán necesarios durante este proceso.
	SELECT NVL(valor,0)
	INTO cUsuario				--Usuario Necesario para la ejecución de los sps: sp_eliminarse y sp_sustituirse.
	FROM bdicobranza:cb_param 
	WHERE cod_param = '19';

	SELECT NVL(valor,0)
	INTO vCausa					--Causa Necesaria para la ejecucion del sp_sustituirse, Causa por la cual será reemplazada la anterior.
	FROM bdicobranza:cb_param 
	WHERE cod_param = '31';
	
	SELECT NVL(valor,0)
	INTO vSituacionEsp			--Situación Necesaria para la ejecucion del sp_sustituirse, Situacion por la cual será reemplazada la anterior.
	FROM bdicobranza:cb_param 
	WHERE cod_param = '30';

	---Se checa si existen clientes con situacion especial L 
	IF EXISTS(SELECT numcte FROM bdisitesp:se_ctessitespcte WHERE situacion in ('L')) THEN

	FOREACH WITH HOLD
		--Se obtiene un cliente, su empresa, situacion y causa , solo con situaciones L.
		SELECT NVL(empresa,0),NVL(numcte,0),NVL(situacion,0),NVL(causa,0)
		INTO cEmpresa,cNumcte,cSitEspecial,sCausaSE
		FROM bdisitesp:se_ctessitespcte
		WHERE situacion in ('L')
		--Se obtienen el numero de credito del cliente con los siguientes estatus: 'AA','BT','BA'
		SELECT NVL(num_credito,0) 
		INTO cNumCredito
		FROM bdicred:sd_maecred 
		WHERE numcte=cNumcte AND status_cred IN ('AA','BT','BA','E1','E2','E3');
			---Se checa si existe el cliente en el catalogo de marcas
			IF EXISTS (SELECT numcte FROM bdicobranza:cb_marcacliente WHERE numcte=cNumcte) THEN
				---Se obtiene el tipo de Marca de cada domicilio del cliente solo con estatus sin atender.
				SELECT NVL(Tipo_Marca,'')
				INTO cTipoMarca_loc
				FROM bdicobranza:cb_marcacliente
				WHERE numcte=cNumcte AND tipo_domicilio='1' AND estatus='SA'; 
	
				SELECT NVL(Tipo_Marca,'')
				INTO cTipoMarca_tra
				FROM bdicobranza:cb_marcacliente
				WHERE numcte=cNumcte AND tipo_domicilio='2' AND estatus='SA'; 
			
				SELECT NVL(Tipo_Marca,'')
				INTO cTipoMarca_ref
				FROM bdicobranza:cb_marcacliente
				WHERE numcte=cNumcte AND tipo_domicilio='3' AND estatus='SA'; 

				IF cTipoMarca_Loc IS NULL THEN 
				    LET cTipoMarca_Loc='PL';
				END IF;
				IF cTipoMarca_tra IS NULL THEN 
					LET cTipoMarca_tra='PL';
				END IF;
				IF cTipoMarca_ref IS NULL THEN 
					LET cTipoMarca_ref='PL';				
				END IF;
				
			--Significados de las marcas:
				--* CM.- Candidato a M 
				--* LV.- L a verificar 
				--* BL.- Borrar a L
				--* PL.- Sin repuesta
				
			--Se realiza las validaciones necesarias para determinar el resulta final del estado de cobranza		
			IF (cTipoMarca_loc='LV' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='LV') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='BL') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='CM') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='PL') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='LV')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='BL')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='CM') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='PL')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='LV')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='BL')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='CM') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='PL') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='LV') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='BL') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='CM')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='PL')
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='LV')
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='BL')					
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='CM') 
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='CM') 
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='LV')
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='LV') THEN

					---Se ejecuta el sp que inserta en la tabla cb_cteedocobloc por numero de cliente.
							EXECUTE PROCEDURE bdicobranza:sp_CiLocGeneraArchivoCobranza(cNumcte) INTO cCodRet2;
						CONTINUE FOREACH;
				
			ELIF (cTipoMarca_loc='BL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='LV') 
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='BL') 
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='CM') 
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='LV') THEN 
					--En esta condicion se requiere realizar el desmarcaje del estatus L, debido a esto se hace el llamado al procedimiento que realiza dicha operación.
							EXECUTE PROCEDURE bdisitesp:sp_eliminarse(cNumcte,
								 cEmpresa,
								 cNumCredito,
								 cSitEspecial,
								 sCausaSE	,
								 cUsuario,
								 cUsuario,
								 1 ,	--1.- Cliente, 2.- Credito
								 1		--1.- Individual, 2.- General
								) INTO cCodRet2;
						
			ELIF (cTipoMarca_loc='CM' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='CM') THEN 
					--En esta condicion se requiere realizar el marcaje a estatus M, debido a esto se hace el llamado al procedimiento que realiza dicha operación.	
							EXECUTE PROCEDURE bdisitesp:sp_sustituirse(cNumcte,
								 cEmpresa,
								 cNumCredito,
								 vSituacionEsp,
								 vCausa,
								 cUsuario,
								 cUsuario,
								 1 	--1.- Cliente, 2.- Credito
								 ) INTO cCodRet2;
			
			ELIF (cTipoMarca_loc='CM' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='PL') THEN 
					---Esta condición no realiza operación debido a que su resultado final es permanecer en estatus L.
			END IF;
		END IF;
		IF cCodRet2 <> 0 THEN
			LET cCodRet='00002'; 
			LET cDescripcion='En almenos algún llamado no se completo exitosamente';
		END IF;
	END FOREACH;
	ELSE
			LET cCodRet='00001';  
			LET cDescripcion='No Hay clientes con situacion especial';
	END IF;
	RETURN cCodRet,cDescripcion;
	END;	 
END PROCEDURE

DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Realiza un proceso de evaluacion final referente a los clientes con situacion especial',
'FECHA       : 31 de Agosto de 2010',
'VERSION     : 20100831.1230',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_clientevencido(pEmpresa CHAR(3), pNumCliente CHAR(20))

    RETURNING VARCHAR (6);

    -- 15/07/2008
    -- Creado por:
    -- Abraham Ayala Aguilar
    -- Consulta si el cliente tiene creditos vencidos.

	-- 10-10-2008
	-- Modifico:
	-- Abraham Ayala
	-- Se sustituyo la manera de consultar si el cliente tiene cuentas vencidas, ahora se calcula conforme a la fecha de vencido,
    -- atraves del SP_dias_vencido.

    -- 30-10-2008
    -- Modifico:
    -- Walberto Castro
    -- Se agrego la validacion de cuando los días vencidos sean mayor que 165 días se regrese el codigo de retorno 003.

    -- 12-06-2009
    -- Modifico:
    -- Bernardo Carlos Báez González
    -- Se modifico para revisar si el Cliente-Cuenta tiene un compromiso o acuerdo vigente y Marcar los compromisos cumplidos.
    -- Esto solo aplicara cuando se efectue un pago de tarjeta de credito en bdicred:sd_movdia para el cliente-Cuenta que se esta
    -- evaluando.
	--19-09-2012
	--Se depura codigo que no se utiliza y se agrega validación para tomar en cuenta solo creditos con estatus BA y BT para realizar convenios.

--DEFINICION DE VARIABLES--
    DEFINE vCod_Ret       VARCHAR (6);
    DEFINE iSqlErr        INTEGER;
    DEFINE vStatus       INTEGER;
    DEFINE vNumCredito    CHAR(20);
	DEFINE vmSuma   MONEY(18,2);
    DEFINE vmCatidadAcordada    MONEY(18,2);
    DEFINE vdFechaAcuerdo DATE;

--    Set debug file to '/tmp/sp_clientevencido_pba.out';
--    trace on;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCod_Ret = iSqlErr;
                RETURN vCod_Ret;
            END IF;
        END EXCEPTION;


--INICIALIZACION DE VARIABLES--
        LET vCod_Ret = "000";   --No tiene cuentas vencidas
        LET vmSuma = 0.00;
        LET vmCatidadAcordada = 0.00;
		

        IF (pEmpresa IS NOT NULL and pEmpresa <> '') AND (pNumCliente IS NOT NULL and pNumCliente <> '') THEN

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		       FOREACH
			   
                SELECT a.num_credito INTO vNumCredito
                FROM bdicred:"informix".sd_maecred a
				INNER JOIN bdicred:sd_maesdos b ON b.num_credito = a.num_credito
                WHERE a.empresa = pEmpresa AND a.numcte = pNumCliente
				AND a.status_cred IN ('BA','BT','E1','E2','E3')       -- solo se deben de realizar convenios sobre creditos BT y  BA
				AND (b.monto_vencido + b.mto_venc_trasp) > 0
				
				
				
						EXECUTE PROCEDURE bdicred:"informix".sp_dias_vencido(pEmpresa, vNumCredito) INTO vCod_Ret, vStatus;

						IF EXISTS(SELECT * FROM bdicobranza:"informix".cb_compac WHERE empresa= '001' AND numcliente = pNumCliente) THEN
							LET vCod_Ret = "004";   --Tiene convenio vigente
							Return vCod_Ret;
						END IF;

						IF vCod_Ret = '000' THEN
								IF vStatus > 0 THEN
								   
										LET vCod_Ret = "001";   --Tiene cuentas vencidas
									
								END IF;
						ELSE
							
							LET vCod_Ret = "002";   --Error al calcular dias vencidos
							
							
						END IF;
						
						Return vCod_Ret;
						
            END FOREACH;

        ELSE

            LET vCod_Ret = "999";   --Faltan valores

        END IF;

        RETURN vCod_Ret;

    END;

END PROCEDURE;