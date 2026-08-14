CREATE PROCEDURE "informix".sp_consulta_cuentas_validas_app_pr(pProceso CHAR(1),
										 pEmpresa CHAR(3), pTarjeta CHAR (20),
                                         pNum_cte CHAR(20), pCuenta CHAR(20),
                                         pRegistro SMALLINT )
RETURNING CHAR(5), CHAR(20), CHAR(20), CHAR(120), CHAR(13), CHAR(10), CHAR(80), CHAR(10), CHAR(143), CHAR(100);

    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    DEFINE cod_ret       CHAR(5);
    DEFINE v_cuenta      CHAR(20);
    DEFINE v_numtarjeta  CHAR(20);
    DEFINE sql_err       INTEGER;
	DEFINE cCuentaValNum CHAR(20);
	DEFINE cNumCelValNum CHAR(10);
	DEFINE cEsTransfer CHAR(1);
	DEFINE cNumCliente CHAR(10);
	DEFINE cNumCliente2 CHAR(10);
	DEFINE cDescripcion	CHAR(40);
	DEFINE cEstado		CHAR(1);
	DEFINE cTelefono	CHAR(13);
	DEFINE cAlias		CHAR(80);
	DEFINE cNomComp		CHAR(143);
	DEFINE cIdUsuario   CHAR(11);
	DEFINE cEMail		CHAR(100);
    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    LET cod_ret       = "00100";
    LET v_cuenta      = " ";
    LET v_numtarjeta  = "0000000000000000";
	LET cCuentaValNum='';
	LET cNumCelValNum='';
	LET cEsTransfer='';
	LET cNumCliente='';
	LET cNumCliente2='';	
	LET	cDescripcion = ''; 
	LET cEstado = '';
	LET	cTelefono = '';
	LET cAlias = '';	
	LET cNomComp = '';	
	LET cIdUsuario  = '';
	LET sql_err = 0;
	LET cEMail = '';
	
    --SET DEBUG FILE TO "sp_consulta_cuentas_validas_app_pr.out";
    --TRACE ON;	
	/*
			CODRET 					DESCRIPCIÓN 
			00001					No se  encontró cuenta.
			00003					Tiene Servicio transfer.
			00004					No es una cuenta.	
			00006					Tiene servicio SPEI 
	        00007					no se encontro registro consulta inicial(cliente)
			00100					Parametros no validos.
			00101					El cliente no tiene cuentas de Captación.
			
			Tipos de estados.
			I = Cuenta con servicio Inactivo.
			A = Cuenta con servicio Activo.
			E = El servicio se encuentra Activo con diferente cuenta. 
			'' = No Tiene servicio.			
	*/
    BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN NVL(cod_ret,''), TRIM(NVL(v_cuenta,'')), TRIM(NVL(v_numtarjeta,'')), TRIM(NVL(cDescripcion,'')), TRIM(NVL(cTelefono,'')), TRIM(NVL(cEstado,'')),TRIM(NVL(cAlias,'')), TRIM(NVL(cNumCliente, '')), TRIM(NVL(cNomComp,'')), TRIM(NVL(cEMail,''));
        END IF
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF (NVL(pProceso, '') <> '' AND (pProceso > '0' AND pProceso < '5' )) THEN 
		-- Se obtiene el Número de Cuenta/Credito, Número de Cliente y Nombre del Producto.
		IF pProceso= '2' THEN		
			IF (  NVL(pTarjeta, '' ) <> ''OR NVL(pEmpresa,'') = '' ) THEN
			
				-- Busqueda por Tarjeta de Debito
				SELECT tar.cuenta, tar.numcte, prod.nombre
				INTO v_cuenta,cNumCliente, cDescripcion
				FROM bdicheq:"informix".sc_tarjeta tar, bdicheq:"informix".sc_producto prod
				WHERE tar.empresa = pEmpresa AND tar. num_tarjeta = TRIM(pTarjeta) AND tar.tipo_tarjeta = 'T'
				AND tar.empresa = prod.empresa 
				AND tar.prodtarjeta = prod.producto ; 
				
				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
					LET cod_ret = '00007';		
				END IF;
				
				LET v_numtarjeta = pTarjeta; 
				
			END IF;	
		ELIF pProceso= '3' THEN
			IF (NVL(pCuenta, '') <> '') THEN
			
				-- Busqueda por Numero de Cuenta
			    SELECT mae.num_cte, prod.nombre
			    INTO cNumCliente, cDescripcion
			    FROM bdicheq:"informix".sc_maechq mae, bdicheq:"informix".sc_producto prod
			    WHERE mae.cuenta = pCuenta AND mae.producto = prod.producto  
				AND mae.status_cta NOT IN('2','6','7');
				   
				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
					LET cod_ret = '00007';		
				END IF;
				
				LET v_cuenta = pCuenta;
				
			END IF;
		
		ELIF pProceso= '4' THEN		
			IF (  NVL(pTarjeta, '' ) <> ''OR NVL(pEmpresa,'') = '' ) THEN
			
				-- Busque da por Tarjeta de Crédito
				SELECT tar.num_credito, tar.numcte, prod.nombre_prod
				INTO v_cuenta,cNumCliente, cDescripcion
				FROM bdicred:"informix".sd_tarjeta tar, 
				bdicred:"informix".sd_definicion prod
				WHERE tar.empresa = pEmpresa AND tar. num_tarjeta = TRIM(pTarjeta) AND tar.tipo_tarjeta = 'T'
				AND tar.empresa = prod.empresa 
				AND tar.prodtarjeta = prod.num_producto ; 
				
				IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
					LET cod_ret = '00007';		
				END IF;
				
				LET v_numtarjeta = pTarjeta; 
				
			END IF;	
			
		ELSE 
			/*
			SELECT numcte
			INTO cNumCliente
			FROM bdinteg:"informix".si_cliente 
			WHERE empresa = pEmpresa
			AND numcte = pNum_cte;
			
			IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
				LET cod_ret = '00007';		
			END IF;
			
			LET cNumCliente = pNum_cte;
			*/
			-- Por el momento no se permite busqueda por Numero de Cliente. En dado caso de que esto cambie, quitar esta linea y desbloquear la seccion de arriba.
			LET cod_ret = '00007';
			
		END IF;	
		
		--- REGRESA EL NUMERO DE TELEFONO 		
		IF cod_ret  = '00100'  THEN
		
			-- Se obtiene el Nombre del Cliente
			SELECT TRIM(NVL(nombre1," ")) || " " || TRIM(NVL(nombre2," ")) || " " || 
				   TRIM(NVL(apell_paterno," ")) || " " || TRIM(NVL(apell_materno,' ')) || " " ||TRIM(NVL(razon_social, " ")) 
			INTO cNomComp
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = cNumCliente;	
				
			-- Se obtiene el Número de Celular
			SELECT telefono
			INTO cTelefono
			FROM bdinteg:"informix".si_telefonos	 
			WHERE numcte = cNumCliente 
			AND status_tel= 'A' 
			AND tipo_tel= 2;
			
			-- Se obtiene el EMail activo del cliente con Tipo_Correo = 1.
			SELECT LIMIT 1 correo_elec AS correo_electronico
			INTO cEMail
			FROM bdinteg:"informix".si_correos	 
			WHERE empresa = pEmpresa AND numcte = cNumCliente AND status_correo = 'A' AND tipo_correo = 1;
			
			LET cEMail = NVL(cEMail, '');
			
			-- Se verifica si el Número Celular esta asignado a otro cliente.
			SELECT num_cliente
			INTO cNumCliente2
			FROM bdibpi: "informix".pr_registro_app
			WHERE celular = cTelefono AND num_cliente != cNumCliente ;
			
			-- Si el Número Celular NO esta asignado a otro cliente, se obtiene el resto de los datos.
			IF DBINFO('SQLCA.SQLERRD2') = 0  THEN
			
				SELECT cuenta,telefono,es_transfer 
				INTO cCuentaValNum,cNumCelValNum,cEsTransfer
				FROM bdicheq:"informix".sc_cuenta_telefono 
				WHERE telefono = cTelefono AND num_cte != cNumCliente;
				
				IF DBINFO('SQLCA.SQLERRD2') = 0  THEN
				
					-- Se obtienen los datos de Debito
					IF pProceso <> '4' THEN
						
						SELECT {INDEX+(bdicheq:"informix".sc_maechq maecheques)} 
							mae.cuenta,'0000000000000000',prod.nombre
							INTO v_cuenta, v_numtarjeta,cDescripcion
							FROM bdicheq:"informix".sc_maechq mae, bdicheq:"informix".sc_producto prod 
							WHERE mae.num_cte = cNumCliente 
							AND mae.producto = prod.producto
							AND mae.producto IN ('2000', '1900', '1800','1300')
							AND mae.status_cta NOT IN('2','6','7')
							AND mae.cuenta = v_cuenta;
					ELSE
						-- Se obtienen los datos de Crédito
						
						SELECT {INDEX+(bdicred:"informix".sd_maecred sd_maecred)} 
							mae.num_credito,'0000000000000000',prod.nombre_prod
							INTO v_cuenta, v_numtarjeta,cDescripcion
							FROM bdicred:"informix".sd_maecred mae, 
							     bdicred:"informix".sd_definicion prod, 
								 bdicred:"informix".sd_maesdos dos
							WHERE mae.numcte = cNumCliente 
							AND mae.num_credito = dos.num_credito
							AND mae.num_producto = prod.num_producto
							AND mae.num_producto IN ('6001', '6500', '6600','7000', '8100', '8500')
							AND mae.status_cred IN ('AA','E1')
							AND (dos.monto_vencido + dos.mto_venc_trasp) = 0
							AND mae.num_credito = v_cuenta;
						
					END IF;
					
					-- Si no se encontro información, se devuelve el numero de errror.
					IF DBINFO('SQLCA.SQLERRD2') =  0 THEN
						LET cod_ret = '00004';
					ELSE 			
						-- Se obtiene el Id_Usuario registrado en caso de existir
						SELECT num_cliente, id_usuario
						INTO cNumCliente2, cIdUsuario
						FROM bdibpi: "informix".pr_registro_app
						WHERE num_cliente = cNumCliente;
						
						IF DBINFO('SQLCA.SQLERRD2') <> 0 THEN
							SELECT num_cliente,estatus_servicio, alias
							INTO cNumCliente2,cEstado, cAlias
							FROM bdibpi: "informix".pr_registro_app
							WHERE cuenta = v_cuenta AND celular = cTelefono AND id_usuario = cIdUsuario;	
							
							IF DBINFO('SQLCA.SQLERRD2') =  0 THEN							
								IF pProceso <> '1' THEN 
									LET cEstado = 'E';
									SELECT alias
									INTO cAlias
									FROM bdibpi: "informix".pr_registro_app
									WHERE num_cliente = cNumCliente; 
								END IF;
							END IF;
						END IF;
						
						LET cod_ret = '00000';
					END IF;			
					
					-- Se devuelve la información de la cuenta.
					RETURN NVL(cod_ret,''), TRIM(NVL(v_cuenta,'')), TRIM(NVL(v_numtarjeta,'')), TRIM(NVL(cDescripcion,'')), TRIM(NVL(cTelefono,'')), TRIM(NVL(cEstado,'')),TRIM(NVL(cAlias,'')), TRIM(NVL(cNumCliente, '')), TRIM(NVL(cNomComp,'')), TRIM(NVL(cEMail,'')) WITH RESUME;
						
				ELSE 
					LET cod_ret = '00005';
				END IF;
			ELSE 
				LET cod_ret = '00005';
			END IF;
		END IF;

    END IF;
	IF cod_ret <> '00000' THEN 
		RETURN NVL(cod_ret,''), TRIM(NVL(v_cuenta,'')), TRIM(NVL(v_numtarjeta,'')), TRIM(NVL(cDescripcion,'')), TRIM(NVL(cTelefono,'')), TRIM(NVL(cEstado,'')),TRIM(NVL(cAlias,'')), TRIM(NVL(cNumCliente, '')), TRIM(NVL(cNomComp,'')), TRIM(NVL(cEMail,''));
	END IF;
	
