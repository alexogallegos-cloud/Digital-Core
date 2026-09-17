CREATE PROCEDURE "informix".consppes_n (pempresa char(3), pnumcte char(20), pnum_direc smallint)
            RETURNING CHAR(5), -- Codigo Retorno
                                     CHAR(3), -- Empresa
                                     CHAR(20), -- NumCte
                                     CHAR(1), -- Tipo_ppes
                                     CHAR(2), -- puesto_ppes
                                     CHAR(26), -- Apell_paterno
                                     CHAR(26), -- Apell_materno
                                     CHAR(26), -- Nombre1
                                     CHAR(26), -- Nombre2
                                     DECIMAL(14,2), --Participacion
                                     CHAR(80), -- Domicilio
                                     CHAR(20), -- Telefono
                                     CHAR(8), -- User_insert
                                     DATE, -- Fecha_insert
                                     INTEGER, -- NumeroRegistro
                                     CHAR(40); -- Asociacion_civil

-- Definicion de Variables
DEFINE vcodret CHAR(5);
DEFINE vciclo SMALLINT;
DEFINE vsqlerr INTEGER;
-- si_cteppes
DEFINE vempresa CHAR(3);
DEFINE vnumcte CHAR(20);
DEFINE vtipo_ppes CHAR(1);
DEFINE vpuesto_ppes  CHAR(2);
DEFINE vapell_paterno  CHAR(26);
DEFINE vapell_materno CHAR(26);
DEFINE vnombre1  CHAR(26);
DEFINE vnombre2  CHAR(26);
DEFINE vparticipacion DECIMAL(14,2);
DEFINE vdomicilio  CHAR(80);
DEFINE vtelefono  CHAR(20);
DEFINE vuser_insert CHAR(8);
DEFINE vfecha_insert DATE;
DEFINE vnumeroregistro  INTEGER ;
DEFINE vasociacioncivil CHAR(40);

-- Inicializacion de Variables
LET vciclo = 0;
LET vcodret = "000";
LET  vsqlerr = 0;
-- si_cteppes
LET vempresa = "";
LET vnumcte = "";
LET vtipo_ppes = "";
LET vpuesto_ppes = "";
LET vapell_paterno = "";
LET vapell_materno = "";
LET vnombre1 = "";
LET vnombre2 = "";
LET vparticipacion = 0;
LET vdomicilio = "";
LET vtelefono = "";
LET vuser_insert = "";
LET vfecha_insert = "";
LET vnumeroregistro = 0;
LET vasociacioncivil = "";

    --SET DEBUG FILE TO "/respaldosbd/consppes_n.out";
    --TRACE ON;

BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret,vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                            vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil;
        END IF;
    END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION  TO DIRTY READ;

    FOREACH
        SELECT empresa, numcte,tipo_ppes,puesto_ppes,apell_paterno,apell_materno,nombre1,nombre2,
                        participacion,domicilio,telefono,user_insert,fecha_insert,numeroregistro,asociacion_civil
             INTO  vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                        vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil
           FROM bdinteg:"informix".si_cteppes
        WHERE numcte = pnumcte AND empresa = pempresa
        ORDER BY numeroregistro
        
        LET vciclo = vciclo+1;
        
        IF vciclo <= pnum_direc THEN
            CONTINUE FOREACH;
        END IF
        
        RETURN vcodret,vempresa,vnumcte,vtipo_ppes,vpuesto_ppes,vapell_paterno,vapell_materno,vnombre1,vnombre2,
                        vparticipacion,vdomicilio,vtelefono,vuser_insert,vfecha_insert,vnumeroregistro,vasociacioncivil WITH RESUME;

    END FOREACH;

END

END PROCEDURE
DOCUMENT
"Consulta de personas politicas",
"Autor : Daniela Viridiana Ramirez Perez",
"FECHA : 15/07/2011",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_consultamensajeticketinteligente(cEmpresa CHAR(3), sIdMensaje SMALLINT, cCuenta CHAR(12), cTarjeta CHAR(20))

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Consulta el mensaje asignado a una campaña
--Realizó: Nancy Sevilla Camacho
--Fecha: 19/04/2012     
--BD: BDINTEG  
--------------------------------------------------------------------
-- MODIFICACIÓN 
--Se limpian variables dentro del WHILE
--Modificó: Nancy Sevilla Camacho
--Fecha: 27/06/2012    
--BD: BDINTEG  
--------------------------------------------------------------------

