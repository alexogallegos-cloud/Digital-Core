CREATE PROCEDURE "informix".genmov_calif_crd( p_empresa                CHAR(3),
											   p_num_credito            CHAR(20),
											   p_num_producto           CHAR(4),
											   p_codigo_ref             INTEGER,
											   p_codigo_fun             CHAR(3),
											   p_fecha_hoy              DATE,
											   p_monto                  MONEY(14,2),
											   p_foliosuc               CHAR(16),
											   p_sucursal               CHAR(4),
											   p_divisa                 CHAR(2),
											   p_transacc_suc           CHAR(4))
RETURNING CHAR(10), CHAR(80);

DEFINE cCodret        CHAR(06);
DEFINE cMensaje       CHAR(80);
DEFINE cPlaza         CHAR(3);
DEFINE dtHora          DATETIME HOUR TO FRACTION(3);
DEFINE cReversado     CHAR(1);
DEFINE cUsuario       CHAR(8);
DEFINE cNumProducto  CHAR(4);
DEFINE iCodigoRef    INTEGER;
DEFINE cCodigoFun    CHAR(3);
DEFINE dtFechaHoy     DATE;
DEFINE dMonto         DECIMAL(18,2);
DEFINE cFolioSuc      CHAR(16);
DEFINE cSucursal      CHAR(4);
DEFINE cDivisa        CHAR(2);
DEFINE cTransaccSuc  CHAR(4);
DEFINE iSqlErr     INTEGER;
DEFINE iIsamErr    INTEGER;
DEFINE cErrorInfo  CHAR(80);
DEFINE iCadena     INTEGER;
DEFINE cSucOri     CHAR(4);

LET cCodret      = '000000';
LET cMensaje      = 'PROCESO EXITOSO';
LET cNumProducto =  p_num_producto ;
LET iCodigoRef   =  p_codigo_ref   ;
LET cCodigoFun   =  p_codigo_fun   ;
LET dtFechaHoy    =  p_fecha_hoy    ;
LET dMonto        =  p_monto        ;
LET cFolioSuc     =  p_foliosuc     ;
LET cSucursal     =  p_sucursal     ;
LET cDivisa       =  p_divisa       ;
LET cTransaccSuc =  p_transacc_suc ;
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cSucOri            = "";

BEGIN
   ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodret  = iSqlErr;
      LET cMensaje  = cErrorInfo;
      RETURN cCodret, cMensaje;
   END EXCEPTION;


   IF (p_transacc_suc IS NULL) THEN
      LET cTransaccSuc = '0000';
   END IF;
   
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
   IF (dtFechaHoy IS NULL) THEN
      SELECT fecha_hoy
      INTO   dtFechaHoy
      FROM   "informix".sd_fechas;
   END IF;
   
   IF (dMonto IS NULL) THEN
      LET dMonto = 0;
   END IF;
   
   IF (cDivisa IS NULL) THEN
      LET cDivisa = '00';
   END IF;
   
   IF (cNumProducto IS NULL) THEN
      LET cNumProducto = '    ';
   END IF;

   IF (cFolioSuc IS NULL) THEN
      LET cCodret = '000110';
      LET cMensaje = 'ERROR';
      RETURN cCodret, cMensaje;
   END IF;

   LET cCodret    = '000000';
   LET cMensaje    = 'PROCESO EXITOSO';
   LET dtHora       = EXTEND(CURRENT,HOUR TO fraction(3));
   LET cReversado  = 'N';
   LET iCadena = 0;
   let iCadena = length(p_foliosuc) - 8;
   LET cUsuario    = substr(p_foliosuc,1,iCadena);


   --############################################################
   --####  GENERACION DE MOVIMIENTOS Y DETALLE CONTABLE     #####
   --############################################################
 

   SELECT plaza
   INTO   cPlaza
   FROM   bdinteg:"informix".si_sucursales
   WHERE  empresa  = p_empresa
   AND    sucursal = cSucursal;

   IF cPlaza IS NULL OR cPlaza = '' THEN
      LET cCodret = '000100';
      LET cMensaje = 'LA INFORMACION PLAZA/SUCURSAL DEL CREDITO ES INCORRECTA';
      RETURN cCodret, cMensaje;
   END IF;

   SELECT sucursal INTO cSucOri
     FROM "informix".sd_maecredcrd
    WHERE empresa = p_empresa
      AND num_credito = p_num_credito;

   INSERT INTO "informix".sd_movhis_calif_crd (
               EMPRESA        ,
               FECHA_MOV      ,
               HORA_MOV       ,
               SUCURSAL       ,
               NUM_CREDITO    ,
               PLAZA          ,
               TRANSACC_SUC   ,
               USUARIO        ,
               MONTO          ,
               CODIGO_FUN     ,
               CODIGO_REF     ,
               DIVISA         ,
               REVERSADO      ,
               FOLIO_SUC      ,
               NUM_PRODUCTO   ,
	       SUC_ORIGEN     )
      VALUES ( p_empresa,
               dtFechaHoy,
               current,
               cSucursal,
               p_num_credito,
               cPlaza,
               cTransaccSuc,
               cUsuario,
               dMonto,
               cCodigoFun,
               iCodigoRef,
               cDivisa,
               cReversado,
               cFolioSuc,
               cNumProducto,
	       cSucOri);

   RETURN cCodret, cMensaje;

END;
END PROCEDURE
DOCUMENT
"Descripción: Se realiza procedimiento espejo al",
"procedimiento genmov_calif con la finalidad de",
"almacenar los movimientos de calificación para",
"los créditos reestructurados",
"Base de Datos: bdicred",
"AUTOR : Jesus Manuel Aguilar Heredia",
"FECHA : 02/Agosto/2011";

