CREATE PROCEDURE "informix".sp_sw_ro_consrepopermaeofi(pUsuario CHAR(8), pIdFunciON CHAR(10), pFchInicio CHAR(10),pFchFin CHAR(10),  
											pRegistros INT, pRecuperaciON INT, pUsuarioINSERT CHAR(8))
	RETURNING CHAR(5) AS     CodRet,
		     CHAR(8) AS  UserINSERT,
			 CHAR(45) AS  NombreUser,
			 CHAR(164) AS Nombre, 
			 CHAR(13) AS  Rfc, 
			 CHAR(20) AS  Numcte, 
			 CHAR(20) AS  Cuenta, 
			 CHAR(40) AS  MotivoBlo,
			 MONEY(14,2) AS  MontoBlo,
			 CHAR(15) AS  Respuesta,
			 CHAR(10) AS  FchOficio, 
			 CHAR(60) AS  Oficio
	DEFINE cCodRet	   CHAR(5);
	DEFINE iSqlErr 	   INT;
	DEFINE cUserINSERT CHAR (8);
	DEFINE cNombreUser CHAR(45);
	DEFINE cNombre     CHAR(164); 
	DEFINE crfc        CHAR(13); 
	DEFINE cNumcte     CHAR(20); 
	DEFINE cCuenta     CHAR(20); 
	DEFINE cIndBloSis  CHAR(1);
	DEFINE cMotivoBlo  CHAR(40);
	DEFINE mMontoBlo   MONEY(14,2);
	DEFINE cRespuesta  CHAR(15);
	DEFINE cfchOficio  CHAR(10); 
	DEFINE cOficio 	   CHAR(60);
	DEFINE cCodRetorno CHAR(5);
	DEFINE cNumEmple   CHAR(8);
	DEFINE cUsuEstado  CHAR(1);
	DEFINE cUsuIp	   CHAR(15);
	DEFINE cUsuMac 	   CHAR(17);
	DEFINE iUsuBloqueo INTEGER;
	DEFINE iContador   INTEGER;
	DEFINE iRegistros  INTEGER;
	DEFINE iId 		   INTEGER;	
	DEFINE idBusq 	   INTEGER;
	DEFINE iIdBusqueda INTEGER;
	DEFINE iIdoficio   INTEGER;
	DEFINE iIdResulper INTEGER;
	LET cCodRet     = '00000';
	LET iSqlErr	    = 0;
	LET cUserINSERT = '';
	LET cNombreUser = '';
	LET cNombre     = ''; 
	LET crfc        = ''; 
	LET cNumcte     = ''; 
	LET cCuenta     = '';
	LET cIndBloSis  = '';	
	LET cMotivoBlo  = '';
	LET mMontoBlo	= 0;
	LET cRespuesta  = '';
	LET cfchOficio  = ''; 
	LET cfchOficio  = ''; 
	LET cOficio 	= '';
	LET cCodRetorno = '';
	LET cNumEmple   = '';
	LET cUsuEstado	= '';
	LET cUsuIp		= '';
	LET cUsuMac     = '';
	LET iUsuBloqueo = 0;
	LET iContador   = 0; 	
	LET iRegistros  = 0;	
	LET iId			= 0;
	LET idBusq 		= 0;
	LET iIdBusqueda = 0;
	LET iIdoficio   = 0;
	LET iIdResulper = 0;

	BEGIN
		--EXEPCIONES
		ON EXCEPTION SET  iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet= iSqlErr;
				RETURN  cCodRet,cUserINSERT, cNombreUser, cNombre, 
						crfc,  cNumcte,  cCuenta,  cMotivoBlo, 
						mMontoBlo, cRespuesta, cfchOficio, cOficio;
			END IF;				
		END EXCEPTION;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN  cCodRet,cUserINSERT, cNombreUser, cNombre, 
					crfc,  cNumcte,  cCuenta,  cMotivoBlo, 
					mMontoBlo, cRespuesta, cfchOficio,  cOficio;
		END IF;
		-- VALIDACIONES DE ENTRADA
		IF  pUsuario = '' OR 
			pIdFunciON = '' OR 
			pFchInicio  = '' OR 
			pFchFin  = '' OR 
			pRegistros = '' OR 
			pRecuperaciON = ''
			THEN
				LET cCodRet = '00003';
				RETURN  cCodRet,cUserINSERT, cNombreUser, cNombre, 
					crfc,  cNumcte,  cCuenta,  cMotivoBlo, 
					mMontoBlo, cRespuesta, cfchOficio,  cOficio;
		END IF;
              --VALIDA SI HAY DATOS 
		SET ISOLATION TO DIRTY READ;
		SELECT {+INDEX (bdicnweb:sw_ro_resulper idx_numcte)} COUNT(*) INTO  iRegistros
            FROM sw_ro_resulper AS r LEFT JOIN sw_ro_ctecta AS c ON (r.id_resulper= c.id_resulcte 
				AND r.id_oficio = c.id_oficio 
				AND r.id_busqueda = c.id_busqueda) 
				LEFT JOIN sw_ro_bloqueos AS b ON (c.id_resulcte=b.id_resulcte AND c.id_oficio = b.id_oficio) 
				LEFT JOIN sw_ro_maeoficios AS m on(r.id_oficio= m.id_oficio)							 
			WHERE r.status=1 
				AND  r.fecha_INSERT >= TO_DATE (pFchInicio ||' 00:00:00' ,'%Y-%m-%d %H:%M:%S' ) 
				AND r.fecha_INSERT <= TO_DATE (pFchFin ||' 23:59:59' ,'%Y-%m-%d %H:%M:%S')
                AND r.user_INSERT = pUsuarioINSERT;
            --MANDAR CODIGO  "NO EXISTE DATOS"
            IF iRegistros = 0 AND pRegistros = 0  THEN
                LET cCodRet='00017';
				RETURN  cCodRet, cNumEmple, cNombreUser, cNombre, 
						crfc,  cNumcte,  cCuenta,  cMotivoBlo, 
						mMontoBlo, cRespuesta, cfchOficio, cOficio;
		    END IF;
		
		SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdicnweb:sw_ro_resulper idx_numcte)} skip pRegistros FIRST pRecuperaciON DISTINCT (rp.id_busqueda),
					TRIM(TRIM(TRIM(TRIM( TRIM(TRIM(b.apell_paterno)|| ' ' ||
					TRIM(b.apell_materno))|| ' ' || TRIM(b.nombre1)) || ' ' || 
					TRIM(b.nombre2)) || ' ' || TRIM( b.razon_social)|| ' ' || 
					TRIM( b.num_tarjeta))) 
					AS nombre,b.rfc,b.numcte,b.cuenta,
						b.id_tipobusqueda, c.ind_bloqueo_cta_por_sistema, rp.status_busqueda, m.fecha_oficio,
						m.oficio
                INTO iId, cNombre, crfc,  cNumcte,  
						cCuenta, idBusq, cIndBloSis,  cRespuesta, 
						cfchOficio,cOficio
				FROM sw_ro_resulper rp LEFT JOIN sw_ro_buscaper b ON rp.id_busqueda = b.id_busqueda 
										LEFT JOIN sw_ro_resulcte rc 	ON rc.id_busqueda = rp.id_busqueda 
										LEFT JOIN sw_ro_ctecta c ON (b.id_busqueda=c.id_busqueda AND b.numcte = c.numcte AND b.cuenta= c.cuenta)
										LEFT JOIN sw_ro_maeoficios AS m on(b.id_oficio= m.id_oficio)
                WHERE  rp.ind_omitir = 0 
					AND rp.status=1 
					AND  rp.fecha_INSERT >= TO_DATE (pFchInicio ||' 00:00:00' ,'%Y-%m-%d %H:%M:%S' ) 
					AND rp.fecha_INSERT <= TO_DATE (pFchFin ||' 23:59:59' ,'%Y-%m-%d %H:%M:%S') 
					AND rp.user_INSERT = pUsuarioINSERT ORDER BY m.oficio 
				
				EXECUTE PROCEDURE bdinteg:sp_cnsif_consultaejecutivo(pUsuario , pIdFuncion, pUsuarioINSERT) 
					INTO  cCodRetorno, cNumEmple, cUsuEstado, cUsuIp,cUsuMac, 
							cNombreUser, iUsuBloqueo;
				IF idBusq = 6 THEN
					LET cNombre = 'No. Tarjeta: ' ||  cNombre;
				END IF;
				--AGREGAR LA DESCRIPCION DEL BLOQUEO 
				IF cIndBloSis = '1'THEN
					SET ISOLATION TO DIRTY READ;
					SELECT bl.monto_bloqueo,bl.causa_bloqueo 
                    INTO cMotivoBlo, mMontoBlo
                    FROM sw_ro_buscaper b
					LEFT JOIN sw_ro_bloqueos AS bl ON (b.id_busqueda=bl.id_busqueda AND b.numcte= bl.numcliente AND b.cuenta = bl.cuenta)
					WHERE bl.id_busqueda=iId;
				END IF;
				IF cRespuesta= '1'  THEN
					LET cRespuesta='Localizado';
					SET ISOLATION TO DIRTY READ;
					SELECT TRIM( TRIM(apell_paterno)|| ' ' ||TRIM(apell_materno)|| ' ' || 
							TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || 
							TRIM( razon_social)) 
						AS nombre,rfc,numcte
					INTO   cNombre, crfc,  cNumcte
					FROM  sw_ro_resulcte  
					WHERE  id_busqueda = iId;
				ELIF cRespuesta= '2' THEN
					LET cRespuesta='Homonimo';
				ELIF cRespuesta= '0' THEN
					LET cRespuesta='No Localizado';
				END IF;
                LET iContador= iContador + 1;
				RETURN  cCodRet, cNumEmple, cNombreUser, cNombre, 
						crfc,  cNumcte,  cCuenta,  cMotivoBlo,
						mMontoBlo, cRespuesta, cfchOficio, cOficio 
					WITH resume;
			END FOREACH
		END
        IF iContador = 0  THEN
			LET cCodRet='01001';
			RETURN cCodRet, cNumEmple, cNombreUser, cNombre, 
					crfc,  cNumcte,  cCuenta,  cMotivoBlo, 
					mMontoBlo, cRespuesta, cfchOficio, cOficio;	
        END IF;
END PROCEDURE;