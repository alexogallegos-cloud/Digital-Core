CREATE PROCEDURE "informix".conscteeliminaadicional(pNumeroCuenta char(13),pTipo smallint)
	-- DATOS A REGRESAR 
	
	RETURNING
	char(5),	-- Codigo de retorno
	char(9),	-- Numero de Cliente
	char(26),	-- Apellido paterno
	char(26),	-- Apellido materno
	char(26),	-- Nombre 1
	char(26),	-- Nombre 2
	char(13),	-- RFC
	char(10),	--Fecha de Nacimiento
	char(20);	--Numero de tarjeta
	
	-- Declaracion de variables 

	DEFINE vCodRet		char(5);
	DEFINE vNumCte		char(20);
	DEFINE vApePat		char(26);
	DEFINE vApeMat		char(26);
	DEFINE vNombre1		char(26);
	DEFINE vNombre2		char(26);
	DEFINE vRFC		char(13);
	DEFINE vFechaNac	char(10);
	DEFINE vNumeroTarjeta	char(20);
	DEFINE vCantidad	smallint;
	
	-- Se Inicializan las Variables
	
	LET vCodRet  = "00000";
	LET vNumCte = "";
	LET vApePat = "";
	LET vApeMat = "";
	LET vNombre1 = "";
	LET vNombre2 = "";
	LET vRFC = "";
	LET vFechaNac = "";
	LET vNumeroTarjeta = "33333333";
	LET vCantidad = 0;
	
	
--	SET DEBUG FILE TO '/tmp/zprueba.out';
--	TRACE ON;
BEGIN
	IF ptipo=1 THEN --B aDICIONAL DE credito

			-- Se verifica que exista el número de cuenta 
			IF EXISTS (SELECT 1 
				FROM bdicred:sd_tarjeta 
				WHERE empresa = '001'
				AND num_credito = pnumerocuenta) THEN

				-- Ciclo para Obtner la cantidad de clientes y sus datos asociados a pnumerocuenta
				FOREACH

					SELECT numcte
					INTO vnumcte
					FROM bdicred:sd_tarjeta 
					WHERE empresa = '001'
					AND num_credito = pnumerocuenta
					AND tipo_tarjeta='A' 
					AND status_tar = 'A'

					SELECT num_tarjeta
					INTO vNumeroTarjeta
					FROM bdicred:sd_tarjeta a
					WHERE empresa = '001' 
                    and num_credito = pnumerocuenta
					AND secuencia = (SELECT MAX(secuencia) FROM bdicred:sd_tarjeta WHERE empresa = '001' and a.num_credito = num_credito AND numcte = vnumcte AND tipo_tarjeta='A' and status_tar = 'A');

					--IF vCantidad != 0 THEN
--					IF vnumcte IS NOT NULL THEN
					-- Se buscan los datos generales del cliente en si_cliente y si_ctepf
						SELECT cl.apell_paterno, cl.apell_materno, cl.nombre1, cl.nombre2, cl.rfc, pf.fecha_nac
						INTO vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac
						FROM  bdinteg:si_cliente AS cl, bdinteg:si_ctepf AS pf
						WHERE pf.numcte = vnumcte
						AND pf.numcte = cl.numcte
						AND cl.tpo_persona = '01';

						IF vApePat IS NULL OR  vNombre1 IS NULL THEN

							LET vCodRet="259";
							LET vNumCte = "";
							LET vApePat = "";
							LET vApeMat = "";
							LET vNombre1 = "";
							LET vNombre2 = "";
							LET vRFC = "";
							LET vFechaNac = "";
							LET vNumeroTarjeta = "";
						ELSE

							LET vCodRet = "00000";
							LET vCantidad = vCantidad + 1;

						END IF;

--					ELSE  --Cliente NO TIENE ADICIONALES

--						LET vCodRet="259";
--						LET vNumCte = "";
--						LET vApePat = "";
--						LET vApeMat = "";
--						LET vNombre1 = "";
--						LET vNombre2 = "";
--						LET vRFC = "";
--						LET vFechaNac = "";
--						LET vNumeroTarjeta = "";

--					END IF;					

					RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta WITH RESUME;

				END FOREACH;

				IF vCantidad = 0 THEN

					LET vCodRet="259";
					LET vNumCte = "";
					LET vApePat = "";
					LET vApeMat = "";
					LET vNombre1 = "";
					LET vNombre2 = "";
					LET vRFC = "";
					LET vFechaNac = "";
					LET vNumeroTarjeta = "";

					RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta;
				END IF

			ELSE	--LA CUENTA NO EXISTE

				LET Vcodret="100";
				LET vNumCte = "";
				LET vApePat = "";
				LET vApeMat = "";
				LET vNombre1 = "";
				LET vNombre2 = "";
				LET vRFC = "";
				LET vFechaNac = "";
				LET vNumeroTarjeta = "";


			RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta;
		END IF;