CREATE PROCEDURE "informix".sp_consultarcompromisosacuerdos
(
pEmpresa      	CHAR(3), 
pNumDivision  	INTEGER, 
pNumRegion    	INTEGER, 
pNumSucursal  	CHAR(4), 
pFechaInicio  	CHAR(10), 
pFechaFin     	CHAR(10),
pUsuario      	CHAR(8),
pTipoEjecucion 	SMALLINT,
pOrigen			SMALLINT
)
	RETURNING CHAR(6)        AS COD_RET,
			  CHAR(80)       AS DESCRIPCION,
			  VARCHAR(100)   AS DIVISION,
			  CHAR(30)       AS REGION,
			  CHAR(4)        AS SUCURSAL,
			  INTEGER        AS NUM_RDOS_COMP,
			  DECIMAL(18,2)  AS NEG_EFEC_VOL_COMP,
			  DECIMAL(18,2)  AS IMP_NEG_COMP,
			  DECIMAL(18,2)  AS IMP_REC_COMP,
			  DECIMAL(18,2)  AS NEG_EFEC_MONT_COMP,
			  DECIMAL(8,2)   AS PORC_CUMP_COMP,
			  INTEGER        AS NUM_RDOS_ACUE,
			  DECIMAL(18,2)  AS NEG_EFEC_VOL_ACRD,
			  DECIMAL(18,2)  AS IMP_NEG_ACUE,
			  DECIMAL(18,2)  AS IMP_REC_ACUE,
			  DECIMAL(18,2)  AS NEG_EFEC_MONT_ACRD,
			  DECIMAL(8,2)   AS PORC_CUMP_ACUE,
			  INTEGER  		 AS NUM_CTES_CON_VDO,
			  INTEGER   	 AS NUM_CONVENIOS,
			  DECIMAL(8,2)   AS PORC_CTES_CONV,
			  DECIMAL(18,2)  AS PESOS_CONVENIOS,
			  DECIMAL(18,2)  AS PESOS_PAGO,
			  DECIMAL(8,2)   AS PORC_REC_CONV,
			  DATE           AS FECHA_ACUE_COMP;
			  			     
	---DECLARACIONES
	DEFINE iSqlErr              INTEGER;
	DEFINE iIsamErr             INTEGER;
	DEFINE cErrorInfo           CHAR(80);
	DEFINE cCodRet              CHAR(6);
	DEFINE cMensajeRet          CHAR(80);
	DEFINE iNRows               INTEGER;

	DEFINE iDivision            INTEGER;
	DEFINE vcNomDivision        VARCHAR(100);
	DEFINE iRegion              INTEGER;
	DEFINE cNomRegion           CHAR(30);
	DEFINE cSucursal            CHAR(4);
	DEFINE iNum_Rdos            INTEGER;
	DEFINE dImp_Neg             DECIMAL(18,2);
	DEFINE dImp_Rec             DECIMAL(18,2);
	DEFINE dPorc_Cump           DECIMAL(8,2);

	DEFINE iNum_Rdos_Comp       INTEGER;
	DEFINE dImp_Neg_Comp        DECIMAL(18,2);
	DEFINE dImp_Rec_Comp        DECIMAL(18,2);
	DEFINE dPorc_Cump_Comp      DECIMAL(8,2);
	DEFINE iNum_Rdos_Acue       INTEGER;
	DEFINE dImp_Neg_Acue        DECIMAL(18,2);
	DEFINE dImp_Rec_Acue        DECIMAL(18,2);
	DEFINE dPorc_Cump_Acue      DECIMAL(8,2);
	DEFINE dtFechaAcueComp       DATE;
	DEFINE cUsuario             CHAR(8);
	DEFINE iNumSesion           INTEGER;
	DEFINE iId_sesion           INTEGER;
	DEFINE iRegistros           INTEGER;
	DEFINE iContador            INTEGER;

	DEFINE cNombreArchivo	  	CHAR(80);
	DEFINE cSql          		CHAR(1024);
	DEFINE cRuta		      	CHAR(80);   
	DEFINE cConsulta		  	CHAR(2200);
	DEFINE cTabla		      	CHAR(1); 
	DEFINE cFechaAcueComp	  	CHAR(10); 	
	--Declaracion Variables Fechas.
	DEFINE dtFechaHoy 			DATE;	
	DEFINE dtFechCortInmAnt		DATE;
	DEFINE dtFechCortMesSig		DATE;
	----Declaracion Variables Archivo.
	DEFINE dNegEfectVolComp 	DECIMAL(18,2);
	DEFINE dNegEfectMontComp 	DECIMAL(18,2);
	DEFINE dNegEfectVolAcue 	DECIMAL(18,2);
	DEFINE dNegEfectMontAcue 	DECIMAL(18,2);
	DEFINE vDia, vMes         CHAR(2);
  DEFINE vAnio              CHAR(4);
  DEFINE cFechCortInmAnt_2, cFechCortMesSig_2 CHAR(10);		
  DEFINE vSucursal          CHAR(4);
  DEFINE vSuma              DECIMAL(18,2);			
  DEFINE vNegEfecMonCom     DECIMAL(18,2);
	DEFINE vMonAcue           DECIMAL(18,2);
  DEFINE vPartNum_min       INTEGER;
  DEFINE vPartNum_max       INTEGER;
  DEFINE dtFechaInicio       DATE;
  DEFINE dtFechaFin          DATE;
  
  ----Declaracion Variables del anexo de columnas a la tabla tme_encabezadosexcel.
	DEFINE	iNumCtesVdo		INTEGER;
	DEFINE	iNumConvenios	INTEGER;
	DEFINE	dPorcCtesConv	DECIMAL(8,2);
	DEFINE	dPesosConvenios	DECIMAL(18,2);
	DEFINE	dPesosPago		DECIMAL(18,2);
	DEFINE	dPorcRecConv	DECIMAL(8,2);
  --DEFINE  vSucursalCAT  CHAR(4);	
  DEFINE vRegs          INTEGER;		  			  
   		
	---INICIALIZACIONES
	LET iSqlErr                 = 0;
	LET iIsamErr                = 0;
	LET cErrorInfo              = "";
	LET cCodRet                 = "000000";
	LET cMensajeRet             = "PROCESO EXITOSO";
	LET iNRows                  = 0;

	LET iDivision               = 0;
	LET vcNomDivision           = "";
	LET iRegion                 = 0;
	LET cNomRegion              = "";
	LET cSucursal               = "";
	LET iNum_Rdos               = 0;
	LET dImp_Neg                = 0.0;
	LET dImp_Rec                = 0.0;
	LET dPorc_Cump              = 0.0;

	LET iNum_Rdos_Comp          = 0;
	LET dImp_Neg_Comp           = 0.0;
	LET dImp_Rec_Comp           = 0.0;
	LET dPorc_Cump_Comp         = 0.0;
	LET iNum_Rdos_Acue          = 0;
	LET dImp_Neg_Acue           = 0.0;
	LET dImp_Rec_Acue           = 0.0;
	LET dPorc_Cump_Acue         = 0.0;
	LET dtFechaAcueComp          = DATE(1);
	LET cUsuario                = "";  
	LET iNumSesion              = 0;
	LET iId_sesion              = 0;
	LET iRegistros              = 0;
	LET iContador               = 0;
	LET cNombreArchivo          = "";
	LET cSql             		= "";
	LET cRuta					= "";
	LET cConsulta               = "";
	LET cTabla					= "N";
	LET cFechaAcueComp          = "";	
	--Inicializacion Variables Fechas.
	LET dtFechaHoy 				= DATE(1);	 --01/01/1900
	LET dtFechCortInmAnt		= DATE(1);
	LET dtFechCortMesSig		= DATE(1);				
	--Inicializacion Variables Archivo.
	LET dNegEfectVolComp 		= 0.00;
	LET dNegEfectMontComp 		= 0.00;
	LET dNegEfectVolAcue 		= 0.00;
	LET dNegEfectMontAcue 		= 0.00;
	LET vDia = ''; LET vMes = ''; LET vAnio = '';
	LET cFechCortInmAnt_2 = ''; LET cFechCortMesSig_2 = '';
  LET vSucursal         = '';
  LET vSuma             = 0.00;
  LET vNegEfecMonCom    = 0.00;
  LET vMonAcue          = 0.00;
  LET vPartNum_min = 0; LET vPartNum_max = 0;
  LET dtFechaInicio = pFechaInicio; 
  LET dtFechaFin =	pFechaFin;	
  ---- Inicialización Variables del anexo de columnas a la tabla tme_encabezadosexcel.
	LET	iNumCtesVdo		= 0;
	LET	iNumConvenios	= 0;
	LET	dPorcCtesConv	= 0.0;
	LET	dPesosConvenios	= 0.0;
	LET	dPesosPago		= 0.0;
	LET	dPorcRecConv	= 0.0;
	--LET vSucursalCAT = '9999';
	LET vRegs = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet = cErrorInfo;

				DELETE FROM bdicred:"informix".sd_consulta_acue_comp WHERE usuario = pUsuario;
        DELETE FROM bdicred:"informix".sd_consulta_acue_comp_2 WHERE usuario = pUsuario;
        															
			    --SI EXISTEN SE ELIMINAN TABLAS TEMPORALES.				PROD= 3145810
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdos' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE bdicred:tmeacuerdos;
				END IF;				
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdosaompromisos2' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE bdicred:tmeacuerdosaompromisos2;
				END IF;				
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdosaompromisos3' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE bdicred:tmeacuerdosaompromisos3;
				END IF;															
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcomacue' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE bdicred:tempcomacue;
				END IF;
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcomacue2' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE bdicred:tempcomacue2;
				END IF;
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcom1' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE bdicred:tempcom1;
				END IF;
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcom4' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE bdicred:tempcom4;
				END IF;
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE bdicred:bit_realiza_filtrada;
				END IF;
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada2' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE bdicred:bit_realiza_filtrada2;
				END IF;
				IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada3' AND dbsname='bdicred' AND partnum > 2097154) THEN
					DROP  TABLE bdicred:bit_realiza_filtrada3;
				END IF;
																						
				IF cTabla="S" THEN   
					DROP TABLE bdicred:TME_ENCABEZADOSEXCEL;
				END IF;
				
				RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0, '';
				
		  END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
    DELETE FROM bdicred:"informix".sd_consulta_acue_comp WHERE usuario =  pUsuario;    ---MACF
    DELETE FROM bdicred:"informix".sd_consulta_acue_comp_2 WHERE usuario =  pUsuario;  

	--SET DEBUG FILE TO "/respaldosbd/has/sp_ConsultarCompromisosAcuerdos.out";
	--SET DEBUG FILE TO "/informix/macf/sp_ConsultarCompromisosAcuerdos.trc";
  --TRACE ON;

   --INSERT INTO bdicred:sd_consulta_acue_comp_2 (sucursal,num_rdos_comp,fecha_acuecomp, usuario, id_sesion) VALUES('9999',pOrigen, dtFechaInicio,'92920268',301);  --TEST
   --INSERT INTO bdicred:sd_consulta_acue_comp_2 (sucursal,fecha_acuecomp, usuario, id_sesion) VALUES('9999',dtFechaFin,'92920268',301);  --TEST

		SELECT MIN(partnum) INTO vPartNum_min
		  FROM sysmaster:SysTabNames;
		  
		SELECT MAX(partnum) INTO vPartNum_max
		  FROM sysmaster:SysTabNames;

		-- REALIZA VALIDACIONES GENERALES
		IF (NVL(pEmpresa,"") = "") OR (pNumDivision IS NULL) OR (pNumRegion IS NULL) OR (pNumSucursal IS NULL) OR (NVL(pFechaInicio,"") = "") 
			OR (NVL(pFechaFin,"") = "") OR (NVL(pUsuario,"") = "") 	OR (pTipoEjecucion NOT IN (1,2)) THEN
			LET cCodRet = "000001";
			LET cMensajeRet = "PARAMETRO INVALIDO";						
			RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0, '';
		END IF;
			
		--SI EXISTEN SE ELIMINAN TABLAS TEMPORALES.				   PROD= 3145810
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdos' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP  TABLE bdicred:tmeacuerdos;
		END IF;				
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdosaompromisos2' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP  TABLE bdicred:tmeacuerdosaompromisos2;
		END IF;				
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tmeacuerdosaompromisos3' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP  TABLE bdicred:tmeacuerdosaompromisos3;
		END IF;															
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcomacue' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP  TABLE bdicred:tempcomacue;
		END IF;
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcomacue2' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP  TABLE bdicred:tempcomacue2;
		END IF;
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcom1' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP  TABLE bdicred:tempcom1;
		END IF;
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tempcom4' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP  TABLE bdicred:tempcom4;
		END IF;
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP  TABLE bdicred:bit_realiza_filtrada;
		END IF;
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada2' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP  TABLE bdicred:bit_realiza_filtrada2;
		END IF;
		IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='bit_realiza_filtrada3' AND dbsname='bdicred' AND partnum > 2097154) THEN
			DROP  TABLE bdicred:bit_realiza_filtrada3;
		END IF;
		
		SELECT DBINFO('sessionid')
		INTO iNumSesion
		FROM "informix".systables
		WHERE tabname = 'systables';
	
    IF pTipoEjecucion =1 THEN
      IF EXISTS (select dbsname, tabname from sysmaster: SysTabNames WHERE tabname='tme_encabezadosexcel' AND dbsname='bdicred' AND partnum > 3145810) THEN
			   DROP  TABLE bdicred:tme_encabezadosexcel;
	    END IF;
    
			CREATE TABLE tme_encabezadosexcel(
						fecha_acuecomp     CHAR(10),
						sucursal   		   CHAR(10),
						num_rdos_comp	   CHAR(20),
						neg_efecvol_comp   CHAR(40),
						imp_neg_comp       CHAR(20),
						imp_rec_comp	   CHAR(20),
						neg_efecmonto_comp CHAR(40),
						porc_cump_comp     CHAR(20),
						num_rdos_acue      CHAR(20),
						neg_efecvol_acue   CHAR(40),
						imp_neg_acue       CHAR(20),
						imp_rec_acue       CHAR(20),
						neg_efecmonto_acue CHAR(40),
						porc_cump_acue     CHAR(20),
						num_ctes_con_vdo   CHAR(40),
						num_convenios      CHAR(20),
						porc_ctes_conv     CHAR(20),
						pesos_convenios    CHAR(20),
						pesos_pago         CHAR(20),
						porc_rec_conv      CHAR(20)
						);
			LET cTabla="S";
		
    	--se agrega encabezado para el archivo excel
			INSERT INTO bdicred:tme_encabezadosexcel (fecha_acuecomp, sucursal, num_rdos_comp, neg_efecvol_comp, imp_neg_comp, imp_rec_comp, neg_efecmonto_comp, porc_cump_comp,num_rdos_acue, neg_efecvol_acue, imp_neg_acue, imp_rec_acue, neg_efecmonto_acue, porc_cump_acue, num_ctes_con_vdo, num_convenios, porc_ctes_conv, pesos_convenios, pesos_pago, porc_rec_conv)
			VALUES("","COMPROMISOS","","","","","","","ACUERDOS","","","","","","RECUPERADO POR CONVENIO","","","","","");
			INSERT INTO bdicred:tme_encabezadosexcel (fecha_acuecomp, sucursal, num_rdos_comp, neg_efecvol_comp, imp_neg_comp, imp_rec_comp,neg_efecmonto_comp,porc_cump_comp,num_rdos_acue,neg_efecvol_acue,imp_neg_acue,imp_rec_acue, neg_efecmonto_acue, porc_cump_acue, num_ctes_con_vdo, num_convenios, porc_ctes_conv, pesos_convenios, pesos_pago, porc_rec_conv)
			VALUES("FECHA","SUCURSAL","No. REALIZADOS","NEGOCIACIÓN EFECTIVA (VOLUMEN) %","IMPTE. NEGOCIADO","IMPTE. RECUPERADO","NEGOCIACIÓN EFECTIVA (MONTO) %","% CUMPLIMIENTO","No. REALIZADOS","NEGOCIACIÓN EFECTIVA (VOLUMEN) %","IMPTE. NEGOCIADO","IMPTE. RECUPERADO","NEGOCIACIÓN EFECTIVA (MONTO) %","% CUMPLIMIENTO","# CTES. C/VDO.","# CONV.","% CTES. CONV.","$ CONV. (MILES)","$ PAGO (MILES)","% REC. CONVENIO");

	   END IF;
 
		--se obtiene el numero de registros a retornar en la consulta
		SELECT NVL(valor_numerico,0)::INTEGER
		INTO iRegistros
		FROM bdicobranza:"informix".cb_param_campania
		WHERE empresa = '001'
			AND tipo_campania = 21 
			AND grupo_parametro = 'ESTADCOYAC'
			AND num_parametro = 1;
	 
		IF NVL(iRegistros,0) = 0 THEN
			LET cCodRet= "000003";
			LET cMensajeRet = "No se pudo obtener el numero de registros a retornar";						
			RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0, '';
		END IF;	 
	 
		--Se obtiene la ruta donde se almacenara el archivo generado.
		SELECT  TRIM(valor_alfabetico) 
		INTO cRuta
		FROM bdicobranza:"informix".cb_param_campania
		WHERE tipo_campania = 11  
			AND  grupo_parametro = 'RUTAS'
			AND num_parametro =1;

		IF NVL(cRuta,"") = "" THEN
			LET cCodRet= "000004";
			LET cMensajeRet = "No se pudo obtener la ruta donde se almacenara el archivo";						
			RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0, '';		
		END IF;	
		
	IF pTipoEjecucion = 2 THEN 
    		LET cNombreArchivo= TRIM(pUsuario)||iNumSesion||DAY(CURRENT) || LPAD(TRIM(MONTH(CURRENT)::CHAR(2)),2,'0') || YEAR(CURRENT);
    		LET cConsulta = "SELECT fecha_acuecomp,sucursal, num_rdos_comp, neg_efecvol_comp, imp_neg_comp,imp_rec_comp, neg_efecmonto_comp, porc_cump_comp, num_rdos_acue, neg_efecvol_acue, imp_neg_acue, imp_rec_acue, neg_efecmonto_acue, porc_cump_acue, num_ctes_con_vdo, num_convenios, porc_ctes_conv, pesos_convenios, pesos_pago, porc_rec_conv FROM tme_encabezadosexcel";
    		
    		LET cSql = '';
    		LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
    		SYSTEM TRIM(cSql);
    		
    		LET cSql = '';
    		LET cSql = "dbaccess bdicred " ||TRIM(cRuta)||'query1.sql';
    		SYSTEM cSql;
    		LET cSql = '';
    		--LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';		
    		SYSTEM cSql; 
    		
 				-- DROP TABLE bdicred:tme_encabezadosexcel;   ---PARA PRUEBA MACF
 				
    		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';				
    		RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0,0,0,0,0,0, '';		
	END IF; 
		
		IF pOrigen = 3 THEN
        SELECT count(*) into iNRows
          FROM  bdicobranza:cb_compac_his
          WHERE ( fecha_insert >= dtFechaInicio AND fecha_insert <= dtFechaFin )
           AND empresa = '001'
           AND tipo_compac = "1"
           AND origen = 3;
           
           IF iNRows <= 0 THEN
           		LET cCodRet = "000002";
          		LET cMensajeRet = "NO EXISTEN DATOS PARA ESTA CONSULTA";
          		RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0,0,0,0,0,0,MDY(1,1,1900);
           END IF; 
           
    ---division, nom_division, region, nom_region  0,'CAT',0,'CAT'
    		INSERT INTO bdicred:"informix".sd_consulta_acue_comp_2 (sucursal, fecha_acuecomp, num_rdos_comp, imp_neg_comp,
														  imp_rec_comp, porc_cump_comp, usuario, id_sesion )
        SELECT ch.sucursal, ch.fecha_insert, COUNT(ch.empresa)::INTEGER, SUM(ch.importe)::DECIMAL(18,2),  
              SUM(ch.imp_pagado)::DECIMAL(18,2), ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(18,2), pUsuario, iNumSesion
          FROM bdicobranza:cb_compac_his ch 
         WHERE ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
           AND ch.empresa = '001'
           AND ch.tipo_compac = "1"
           AND ch.origen = 3
         GROUP BY ch.sucursal, ch.fecha_insert;
    
        SELECT ch.sucursal as sucursal, ch.fecha_insert as fecha, COUNT(ch.empresa)::INTEGER AS num_rdos_acue, SUM(ch.importe)::DECIMAL(18,2) AS imp_neg_acue,  
              SUM(ch.imp_pagado)::DECIMAL(18,2) AS imp_rec_acue, ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(18,2) AS porc_cump_acue, pUsuario AS usuario, iNumSesion AS id_sesion
          FROM bdicobranza:cb_compac_his ch 
         WHERE ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
           AND ch.empresa = '001'
           AND ch.tipo_compac = "2"
           AND ch.origen = 3
         GROUP BY ch.sucursal, ch.fecha_insert
        INTO TEMP tmeacuerdos WITH NO LOG;
      
    
      	--SELECT t1.division, t2.region, t2.sucursal, t2.fecha, t2.num_rdos_acue, t2.imp_neg_acue, t2.imp_rec_acue,
      	SELECT t2.sucursal, t2.fecha, t2.num_rdos_acue, t2.imp_neg_acue, t2.imp_rec_acue,
  		   t2.porc_cump_acue , t1.usuario , t1.id_sesion
      		FROM bdicred:sd_consulta_acue_comp_2 t1, bdicred:tmeacuerdos t2
      		WHERE t1.sucursal = t2.sucursal 
      			AND t1.fecha_acuecomp = t2.fecha
      			AND t1.usuario   =  pUsuario
      			AND t1.id_sesion = iNumSesion
      		INTO TEMP tmeacuerdosaompromisos2 WITH NO LOG;
    
  		  FOREACH 
      			--SELECT division, region, sucursal, fecha, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue  
      			--INTO iDivision, iRegion, cSucursal, dtFechaAcueComp, iNum_Rdos, dImp_Neg, dImp_Rec, dPorc_Cump
      			SELECT sucursal, fecha, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue  
      			  INTO cSucursal, dtFechaAcueComp, iNum_Rdos, dImp_Neg, dImp_Rec, dPorc_Cump
      			  FROM bdicred:tmeacuerdosaompromisos2
      			 WHERE usuario  = pUsuario
       				 AND id_sesion = iNumSesion
      
      			UPDATE {+INDEX(bdicred:sd_consulta_acue_comp_2 inx_pk_consulta_acue_comp2)} bdicred:sd_consulta_acue_comp_2
      			SET num_rdos_acue = iNum_Rdos, imp_neg_acue = dImp_Neg, imp_rec_acue = dImp_Rec, porc_cump_acue = dPorc_Cump
      			WHERE sucursal = cSucursal AND fecha_acuecomp = dtFechaAcueComp 
      				AND usuario  = pUsuario
      				AND id_sesion =  iNumSesion;
    		END FOREACH;
      	
        SELECT t2.sucursal, t2.fecha, t2.num_rdos_acue, t2.imp_neg_acue, 
    			   t2.imp_rec_acue, t2.porc_cump_acue, t2.usuario, t2.id_sesion
    		FROM bdicred:sd_consulta_acue_comp_2 t1 
    		      RIGHT OUTER JOIN bdicred:tmeacuerdos t2 ON ( t1.sucursal = t2.sucursal AND 
                                                           t1.fecha_acuecomp = t2.fecha AND 
                                                           t1.usuario = t2.usuario AND 
                                                           t1.id_sesion = t2.id_sesion )
    		--WHERE t2.usuario = pUsuario
    		--	AND t2.id_sesion = iNumSesion
    		INTO TEMP tmeacuerdosaompromisos3 WITH NO LOG;
    
        FOREACH
            SELECT sucursal, fecha, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue, usuario, id_sesion 
            INTO cSucursal, dtFechaAcueComp, iNum_Rdos, dImp_Neg, dImp_Rec, dPorc_Cump, cUsuario, iNumSesion
            FROM tmeacuerdosaompromisos3
                                    
            UPDATE {+INDEX(bdicred:sd_consulta_acue_comp_2 inx_pk_consulta_acue_comp2)} bdicred:sd_consulta_acue_comp_2
      			   SET num_rdos_acue = iNum_Rdos, imp_neg_acue = dImp_Neg, imp_rec_acue = dImp_Rec, porc_cump_acue = dPorc_Cump
      		 	 WHERE sucursal = cSucursal AND fecha_acuecomp = dtFechaAcueComp 
      			 	 AND usuario  = pUsuario
      			 	 AND id_sesion =  iNumSesion;
            
            LET vRegs=dbinfo("sqlca.sqlerrd2");
            IF vRegs <= 0 THEN
              INSERT INTO bdicred:sd_consulta_acue_comp_2 (sucursal, fecha_acuecomp, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue, usuario, id_sesion)
              VALUES(cSucursal, dtFechaAcueComp, iNum_Rdos, dImp_Neg, dImp_Rec, dPorc_Cump, cUsuario, iNumSesion);
            END IF;
            
            --INSERT INTO bdicred:sd_consulta_acue_comp_2 (sucursal,num_rdos_comp, fecha_acuecomp, usuario, id_sesion)  --TEST
            -- VALUES('1111',vRegs, dtFechaAcueComp,'92920268',259);   ---TEST
            
        END FOREACH;
  		      
        -- RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0,0,0,0,0,0,MDY(1,1,1900);  TEST
    ELSE
        		----------------------------------------------------    CONSULTA DE COMPROMISOS   ----------------------------------------------------
      		INSERT INTO bdicred:"informix".sd_consulta_acue_comp (division, nom_division, region, nom_region, sucursal, fecha_acuecomp, num_rdos_comp, imp_neg_comp,
      														  imp_rec_comp, porc_cump_comp, usuario, id_sesion )
      		SELECT reg.division, par.descripcion, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, COUNT(ch.empresa)::INTEGER, SUM(ch.importe)::DECIMAL(18,2), 
      			SUM(ch.imp_pagado)::DECIMAL(18,2), ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(18,2), pUsuario, iNumSesion
      		FROM bdicobranza:"informix".cb_compac_his ch, 
      			bdinteg:"informix".si_ciudades ciu, 
      			bdinteg:"informix".si_catciudades cat,
      			bdinteg:"informix".si_regiones reg,
      			bdinteg:"informix".si_sucursales suc,
      			bdicobranza:"informix".cb_param_campania par
      		WHERE suc.estado  = ciu.estado
      			AND suc.ciudad  = ciu.ciudad
      			AND ch.sucursal = suc.sucursal
      			AND cat.numerociudad  = ciu.ciudad_coppel
      			AND cat.numero_region = reg.numero_region
      			AND ch.tipo_compac = "1" 
      			AND ch.empresa = pEmpresa
      			AND ch.origen = DECODE(pOrigen, 0, ch.origen, pOrigen)
      			AND ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
      			AND reg.division = DECODE(pNumDivision, 0, reg.division, pNumDivision)
      			AND par.num_parametro = reg.division
      			AND par.grupo_parametro = "DIVISIONES"
      			AND cat.numero_region = DECODE(pNumRegion, 0, cat.numero_region, pNumRegion)
      			AND ch.sucursal = DECODE(pNumSucursal, "", ch.sucursal, pNumSucursal)
      		GROUP BY reg.division, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, par.descripcion;

      		----------------------------------------------------    CONSULTA DE ACUERDOS   ----------------------------------------------------
      		SELECT reg.division AS division, par.descripcion AS nom_division, cat.numero_region AS region, reg.nombre_region AS nom_region, ch.sucursal AS sucursal,
      		   ch.fecha_insert AS fecha, COUNT(ch.empresa)::INTEGER AS num_rdos_acue,SUM(ch.importe)::DECIMAL(18,2) AS imp_neg_acue,
      		   SUM(ch.imp_pagado)::DECIMAL(18,2) AS imp_rec_acue, ((SUM(ch.imp_pagado) / SUM(ch.importe)) * 100)::DECIMAL(18,2) AS porc_cump_acue,
      		   pUsuario AS usuario, iNumSesion AS id_sesion 
      		FROM bdicobranza:"informix".cb_compac_his ch, bdinteg:"informix".si_ciudades ciu, bdinteg:"informix".si_catciudades cat,
      		     bdinteg:"informix".si_regiones reg, bdinteg:"informix".si_sucursales suc,  bdicobranza:"informix".cb_param_campania par
      		WHERE suc.estado = ciu.estado
      			AND suc.ciudad = ciu.ciudad
      			AND ch.sucursal = suc.sucursal
      			AND cat.numerociudad = ciu.ciudad_coppel
      			AND cat.numero_region = reg.numero_region
      			AND ch.tipo_compac = "2" 
      			AND ch.empresa = pEmpresa
      			AND ch.origen = DECODE(pOrigen, 0, ch.origen, pOrigen)
      			AND ( ch.fecha_insert >= dtFechaInicio AND ch.fecha_insert <= dtFechaFin )
      			AND reg.division = DECODE(pNumDivision, 0, reg.division, pNumDivision)
      			AND par.num_parametro = reg.division
      			AND par.grupo_parametro = "DIVISIONES"
      			AND cat.numero_region = DECODE(pNumRegion, 0, cat.numero_region, pNumRegion)
      			AND ch.sucursal = DECODE(pNumSucursal, "", ch.sucursal, pNumSucursal)  
      		GROUP BY reg.division, cat.numero_region, reg.nombre_region, ch.sucursal, ch.fecha_insert, par.descripcion 
      		INTO TEMP tmeacuerdos WITH NO LOG;
    
          	SELECT t1.division, t2.region, t2.sucursal, t2.fecha, t2.num_rdos_acue, t2.imp_neg_acue, t2.imp_rec_acue,
      		   t2.porc_cump_acue , t1.usuario , t1.id_sesion
      		FROM bdicred:"informix".sd_consulta_acue_comp t1, bdicred:tmeacuerdos t2
      		WHERE t1.division = t2.division 
      			AND t1.region   = t2.region 
      			AND t1.sucursal = t2.sucursal 
      			AND t1.fecha_acuecomp = t2.fecha
      			AND t1.usuario   =  pUsuario
      			AND t1.id_sesion = iNumSesion
      		INTO TEMP tmeacuerdosaompromisos2 WITH NO LOG;
    
    		FOREACH 
      			SELECT division, region, sucursal, fecha, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue  
      			INTO iDivision, iRegion, cSucursal, dtFechaAcueComp, iNum_Rdos, dImp_Neg, dImp_Rec, dPorc_Cump
      			FROM bdicred:tmeacuerdosaompromisos2
      			WHERE usuario  = pUsuario
      				AND id_sesion = iNumSesion
      
      			UPDATE {+INDEX(bdicred:"informix".sd_consulta_acue_comp inx_pk_consulta_acue_comp)} bdicred:"informix".sd_consulta_acue_comp
      			SET num_rdos_acue = iNum_Rdos, imp_neg_acue = dImp_Neg, imp_rec_acue = dImp_Rec, porc_cump_acue = dPorc_Cump
      			WHERE division = iDivision 
      			AND region = iRegion 
      				AND sucursal = cSucursal 
      				AND fecha_acuecomp = dtFechaAcueComp
      				AND usuario  = pUsuario
      				AND id_sesion =  iNumSesion;
    		END FOREACH;
					
    		SELECT t2.division, t2.nom_division, t2.region, t2.nom_region, t2. sucursal, t2.fecha, t2.num_rdos_acue, t2.imp_neg_acue,  
    			   t2.imp_rec_acue, t2.porc_cump_acue, t1.division AS division2, t2.usuario, t2.id_sesion
    		FROM bdicred:"informix".sd_consulta_acue_comp t1
    		RIGHT OUTER JOIN bdicred:tmeacuerdos t2 ON (t1.division = t2.division AND t1.region = t2.region AND t1.sucursal = t2.sucursal 
    											                 AND t1.fecha_acuecomp = t2.fecha AND t1.usuario = t2.usuario AND t1.id_sesion = t2.id_sesion)
    		WHERE  t2.usuario = pUsuario
    			AND t2.id_sesion = iNumSesion
    		INTO TEMP tmeacuerdosaompromisos3 WITH NO LOG;
    
    		INSERT INTO bdicred:"informix".sd_consulta_acue_comp (division, nom_division, region, nom_region, sucursal, fecha_acuecomp, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue, usuario, id_sesion)
    		SELECT division, nom_division, region, nom_region, sucursal, fecha, num_rdos_acue, imp_neg_acue, imp_rec_acue, porc_cump_acue, usuario, id_sesion
    		FROM bdicred:tmeacuerdosaompromisos3 
    		WHERE division2 IS NULL
    			AND usuario   =  pUsuario
    			AND id_sesion = iNumSesion; 
    
    END IF;
		
 IF pOrigen <> 3 THEN																					
		--********************SE CALCULA LAS FECHAS PARA NEGOCIACIÓN EFECTIVA (Volumen-Monto)***********************
		--**********************************************************************************************************
		--SE OBTIENE LA FECHA DE HOY DEL SISTEMA.
	  SELECT fecha_hoy
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pEmpresa;  
    
    --LET dtFechaHoy = '04/19/2012'; ---TEST								
		--SE VALIDA EL DIA DE LA FECHA DE HOY PARA CALCULAR LA FECHA CORTE INMEDIATA ANTERIOR Y FECHA CORTE MES SIGUIENTE.
		IF DAY(dtFechaHoy) > 20 THEN
			------------------------------------FECHA CORTE INMEDIATA ANTERIOR------------------------------------
			LET dtFechCortInmAnt = (MONTH(dtFechaHoy) UNITS MONTH || 21 UNITS DAY || YEAR(dtFechaHoy) UNITS YEAR)::DATE ;
			------------------------------------FECHA CORTE MES SIGUIENTE------------------------------------
			LET dtFechCortMesSig = (MONTH(dtFechaHoy) UNITS MONTH || 20 UNITS DAY || YEAR(dtFechaHoy) UNITS YEAR )::DATE + 1 UNITS MONTH;
      
		  LET vDia = day(dtFechCortInmAnt);
		  IF month(dtFechCortInmAnt) < 10 then
			LET vMes = '0' || month(dtFechCortInmAnt);
		  ELSE
			LET vMes = month(dtFechCortInmAnt);
		  END IF;
		  LET vAnio = year(dtFechCortInmAnt);
		  LET cFechCortInmAnt_2 = vAnio || '/' || vMes || '/' || vDia;
		  
			LET vDia = day(dtFechCortMesSig);
		  IF month(dtFechCortMesSig) < 10 then
			LET vMes = '0' || month(dtFechCortMesSig);
		  ELSE
			LET vMes = month(dtFechCortMesSig);
		  END IF;
		  LET vAnio = year(dtFechCortMesSig);
		  LET cFechCortMesSig_2 = vAnio || '/' || vMes || '/' || vDia;
      			
		ELSE		
			------------------------------------FECHA CORTE INMEDIATA ANTERIOR------------------------------------
			LET dtFechCortInmAnt = (MONTH(dtFechaHoy) UNITS MONTH || 21 UNITS DAY || YEAR(dtFechaHoy) UNITS YEAR )::DATE - 1 UNITS MONTH;
			------------------------------------FECHA CORTE MES SIGUIENTE------------------------------------
			LET dtFechCortMesSig = (MONTH(dtFechaHoy) UNITS MONTH || 20 UNITS DAY || YEAR(dtFechaHoy) UNITS YEAR )::DATE ;
      
			LET vDia = day(dtFechCortInmAnt);
		  IF month(dtFechCortInmAnt) < 10 then
			LET vMes = '0' || month(dtFechCortInmAnt);
		  ELSE
			LET vMes = month(dtFechCortInmAnt);
		  END IF;
		  LET vAnio = year(dtFechCortInmAnt);
		  LET cFechCortInmAnt_2 = vAnio || '/' || vMes || '/' || vDia;
		  
			LET vDia = day(dtFechCortMesSig);
		  IF month(dtFechCortMesSig) < 10 then
			LET vMes = '0' || month(dtFechCortMesSig);
		  ELSE
			LET vMes = month(dtFechCortMesSig);
		  END IF;
		  LET vAnio = year(dtFechCortMesSig);
		  LET cFechCortMesSig_2 = vAnio || '/' || vMes || '/' || vDia;
		END IF; 
				
		--**************************NEGOCIACIÓN EFECTIVA (volumen) PARA COMPROMISOS Y ACUERDOS********************************			
		----------------------------SE OBTIENE No. COMPROMISOS Y ACUERDOS REALIZADOS -----------------------------------------		
		--SE OBTIENE EL NUMERO DE COMPROMISOS Y ACUERDOS ENTRE UN RANGO DE FECHAS.
		-- Agrego que no se tomen los Compromisos y Acuerdos mismo día
		SELECT Suc AS sucursal,COUNT(TotalComp) AS TotalCompromisos,COUNT(TotalAcue)  AS TotalAcuerdos		
			   FROM TABLE (MULTISET (SELECT CASE WHEN t1.tipo_compac = "1" THEN t1.empresa END AS TotalComp,
											CASE WHEN t1.tipo_compac = "2" THEN t1.empresa END AS TotalAcue,
																				t1.sucursal AS Suc																					
									 FROM bdicobranza:"informix".cb_compac_his t1		 								  
									 WHERE t1.tipo_compac in ("1","2")
									   AND t1.origen = DECODE(pOrigen, 0, t1.origen, pOrigen)                           
									   AND t1.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig  
									   AND t1.fecha_insert <> t1.fecha_compac
									   AND t1.plazo <> 1 

						   ))						
		GROUP BY Suc
		INTO TEMP tempcom1 WITH NO LOG;
		
		---------------------------SE OBTIENE EL TOTAL DE CTES QUE ACUDIERON A REALIZAR COMPROMISOS Y ACUERDOS-----------------
    --- MACF: Agrego que filtre por origen en compac_his, pq en compac_bit_realiza solo se cuentan a los q se les ofrece convenio en Sucursal
    --- Modifico radicalmente este query pq solo debe obtenerse el conteo de cb_compac_bit_realiza rea 		
    --- totnumcte =num de veces que al cliente se le ofreció realizar un convenio cuando acudió a ventanilla. 
		SELECT {+INDEX(bdicobranza:"informix".cb_compac_bit_realiza idx_compacbitrealiza_fh)} rea.sucursal AS sucursal, --forzar por indice
           rea.numcliente AS numcte, fh_movimiento AS fechmov, COUNT(rea.numcliente) AS totnumcte,1 AS num_compacs  
			   --com.tipo_compac AS tipcompac   
			FROM bdicobranza:"informix".cb_compac_bit_realiza rea
      WHERE fh_movimiento >= TO_DATE(cFechCortInmAnt_2, "%Y/%m/%d")
        AND fh_movimiento <= TO_DATE(cFechCortMesSig_2, "%Y/%m/%d")  
		GROUP BY rea.sucursal, fh_movimiento, rea.numcliente
		ORDER BY 1		
		INTO TEMP bit_realiza_filtrada WITH NO LOG;
				
		---------------------------SE AGRUPA POR SUCURSAL Y SE HACE EL CONTEO DE COMPROMISOS Y DE ACUERDOS-------------------
		SELECT sucursal, count(num_compacs) as TotNumCompacs  
		  FROM bit_realiza_filtrada
     GROUP by sucursal
      INTO TEMP bit_realiza_filtrada2 WITH NO LOG; 

		SELECT sucursal, count(totnumcte) as totnumcte  
		  FROM bit_realiza_filtrada
     GROUP by sucursal
      INTO TEMP bit_realiza_filtrada3 WITH NO LOG;

																	
		--SE REALIZA EL CALCULO PARA OBTENER LA NEGOCIACION EFECTIVA(VOLUMEN) Y SE OBTIENE 
		--LOS TOTALES DE NEGOCIACIÓN EFECTIVA(Volumen) TANTO PARA COMPROMISOS COMO PARA ACUERDOS.
		SELECT t3.sucursal as sucursal, 
           CASE WHEN t3.TotNumCompacs = 0 THEN 0 ELSE ROUND((t1.TotalCompromisos/t3.TotNumCompacs) * 100,2) END AS neg_com_por_suc,
		       CASE WHEN t3.TotNumCompacs = 0 THEN 0 ELSE ROUND((t1.TotalAcuerdos/t3.TotNumCompacs) * 100,2) END AS neg_acue_por_suc,
				    t4.totnumcte AS totnumcte
				    --- t1.TotalCompromisos+t1.TotalAcuerdos AS totnumcte ..esto no es lo que se necesita
				   --t4.num_compacs
      FROM tempcom1 t1, bit_realiza_filtrada2 t3, bit_realiza_filtrada3 t4
     WHERE t1.sucursal = t3.sucursal
	     AND t4.sucursal = t3.sucursal
     GROUP BY 1,2,3,4
     INTO TEMP tempcom4 WITH NO LOG; 


																											
		--************************NEGOCIACIÓN EFECTIVA (Monto)PARA COMPROMISOS Y ACUERDOS******************************* 																			
		--------------------------SE OBTIENE IIMPORTE RECUPERADO Y MONTO VENCIDO DE COMPROMISOS-------------------------
		--- MACF: Agrego que filtre por origen en compac_his, pq en compac_bit_realiza solo se cuentan a los q se les ofrece convenio en Sucursal
    --SELECT com.sucursal AS sucursal,CASE WHEN SUM(NVL(mae.monto_vencido + mae.mto_venc_trasp,0.00)) <> 0 THEN  ROUND(NVL(SUM(NVL(com.imp_pagado,0.00))/ SUM(NVL(mae.monto_vencido + mae.mto_venc_trasp,0.00)) * 100,0.00),2) ELSE 0 END AS NegEfecMonCom,0.00 AS NegEfecMonAcue
    SELECT com.sucursal AS sucursal, SUM(NVL(mae.monto_vencido + mae.mto_venc_trasp,0.00)) AS NegEfecMonCom, 0.00 AS NegEfecMonAcue 
		FROM bdicobranza:"informix".cb_compac_his com,    ---MACF ahora nada más se obtiene el vencido para compromisos
			   bdicred:"informix".sd_maesdoshist mae			 
		WHERE mae.empresa = '001'
			AND com.numcuenta = mae.num_credito
			AND com.tipo_compac = "1"
			AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
      AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)        ---MACF
      AND com.fecha_insert <> com.fecha_compac
			AND com.plazo <> 1							
		GROUP BY com.sucursal
		ORDER BY com.sucursal
		INTO TEMP tempcomacue WITH NO LOG;
    
    ----OBTENER PARA CADA GRUPO DE CREDITOS DE CADA SUCURSAL CONTENIDO EN LA TABLA DE cb_compac_his
    SET LOCK MODE TO WAIT 3;
    FOREACH
        SELECT sucursal, NegEfecMonCom INTO vSucursal, vNegEfecMonCom  
          FROM tempcomacue
        
            SELECT {+INDEX(bdicred:"informix".sd_movhis inx_movhis)} NVL(SUM(monto),0)  INTO vSuma 
              FROM bdicred:"informix".sd_movhis 
             WHERE empresa = '001' 
               and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
               and fecha_mov >= dtFechCortInmAnt and fecha_mov <= dtFechCortMesSig and reversado = 'N'
               --and fecha_mov >= '2012-03-21' and fecha_mov <= '2012-04-20' and reversado = 'N'
               and num_credito in (
                                    SELECT com.numcuenta
                                      FROM bdicobranza:"informix".cb_compac_his com
                                     WHERE com.tipo_compac = "1" 							
                                     --AND com.fecha_compac BETWEEN '2012-03-21' AND '2012-04-20'
                                     AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
                                     AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)
                                     AND com.sucursal = vSucursal
                                     AND com.fecha_insert <> com.fecha_compac
			                               AND com.plazo <> 1	
               );
    
    			  IF vSuma > 0.00 AND vNegEfecMonCom > 0.00 THEN
                UPDATE tempcomacue SET NegEfecMonCom = ROUND(vSuma/vNegEfecMonCom * 100,2)
                 WHERE sucursal = vSucursal;
            END IF; 
               
    END FOREACH;     			

    -----------------CAMBIO EN QUERY DE ARRIBA QUEDA ASI
    SELECT com.sucursal AS sucursal, SUM(NVL(mae.monto_vencido + mae.mto_venc_trasp,0.00)) AS MonAcue 
		FROM bdicobranza:"informix".cb_compac_his com,    ---MACF ahora nada más se obtiene el vencido para Acuerdos
    		 bdicred:"informix".sd_maesdoshist mae			 
		WHERE com.tipo_compac = "2" 					
			AND com.numcuenta = mae.num_credito
			AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
      AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)        ---MACF
      AND com.fecha_insert <> com.fecha_compac
			AND com.plazo <> 1							
		GROUP BY com.sucursal
		ORDER BY com.sucursal
    INTO TEMP tempcomacue2 WITH NO LOG;
    
    ---se barre tempcomacue2 por Sucursal para sacar los pagos
    SET LOCK MODE TO WAIT 3;
    FOREACH
        SELECT sucursal, MonAcue INTO vSucursal, vMonAcue 
          FROM tempcomacue2
        
            SELECT {+INDEX(bdicred:"informix".sd_movhis inx_movhis)} NVL(SUM(monto),0)  INTO vSuma 
            FROM bdicred:"informix".sd_movhis 
            WHERE empresa = '001' 
            and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
            and fecha_mov >= dtFechCortInmAnt and fecha_mov <= dtFechCortMesSig and reversado = 'N'
            --and fecha_mov >= '2012-03-21' and fecha_mov <= '2012-04-20' and reversado = 'N'
            and num_credito in (
                                SELECT com.numcuenta
                                  FROM bdicobranza:"informix".cb_compac_his com
                                 WHERE com.tipo_compac = "2" 							
                                 --AND com.fecha_compac BETWEEN '2012-03-21' AND '2012-04-20'
                                 AND com.fecha_compac BETWEEN dtFechCortInmAnt AND dtFechCortMesSig
                                 AND com.origen = DECODE(pOrigen, 0, com.origen, pOrigen)
                                 AND com.sucursal = vSucursal
                                 AND com.fecha_insert <> com.fecha_compac
			                           AND com.plazo <> 1	
								);
            IF vSuma > 0.00 AND vMonAcue > 0.00 THEN
        			  UPDATE tempcomacue2 SET MonAcue = ROUND(vSuma/vMonAcue * 100,2)
                 WHERE sucursal = vSucursal;
            END IF;   
    END FOREACH;     			

 END IF;


  IF pOrigen = 3 THEN
     IF pTipoEjecucion =1  THEN
          FOREACH
            SELECT fecha_acuecomp, sucursal, num_rdos_comp, 0, imp_neg_comp, imp_rec_comp, 0, porc_cump_comp, num_rdos_acue, 0, imp_neg_acue, imp_rec_acue, 0, 
                   porc_cump_acue, 0, num_rdos_comp+num_rdos_acue, 0, imp_neg_comp+imp_neg_acue, imp_rec_comp+imp_rec_acue,
                   (((imp_rec_comp + imp_rec_acue) / (imp_neg_comp + imp_neg_acue)) * 100) 
              INTO dtFechaAcueComp, cSucursal, iNum_Rdos_Comp, dNegEfectVolComp, dImp_Neg_Comp, dImp_Rec_Comp, dNegEfectMontComp, dPorc_Cump_Comp, iNum_Rdos_Acue,dNegEfectVolAcue,
                   dImp_Neg_Acue, dImp_Rec_Acue, dNegEfectMontAcue, dPorc_Cump_Acue, iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, 
                   dPorcRecConv  
              FROM bdicred:"informix".sd_consulta_acue_comp_2
             WHERE usuario   = pUsuario
      			   AND id_sesion = iNumSesion
      		   ORDER BY fecha_acuecomp,sucursal

 
            LET iContador = iContador + 1; 
      		--1o insertar
      		  LET cFechaAcueComp=DAY(dtFechaAcueComp)||'-'||MONTH(dtFechaAcueComp)||'-'||YEAR(dtFechaAcueComp);
      			INSERT INTO bdicred:tme_encabezadosexcel (fecha_acuecomp,sucursal,num_rdos_comp,neg_efecvol_comp,imp_neg_comp,imp_rec_comp,neg_efecmonto_comp,porc_cump_comp,num_rdos_acue,neg_efecvol_acue,imp_neg_acue,imp_rec_acue,neg_efecmonto_acue,porc_cump_acue,num_ctes_con_vdo,num_convenios,porc_ctes_conv,pesos_convenios,pesos_pago,porc_rec_conv)
      				VALUES(cFechaAcueComp,cSucursal,iNum_Rdos_Comp,dNegEfectVolComp,dImp_Neg_Comp,dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue,dImp_Neg_Acue,dImp_Rec_Acue,dNegEfectMontAcue,dPorc_Cump_Acue,iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv);	
      			LET cFechaAcueComp="";	
      
      			IF iContador <=  iRegistros THEN
      			  --luego regresar datos para el grid
      					RETURN cCodRet, cMensajeRet, NVL(vcNomDivision,""), NVL(cNomRegion,""), NVL(cSucursal,""), NVL(iNum_Rdos_Comp,0), NVL(dNegEfectVolComp,0.0), NVL(dImp_Neg_Comp,0.0), NVL(dImp_Rec_Comp,0.0), 
      					NVL(dNegEfectMontComp,0.0), NVL(dPorc_Cump_Comp,0.0), NVL(iNum_Rdos_Acue,0), NVL(dNegEfectVolAcue,0.0), NVL(dImp_Neg_Acue,0.0), NVL(dImp_Rec_Acue,0.0), NVL(dNegEfectMontAcue,0.0), NVL(dPorc_Cump_Acue,0.0), NVL(iNumCtesVdo,0), NVL(iNumConvenios,0), NVL(dPorcCtesConv,0.0), NVL(dPesosConvenios,0.0), NVL(dPesosPago,0.0), NVL(dPorcRecConv,0.0),NVL(dtFechaAcueComp,MDY(1,1,1900)) WITH RESUME;
      			END IF;
          END FOREACH;    
     END IF; 
  
  ELSE  
      	-- BARRE LA TABLA DE TRABAJO PARA OBTENER LOS RESULTADOS
      	FOREACH				
      	
      		--**************SE OBTINENE LAS 4 COLUMNAS DE VOLUMEN Y MONTO EN LA TABLA FINAL DE TRABAJO************
      		SELECT consul.id_sesion, consul.usuario, consul.nom_division, consul.nom_region, consul.sucursal, consul.fecha_acuecomp,consul.num_rdos_comp,
                 t3.neg_com_por_suc,consul.imp_neg_comp, consul.imp_rec_comp, t1.NegEfecMonAcue,consul.porc_cump_comp, consul.num_rdos_acue,
                 t3.neg_acue_por_suc,consul.imp_neg_acue, consul.imp_rec_acue,t2.MonAcue,consul.porc_cump_acue,	t3.totnumcte,
      		(consul.num_rdos_comp + consul.num_rdos_acue),
      		((consul.num_rdos_comp + consul.num_rdos_acue) / t3.totnumcte),
      		(consul.imp_neg_comp + consul.imp_neg_acue),
      		(consul.imp_rec_comp + consul.imp_rec_acue),
      		(((consul.imp_rec_comp + consul.imp_rec_acue) / (consul.imp_neg_comp + consul.imp_neg_acue)) * 100)
      		INTO iId_sesion, cUsuario, vcNomDivision,cNomRegion,cSucursal,dtFechaAcueComp,iNum_Rdos_Comp,  dNegEfectVolComp,dImp_Neg_Comp,dImp_Rec_Comp,  dNegEfectMontComp, dPorc_Cump_Comp,iNum_Rdos_Acue,   dNegEfectVolAcue,dImp_Neg_Acue,dImp_Rec_Acue,	dNegEfectMontAcue,dPorc_Cump_Acue,
      				iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv
      		FROM bdicred:"informix".sd_consulta_acue_comp consul
      			LEFT OUTER JOIN tempcom4 t3 ON(consul.sucursal = t3.sucursal)
      			LEFT OUTER JOIN	tempcomacue t1 ON(consul.sucursal = t1.sucursal)
      			LEFT OUTER JOIN	tempcomacue2 t2 ON(consul.sucursal = t2.sucursal)								
      		WHERE consul.usuario   = pUsuario
      			AND consul.id_sesion = iNumSesion
      		ORDER BY consul.fecha_acuecomp,consul.sucursal
      		
      		LET iContador = iContador + 1; 
      
      		IF pTipoEjecucion =1  THEN
      		--1o insertar
      		  LET cFechaAcueComp=DAY(dtFechaAcueComp)||'-'||MONTH(dtFechaAcueComp)||'-'||YEAR(dtFechaAcueComp);
      				INSERT INTO bdicred:tme_encabezadosexcel (fecha_acuecomp,sucursal,num_rdos_comp,neg_efecvol_comp,imp_neg_comp,imp_rec_comp,neg_efecmonto_comp,porc_cump_comp,num_rdos_acue,neg_efecvol_acue,imp_neg_acue,imp_rec_acue,neg_efecmonto_acue,porc_cump_acue,num_ctes_con_vdo,num_convenios,porc_ctes_conv,pesos_convenios,pesos_pago,porc_rec_conv)
      				VALUES(cFechaAcueComp,cSucursal,iNum_Rdos_Comp,dNegEfectVolComp,dImp_Neg_Comp,dImp_Rec_Comp,dNegEfectMontComp,dPorc_Cump_Comp,iNum_Rdos_Acue,dNegEfectVolAcue,dImp_Neg_Acue,dImp_Rec_Acue,dNegEfectMontAcue,dPorc_Cump_Acue,iNumCtesVdo, iNumConvenios, dPorcCtesConv, dPesosConvenios, dPesosPago, dPorcRecConv);	
      				LET cFechaAcueComp="";	
      
      				IF iContador <=  iRegistros THEN
      			  --luego regresar datos para el grid
      					RETURN cCodRet, cMensajeRet, NVL(vcNomDivision,""), NVL(cNomRegion,""), NVL(cSucursal,""), NVL(iNum_Rdos_Comp,0), NVL(dNegEfectVolComp,0.0), NVL(dImp_Neg_Comp,0.0), NVL(dImp_Rec_Comp,0.0), 
      					NVL(dNegEfectMontComp,0.0), NVL(dPorc_Cump_Comp,0.0), NVL(iNum_Rdos_Acue,0), NVL(dNegEfectVolAcue,0.0), NVL(dImp_Neg_Acue,0.0), NVL(dImp_Rec_Acue,0.0), NVL(dNegEfectMontAcue,0.0), NVL(dPorc_Cump_Acue,0.0), NVL(iNumCtesVdo,0), NVL(iNumConvenios,0), NVL(dPorcCtesConv,0.0), NVL(dPesosConvenios,0.0), NVL(dPesosPago,0.0), NVL(dPorcRecConv,0.0),NVL(dtFechaAcueComp,MDY(1,1,1900)) WITH RESUME;
      				END IF;    
      		END IF;
      			
      	END FOREACH;
	
  END IF;
  		
	LET iNRows = dbinfo("sqlca.sqlerrd2");
	IF iNRows = 0 THEN
		LET cCodRet = "000002";
		LET cMensajeRet = "NO EXISTEN DATOS PARA ESTA CONSULTA";
		--DELETE FROM bdicred:"informix".sd_consulta_acue_comp  WHERE usuario  = pUsuario   AND id_sesion = iId_sesion;
		--SE ELIMINAN TABLAS TEMPORALES.
		
		DROP TABLE bdicred: tempcomacue;	
		DROP TABLE bdicred: tempcomacue2;		
		DROP TABLE bdicred: tempcom1;		
		DROP TABLE bdicred: tempcom4;
		DROP TABLE bdicred: bit_realiza_filtrada;
		DROP TABLE bdicred: bit_realiza_filtrada2;
									
		DROP TABLE bdicred: tmeacuerdos;
		DROP TABLE bdicred: tmeacuerdosaompromisos2;
		DROP TABLE bdicred: tmeacuerdosaompromisos3; 	
		
		RETURN cCodRet, cMensajeRet, 0, 0, "", 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0,0,0,0,0,0,MDY(1,1,1900);
		
	ELSE
	     IF pOrigen = 3 THEN
          DROP TABLE bdicred: tmeacuerdos;
      		DROP TABLE bdicred: tmeacuerdosaompromisos2;
      		DROP TABLE bdicred: tmeacuerdosaompromisos3;
       ELSE	     
      		DELETE FROM bdicred:"informix".sd_consulta_acue_comp  WHERE usuario  = pUsuario   AND id_sesion = iId_sesion;
      		DELETE FROM bdicred:"informix".sd_consulta_acue_comp_2  WHERE usuario  = pUsuario   AND id_sesion = iId_sesion;
      		--SE ELIMINAN TABLAS TEMPORALES.
      		DROP TABLE bdicred: tempcomacue;	
      		DROP TABLE bdicred: tempcomacue2;		
      		DROP TABLE bdicred: tempcom1;		
      		DROP TABLE bdicred: tempcom4;
      		DROP TABLE bdicred: bit_realiza_filtrada;
      		DROP TABLE bdicred: bit_realiza_filtrada2;
      		DROP TABLE bdicred: bit_realiza_filtrada3;
      									
      		DROP TABLE bdicred: tmeacuerdos;
      		DROP TABLE bdicred: tmeacuerdosaompromisos2;
      		DROP TABLE bdicred: tmeacuerdosaompromisos3; 	
      END IF;
	END IF;
	

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento principal para la obtención de los datos de compromisos y convenios.', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2010',
'VERSION: 20100827.1152',
'MODIFICACION: Se modifico para que muestre los datos ordenados por Fecha y Sucursal.Tambien se agrego la validacion',
' del tipo de consulta, REGION ,DIVISION O SUCURSAL, ya que por sucursal se mostraran agrupados por fecha, y region y division agrupada por sucursal', 
'AUTOR: Guadalupe Payan, Abigail Vasavilbazo Cañedo ',
'FECHA: Septiembre 2010',
'VERSION: 20101018.1117',
'MODIFICACION: Se modificó para que se pueda trabajar con el aplicativo en varias sesiones al mismo tiempo sin marcar ningun error',
'y se agrega la opcion para generar un archivo excel con la informacion de la consulta, y que solo regrese un cierto numero de registros de muestra',
'AUTOR: Héctor Manuel Bojórquez Ruelas,Jesús Manuel Aguilar Heredia',
'FECHA: Junio 2011',
'VERSION: 20110630.1010',
'MODIFICACION: Se modifica para que se aguarde la fecha a formato dd-mm-yyyy en la generacion del archivo',
'AUTOR: Jesús Manuel Aguilar Heredia',
'FECHA: Julio 2011',
'VERSION: 20110708.0949',
'DESCRIPCION MODIFICACION: Se modifico para calcular y retornar la Negociación Efectiva(volumen) y la Negociación Efectiva(monto) tanto para Compromisos',
'						   como para Acuerdos',
'FECHA MODIFICACION: 03 de Mayo del 2012',
'AUTOR MODIFICACION: Guadalupe Payan',
'VERSION: 20120503.1508',
'BD: bdicred',
'FECHA: 2012-07-26',
'MODIFICACION: Filtrar para que solamente tome el origen 2 (sucursal) en query principal. Autor:MACF',
'DESCRIPCION MODIFICACION: Se modifica para agregar nuevas coulmas tales como: ' ,
	'numero clientes vencido, numero convenios, porcentaje clientes convenios, pesos convenios, pesos pago, porcentaje rec convenios',
