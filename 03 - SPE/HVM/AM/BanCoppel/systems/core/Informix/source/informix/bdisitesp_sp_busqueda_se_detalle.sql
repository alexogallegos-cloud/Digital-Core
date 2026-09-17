CREATE PROCEDURE "informix".sp_busqueda_se_detalle( pEmpresa	CHAR(3),
											      pDia 		DATE,
											      pDiaMin	DATE,
											      pDiaMax	DATE,
												    pUsuario	CHAR(8),
                            pTipo char(1)
											     )
	RETURNING
	  CHAR(6),   --cod retorno
    INTEGER,   -- id
    CHAR(20),  -- numero de cleinte
	  CHAR(107), -- nombre del cliente
    CHAR(2),   --SE anterior
    SMALLINT,  --causa anterior
    CHAR(2),   --SE
    SMALLINT   --causa
	--Declaracion de variables
	  DEFINE v_codret 		   CHAR(6);
	  DEFINE v_sqlerr 		   INTEGER;
    DEFINE vId             INTEGER;
    DEFINE vIdanterior     INTEGER;
    DEFINE vNumcte         CHAR(20);
    DEFINE vNomcte         CHAR(107);
    DEFINE vSE             CHAR(1);
    DEFINE vCausa          SMALLINT;
    DEFINE vSEanterior     CHAR(1);
    DEFINE vCausaanterior  SMALLINT;


	--Inicializacion de variables
	  LET v_codret = "000";
	  LET v_sqlerr = 0;

	  LET vId            = 0;
    LET vNumcte        = '';
    LET vNomcte        = '';
    LET vSE            = '';
    LET vCausa         = 0;
    LET vSEanterior    = '';
    LET vCausaanterior = 0;

	--******************************************************
	--12-02-2009
	--Realizo:
	--Bernardo Carlos Baez Gonzalez
	--Obtener los movimientos de Situaciones y Causa por usuario y fecha.
	--******************************************************
	--21-04-2010
	--Modificó: Bernardo Carlos Baez Gonzalez
	--Se modifica para solo contemplar SE y Causas que apliquen a clientes
	--******************************************************

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            return v_codret, vId, vNumcte, nvl(vNomcte,' '), nvl(vSEanterior,'NE'), nvl(vCausaanterior,0), vSE, vCausa;
	        END IF;
	    END EXCEPTION;