END
END PROCEDURE
DOCUMENT
'FOLIO.........: ',
'AUTOR.........: Edgar Manjarrez López',
'FECHA.........: 31/07/2015',
'MODIFICACIÓN..: Se crea stored procedure espejo al sp bdicheq:sp_consulta_cuentas_validas_suc_pr el cual se utiliza en el registro del servicio PagoRayo mediante la APP e incluye validacion de cuentas asociadas a tarjetas de credito. A diferencia del original, este SP solo devuelve 1 producto',
'SOLICITA......: Lic. Mendoza',
'BD............: BDIBPI';

CREATE PROCEDURE "informix".sp_obtenercuentasparatoken(psEmpresa CHAR(3), psSucursal CHAR(4), psNumCte CHAR(20), pmCostoToken MONEY(18,2), psecuencia SMALLINT, psCveOperacion CHAR(12))
    RETURNING CHAR(5), CHAR(20),CHAR(50),CHAR(1);

--Declaracion de variables

DEFINE vsCodRet  		CHAR(5);
DEFINE viSqlErr  		INTEGER;
DEFINE vsCuenta  		CHAR(20);
DEFINE vsTipoCta 		CHAR(50);
DEFINE v_ciclo   		SMALLINT;
DEFINE mIva 			MONEY(16,2);
DEFINE mMonto 			MONEY(16,2);
DEFINE mSaldoCred 		MONEY(16,2);
DEFINE sValida 			SMALLINT;
DEFINE vCreditoDebito 	CHAR(1);