--DATOS A REGRESAR---
RETURNING
CHAR(5)  AS codigo_retorno,
CHAR(40) AS mensaje;
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr     INTEGER;
DEFINE cCodRet     CHAR(5);	
DEFINE iRows       INTEGER;
---------------------------
DEFINE cMensaje    CHAR(55);
DEFINE cMensajeInc CHAR(55);
DEFINE cVariable   CHAR(20);
DEFINE cValorVar   CHAR(10);
DEFINE i           INTEGER;
DEFINE dSdoVencido DECIMAL(14,2);
DEFINE cMontoMin   CHAR(10);
DEFINE cSaldoTotal CHAR(10);
DEFINE cFechaCorte CHAR(10);
DEFINE dExpiracion DATE;
DEFINE dFechaHoy   DATE;
DEFINE iFecha      INTEGER;
DEFINE cSistema    CHAR(2);
DEFINE cEstatus    CHAR(1);	
DEFINe cSucursal CHAR(4);
DEFINE dSaldoVencido DECIMAL(14,2);
DEFINE cStatuscred  CHAR(2);
DEFINE dInteresvencido DECIMAL(14,2);
DEFINE dIvacredito DECIMAL(14,2);
DEFINE dInteresmes DECIMAL(14,2);
DEFINE dIntMora    DECIMAL(14,2);
DEFINE dIvaIntMora DECIMAL(14,2);
DEFINE dPorcIva    DECIMAL(14,2);
DEFINE cDia	 CHAR(2);
DEFINE cMes  CHAR(2);
DEFINE cAnio CHAR(2);

DEFINE dFechaHoyPrueba DATE;

--INICIALIZACION DE VARIABLES--
LET iSqlErr      = 0;
LET cCodRet      = '00000';
LET iRows        = 0;
-------------------------------
LET cMensaje     = '';
LET cMensajeInc  = '';
LET cVariable    = '';
LET cValorVar    = '';
LET i            = 0;
LET dSdoVencido  = 0;
LET cMontoMin    = 'MtoMin';
LET cSaldoTotal  = 'SdoTot';
LET cFechaCorte  = 'FecCort';
LET dExpiracion  = '01/01/1900';
LET dFechaHoy    = '01/01/1900';
LET iFecha       = 0;
LET cSistema     = '';
LET cEstatus     = '';
LET dSaldoVencido = 0;
LET cStatuscred = '';
LET dInteresvencido = 0;
LET dIvacredito = 0;
LET dInteresmes = '';
LET dIntMora = '';
LET dIvaIntMora = '';
LET dPorcIva = '';
LET cSucursal = '';
LET cDia = '';
LET	cMes = '';
LET	cAnio = '';

LET dFechaHoyPrueba    = '01/01/1900';

	--SET DEBUG FILE TO "/home/sysifx/Nancy/sp_consultamensajeticketinteligente.out";
	--TRACE ON;


	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cMensaje;
			END IF;
		END EXCEPTION;	
		
