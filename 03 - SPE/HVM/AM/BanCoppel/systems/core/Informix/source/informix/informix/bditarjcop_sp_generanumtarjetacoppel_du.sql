CREATE PROCEDURE "informix".sp_generanumtarjetacoppel_du(
	cUsuario CHAR(8),
	cPassword CHAR(8),
	cIdSession CHAR(30),
	cIpOrigen CHAR(15),
	cAgentTransTypeCode CHAR(10),
	cAgentCd CHAR(3),
	pEmpresa CHAR(3),
	pSucursal CHAR(4), 
	pNumCte VARCHAR(20), 
	pNumSolicitud CHAR(20))
RETURNING
	CHAR(5) AS  cCodRet,
	CHAR(20) AS cMensaje,
	CHAR(5) AS  cCodRes,
	CHAR(100)AS cMensajeProc,
	CHAR(20) AS cNumTarjetaCoppel,
	CHAR(1050) AS cTaramaParametricoCliente;  --- Trama conformada a enviar al servicio 


	-----------------------------------------------------------------------------------------------------
	--	00000 = Operacion Exitosa
	--	00001 = Parametro de entrada vacios o Nulos
	--	00002 = Sesion invalida
	--	00003 = El Cliente ya es cliente Coppel
	--	00004 = El numero de solicitud no es de tipo TDC Coppel
	--	00005 = El numero de solicitud no tiene estatus de autorizada
	--	00006 = El numero de solicitud no le corresponde al cliente
	--	00007 = El Cliente ya es cliente Coppel(sp_relacionbancoppelcoppel)
	-- 	00008 = Error al generar el numero de la tarjeta (sp_AsignarTarjetaNumeradaCop)
	-- 	00009 = error en la confirma la asignacion de la tarjeta 
	--	00010 = El cliente ya es cliente coppel(sp_AperCredCoppel2)
	--	00011 = Hubo un error al ejecutar el proc sp_relaciona_ctebancplcpl_club
	--	00012 = No existen datos del parametrico del cliente
	--	00013 = Error no controlado
	-----------------------------------------------------------------------------------------------------

--- DECLARACIONES
DEFINE cCodRet 							CHAR(5);
DEFINE iSqlErr                          INTEGER;
DEFINE iSamErr                          INTEGER;
DEFINE cDesErr                          CHAR(60);

DEFINE cCodRetornoProc					char(6);
define cTaramaParametricoCliente 				CHAR(1050);
define cNumeroTarjetaCoppel				CHAR(20);
define cMensaje							CHAR(100);
define cMensajeProc 					CHAR(100);
DEFINE cNumProducto						CHAR(6);
DEFINE s_numsol         CHAR(20);
DEFINE s_numcte         CHAR(20);
DEFINE s_nombre         CHAR(110);
DEFINE s_fechaaut       DATE;
DEFINE  s_fechasol      DATE;
DEFINE s_linea          MONEY(14,2);
DEFINE s_status         CHAR(2);
DEFINE s_stdesc         CHAR(130);
DEFINE s_comentario     CHAR(255);
DEFINE s_rfc            CHAR(15);
DEFINE s_diacorte       CHAR(2);
DEFINE s_divisa         CHAR(2);
DEFINE s_ingreso        MONEY(14,2);
DEFINE v_CausaSitEsp    SMALLINT;
DEFINE vfecha_hoy       DATE;
DEFINE vdias_rt         SMALLINT;
DEFINE vdias_at         SMALLINT;
DEFINE vdias_vigencia   INTEGER; 
DEFINE s_ProdDes		VARCHAR(50);

DEFINE iejecucion        INTEGER;
DEFINE s_Limit           SMALLINT;
DEFINE iEsCtaCap         INTEGER;
DEFINE iConsultaSP       INTEGER;
DEFINE vCantRegPres      INTEGER;
DEFINE cSitEsp          CHAR(1);
DEFINE cCausaSol         CHAR(3);
DEFINE vDescCausaSol    CHAR(100);

--VARIABLES PARA CREDINOMINA
DEFINE cCuenta_eje      CHAR(20);
DEFINE iFrecuencia      INTEGER;
DEFINE iDiaPago         INTEGER;
DEFINE s_Producto 		CHAR(4);

