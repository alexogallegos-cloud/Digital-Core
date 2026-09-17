CREATE PROCEDURE "informix".sp_monitor_atm_admin_ofi_web(pempresa CHAR(3),
												pplaza CHAR(3),
												psucursal CHAR(4),
												pregistro SMALLINT,
												pfinicio DATE,
												pffin DATE)
RETURNING
	CHAR(5),
	CHAR(8),       -- vfoliooper
	CHAR(4),       -- vsucursal
	DATE,          -- vfechasolicitud
	CHAR(8),       -- vusuariosolicitud
	DATE,          -- vfechaenvio
	CHAR(8),       -- vusuarioenvio
	DATE,          -- vfeCHARecepcion
	CHAR(8),       -- vusuariorecepcion
	CHAR(2),       -- vstatus
	DECIMAL(14,2), -- vmonto
	DATE,          -- vfeCHAReversion
	CHAR(8),       -- vusuarioreversion
	CHAR(40),      -- vnombre
	CHAR(30),      -- vdescripcion
	CHAR(4),       -- vcod_trans
	CHAR(35),      -- vdesc_trans
	CHAR(18),      -- vdeno_1
	CHAR(18),      -- vdeno_2
	CHAR(18),      -- vdeno_3
	CHAR(18),      -- vdeno_4
	CHAR(18),      -- vdeno_5
	CHAR(18),      -- vdeno_6
	CHAR(18),      -- vdeno_7
	CHAR(18),      -- vdeno_8
	CHAR(18),      -- vdeno_9
	CHAR(18),      -- vdeno_10
	CHAR(18),      -- vcant_1
	CHAR(18),      -- vcant_2
	CHAR(18),      -- vcant_3
	CHAR(18),      -- vcant_4
	CHAR(18),      -- vcant_5
	CHAR(18),      -- vcant_6
	CHAR(18),      -- vcant_7
	CHAR(18),      -- vcant_8
	CHAR(18),      -- vcant_9
	CHAR(18);      -- vcant_10
	

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE vfoliooper CHAR(8);
DEFINE vsucursal CHAR(4);
DEFINE vfechasolicitud DATE;
DEFINE vusuariosolicitud CHAR(8);
DEFINE vfechaenvio DATE;
DEFINE vusuarioenvio CHAR(8);
DEFINE vfeCHARecepcion DATE;
DEFINE vusuariorecepcion CHAR(8);
DEFINE vstatus CHAR(2);
DEFINE vmonto DECIMAL(14,2);
DEFINE vfeCHAReversion DATE;
DEFINE vusuarioreversion CHAR(8);
DEFINE vplaza CHAR(3);
DEFINE vcont SMALLINT;
DEFINE vnombre CHAR(40);
DEFINE vdescripcion CHAR(30);
DEFINE vcod_trans CHAR(4);
DEFINE vdesc_trans CHAR(35);

DEFINE vdeno_1 CHAR(18);
DEFINE vdeno_2 CHAR(18);
DEFINE vdeno_3 CHAR(18);
DEFINE vdeno_4 CHAR(18);
DEFINE vdeno_5 CHAR(18);
DEFINE vdeno_6 CHAR(18);
DEFINE vdeno_7 CHAR(18);
DEFINE vdeno_8 CHAR(18);
DEFINE vdeno_9 CHAR(18);
DEFINE vdeno_10 CHAR(18);


DEFINE vcant_1 INTEGER;
DEFINE vcant_2 INTEGER;
DEFINE vcant_3 INTEGER;
DEFINE vcant_4 INTEGER;
DEFINE vcant_5 INTEGER;
DEFINE vcant_6 INTEGER;
DEFINE vcant_7 INTEGER;
DEFINE vcant_8 INTEGER;
DEFINE vcant_9 INTEGER;
DEFINE vcant_10 INTEGER;

LET vcodret = "00000";
LET  vsqlerr = 0;
LET vfoliooper = "";
LET vsucursal = "";
LET vfechasolicitud ="";
LET vusuariosolicitud = "";
LET vfechaenvio ="";
LET vusuarioenvio = "";
LET vfeCHARecepcion = "";
LET vusuariorecepcion = "";
LET vstatus = "";
LET vmonto = 0;
LET vfeCHAReversion ="";
LET vusuarioreversion = "";
LET vplaza = "";
LET vcont = 0;
LET vnombre ="";
LET vdescripcion ="";
LET vcod_trans ="";
LET vdesc_trans = "";
LET vdeno_1 ="";
LET vdeno_2 ="";
LET vdeno_3 ="";
LET vdeno_4 ="";
LET vdeno_5 ="";
LET vdeno_6 ="";
LET vdeno_7 ="";
LET vdeno_8 ="";
LET vdeno_9 ="";
LET vdeno_10 ="";

LET vcant_1 ="";
LET vcant_2 ="";
LET vcant_3 ="";
LET vcant_4 ="";
LET vcant_5 ="";
LET vcant_6 ="";
LET vcant_7 ="";
LET vcant_8 ="";
LET vcant_9 ="";
LET vcant_10 ="";