--------------------------------------------------------------------------------------------------------------
	ELSE	--Buscar Datos de DICIONAL DE DEBITO

		IF EXISTS (SELECT 1
			FROM bdicheq:sc_firmantes 
			WHERE empresa = '001'
			AND cuenta = pnumerocuenta) THEN

			-- Ciclo para Obtner la cantidad de clientes y sus datos asociados a pnumerocuenta
			FOREACH
				SELECT numcte
				INTO vnumcte
				FROM bdicheq:sc_firmantes
				WHERE empresa = '001'
				AND cuenta = pnumerocuenta
				AND secuencia != 1
				GROUP BY numcte

--				IF Vnumcte IS NOT NULL OR Vnumcte != "" THEN --Si la variable no es nula o vacia hace lo sig:

					--se buscan los datos generales del cliente en si_cliente y si_ctepf

					SELECT cl.apell_paterno, cl.apell_materno, cl.nombre1, cl.nombre2, cl.rfc, pf.fecha_nac
					INTO vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac
					FROM  bdinteg:si_cliente AS cl, bdinteg:si_ctepf AS pf
					WHERE pf.numcte = vnumcte
					AND pf.numcte = cl.numcte
					AND cl.tpo_persona = '01';
					
					--Se busca el número de cliente en la tabla sc_tarjeta para ver si existe y de existir se toma el número de tarjeta
					
					IF EXISTS (SELECT 1
						FROM  bdicheq:sc_tarjeta
							WHERE   empresa = '001'
								AND numcte = vnumcte
								AND cuenta = pNumeroCuenta
								AND tipo_tarjeta ='A' 
								AND status_tar = 'A') THEN

						SELECT num_tarjeta 
                            INTO vNumeroTarjeta
							FROM  bdicheq:sc_tarjeta
								WHERE   empresa = '001'
									AND numcte = Vnumcte
									AND cuenta = pNumeroCuenta
									AND tipo_tarjeta ='A' 
									AND status_tar = 'A';
					
							
					ELSE

						LET vNumeroTarjeta = '100';		

					END IF;	

					IF vApePat IS NULL OR  vNombre1 IS NULL THEN

						LET vCodRet="259";
						LET vNumCte = "";
						LET vApePat = "";
						LET vApeMat = "";
						LET vNombre1 = "";
						LET vNombre2 = "";
						LET vRFC = "";
						LET vFechaNac = "";
						LET vNumeroTarjeta = "";

					ELSE

						LET vCodRet = "00000";
						LET vCantidad = vCantidad + 1;

					END IF;

--				ELSE  --Cliente NO TIENE ADICIONALES

--					LET vCodRet="259";
--					LET vNumCte = "";
--					LET vApePat = "";
--					LET vApeMat = "";
--					LET vNombre1 = "";
--					LET vNombre2 = "";
--					LET vRFC = "";
--					LET vFechaNac = "";
--					LET vNumeroTarjeta = "";

--				END IF ;					

					--LET vNumeroTarjeta = "";

				RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta WITH RESUME;

			END FOREACH;

			IF vCantidad = 0 THEN

				LET vCodRet="259";
				LET vNumCte = "";
				LET vApePat = "";
				LET vApeMat = "";
				LET vNombre1 = "";
				LET vNombre2 = "";
				LET vRFC = "";
				LET vFechaNac = "";
				LET vNumeroTarjeta = "";

				RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta;
			END IF

		ELSE	--LA CUENTA NO EXISTE

			LET Vcodret = "100";
			LET vNumCte = "";
			LET vApePat = "";
			LET vApeMat = "";
			LET vNombre1 = "";
			LET vNombre2 = "";
			LET vRFC = "";
			LET vFechaNac = "";
			LET vNumeroTarjeta = "";

			RETURN vCodRet , vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vFechaNac, vNumeroTarjeta ;
		END IF

	END IF
END;		
END PROCEDURE

DOCUMENT
"Elaboro : Adrian Acosta Solis",
"FECHA : 14/Marzo/2007",
"Ver.  : 1.1",
"BD    : bdinteg,bdicred,bdmaecheq",
"VER   : 1.1";