--VARIABLES DE TELEFONOS
DEFINE cTelCasa      CHAR(10);
DEFINE cTelOficina   CHAR(10);

DEFINE cNumCteBanco char(20);
DEFINE cNumCteCoppel char(20);

DEFINE cterelacionado CHAR(1);
DEFINE CteBancoppel CHAR(20);
DEFINE CteCoppel	CHAR(20);
DEFINE CteCpelProspecto CHAR(1) ;
DEFINE dFechaInsertSesion DATE ;
DEFINE dFechaInsertSesionPrueba DATE ;
--HU 24360 Se agregan variables 
DEFINE cNumCte CHAR(20);
DEFINE cNumProd CHAR(6);
DEFINE cNumSolicitud CHAR(16);
DEFINE cCanal CHAR(2);

--HU ?????
DEFINE vUsuarioInsert	VARCHAR(20);

--Inicializacion de variables 
LET cCodRet 			="00000";
LET cCodRetornoProc		="00001";
let cTaramaParametricoCliente	='';
let cNumeroTarjetaCoppel ='';
let cNumProducto ='';
let cMensajeProc ='';
LET cMensaje = 'Consulta exitosa';
LET s_nombre         = "";
LET s_numcte         = "";
LET s_fechaaut       = "";
LET s_fechasol       = "";
LET s_status         = "";
LET s_numsol         = "";
LET s_comentario     = "";
LET s_stdesc         = "";
LET s_rfc            = "";
LET s_linea          = 0;
LET s_diacorte       = "";
LET s_divisa         = "";
LET vfecha_hoy       = "";
LET vdias_rt         = 0;
LET vdias_at         = 0;
LET vdias_vigencia   = 0;
LET	v_CausaSitEsp	 = 0;
LET	iejecucion		 = 0;
LET	s_Limit			 = 0;
LET	iEsCtaCap 		 = 0;
LET	iConsultaSP		 = 0;
LET	vCantRegPres	= 0;
LET	cSitEsp			= '';
LET	cCuenta_eje		= '';
LET	iFrecuencia		= 1;
LET	iDiaPago		= 0;
LET	cTelCasa		='';
LET	cTelOficina		='';
LET vDescCausaSol	='';
LET cCausaSol  ='';
LET s_ProdDes = '';
let cterelacionado ='';
let CteBancoppel  ='';
let CteCoppel	  ='';
let CteCpelProspecto   ='';
--HU 24360
let cNumCte = '';
let cNumProd = '';
let cNumSolicitud = '';
let cCanal = '';