--SET debug file to "/informix/sp_monitor.out";
--trace on;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret,vfoliooper,vsucursal,vfechasolicitud,vusuariosolicitud,
                     vfechaenvio,vusuarioenvio,vfeCHARecepcion,vusuariorecepcion,vstatus,vmonto,vfeCHAReversion,
                     vusuarioreversion,vnombre, vdescripcion,vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,vdeno_4,vdeno_5,vdeno_6,vdeno_7,vdeno_8,vdeno_9,vdeno_10, vcant_1, vcant_2, vcant_3,vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10;

      END IF;
   END EXCEPTION;

	IF pplaza IS NULL OR pplaza = '' THEN
		SELECT plaza_cajagen INTO vplaza
		FROM   bdinteg:"informix".si_sucursales
		WHERE  sucursal = psucursal;
	ELSE
		LET  vplaza = pplaza;
	END IF;

   IF psucursal != '' THEN
      FOREACH
         SELECT   o.folio_oper,o.cod_trans,p.descripcion,o.denominacion_1,o.denominacion_2,o.denominacion_3,
                  o.denominacion_4,o.denominacion_5,o.denominacion_6,o.denominacion_7,o.denominacion_8,o.denominacion_9,o.denominacion_10,o.cantidad_1,o.cantidad_2,o.cantidad_3,o.cantidad_4,
                  o.cantidad_5,o.cantidad_6,o.cantidad_7,o.cantidad_8,o.cantidad_9,o.cantidad_10,o.monto,o.sucursal

         INTO      vfoliooper,vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,
                     vdeno_4,vdeno_5,vdeno_6,vdeno_7,vdeno_8,vdeno_9,vdeno_10, vcant_1, vcant_2, vcant_3,
                     vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10,vmonto,vsucursal

         FROM   bdisuc:"informix".ss_param_cajagen p , bdisuc:"informix".ss_operaciones o
         WHERE o.sucursal = psucursal AND
         o.cod_trans = p.codigo AND o.cod_trans BETWEEN '0036' AND '0040' AND 
         o.fecha_operacion BETWEEN pfinicio AND pffin ORDER BY o.folio_oper


         SELECT    m.fecha_solicitud, m.usuario_solicitud,
                  m.fecha_envio, m.usuario_envio, m.fecha_recepcion, m.usuario_recepcion, m.status, m.fecha_reversion,
                  m.usuario_reversion
         INTO     vfechasolicitud,vusuariosolicitud,
                  vfechaenvio,vusuarioenvio,vfeCHARecepcion,vusuariorecepcion,vstatus,vfeCHAReversion,
                  vusuarioreversion
         FROM bdisuc:"informix".ss_mae_entradasalida m
         WHERE folio_oper = vfoliooper;
		 
		 IF NVL(vfechasolicitud, '') = '' THEN
			SELECT fecha_operacion
			INTO vfechasolicitud
			FROM bdisuc:"informix".ss_operaciones
			WHERE folio_oper = vfoliooper;
		 END IF

		 SELECT nombre
         INTO vnombre
         FROM bdinteg:"informix".si_sucursales
         WHERE sucursal = vsucursal;

         SELECT descripcion
         INTO vdescripcion
         FROM bdisuc:"informix".ss_catstatus
         WHERE status = vstatus;

         IF vdescripcion IS NULL THEN
          LET vdescripcion = 'Operacion Realizada';
         END IF;


         IF vcont < pregistro THEN
            LET vcont = vcont + 1;
            CONTINUE foreach;
         END IF
         LET vcont = vcont + 1;
		 

        RETURN    NVL(vcodret, '00001'), vfoliooper,vsucursal,vfechasolicitud,vusuariosolicitud,
                  vfechaenvio,vusuarioenvio,vfeCHARecepcion,vusuariorecepcion,vstatus,vmonto,vfeCHAReversion,
                  vusuarioreversion,vnombre, vdescripcion, vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,
                     vdeno_4,vdeno_5,vdeno_6,vdeno_7,vdeno_8,vdeno_9,vdeno_10, vcant_1, vcant_2, vcant_3,
                     vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10
                  WITH RESUME;

   END FOREACH;

ELSE
   FOREACH
          SELECT   o.folio_oper,o.cod_trans,p.descripcion,o.denominacion_1,o.denominacion_2,o.denominacion_3,
                  o.denominacion_4,o.denominacion_5,o.denominacion_6,o.denominacion_7,o.denominacion_8,o.denominacion_9,o.denominacion_10,o.cantidad_1,o.cantidad_2,o.cantidad_3,o.cantidad_4,
                  o.cantidad_5,o.cantidad_6,o.cantidad_7,o.cantidad_8,o.cantidad_9,o.cantidad_10,o.monto,o.sucursal

         INTO      vfoliooper,vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,
                     vdeno_4,vdeno_5,vdeno_6,vdeno_7,vdeno_8,vdeno_9,vdeno_10, vcant_1, vcant_2, vcant_3,
                     vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10,vmonto,vsucursal

         FROM   bdisuc:"informix".ss_param_cajagen p , bdisuc:"informix".ss_operaciones o
         WHERE o.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales
                                              WHERE plaza_cajagen = pplaza AND
                                                    tpo_sucursal = "C" ) AND
         o.cod_trans = p.codigo AND o.cod_trans BETWEEN '0036' AND '0040' AND
         o.fecha_operacion BETWEEN pfinicio AND pffin ORDER BY o.folio_oper


         SELECT    m.fecha_solicitud, m.usuario_solicitud,
                  m.fecha_envio, m.usuario_envio, m.fecha_recepcion, m.usuario_recepcion, m.status, m.fecha_reversion,
                  m.usuario_reversion
         INTO     vfechasolicitud,vusuariosolicitud,
                  vfechaenvio,vusuarioenvio,vfeCHARecepcion,vusuariorecepcion,vstatus,vfeCHAReversion,
                  vusuarioreversion
         FROM bdisuc:"informix".ss_mae_entradasalida m
         WHERE folio_oper = vfoliooper;


		 IF NVL(vfechasolicitud, '') = '' THEN
			SELECT fecha_operacion
			INTO vfechasolicitud
			FROM bdisuc:"informix".ss_operaciones
			WHERE folio_oper = vfoliooper;
		 END IF
		 
		 
         SELECT nombre
         INTO vnombre
         FROM bdinteg:"informix".si_sucursales
         WHERE sucursal = vsucursal;

         SELECT descripcion
         INTO vdescripcion
         FROM bdisuc:"informix".ss_catstatus
         WHERE status = vstatus;

        IF vdescripcion IS NULL THEN
          LET vdescripcion = 'Operacion Realizada';
        END IF;

        IF vcont < pregistro THEN
            LET vcont = vcont + 1;
            continue foreach;
        END IF
        LET vcont = vcont + 1;


        RETURN    NVL(vcodret, '00001'),vfoliooper,vsucursal,vfechasolicitud,vusuariosolicitud,
                     vfechaenvio,vusuarioenvio,vfeCHARecepcion,vusuariorecepcion,vstatus,vmonto,vfeCHAReversion,vusuarioreversion,vnombre, vdescripcion,vcod_trans,vdesc_trans,vdeno_1,vdeno_2,vdeno_3,vdeno_4,vdeno_5,vdeno_6,vdeno_7,vdeno_8,vdeno_9,vdeno_10, vcant_1, vcant_2, vcant_3,vcant_4, vcant_5, vcant_6,vcant_7,vcant_8,vcant_9,vcant_10
                  WITH RESUME;

   END FOREACH;

