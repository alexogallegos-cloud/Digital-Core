CREATE PROCEDURE "informix".consctesfirminv_pba(pEmpresa CHAR(3), pNumeroCuenta CHAR(20), pNumeroCliente CHAR(20), pTipo CHAR(1))

    -- DATOS A REGRESAR --
    RETURNING
    CHAR(5),  -- Codigo de retorno
    CHAR(1),  -- Tipo de cliente
    CHAR(20), -- Numero de Cliente
    CHAR(26), -- Apellido paterno
    CHAR(26), -- Apellido materno
    CHAR(26), -- Nombre 1
    CHAR(26), -- Nombre 2
    CHAR(13), -- RFC
    CHAR(10), -- Fecha de Nacimiento
    SMALLINT, -- Secuencia
    CHAR(2),  -- Parentesco
    CHAR(4);  --Producto Cuenta

    -- DECLARACION DE VARIABLES --
    DEFINE vCodRet      CHAR(5);
    DEFINE vTipoCte     CHAR(1);
    DEFINE vNumCte      CHAR(20);
    DEFINE vApePat      CHAR(26);
    DEFINE vApeMat      CHAR(26);
    DEFINE vNombre1     CHAR(26);
    DEFINE vNombre2     CHAR(26);
    DEFINE vRFC         CHAR(13);
    DEFINE vFechaNac    CHAR(10);
    DEFINE vSecuencia   SMALLINT;
    DEFINE vParentesco  CHAR(2);
    DEFINE vProductoCuenta CHAR(4);
    DEFINE vCantReg     SMALLINT;
	DEFINE vRFC_alterno CHAR(13);
	DEFINE vexiste      SMALLINT;

    -- INICIALIZACION DE VARIABLES --
    LET vCodRet = "000";
    LET vCantReg = 0;
    LET vTipoCte = "";
    LET vNumCte = "";
    LET vApePat = "";
    LET vApeMat = "";
    LET vNombre1 = "";
    LET vNombre2 = "";
    LET vRFC = "";
    LET vFechaNac = "";
    LET vSecuencia = 0;
    LET vParentesco = "";
    LET vProductoCuenta = "";
	LET vRFC_alterno = "";
	LET vexiste = 0;

    -- Consulta Titular y Firmantes de Inversiones
    -- Autor: Frank Gaxiola Gaxiola
    -- Fecha: 17 Sep 2007
    -- BD: bdinvers

    --set debug file to '/tmp/ConsCtesFirmInv.out';
    --trace on;

    -- OBTENER SOLO EL TITULAR --
    IF pTipo = 1 THEN
	    SELECT COUNT(*) 
          INTO vexiste
          FROM bdinvers:sv_maeinv 
		 WHERE cuenta = pNumeroCuenta;

        IF vexiste > 0 THEN		 
           SELECT
                si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno, 'T' AS tipo_cliente,
                si_pf.fecha_nac
            INTO
                vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vTipoCte, vFechaNac
            FROM
                bdinteg:si_cliente AS si_cte,
                bdinteg:si_ctepf AS si_pf,
                bdinvers:sv_maeinv AS sv_min
            WHERE
                sv_min.cuenta = pNumeroCuenta AND
		        sv_min.status_cta = '1' AND
                sv_min.num_cte = si_cte.numcte AND
                sv_min.num_cte = si_pf.numcte;
				
            LET vCantReg = vCantReg + 1;
			IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
               LET vRFC = vRFC_alterno;
            END IF;	
            RETURN vCodRet, vTipoCte, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vSecuencia, vParentesco, vProductoCuenta;
        ELSE
            LET vCodRet = "100";
             RETURN vCodRet, vTipoCte, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vSecuencia, vParentesco, vProductoCuenta;
        END IF;
    END IF;

    IF pTipo = 2 THEN
        -- OBTENER SOLO LOS FIRMANTES --
        FOREACH
            SELECT {+INDEX(sv_maeinv idx_sv_maeinv1), +INDEX(sv_cotitular idx_sv_cotitular)} DISTINCT
                si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, si_cte.rfc_alterno, 'F' AS tipo_cliente,
                si_pf.fecha_nac, sv_minv.cod_instrum, sv_fir.parentesco
            INTO
                vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vRFC_alterno, vTipoCte, vFechaNac, vProductoCuenta, vParentesco
            FROM
                bdinvers:sv_maeinv AS sv_minv,
                bdinvers:sv_cotitular AS sv_fir,
                bdinteg:si_cliente AS si_cte,
                bdinteg:si_ctepf AS si_pf
            WHERE
                sv_fir.empresa =  pEmpresa AND sv_fir.cuenta =  pNumeroCuenta AND
                sv_fir.numcte = si_cte.numcte AND sv_fir.numcte = si_pf.numcte  AND
                sv_minv.cuenta = pNumeroCuenta
            LET vCantReg = vCantReg + 1;
			IF vRFC_alterno is not null and vRFC_alterno <> "" THEN
               LET vRFC = vRFC_alterno;
            END IF;	
            RETURN vCodRet, vTipoCte, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vSecuencia, vParentesco, vProductoCuenta WITH RESUME;
        END FOREACH;

       IF vCantReg = 0 THEN
             LET vCodRet = "132";
             RETURN vCodRet, vTipoCte, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vSecuencia, vParentesco, vProductoCuenta;
       END IF;
    END IF;
END PROCEDURE;