--HU ?????
LET vUsuarioInsert = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr, cDesErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = '00013';
				LET cCodRetornoProc = iSqlErr;
			END IF;
			--ROLLBACK WORK;			
			RETURN cCodRet,'Ocurrio un error no controlado',cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
		END EXCEPTION;
		
		--BEGIN WORK;
		
			--SET DEBUG FILE TO '/home/sysifx/jbueno/SPNUEVO/sp_generanumtarjetacoppel_du.out';
			--TRACE ON;
			
			--Realizar validaciones de los parametros de entrada
			if(nvl(cAgentTransTypeCode,'') = '' OR NVL(cAgentCd,'') = '' OR NVL(cUsuario,'') = '' OR NVL(cPassword,'') = '' OR	NVL(cIpOrigen,'') = '' OR NVL(cIdSession ,'') = '' OR NVL(pEmpresa,'') ='' OR NVL(pSucursal ,'') = ''
				OR	NVL(pNumCte,'') = '' OR NVL(pNumSolicitud,'') = '') THEN 
				let cMensajeProc ='Todos los parametros son obligatorios.';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
			
			--Hacemos la cosulta para obtener la fecha de la sesion  y la comparamos con la fecha hoy 
			IF EXISTS(SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes WHERE agent_cd = cAgentCd AND transaccion = cAgentTransTypeCode AND usuario = trim(cUsuario) AND activa = 'S') THEN
				let dFechaInsertSesionPrueba = today;
				SELECT fecha_insert
				INTO dFechaInsertSesion
				FROM bdisac:"informix".sac_ws_clientes 
				WHERE agent_cd = cAgentCd AND usuario = trim(cUsuario);
				
				IF(dFechaInsertSesion <> today)THEN
					LET cCodRetornoProc = '09978';
					LET cMensajeProc ='Fecha de peticion incorrecta.'; 
					RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
				END IF;
			END IF;
			
			--Implementar la seguridad AQUI
			EXECUTE PROCEDURE  bdisac:"informix".sp_valida_session(TRIM(cAgentTransTypeCode), TRIM(cAgentCd), TRIM(cUsuario), TRIM(cPassword), TRIM(cIpOrigen), TRIM(cIdSession) ) 
			INTO cCodRetornoProc, cMensajeProc;
			IF(LPAD(TRIM(NVL(cCodRetornoProc,'00000')),5,'0') <> '00000')THEN
				let cCodRetornoProc = LPAD(TRIM(NVL(cCodRetornoProc,'00000')),5,'0');
				--let cMensajeProc ='Error en la validacion de la sesion';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
			
			--valida si el cliente ya es cliente coppel
			EXECUTE PROCEDURE bdisolic:'informix'.sp_ValidaExisteCoppel (pEmpresa,pNumCte)
			INTO cCodRetornoProc;
			
			IF(cCodRetornoProc <> '00000')THEN
				let cMensajeProc ='El Cliente ya es cliente Coppel';
				LET cCodRetornoProc = '00003';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
			
			
			--Consultar el numero de producto
			--EXECUTE PROCEDURE bdinteg: sp_obtenerNumProducto(pEmpresa,pNumSolicitud,'') 
			--HU ?????
			SELECT num_producto, user_insert 
				INTO cNumProducto, vUsuarioInsert 
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE empresa = pEmpresa 
				AND num_solicitud = pNumSolicitud; 
			
			IF cNumProducto <> '6500' THEN 
				let cMensajeProc ='El numero de solicitud no es de tipo TDC Coppel';
				let cCodRetornoProc = '00004';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc, cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
			
			--Si existe el registro de la solicitud en estatus 'PA' cambiarlo a AT para que pueda continuar el proceso
			IF EXISTS(SELECT * FROM bdisolic:"informix".ss_solicitudes WHERE   num_producto = cNumProducto AND  numcte =pNumCte AND status_solicitud='PA')THEN
			--	UPDATE  bdisolic: ss_solicitudes set status_solicitud ='AT' WHERE  num_producto = cNumProducto AND  numcte =pNumCte;
			--	UPDATE bdisolic: ss_autorizacion  set status_solicitud ='AT' WHERE  num_solicitud =pNumSolicitud AND status_solicitud='PA';
			
			EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, '70000001',pNumSolicitud, 'AT', '', 'Solicitud Autorizada' )
				INTO cCodRetornoProc;
				if (cCodRetornoProc <> '000000') THEN
					RETURN cCodRet,cMensaje,cCodRetornoProc, cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
				end if;
			END IF;
			
			--Validar que el cliente tenga una solicitud autorizada de credito
			FOREACH
				EXECUTE PROCEDURE bdisolic:"informix".sp_conssolicitudescredito2_mov_2(1,pEmpresa,pSucursal,0,pNumCte,'',cNumProducto,0,0,0, 1, 0, '', '')
				INTO  cCodRetornoProc ,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
							s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
							iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,cTelCasa,cTelOficina
				if(cNumProducto =s_Producto )THEN
					exit FOREACH;
				end if
			END FOREACH;
			
			IF(LPAD(TRIM(NVL(cCodRetornoProc,'00000')),5,'0') <> '00000' OR s_status <> 'AT' OR NVL(s_Producto,'') = '' )THEN
				let cMensajeProc ='El numero de solicitud no tiene estatus de autorizada';
				let cCodRetornoProc = '00005';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
			
			
			IF(pNumCte <> s_numcte OR pNumSolicitud <> s_numsol) THEN
				let cMensajeProc ='El numero de solicitud no le corresponde al cliente';
				let cCodRetornoProc = '00006';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
			
			EXECUTE PROCEDURE bdinteg:'informix'.sp_relacionbancoppelcoppel (pEmpresa,pNumCte,pNumSolicitud)
			INTO cCodRetornoProc, cNumCteBanco, cNumCteCoppel;
			
			IF (cNumCteCoppel <> '') THEN
				--Se cancela el proceso quiere decir que el cliente ya tiene un cliente coppel asignado
				if(cCodRetornoProc = '000001') THEN
					let cMensajeProc ='El numero de solicitud es incorrecto, favor de validar e intentar nuevamente';
				ELSE
					let cMensajeProc ='El Cliente ya es cliente Coppel';
				END IF;
				LET cCodRetornoProc = '00007';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			end if;
			
			--Se consulta el numero de tarjeta coppel que se va asignar
			
			EXECUTE PROCEDURE bditarjcop:'informix'.sp_AsignarTarjetaNumeradaCop (pEmpresa,pSucursal)
			INTO cCodRetornoProc, cNumeroTarjetaCoppel;
			
			--Validar los mensajes del procedimiento enviarlo en la variable cMensajeProc
			IF(cCodRetornoProc <> '00000')THEN
				IF (CAST(cCodRetornoProc AS INTEGER) = 200)THEN
					let cMensajeProc ='La empresa proporcionada no existe';
				ELIF(CAST(cCodRetornoProc AS INTEGER) = 201) THEN
					let cMensajeProc ='La sucursal no cuenta con inventario de tarjetas';
				ELIF(CAST(cCodRetornoProc AS INTEGER) = 202) THEN
					let cMensajeProc ='Datos en blanco';
				ELIF(CAST(cCodRetornoProc AS INTEGER) = 203) THEN
					let cMensajeProc ='No existen tarjetas para asignar';
				ELIF(CAST(cCodRetornoProc AS INTEGER) = 204) THEN
					let cMensajeProc ='No se obtiene el numero de la ultima tarjeta asignada del primer envio asignado a la sucursal';
				end if;
				LET cCodRetornoProc = '00008';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
			
			--Se confirma la asignacion de la tarjeta 
			EXECUTE PROCEDURE bditarjcop:'informix'.sp_ConfirmarTarjetaAsigCop (pEmpresa,pSucursal, 'N', cNumeroTarjetaCoppel, pNumCte)
			INTO cCodRetornoProc;
			
			IF(cCodRetornoProc <> '00000')THEN
				
				IF (CAST(cCodRetornoProc AS INTEGER) = 1700)THEN
					let cMensajeProc ='La empresa proporcionada no existe';
				ELIF(CAST(cCodRetornoProc AS INTEGER) = 1701) THEN
					let cMensajeProc ='La sucursal no cuenta con inventario de tarjetas';
				ELIF(CAST(cCodRetornoProc AS INTEGER) = 1702) THEN
					let cMensajeProc ='El tipo de tarjeta no es valido';
				ELIF(CAST(cCodRetornoProc AS INTEGER) = 1703) THEN
					let cMensajeProc ='No existe el numero de tarjeta proporcionado';
				ELIF(CAST(cCodRetornoProc AS INTEGER) = 1704) THEN
					let cMensajeProc ='El numero de tarjeta ya fue asignada';
				end if;
				LET cCodRetornoProc = '00009';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
			
			--Guarda la apertura del credito
			EXECUTE PROCEDURE bdisolic:'informix'.sp_AperCredCoppel2 (pEmpresa, pNumCte, cNumeroTarjetaCoppel, vUsuarioInsert, pNumSolicitud, '70000001', pSucursal)
			INTO cCodRetornoProc;
			
			IF(cCodRetornoProc <> '00000')THEN
				--Validar los mensajes del procedimiento enviarlo en la variable cMensaje
				LET cCodRetornoProc = '00010';
				let cMensajeProc ='El cliente ya es cliente coppel';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
			
			UPDATE bdisolic:"informix".ss_autorizacion
				SET user_insert = vUsuarioInsert
				WHERE empresa = pEmpresa 
				AND num_solicitud = pNumSolicitud
				AND status_solicitud = 'AP'; 
				
			--Se confirma la asignacion de la tarjeta 
			EXECUTE PROCEDURE  bdinteg:'informix'.sp_consulta_ctebancplcpl_club (pEmpresa,pNumCte,'1')
			INTO cCodRetornoProc,cterelacionado,CteBancoppel,CteCoppel,CteCpelProspecto;
			
			--Se confirma la asignacion de la tarjeta 
			EXECUTE PROCEDURE  bdinteg:'informix'.sp_guardacteprospecto_club (pEmpresa,pNumCte,cNumeroTarjetaCoppel,'')
			INTO cCodRetornoProc;
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_relaciona_ctebancplcpl_club(pEmpresa, pNumCte, cNumeroTarjetaCoppel,'','0','1')
			INTO cCodRetornoProc;
			
			IF(cCodRetornoProc <> '000000')THEN
				--Validar los mensajes del procedimiento enviarlo en la variable cMensaje
				LET cCodRetornoProc = '00011';
				let cMensajeProc ='Hubo un error al el proceso relaciona cliente coppel bcpl';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
			
			
			EXECUTE PROCEDURE bdinteg:'informix'.sp_altactecoppelnuevoparametrico_club (pEmpresa,pNumCte,pNumSolicitud)
			INTO cCodRetornoProc,cTaramaParametricoCliente;
			
			IF(cCodRetornoProc <> '00000')THEN
				--Validar los mensajes del procedimiento enviarlo en la variable cMensaje
				LET cCodRetornoProc = '00012';
				let cMensajeProc ='No existen datos del parametrico del cliente';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