'FECHA MODIFICACION: 27 de Agosto del 2012',
'AUTOR MODIFICACION: Mohamed Carreón',
'VERSION: 20120827.1248',
'BD: bdicred',
'FECHA: 2012-08-27';

CREATE PROCEDURE "informix".sp_cac_consulta_productos()
RETURNING 
		CHAR(5)		AS cCodRet,
		CHAR(80)	AS cMensajeRet,
		CHAR (40)	AS nombre_prod,
		CHAR (4)	AS num_producto;
		
---DECLARACIONES
    DEFINE iSqlErr						INTEGER;
    DEFINE iIsamErr						INTEGER;
    DEFINE vErrorInfo					VARCHAR(80);
    DEFINE cCodRet						CHAR(5);
	DEFINE cMensajeRet     				CHAR(80);
	DEFINE cNum_Producto				CHAR(4);
	DEFINE cNombre_prod					CHAR(40);
	DEFINE iRows						INTEGER;
	
	
	---INICIALIZACIONES
	LET iSqlErr						= 0;
	LET iIsamErr					= 0;
	LET vErrorInfo					= '';
	LET cCodRet						= '00000';
	LET cMensajeRet					= 'PROCESO EXITOSO';
	LET cNombre_prod				= '';
	LET cNum_Producto				= '';
	LET iRows						= 0;
	
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		   IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensajeRet = TRIM(NVL(vErrorInfo,''));
				RETURN TRIM(cCodRet),TRIM(NVL(cMensajeRet,'')),TRIM(NVL(cNombre_prod,'')),TRIM(NVL(cNum_Producto,''));
				
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/home/sysifx/respaldosbd/josue/sp_cac_consulta_productos';
	--TRACE ON;
	
				FOREACH
					SELECT nombre_prod,num_producto 
					INTO cNombre_prod,cNum_Producto 
					FROM bdicred: "informix".sd_definicion
					ORDER BY num_producto
								
				RETURN TRIM(cCodRet),TRIM(NVL(cMensajeRet,'')),TRIM(NVL(cNombre_prod,'')),TRIM(NVL(cNum_Producto,'')) WITH RESUME;
										

				END FOREACH;
				
				LET iRows = dbinfo("sqlca.sqlerrd2");

				IF(iRows = 0) THEN					
					LET cCodRet = "00001";
					LET cMensajeRet = "NO SE ENCONTRO INFORMACIÓN EN EL CATÁLOGO DE PRODUCTOS DE CRÉDITO";

				RETURN TRIM(cCodRet),TRIM(NVL(cMensajeRet,'')),TRIM(NVL(cNombre_prod,'')),TRIM(NVL(cNum_Producto,''));
					
				END IF;	
					
				
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Creación de un procedimiento nuevo el cual consulta y regresa la información de los campos nombre_prod','y num_producto de la tabla sd_definicion', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 07 de Agosto del 2012',
'VERSION: 20120807.1048',
'BD BDICRED',

