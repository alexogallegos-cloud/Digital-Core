CREATE PROCEDURE "informix".sp_sucrelacionada_web(cEmpresa CHAR(3),
												cSucursalMat		CHAR(4),
												cSucursalRel		CHAR(4),
												cCaja				CHAR(10),
												cStatusRel			CHAR(1),
												cUsuario 			CHAR(8),
												iRegistro			INTEGER,
												iTipoModo			INTEGER)

RETURNING 			CHAR(5)		AS retorno,
					CHAR(4)		AS sucursal_relacion,
					CHAR(40)	AS nombre_suc,
					CHAR(1)		AS estatus,
					DATE		AS fecha_alta,
					DATE		AS fecha_cambio,
					CHAR(8)		AS usuario_alta,
					CHAR(8)		AS usuario_cambio;

	DEFINE iSqlErr				INTEGER;
	DEFINE cCodret				CHAR(5);
	DEFINE cSucursal			CHAR(4);
	DEFINE cSucRelacion			CHAR(4);
	DEFINE cEstatus				CHAR(1);
	DEFINE dAlta				DATE;
	DEFINE dCambio				DATE;
	DEFINE cUsrAlta				CHAR(8);
	DEFINE cUsrCambio			CHAR(8);
	DEFINE cNombre				CHAR(40);
	DEFINE cTipo				CHAR(1);

	-----------------------------------------------------------------------------
	--SET DEBUG FILE TO "/tmp/sp_sucrelacionada.out";
	--TRACE ON;
	-----------------------------------------------------------------------------

	LET iSqlErr			= 0;
	LET cCodret			= '00000';
	LET cSucursal		= '';
	LET cSucRelacion	= '';
	LET cEstatus		= '';
	LET dAlta			= MDY(01,01,1900);
	LET dCambio			= MDY(01,01,1900);
	LET cUsrAlta		= '';
	LET cUsrCambio		= '';
	LET cNombre			= '';
	LET cTipo			= '';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		--EL PARAMETRO NO PUEDE SER NULO
		IF NVL(cSucursalMat,'') = '' OR NVL(cEmpresa,'') = '' OR NVL(iTipoModo,'') = '' THEN
			LET cCodret = '00001';
			RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
		END IF;

		IF iTipoModo = 0 THEN --CONSULTA
			IF NVL(cSucursalRel,'') = '' THEN --TRAER TODAS LAS SUCURSALES
				LET cCodret = '00002';
				FOREACH
					SELECT SKIP iRegistro
					rel.empresa, rel.sucursal_matriz, rel.sucursal_relacionada, rel.status_relacion, rel.fecha_altarel, rel.fecha_cambiorel,
					rel.usuario_altarel, rel.usuario_cambiorel, suc.nombre
					INTO cCodret, cSucursal, cSucRelacion, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio, cNombre
					FROM bdisuc:"informix".ss_sucursalesrelacionadas rel, bdinteg:"informix".si_sucursales suc
					WHERE rel.empresa = cEmpresa
					AND rel.sucursal_matriz = cSucursalMat
					AND suc.sucursal = rel.sucursal_relacionada
					AND rel.sucursal_matriz <> rel.sucursal_relacionada
					LET cCodret = '00000';
					RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio WITH RESUME;
				END FOREACH;
				IF cCodret = '00002' THEN
					RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
				END IF;
			ELSE
				IF cSucursalMat <> cSucursalRel THEN
					--BUSCA SI EXISTE LA SUCURSAL
					IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_sucursales WHERE sucursal = cSucursalRel) THEN
						--BUSCA LA RELACION ENTRE SUCURSALES
						IF  EXISTS (SELECT 1 FROM bdisuc:"informix".ss_sucursalesrelacionadas
						WHERE sucursal_matriz = cSucursalMat
						AND sucursal_relacionada = cSucursalRel AND status_relacion  ='A') THEN
							LET cCodret = '00000';
						ELSE
							LET cCodret = '00002';
						END IF;
					ELSE--NO EXISTE LA SUCURSAL RELACIONADA
						LET cCodret = '00004';
					END IF
				ELSE
					LET cCodret = '00000';
				END IF;
				--BUSCA LA CAJA Y LA SUCURSAL QUE LA CREO
				IF EXISTS(SELECT 1 FROM bdisuc:"informix".ss_numcajas WHERE numerocaja = cCaja) THEN
					SELECT NVL(numsuc_crea,numsucursal) INTO cSucRelacion FROM bdisuc:"informix".ss_numcajas WHERE numerocaja = cCaja;
					IF cSucRelacion <>  cSucursalMat THEN
						LET cCodret = '00003'; -- LA SUCURSAL NO CREO LA CAJA
					ELSE
						LET cCodret = '00000'; -- LA SUCURSAL CREO LA CAJA
					END IF
				END IF;
				RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
			END IF
		ELIF iTipoModo = 1 THEN --GRABA
			--VALIDA LOS CAMPOS A INSERTAR
			IF NVL(cSucursalMat,'') = '' OR NVL(cSucursalRel,'') = '' OR NVL(cStatusRel,'') = '' OR NVL(cUsuario,'')  = '' THEN
				LET cCodret = '00001';
				RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
			ELSE
				LET dAlta = CURRENT::DATE;
				--VERIFICAR QUE NO SEA RELACION CON LA MISMA SUCURSAL
				IF cSucursalMat  <> cSucursalRel THEN
					--VERIFICAR QUE SEA N
					SELECT tpo_sucursal INTO cTipo FROM bdinteg:"informix".si_sucursales WHERE empresa = cEmpresa AND sucursal = cSucursalRel;
					IF NVL(cTipo, '') = '' THEN
						LET cCodret = '00003';
					ELSE
						IF cTipo = 'S' THEN
							LET cCodret = '00002';
						ELSE
							LET cCodret = '00000';
							--VERIFICAR QUE AMBAS SUCURSALES NO TENGAN UNA RELACION CON OTRA SUCURSAL MATRIZ
							FOREACH
								SELECT sucursal_matriz INTO cSucursal FROM bdisuc:"informix".ss_sucursalesrelacionadas
								WHERE sucursal_relacionada IN (cSucursalRel,cSucursalMat)
								AND status_relacion = 'A' AND sucursal_matriz <> cSucursalMat
								AND sucursal_matriz <> sucursal_relacionada
								LET cCodret = '00002';
							END FOREACH;
							IF cCodret <> '00002' THEN
								--VERIFICA QUE LA SUCURSAL RELACIONADA NO SEA UNA SUCURSAL MATRIZ
								FOREACH
									SELECT sucursal_matriz INTO cSucursal
									FROM bdisuc:"informix".ss_sucursalesrelacionadas
									WHERE sucursal_matriz = cSucursalRel
									AND status_relacion = 'A'
									AND sucursal_matriz <> sucursal_relacionada
									LET cCodret = '00002';
								END FOREACH;
							END IF;
						END IF;
					END IF;
				ELSE
					LET cCodret = '00000';
				END IF;
				IF cCodret = '00000' THEN
					LET cCodret = '00001';
					--SI EXISTE ACTUALIZA SI NO INSERTA
					IF EXISTS (SELECT 1 FROM bdisuc:"informix".ss_sucursalesrelacionadas
					WHERE empresa = cEmpresa AND sucursal_matriz = cSucursalMat AND sucursal_relacionada = cSucursalRel) THEN
						UPDATE bdisuc:"informix".ss_sucursalesrelacionadas SET status_relacion = cStatusRel, fecha_cambiorel = dAlta,
						usuario_cambiorel = cUsuario
						WHERE empresa = cEmpresa AND sucursal_matriz = cSucursalMat AND sucursal_relacionada = cSucursalRel;
						LET cCodret = '00000';
						RETURN cCodret, cSucRelacion, cNombre, cEstatus, dCambio, dAlta, cUsrAlta, cUsrCambio;
					ELSE
						INSERT INTO bdisuc:"informix".ss_sucursalesrelacionadas (empresa, sucursal_matriz, sucursal_relacionada, status_relacion,
						fecha_altarel, fecha_cambiorel, usuario_altarel, usuario_cambiorel)
						VALUES (cEmpresa, cSucursalMat, cSucursalRel, cStatusRel, dAlta, dCambio, cUsuario, cUsrCambio);
						LET cCodret = '00000';
						RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
					END IF;
				ELSE
					RETURN cCodret, cSucRelacion, cNombre, cEstatus, dAlta, dCambio, cUsrAlta, cUsrCambio;
				END IF;
			END IF;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Victor Hugo NuÃÂ±ez',