--HU 24360 inicio
			EXECUTE PROCEDURE bdisolic:'informix'.sp_prospecteo_solicitudes('001', pNumCte, cNumProducto, pNumSolicitud, 'F' , '3', 0)
			INTO cCodRetornoProc, cNumCte, cNumProd , cNumSolicitud, cCanal;
			

			IF(cCodRetornoProc <> '00000')THEN
				--Validar los mensajes del procedimiento enviarlo en la variable cMensaje
				LET cCodRetornoProc = '00014';
				let cMensajeProc = 'Ocurrio un error al actualizar el estatus de la solicitud (prospecteo)';
				--ROLLBACK WORK;
				RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
			END IF;
--HU 24360 fin
		---COMMIT WORK;
		
		let cMensajeProc = 'La asignacion de la Tarjeta de Credito Coppel se realizo con exito';
		let cMensaje = 'Asignacion exitosa';
		---SE OBTIENEN LAS TRAMAS DE LAS HUELLAS PARA ENVIARLAS AL INTERFACESCOPPEL
		RETURN cCodRet,cMensaje,cCodRetornoProc,cMensajeProc,cNumeroTarjetaCoppel,cTaramaParametricoCliente;
		--RETURN '00000','500006555','650093426791','Consulta exitosa','500006555|JESUS| |LOPEZ|LOPEZ|M|19910101|C|19|9999|879514|654| |E| |0|0|0|0|0|0|0|0| |0|6679955813|P| |0|N|8|0|0|0|0|0|0|0|0|COMERCIO ELECTRONICO|4|108|162560|542| |0|0|0|0|0|MARIA| |LOPEZ|LOPEZ|0|20210929|0|0|0| |0|0|19000101|19000101|0|0|0|0|0|0|1|0|0|0|0|A|C|0002|100|95347143|4|C||0|0|0|';
	END;
