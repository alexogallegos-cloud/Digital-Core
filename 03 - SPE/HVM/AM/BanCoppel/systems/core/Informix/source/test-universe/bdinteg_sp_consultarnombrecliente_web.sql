CREATE PROCEDURE "informix".sp_consultarnombrecliente_web(p_sEmpresa CHAR(3), p_sNumcte CHAR(20))
	RETURNING 	CHAR(5) AS retorno,
				CHAR(3) AS empresa, 
				CHAR(20) AS numcte, 
				CHAR(2) AS status_cte, 
				CHAR(4) AS sucursal, 
				CHAR(2) AS tpo_persona,
				CHAR(1) AS tipo_cliente,
				CHAR(26) AS apell_paterno, 
				CHAR(26) AS apell_materno,
				CHAR(26) AS nombre1, 
				CHAR(26) AS nombre2, 
				CHAR(60) AS razon_social,
				CHAR(13) AS rfc,
				DATE AS fecha_alta,
				CHAR(20) AS numcte_ref;

	DEFINE iSqlErr			INTEGER;
	DEFINE v_sValRetorno	CHAR(5);
	DEFINE v_sEmpresa 		CHAR(3);
	DEFINE v_sNumCte		CHAR(20);
	DEFINE v_sStatusCte		CHAR(2);
	DEFINE v_sSucursal		CHAR(4);
	DEFINE v_sTipoPersona	CHAR(2);
	DEFINE v_sTipoCliente	CHAR(1);
	DEFINE v_sApellPaterno	CHAR(26);
	DEFINE v_sApellMaterno	CHAR(26);
	DEFINE v_sNombre1		CHAR(26);
	DEFINE v_sNombre2		CHAR(26);
	DEFINE v_sRazonSocial	CHAR(60);
	DEFINE v_sRfc			CHAR(13);
	DEFINE v_dFechaAlta		DATE;
	DEFINE v_sNumCteRef		CHAR(20);
	DEFINE v_sRfc_alterno   CHAR(13);
	DEFINE cSufijo          CHAR(60);	--DSB 21/05/2013
	
	------------------------------------------------------------------------------------------
	--Creado por Erick Zamora 03/Agosto/2009
	--Obtiene los datos del cliente especificado, o de todas los clientes del catalogo
	--Caso de uso asociado: PCU-bdinteg\CU-0104-ConsultarNombreCliente-SPL
	--SET DEBUG FILE TO "/tmp/sp_consultarNombreCliente.out"; 
	--TRACE ON;
	------------------------------------------------------------------------------------------	
	
	LET v_sValRetorno = '00001';
	--DSB 21/05/2013
	LET iSqlErr			    = 0;	
	LET v_sEmpresa 		    = '';
	LET v_sNumCte		    = '';
	LET v_sStatusCte		= '';
	LET v_sSucursal		    = '';
	LET v_sTipoPersona	    = '';
	LET v_sTipoCliente	    = '';
	LET v_sApellPaterno     = '';
	LET v_sApellMaterno	    = '';
	LET v_sNombre1		    = '';
	LET v_sNombre2		    = '';
	LET v_sRazonSocial	    = '';
	LET v_sRfc			    = '';
	LET v_dFechaAlta		= DATE(1);
	LET v_sNumCteRef		= '';
	LET v_sRfc_alterno      = '';
	LET cSufijo             = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/sp_consultarNombreCliente.out"; 
		--TRACE ON;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--DEBE PROPORCIONARSE LA EMPRESA
		IF NVL(p_sEmpresa,'') = '' OR NVL(p_sNumcte,'') = '' THEN
			RETURN v_sValRetorno,'','','','','','','','','','','','','','';
		END IF;
		
		LET p_sNumcte = LPAD(TRIM(p_sNumcte),9,'0');
		
		FOREACH
			SELECT empresa, numcte, status_cte, sucursal, tpo_persona, tipo_cliente, apell_paterno,
			apell_materno, nombre1, nombre2, razon_social, rfc, fecha_alta, numcte_ref, rfc_alterno
			INTO v_sEmpresa, v_sNumCte, v_sStatusCte, v_sSucursal, v_sTipoPersona, v_sTipoCliente, v_sApellPaterno,
			v_sApellMaterno, v_sNombre1, v_sNombre2, v_sRazonSocial, v_sRfc, v_dFechaAlta, v_sNumCteRef, v_sRfc_alterno
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = p_sEmpresa AND numcte = p_sNumcte
			
			--DSB 21/05/2013		
			SELECT NVL(descripcion, '')
			INTO cSufijo
			FROM bdinteg:"informix".si_sufijos suf,
			bdinteg:"informix".si_ctepm cte
			WHERE suf.codigo = cte.sufijo
			AND cte.numcte = p_sNumcte;
			LET v_sRazonSocial = TRIM(NVL(v_sRazonSocial,''))||" "||TRIM(NVL(cSufijo,''));

			IF v_sRfc_alterno IS NOT NULL AND v_sRfc_alterno <> "" THEN
               LET v_sRfc = v_sRfc_alterno;
            END IF;	
			
			LET v_sValRetorno = '00000';
			RETURN v_sValRetorno,v_sEmpresa, v_sNumCte, v_sStatusCte, v_sSucursal, v_sTipoPersona, v_sTipoCliente, v_sApellPaterno,
			v_sApellMaterno, v_sNombre1, v_sNombre2, v_sRazonSocial, v_sRfc, v_dFechaAlta, v_sNumCteRef WITH RESUME;
		END FOREACH;
	END