--SET DEBUG FILE TO "/tmp/sp_ObtenerCuentasParaToken.out";
--TRACE ON;

--Asignacion de variables

LET vsCodRet 		= '00000';
LET viSqlErr 		= 0;
LET v_ciclo 		= 0;
LET vsCuenta 		= '';
LET vsTipoCta 		= '';
LET mIva 			= 0;
LET mMonto 			= 0;
LET sValida 		= 0;
LET vCreditoDebito 	= '';

IF NVL(psNumCte, '') = ''  OR  NVL(psEmpresa, '') = '' OR NVL(psSucursal, '') = '' OR NVL(pmCostoToken, '') = '' OR NVL(psecuencia, '') = '' OR NVL(psCveOperacion, '') = '' THEN --Valida parámetros
    LET vsCodRet = '00002';
    RETURN vsCodRet, vsCuenta, vsTipoCta,vCreditoDebito;
END IF;

--Inicio del procedimiento

BEGIN

    ON EXCEPTION SET viSqlErr --Manejador de Errores
        IF viSqlErr <> 0 then
            LET vsCodRet = viSqlErr;
            RETURN vsCodRet, vsCuenta, vsTipoCta,vCreditoDebito;
        END IF;
    END EXCEPTION;
   
	SET lock mode to wait 3;

    SELECT iva
    INTO mIva
    FROM bdinteg:"informix".si_sucursales
    WHERE empresa = psEmpresa
    AND sucursal = psSucursal;

    LET mIva = pmCostoToken * mIva;
    LET mMonto = pmCostoToken + mIva;


    FOREACH

        SELECT cta.cuenta, prod.nombre, 'D'
        INTO vsCuenta, vsTipoCta, vCreditoDebito
        FROM bdicheq:"informix".sc_maechq cta, bdicheq:"informix".sc_producto prod
        WHERE cta.num_cte = psNumCte
        AND cta.empresa =  psEmpresa
        AND cta.status_cta = '1'
        AND cta.sdo_actual >= mMonto
        AND cta.producto = prod.producto
        AND cta.producto IN (SELECT producto FROM bdinteg:"informix".si_bpipprod WHERE id_oper = TRIM(psCveOperacion))
                            
        LET v_ciclo = v_ciclo + 1;

        IF v_ciclo <= psecuencia THEN
            CONTINUE FOREACH;
        END IF;

		LET sValida = 1;
        RETURN vsCodRet, vsCuenta, vsTipoCta,vCreditoDebito WITH RESUME;


    END FOREACH;

    FOREACH

											
        SELECT num_credito INTO vsCuenta FROM bdicred:"informix".sd_maecred WHERE empresa = psEmpresa
																		 
														 
																						
        AND numcte = psNumCte  AND status_cred IN ('AA','E1')

        FOREACH
            SELECT b.monto_otorgado - (b.sdo_cap_insoluto + sdo_retenido), c.nombre_prod, 'C'
            INTO mSaldoCred, vsTipoCta, vCreditoDebito
            FROM bdicred:"informix".sd_maecred a, bdicred:"informix".sd_maesdos b,bdicred:"informix".sd_definicion c
																		   
            WHERE a.num_credito = vsCuenta
									
            AND a.empresa = "001"
            AND b.num_credito = a.num_credito
            AND a.empresa = b.empresa
            AND c.num_producto = a.num_producto
            AND (b.monto_vencido + b.mto_venc_trasp) = 0
            AND (NVL(a.id_unidad_prod,0) <> 3
            AND NVL(a.id_unidad_prod,0) <> 4)
            AND c.cod_tipcred  = 3
            LET v_ciclo = v_ciclo + 1;

            IF v_ciclo <= psecuencia THEN
                CONTINUE FOREACH;
            END IF;

            IF mSaldoCred >= mMonto THEN
                RETURN vsCodRet, vsCuenta, vsTipoCta,vCreditoDebito WITH RESUME;
				LET sValida = 1;
            END IF;

        END FOREACH;
    END FOREACH;
	
	IF sValida = 0 THEN
		LET vsCodRet =  '00001';
		RETURN vsCodRet, vsCuenta, vsTipoCta,vCreditoDebito WITH RESUME;
	ELIF v_ciclo = 0 THEN
        LET vsCodRet =  '00001';
        RETURN vsCodRet, vsCuenta, vsTipoCta,vCreditoDebito WITH RESUME;
    END IF;