END IF;
END
END PROCEDURE
DOCUMENT
'MODIFICÃÂ:    	Jesus Moreno',
'FECHA:       	14/10/2019',
'DESCRIPCIÃÂN: 	se modIFica el tipo de dato de las variables DEFINE vcant_1,vcant_2,vcant_3,vcant_4,vcant_5 ,vcant_6',
'BASE DE DATOS: bdisuc',
'FOLIO:628',
'Llamado desde:MonitorAtm.exe',
'MODIFICÃÂ:    	Jesus Moreno',
'FECHA:       	06/01/2020',
'DESCRIPCIÃÂN: 	se renombra el sp de sp_monitor_atm01 a sp_monitor_atm_admin';

CREATE PROCEDURE "informix".sp_consultarcardcarriers_web(p_sEmpresa CHAR(3), p_sSucursal CHAR(10), p_sTipoImagen CHAR(1), p_sFolio CHAR(16), 
											p_sNumCaja CHAR(10), p_iNumPaquete INTEGER,
											p_iCantRegistros INTEGER,p_cOpcion CHAR(1),
											p_sSecuencia CHAR(5))
	RETURNING	CHAR(5)  	AS retorno, 
				CHAR(3)  	AS empresa, 
				CHAR(10) 	AS numerocaja,
				CHAR(1)  	AS tipoimagen,
				INTEGER  	AS numeropaquete,
				CHAR(16) 	AS folioinicio,
				CHAR(16) 	AS foliofinal,
				CHAR(4)  	AS sucursal,
				CHAR(1)  	AS estatus,
				DATE     	AS fecha_insert,
				CHAR(80) 	AS desimagen,
				CHAR(8)  	AS numUsuarioRegistro,
				CHAR(45) 	AS desUsuarioRegistro,
				CHAR(8)  	AS numUsuarioAutorizo,
				CHAR(45) 	AS desUsuarioAutorizo,					
				CHAR(8)  	AS numUsuarioSolicita,
				CHAR(45) 	AS desUsuarioSolicita,
				CHAR(100) 	AS desComentario,
				--folio_1668
				INTEGER 	AS iCantHojas,
				INTEGER 	AS iCapacidad,
				INTEGER 	AS iCantDocs,
				CHAR(5)		AS sSecuencia;	
				
	
	DEFINE iSqlErr					INTEGER;
	DEFINE v_sValRetorno			CHAR(5);
	DEFINE v_sEmpresa				CHAR(3);
	DEFINE v_sNumCaja 				CHAR(10);
	DEFINE v_sTipoImagen			CHAR(1);
	DEFINE v_sFolioInicio			CHAR(16);
	DEFINE v_sFolioFinal			CHAR(16);
	DEFINE v_sSucursal				CHAR(4);
	DEFINE v_sEstatus				CHAR(1);
	DEFINE v_iNumPaquete			INTEGER;	
	DEFINE v_dFechaInsercion		DATE;	
	DEFINE v_iFolio					INT8;
	DEFINE v_iFolioInicio			INT8;
	DEFINE v_iFolioFinal			INT8;
	DEFINE v_sDesimagen				CHAR(80);
	DEFINE v_sNumUsuarioRegistro	CHAR(8);
	DEFINE v_sDesUsuarioRegistro	CHAR(45);
	DEFINE v_sNumUsuarioAutorizo	CHAR(8);
	DEFINE v_sDesUsuarioAutorizo	CHAR(45);
	DEFINE v_sNumUsuarioSolicita	CHAR(8);
	DEFINE v_sDesUsuarioSolicita	CHAR(45);
	DEFINE v_sDesComentario			CHAR(100);
	--folio_1668
	DEFINE iNumReg					INTEGER;
	DEFINE iCapacidad				INTEGER;	
	DEFINE iCantidad 				INTEGER;
	DEFINE iCantDocs				INTEGER;
	DEFINE iBandUpdate				INTEGER;
	DEFINE sSecuencia				CHAR(5);
	
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/informix/mireya/sp_consultarcardcarriers_web.out";
	--TRACE ON;
	-----------------------------------------------------------------------------	
	
	LET v_sValRetorno 		= '00001';
	--folio_1668
	LET iNumReg 			= 0;
	LET iCapacidad 			= 0;
	LET iCantDocs 			= 0;	
	LET v_sDesComentario 	= '';
	LET iBandUpdate 		= 1;
	LET sSecuencia 			= '';
	BEGIN	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','',0,0,0,'';
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		--LOS PARAMETROS NO DEBEN SER NULOS					--folio_1668
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sSucursal,'')='' OR NVL(p_cOpcion,'')='' 
		OR (p_cOpcion NOT IN ('1','2')) THEN
			RETURN v_sValRetorno,'','','','','','','','','','','','','','','','','',0,0,0,'';
		END IF;
		
		-- ACTUALIZA LOS PAQUETES CARDCARRIERS DE UNA SUCURSAL
		IF p_cOpcion = '2' THEN
		
			IF p_sEmpresa = '' OR p_sNumCaja = '' OR p_sSucursal = ''  THEN
				RETURN v_sValRetorno,'','','','','','','','','','','','','','','','','',0,0,0,'';
			END IF;
		
			UPDATE "informix".ss_cardcarriers SET estatus='E'  WHERE empresa = p_sEmpresa 
			AND numerocaja = p_sNumCaja AND sucursal = p_sSucursal AND numeropaquete=p_iNumPaquete;
			
			LET iBandUpdate = 1;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET v_sValRetorno = '00002'; 
					RETURN v_sValRetorno,'','','','','','','','','','','','','','','','','',0,0,0,'';
				END IF;
				
				IF iBandUpdate = 1 THEN

					UPDATE "informix".ss_cardcarriers 
					SET numeropaquete = numeropaquete - 1
					WHERE empresa = p_sEmpresa
					AND numerocaja = p_sNumCaja
					AND sucursal = p_sSucursal
					AND numeropaquete > p_iNumPaquete
					AND estatus <> 'E';
					---AND secuencia = p_sSecuencia;
					
					/*IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
						LET v_sValRetorno = '00007'; 
						RETURN v_sValRetorno,'','','','','','','','','','','','','','','','','',0,0,0,'';
					END IF;*/
					
					--SE ACTUALIZA EL NUMERO DE HOJAS REGISTRADAS POR LA CANTIDAD TOTAL DE HOJAS
					SELECT NVL(SUM(cantidad_hojas),0) 
					INTO iCantidad
					FROM "informix".ss_cardcarriers
					WHERE empresa = p_sEmpresa
					AND numerocaja = p_sNumCaja
					AND sucursal = p_sSucursal
					AND estatus <> 'E';

					UPDATE "informix".ss_numcajas
					SET num_hojas_registradas = iCantidad
					WHERE empresa = p_sEmpresa
					AND numerocaja = p_sNumCaja
					AND numsucursal = p_sSucursal
					AND estatus = 'Activa'
					AND tipopaquete = 4;
						
						
					LET v_sValRetorno = '00000';
					
				END IF;		
					
						
					LET v_sEmpresa = NULL;
					LET v_sNumCaja = NULL;
					LET v_sTipoImagen = NULL;
					LET v_iNumPaquete = NULL;
					LET v_sFolioInicio = NULL;
					LET v_sFolioFinal = NULL;
					LET v_sSucursal = NULL;
					LET v_sEstatus = NULL;
					LET v_sDesimagen = NULL;
					LET v_sNumUsuarioRegistro = NULL;
					LET v_sDesUsuarioRegistro = NULL;
					LET v_sNumUsuarioAutorizo = NULL;
					LET v_sDesUsuarioAutorizo = NULL;
					LET v_sDesUsuarioSolicita = NULL;
					LET v_sNumUsuarioSolicita = NULL;
					LET v_sDesComentario = NULL;
					LET v_dFechaInsercion = NULL;
					

				
				RETURN NVL(v_sValRetorno,''), NVL(v_sEmpresa,''), NVL(v_sNumCaja,''), 
				NVL(v_sTipoImagen,''), NVL(v_iNumPaquete,''), NVL(v_sFolioInicio,''), 
				NVL(v_sFolioFinal,''),NVL(v_sSucursal,''),NVL(v_sEstatus,''),
				NVL(v_dFechaInsercion,''), NVL(v_sDesimagen,''), NVL(v_sNumUsuarioRegistro,''),
				NVL(v_sDesUsuarioRegistro,''), NVL(v_sNumUsuarioAutorizo,''), 
				NVL(v_sDesUsuarioAutorizo,''), NVL(v_sNumUsuarioSolicita,''),
				NVL(v_sDesUsuarioSolicita,''),NVL(v_sDesComentario,''),iNumReg,iCapacidad,iCantDocs,NVL(sSecuencia,'');		

		END IF;	
		
		-- CONSULTA LOS PAQUETES CARDCARRIERS DE UNA SUCURSAL
		IF p_cOpcion = '1'  THEN
		
			IF p_sFolio = '' THEN
				LET p_sFolio = NULL;
			END IF;

			IF p_sNumCaja = '' THEN
				LET p_sNumCaja = NULL;
			END IF;

			IF p_iNumPaquete = 0 THEN
				--LET p_iNumPaquete = 0;
			END IF

			IF p_sTipoImagen = '' THEN
				LET p_sTipoImagen = NULL;
			END IF;
			
			SELECT NVL(a.capacidad,0), NVL(b.num_hojas_registradas,0) 
			INTO iCapacidad,iNumReg 
			FROM "informix".ss_cattipopaquetes a, "informix".ss_numcajas b
			WHERE a.empresa = p_sEmpresa 
			AND b.numerocaja = p_sNumCaja
			AND a.tipopaquete = b.tipopaquete
			AND b.tipopaquete = '4';
		
			--OBTIENE LOS DOCUMENTOS CARDCARRIERS PARA UNA SUCURSAL Y TIPO DE IMAGEN ESPECIFICADO
			FOREACH
				SELECT SKIP p_iCantRegistros b.tipoimagen, NVL(b.descripcion,''), a.empresa, a.folioinicio, a.sucursal, a.foliofinal, a.numerocaja, 
				a.numeropaquete, a.estatus, a.usuarioregistra, a.usuarioautoriza, a.usuariosolicita, a.comentario, 
				a.fecha_insert,a.cantidad_hojas,secuencia
				INTO v_sTipoImagen, v_sDesimagen,v_sEmpresa, v_sFolioInicio,v_sSucursal,v_sFolioFinal, v_sNumCaja, 
				v_iNumPaquete, v_sEstatus, v_sNumUsuarioRegistro, v_sNumUsuarioAutorizo, v_sNumUsuarioSolicita, v_sDesComentario, 
				v_dFechaInsercion,iCantDocs,sSecuencia
				FROM "informix".ss_cardcarriers a, "informix".ss_catcardcarriers b
				--WHERE a.tipoimagen = NVL(p_sTipoImagen, a.tipoimagen ) --dsb-07/08/2012
				WHERE a.empresa = p_sEmpresa 
				AND (NVL(p_sFolio,a.foliofinal)::INT8) BETWEEN (a.folioinicio::INT8) AND (a.foliofinal::INT8)
				AND a.sucursal = p_sSucursal
				AND a.numerocaja = NVL(p_sNumCaja, a.numerocaja)
				AND a.numeropaquete = NVL(null, a.numeropaquete) 
				AND b.empresa = a.empresa			
				AND b.tipoimagen = a.tipoimagen
				AND a.estatus <> 'E'
				ORDER BY a.numeropaquete	

				--OBTIENE EL NOMBRE DEL USUARIO QUE REGISTRA
				IF NVL(v_sNumUsuarioRegistro,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioRegistro 
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioRegistro;
				ELSE
					LET v_sDesUsuarioRegistro = '';
				END IF

				--OBTIENE EL NOMBRE DEL USUARIO QUE AUTORIZA
				IF NVL(v_sNumUsuarioAutorizo,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioAutorizo 
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioAutorizo;
				ELSE
					LET v_sDesUsuarioAutorizo = '';
				END IF
				
				--OBTIENE EL NOMBRE DEL USUARIO QUE SOLICITA
				IF NVL(v_sNumUsuarioSolicita,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioSolicita
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioSolicita;
				ELSE 
					LET v_sDesUsuarioSolicita = '';
				END IF
				
				LET v_sValRetorno = '00000';
				
				
				RETURN NVL(v_sValRetorno,''), NVL(v_sEmpresa,''), NVL(v_sNumCaja,''), 
				NVL(v_sTipoImagen,''), NVL(v_iNumPaquete,''), NVL(v_sFolioInicio,''), 
				NVL(v_sFolioFinal,''),NVL(v_sSucursal,''),NVL(v_sEstatus,''),
				NVL(v_dFechaInsercion,''), NVL(v_sDesimagen,''), NVL(v_sNumUsuarioRegistro,''),
				NVL(v_sDesUsuarioRegistro,''), NVL(v_sNumUsuarioAutorizo,''), 
				NVL(v_sDesUsuarioAutorizo,''), NVL(v_sNumUsuarioSolicita,''),
				NVL(v_sDesUsuarioSolicita,''),NVL(v_sDesComentario,''),iNumReg,iCapacidad,iCantDocs,NVL(sSecuencia,'') WITH RESUME;
			END FOREACH;
		END IF;	
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
		    RETURN '00000', '', '', '', 0, 0, 0,'','',	'19000101', '','',	'','', 	'','',	'','',iNumReg,iCapacidad,iCantDocs,'';
	    END IF;	
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Erick Zamora', 
'FECHA:       04/Agosto/2009',
'DESCRIPCION: Consulta los documentos cardcarriers para una sucursal y tipo de imagen epecificado de forma paginada',
'CASO DE USO: Caso de uso asociado: PCU-bdisuc\CU-0009-ConsultarCardCarriers-SPL',
'MODIFICADO:  Fabiola Corrales 16/Oct/2009. Se modifica para agregar los campos usuarioregistra, usuarioautoriza, usuariosolicita, comentario',
'MODIFICO:     Victor Hugo NuÃ?Ã?Ã?ÃÂ±ez', 
'FECHA:       07/Agosto/2012',
'DESCRIPCION: Se remueve el filtro por tipo de imagen',
'MODIFICO: ISARAI BOJORQUEZ',
'FECHA MODIFICACION: 14 DE OCTUBRE DE 2014',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA CONSULTAR LA CANTIDAD DE HOJAS QUE TIENE LA CAJA',
'Y EL NUMERO DE HOJAS REGISTRADAS.',
'VERSION: 20141014.0952',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_consulta_piezas_bym(pOpcion CHAR(1),pDato CHAR(10),pFechaIni DATE,pFechafin DATE,pRegistros INTEGER)
RETURNING   CHAR(6)   AS CodRet, 
			INTEGER   AS IdPieza, 
			CHAR(10)  AS Denominacion , 
			CHAR(40)  AS Serie, 
			CHAR(40)  AS Folio, 
			DATE      AS FechaEmision, 
			CHAR(10)  AS NumRecibo, 
			CHAR(20)  AS Estatus, 
			CHAR(20)  AS Dictamen,
			DATE      AS FechaPago, 
			CHAR(11)  AS CuentaCliente,
			CHAR(200) AS Nota,
			CHAR(104) AS NomTenedor,
			INTEGER   AS Secuencia,
			INTEGER   AS Termino;

-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err           INTEGER;
DEFINE cCodRet            CHAR(6);
DEFINE iIdpieza           INTEGER;
DEFINE cDenominacion      CHAR(10);
DEFINE cSerie             CHAR(40);
DEFINE cFolio             CHAR(40);
DEFINE dFechaEmision      DATE;
DEFINE cNumRecibo         CHAR(10);
DEFINE cEstatus           CHAR(20);
DEFINE cDictamen          CHAR(20);
DEFINE dFechaPago         DATE;
DEFINE cCuentaCliente     CHAR(11);
DEFINE cNota              CHAR(200);
DEFINE cNomTenedor        CHAR(104);
DEFINE iIdTenedor         INTEGER;
DEFINE iDenominacion      INTEGER;
DEFINE iDictamen          INTEGER;
DEFINE iEstatus           INTEGER;
DEFINE cNombre1           CHAR(26);
DEFINE cNombre2           CHAR(26);
DEFINE cApPaterno         CHAR(26); 
DEFINE cApMaterno         CHAR(26);
DEFINE iBandCons1         INTEGER;
DEFINE iBandCons2         INTEGER;
DEFINE iBandCons3         INTEGER;
DEFINE iContador          INTEGER;
DEFINE iContadorSec       INTEGER;
DEFINE iSecuencia         INTEGER;
DEFINE iSecuencia2        INTEGER;
DEFINE iTermino           INTEGER;
DEFINE iResivos           INTEGER;
DEFINE iContRep           INTEGER;
DEFINE iFin               INTEGER;
DEFINE iQuedan            INTEGER;
DEFINE iLimit             INTEGER;
DEFINE iLimit2            INTEGER;
DEFINE iInicio            INTEGER;
DEFINE iFaltan            INTEGER;
DEFINE iContadorParaFin   INTEGER;
DEFINE cNumReciboContando CHAR(10);
DEFINE iSiguienteResivo   INTEGER; 

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET cCodRet             = '000000';
LET iIdpieza            = 0;
LET cDenominacion       = '';
LET cSerie              = '';
LET cFolio              = '';
LET dFechaEmision       = DATE(1);
LET cNumRecibo          = '';
LET cEstatus            = '';
LET cDictamen           = '';
LET dFechaPago          = DATE(1);
LET cCuentaCliente      = '';
LET cNota               = '';
LET cNomTenedor         = '';
LET iIdTenedor          = 0;
LET iDenominacion       = 0;
LET iDictamen           = 0;
LET iEstatus            = 0;
LET cNombre1            = '';
LET cNombre2            = '';  
LET cApPaterno          = '';
LET cApMaterno          = '';
LET iBandCons1          = 0;
LET iBandCons2          = 0;
LET iBandCons3          = 0;
LET iContador           = 0;
LET iContadorSec        = 0;
LET iTermino            = 0;
LET iSecuencia          = 0;
LET iSecuencia2         = 0;
LET iResivos            = 0;
LET iContRep            = 0;
LET iFin                = 0;
LET iQuedan             = 0;
LET iLimit              = 10;
LET iLimit2             = 0;
LET iInicio             = 0;
LET iFaltan             = 0;
LET iContadorParaFin    = 0;
LET cNumReciboContando  = '';
LET iSiguienteResivo    = 0;

SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/informix/Acuellar/sp_consulta_piezas_bym.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			RETURN cCodRet, iIdpieza, cDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, cEstatus, cDictamen, dFechaPago, cCuentaCliente, cNota, cNomTenedor, iSecuencia, iTermino WITH RESUME;
		END IF;
	END EXCEPTION;
	
	--validacion inicio
	IF TRIM(NVL(pOpcion,'')) = '1' OR TRIM(NVL(pOpcion,'')) = '2' OR TRIM(NVL(pOpcion,'')) = '3' OR TRIM(NVL(pOpcion,'')) = '4' THEN
		
		IF TRIM(NVL(pOpcion,'')) = '3' THEN
			IF TRIM(NVL(pFechaIni,'')) = '' OR TRIM(NVL(pFechafin,'')) = '' THEN
				LET cCodRet = '000001';
			END IF;
		ELSE
			IF TRIM(NVL(pDato,'')) = '' THEN
				LET cCodRet = '000001';
			END IF;
		END IF;
	
	ELSE
		LET cCodRet = '000001';
	END IF;
	
	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF  cCodRet =  '000000' THEN
	
		LET iSecuencia = pRegistros;
		
       IF TRIM(NVL(pOpcion,'')) = '2' THEN  --------------------------------  FOLIO     -----------------------------------------------------------------------
	
	        SELECT {+INDEX (bdisuc:"informix".ss_recibo_bym_falsos 7153_569)} COUNT(num_recibo)
			INTO iContadorSec  
			FROM bdisuc:"informix".ss_recibo_bym_falsos
			WHERE num_recibo = pDato; 
			
			LET iSecuencia2 = pRegistros;
			
			WHILE (cCodRet = '000000' AND iContRep < iLimit AND iResivos < iContadorSec  AND iTermino = 0)
			
            FOREACH 		
                SELECT {+AVOID_FULL(bdisuc:"informix".ss_recibo_bym_falsos)} SKIP iResivos LIMIT 1  num_recibo, id_tenedor
                INTO cNumRecibo, iIdTenedor
                FROM bdisuc:"informix".ss_recibo_bym_falsos
                WHERE num_recibo = pDato 
                ORDER BY num_recibo
                 
                LET iBandCons1  = 1;
                LET iSiguienteResivo = iResivos + 1; 
                
                SELECT COUNT(id_denominacion)
                INTO iContador
                FROM bdisuc:"informix".ss_piezas_bym_falsos
                WHERE  num_recibo =  cNumRecibo;

                IF iSecuencia2 > iContador THEN
                    LET iSecuencia2 = iSecuencia2 - iContador;
                ELSE
                    LET iQuedan =  iContador - iSecuencia2;
                    LET iInicio = iContador - iQuedan;
                    LET iSecuencia2 = 0;
                END IF;

                IF iSecuencia2 = 0 AND iQuedan > 0 THEN
					
						IF iContRep <> 0 THEN
							LET iLimit2 = iLimit - iContRep;
						ELSE
							LET iLimit2 = iLimit;	
						END IF;
					
						LET iFaltan = 0;
						
						IF iSiguienteResivo < iContadorSec THEN
							FOREACH 		
								SELECT SKIP iSiguienteResivo LIMIT iContadorSec  num_recibo
								INTO cNumReciboContando
								FROM bdisuc:"informix".ss_recibo_bym_falsos
								WHERE num_recibo = pDato 
								ORDER BY num_recibo
		
								SELECT COUNT(id_denominacion)
								INTO iContadorParaFin
								FROM bdisuc:"informix".ss_piezas_bym_falsos
								WHERE num_recibo = cNumReciboContando;
			
								LET iFaltan = iFaltan + NVL(iContadorParaFin,0);
		
							END FOREACH ;
						END  IF;				
						
						FOREACH																
							SELECT  SKIP iInicio LIMIT iLimit2 id_denominacion, serie, folio, fecha_emision,  estatus, dictamen_banxico, fecha_pago, nota, id_pieza, num_cta_cliente
							INTO iDenominacion, cSerie, cFolio, dFechaEmision, iEstatus, iDictamen, dFechaPago, cNota, iIdpieza, cCuentaCliente 
							FROM bdisuc:"informix".ss_piezas_bym_falsos
							WHERE num_recibo =  cNumRecibo							
							ORDER BY id_denominacion
							
							LET iBandCons2  = 1;
							
							SELECT  desc_dictamen
							INTO cDictamen
							FROM bdisuc:"informix".ss_cat_dictamen_bym_falsos
							WHERE empresa = '001' 
							AND id_dictamen = iDictamen;
							
							LET cDictamen = NVL(cDictamen,'');
							
							SELECT denominacion
							INTO cDenominacion
							FROM bdisuc:"informix".ss_denominacion_bym_falsos
							WHERE empresa = '001' 
							AND id_denominacion = iDenominacion;
							
							IF dbinfo("sqlca.sqlerrd2") = 1 THEN 

								SELECT desc_estatus
								INTO cEstatus
								FROM bdisuc:"informix".ss_cat_estatus_bym_falsos
								WHERE empresa = '001' 
								AND id_estatus = iEstatus;
									
								IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
								
									SELECT nombre_1, nombre_2, ap_paterno, ap_materno
									INTO cNombre1, cNombre2, cApPaterno, cApMaterno
									FROM bdisuc:"informix".ss_tenedor_pieza
									WHERE id_tenedor = iIdTenedor;
										
									IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
										LET cNomTenedor = TRIM(TRIM(cNombre1) || ' ' || TRIM(cNombre2)) || ' ' || TRIM(TRIM(cApPaterno) || ' ' || TRIM(cApMaterno));
									ELSE
										LET cCodRet ='000002';
									END IF;
								ELSE
									LET cCodRet = '000002';
								END IF;

							ELSE
								LET cCodRet = '000002';
							END IF;
							
							IF cCodRet <> '000000' THEN
								LET iIdpieza       = 0;
								LET cDenominacion  = '';
								LET cSerie         = '';
								LET cFolio         = '';
								LET cDictamen      = '';
								LET cEstatus       = '';
								LET cNota          = '';
								LET cNomTenedor    = '';
								LET dFechaEmision  = DATE(1);
								LET cNumRecibo     = '';
								LET dFechaPago     = DATE(1);
								LET cCuentaCliente = '';
								LET iSecuencia     = 0;
							ELSE
								LET iSecuencia =  iSecuencia +1;
								LET iContRep = iContRep +1;
							END IF;
							
							IF iFaltan = 0 OR iContadorSec = iSiguienteResivo THEN
								IF iLimit2 >= iQuedan  THEN
									LET iFin = iFin + 1;
								END IF;
				
								IF iFin = iQuedan AND iFin <> 0 THEN
									LET iTermino = 1;
								END IF;
							END IF;
							
							IF  dFechaEmision  = DATE(1) THEN
								LET dFechaEmision = '';
							END IF;
							
							RETURN cCodRet, iIdpieza, cDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, cEstatus, cDictamen, dFechaPago, cCuentaCliente, cNota, cNomTenedor, iSecuencia, iTermino  WITH RESUME;
							LET iBandCons3 = 1;
						END FOREACH						
					END IF;
			END FOREACH;
				
				IF iContadorSec = iSiguienteResivo OR iContadorSec = 0 THEN
					IF  iBandCons1  = 0 OR iBandCons2  = 0  THEN
						LET cCodRet = '000002';
					END IF;
				END IF;
				
				IF cCodRet = '000000' THEN
					IF iContRep < iLimit THEN
						LET iResivos = iSiguienteResivo;
					END IF;	
				END IF;
			END WHILE;		
			IF iContadorSec = 0 THEN
				LET cCodRet = '000002';
			END IF;			
		END IF;	
				
		IF TRIM(NVL(pOpcion,'')) = '1' or TRIM(NVL(pOpcion,'')) = '4' THEN  --------------------------------  Sucursal     -----------------------------------------------------------------------
	
	        SELECT {+INDEX (bdisuc:"informix".ss_recibo_bym_falsos 7153_569)} COUNT(a.num_recibo)
			INTO iContadorSec  --3
			FROM bdisuc:"informix".ss_recibo_bym_falsos a
            INNER JOIN bdisuc:"informix".ss_piezas_bym_falsos b ON a.num_Recibo=b.num_recibo AND b.num_guia IS NULL
			WHERE num_sucursal_retencion = pDato
            AND a.fecha_insert>=today-5; 
			
			LET iSecuencia2 = pRegistros;
			
			WHILE (cCodRet = '000000' AND iContRep < iLimit AND iResivos < iContadorSec  AND iTermino = 0)
			
            FOREACH 		
                SELECT {+AVOID_FULL(bdisuc:"informix".ss_recibo_bym_falsos)} SKIP iResivos LIMIT 1  num_recibo, id_tenedor
                INTO cNumRecibo, iIdTenedor
                FROM bdisuc:"informix".ss_recibo_bym_falsos
                WHERE num_sucursal_retencion = pDato 
                ORDER BY num_recibo
                 
                LET iBandCons1  = 1;
                LET iSiguienteResivo = iResivos + 1; 
                
                SELECT COUNT(id_denominacion)
                INTO iContador
                FROM bdisuc:"informix".ss_piezas_bym_falsos
                WHERE  num_recibo =  cNumRecibo;

                IF iSecuencia2 > iContador THEN
                    LET iSecuencia2 = iSecuencia2 - iContador;
                ELSE
                    LET iQuedan =  iContador - iSecuencia2;
                    LET iInicio = iContador - iQuedan;
                    LET iSecuencia2 = 0;
                END IF;

                IF iSecuencia2 = 0 AND iQuedan > 0 THEN
					
						IF iContRep <> 0 THEN
							LET iLimit2 = iLimit - iContRep;
						ELSE
							LET iLimit2 = iLimit;	
						END IF;
					
						LET iFaltan = 0;
						
						IF iSiguienteResivo < iContadorSec THEN
							FOREACH 		
								SELECT SKIP iSiguienteResivo LIMIT iContadorSec  num_recibo
								INTO cNumReciboContando
								FROM bdisuc:"informix".ss_recibo_bym_falsos
								WHERE num_sucursal_retencion = pDato 
								ORDER BY num_recibo
		
								SELECT COUNT(id_denominacion)
								INTO iContadorParaFin
								FROM bdisuc:"informix".ss_piezas_bym_falsos
								WHERE num_recibo = cNumReciboContando;
			
								LET iFaltan = iFaltan + NVL(iContadorParaFin,0);
		
							END FOREACH ;
						END  IF;				
						
						FOREACH																
							SELECT  SKIP iInicio LIMIT iLimit2 id_denominacion, serie, folio, fecha_emision,  estatus, dictamen_banxico, fecha_pago, nota, id_pieza, num_cta_cliente
							INTO iDenominacion, cSerie, cFolio, dFechaEmision, iEstatus, iDictamen, dFechaPago, cNota, iIdpieza, cCuentaCliente 
							FROM bdisuc:"informix".ss_piezas_bym_falsos
							WHERE num_recibo =  cNumRecibo							
							ORDER BY id_denominacion
							
							LET iBandCons2  = 1;
							
							SELECT  desc_dictamen
							INTO cDictamen
							FROM bdisuc:"informix".ss_cat_dictamen_bym_falsos
							WHERE empresa = '001' 
							AND id_dictamen = iDictamen;
							
							LET cDictamen = NVL(cDictamen,'');
							
							SELECT denominacion
							INTO cDenominacion
							FROM bdisuc:"informix".ss_denominacion_bym_falsos
							WHERE empresa = '001' 
							AND id_denominacion = iDenominacion;
							
							IF dbinfo("sqlca.sqlerrd2") = 1 THEN 

								SELECT desc_estatus
								INTO cEstatus
								FROM bdisuc:"informix".ss_cat_estatus_bym_falsos
								WHERE empresa = '001' 
								AND id_estatus = iEstatus;
									
								IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
								
									SELECT nombre_1, nombre_2, ap_paterno, ap_materno
									INTO cNombre1, cNombre2, cApPaterno, cApMaterno
									FROM bdisuc:"informix".ss_tenedor_pieza
									WHERE id_tenedor = iIdTenedor;
										
									IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
										LET cNomTenedor = TRIM(TRIM(cNombre1) || ' ' || TRIM(cNombre2)) || ' ' || TRIM(TRIM(cApPaterno) || ' ' || TRIM(cApMaterno));
									ELSE
										LET cCodRet ='0000-1'; --'000002';
									END IF;
								ELSE
									LET cCodRet = '000001'; --'000002';
								END IF;

							ELSE
								LET cCodRet = '000002';
							END IF;
							
							IF cCodRet <> '000000' THEN
								LET iIdpieza       = 0;
								LET cDenominacion  = '';
								LET cSerie         = '';
								LET cFolio         = '';
								LET cDictamen      = '';
								LET cEstatus       = '';
								LET cNota          = '';
								LET cNomTenedor    = '';
								LET dFechaEmision  = DATE(1);
								LET cNumRecibo     = '';
								LET dFechaPago     = DATE(1);
								LET cCuentaCliente = '';
								LET iSecuencia     = 0;
							ELSE
								LET iSecuencia =  iSecuencia +1;
								LET iContRep = iContRep +1;
							END IF;
							
							IF iFaltan = 0 OR iContadorSec = iSiguienteResivo THEN
								IF iLimit2 >= iQuedan  THEN
									LET iFin = iFin + 1;
								END IF;
				
								IF iFin = iQuedan AND iFin <> 0 THEN
									LET iTermino = 1;
								END IF;
							END IF;
							
							IF  dFechaEmision  = DATE(1) THEN
								LET dFechaEmision = '';
							END IF;
							
							RETURN cCodRet, iIdpieza, cDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, cEstatus, cDictamen, dFechaPago, cCuentaCliente, cNota, cNomTenedor, iSecuencia, iTermino  WITH RESUME;
							LET iBandCons3 = 1;
						END FOREACH						
					END IF;
			END FOREACH;
				
				IF iContadorSec = iSiguienteResivo OR iContadorSec = 0 THEN
					IF  iBandCons1  = 0 OR iBandCons2  = 0  THEN
						LET cCodRet = '000002';
					END IF;
				END IF;
				
				IF cCodRet = '000000' THEN
					IF iContRep < iLimit THEN
						LET iResivos = iSiguienteResivo;
					END IF;	
				END IF;
			END WHILE;		
			IF iContadorSec = 0 THEN
				LET cCodRet = '000002';
			END IF;			
		END IF;	
	
	
		IF TRIM(NVL(pOpcion,'')) = '3' THEN  --------------------------------  Rango de fechas     -----------------------------------------------------------------------
		
			SELECT COUNT(id_denominacion)
			INTO iContador 	
			FROM bdisuc:"informix".ss_piezas_bym_falsos
			WHERE fecha_insert >= pFechaIni AND fecha_insert <= pFechafin;
	
			FOREACH
				SELECT SKIP pRegistros LIMIT iLimit  id_denominacion, serie, folio, fecha_emision, num_recibo, estatus, dictamen_banxico, fecha_pago, nota, id_pieza, num_cta_cliente
				INTO iDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, iEstatus, iDictamen, dFechaPago, cNota, iIdpieza, cCuentaCliente 
				FROM bdisuc:"informix".ss_piezas_bym_falsos
				WHERE fecha_insert >= pFechaIni AND  fecha_insert <= pFechafin
				ORDER BY id_denominacion
				
				LET iBandCons2  = 1;	
				
				SELECT desc_dictamen
				INTO cDictamen
				FROM bdisuc:"informix".ss_cat_dictamen_bym_falsos
				WHERE empresa = '001' 
				AND id_dictamen = iDictamen;
				
				LET cDictamen = NVL(cDictamen,'');
				
				SELECT  num_recibo, id_tenedor
				INTO    cNumRecibo, iIdTenedor
				FROM bdisuc:"informix".ss_recibo_bym_falsos
				WHERE num_recibo= cNumRecibo;
				
				IF dbinfo("sqlca.sqlerrd2") = 1 THEN 	
				
					SELECT denominacion
					INTO cDenominacion
					FROM bdisuc:"informix".ss_denominacion_bym_falsos
					WHERE empresa = '001' 
					AND id_denominacion = iDenominacion;
					
					IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
						
						SELECT desc_estatus
						INTO cEstatus
						FROM bdisuc:"informix".ss_cat_estatus_bym_falsos
						WHERE empresa = '001' 
						AND id_estatus = iEstatus;
						
						IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
						
							SELECT nombre_1, nombre_2, ap_paterno, ap_materno
							INTO cNombre1, cNombre2, cApPaterno, cApMaterno
							FROM bdisuc:"informix".ss_tenedor_pieza
							WHERE id_tenedor = iIdTenedor;
								
							IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
								LET cNomTenedor = TRIM(TRIM(cNombre1) || ' ' || TRIM(cNombre2)) || ' ' || TRIM(TRIM(cApPaterno) || ' ' || TRIM(cApMaterno));
							ELSE
								LET cCodRet = '000002';
							END IF;
							
						ELSE
							LET cCodRet = '000002';
						END IF;
					ELSE
						LET cCodRet = '000002';
					END IF;
				ELSE
					LET cCodRet = '000002';
				END IF;	
					
				IF cCodRet <> '000000' THEN
					LET iIdpieza       = 0;
					LET cDenominacion  = '';
					LET cSerie         = '';
					LET cFolio         = '';
					LET cDictamen      = '';
					LET cEstatus       = '';
					LET cNota          = '';
					LET cNomTenedor    = '';
					LET dFechaEmision  = DATE(1);
					LET cNumRecibo     = '';
					LET dFechaPago     = DATE(1);
					LET cCuentaCliente = '';
					LET iSecuencia     = 0;
				ELSE
					LET iSecuencia = iSecuencia +1;
				END IF;
				
				IF iSecuencia = iContador  THEN
					LET iTermino = 1;
				END IF;
					
				RETURN cCodRet, iIdpieza, cDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, cEstatus, cDictamen, dFechaPago, cCuentaCliente, cNota, cNomTenedor, iSecuencia, iTermino  WITH RESUME;
				LET iBandCons3 = 1;
	
			END FOREACH;
			
			IF  iBandCons2  = 0 OR iBandCons2  = 0 THEN
				LET cCodRet = '000002';
			END IF;		
		
		IF iContadorSec = 0 THEN
			LET cCodRet = '000002';
		END IF;
			
	   END IF;	
	 END IF;
	
	IF iBandCons3 = 0 THEN
		IF cCodRet <> '000000' THEN
			LET iIdpieza       = 0;
			LET cDenominacion  = '';
			LET cSerie         = '';
			LET cFolio         = '';
			LET cDictamen      = '';
			LET cEstatus       = '';
			LET cNota          = '';
			LET cNomTenedor    = '';
			LET dFechaEmision  = DATE(1);
			LET cNumRecibo     = '';
			LET dFechaPago     = DATE(1);
			LET cCuentaCliente = '';
			LET iSecuencia     = 0;
		END IF;
						
		RETURN cCodRet, iIdpieza, cDenominacion, cSerie, cFolio, dFechaEmision, cNumRecibo, cEstatus, cDictamen, dFechaPago, cCuentaCliente, cNota, cNomTenedor, iSecuencia, iTermino WITH RESUME;
	END IF;
	
END;    
END PROCEDURE;