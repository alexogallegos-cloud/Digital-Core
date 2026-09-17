CREATE PROCEDURE "informix".consctesfirxnumctaper_web(pEmpresa CHAR(3), pNumeroCuenta CHAR(20), pNumeroCliente CHAR(20))
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
   --	DEFINE vFechaNac2 	DATE;
	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  		= "00000";
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
  --  LET vFechaNac2 = "";

	--SET DEBUG FILE TO "/respaldosbd/ConsCtesFirXnumCtaPer.out";
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
			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
					Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco WITH RESUME;
		
		END FOREACH;

		IF vCantReg = 0 THEN
			LET vCodRet  	 = "00000";
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
'DESCRIPCION: Se agrega filtro para obtener datos de tajertas unicamente Activas',
'EJECUTADO O LLAMADO POR: AperTP.exe',
'AUTOR : Elmer LÃÂÃÂ³pez',
'FECHA : 12/Octubre/2016',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".consctestar_web(pEmpresa char(3), pNumeroCuenta char(26), pNumeroCliente char(20))
        -- DATOS A REGRESAR --
        RETURNING
        char(5),    -- Codigo de retorno
        char(20),   -- # Cliente
        char(26),   -- Apellido paterno
        char(26),   -- Apellido materno
        char(26),   -- Nombre 1
        char(26),   -- Nombre 2
        char(13),   -- RFC
        char(16),   -- # Tarjeta
        date   ,    --  Expiracion
        char(4),    -- Producto tarjeta
        money(14,2), -- Limite de retiro maximo por mes
        char(1),    -- Status tarjeta
        char(8),    -- Tipo de cliente
        char(10),   --Fecha de Nacimiento
        char(4);    --Producto de la cuenta

        -- VARIABLES --
        DEFINE vCodRet  char(5);
        DEFINE vTipCte  char(1);
        DEFINE vNumCte  char(20);
        DEFINE vApePat  char(26);
        DEFINE vApeMat  char(26);
        DEFINE vNombre1 char(26);
        DEFINE vNombre2 char(26);
        DEFINE vRFC     char(13);
        DEFINE vNumTarj char(16);
        DEFINE Vexpiracion date;
        DEFINE Vprodtarjeta char(4);
        DEFINE vLimTar  money(14,2);
        DEFINE vTipoCte char(8);
        DEFINE vStatTjt char(1);
        DEFINE vFechaNac char(10);
        DEFINE vProductoCuenta char(4);
        DEFINE vCantReg smallint;




        -- INICIALIZACION DE VARIABLES --
        LET vCodRet  = "00000";
        LET vCantReg = 0;
        LET vTipCte = "";
        LET vNumCte = "";
        LET vApePat = "";
        LET vApeMat = "";
        LET vNombre1 = "";
        LET vNombre2 = "";
        LET vRFC = "";
        LET vNumTarj = "";
        LET Vexpiracion = "";
        LET Vprodtarjeta = "";
        LET vLimTar = 0;
        LET vTipoCte = "";
        LET vStatTjt = "";
        LET vFechaNac = "";
        LET vProductoCuenta = "";





        -- BUSCAR QUE TIPO DE CLIENTE ES [ TITULAR O FIRMANTE] --
        LET     vTipCte = "";

      /*  SELECT
                'T' AS tipo_cliente, sc_mcq.num_cte
        INTO
                vTipCte, vNumCte
        FROM
                bdicheq:sc_maechq AS sc_mcq
        WHERE
                sc_mcq.empresa = pEmpresa AND
                sc_mcq.cuenta  = pNumeroCuenta AND
                sc_mcq.num_cte = pNumeroCliente;*/

   -- SET DEBUG FILE TO '/tmp/consctestar.out';
	--TRACE ON;

       -- IF vTipCte = 'T' THEN
                -- CICLO PARA OBTENER AL TITULAR Y LOS FIRMANTES Y LAS TARJETAS DE CREDITO EN CASO DE QUE TENGAN --
                FOREACH
                        SELECT 
                                si_cte.numcte, si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 'Titular' AS tipo_cliente, si_pf.fecha_nac, sc_mcq.producto
						INTO
                                vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vTipoCte, vFechaNac, vProductoCuenta		
                        FROM
                                bdicheq:sc_maechq AS sc_mcq,
                                bdinteg:si_cliente AS si_cte,
                                bdinteg:si_ctepf AS si_pf
                        WHERE
                                sc_mcq.empresa = pEmpresa 
								AND sc_mcq.cuenta =  pNumeroCuenta 
								AND sc_mcq.num_cte = pNumeroCliente 
								AND sc_mcq.num_cte = si_cte.numcte 
								AND si_cte.empresa = pEmpresa 
								AND sc_mcq.num_cte = si_pf.numcte

                        SELECT
                                sc_tjt.expiracion, sc_tjt.prodtarjeta, sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
                        INTO
                                Vexpiracion, Vprodtarjeta, vNumTarj, vLimTar, vStatTjt
                        FROM
                                bdicheq:sc_tarjeta AS sc_tjt
                        WHERE
                                sc_tjt.empresa = pEmpresa AND
                                sc_tjt.cuenta = pNumeroCuenta AND
                                sc_tjt.numcte = vNumCte AND
                               -- sc_tjt.status_tar != 'C' AND
                                sc_tjt.secuencia = (SELECT MAX(sc_tjt.secuencia) FROM bdicheq:sc_tarjeta AS sc_tjt WHERE sc_tjt.empresa = pEmpresa AND sc_tjt.cuenta = pNumeroCuenta AND sc_tjt.numcte = vNumCte);


                        IF vNumTarj IS NULL  THEN
								LET vNumTarj = "Sin tarjeta";
                                LET vLimTar = 0;
                                LET vStatTjt = "";
                        END IF

                        LET vCantReg = vCantReg + 1;

                        RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta WITH RESUME;

               END FOREACH;
       
   

        IF vCantReg = 0 THEN
                LET vCodRet  = "00252";
                LET vNumCte  = "";
                LET vApePat  = "";
                LET vApeMat  = "";
                LET vNombre1 = "";
                LET vNombre2 = "";
                LET vRFC     = "";
                LET vNumTarj = "";
                LET Vexpiracion = "";
                LET Vprodtarjeta = "";
                LET vLimTar  = 0;
                LET vStatTjt = "";
                LET vTipoCte = "";
                LET vFechaNac = "";

                RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta;
        END IF
		
END PROCEDURE
DOCUMENT
'AUTOR ULTIMA MODIFICACION: Dulce Ramirez',
'DESCRIPCION ULTIMA MODIFICACION: Se modifica para que contemple Ãºnicamente las tarjetas del Titular ',        
'FECHA: Junio/2010',
'BD: BDICHEQ';

create procedure "informix".conscuentas_web(pempresa char(3), pNumCte char(20))

        returning char(5), char(20);

        DEFINE v_cod_ret char(5);
        DEFINE v_ciclo smallint;
        DEFINE v_cuenta char (20);
        DEFINE v_fcuenta char (20);


        LET v_cod_ret  = "00000";
        LET v_ciclo    = 0;
        LET v_cuenta   = "";
        LET v_fcuenta  = "";


                foreach

                select
                                cuenta
                into
                                v_cuenta
                from

                                bdicheq:sc_firmantes
                where
                                empresa = pempresa and
                                numcte = pNumCte

                                if not v_cuenta is null then
                                        LET v_ciclo = v_ciclo + 1;

                                        return v_cod_ret, v_cuenta with resume;
                                end if

                end foreach;


        if  v_ciclo = 0 then
                return "00101", "";
        end if

end procedure
;