END
END PROCEDURE
DOCUMENT
"Obtiene Cuentas del cliente que esten dentro de los productos permitidos para bpi y que tengan saldo suficiente",
"Autor : Dulce Ramirez",
"FECHA : Noviembre de 2009",
"Ver.  : 1.0",
"BD    : bdibpi",
"VER   : 1.0",

"Modificación",
"Descripción: Se agrega validación para cuando existan cuentas de crédito y no tengan saldo disponible",
"Autor : Daniela Ramirez",
"FECHA : Junio de 2011",
"BD    : bdibpi",

"Modificación",
"Descripción: Se agrega el campo que vCreditoDebito que identifica el tipo de cuenta ",
"Autor : René Aldana Hernández",
"FECHA : Julio de 2015",
"BD    : bdibpi";

CREATE PROCEDURE "informix".sp_desencripta_folio_contrato_bpi(pc_cadena_enc CHAR(45))
RETURNING CHAR(5), CHAR(50);

	DEFINE vcCodRet CHAR(5);
	DEFINE viSqlErr INTEGER;
	DEFINE vcMensaje CHAR(16);	
	DEFINE vcLetras CHAR(3);
	DEFINE idx SMALLINT;
	DEFINE sw SMALLINT;
	DEFINE vnIni SMALLINT;
	DEFINE vnFin SMALLINT;
	DEFINE vcCadena char(3);
	DEFINE vcCodigo char(3);
	DEFINE vn_tamanio SMALLINT;
	DEFINE vn_tamanio_ini SMALLINT;
	DEFINE vn_tamanio_act SMALLINT;

	LET vcCodRet = '00000';
	LET viSqlErr = 0;
	LET vcMensaje = '';
	LET vcLetras = '';
	LET sw = 0;
	LET idx = 1;
	LET vnIni = 1;
	LET vnFin = 3;
	LET vcCadena = '';
	LET vcCodigo = '';
	LET vn_tamanio = 0;
	LET vn_tamanio_ini = 24;	
	LET vn_tamanio_act = 36;
	
	--SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_desencripta_folio_contrato.out';
	--TRACE ON;
	
	IF NVL(pc_cadena_enc, '') = '' OR pc_cadena_enc IS NULL THEN 
		LET vcCodRet = '00003';
		LET vcMensaje = 'Valor Nulo';
	END IF;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
        ON EXCEPTION SET viSqlErr
            IF viSqlErr <> 0 then
                LET vcCodRet = viSqlErr;
                LET vcMensaje = 'Error Inesperado';
                RETURN vcCodRet, vcMensaje;
            END IF;	
        END EXCEPTION; 	
        
	    IF LENGTH(pc_cadena_enc) > 0 OR pc_cadena_enc <> '' THEN	
	      
            LET vn_tamanio = length(pc_cadena_enc) / 3;
            
            FOR idx in (1 to vn_tamanio)    
                IF sw = 0 THEN
                    LET vcLetras = SUBSTR(pc_cadena_enc, vnIni, vnFin);
                    LET sw = 1;
                ELSE   
                    LET vnIni = vnIni + 3;
                    LET vnFin = vnFin + 3;
                    LET vcLetras = SUBSTR(pc_cadena_enc, vnIni, vnFin);
                END IF;
              
                 SELECT letra INTO vcLetras 
                   FROM bdibpi:bpi_base_encripta
                  WHERE valor = vcLetras;
                         
                 LET vcMensaje = TRIM(vcLetras) || vcMensaje;   
                        
            END FOR;
            
        ELSE
            LET vcCodRet = '00003';
            LET vcMensaje = 'Valor Nulo';            
        END IF;
        
	    RETURN vcCodRet, TRIM(vcMensaje);
	    
    END;			
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para descifrar folio contrato.',
'AUTOR : Fidel Arteaga G',
'FECHA : 16 de Marzo 2022',
'BD: bdibpi';

