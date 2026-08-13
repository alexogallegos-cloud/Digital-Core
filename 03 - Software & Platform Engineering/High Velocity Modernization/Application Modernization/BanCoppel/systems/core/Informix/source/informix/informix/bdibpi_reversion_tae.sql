CREATE PROCEDURE "informix".reversion_tae(pEmpresa  CHAR(3), pId_Sucursal CHAR (4),   pUsuario  CHAR(8), pFolioSucursal CHAR (16),  pTiporev  CHAR(1), pNumCategoria  CHAR(2), pNumConvenio   CHAR(3),   pFechaPago     DATE,   pReferencia CHAR (27), pNumTrama      INTEGER,pCadena_Req    CHAR (1620),   pCadena_Rply   CHAR (1620))
    RETURNING CHAR(5);
  
    --DESCRIPCION: Se crea spl nuevo para realizar el reverso del cobro y abono realizados de la compra de tiempo aire así
    --             como el registro en tablas del sistema si la respuesta de la conexión a Interactué no es exitosa
    --AUTOR: SOLSER SISTEM S.A. DE C.V
    --FECHA: 03/10/2019
    --VERSION: 20191003.0001
    --BD: bdibpi
    --SUSTENTO: Se definio en el Requerimiento: RQI 03 767 Compra Tiempo Aire Portal BanCoppel.doc
    --SOLICITO: Arturo Alejandro Vazquez Fernandez

    --DECLARA VARIABLES
    DEFINE   vempresa  CHAR(3);
    DEFINE   vidSucursal CHAR (4);
    DEFINE   vusuario  CHAR(8);
    DEFINE   vfolioSucursal CHAR (16);
    DEFINE   vtipoRev  CHAR(1);
    DEFINE   vfechaPago  DATE;
    DEFINE   vnumTrama       INTEGER;
    DEFINE   vcadenaReq  CHAR (1620);
    DEFINE   vcadenaRply     CHAR (1620);
    DEFINE   vnumCategoria  CHAR(2);
    DEFINE   vnumConvenio    CHAR(3);
    DEFINE   vReferencia CHAR (27);
    DEFINE   vcodigoRespuesta CHAR(40);
    DEFINE   vconceptoRespuesta CHAR(80);
    DEFINE   venviaTrama INTEGER;
    DEFINE   vreversa CHAR (1); 
    DEFINE   vcodErr CHAR (4);
    DEFINE   vcodErr_reversa CHAR (4);
    DEFINE   vencErrores CHAR(80);
    DEFINE   cod_ret              CHAR(5);
 
    --INICIA VARIABLES
    LET vempresa              ='';
    LET vidSucursal           ='';
    LET vusuario              ='';
    LET vfolioSucursal        ='';
    LET vtipoRev              ='';
    LET vfechaPago            ='';
    LET vnumTrama             = 0;
    LET vcadenaReq            ='';
    LET vcadenaRply           ='';
    LET vnumCategoria         ='';
    LET vnumConvenio          ='';
    LET vReferencia           ='';
    LET vcodigoRespuesta      ='';
    LET vconceptoRespuesta    ='';
    LET venviaTrama           = 0;
    LET vreversa              ='';
    LET vcodErr               ='';
    LET vcodErr_reversa       ='';
    LET vencErrores           ='';
    LET cod_ret               ='00000';
	
	
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
		
		
		
		
	
	--	SET DEBUG FILE TO '/informix/gaby/ArchivosOut/reversion_tae.out';
	--	TRACE ON;
    
    BEGIN
         LET vempresa             =  pEmpresa;
         LET vidSucursal          =  pId_Sucursal;
         LET vusuario             =  pUsuario;
         LET vfolioSucursal       =  pFolioSucursal;
         LET vtipoRev             =  pTiporev;
         LET vfechaPago           =  pFechaPago;
         LET vnumTrama            =  pNumTrama;
         LET vcadenaReq           =  pCadena_Req;
         LET vcadenaRply          =  pCadena_Rply;
         LET vnumCategoria        =  pNumCategoria;
         LET vnumConvenio         =  pNumConvenio;
         LET vReferencia          =  pReferencia;

        CALL bdicheq:"informix".reversion( vempresa, vidSucursal, vusuario, vfolioSucursal, vtipoRev)
            RETURNING cod_ret;
        
        IF ( cod_ret is null OR cod_ret <> '000' ) THEN
            RETURN cod_ret;
        END IF;


        CALL bdisac:"informix".sp_inserta_msw_respuesta(vnumCategoria, vnumConvenio, vidSucursal, vfolioSucursal, vfechaPago, vnumTrama, vcadenaReq, vcadenaRply)
            RETURNING cod_ret, vcodigoRespuesta;
        
        IF ( cod_ret is null OR cod_ret <> '00000' ) THEN
            RETURN cod_ret;
        END IF;

        CALL bdisac:"informix".sp_obtiene_tae_catrespws(vcodigoRespuesta, vnumTrama)
            RETURNING cod_ret, vconceptoRespuesta;
        
        IF ( cod_ret is null OR cod_ret <> '00000' ) THEN
            RETURN cod_ret;
        END IF;

        CALL bdisac:"informix".sp_bitacorawstae(vnumCategoria, vnumConvenio, vidSucursal, vfolioSucursal, vfechaPago, vcodigoRespuesta, vconceptoRespuesta, vReferencia, vnumTrama)
            RETURNING cod_ret;

        IF ( cod_ret is null OR cod_ret <> '00000' ) THEN
            RETURN cod_ret;
        END IF;

        CALL bdisac:"informix".sp_obtiene_msw_validacion(vcodigoRespuesta, vnumCategoria, vnumConvenio, vnumTrama)
            RETURNING cod_ret, venviaTrama, vreversa, vcodErr, vcodErr_reversa, vencErrores;
        
        IF ( cod_ret is null OR cod_ret <> '00000' ) THEN
            RETURN cod_ret;
        END IF;

    END;

       RETURN cod_ret;
END PROCEDURE;