END PROCEDURE
DOCUMENT
'Folio: NA',
'AUTOR :99804975 Jesus isaias bueno',
'FECHA : 01/07/2014',
'MODIFICACION: Se omite la ejecucion del procedimiento sp_obtenerNumProducto se obtiene el numero de producto de forma directa',
'SUSTENTO: INC- Friends and Family',
'BD: bditarjcop',
'Folio: HU 24360 Generacion de Tarjeta Coppel operando las 24 horas',
'AUTOR : ANTONIO DE JESUS ANDRADE',
'FECHA : 15/08/2023',
'MODIFICACION: Se agrega ejecucion del procedimiento sp_prospecteo_solicitudes para cambiar estatus de la solicitud a F, cuando se asigna el numero de tarjeta',
'BD: bditarjcop',
'Etiqueta: HU 24360',
'Folio: HU ????? Identificar numero de empleado que realiza la solicitud en el procedimiento de apertura',
'AUTOR : MIGUEL ANGEL MARTINEZ MARTINEZ',
'FECHA : 25/03/2025',
'MODIFICACION: Se agrega la variable vUsuarioInsert para identificacion de empleado, se envia a sp_AperCredCoppel2',
'BD: bditarjcop',
'Etiqueta: HU ?????';


grant  execute on function "informix".sp_asignartarjetarepadicop (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_asignartarjetarepadicop (char,char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_asignartarjetarepadicop (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_asignartarjetarepadicop (char,char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_calcularnumverificador (integer) to "sysaccapp" as "informix";
grant  execute on function "informix".sp_calcularnumverificador (integer) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_calcularnumverificador (integer) to "sissics" as "informix";
grant  execute on function "informix".sp_calcularnumverificador (integer) to "public" as "informix";
grant  execute on function "informix".sp_calcularnumverificador (integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_confirmartarjetaasigcop (char,char,char,char,char) to "sysaccapp" as "informix";
grant  execute on function "informix".sp_confirmartarjetaasigcop (char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_confirmartarjetaasigcop (char,char,char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_confirmartarjetaasigcop (char,char,char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_confirmartarjetaasigcop (char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_confirmartarjetaextcop (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_confirmartarjetaextcop (char,char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_confirmartarjetaextcop (char,char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_confirmartarjetaextcop (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_genreprecepciontarcop (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_genreprecepciontarcop (char,char) to "public" as "informix";
grant  execute on function "informix".sp_genreprecepciontarcop (char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_genreprecepciontarcop (char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_guardarhistestadisticatarcop () to "c90306542" as "informix";
grant  execute on function "informix".sp_guardarhistestadisticatarcop () to "public" as "informix";
grant  execute on function "informix".sp_guardarhistestadisticatarcop () to "sissics" as "informix";
grant  execute on function "informix".sp_guardarhistestadisticatarcop () to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_recibirlotetarcop (char,char,integer,char,integer,integer,integer,char) to "sissics" as "informix";
grant  execute on function "informix".sp_recibirlotetarcop (char,char,integer,char,integer,integer,integer,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_recibirlotetarcop (char,char,integer,char,integer,integer,integer,char) to "public" as "informix";
grant  execute on function "informix".sp_recibirlotetarcop (char,char,integer,char,integer,integer,integer,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_registrarnuevolotetarjcop (char,char,char,char,integer,datetime,integer,integer,integer,char,datetime) to "public" as "informix";
grant  execute on function "informix".sp_registrarnuevolotetarjcop (char,char,char,char,integer,datetime,integer,integer,integer,char,datetime) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_registrarnuevolotetarjcop (char,char,char,char,integer,datetime,integer,integer,integer,char,datetime) to "c90306542" as "informix";
grant  execute on function "informix".sp_registrarnuevolotetarjcop (char,char,char,char,integer,datetime,integer,integer,integer,char,datetime) to "sissics" as "informix";
grant  execute on function "informix".sp_au_guardarbitacora (varchar,varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_au_guardarbitacora (varchar,varchar,varchar,varchar) to "sissics" as "informix";
grant  execute on function "informix".sp_au_guardarbitacora (varchar,varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_au_guardarbitacora (varchar,varchar,varchar,varchar) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_au_obtenerrepositorios (varchar) to "sissics" as "informix";
grant  execute on function "informix".sp_au_obtenerrepositorios (varchar) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_au_obtenerrepositorios (varchar) to "public" as "informix";
grant  execute on function "informix".sp_au_obtenerrepositorios (varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_au_validanomarchivo (varchar,varchar) to "sissics" as "informix";
grant  execute on function "informix".sp_au_validanomarchivo (varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_au_validanomarchivo (varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_au_validanomarchivo (varchar,varchar) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_ostelefonica (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_ostelefonica (char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_ostelefonica (char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_ostelefonica (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_registrarsucursaltarcop (char,char,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_registrarsucursaltarcop (char,char,date) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_registrarsucursaltarcop (char,char,date) to "sissics" as "informix";
grant  execute on function "informix".sp_registrarsucursaltarcop (char,char,date) to "public" as "informix";
grant  execute on function "informix".sp_activadesactivaproductos (char,integer,char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_activadesactivaproductos (char,integer,char,char,char,char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_activadesactivaproductos (char,integer,char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_activadesactivaproductos (char,integer,char,char,char,char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_guardareporte (char,char,char,char,char,date,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_guardareporte (char,char,char,char,char,date,char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_guardareporte (char,char,char,char,char,date,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_guardareporte (char,char,char,char,char,date,char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_madpstelitdc_cat (char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_madpstelitdc_cat (char) to "sissics" as "informix";
grant  execute on function "informix".sp_madpstelitdc_cat (char) to "public" as "informix";
grant  execute on function "informix".sp_madpstelitdc_cat (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_madpstelitdc_prodos (char,char,char,char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_madpstelitdc_prodos (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_madpstelitdc_prodos (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_madpstelitdc_prodos (char,char,char,char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucau (char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucau (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucau (char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucau (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucos (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucos (char,char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucos (char,char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucos (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucursales (char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucursales (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucursales (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_madpstelitdc_sucursales (char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_regclaugruposuctarcop (char,char,char,char,char,date,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_regclaugruposuctarcop (char,char,char,char,char,date,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_regclaugruposuctarcop (char,char,char,char,char,date,char,char) to "public" as "informix";
grant  execute on function "informix".sp_regclaugruposuctarcop (char,char,char,char,char,date,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_regclaugruposuctarcopos (char,char,char,char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_regclaugruposuctarcopos (char,char,char,char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_regclaugruposuctarcopos (char,char,char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_regclaugruposuctarcopos (char,char,char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportemovtoshis (char,date,date) to "sissics" as "informix";
grant  execute on function "informix".sp_reportemovtoshis (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_reportemovtoshis (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_reportemovtoshis (char,date,date) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_validasucprodaltaunica (char,char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_validasucprodaltaunica (char,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_validasucprodaltaunica (char,char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_validasucprodaltaunica (char,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_clausurarsucursaltarcop (char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_clausurarsucursaltarcop (char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_clausurarsucursaltarcop (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_clausurarsucursaltarcop (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_conslotepend (char,char) to "public" as "informix";
grant  execute on function "informix".sp_conslotepend (char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_conslotepend (char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_conslotepend (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_generarreptarjetaext (char,date,date) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_generarreptarjetaext (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_generarreptarjetaext (char,date,date) to "sissics" as "informix";
grant  execute on function "informix".sp_generarreptarjetaext (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_generarreptarjetaext_pba (char,date,date) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_generarreptarjetaext_pba (char,date,date) to "public" as "informix";
grant  execute on function "informix".sp_generarreptarjetaext_pba (char,date,date) to "c90306542" as "informix";
grant  execute on function "informix".sp_generarreptarjetaext_pba (char,date,date) to "sissics" as "informix";
grant  execute on function "informix".sp_cancela_tarjetas (char) to "public" as "informix";
grant  execute on function "informix".sp_cancela_tarjetas (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cancela_tarjetas (char) to "sissics" as "informix";
grant  execute on function "informix".sp_cancela_tarjetas (char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_tarjeta_pendiente (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tarjeta_pendiente (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_tarjeta_pendiente (char,char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_tarjeta_pendiente (char,char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_asignartarjetanumeradacop (char,char) to "public" as "informix";
grant  execute on function "informix".sp_asignartarjetanumeradacop (char,char) to "sissics" as "informix";
grant  execute on function "informix".sp_asignartarjetanumeradacop (char,char) to "sysaccapp" as "informix";
grant  execute on function "informix".sp_asignartarjetanumeradacop (char,char) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_asignartarjetanumeradacop (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_au_guardarbitacora_pba (varchar,varchar,varchar,varchar) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_au_guardarbitacora_pba (varchar,varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_au_guardarbitacora_pba (varchar,varchar,varchar,varchar) to "sissics" as "informix";
grant  execute on function "informix".sp_au_guardarbitacora_pba (varchar,varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_au_validanomarchivo_pba (varchar,varchar) to "all_role_bditarjcop" as "informix";
grant  execute on function "informix".sp_au_validanomarchivo_pba (varchar,varchar) to "sissics" as "informix";
grant  execute on function "informix".sp_au_validanomarchivo_pba (varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_au_validanomarchivo_pba (varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_reversatarjetascoppel (char,char,integer,char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_reversatarjetascoppel (char,char,integer,char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_validastatustarjcoppel (char,char,char,integer) to "public" as "informix";
grant  execute on function "informix".sp_validastatustarjcoppel (char,char,char,integer) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultarangotarjetascoppel (char,char,integer,char,char,smallint) to "c90306542" as "informix";
grant  execute on function "informix".sp_consultarangotarjetascoppel (char,char,integer,char,char,smallint) to "public" as "informix";
grant  execute on function "informix".sp_esnumerico (char) to "public" as "informix";
grant  execute on function "informix".sp_esnumerico (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bajatarjetassucursales (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_bajatarjetassucursales (char) to "public" as "informix";
grant  execute on function "informix".sp_tarjeta_pendiente_web (char,char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_tarjeta_pendiente_web (char,char,char) to "public" as "informix";
grant  execute on function "informix".sp_enviar_tarjcop (char) to "c90306542" as "informix";
grant  execute on function "informix".sp_activacionlotesucursal (char,char) to "c90306542" as "informix";
grant  execute on function "informix".sp_cargarsurtidotarcop_pba (varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_cargarsurtidotarcop_pbalm (varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_cargarsurtidotarcop (varchar,varchar,varchar) to "c90306542" as "informix";
grant  execute on function "informix".sp_cargarsurtidotarcop (varchar,varchar,varchar) to "public" as "informix";
grant  execute on function "informix".sp_generanumtarjetacoppel_du (char,char,char,char,char,char,char,char,varchar,char) to "sysaccapp" as "informix";
grant  execute on function "informix".sp_generanumtarjetacoppel_du (char,char,char,char,char,char,char,char,varchar,char) to "c90306542" as "informix";
revoke  execute on function "informix".sp_enviar_tarjcop (char) from public as "informix";
revoke  execute on function "informix".sp_activacionlotesucursal (char,char) from public as "informix";
revoke  execute on function "informix".sp_cargarsurtidotarcop_pba (varchar,varchar,varchar) from public as "informix";
revoke  execute on function "informix".sp_cargarsurtidotarcop_pbalm (varchar,varchar,varchar) from public as "informix";
revoke  execute on function "informix".sp_generanumtarjetacoppel_du (char,char,char,char,char,char,char,char,varchar,char) from public as "informix";

revoke usage on language SPL from public ;

grant usage on language SPL to public ;

grant usage on language SPL to ifxcons ;

grant usage on language SPL to ifxdesaa ;

grant usage on language SPL to ifxprod ;

grant usage on language SPL to ifxconsacc ;

grant usage on language SPL to ifxsopsuc ;


create index "informix".idx_bitacoratarcop_old_02mar2023 on "informix"
    .bitacoratarcop_old_02mar2023 (nomarchivo,codretorno) using 
    btree  in dbs_idxinteg;
create index "informix".idx_envioshisttarcop1 on "informix".envioshisttarcop 
    (empresa,cvesucursal,tipotarjeta,enviodisponible) using btree 
     in datos01;
create index "informix".idx_enviostarcop1 on "informix".enviostarcop 
    (enviodisponible,empresa,cvesucursal,tipotarjeta) using btree 
     in datos01;
create index "informix".idx_mensajestarcop1 on "informix".mensajestarcop 
    (codmensaje) using btree  in datos01;
create index "informix".idx_paraminvtarcop1 on "informix".paraminvtarcop 
    (empresa,descripcion) using btree  in datos01;
create index "informix".idx_sucursalescajaunica on "informix".sucursalescajaunica 
    (cvesucursal) using btree  in datos01;
create index "informix".idx_tarjetasnumtarcop on "informix".tarjetasnumtarcop 
    (numtarjeta,cvesucursal) using btree  in dbs_idxinteg;
create index "informix".idx_tarjetasnumtarcop1 on "informix".tarjetasnumtarcop 
    (estatustarjeta,fechaasignacion) using btree  in datos01;
    
create index "informix".idx_tarjetasnumtarcop2 on "informix".tarjetasnumtarcop 
    (empresa,numtarjeta) using btree  in datos01;
create index "informix".idx_tarjetasrepotarcop1 on "informix".tarjetasrepotarcop 
    (estatustarjeta,fechaasignacion) using btree  in datos01;
    
create index "informix".detallerepadic_01 on "informix".detallerepadic 
    (secuencia,tipocliente,fecha) using btree  in datos01;
create index "informix".idx_bitacoratarcop_old032024 on "informix"
    .bitacoratarcop_old032024 (nomarchivo,codretorno) using btree 
     in dbs_idxinteg;
create index "informix".idx_bitacoratarcop on "informix".bitacoratarcop 
    (nomarchivo,codretorno) using btree  in idx_info05;