CREATE PROCEDURE "informix".sps_actualizastatususuario_bpi(pEmpresa char(3), pIdUsuario char(20), pUsuario char(50), pStatus integer, pIp char (15),pSuc char (4), pUsuCambio char (8), pIndicador CHAR(1))
   returning char(5);
   
   -- Creador: Moises Soriano	
	-- Objetivo: Se clona sp_actualizastatususuario_bpi, se agrega parametro de entrada
	-- Solicito: Alejandro Vazquez
	-- Fecha: 11/04/2016

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   DEFINE cod_ret char(5);
   DEFINE sql_err integer;
   DEFINE iStatus integer;
   DEFINE cNumcte char(9);
   DEFINE v_f_pri_ingreso  DATETIME YEAR to SECOND;
   DEFINE vFolio CHAR(55);   
   DEFINE vFolioCN2 CHAR(3);
   DEFINE vSucursal CHAR(4);
   DEFINE pCount INTEGER;
   DEFINE cNstoken CHAR(9);
   DEFINE vnstoken CHAR(9);
   
   DEFINE vcCodRet CHAR(5);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret       = "000";
   LET iStatus = "0";
   LET cNumcte = "";
   LET v_f_pri_ingreso = null;
   LET vFolio = "";
   LET vFolioCN2 = "";
   LET vSucursal = "";
   LET pCount =0;
   
   LET vcCodRet = '';
   
    SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;  

    --SET DEBUG FILE TO '/home/informix/bibiana/sp_actualizastatususuario_bpi.out';
    --TRACE ON;	
   
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;
		
    IF pIdUsuario <> 0 THEN
		
		IF pIndicador = '1'  THEN  -- pIdUsuario = id_usuario
			SELECT bpi.numcte INTO cNumcte
			FROM bdinteg:"informix".si_bpiusuarios bpi INNER JOIN bdibpi:"informix".bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'  
			WHERE empresa = pEmpresa AND id_usuario = pIdUsuario;
		ELIF pIndicador = '2' THEN -- pIdUsuario = numcliente
			LET cNumcte = pIdUsuario;
        ELIF pIndicador = '' THEN -- Cuando pIndicador es vacio
            SELECT bpi.numcte INTO cNumcte
			FROM bdinteg:"informix".si_bpiusuarios bpi INNER JOIN bdibpi:"informix".bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'  
			WHERE empresa = pEmpresa AND id_usuario = pIdUsuario;

            IF cNumcte = '' OR cNumcte IS NULL THEN
                LET cNumcte = pIdUsuario; 
            END IF;
		END IF;
		
	ELSE
		LET cod_ret = '003';
	END IF;

    IF cNumcte <> "" THEN

        IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumcte ) THEN
		
			SELECT id_status,f_pri_ingreso INTO iStatus,v_f_pri_ingreso FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa and numcte = cNumcte;
							
				INSERT INTO bdinteg:"informix".si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (cNumcte, iStatus, pStatus, pIp, current, pSuc, pUsuCambio);
				
				UPDATE bdinteg:"informix".si_bpiusuarios SET id_status = pStatus, f_status = current  WHERE empresa = pEmpresa AND numcte = cNumcte;
				
				IF (pStatus == 30 AND v_f_pri_ingreso is null) THEN
					UPDATE 	bdinteg:"informix".si_bpiusuarios SET f_pri_ingreso = current WHERE empresa = pEmpresa AND numcte = cNumcte;
				END IF;
				
				-- Inicia: Asginacion de token digital a clientes con folio AppBancoppel
				SELECT {+INDEX bdinteg:"informix".si_bpiusuarios idx_bpi} folio_contrato, suc_registro
				INTO vFolio, vSucursal
				FROM bdinteg:"informix".si_bpiusuarios 
				WHERE numcte = cNumcte AND empresa = pEmpresa;
				
				IF length(vFolio) > 12 THEN
                    EXECUTE PROCEDURE bdibpi:"informix".sp_desencripta_folio_contrato_bpi(vFolio) INTO vcCodRet, vFolio;
                END IF;
                
				LET vFolioCN2 = TRIM(SUBSTR(vFolio, 1, 3));

				IF vFolioCN2 = "CN2" THEN
					SELECT COUNT (*) INTO pCount FROM bdinteg:"informix".si_bpitoken where num_cliente = cNumcte AND empresa = pEmpresa;
					SELECT COUNT (*) INTO cNstoken 	FROM bdinteg:"informix".si_bpitoken;
					
					LET vnstoken = 'TEMP' ||  TRIM(SUBSTRING(cNstoken+1 FROM 2 FOR 6));
					
					IF pCount = 0 THEN	
						INSERT INTO bdinteg:"informix".si_bpitoken(empresa, num_cliente, ns_token, suc_registro, folio_token, id_status_token, f_status, f_registro,tipo_token)
						VALUES(pEmpresa, cNumcte, vnstoken, vSucursal, vFolio, '140', CURRENT, CURRENT,'2');
					END IF;
				END IF;
				-- Fin: Asginacion de token digital a clientes con folio AppBancoppel
				
				LET cod_ret = '000';  -- Usuario bloqueado

        ELSE

            LET cod_ret = '001';  -- No existe el Cliente

        END IF ;

    ELSE

        LET cod_ret = '002';  -- No existe el Usuario

    END IF ;

    RETURN cod_ret;

END

END PROCEDURE ;