CREATE PROCEDURE "informix".sp_consulta_sesion(pc_numero_cliente varchar(20), pc_canal varchar(50), pc_id_sesion char(500), pc_usuario varchar(20))
    RETURNING CHAR(5),CHAR(3);
	
	DEFINE resultado CHAR(3);
    DEFINE vcodret   CHAR(5);
    DEFINE sql_err   INTEGER;
	DEFINE vCount 	INTEGER;
    DEFINE vCountinactivas INTEGER;
    DEFINE vCountBex INTEGER;
	
	LET resultado = '000';
	LET vcodret   = '00000';
	LET vCount	  = 0;
    LET vCountinactivas = 0;
    LET vCountBex = 0;
	
	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_consulta_sesion.out";
    --TRACE ON; 
BEGIN	
	ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
			LET vcodret = sql_err;
        RETURN vcodret, resultado;
       END IF;
	END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

   
	
	SELECT COUNT(numcliente) 
	INTO vCount 
	FROM "informix".bpi_doblesesion 
	WHERE numcliente = pc_numero_cliente;


	IF vCount > 0 THEN
--GM3 P.Del Razo: 15/11/2018 INI:Modificacion Validacion Doble Sesion para evitar error -284
		SELECT SUM(CASE WHEN (CURRENT - fecha) < '0 00:08:00.000' THEN 1 ELSE 0 END)
        INTO vCountinactivas
        FROM "informix".bpi_doblesesion 
        WHERE numcliente = pc_numero_cliente;
       

		LET vCountinactivas = NVL(vCountinactivas,0);
				
		IF ( vCountinactivas > 0 ) THEN
			LET resultado = '003';
            SELECT COUNT(numcliente) INTO vCountBex  FROM "informix".bpi_doblesesion where canal = 'NBEX'  AND  numcliente = pc_numero_cliente;
            IF ( vCountBex > 0 ) THEN
                LET resultado = '005';
            END IF;
		ELSE
			SELECT COUNT(numcliente)  
			INTO vCount 
			FROM "informix".bpi_doblesesion
			WHERE numcliente = pc_numero_cliente;