'DESCRIPCION: Se modifíca para regresar los registros ordenados de acuaerdo al número de producto', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 04 de septiembre del 2012',
'VERSION: 20120904.1600';

CREATE PROCEDURE "informix".sp_consultas_cac_central_pba1(pEmpresa          CHAR(3), 
                                                     pSucursal         CHAR(4),
                                                     pFechaInicial     DATE,
                                                     pFechaFinal       DATE,
                                                     pNumSol           CHAR(20),
                                                     pBanCac           CHAR(1),
                                                     pCac_Opt1_1       DECIMAL(5,2),
                                                     pCac_Opt3_1       INTEGER)
RETURNING 
          CHAR(6),          -- Código de Retorno  
          CHAR(80),         -- Mensaje de Retorno
          CHAR(20),         -- Número de Solicitud
          CHAR(20),         -- Número de Cliente
          CHAR(104),        -- Nombre del Cliente
          CHAR(13),         -- RFC
          CHAR(4),          -- Sucursal
          DATE,             -- Fecha Solicitud
          DATE,             -- Fecha Cambio Estatus
          DECIMAL(18,2),    -- Importe de Linea
          DECIMAL(5,2),     -- Eficiencia
          INTEGER,          -- Historial
          DECIMAL(5,2),     -- Puntos 1a Sección
          DECIMAL(5,2),     -- Puntos 2da Sección
          CHAR(2),          -- Estatus
          CHAR(511),        -- Observaciones Anteriores
          DECIMAL(8,2);
                  
DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE iComproboIngresos       INTEGER;
DEFINE iProfPens               INTEGER;
DEFINE cBanCac                 CHAR(1);

DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);

DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;

DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);

DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);

DEFINE dfecha                  CHAR(10);
DEFINE ddia                    CHAR(02);
DEFINE dmes                    CHAR(02);
DEFINE danio                   CHAR(04);


LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;
LET iComproboIngresos          = 0;
LET iProfPens                  = 0;
LET cBanCac                    = '';

LET cNombreCte                 = '';
LET cRFC                       = '';

LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;

LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';

LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';

LET dfecha                     = '';


-- ** HISTORIAL DE CAMBIOS ** --

--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.

-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la selección principal los 3 tipos de consulta 
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet,cMensajeRet,NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones;
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!
--SET DEBUG FILE TO '/tmp/sp_consultas_CAC_central.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizó la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor 
           INTO dfecha 
           FROM "informix".sd_param 
          WHERE cod_param='030';
     LET pFechaInicial=DATE(dfecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;    
  
FOREACH 

    -- Se obtienen los datos de la solicitud.
     SELECT 
            sol.num_solicitud,         -- Número de Solicitud
            sol.numcte,                -- Número Cte
            sol.sucursal,              -- Sucursal
            sol.status_solicitud,      -- Status Solicitud
            sol.tipo_solicitud,        -- Tipo Solicitud
            sol.monto_solicitado,      -- Monto Solicitado
            sol.fecha_insert,          -- Fecha Insert
            (CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima Autorización
                 THEN NVL(aut.fecha_entrada,date(1))
                 ELSE NVL(esp.fecha_modif,date(1)) 
            END),
            (CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de Autorización
                 THEN NVL(aut.comentario,"")
                 ELSE NVL(esp.comentario,"")
            END),
            NVL(aut.revision_cac,0)
       INTO cNumSolicitud,
            cNumCte,
            cSucursal,
            cStatusSol,
            cTipoSolicitud,
            dMontoSolicitado,
            dtFechaInsert,
            dtFechaModificacion,
            cComentarioAut,
            iRevisionCac
      FROM bdisolic:"informix".ss_solicitudes sol
FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud 
                                                          AND aut.empresa= sol.empresa 
                                                          AND aut.status_solicitud= sol.status_solicitud
                                                          AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
                                                                                   FROM bdisolic:ss_autorizacion aut_aux
                                                                                   WHERE aut_aux.empresa= sol.empresa 
                                                                                   AND aut_aux.num_solicitud= sol.num_solicitud 
                                                                                   AND aut_aux.status_solicitud= sol.status_solicitud)
                                                          AND aut.ejecutivo_auto= aut.ejecutivo_auto)
FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa  
                                                                   AND esp.num_solicitud= sol.num_solicitud
                                                                   AND esp.numcte=sol.numcte
                                                                   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0) 
                                                                                         FROM bdisolic:ss_autorizacion_especial AS esp_aux
                                                                                        WHERE esp_aux.empresa= sol.empresa
                                                                                          AND esp_aux.num_solicitud= sol.num_solicitud
                                                                                          AND esp_aux.numcte= sol.numcte)
                                                                   AND sol.status_solicitud= esp.status_nvo)
      Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
     WHERE sol.num_solicitud= (CASE WHEN pNumSol IS NULL THEN sol.num_solicitud ELSE pNumSol END)
       AND sol.empresa= pEmpresa
       AND sol.status_solicitud= (CASE WHEN pBanCac= 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opción de la consulta es CAC, si es asi tendrian que ser solo status "RT"
       AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
       AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
       AND (sol.fecha_insert >= (CASE WHEN pFechaInicial IS NULL THEN sol.fecha_insert ELSE pFechaInicial END) 
       AND  sol.fecha_insert <= (CASE WHEN pFechaFinal IS NULL THEN sol.fecha_insert ELSE pFechaFinal END))
       
       

    -- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
    -- En caso contrario no se mostraria en la consulta.

       IF cStatusSol IN ('CC','BC') THEN
            SELECT COUNT(*)
              INTO iInfoBuro
              FROM bdiburo:"informix".br_traslado AS tras 
              INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud = reg.num_solicitud) 
			  WHERE tras.num_solicitud = cNumSolicitud;
             
             IF NVL(iInfoBuro,0) = 0 THEN
                
				SELECT COUNT(*)
                INTO iInfoBuro
                FROM bdiburo:"informix".br_traslado AS tras 
                INNER JOIN bdiburo:"informix".sb_regreso_2011 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud) 
                WHERE tras.num_solicitud = cNumSolicitud;
				
				IF NVL(iInfoBuro,0) = 0 THEN
				   CONTINUE FOREACH;
                END IF;
			 
			 END IF;
			 
       END IF;

    -- Se obtienen los datos de la información crediticia en COPPEL/BANCOPPEL.
    
    IF pBanCac= 'S' THEN
        SELECT ef.situacion_pago,         -- Situacion Pago
               ef.meses_historia          -- Meses Historia
          INTO dSituacionPago,
               iMesesHistoria
          FROM bdisolic:"informix".ss_resum_scor_fin AS ef 
         WHERE ef.empresa= pEmpresa
           AND ef.num_solicitud= cNumSolicitud
           AND ef.meses_historia > 13
           AND ef.fuente =  'T' 
           AND NVL(ef.evalua_cc,'') <> '1'; -- No haya tenido malos antecedentes crediticios    
    ELSE 
       SELECT ef.situacion_pago,         -- Situacion Pago
               ef.meses_historia          -- Meses Historia
          INTO dSituacionPago,
               iMesesHistoria
          FROM bdisolic:"informix".ss_resum_scor_fin AS ef 
         WHERE ef.empresa= pEmpresa
           AND ef.num_solicitud= cNumSolicitud;
    END IF
          IF dSituacionPago IS NULL AND iMesesHistoria IS NULL THEN
            CONTINUE FOREACH;
          END IF;

    -- Se obtiene las puntuaciones del scoring que se le realizó al cliente.
    SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
           NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
           NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
           COUNT(num_solicitud) AS cantidad
      INTO dSeccion1,
           dSeccion2,
           dSumaSecciones,
           iCantidad
      FROM bdisolic:"informix".ss_resumen_scoring 
     WHERE empresa= pEmpresa
       AND num_solicitud = cNumSolicitud
       AND seccion IN ('1','2'); 

    IF iCantidad <> 2 THEN 

           LET dSeccion1= 0;
           LET dSeccion2= 0;
           LET dSumaSecciones= 0;

        SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
               COUNT(*) AS cuantos
          INTO dSeccion1, icuantos
          FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:ss_resum_scor_fin rsf
         WHERE rsf.empresa = pEmpresa
           AND rsf.num_solicitud = cNumSolicitud
           AND rsf.empresa = sf.empresa
           AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
           AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
           AND sf.min_mes_hist <= rsf.meses_historia
           AND sf.max_mes_hist >= rsf.meses_historia
           AND sf.min_porc_pago <= rsf.situacion_pago
           AND sf.max_porc_pago >= rsf.situacion_pago;

       FOREACH      
            SELECT sg.empresa, sg.seccion, 
                   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
              INTO cEmpAux, iSecAux, dSeccionAux
              FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:ss_scoring_grupo sg
             WHERE sg.empresa = dc.empresa
               AND sg.grupo = dc.grupo
               AND sg.seccion = dc.seccion
               AND dc.num_solicitud = cNumSolicitud
               AND dc.seccion = '2'
               AND dc.empresa = pEmpresa
          GROUP BY sg.empresa, sg.seccion, sg.agrupar

            LET dSeccion2= dSeccion2 + dSeccionAux;
            LET dSumaSecciones= dSeccion1 + dSeccion2;
   END FOREACH;

   END IF;

       IF pBanCac= "S" THEN

            IF (dSumaSecciones < pCac_Opt1_1) THEN
                  CONTINUE FOREACH;
            END IF;
            {IF pCac_Opt3_1 <> 0 THEN
                IF iRevisionCac <> 0 THEN
                    CONTINUE FOREACH;
                END IF;
            END IF;}

       

       END IF;

 -- Se obtiene el nombre del cliente
    SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
                                              TRIM(nvl(a.nombre2,'')) ||' '||
                                              TRIM(nvl(a.apell_paterno,'')) ||' '||
                                              TRIM(nvl(a.apell_materno,'')),
                                              TRIM(a.razon_social)),
           rfc
      INTO cNombreCte, cRFC
      FROM bdinteg:"informix".si_cliente a
     WHERE a.numcte = cNumCte;


    RETURN cCodRet,cMensajeRet,NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones WITH RESUME;
           
