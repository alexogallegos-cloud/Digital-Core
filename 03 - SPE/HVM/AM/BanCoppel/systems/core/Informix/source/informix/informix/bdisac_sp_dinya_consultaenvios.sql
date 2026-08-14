CREATE PROCEDURE "informix".sp_dinya_consultaenvios
		(pNumControl CHAR(12),
		 pIdentificacion CHAR(2),
		 pNumeroId CHAR(25))
RETURNING  CHAR(5) ,DATE, MONEY(16,2), CHAR(26),CHAR(26),CHAR(26),CHAR(26),CHAR(26),CHAR(26),CHAR(26),CHAR(26), CHAR(20), CHAR(20),
CHAR(80), CHAR(80), CHAR(200),CHAR(100);

DEFINE cCodRet 			CHAR(5);
DEFINE dFechaEnvio 		DATE;
DEFINE cCiudadOrigen 	CHAR(3);
DEFINE cSucursalOrigen  CHAR(4);
DEFINE cNombre1Rem 		CHAR(26);
DEFINE cNombre2Rem 		CHAR(26);
DEFINE cApellido1Rem 	CHAR(26);
DEFINE cApellido2Rem 	CHAR(26);
DEFINE cNombre1Ben 		CHAR(26);
DEFINE cNombre2Ben 		CHAR(26);
DEFINE cApellido1Ben 	CHAR(26);
DEFINE cApellido2Ben 	CHAR(26);
DEFINE mImporteEnvio 	MONEY (16,2);
DEFINE cTelBen			CHAR(20);
DEFINE cTelRem			CHAR(20);
DEFINE cDirBen			CHAR(80);
DEFINE cDirRem			CHAR(80);
DEFINE cCiudad			CHAR(3);
DEFINE cEstado			CHAR(2);
DEFINE cNombreCd		CHAR(200);
DEFINE iSqlErr			INTEGER;
DEFINE cMensaje			CHAR(100);
DEFINE isam_error		INTEGER;
DEFINE cDescripcion		CHAR(200);
DEFINE dFecha_Hoy		DATE;

	DEFINE iMensaje CHAR(50);
	DEFINE cid_ptf CHAR(5); 
	DEFINE ccve_pais CHAR(3);
	DEFINE cnompais CHAR(20);
	DEFINE ccalle VARCHAR(100); 
	DEFINE cnum_ext VARCHAR(6); 
	DEFINE cnum_int VARCHAR(5); 
	DEFINE ccve_col CHAR(8);
	DEFINE cnomcol VARCHAR(100);
	DEFINE ccve_mun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE ccve_localidad CHAR(14);
	DEFINE cnomlocalidad VARCHAR(60);
	DEFINE ccp CHAR(5); 
	DEFINE ccve_ciudad CHAR(3);
	DEFINE cnomciudad VARCHAR(60);
	DEFINE ccve_estado CHAR(2); 
	DEFINE cnomestado VARCHAR(30);
	DEFINE ctel1 VARCHAR(14); 
	DEFINE ctel2 VARCHAR(14);
	DEFINE ctipo VARCHAR(5);