--GM3 P.Del Razo: 15/11/2018 FIN: Modificacion Validacion Doble Sesion para evitar error -284		
			IF vCount > 0 THEN
				DELETE FROM "informix".bpi_doblesesion 
				WHERE numcliente = pc_numero_cliente;
						
				INSERT INTO "informix".bpi_doblesesion (numcliente, 
					usuario, fecha, canal, id_sesion, status)
				VALUES (pc_numero_cliente, pc_usuario, CURRENT, pc_canal, pc_id_sesion, '0');
				
				LET resultado = '000';		
			ELSE
				LET resultado = '004';
			END IF;
		END IF;
		
	ELSE  
--GM3 GABRIELA MENDOZA: 15/11/2018 INI: INSERT		
		INSERT INTO "informix".bpi_doblesesion (numcliente, usuario, fecha, canal, id_sesion, status)
		VALUES (pc_numero_cliente, pc_usuario, CURRENT, pc_canal, pc_id_sesion, '0');
--GM3 GABRIELA MENDOZA: 15/11/2018 FIN: INSERT	
	END IF;
END;	
	RETURN	vcodret, resultado;	
END PROCEDURE

DOCUMENT
'MODIFICADO POR: GM3-PATRICIA DEL RAZO HERNANDEZ',
'MODIFICADO POR: GM3-GABRIELA MENDEZ',
'VoBo POR: GM2-JUAN OLIVARES',
'FECHA DE MODIFICACION: 15 DE NOVIEMBRE DE 2018',
'OBJETIVO: CAMBIO: VALIDACION DOBLE SESION',
'          EVITAR ERROR -284',
'BD: BDIBPI';

