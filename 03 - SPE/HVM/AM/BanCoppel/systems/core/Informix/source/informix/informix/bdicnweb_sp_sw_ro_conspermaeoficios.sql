CREATE PROCEDURE "informix".sp_sw_ro_conspermaeoficios(pUsuario CHAR(8), pIdFunciON CHAR(10), pFchInicio CHAR(10),pFchFin CHAR(10),

											pStatusBusqueda CHAR(1), pRegistros INT, pRecuperaciON INT)

	RETURNING CHAR(5) AS CodRet,

		  CHAR(164) AS Nombre,

		  CHAR(13) AS Rfc, 

		  CHAR(20) AS Numcte,

		  CHAR(20) AS Cuenta,

		  CHAR(40) AS MotivoBlo,

		  money(14,2) AS MontoBlo,

		  CHAR(10) AS fchOficio, 

		  CHAR(60) AS Oficio, 

		  CHAR(12) AS UserINSERT, 

		  CHAR(45) AS NombreUser

	 DEFINE cCodRet		CHAR(5);

	 DEFINE iSqlErr 	INT;

	 DEFINE cNombre     CHAR(164); 

	 DEFINE crfc        CHAR(13); 

	 DEFINE cNumcte     CHAR(20); 

	 DEFINE cCuenta     CHAR(20); 

	 DEFINE cMotivoBlo	CHAR(40);

	 DEFINE mMontoBlo	MONEY(14,2);

	 DEFINE cfchOficio  CHAR(10); 

	 DEFINE cOficio     CHAR(60); 

	 DEFINE cUserINSERT CHAR(12);

	 DEFINE cCodRetorno CHAR(5);

	 DEFINE cNumEmple   CHAR(8);

	 DEFINE cUsuEstado	CHAR(1);

	 DEFINE cUsuIp		CHAR(15);

	 DEFINE cUsuMac 	CHAR(17);

	 DEFINE cNombreUser CHAR(45);

	 DEFINE iUsuBloqueo INTEGER;

	 DEFINE iContador   INTEGER;

     DEFINE iRegistros  INTEGER;

     DEFINE ibusq       INTEGER;

     DEFINE iTipoBus    INTEGER;

     DEFINE iIdBusq     INTEGER;

     DEFINE iIdOficio   INTEGER;

     DEFINE idTipBusq   INTEGER;

     DEFINE cIndBloSis  CHAR(1);

	 LET cCodRet     = '00000';

	 LET iSqlErr	 = 0;

	 LET cNombre     = ''; 

	 LET crfc        = ''; 

	 LET cNumcte     = ''; 

	 LET cCuenta     = ''; 

	 LET cMotivoBlo	 = '';

	 LET mMontoBlo	 = 0;

	 LET cfchOficio  = ''; 

	 LET cOficio     = '';

	 LET cUserINSERT = ''; 

	 LET cCodRetorno = '';

	 LET cNumEmple   = '';

	 LET cUsuEstado	 = '';

	 LET cUsuIp		 = '';

	 LET cUsuMac     = '';

	 LET cNombreUser = '';

 	 LET iUsuBloqueo = 0;

	 LET iContador   = 0; 	

	 LET iRegistros  = 0;

     LET ibusq       = 0;

     LET iTipoBus    = 0;

     LET iIdBusq     = 0;

     LET iIdOficio   = 0;

     LET idTipBusq   = 0;

     LET cIndBloSis  = 0;

	

	BEGIN			

		ON EXCEPTION SET  iSqlErr

			IF iSqlErr <> 0 THEN

				LET cCodRet= iSqlErr;

				RETURN cCodRet, cNombre, cRfc, cNumcte, cCuenta, cMotivoBlo, mMontoBlo, cfchOficio, cOficio, cUserINSERT, cNombreUser;

			END IF;				

		END EXCEPTION;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD

		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;

		IF cCodRet <> '00000' THEN

			RETURN cCodRet, cNombre, cRfc, cNumcte, cCuenta, cMotivoBlo, mMontoBlo, cfchOficio, cOficio, cUserINSERT, cNombreUser;

		END IF;

		-- VALIDACIONES DE ENTRADA

		IF  pUsuario = ''OR 

			pIdFunciON = ''OR 

			pFchInicio  = ''OR 

			pFchFin  = ''OR 

			pStatusBusqueda = ''OR 

			pRegistros = ''OR 

			pRecuperaciON = ''

			THEN

				LET cCodRet = '00003';

				RETURN cCodRet, cNombre, cRfc, cNumcte, cCuenta, cMotivoBlo, mMontoBlo, cfchOficio, cOficio, cUserINSERT, cNombreUser;

		END IF;

		--VALIDA SI NO HAY DATOS 

		SET ISOLATION TO DIRTY READ;

		SELECT  {+INDEX (bdicnweb:sw_ro_resulper idx_numcte)} COUNT(*) INTO  iRegistros

			FROM sw_ro_resulper AS r LEFT JOIN sw_ro_ctecta AS c ON (r.id_oficio = c.id_oficio AND r.id_busqueda = c.id_busqueda)

				 LEFT JOIN sw_ro_bloqueos AS b ON (c.id_resulcte=b.id_resulcte AND c.id_oficio = b.id_oficio) 

				 LEFT JOIN sw_ro_maeoficios AS m on(r.id_oficio= m.id_oficio)

				WHERE r.status_busqueda =  pStatusBusqueda 

					AND r.status = 1 AND r.ind_omitir = 0

					AND  r.fecha_INSERT >= TO_DATE (pFchInicio ||' 00:00:00' ,'%Y-%m-%d %H:%M:%S' ) 

					AND r.fecha_INSERT <= TO_DATE (pFchFin ||' 23:59:59' ,'%Y-%m-%d %H:%M:%S');

		 --MANDAR CODIGO  "NO EXISTE DATOS"

		IF iRegistros = 0 AND pRegistros = 0  THEN

			LET cCodRet='00017';

			RETURN cCodRet, cNombre, cRfc, cNumcte, cCuenta, cMotivoBlo, mMontoBlo, cfchOficio, cOficio, cUserINSERT, cNombreUser;

		END IF;

		IF pStatusBusqueda=0 THEN

			--SELECCIONA UN REGISTRO PARA GENERAR EL REPORTE  INEXISTENTES

			SET ISOLATION TO DIRTY READ;

			FOREACH

				SELECT {+INDEX (bdicnweb:sw_ro_resulper idx_numcte)} skip pRegistros FIRST pRecuperacion

					TRIM( TRIM(r.apell_paterno)|| ' ' ||TRIM(r.apell_materno)|| ' ' || TRIM(r.nombre1) || ' ' || TRIM(r.nombre2) || ' ' || TRIM( r.razon_social)|| TRIM(r.numcte)|| TRIM( r.cuenta)|| TRIM( r.num_tarjeta)) AS nombre,

					r.rfc, r.numcte, c.cuenta,c.motivo_bloqueo,b.monto_bloqueo,m.fecha_oficio, m.oficio, m.user_INSERT,bp.id_tipobusqueda 

					INTO   cNombre, cRfc, cNumcte, cCuenta, cMotivoBlo, mMontoBlo, cfchOficio , cOficio, cUserINSERT, idTipBusq 

					FROM sw_ro_resulper AS r LEFT JOIN sw_ro_ctecta AS c ON (r.id_oficio = c.id_oficio AND r.id_busqueda = c.id_busqueda)

					LEFT JOIN sw_ro_bloqueos AS b ON (c.id_resulcte=b.id_resulcte AND c.id_oficio = b.id_oficio) 

					LEFT JOIN sw_ro_maeoficios AS m on(r.id_oficio= m.id_oficio)

					LEFT JOIN sw_ro_buscaper bp ON r.id_busqueda = bp.id_busqueda AND r.id_oficio = bp.id_oficio

					WHERE r.status_busqueda = pStatusBusqueda

						AND r.status = 1 

						AND r.ind_omitir = 0  

						AND  r.fecha_INSERT >= TO_DATE (pFchInicio ||' 00:00:00' ,'%Y-%m-%d %H:%M:%S' ) 

						AND r.fecha_INSERT <= TO_DATE (pFchFin ||' 23:59:59' ,'%Y-%m-%d %H:%M:%S') ORder BY m.oficio

					IF idTipBusq = 4 THEN

						LET cNombre = 'No. Cliente: '  || cNombre;

					ELIF idTipBusq = 5 THEN

						LET cNombre = 'No. Cuenta: '  ||  cNombre;

					ELIF idTipBusq = 6 THEN

						LET cNombre = 'No. Tarjeta: ' ||  cNombre;

					END IF;

				EXECUTE PROCEDURE bdinteg:sp_cnsif_consultaejecutivo(pUsuario , pIdFuncion, cUserINSERT) 

				INTO  cCodRetorno, cNumEmple, cUsuEstado, cUsuIp,

						cUsuMac, cNombreUser, iUsuBloqueo ; 

				LET iContador= iContador + 1;

				RETURN cCodRet, cNombre, cRfc, cNumcte, cCuenta, cMotivoBlo, mMontoBlo, cfchOficio, cOficio, cUserINSERT, cNombreUser WITH resume;

			END  FOREACH

		END IF;

        IF pStatusBusqueda=1 THEN

			-- SELECCIONA UN REGISTRO PARA GENERAR EL REPORTE LOCALIZADOS

			SET ISOLATION TO DIRTY READ;

            FOREACH

				SELECT {+INDEX (bdicnweb:sw_ro_resulper idx_numcte)} skip pRegistros FIRST pRecuperacion

					TRIM( TRIM(rc.apell_paterno)|| ' ' ||TRIM(rc.apell_materno)|| ' ' || TRIM(rc.nombre1) || ' ' || TRIM(rc.nombre2) || ' ' || TRIM( rc.razon_social)) AS nombre

					, rc.rfc

					, rc.numcte

					, c.ind_bloqueo_cta_por_sistema

					, c.cuenta

					, m.fecha_oficio

					, m.oficio

					, m.user_INSERT

					, r.id_busqueda

					, b.id_resulcte 

				INTO cNombre, cRfc, cNumcte, cIndBloSis, 

						cCuenta,  cfchOficio , cOficio, cUserINSERT, 

						iIdBusq, ibusq

				FROM ((sw_ro_resulper AS r LEFT JOIN sw_ro_ctecta c ON (c.id_oficio = r.id_oficio AND c.id_busqueda = r.id_busqueda AND c.ind_terminado = '1'))

					LEFT JOIN sw_ro_bloqueos b ON (b.id_oficio = c.id_oficio AND b.id_busqueda = c.id_busqueda AND b.id_resulcte = c.id_resulcte AND b.cuenta = c.cuenta))

					LEFT JOIN sw_ro_resulcte rc  ON r.id_resulper=rc.id_resulper AND r.id_busqueda = rc.id_busqueda AND r.id_oficio = rc.id_oficio 

					, sw_ro_maeoficios AS m

				WHERE r.status_busqueda = pStatusBusqueda 

					AND r.ind_omitir = '0' 

					AND r.status = '1'

					AND r.fecha_INSERT >= TO_DATE (pFchInicio ||' 00:00:00' ,'%Y-%m-%d %H:%M:%S' ) 	

					AND r.fecha_INSERT <= TO_DATE (pFchFin ||' 23:59:59' ,'%Y-%m-%d %H:%M:%S')

					AND m.id_oficio = r.id_oficio

					ORDER BY r.numcte, m.oficio

				IF cIndBloSis = '1' THEN

					SET ISOLATION TO DIRTY READ;

					SELECT monto_bloqueo,causa_bloqueo 

					INTO  mMontoBlo, cMotivoBlo

					FROM    sw_ro_bloqueos 

					WHERE  cuenta = cCuenta 

						AND id_busqueda=iIdBusq 

						AND id_resulcte=ibusq;

				ELSE

					LET cMotivoBlo	 = '';

					LET mMontoBlo	 = 0;

				END IF;

				EXECUTE PROCEDURE bdinteg:sp_cnsif_consultaejecutivo(pUsuario , pIdFuncion, cUserINSERT) 

				INTO  cCodRetorno, cNumEmple, cUsuEstado, cUsuIp,

						cUsuMac, cNombreUser, iUsuBloqueo ; 

				LET iContador= iContador + 1;

				RETURN cCodRet, cNombre, cRfc, cNumcte, cCuenta, cMotivoBlo, mMontoBlo, cfchOficio, cOficio, cUserINSERT, cNombreUser WITH resume;

			END  FOREACH

        END IF;

        IF pStatusBusqueda=2 THEN

			-- SELECCIONA UN REGISTRO PARA GENERAR EL REPORTE  HOMONIMOS

			SET ISOLATION TO DIRTY READ;

            FOREACH SELECT {+INDEX (bdicnweb:sw_ro_resulper idx_numcte)} skip pRegistros FIRST pRecuperacion

				rp.id_busqueda

				, TRIM( TRIM(rp.apell_paterno)|| ' ' ||TRIM(rp.apell_materno)|| ' ' || TRIM(rp.nombre1) || ' ' || TRIM(rp.nombre2) || ' ' || TRIM( rp.razon_social)) AS nombre

				, TRIM(rp.rfc) AS rfc

				, rp.numcte

				, m.fecha_oficio

				, m.oficio

				, m.user_INSERT 

				INTO ibusq, cNombre, cRfc, cNumcte, cfchOficio , cOficio, cUserINSERT 

				FROM sw_ro_resulper rp

				, sw_ro_maeoficios m

				WHERE rp.status_busqueda = pStatusBusqueda AND rp.status = 1 AND rp.ind_omitir = 0

					AND  rp.fecha_INSERT >= TO_DATE (pFchInicio ||' 00:00:00' ,'%Y-%m-%d %H:%M:%S' )

					AND rp.fecha_INSERT <= TO_DATE (pFchFin ||' 23:59:59' ,'%Y-%m-%d %H:%M:%S')

					AND m.id_oficio = rp.id_oficio

					AND m.user_INSERT = rp.user_INSERT

				EXECUTE PROCEDURE bdinteg:sp_cnsif_consultaejecutivo(pUsuario , pIdFuncion, cUserINSERT) 

				INTO  cCodRetorno, cNumEmple, cUsuEstado, cUsuIp,cUsuMac, cNombreUser, iUsuBloqueo ; 

                LET iContador= iContador + 1;

				RETURN cCodRet, cNombre, cRfc, cNumcte, cCuenta, cMotivoBlo, mMontoBlo, cfchOficio, cOficio, cUserINSERT, cNombreUser WITH resume;

			END  FOREACH

		END IF;

		IF iContador = 0  THEN

			LET cCodRet='01001';

			RETURN cCodRet, cNombre, cRfc, cNumcte, cCuenta, cMotivoBlo, mMontoBlo, cfchOficio, cOficio, cUserINSERT, cNombreUser;	

		END IF;

	END;

END PROCEDURE;