CREATE PROCEDURE "informix".prorratea_cargos(pEmpresa CHAR(3),
				  pCredito CHAR(20),
				  pMonto   DECIMAL(14,2)) 
RETURNING CHAR(5);


   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vMtoPaso	      DECIMAL(14,2);
   DEFINE vMtoDif 	      DECIMAL(14,2);
   DEFINE vInsoluto           DECIMAL(14,2);
   DEFINE vFecha	      DATE;
   DEFINE vCuotas	      SMALLINT;
   DEFINE vMensaje	      VARCHAR(50);
   DEFINE i		      SMALLINT;
   DEFINE GLOBAL FechaHoy     DATE DEFAULT NULL;
 
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;



  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "000";
   LET vMtoPaso	  = 0; 
   LET vMtoDif 	  = 0;
   LET vInsoluto  = 0;
   LET vCuotas    = 0;
   LET vFecha	  = "";
   LET vMensaje   = "";
   LET i	  = 0;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	SELECT COUNT(*)
	  INTO vCuotas
	  FROM sd_amortiza_credito
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND fecha_cuota = FechaHoy + 1 UNITS MONTH;

	IF vCuotas = 0 THEN

       	  CALL sp_calcula_fecha("001" ,1 ,"M" ,FechaHoy  ,"01" ,"01")
       	  RETURNING cod_ret, vMensaje, vFecha;


          INSERT INTO sd_amortiza_credito values
            (pEmpresa,pCredito,vFecha ,"3",0,0,0,"1","0","",
             0,0,"1","0","", 0,0,"1","0","",
             0,0,0,0,0,0,0,"1", 0,0,"1","",
             i,0,0,"","");

	END IF

	LET vMtoPaso = pMonto;

	UPDATE sd_amortiza_credito
	   SET capital_mto_cuota = vMtoPaso,
	       capital_debe = vMtoPaso,
               capital_status='1'
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND fecha_cuota = FechaHoy;

	IF vMtoDif <> 0 THEN
		SELECT MAX(fecha_cuota)
		  INTO vFecha
		  FROM sd_amortiza_credito
		 WHERE empresa = pEmpresa
		   AND num_credito = pCredito
	   	   AND capital_status = "1";

		UPDATE sd_amortiza_credito
	   	   SET capital_mto_cuota = capital_mto_cuota + vMtoDif,
    	       	       capital_debe = capital_debe + vMtoDif
		 WHERE empresa = pEmpresa
		   AND num_credito = pCredito
   		   AND fecha_cuota = vFecha;
	END IF	

	IF cod_ret = "00000" THEN
		LET cod_ret = "000";
	END IF 


END
	RETURN cod_ret;

END PROCEDURE
DOCUMENT
'Procedimiento para la insercion de amortizaciones, asi como',
'para el prorrateo de la deuda',
'AUTOR : Antonio Ruiz Mtz',
'FECHA : 08/Mayo/2007',
'VERSION: 1.00.001',
'BD    : BDICRED'
;

CREATE PROCEDURE "informix".arregla_edocta()
     RETURNING CHAR(5);

--// ***************************************************************************
--// Actualiza registros de transparencia
--// ***************************************************************************

--//Definicion de variables
DEFINE vnumcredito  CHAR(20);
DEFINE vmonto       DECIMAL(14,2);
DEFINE vmonto2      DECIMAL(14,2);
DEFINE vcodigoref   INTEGER;
DEFINE vchrcodret   CHAR(5);
DEFINE vintcodret   INTEGER;
DEFINE vetiqueta    CHAR(50);
DEFINE v_cl_cobra     VARCHAR(60,1);


LET vnumcredito = '';
LET vchrcodret = '';
LET vetiqueta = '';
LET vmonto = 0.0;
LET vmonto2 = 0.0;
LET vcodigoref = 0;
LET vintcodret = 0;
LET v_cl_cobra ='';

BEGIN
    ON EXCEPTION SET vintcodret
    	IF vintcodret <> 0 THEN
           rollback work;
    	   LET vchrcodret = vintcodret;
           RETURN vchrcodret;
    	END IF;
    END EXCEPTION;

    --//DEBUG FLAG
--    SET debug file to "/tmp/actedocta.out";
--    TRACE ON;

    --//Actualiza etiquetas de moratorios