END FOREACH;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'las consultas del Aplicativo CConCac en el central',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 03/01/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consultas_cac_central_pba2(pEmpresa          CHAR(3),
                                                     pSucursal         CHAR(4),
                                                     pFechaInicial     DATE,
                                                     pFechaFinal       DATE,
                                                     pNumSol           CHAR(20),
                                                     pBanCac           CHAR(1),
                                                     pCac_Opt1_1       DECIMAL(5,2),
                                                     pCac_Opt3_1       INTEGER,
                                                     pArea             CHAR(2),
                                                     pStatus           CHAR(2),
                                                     pCausa            CHAR(3),
													 pProducto         CHAR(4)
                                                     )
RETURNING
          CHAR(6),          -- Código de Retorno
          CHAR(80),         -- Mensaje de Retorno		 
          CHAR(20),         -- Número de Solicitud
          CHAR(20),         -- Número de Cliente
          CHAR(104),        -- Nombre del Cliente
          CHAR(13),         -- RFC
          CHAR(4),          -- Sucursal
          DATE,             -- Fecha Solicitud
          DATE,             -- Fecha Cambio Estatus
          DECIMAL(18,2),    -- Importe de Linea
          DECIMAL(5,2),     -- Eficiencia
          INTEGER,          -- Historial
          DECIMAL(5,2),     -- Puntos 1a Sección
          DECIMAL(5,2),     -- Puntos 2da Sección
          CHAR(2),          -- Estatus
          CHAR(511),        -- Observaciones Anteriores
          DECIMAL(8,2),     -- Suma de Secciones
		  CHAR(3);          -- Causa del Status


DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);
DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;
DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);
DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);
DEFINE cFecha                  CHAR(10);
DEFINE cCausa					CHAR(3);
DEFINE dECValor1					DECIMAL(5,2);
DEFINE dECValor2					DECIMAL(5,2);
DEFINE dMACValor1					DECIMAL(5,2);
DEFINE dMACValor2					DECIMAL(5,2);
DEFINE dPSValor1					DECIMAL(5,2);
DEFINE dPSValor2					DECIMAL(5,2);

DEFINE iMeseshist               INTEGER;
DEFINE cProducto               CHAR(4);



LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;

LET cNombreCte                 = '';
LET cRFC                       = '';

LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;

LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';

LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';

LET cFecha                     = '';
LET cCausa						= '';
LET dECValor1					= 0.0;
LET dECValor2					= 0.0;
LET dMACValor1				= 0.0;
LET dMACValor2				= 0.0;
LET dPSValor1					= 0.0;
LET dPSValor2					= 0.0;
LET iMeseshist               = 0;
LET cProducto               = "";


-- ** HISTORIAL DE CAMBIOS ** --

--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.

-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la selección principal los 3 tipos de consulta
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
--
--Autor Mohamed Carreón
--07/06/ 2010
--Comentarios: se agregó la causa del status y los filtros para los criterios del cac y mc.

--Autor: Viridiana Osobampo Aguilar
--24/01/ 2011
--Comentarios: Se modifica para que la validación de eficiencia, meses de historia y puntuación scoring
--                        solo se realice cuando se trate de una consulta por CAC o MC.

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet,cMensajeRet,NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,'');
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!

--SET DEBUG FILE TO '/home/sysifx/Viridiana/sp_consultas_CAC_central.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizó la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor
           INTO cFecha
           FROM bdicred:"informix".sd_param
          WHERE cod_param='030';
     LET pFechaInicial=DATE(cFecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;


IF pArea <> '' THEN
--- >>> POR CAC O MC <<< ---
---  OBTIENE LOS CRITERIOS DE EFICIENCIA COPPEL

    SELECT valor1,valor2
      INTO dECValor1,dECValor2
      FROM bdicred:"informix".sd_criterios_consulta_cac
     WHERE id_area = pArea
       AND tpo_criterio = "01";

---  OBTIENE LOS CRITERIOS DE MESES DE HISTORIA COPPEL
    SELECT valor1,valor2
      INTO dMACValor1,dMACValor2
      FROM  bdicred:"informix".sd_criterios_consulta_cac
     WHERE id_area = pArea
       AND tpo_criterio = "02";

---  OBTIENE LOS CRITERIOS DE PUNTUACION DE SCORING
    SELECT valor1,valor2
      INTO dPSValor1,dPSValor2
      FROM  bdicred:"informix".sd_criterios_consulta_cac
     WHERE id_area = pArea
       AND tpo_criterio = "03";
END IF;


FOREACH
    -- Se obtienen los datos de la solicitud.
     SELECT {+INDEX(bdisolic:ss_solicitudes idx_ss_solicitudes3)}
            sol.num_solicitud,         -- Número de Solicitud
            sol.numcte,                -- Número Cte
            sol.sucursal,              -- Sucursal
            sol.status_solicitud,      -- Status Solicitud
            sol.tipo_solicitud,        -- Tipo Solicitud
            sol.monto_solicitado,      -- Monto Solicitado
            sol.fecha_insert,          -- Fecha Insert
            (CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima Autorización
                 THEN NVL(aut.fecha_entrada,date(1))
                 ELSE NVL(esp.fecha_modif,date(1))
            END),
            (CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de Autorización
                 THEN NVL(aut.comentario,"")
                 ELSE NVL(esp.comentario,"")
            END),
            NVL(aut.revision_cac,0),
	    aut.causa_solicitud,
		sol.num_producto
       INTO cNumSolicitud,
            cNumCte,
            cSucursal,
            cStatusSol,
            cTipoSolicitud,
            dMontoSolicitado,
            dtFechaInsert,
            dtFechaModificacion,
            cComentarioAut,
            iRevisionCac,
			cCausa,
			cProducto
      FROM bdisolic:"informix".ss_solicitudes sol
FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud
                                                          AND aut.empresa= sol.empresa
                                                          AND aut.status_solicitud= sol.status_solicitud
                                                          AND aut.fecha_entrada=(SELECT MAX(aut_aux.fecha_entrada)
                                                                                   FROM bdisolic:"informix".ss_autorizacion aut_aux
                                                                                   WHERE aut_aux.empresa= sol.empresa
                                                                                   AND aut_aux.num_solicitud= sol.num_solicitud
                                                                                   AND aut_aux.status_solicitud= sol.status_solicitud)
                                                          AND aut.ejecutivo_auto= aut.ejecutivo_auto)
FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa
                                                                   AND esp.num_solicitud= sol.num_solicitud
                                                                   AND esp.numcte=sol.numcte
                                                                   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0)
                                                                                         FROM bdisolic:"informix".ss_autorizacion_especial AS esp_aux
                                                                                        WHERE esp_aux.empresa= sol.empresa
                                                                                          AND esp_aux.num_solicitud= sol.num_solicitud
                                                                                          AND esp_aux.numcte= sol.numcte)
                                                                   AND sol.status_solicitud= esp.status_nvo)
      Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
	LEFT OUTER JOIN bdicred:"informix".sd_criterios_status_causa_cac cri ON (aut.status_solicitud = cri.status AND aut.causa_solicitud = cri.causa AND cri.id_area = pArea)
     WHERE sol.num_solicitud= (CASE WHEN pNumSol IS NULL THEN sol.num_solicitud ELSE pNumSol END)
       ---AND sol.empresa= pEmpresa
       AND sol.status_solicitud = (CASE WHEN pBanCac = 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opción de la consulta es CAC, si es asi tendrian que ser solo status "RT"
       AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
       ---AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
       AND sol.sucursal between '0000' and '9760'
       AND (sol.fecha_insert >= (CASE WHEN pFechaInicial IS NULL THEN sol.fecha_insert ELSE pFechaInicial END)
			AND  sol.fecha_insert <= (CASE WHEN pFechaFinal IS NULL THEN sol.fecha_insert ELSE pFechaFinal END))
		AND NVL(cri.id_area,'') = DECODE(pArea,'',NVL(cri.id_area,''),pArea)

		AND NVL(sol.num_producto,'') = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
		AND NVL(aut.status_solicitud,'') = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)
		AND NVL(aut.causa_solicitud,'') = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)

    -- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
    -- En caso contrario no se mostraria en la consulta.

       IF cStatusSol IN ('CC','BC') THEN
            SELECT COUNT(*)
              INTO iInfoBuro
              FROM bdiburo:"informix".br_traslado AS tras
              INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud = reg.num_solicitud)
			  WHERE tras.num_solicitud = cNumSolicitud;

             IF NVL(iInfoBuro,0) = 0 THEN

				SELECT COUNT(*)
                INTO iInfoBuro
                FROM bdiburo:"informix".br_traslado AS tras
                INNER JOIN bdiburo:"informix".sb_regreso_2011 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud)
                WHERE tras.num_solicitud = cNumSolicitud;

				IF NVL(iInfoBuro,0) = 0 THEN
				   CONTINUE FOREACH;
                END IF;

			 END IF;

       END IF;

    -- Se obtienen los datos de la información crediticia en COPPEL/BANCOPPEL.

               SELECT ef.situacion_pago,         -- Situacion Pago
                       ef.meses_historia          -- Meses Historia
                  INTO dSituacionPago,
                       iMesesHistoria
                  FROM bdisolic:"informix".ss_resum_scor_fin AS ef
                 WHERE ef.empresa= pEmpresa
                   AND ef.num_solicitud= cNumSolicitud;
				   
				   -- SE VALIDA QUE EL PRODUCTO NO SEA DE REESTRUCTURA DE TARJETAS DE CRÉDITO

                  IF (dSituacionPago IS NULL AND iMesesHistoria IS NULL) AND NVL(cProducto,'') <> '6011' THEN
                    CONTINUE FOREACH;
                  END IF;

                IF NVL(pArea, "") <> "" THEN

                      IF NOT ((dSituacionPago >= dECValor1 AND dSituacionPago <= dECValor2) AND
                               (iMesesHistoria >= dMACValor1 AND iMesesHistoria <=dMACValor2)) AND NVL(cProducto,'') <> '6011' THEN

                            CONTINUE FOREACH;
                  END IF;

    END IF;
    -- Se obtiene las puntuaciones del scoring que se le realizó al cliente.
    SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
           NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
           NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
           COUNT(num_solicitud) AS cantidad
      INTO dSeccion1,    
           dSeccion2,
           dSumaSecciones,
           iCantidad
      FROM bdisolic:"informix".ss_resumen_scoring
     WHERE empresa= pEmpresa
       AND num_solicitud = cNumSolicitud
       AND seccion IN ('1','2');

    IF iCantidad <> 2 THEN

           LET dSeccion1= 0;
           LET dSeccion2= 0;
           LET dSumaSecciones= 0;

        SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
               COUNT(*) AS cuantos
          INTO dSeccion1, icuantos
          FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:"informix".ss_resum_scor_fin rsf
         WHERE rsf.empresa = pEmpresa
           AND rsf.num_solicitud = cNumSolicitud
           AND rsf.empresa = sf.empresa
           AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
           AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
           AND sf.min_mes_hist <= rsf.meses_historia
           AND sf.max_mes_hist >= rsf.meses_historia
           AND sf.min_porc_pago <= rsf.situacion_pago
           AND sf.max_porc_pago >= rsf.situacion_pago;

       FOREACH
            SELECT sg.empresa, sg.seccion,
                   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
              INTO cEmpAux, iSecAux, dSeccionAux
              FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg
             WHERE sg.empresa = dc.empresa
               AND sg.grupo = dc.grupo
               AND sg.seccion = dc.seccion
               AND dc.num_solicitud = cNumSolicitud
               AND dc.seccion = '2'
               AND dc.empresa = pEmpresa
          GROUP BY sg.empresa, sg.seccion, sg.agrupar

            LET dSeccion2= dSeccion2 + dSeccionAux;
            LET dSumaSecciones= dSeccion1 + dSeccion2;
   END FOREACH;

   END IF;

   IF NVL(pArea,"") <> "" THEN
        IF NOT (dSumaSecciones >= dPSValor1 AND dSumaSecciones <= dPSValor2) AND NVL(cProducto,'') <> '6011' THEN
                CONTINUE FOREACH;
        END IF;
   END IF;

 -- Se obtiene el nombre del cliente
    SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
                                              TRIM(nvl(a.nombre2,'')) ||' '||
                                              TRIM(nvl(a.apell_paterno,'')) ||' '||
                                              TRIM(nvl(a.apell_materno,'')),
                                              TRIM(a.razon_social)),
           rfc
      INTO cNombreCte, cRFC
      FROM bdinteg:"informix".si_cliente a
     WHERE a.numcte = cNumCte;


    RETURN cCodRet,cMensajeRet,NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
           NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,'') WITH RESUME;