'FECHA: 23/Agosto/2012',
'BD: BDISUC',
'DESCRIPCION: Guarda, elimina y consulta las sucursales relacionadas';

CREATE PROCEDURE "informix".sp_validarcaja_web(p_sEmpresa CHAR(3), p_sCaja CHAR(10), p_sSucursal CHAR(4), p_iTipoPaquete  SMALLINT)
	RETURNING 	CHAR(5) AS retorno,
				CHAR(3) AS empresa,
				CHAR(10) AS numerocaja,
				CHAR(4) AS numsucursal,
				SMALLINT AS tipopaquete,
				DATE AS fecha_insert,
				CHAR(7) AS status;
				
	
	DEFINE iSqlErr				INTEGER;
	DEFINE v_sValRetorno		CHAR(5);
	DEFINE v_sEmpresa			CHAR(3);
	DEFINE v_sNumerocaja		CHAR(10);
	DEFINE v_sNumSucursal		CHAR(4);
	DEFINE v_iTipoPaquete 		SMALLINT;
	DEFINE v_dFechaInsercion	DATE;	
	
	DEFINE v_sSucursal			CHAR(4);
	DEFINE v_iMes				SMALLINT;
	DEFINE v_iAnio				SMALLINT;
	DEFINE v_iConsecutivo		SMALLINT;
	
	DEFINE v_sCajaNueva			CHAR(6);	
	DEFINE v_iMesMayor			SMALLINT;
	DEFINE v_iAnioMayor			SMALLINT;
	DEFINE v_iConsecutivoMayor	SMALLINT;
	DEFINE v_cStatus		    CHAR(7);
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_validarCaja.out";
	--TRACE ON;
	-----------------------------------------------------------------------------
	LET isqlerr 	         = 0;
	LET v_sValRetorno        = '00001';	
	LET  v_sEmpresa			 = '';
	LET  v_sNumerocaja		 = '';
	LET  v_sNumSucursal		 = '';
	LET  v_iTipoPaquete 	 = '';	
	LET  v_dFechaInsercion	 = '';
	LET  v_sSucursal		 = '';
	LET  v_iMes				 = '';
	LET  v_iAnio			 = '';
	LET  v_iConsecutivo		 = '';
	LET  v_sCajaNueva		 = '';
	LET  v_iMesMayor		 = '';
	LET  v_iAnioMayor		 = ''; 
	LET  v_iConsecutivoMayor = '';		
	LET v_cStatus            = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','';
			END IF;
		END EXCEPTION;
		
		
		 SET ISOLATION TO DIRTY READ;
         SET LOCK MODE TO WAIT 3;
		
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sCaja,'')='' OR p_iTipoPaquete  IS NULL OR NVL(p_sSucursal,'')='' THEN
			RETURN v_sValRetorno,'','','','','','';
		END IF;
		
		SELECT empresa, numerocaja, numsucursal, tipopaquete, fecha_insert,estatus
		INTO v_sEmpresa, v_sNumerocaja, v_sNumSucursal, v_iTipoPaquete, v_dFechaInsercion,v_cStatus
		FROM bdisuc:"informix".ss_numcajas 
		WHERE empresa = p_sEmpresa AND numerocaja = p_sCaja 
		AND numsucursal = p_sSucursal;
		
		--SI LA CAJA EXISTE
		IF v_sNumerocaja IS NOT NULL THEN
			IF v_iTipoPaquete  = p_iTipoPaquete  THEN
				LET v_sValRetorno = '00000'; --EXISTE Y ES EL MISMO TIPO
			ELSE
				LET v_sValRetorno = '00002'; --EXISTE PERO NO ES EL MISMO TIPO
			END IF;
		ELSE
		--SI NO EXISTE
			--para el numero de caja 0316020902
			LET v_sSucursal = SUBSTR(p_sCaja,1,4);		--0316
			LET v_iMes = SUBSTR(p_sCaja,5,2);			--02
			LET v_iAnio = SUBSTR(p_sCaja,7,2);			--09
			LET v_iConsecutivo = SUBSTR(p_sCaja,9,2);	--02
			
			--SE OBTIENE EL NUMERO DE CAJA CON EL AÃO, MES Y CONSECUTIVO MAS ALTO, EN EL FORMATO SIGUIENTE
			--AAMMCC (AÃO-MES-CONSECUTIVO)
			SELECT NVL(MAX((SUBSTR(numerocaja,7,2) || SUBSTR(numerocaja,5,2) || SUBSTR(numerocaja,9,2))::INT),'00000')
			INTO v_sCajaNueva
			FROM bdisuc:"informix".ss_numcajas 
			WHERE numsucursal = v_sSucursal;
			
			LET v_sCajaNueva = LPAD(TRIM(v_sCajaNueva),6,'0');
			LET v_iMesMayor = SUBSTR(v_sCajaNueva,3,2);
			LET v_iAnioMayor = SUBSTR(v_sCajaNueva,1,2);
			LET v_iConsecutivoMayor = SUBSTR(v_sCajaNueva,5,2);
			
			--NO SE PUEDE INGRESAR UNA CAJA CON UN AÃO ANTERIOR, YA QUE LA FECHA ES ASCENDENTE 
			IF v_iAnio < v_iAnioMayor THEN
				LET v_sValRetorno = '00004';			
			ELIF v_iAnio = v_iAnioMayor THEN
				--SI ES EL MISMO AÃO PERO EL MES ES ANTERIOR, TAMBIEN SE MARCA UN ERROR
				IF v_iMes < v_iMesMayor THEN
					LET v_sValRetorno = '00004';			
				--SI ES EL MISMO AÃO Y MES 
				ELIF v_iMes = v_iMesMayor THEN
					--SI  EL CONSECUTIVO NO CORRESPONDE AL SIGUIENTE NUMERO DEL CONSECUTIVO MAYOR, 
					--SE MARCA UN ERROR Y SE REGRESA EL NUMERO DE CAJA CON EL CONSECUTIVO SIGUIENTE AL CONSECUTIVO MAYOR			
					IF v_iConsecutivo <> v_iConsecutivoMayor + 1 THEN
						LET v_sValRetorno = '00005'; --NUMERO CONSECUTIVO INCORRECTO
						LET v_sNumerocaja = v_sSucursal || LPAD(v_iMes,2,'0') || LPAD(v_iAnio,2,'0') || LPAD(v_iConsecutivoMayor + 1,2,'0');
					ELSE
						LET v_sValRetorno = '00003'; --NUMERO DE CAJA CORRECTA
					END IF;
					
				--SI ES EL MISMO AÃO Y EL MES ES MAYOR, SE INICIALIZA EL NUMERO CONSECUTIVO EN 01
				ELSE
					IF v_iConsecutivo <> 1 THEN
						LET v_sValRetorno = '00005'; --NUMERO CONSECUTIVO INCORRECTO
						LET v_sNumerocaja = v_sSucursal || LPAD(v_iMes,2,'0') || LPAD(v_iAnio,2,'0') || '01';
					ELSE
						LET v_sValRetorno = '00003'; --NUMERO DE CAJA CORRECTA
					END IF;
				END IF;
			ELSE
				--SI EL AÃO ES MAYOR SE INICIALIZA EL NUMERO CONSECUTIVO EN 01
				IF v_iConsecutivo <> 1 THEN
					LET v_sValRetorno = '00005'; --NUMERO CONSECUTIVO INCORRECTO
					LET v_sNumerocaja = v_sSucursal || LPAD(v_iMes,2,'0') || LPAD(v_iAnio,2,'0') || '01';
				ELSE
					LET v_sValRetorno = '00003'; --NUMERO DE CAJA CORRECTA
				END IF;
			END IF;
		END IF;
		
		RETURN v_sValRetorno, v_sEmpresa, v_sNumerocaja, v_sNumSucursal, v_iTipoPaquete, v_dFechaInsercion,v_cStatus;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Erick Zamora',