BEGIN
	ON EXCEPTION SET iSqlErr,isam_error,cDescripcion
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)										 
			VALUES (iSqlErr,isam_error,cDescripcion,'sp_DinYa_consultaenvios',dFecha_Hoy,CURRENT );
			RETURN cCodRet,dFechaEnvio, mImporteEnvio, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, cNombre1Ben, 
		cNombre2Ben, cApellido1Ben, cApellido2Ben, cTelRem, cTelBen, cDirRem, cDirBen, cNombreCd,cMensaje;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO "/informix/HMLG/sp_DinYa_consultaenvios.out";
	--TRACE ON;	
	
	LET cCodRet 		= '00000';
	LET dFechaEnvio 	= '';
	LET cCiudadOrigen	= '';
	LET cNombre1Rem 	= '';
	LET cNombre2Rem 	= '';
	LET cApellido1Rem 	= '';
	LET cApellido2Rem 	= '';
	LET cNombre1Ben 	= '';
	LET cNombre2Ben 	= '';
	LET cApellido1Ben 	= '';
	LET cApellido2Ben 	= '';
	LET mImporteEnvio  	= '0.00';
	LET cTelBen			= '';
	LET cTelRem			= '';
	LET cDirBen			= '';
	LET cDirRem			= '';
	LET iSqlErr			= 0;
	LET cCiudad			= '';
	LET cEstado			= '';
	LET cNombreCd		='';
	LET cSucursalOrigen	= '';
	LET cMensaje		= '';
	LET isam_error		= '';
	LET cDescripcion	= '';
	LET dFecha_Hoy		= '';
	
	LET iMensaje = '';
	LET cid_ptf = '';
	LET ccve_pais = '';
	LET cnompais = '';
	LET ccalle = '';
	LET cnum_ext = ''; 
	LET cnum_int = '';
	LET ccve_col = '';
	LET cnomcol = '';
	LET ccve_mun = '';
	LET cnommunicipio = '';
	LET ccve_localidad = '';
	LET cnomlocalidad = '';
	LET ccp = '';
	LET ccve_ciudad = '';
	LET cnomciudad = '';
	LET ccve_estado = ''; 
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';
	
	
	
	SELECT fecha_hoy 
	INTO dFecha_Hoy
	FROM sac_fechas where empresa='001';	

	IF pNumControl = '' OR pIdentificacion= '' OR pNumeroId = '' OR pNumControl IS NULL OR 
		pIdentificacion IS NULL OR pNumeroId IS NULL THEN
		LET cCodRet= '00001';
		RETURN cCodRet,dFechaEnvio, mImporteEnvio, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, cNombre1Ben, 
		cNombre2Ben, cApellido1Ben, cApellido2Ben, cTelRem, cTelBen, cDirRem, cDirBen, cNombreCd,cMensaje;
	END IF;	

	IF NOT EXISTS (SELECT {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} no_control FROM Bdisac:sac_enviosdineroya WHERE no_control = pNumControl and estatus is not null) THEN
		LET cCodRet= '00002';
		IF NOT EXISTS (SELECT {+INDEX (bdisac:sac_enviosdineroyahis idxsac_envdinyahis13_1)} no_control FROM Bdisac:sac_enviosdineroyahis WHERE no_control = pNumControl and estatus is not null) THEN
			LET cCodRet= '00002';
		ELIF EXISTS (SELECT  {+INDEX (bdisac:sac_enviosdineroyahis idxsac_envdinyahis13_1)} no_control FROM Bdisac:sac_enviosdineroyahis WHERE no_control = pNumControl AND estatus = '02') THEN
			LET cCodRet= '00003';
		ELIF EXISTS(SELECT {+INDEX (bdisac:sac_enviosdineroyahis idxsac_envdinyahis13_1)} no_control FROM Bdisac:sac_enviosdineroyahis WHERE no_control = pNumControl AND estatus = '03') THEN
			LET cCodRet= '00004';
		ELIF EXISTS(SELECT {+INDEX (bdisac:sac_enviosdineroyahis idxsac_envdinyahis13_1)} no_control FROM Bdisac:sac_enviosdineroyahis WHERE no_control = pNumControl AND estatus = '04') THEN
			LET cCodRet= '00005';
		ELIF EXISTS(SELECT {+INDEX (bdisac:sac_enviosdineroyahis idxsac_envdinyahis13_1)} no_control FROM Bdisac:sac_enviosdineroyahis WHERE no_control = pNumControl AND estatus = '05') THEN
			LET cCodRet= '00002';
		END IF;	
		RETURN cCodRet,dFechaEnvio, mImporteEnvio, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, cNombre1Ben, 
		cNombre2Ben, cApellido1Ben, cApellido2Ben, cTelRem, cTelBen, cDirRem, cDirBen, cNombreCd,cMensaje;
	ELIF EXISTS (SELECT  {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} no_control FROM Bdisac:sac_enviosdineroya WHERE no_control = pNumControl AND estatus = '02') THEN
		LET cCodRet= '00003';
		RETURN cCodRet,dFechaEnvio, mImporteEnvio, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, cNombre1Ben, 
		cNombre2Ben, cApellido1Ben, cApellido2Ben, cTelRem, cTelBen, cDirRem, cDirBen, cNombreCd,cMensaje;
	ELIF EXISTS(SELECT {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} no_control FROM Bdisac:sac_enviosdineroya WHERE no_control = pNumControl AND estatus = '03') THEN
		LET cCodRet= '00004';
		RETURN cCodRet,dFechaEnvio, mImporteEnvio, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, cNombre1Ben, 
		cNombre2Ben, cApellido1Ben, cApellido2Ben, cTelRem, cTelBen, cDirRem, cDirBen, cNombreCd,cMensaje;
	ELIF EXISTS(SELECT {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} no_control FROM Bdisac:sac_enviosdineroya WHERE no_control = pNumControl AND estatus = '04') THEN
		LET cCodRet= '00005';
		RETURN cCodRet,dFechaEnvio, mImporteEnvio, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, cNombre1Ben, 
		cNombre2Ben, cApellido1Ben, cApellido2Ben, cTelRem, cTelBen, cDirRem, cDirBen, cNombreCd,cMensaje;
	ELIF EXISTS(SELECT {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} no_control FROM Bdisac:sac_enviosdineroya WHERE no_control = pNumControl AND estatus = '05') THEN
		LET cCodRet= '00002';
		RETURN cCodRet,dFechaEnvio, mImporteEnvio, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, cNombre1Ben, 
		cNombre2Ben, cApellido1Ben, cApellido2Ben, cTelRem, cTelBen, cDirRem, cDirBen, cNombreCd,cMensaje;
	ELIF NOT EXISTS(SELECT {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} no_control FROM Bdisac:sac_enviosdineroya WHERE no_control = pNumControl AND estatus = '01') THEN
		LET cCodRet= '00002';
		RETURN cCodRet,dFechaEnvio, mImporteEnvio, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, cNombre1Ben, 
		cNombre2Ben, cApellido1Ben, cApellido2Ben, cTelRem, cTelBen, cDirRem, cDirBen, cNombreCd,cMensaje;
	END IF;	

	
	
	SELECT fecha_envio, importe_pago, pri_nom_rem, seg_nom_rem, apell_pat_rem, apell_mat_rem, pri_nom_ben, seg_nom_ben,
		apell_pat_ben, apell_mat_ben, telefono_rem, telefono_ben, direc_rem, direc_ben, 
		suc_origen,e.mensaje
	INTO dFechaEnvio, mImporteEnvio, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, cNombre1Ben, cNombre2Ben,
		cApellido1Ben, cApellido2Ben, cTelRem, cTelBen, cDirRem, cDirBen,
		cSucursalOrigen,cMensaje
	FROM sac_enviosdineroya e
	WHERE no_control = pNumControl;
	
	--cCiudad, cEstado, cNombreCd,
	execute procedure bdisac:"informix".sp_sac_consucursales(cSucursalOrigen) into cCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;
	
	IF cCodRet != '00000' THEN
		LET cCodRet = '00000';
		LET dFechaEnvio = NULL;
		LET mImporteEnvio = NULL;
		LET cNombre1Rem = NULL;
		LET cNombre2Rem = NULL;
		LET cApellido1Rem = NULL;
		LET cApellido2Rem = NULL;
		LET cNombre1Ben = NULL;
		LET cNombre2Ben = NULL;
		LET cApellido1Ben = NULL;
		LET cApellido2Ben = NULL;
		LET cTelRem = NULL;
		LET cTelBen = NULL;
		LET cDirRem = NULL;
		LET cDirBen = NULL;
		LET cSucursalOrigen = NULL;
		LET cNombreCd = NULL;
		LET cMensaje = NULL;
	ELSE
		LET cNombreCd = cnomciudad;
	END IF;
	

	UPDATE {+INDEX (bdisac:sac_enviosdineroya idxsac_envdinya13_1)} sac_enviosdineroya SET identificacion= pIdentificacion, num_ident=pNumeroId WHERE no_control=pNumControl and estatus is not null;
	
	RETURN cCodRet,dFechaEnvio, mImporteEnvio, cNombre1Rem, cNombre2Rem, cApellido1Rem, cApellido2Rem, cNombre1Ben, 
		cNombre2Ben, cApellido1Ben, cApellido2Ben, cTelRem, cTelBen, cDirRem, cDirBen, cNombreCd,cMensaje;
		
END;
END PROCEDURE;