END FOREACH;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para obtener',
'las consultas del Aplicativo CConCac en el central',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 03/01/2009',
'BD    : BDICRED',

'DESCRIPCION: Se modifíca para que se haga un fíltro más ahora por  --- Producto --- ', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 08 de Agosto del 2012',
'VERSION: 20120808.1748',


'DESCRIPCION: Se modifíca para que valide si se encuentra el cliente  o no en la tabla " ss_resum_scor_fin " de , todos modos regrese la información debida', 
'AUTOR: Josué Remberto Zazueta Acosta ',
'FECHA: 04 de septiembre del 2012',
'VERSION: 20120904.1640';

create procedure "informix".liberasalret_pba(pempresa char(3), pejecutivo char(10))
returning char(5);
    
    -- **********************************************************
    -- *        Programa que libera los cheques retenidos       *
    -- *            Autor : Cristian Campos diaz                *
    -- *            Fecha : 06/Septiembre/2007                  *
    -- *            Ver.  : 1.0                                 *
    -- **********************************************************

    define vdias_ret        integer;
    define vdia_res         integer;
    define vmonto           money(14,2);
    define vfecha_alta      date;
    define vnum_chq         integer;
    define vtransacc        char(4);
    define vmonto_ori       money(14,2);
    define vnumero          char(4);
    define vsistema         char(2);
    define vfecha_hoy       date;
    define vfecha_ant       date;
    define vfechab_ant      date;
    define vcuenta          char(20);
    define vcancelado       char(1);
    define vrowid           integer;
    define vcodret          char(5);
    define vcodret2         char(5);
    define vcodret3         char(50);
    define vsqlerr          integer;
    define visamerr         integer;
    define vdescerr         char(50);
    define vconproc         integer;
    define vproceso         char(20);
    define vexiste          integer;
    define vexistefin       integer;
    define vRetenido        DECIMAL(14,2);
    define vabierto         CHAR(1);
    define vcomienza        INTEGER;
    define vsql             char(600);
    define vstmt            char(250);
    define vmincta          char(20);
    define vmaxcta          char(20);
    define vexisteproc      char(12);
    define vcodretsbg1      char(5);
    define vcodretsbg2      char(5);
    define vcontsbg1        integer;
    define vcontsbg2        integer;
    define vcodret_libinterpza  char(5);

    let vcodret   = "000";
    let vcodret2  = "000";
    let vcodret3  = "";
    let vsqlerr   = 0;
    let visamerr  = 0;
    let vdescerr  = "";
    let vconproc  = 0;
    let vproceso  = "libsalretchq";
    let vsistema  = "01";
    let vRetenido = 0;
    let vabierto  = "0";
    let vcomienza = -1;
    let vsql      = '';
    let vstmt     = '';
    let vcodretsbg1 = '';
    let vcodretsbg2 = '';
    let vcontsbg1   = 0;
    let vcontsbg2   = 0;
    let vcodret_libinterpza = '';

    --- set debug file to "liberatranret.out";
    --- trace on;
    
    BEGIN

    on exception set vsqlerr, visamerr, vdescerr
        set debug file to "liberatranret.err";
        trace on;
        if vsqlerr <> 0  then
            let vcodret = vsqlerr;
            let vcodret2 = visamerr;
            let vcodret3 = vdescerr;
            
            LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||pejecutivo||''', '||
                       'status_proc   = '''||'C'||''', '||
                       'codret        = '''||vcodret||''', '||
                       'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
            SYSTEM vsql;
            
            LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
            SYSTEM vstmt;
            
            if vabierto = "1" then
                ROLLBACK WORK;
            end if;
            return vcodret;
        end if;
    end exception;
    
    set isolation to dirty read;
    set lock mode to wait 3;
    
    select fecha_hoy, fecha_ant
      into vfecha_hoy, vfecha_ant 
      from sc_fechas  
     where empresa = pempresa;
     
    -- // VALIDA HAYA FINALIZADO CIERRE DE CAPTACION
    select proceso
      into vexisteproc
      from sc_contproc
     where empresa = pempresa
       and proceso = 'cierre'
       and fecha = vfecha_ant;
    
    if vexisteproc is null or vexisteproc = '' then
        let vcodret = "962";       
        return vcodret;
    END IF
    
    -- // VERIFICA CONTROL DE PROCESOS EN INTEGRAL
    select count(*)   
      into vexiste
      from bdinteg:sx_contproc  
     where empresa = pempresa  
       and proceso = vproceso
       and fecha   = vfecha_hoy
       and sistema = vsistema;

    if vexiste = 0 then
        let vsql = 'echo " INSERT INTO bdinteg:sx_contproc VALUES '||
                   '('''||pempresa||''', '''||vproceso||''', '''||vfecha_hoy||''', '''||vsistema||''', '''||'I'||''', '''||pejecutivo||''','||
                   '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas), NULL, NULL);" > /tmp/horaslibsalret.sql';
        SYSTEM vsql;
        
        let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
        SYSTEM vstmt;
    else
        select count(*)   
          into vexistefin
          from bdinteg:sx_contproc  
         where empresa     = pempresa  
           and proceso     = vproceso
           and fecha       = vfecha_hoy
           and sistema     = vsistema
           and status_proc = "F"; 

        if vexistefin = 0 then
            let vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                       'SET ejecutivo = '''||pejecutivo||''', '||
                       'status_proc   = '''||'I'||''', '||
                       'hora_ini      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                       'WHERE empresa = '''||pempresa||''' '||
                       'AND proceso   = '''||vproceso||''' '||
                       'AND fecha     = '''||vfecha_hoy||''' '||
                       'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
            SYSTEM vsql;
            
            let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
            SYSTEM vstmt;
        else
            let vcodret = "971";
            
            -- // VERIFICA CONTROL DE PROCESOS EN CHEQUES
            select count(*) 
              into vconproc
              from sc_contproc
             where empresa = pempresa
               and proceso = vproceso
               and fecha = vfecha_hoy;

            if vconproc > 0 then
                if vabierto = 1 then
                    ROLLBACK WORK;  
                end if;
                
                return vcodret;
            end if;     
        end if
    end if; 
    
    execute procedure cal_habil_ant(vfecha_hoy) 
    into vcodret, vfechab_ant;

    if vcodret <> "000" then
        if vabierto = 1 then
            ROLLBACK WORK;  
        end if;
        
        let vsql = 'echo "UPDATE bdinteg:sx_contproc '||
                   'SET ejecutivo = '''||pejecutivo||''', '||
                   'status_proc   = '''||'C'||''', '||
                   'codret        = '''||vcodret||''', '||
                   'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
                   'WHERE empresa = '''||pempresa||''' '||
                   'AND proceso   = '''||vproceso||''' '||
                   'AND fecha     = '''||vfecha_hoy||''' '||
                   'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
        SYSTEM vsql;
        
        let vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
        SYSTEM vstmt;
        
        return vcodret;
    end if;  

    select min(cuenta), max(cuenta)
      into vmincta, vmaxcta
      from sc_docret;
    
    foreach principal with hold for
        select numero
          into vnumero
          from bdinteg:si_transacc
         where empresa = pempresa
           and sistema = "01"
           and numero like "08%"
           and tipo_tran in ("20","21","22")
           and naturaleza = "C"
         order by numero
        
        foreach with hold
            select {+INDEX(sc_docret idx_docret2)}
                   rowid, cuenta, transacc, dias_ret, monto, fecha_alta, cancelado, num_chq, monto_ori
              into vrowid, vcuenta, vtransacc, vdias_ret, vmonto, vfecha_alta, vcancelado, vnum_chq, vmonto_ori
              from sc_docret
             where cuenta between vmincta and vmaxcta
               and transacc = vnumero
               and cancelado = 'P'
               and (vfecha_hoy - fecha_alta) >= dias_ret 
               
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                BEGIN WORK;
                LET vabierto = "1";
            END IF;
            
            SELECT sdo_retenido
              INTO vRetenido
              FROM sc_maechq
             where empresa = pempresa
               and cuenta = vcuenta;

            LET vRetenido = vRetenido - vmonto;	

            IF vRetenido >= 0 THEN
                update sc_maechq
                   set sdo_retenido = sdo_retenido - vmonto
                 where empresa = pempresa
                   and cuenta = vcuenta;
            END IF
            
            update {+INDEX(sc_docret idx_docret2)} sc_docret
               set cancelado = "L",
                   dias_ret = 0
             where cuenta = vcuenta
               and transacc = vtransacc
               and cancelado = 'P'
               and rowid = vrowid;
               
            IF vabierto = 1 THEN
                COMMIT WORK;
                BEGIN WORK;
            END IF;

        end foreach;

    end foreach;
    
    IF vabierto = 1 THEN
        COMMIT WORK;
    END IF;
    
    -- // REALIZA LIBERACION DE RETENIDOS INTERPLAZA
    execute procedure "informix".sp_liberaretinterpza(pempresa)
    into vcodret_libinterpza;
    
    -- // REALIZA COBRO DE SOBREGIROS
    execute procedure "informix".sp_cobrosbg(pempresa)
    into vcodretsbg1, vcodretsbg2, vcontsbg1, vcontsbg2;

    -- // REGISTRA FINALIZACION DEL PROCESO
    update sc_contproc
       set fecha = vfecha_hoy
     where empresa = pempresa
       and proceso = vproceso;

    LET vsql = 'echo "UPDATE bdinteg:sx_contproc '||
               'SET ejecutivo = '''||pejecutivo||''', '||
               'status_proc   = '''||'F'||''', '||
               'codret        = '''||vcodret||''', '||
               'hora_fin      = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas) '||
               'WHERE empresa = '''||pempresa||''' '||
               'AND proceso   = '''||vproceso||''' '||
               'AND fecha     = '''||vfecha_hoy||''' '||
               'AND sistema   = '''||vsistema||''';" > /tmp/horaslibsalret.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /tmp/horaslibsalret.sql';
    SYSTEM vstmt;
    
    return vcodret;

    END;

end procedure;