END PROCEDURE
DOCUMENT
'MODIFICO: Jose Luis Polanco B.',
'FECHA: DSB 21/05/2013',
'DESCRIPCION: Se agrega el "sufijo" a la variable de retorno "v_sRazonSocial" para que aparesca en la aplicacion',
'			  al igual ques e agregan la inicializaciones de variables que por regla deben de tener los procedimientos';

CREATE PROCEDURE "informix".sp_cte_ilocalilzable_web( pNumCte       CHAR(20),  -- NO. CLIENTE
                                                  pCanal        SMALLINT,  -- CANAL
                                                  pSucursal     CHAR(4),   -- SUCURSAL
                                                  pUserInsert   CHAR(8) )  -- USUARIO
RETURNING CHAR(5); -- CODIGO DE RETORNO
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vExisteCte   INTEGER;
    
    LET vcodret1   = '00000';
    LET vcodret2   = '000';
    LET vcodret3   = '';
    LET sql_err	   = 0;
    LET isam_err   = 0;
    LET desc_err   = '';
    LET vExisteCte = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cte_ilocalilzable.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cte_ilocalilzable.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pNumCte is null OR pNumCte = '' ) THEN
        LET vcodret1 = '00110'; --- DATOS INSUFICIENTES
        RETURN vcodret1;
    END IF;

    -- // VALIDA EXISTA NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte;

    IF vExisteCte = 0 THEN
        LET vcodret1 = '00104'; --- NO DE CLIENTE NO EXISTE
        RETURN vcodret1;
    END IF;
    
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_bitacora_tel
     WHERE numcte = pNumCte;
     
    IF vExisteCte = 0 THEN
        INSERT INTO bdinteg:"informix".si_bitacora_tel
        ( numcte, ind_telefono, ind_correo, canal, sucursal, user_insert, fecha_oper )
        VALUES
        ( pNumCte, '9', '9', pCanal, pSucursal, pUserInsert, CURRENT );
    ELSE 
        UPDATE bdinteg:"informix".si_bitacora_tel
           SET ind_telefono = '9',
               ind_correo   = '9',
               canal        = pCanal,
               sucursal     = pSucursal,
               user_insert  = pUserInsert,
               fecha_oper   = CURRENT
         WHERE numcte = pNumCte;
    END IF;
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;