'FECHA: 01/Agosto/2009',
'DESCRIPCION: Indica si la caja especificada existe en la tabla numcajas',
'CASO DE USO: PCU-bdisuc\CU-0001-ValidarCaja-SPL',
'MODIFICO: Josue Zepeda',
'FECHA: 18-Abril-2012',
'DESCRIPCION: Se agrego variable v_cStatus para que regrese valor',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_paseatm(pempresa   CHAR(3),
                                       pfecha_pase DATE,
                                       pusuario   CHAR(8))
RETURNING CHAR(5);

   DEFINE vcod_ret                      CHAR(5);
   DEFINE sql_err                       SMALLINT;
   DEFINE isam_err                      SMALLINT;
   DEFINE error_info                    CHAR(40);
   DEFINE v_error                       smallint;
   DEFINE wbegin                        CHAR(1);
   DEFINE wusuario                      CHAR(8);
   DEFINE wejecutivo                    CHAR(8);
   DEFINE wfecha_hoy                    DATE;
   DEFINE nrows                         SMALLINT;
   DEFINE wdescripcion_det              CHAR(80);
   DEFINE wdivisa                       CHAR(2);
   DEFINE vsecuencia                    SMALLINT;
   DEFINE vregional                     CHAR(3);
   DEFINE vsucdest                      CHAR(4);
   DEFINE wproveedor                    CHAR(4);
   DEFINE wnro_auxiliar                 CHAR(12);
   DEFINE vnaturaleza                   CHAR(1);
   DEFINE wmotiv_afecta                 CHAR(2);
   DEFINE wcmayor                       CHAR(4);
   DEFINE wcsub1                        CHAR(3);
   DEFINE wcsub2                        CHAR(3);
   DEFINE wcsub3                        CHAR(3);
   DEFINE wcsub4                        CHAR(3);
   DEFINE wcsector                      CHAR(3);
   DEFINE vcargo                        CHAR(1);