--    FOREACH WITH HOLD
--        select num_credito , monto, codigo_ref 
--          into vnumcredito , vmonto, vcodigoref 
--          from bdicred:sd_movhisedocta 
--         where empresa = '001' 
--           and ( usuario = 'BC426807' or usuario = 'BI426807') 
--           and ((codigo_fun = '340' and codigo_ref =  25)  or (codigo_fun = '033' and codigo_ref =  2))
--
--           begin work;
--
--           if (vcodigoref = 25) then
--               let vetiqueta = 'IVA DE INT MORA';
--           else
--               let vetiqueta = 'INTERESES MORATORIOS';
--           end if;
--
--           UPDATE bdicred:sd_detalle_edocta
--              set concepto = vetiqueta
--            where fecha_emision = mdy('10','20','2008')
--              and num_credito = vnumcredito
--              and cargos > 0 
--              and (concepto =  'BONIF. COMISION' or concepto = 'BONIF. IVA COMIS.')
--              and cargos = vmonto;
--
--           commit work;
--    END FOREACH

    --//Actualiza saldo promedio
  --  FOREACH WITH HOLD
  --      select a.num_credito, round((a.interes_tc*360)/(31*.5923),2)
  --        into vnumcredito, vmonto
  --        from bdicred:sd_encabezado2_edocta a,
  --             bdicred:sd_pie_edocta b 
  --       where a.fecha_emision = mdy('11','20','2008')
  --         and a.fecha_emision = b.fecha_emision 
  --         and a.num_credito   = b.num_credito
  --         and interes_tc > 0

  --         if (vmonto > 0) then
  --             begin work;
  --                  update bdicred:sd_pie_edocta 
  --                     set saldo_promedio = vmonto 
  --                   where fecha_emision = mdy('11','20','2008')
  --                     and num_credito = vnumcredito;
  --             commit work;
  --         end if;

  --  END FOREACH

    --//Actualiza interes vencido
    FOREACH WITH HOLD
        select num_credito, nvl((select sum(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito 
                                   where empresa = '001' and a.num_credito = num_credito 
                                   and fecha_cuota < mdy('02','20','2009') 
                                   and (interes_debe - interes_pagado) > 0),0)
        into vnumcredito, vmonto2
        from bdicred:sd_encabezado2_edocta a
        where --empresa = '001' 
         -- and a.empresa = b.empresa
         -- and a.num_credito = b.num_credito
           fecha_emision = mdy('02','20','2009')
        --  and a.num_credito = c.num_credito
      --    and int_tra_no_exig > 0
      --    and status_cred in ('BA','AA')
          and interes_ven_tc > 0 
          and iva_interes_ven_tc <= 0

          begin work;
              update bdicred:sd_encabezado2_edocta 
                set sdo_pagar = sdo_pagar - iva_interes_ven_tc  + vmonto2,
                    --interes_ven_tc = vmonto, 
                    iva_interes_ven_tc = vmonto2
               where fecha_emision = mdy('02','20','2009')
                 and num_credito = vnumcredito;
          commit work;
      
    END FOREACH;

--    FOREACH WITH HOLD
--        select num_credito
--        into vnumcredito
--        from bdicred:sd_encabezado2_edocta a
--        where --empresa = '001' 
         -- and a.empresa = b.empresa
         -- and a.num_credito = b.num_credito
--           fecha_emision = mdy('02','20','2009')
        --  and a.num_credito = c.num_credito
      --    and int_tra_no_exig > 0
      --    and status_cred in ('BA','AA')
--          and interes_ven_tc > 0 
--          and iva_interes_ven_tc <= 0

--          begin work;
--              update bdicred:sd_encabezado2_edocta 
--                set sdo_pagar = sdo_pagar - interes_ven_tc,
--                    interes_ven_tc = 0
--               where fecha_emision = mdy('02','20','2009')
--                 and num_credito = vnumcredito;
--          commit work;
--      
--    END FOREACH;

 --//Actualiza los vencidos en la clave de cobranza
--    FOREACH WITH HOLD
--            select num_credito,substr(cl_cobra,1,54)||'V' 
--            into vnumcredito,v_cl_cobra
--            from bdicred:sd_encabezado_edocta 
--            where fecha_emision = mdy('01','20','2009')
--            and substr(cl_cobra,1,2) = '04'
--            and substr(cl_cobra,55,1)  = '2'
--
--          begin work;
--              update bdicred:sd_encabezado_edocta  
--                set cl_cobra = v_cl_cobra
--               where fecha_emision = mdy('01','20','2009')
--                 and num_credito = vnumcredito;
--          commit work;
--      
--    END FOREACH;
--    --//Entrega el codigo de retorno 
--    RETURN "0000";


END;
END PROCEDURE;