--	SET debug FILE TO '/tmp/Bernardo/sp_BusquedaDetalle.out';
--	trace ON;

	    --checar valores nulos en los parametros
	    IF pEmpresa = '' THEN

	        LET v_codret = '001';	-- flatan parametros
	        return v_codret, vId, vNumcte, nvl(vNomcte,' '), nvl(vSEanterior,'NE'), nvl(vCausaanterior,0), vSE, vCausa;

        END IF;

        IF pTipo NOT IN ('S','M','E') THEN
             LET v_codret = '002';	-- parametros invalidos
	        RETURN v_codret, vId, vNumcte, nvl(vNomcte,' '), nvl(vSEanterior,'NE'), nvl(vCausaanterior,0), vSE, vCausa;
        END IF;
        IF pUsuario = '' THEN
            LET pUsuario = NULL;
        END IF;
        IF pDia = '01/01/1900' THEN
            let pDia = null;
        END IF;
        IF pDia IS NULL THEN
            IF pDiaMin = '01/01/1900' THEN
                let pDiaMin = null;
            END IF;
            IF pDiaMax = '01/01/1900' THEN
                let pDiaMax = null;
            END IF;
        ELSE
            let pDiaMin = pDia;
            let pDiaMax = pDia;
        END IF;

        --Seccion para consultar todos los datos
        IF pTipo IN ('S','E') THEN
            foreach	
                SELECT {+INDEX (se_ctessitespcte_his  se_ctessitespcte_his_idx2)} numcte, situacion, causa
                  INTO vNumcte, vSE, vCausa
                  FROM se_ctessitespcte_his
                 WHERE usrmodifica = NVL(pUsuario,usrmodifica)
                   AND (date(fchalta) BETWEEN nvl(pDiaMin,date(fchalta)) AND nvl(pDiaMax,date(fchalta))
                    OR date(fchmodifica) BETWEEN nvl(pDiaMin,date(fchalta)) AND nvl(pDiaMax,date(fchalta)))
                   AND tipomovto = pTipo

                LET vId = vId + 1;

                SELECT {+INDEX (se_ctessitespcte_his  se_ctessitespcte_his_idx4)} max(idmovto)
                  INTO vIdanterior
                  FROM se_ctessitespcte_his
                 WHERE numcte = vNumcte
                   AND idmovto < vId;

                SELECT {+INDEX (se_ctessitespcte_his  se_ctessitespcte_his_idx3)} situacion, causa
                  INTO vSEanterior, vCausaanterior
                  FROM se_ctessitespcte_his
                 WHERE numcte = vNumcte
                   AND idmovto = vIdanterior;

                SELECT {+INDEX (bdinteg:si_cliente  idx_si_cliente2)} trim(nombre1) || ' ' || trim(nombre2) || ' ' ||  trim(apell_paterno) || ' ' || trim(apell_materno)
                  INTO vNomcte
                  FROM bdinteg:si_cliente
                 WHERE empresa = pEmpresa
                   AND numcte = vNumcte;

                RETURN v_codret, vId, vNumcte, nvl(vNomcte,' '), nvl(vSEanterior,'NE'), nvl(vCausaanterior,0), vSE, vCausa WITH RESUME;

           END foreach;

               /*foreach	
                select {+INDEX (se_ctessitespcred_his  se_ctessitespcred_his_idx2)} numcte, situacion, causa
                into vNumcte, vSE, vCausa
                from se_ctessitespcred_his
                where usrmodifica = NVL(pUsuario,usrmodifica)
                and (date(fchalta) between nvl(pDiaMin,date(fchalta)) and nvl(pDiaMax,date(fchalta))
                or date(fchmodifica) between nvl(pDiaMin,date(fchalta)) and nvl(pDiaMax,date(fchalta)))
                and tipomovto = pTipo

                LET vId = vId + 1;

                select {+INDEX (se_ctessitespcte_his  se_ctessitespcte_his_idx4)} max(idmovto)
                INTO vIdanterior
                FROM se_ctessitespcte_his
                WHERE numcte = vNumcte
                AND idmovto < vId;

                select {+INDEX (se_ctessitespcte_his  se_ctessitespcte_his_idx3)} situacion, causa
                into vSEanterior, vCausaanterior
                from se_ctessitespcte_his
                where numcte = vNumcte
                and idmovto = vIdanterior;

                select {+INDEX (bdinteg:si_cliente  idx_si_cliente2)} trim(nombre1) || ' ' || trim(nombre2) || ' ' ||  trim(apell_paterno) || ' ' || trim(apell_materno)
                into vNomcte
                from bdinteg:si_cliente
                where empresa = pEmpresa
                and numcte = vNumcte;

                return v_codret, vId, vNumcte, nvl(vNomcte,' '), nvl(vSEanterior,'NE'), nvl(vCausaanterior,0), vSE, vCausa WITH RESUME;

           end foreach;*/
        ELSE 
               foreach
               	SELECT {+INDEX (se_ctessitespcte_his  se_ctessitespcte_his_idx2)} numcte, situacion, causa
                  INTO vNumcte, vSE, vCausa
                  FROM se_ctessitespcte_his
                 WHERE usralta = NVL(pUsuario,usralta)
                   AND (date(fchalta) BETWEEN nvl(pDiaMin,date(fchalta)) AND nvl(pDiaMax,date(fchalta))
                    OR date(fchmodifica) BETWEEN nvl(pDiaMin,date(fchalta)) AND nvl(pDiaMax,date(fchalta)))
                   AND tipomovto = pTipo

                LET vId = vId + 1;

                SELECT {+INDEX (se_ctessitespcte_his  se_ctessitespcte_his_idx4)} max(idmovto)
                  INTO vIdanterior
                  FROM se_ctessitespcte_his
                 WHERE numcte = vNumcte
                   AND idmovto < vId;

                SELECT {+INDEX (se_ctessitespcte_his  se_ctessitespcte_his_idx3)} situacion, causa
                  INTO vSEanterior, vCausaanterior
                  FROM se_ctessitespcte_his
                 WHERE numcte = vNumcte
                   AND idmovto = vIdanterior;

                SELECT {+INDEX (bdinteg:si_cliente  idx_si_cliente2)} trim(nombre1) || ' ' || trim(nombre2) || ' ' ||  trim(apell_paterno) || ' ' || trim(apell_materno)
                  INTO vNomcte
                  FROM bdinteg:si_cliente
                 WHERE empresa = pEmpresa
                   AND numcte = vNumcte;

                RETURN v_codret, vId, vNumcte, nvl(vNomcte,' '), nvl(vSEanterior,'NE'), nvl(vCausaanterior,0), vSE, vCausa WITH RESUME;

           END foreach;

               /*foreach	
                select {+INDEX (se_ctessitespcred_his  se_ctessitespcred_his_idx2)} numcte, situacion, causa
                into vNumcte, vSE, vCausa
                from se_ctessitespcred_his
                where usralta = NVL(pUsuario,usralta)
                and (date(fchalta) between nvl(pDiaMin,date(fchalta)) and nvl(pDiaMax,date(fchalta))
                or date(fchmodifica) between nvl(pDiaMin,date(fchalta)) and nvl(pDiaMax,date(fchalta)))
                and tipomovto = pTipo

                LET vId = vId + 1;

                select {+INDEX (se_ctessitespcte_his  se_ctessitespcte_his_idx4)} max(idmovto)
                INTO vIdanterior
                FROM se_ctessitespcte_his
                WHERE numcte = vNumcte
                AND idmovto < vId;

                select {+INDEX (se_ctessitespcte_his  se_ctessitespcte_his_idx3)} situacion, causa
                into vSEanterior, vCausaanterior
                from se_ctessitespcte_his
                where numcte = vNumcte
                and idmovto = vIdanterior;

                select {+INDEX (bdinteg:si_cliente  idx_si_cliente2)} trim(nombre1) || ' ' || trim(nombre2) || ' ' ||  trim(apell_paterno) || ' ' || trim(apell_materno) 
                into vNomcte 
                from bdinteg:si_cliente
                where empresa = pEmpresa
                and numcte = vNumcte;
                
                return v_codret, vId, vNumcte, nvl(vNomcte,' '), nvl(vSEanterior,'NE'), nvl(vCausaanterior,0), vSE, vCausa WITH RESUME;

           end foreach;*/
       END IF;
           
	END;
END PROCEDURE;