CREATE PROCEDURE "informix".sp_autoriza_datoscte_coppel_bpi(
    pEmpresa CHAR(3),
    pOpcion CHAR(2),
    pIdCliente CHAR(20),
    pEjecutivo CHAR(8),
    pSucursal CHAR(4),
    pCanal SMALLINT,
    pFecha_insert DATETIME YEAR TO SECOND,
    pBandera_autoriza SMALLINT,
    pFecha_mod_bandera DATETIME YEAR TO SECOND,
    pTipo_responsivo INTEGER )

    RETURNING  CHAR (5);
    DEFINE codret CHAR (5);
    DEFINE iSqlErr INTEGER;
    DEFINE contIntento SMALLINT;
    DEFINE decision SMALLINT;
    DEFINE fh_confirma DATETIME YEAR TO SECOND;
 
    LET codret = '00000';
    LET iSqlErr = 0;
    LET contIntento = 0;
    LET decision = 0;
    LET fh_confirma = '';

    BEGIN 
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET codret = iSqlErr;
                RETURN codret;  
            END IF;
        END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	


    IF(pEmpresa <> '' AND pEmpresa IS NOT NULL AND pIdCliente <>'' AND pIdCliente IS NOT NULL AND pOpcion<>'' AND pOpcion IS NOT NULL) THEN

        --Consulta
            IF (pOpcion='01')THEN
                SELECT flag, fecha_confirma INTO decision, fh_confirma FROM bdinteg:"informix".si_autoriza_datos_contacto WHERE numcte = pIdCliente;
                IF NVL(decision,0) = 1 OR fh_confirma <> '' OR fh_confirma IS NOT NULL THEN
                    LET codret = '00000';                ELSE
                    LET codret = '00002';                END IF;

        --REgistra/Actualiza
            ELIF (pOpcion='02')THEN

                SELECT intentos INTO contIntento FROM bdinteg:"informix".si_autoriza_datos_contacto WHERE numcte=pIdCliente;

                IF NVL(contIntento,0) = 0 THEN
                    IF pBandera_autoriza = 1 THEN--Insert autorizado
                        INSERT INTO bdinteg:"informix".si_autoriza_datos_contacto(empresa,numcte,ejecutivo,sucursal,canal,intentos,tipo_responsivo,fecha_insert,fecha_consulta,fecha_confirma,flag)
                        VALUES (pEmpresa,pIdCliente,pEjecutivo,pSucursal,pCanal,0,pTipo_responsivo,pFecha_insert,pFecha_mod_bandera,pFecha_mod_bandera,pBandera_autoriza);
                    ELSE--Insert No autorizado
                        INSERT INTO bdinteg:"informix".si_autoriza_datos_contacto(empresa,numcte,ejecutivo,sucursal,canal,intentos,tipo_responsivo,fecha_insert,fecha_consulta,fecha_confirma,flag)
                        VALUES (pEmpresa,pIdCliente,pEjecutivo,pSucursal,pCanal,1,pTipo_responsivo,pFecha_insert,pFecha_mod_bandera,'',pBandera_autoriza);
                    END IF;
                ELIF pBandera_autoriza = 1 THEN --Update autorizado
                    LET contIntento = contIntento + 1 ;
                    update bdinteg:"informix".si_autoriza_datos_contacto set canal = pCanal, tipo_responsivo = pTipo_responsivo, intentos = contIntento, fecha_consulta =  pFecha_mod_bandera, fecha_confirma = pFecha_mod_bandera, flag = pBandera_autoriza  WHERE numcte=pIdCliente;                  
                ELSE--Update No autorizado
                    LET contIntento = contIntento + 1 ;
                    update bdinteg:"informix".si_autoriza_datos_contacto set canal = pCanal, tipo_responsivo = pTipo_responsivo, intentos = contIntento, fecha_consulta =  pFecha_mod_bandera, fecha_confirma = '', flag = pBandera_autoriza  WHERE numcte=pIdCliente;                  
                END IF;
            END IF; 

        ELSE
            LET codret = '00003'; -- No existe el cliente
        END IF;


    RETURN codret;

    END;
END PROCEDURE;