SET LOCK MODE TO WAIT 3;
SET ISOLATION  TO DIRTY READ;
		--Valida parámetros de entrada
		IF cEmpresa <> '' AND sIdMensaje IS NOT NULL  THEN				
		
			-- Se obtiene sistema y estatus
			SELECT limit 1 sistema,
				   estatus
			  INTO cSistema,
				   cEstatus
			  FROM bdinteg:"informix".si_maecamp
			 WHERE empresa = cEmpresa
			   AND idmensaje = sIdMensaje;

			LET iRows = DBINFO("sqlca.sqlerrd2");
			IF iRows = 0 THEN
			   -- No se encontraron registros para ese Id de Mensaje
			   LET cCodRet = '00001';
			   RETURN cCodRet, 
					  cMensaje
				 WITH RESUME;
			END IF;	

			-- Se valida que el sistema sea de crédito
			IF cSistema = 'SD' THEN
			
				-- Se valida que el estatus sea Normal o Atraso
				IF cEstatus = 'N' OR cEstatus = 'A' THEN
				
					-- Obtiene saldo vencido
					SELECT mto_fin_ven_trasp
					  INTO dSaldoVencido
					  FROM bdicred:"informix".sd_maesdos
					 WHERE num_credito = cCuenta;
							 
					-- Si el estatus es 'Atraso' y no tiene saldo
					IF cEstatus = 'A' AND (dSaldoVencido = 0 OR dSaldoVencido IS NULL) THEN
					
						--No se obtiene mensaje por que no tiene atraso
						LET cCodRet = '00002'; 
						RETURN cCodRet,  
							   cMensaje;
						  
					-- Si el estatus es 'Normal' y tiene saldo
					ELIF cEstatus = 'N' AND dSaldoVencido >= 1 THEN
					
						--No se obtiene mensaje por que tiene atraso	
						LET cCodRet = '00002'; 
						RETURN cCodRet,  
							   cMensaje;
						  
					END IF;
				
				-- Se valida que el estatus sea Por Vencer
				ELIF cEstatus = 'V' THEN
				
					SELECT expiracion
					  INTO dExpiracion
					  FROM bdicred:"informix".sd_tarjeta
					 WHERE num_credito = cCuenta
					   AND num_tarjeta = cTarjeta;
					   
					IF NVL(dExpiracion,"") <> "" THEN
					
						SELECT fecha_hoy
						  INTO dFechaHoy
						  FROM bdicred:"informix".sd_fechas
						 WHERE empresa = cEmpresa;
						 
						IF NVL(dFechaHoy, "") <> "" THEN
						 
						 LET iFecha = dExpiracion - dFechaHoy;
						 
							-- Se valida que la fecha de expiración sea menor a 3 meses
							IF iFecha > 90  THEN
							
								LET cCodRet = '00002'; 
								RETURN cCodRet,  
									   cMensaje;
									   
							END IF;
						 
						 END IF;
					
					END IF;
				
				END IF;
			
			END IF;
			
			FOREACH
			-- Se obtiene el mensaje de la campaña
				SELECT mensaje
				  INTO cMensajeInc
				  FROM bdinteg:"informix".si_detcamp
				 WHERE empresa='001' and idmensaje = sIdMensaje	
				 ORDER BY orden
				  
				LET i = 1;
				LET cVariable = "";
				LET cMensaje = "";
				
				WHILE i <= LENGTH(cMensajeInc)
					IF SUBSTR(cMensajeInc,i,1) = "<" THEN
						LET i = i + 1;	
						WHILE SUBSTR(cMensajeInc,i,1) != ">"
						   --27/06/2012
						   IF SUBSTR(cMensajeInc,i,1) <> " " tHEN
								LET cVariable = Trim(cVariable) || SUBSTR(cMensajeInc,i,1);
						   ELSE 	
								LET cVariable = Trim(cVariable) || "|";											
						   END IF;			
							LET i = i + 1;						
						END WHILE;	

						--27/06/2012
						--Se reemplaza caracter para respetar el espacio en blanco
						LET cVariable =  REPLACE(cVariable, "|" ," ");	
						
						IF TRIM(cVariable) <> "" THEN
						
							IF cVariable = TRIM(cMontoMin) THEN
								--Se obtiene la variable calculable del monto mínimo de pago
							   SELECT a.monto_financiado, b.status_cred, b.sucursal, a.int_tra_no_exig,
									  nvl((SELECT SUM(iva_debe - iva_pagado) from bdicred:"informix".sd_amortiza_credito where b.empresa = empresa and b.num_credito = num_credito and capital_status in ('2','7')),0) iva_interes,							  
							          nvl((SELECT SUM(interes_debe - interes_pagado) from bdicred:"informix".sd_amortiza_credito where a.empresa = empresa and a.num_credito = num_credito and capital_status = '1'),0) interes_mes
								 INTO cValorVar, cStatuscred, cSucursal, dInteresvencido, dIvacredito, dInteresmes
								 FROM bdicred:"informix".sd_maesdos a, bdicred:"informix".sd_maecred b
								WHERE a.empresa = cEmpresa
								  AND a.empresa = b.empresa
								  AND a.num_credito = cCuenta								  
								  AND a.num_credito = b.num_credito;
								  
								 IF ( cStatuscred = 'BT' ) THEN
									 LET cValorVar = cValorVar + dInteresvencido + dIvacredito;

									 IF ( dInteresvencido > 0 ) THEN
										LET cValorVar = cValorVar - dInteresmes;
									  END IF;
								 END IF;								  
								  
							ELIF cVariable = TRIM(cSaldoTotal) THEN
							--se obtiene la variable calculable del saldo total de la deuda
							   SELECT (a.sdo_cap_insoluto + a.sdo_retenido), a.int_tra_no_exig,
									  nvl((SELECT SUM(iva_debe - iva_pagado) from bdicred:"informix".sd_amortiza_credito where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7')),0) iva_interes,							  
									  nvl((SELECT SUM(interes_debe - interes_pagado) from bdicred:"informix".sd_amortiza_credito where a.empresa = empresa and a.num_credito = num_credito and capital_status = '1'),0) interes_mes
								 INTO cValorVar, dInteresvencido, dIvacredito, dInteresmes
								 FROM bdicred:"informix".sd_maesdos a
								WHERE a.empresa = cEmpresa
								  AND a.num_credito = cCuenta;
								  
								IF ( cStatuscred = 'BT' ) THEN
									LET cValorVar = cValorVar + dInteresvencido + dIvacredito;

									IF ( dInteresvencido > 0 ) THEN
										LET cValorVar = cValorVar - dInteresmes;
									END IF;
								END IF;		
									
								SELECT iva 
								INTO dPorcIva
								FROM bdinteg:"informix".si_sucursales
								WHERE empresa = cEmpresa
								AND sucursal = cSucursal;
			 
								SELECT (SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) + Sum(mora_sdo_cope+mora_provi_cope-mora_sdo_cope_pag))
								INTO dIntMora
								FROM bdicred:"informix".sd_amortiza_credito
								WHERE  empresa = cEmpresa
								AND num_credito = cCuenta
								AND capital_status IN ("2","7");

								IF  dIntMora IS NULL OR  dIntMora < 0 THEN
									LET dIntMora = 0;
								END IF;

								SELECT SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * dPorcIva)-mora_iva_pagado)
								INTO dIvaIntMora
								FROM bdicred:"informix".sd_amortiza_credito
								WHERE  num_credito = cCuenta
								AND empresa = cEmpresa
								AND capital_status IN ("2","7")
								AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * dPorcIva)) > 0;

								IF  dIvaIntMora  IS NULL OR  dIvaIntMora < 0 THEN
									LET dIvaIntMora = 0;
								END IF;

								LET cValorVar = cValorVar + dIntMora + dIvaIntMora;

							ELIF cVariable = TRIM(cFechaCorte) THEN
								--Se obtiene la variable calculable de la Fecha limite de pago
							   SELECT prox_fecha_pago
								 INTO dFechaHoyPrueba
								 FROM bdicred:"informix".sd_maecredanexo
								WHERE empresa = cEmpresa
								  AND num_credito = cCuenta;	
									
								LET cDia = SUBSTR(dFechaHoyPrueba,1,2);
								LET cMes = SUBSTR(dFechaHoyPrueba,4,2);
								LET cAnio = SUBSTR(dFechaHoyPrueba,9,2);
								
								LET cValorVar = cDia || "-" || cMes || "-" || cAnio;
								
							ELSE
							
								-- Se obtiene el valor de la variable					
								SELECT valor
								  INTO cValorVar
								  FROM bdinteg:"informix".si_cat_variables
								 WHERE nomvar = cVariable; 					
							
							END IF;

							--IF cValorVar <> "" THEN --27/06/2012
								LET cMensaje =  REPLACE(cMensajeInc,"<" || TRIM(cVariable) || ">" ,TRIM(cValorVar));
								--27/06/2012
								LET cVariable = "";
								LET cMensajeInc = cMensaje;
								LET i = 1;
							--27/06/2012
							/*ELSE
								LET cMensaje =  cMensajeInc;
							END IF;*/
						END IF;
					END IF;
					LET i = i + 1;				
				END WHILE;
				
				--Si no encuentra variables en el texto se asigna el texto original
				IF TRIM(cMensaje) = "" THEN
					LET cMensaje =  cMensajeInc;
				END IF;

				RETURN cCodRet,
					   cMensaje
				  WITH RESUME;				

			END FOREACH; 

		ELSE
		
			--Parámetros de entrada vacíos
			LET cCodRet = '00003';
			
			RETURN cCodRet,
				   cMensaje;			
		
		END IF;

	END
END PROCEDURE;