{****************************************************************************
 **         INICIA REGISTRO DE PASE CONTABLE                               **
 ****************************************************************************}

   DEFINE wsucursal                     CHAR(4);
   DEFINE wtransacc                     CHAR(4);
   DEFINE wprocedencia                  CHAR(4);
   DEFINE wstatus                       CHAR(2);
   DEFINE wmonto                        MONEY(14,2);

{***************************************************************************
 **   TERMINA REGISTRO DE ENCABEZADO DE POLIZA                            **
 ***************************************************************************}

   DEFINE wsectoriza                    CHAR(1);
   DEFINE detusuario                    CHAR(8);
   DEFINE dcontrol_poliza               SMALLINT;
   DEFINE wfolio                        CHAR(8);
   DEFINE wtesoreria                    CHAR(4);
   DEFINE vfecha_envio                  DATE;
   DEFINE vfecha_recep                  DATE;
   DEFINE vtranenvio                    CHAR(4);
   DEFINE vtipo_tran                    CHAR(2);
   DEFINE vdescripcion                  CHAR(50);

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET vcod_ret = sql_err;
      SET DEBUG FILE TO "pasecont.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      IF (wbegin = "S") THEN
         ROLLBACK WORK;
         BEGIN WORK;
      ELSE
         ROLLBACK WORK;
      END IF;
      RETURN vcod_ret;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wbegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION;

   --set debug file to "/tmp/sp_paseatm.out";
   --TRACE ON;
   LET pusuario = "atms";
   LET wbegin = "S";
   LET detusuario = pusuario;
   LET wprocedencia = "";
   LET wstatus = "";
   LET wtesoreria = "";
   LET vfecha_envio = "";
   LET vfecha_recep = "";
   LET wproveedor = "";
   LET vcargo = "";
   LET vtipo_tran = "";
   LET vdescripcion = "";
   LET wmotiv_afecta = "";
   LET wusuario = pusuario;
   LET wnro_auxiliar = " ";
   LET wdescripcion_det = " ";

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
   SET ISOLATION COMMITTED READ;

   SET LOCK MODE TO WAIT 3;

   BEGIN WORK;
      LET vcod_ret = "000";

      SELECT fecha_hoy
      INTO wfecha_hoy
      FROM bdinteg:"informix".si_fechas
      WHERE empresa = pempresa;

      --borra lo existente en la base de contabilidad
      DELETE FROM bdisuc:"informix".ss_poliza_atm;

      DELETE FROM bdicont:"informix".co_poldet
      WHERE empresa = pempresa
        AND fecha_captura = pfecha_pase
        AND usuario = pusuario;

      DELETE FROM bdicont:"informix".co_detpol
      WHERE empresa = pempresa
        AND fecha_captura = pfecha_pase
        AND usuario = pusuario;

      DELETE FROM bdicont:"informix".co_poliza
      WHERE empresa = pempresa
        AND fecha_captura = pfecha_pase
        AND usuario = pusuario;

      -- Carga el Centro de Costo de Tesoreria
      SELECT valor 
      INTO wtesoreria
      FROM bdisuc:"informix".ss_param_cajagen
      WHERE codigo = "0034" 
        AND empresa=pempresa;

      SELECT ejecutivo,sucursal
      INTO wejecutivo,vsucdest
      FROM bdinteg:"informix".si_ejecut
      WHERE empresa = pempresa
        AND ejecutivo = pusuario;

      LET nrows = dbinfo("sqlca.sqlerrd2");

      IF (nrows = 0) THEN
         LET vcod_ret = "090";
         IF (wbegin = "S") THEN
            ROLLBACK WORK;
            BEGIN WORK;
         ELSE
            ROLLBACK WORK;
         END IF;
         RETURN vcod_ret;
      END IF;

      FOREACH
	   SELECT cod_trans,o.sucursal,divisa,procedencia,monto,folio_oper,motiv_afecta
         INTO wtransacc,wsucursal,wdivisa,wprocedencia,wmonto,wfolio,wmotiv_afecta
         FROM bdisuc:"informix".ss_operaciones o, bdisuc:ss_atms_sucursal a
        WHERE o.cod_trans IN ("0037","0038","0039","0040","0041","0042","0043")
	      AND o.fecha_operacion = pfecha_pase
		  AND o.sucursal > '0'
          AND o.reversado NOT IN ('1','SI','si')
          AND o.monto > 0
          AND a.cod_atm = o.sucursal

        -- Verifica si la Transaccion Contabiliza
        SELECT naturaleza,tipo_tran,descripcion
          INTO vnaturaleza,vtipo_tran,vdescripcion
          FROM bdinteg:"informix".si_transacc
         WHERE sistema='04' 
           AND se_contabiliza='S' 
           AND empresa = pempresa 
           AND numero = wtransacc;
        
        IF vnaturaleza IS NULL OR vnaturaleza = "" THEN
            CONTINUE FOREACH;
        END IF

        LET vtranenvio = wtransacc; -- Transacciones Normales
        CALL bdisuc:"informix".sp_contaatm(pempresa,vtranenvio,wsucursal,wtesoreria,wdivisa,wprocedencia,vnaturaleza,wmonto,vtipo_tran,wmotiv_afecta)
        returning vcod_ret;
        IF Trim(vcod_ret) != "000" THEN
            RETURN vcod_ret;
        END IF
      END FOREACH

      LET vsecuencia = 1;
      
      FOREACH
        SELECT sucursal,cod_trans,divisa,cmayor,cnivel1,cnivel2,cnivel3,cnivel4,csector,nro_auxiliar,monto,cargo_abono,cod_proveedor,NVL(UPPER(t.descripcion),'SIN ESPECIFICAR') as descripcion 
        INTO wsucursal,wtransacc,wdivisa,wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,wnro_auxiliar,wmonto,vcargo,vsucdest,wdescripcion_det
        FROM bdisuc:ss_poliza_atm p, bdinteg:si_transacc t
       WHERE t.sistema='04'
         AND t.numero=p.cod_trans
         AND t.empresa = '001'
         AND p.cod_trans = t.numero  

        SELECT regional 
        INTO vregional
        FROM bdinteg:"informix".si_plazas a,bdinteg:si_sucursales b
        WHERE a.plaza = b.plaza
          AND sucursal=wsucursal;

        IF vcargo = "1" THEN
             INSERT INTO bdicont:"informix".co_poldet(usuario,fecha_captura,secuencia,empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
                                           ciudad,sucursal,nro_auxiliar,naturaleza,monto,descripcion_det,fecha_valida,moneda,ccosto_orig)
             VALUES(pusuario,pfecha_pase,vsecuencia,pempresa,wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,vregional,wsucursal,
                    wnro_auxiliar,"D",wmonto,wdescripcion_det,wfecha_hoy,wdivisa,vsucdest);
        END IF

        IF vcargo = "0" THEN
             INSERT INTO bdicont:"informix".co_poldet(usuario,fecha_captura,secuencia,empresa,ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,sector,
                                           ciudad,sucursal,nro_auxiliar,naturaleza,monto,descripcion_det,fecha_valida,moneda,ccosto_orig)
             VALUES(pusuario,pfecha_pase,vsecuencia,pempresa,wcmayor,wcsub1,wcsub2,wcsub3,wcsub4,wcsector,vregional,wsucursal,
                    wnro_auxiliar,"C",wmonto,wdescripcion_det,wfecha_hoy,wdivisa,vsucdest);
        END IF

        LET vsecuencia = vsecuencia + 1;

      END FOREACH;

      IF (wbegin = "S") THEN
        COMMIT WORK;
        BEGIN WORK;
      ELSE
        COMMIT WORK;
      END IF;

      --EJECUTA EL PROCESO DE AUDITOR
      LET pfecha_pase = pfecha_pase;
      LET pempresa = pempresa;
      LET detusuario = detusuario;

      EXECUTE PROCEDURE bdicont:"informix".AUDITAPASE(pfecha_pase,pempresa,detusuario)

      INTO vcod_ret;

      COMMIT WORK;      
      RETURN vcod_ret;

END PROCEDURE;