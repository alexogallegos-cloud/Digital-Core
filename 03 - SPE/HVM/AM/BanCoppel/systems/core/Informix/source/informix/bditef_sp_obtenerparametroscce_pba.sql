CREATE PROCEDURE "informix".sp_obtenerparametroscce_pba(pEmpresa CHAR(3),pUsuario CHAR(8))
            RETURNING 
			CHAR(5),		-- CODIGO RETORNO
            CHAR(30),       -- RAZON SOCIAL
            CHAR(45),       -- NOMBRE USUARIO                
			DATE,			-- FECHA HOY
			CHAR(100),		-- NUMERO BANCO
			VARCHAR(100),   -- IP INTERACT
			VARCHAR(100);   -- PUERTO
			
DEFINE iSqlErr       INT;
DEFINE cCodret       CHAR(5);  
DEFINE cDescripcion  CHAR(40);
DEFINE cIPInteract	 VARCHAR(100);
DEFINE cPuerto		 VARCHAR(100);
DEFINE cBanco		 CHAR(100);
DEFINE cFecha_hoy	 DATE;
DEFINE cNombre		 CHAR(45);
DEFINE cRazonSocial	 CHAR(30);

LET cCodret			= '00000';  
LET cDescripcion    ='';
LET cIPInteract	    ='';
LET cPuerto		    ='';
LET cBanco		    ='';
LET cFecha_hoy	    ='';
LET cNombre		    ='';
LET cRazonSocial	='';
LET iSqlErr         = 0;

BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cRazonSocial, cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto ;     
        END IF;
   END EXCEPTION;

	--EMPRESA
	SELECT razon_social 
	INTO cRazonSocial
	FROM bdinteg:si_empresas 	
	WHERE empresa= pEmpresa;

	--USUARIO
	SELECT nombre 
	INTO cNombre 
	FROM bdinteg:si_ejecut 	
	WHERE ejecutivo = pUsuario;

	--FECHA HOY
	SELECT fecha_hoy 
	INTO cFecha_hoy
	FROM bdinteg:si_fechas 	
	WHERE empresa = pEmpresa;

	--NUMERO BANCO PROPIO
	SELECT valor 
	INTO cBanco 
	FROM bdinteg:si_param 	
	WHERE empresa = pEmpresa 
	AND cod_param='5';

	--CARGA INTERACT IP
	SELECT valor 
	INTO cIPInteract
	FROM bditef:cce_param 	
	WHERE empresa = pEmpresa 
	AND cod_param='3';

	--CARGA INTERACT PORT
	SELECT valor 
	INTO cPuerto
	FROM bditef:cce_param 	
	WHERE empresa = pEmpresa 
	AND cod_param='4';

	IF cPuerto = '' OR cPuerto IS NULL OR cIPInteract= '' OR cIPInteract IS NULL THEN
		LET cCodret= '10000';     
	END IF;
		
	RETURN  cCodRet,cRazonSocial, cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto ;

	    
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS PARAMETROS PARA SISTEMA TEF ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100304.0943';

CREATE PROCEDURE "informix".sp_obtienebancos_pba(pBanco CHAR(3))
RETURNING CHAR(6)     AS cCodRet,
		  CHAR(3)     AS CveBanco,
		  CHAR(40)    AS Descripcion,
		  CHAR(1)     AS TipoBanco,
		  INTEGER     AS CveSIF, 
		  VARCHAR(20) AS NombreCorto,
		  CHAR(1)     AS FlagDomiR,
		  CHAR(1)     AS FlagDomiP;		  		  

    DEFINE cCodRet             CHAR(6);
    DEFINE iSql_Err            INTEGER;
    DEFINE iSam_Err            INTEGER;
    DEFINE cCveBanco           CHAR(3);  
    DEFINE cDescripcion        CHAR(40);
    DEFINE cTipoBanco		   CHAR(1);
    DEFINE iCvecesif           INTEGER;
    DEFINE vNombreCorto		   VARCHAR(20);
    DEFINE cFlgdomiR	       CHAR(1);
    DEFINE cFlgdomiP		   CHAR(1);

    LET cCodRet         = '000000';
    LET iSql_Err        = 0;
    LET iSam_Err        = 0;
    LET cCveBanco       = '';
    LET cDescripcion    = '';
    LET cTipoBanco      = ''; 
    LET iCvecesif       = 0;
    LET vNombreCorto    = '';
    LET cFlgdomiR       = '';
    LET cFlgdomiP       = '';

    SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;

    --- SET DEBUG FILE TO "/home/sysifx/vlv/sp_obtienebancos.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET iSql_Err, iSam_Err
        IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet, cCveBanco, cDescripcion, cTipoBanco, iCvecesif, vNombreCorto, cFlgdomiR, cFlgdomiP;
        END IF;
    END EXCEPTION;

    -- // SE OBTIENE INFORMACION BASICA DEL BANCO.	
    FOREACH 
        SELECT banco, descripcion, tp_banco, cvecesif, vchrnombrecorto, flg_domi_r, flg_domi_p
          INTO cCveBanco, cDescripcion, cTipoBanco, iCvecesif, vNombreCorto, cFlgdomiR, cFlgdomiP
          FROM bdinteg:"informix".si_bancos
         WHERE banco = CASE WHEN pBanco <> ''  THEN pBanco  ELSE banco END
         ORDER BY banco::INTEGER

        RETURN cCodRet, cCveBanco, cDescripcion, cTipoBanco, iCvecesif, vNombreCorto, cFlgdomiR, cFlgdomiP WITH RESUME;
    END FOREACH;

    -- // SE VERIFICA SI LA CONSULTA REGRESO INFORMACION.
    IF DBINFO("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = '000002';
        LET cDescripcion = 'No Existe Banco con esa Clave.';
        RETURN cCodRet, cCveBanco, cDescripcion, cTipoBanco, iCvecesif, vNombreCorto, cFlgdomiR, cFlgdomiP;
    END IF;

    END;
    
END PROCEDURE

DOCUMENT
'AUTOR: Valentin Lopez Valenzuela',
'FECHA CREACION: 15 de Julio del 2011',
'DESCRIPCION: Regresa todos los bancos por su clave de banco.',
'MODIFICO: Guadalupe Payan',
'FECHA MODIFICACION: 15 de Agosto del 2011',
'DESCRIPCION: Se eliminaron dos campos que no se encontraban en la tabla', 
'si_bancos productiva y se elimino la variable bandera iCont,se sustituyo por el comando: DBINFO',
'VERSION: 20110815.1046',
'BD: BDINTEG';

create procedure "informix".ins_reg_devo(
                       pempresa         char(3),
                       pcvebanco        char(3),
                       pnumcuenta       char(20),
                       pnumcheque       char(7), 
                       pmotdevo         char(2), 
                       puser_insert     char(8),
                       pfecha_insert    date)
                       RETURNING char(5),char(50);  
-- version 1.1
-- manejo del pago de TC con SBC

   DEFINE v_codret  char(5);
   DEFINE v_codretdescrip char(50);
   
   DEFINE v_fechapre    date;
   DEFINE v_numcte      char(20);
   DEFINE v_ctadepo     char(20);
   DEFINE v_monto       decimal(16,2);
   DEFINE v_sucursal    char(4);   
   DEFINE v_transacc    char(4);
   DEFINE v_ctacheq     decimal(16,0);
   DEFINE v_folio       char(16);
   DEFINE v_trans_dev   char(4);
   
   DEFINE v_trancheques char(4);
   DEFINE v_trancredito char(4);
   
   
   DEFINE sql_err,isam_err int;   
   DEFINE vrowid int;

   DEFINE vstatus_cta  char(1); 	-- JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009 
   DEFINE vcolateral, vmotivo CHAR(4);  -- JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
   DEFINE vcta_col Integer;
   DEFINE vfecha_alta date;
   DEFINE vreferencia CHAR(40); 
   DEFINE vd_numcuenta decimal(20,0);
   DEFINE vnumcuenta char(20);

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret     = "000";
   LET v_codretdescrip  = " ";
   LET vstatus_cta = " ";
   LET vcolateral= " ";
   LET vmotivo= " ";

	--set debug file to "/tmp/ins_reg_devo.out";
	--trace on;

-- ****************************************************************************
-- ins_reg_devo_bditefv2 JYDG 
-- ****************************************************************************

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF      pempresa        is null or
            pcvebanco       is null or
            pnumcuenta      is null or
            pnumcheque      is null or
            pmotdevo        is null or
            puser_insert    is null or 
            pfecha_insert   is null THEN
    
       -- datos de entrada incompletos
       
       LET v_codret = 190; 
       RETURN v_codret,v_codretdescrip; 
    END IF;

BEGIN

   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         RETURN v_codret,v_codretdescrip; 
      end if;
   end exception;

    -- obtener transacciones
    -- cheques
    
    select  numero
    into    v_trancheques
    from    bdinteg:si_transacc
    where   empresa = pempresa
    and     abreviatura = "DEPLOCALREGCC";
    
    IF v_trancheques is null THEN
        -- no existe el cliente
        LET v_codret = 195; 
        LET v_codretdescrip = "NO EXISTE TRAN CHEQUES";
        RETURN v_codret,v_codretdescrip; 
    END IF;        
   
    -- credito
    select  numero
    into    v_trancredito
    from    bdinteg:si_transacc
    where   empresa = pempresa
    and     abreviatura = "PAGOTCSBC";
    
    IF v_trancredito is null THEN
        -- no existe el cliente
        LET v_codret = 196; 
        LET v_codretdescrip = "NO EXISTE TRAN CREDITO";
        RETURN v_codret,v_codretdescrip; 
    END IF;      
	
	-- obtener la transaccion devolucion cheque de otro banco
    select  valor
    into    v_trans_dev
    from    bdicheq:sc_param
    where   empresa = pempresa
    and     codparam = "trandevobco";

    IF v_trans_dev is null or v_trans_dev = "" THEN
        LET v_codret = 198; 
        LET v_codretdescrip = "NO EXISTE TRAN DEVOTROBCO";
        RETURN v_codret,v_codretdescrip; 
    END IF; 
      
    -- obtener la fecha de presentacion mas
    -- reciente del cheque
    
    LET v_ctacheq = pnumcuenta;

    select  max(fechapresenta)
    into    v_fechapre
    from    bditef:cce_cheques_det
    where   empresa = pempresa
    and     cvebanco = pcvebanco
    and     numcuenta = v_ctacheq
    and     numcheque = pnumcheque;

    IF v_fechapre IS NULL THEN
       -- no existe en cheques_det
       LET v_codret = 191;
       LET v_codretdescrip = "NO EXISTE EL REGISTRO";
       RETURN v_codret,v_codretdescrip;     
    END IF;

    -- obtener los demas datos desde 
    -- sc_docret

	LET vd_numcuenta = pnumcuenta::decimal(20,0);
	LET vnumcuenta = vd_numcuenta;
	LET vnumcuenta = trim(vnumcuenta);
	
    select  fecha_alta,referencia,cuenta,monto_ori,sucursal,transacc
    into    vfecha_alta,vreferencia,v_ctadepo,v_monto,v_sucursal,v_transacc
    from    bdicheq:sc_docret_sbc   --MOHA
    where   empresa = pempresa
    and     banco = pcvebanco
    and     numcuenta = vnumcuenta
	and     num_chq = pnumcheque
	and     cancelado = "T";
    
    IF v_ctadepo is null or v_sucursal is null THEN
        -- no existe el cheque en sc_docret
        LET v_codret = 192; 
        LET v_codretdescrip = "NO EXISTE EL REGISTRO SC_DOCRET";
        RETURN v_codret,v_codretdescrip; 
    END IF;     

    -- obtener el nro de cliente

    -- de cheques
    IF v_transacc = v_trancheques THEN
        select  num_cte, colateral, status_cta, motivo     -- JYDG SE AGREGA 3ULTIMOS CAMPOS PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
        into    v_numcte, vcolateral, vstatus_cta, vmotivo -- JYDG SE AGREGA 3ULTIMOS CAMPOS PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
        from    bdicheq:sc_maechq
        where   empresa = pempresa
        and     cuenta = v_ctadepo;
    END IF;
 
-- JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009   
   IF vcolateral = 'S' and  vstatus_cta = 3 and vmotivo = '99' THEN
	LET vcta_col = 1;
   ELSE
	LET vcta_col = 0;
   END IF;
-- FIN JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
 
    -- de credito
    IF v_transacc = v_trancredito THEN
        select  numcte
        into    v_numcte
        from    bdicred:sd_tarjeta
        where   empresa     = pempresa
        and     num_tarjeta = v_ctadepo;
    END IF;    
  
    

    IF v_numcte is null or v_numcte = "" THEN
        -- no existe el cliente
        LET v_codret = 193; 
        LET v_codretdescrip = "NO EXISTE EL CLIENTE";
        RETURN v_codret,v_codretdescrip;  
    END IF;
     

    -- inserta el registro en la tabla de control para consulta
    -- de devoluciones desde la sucursal
    
    
--JYDG SE COMENTA EL INSERT YA QUE LO REALIZA DENTRO DEL SP bdicheq:devotrobco QUE LLAMA ABAJO MOD 20080116_1120
--    insert into cce_cheques_dev 
--            (empresa,cvebanco,numcuenta,numcheque,
--           fechapresenta,numcte,cta_deposito,
--            monto,sucursal,motivo,codigo_retorno,usuario_alta,
--            fecha_alta)
--    values  (pempresa,pcvebanco,v_ctacheq,pnumcheque,
--            v_fechapre,v_numcte,v_ctadepo,v_monto,
--            v_sucursal,pmotdevo,"000",puser_insert,
--            pfecha_insert); 
--FIN JYDG SE COMENTA EL INSERT YA QUE LO REALIZA DENTRO DEL SP bdicheq:devotrobco QUE LLAMA ABAJO MOD 20080116_1120

    -- proceso del documento y
    -- generar el cargo por comision
    
    
    LET     v_folio = puser_insert || 
            to_char(current hour to fraction,"%H%M%S") || "00";    
    
    
    -- de cheques
    IF v_transacc = v_trancheques THEN
    
        CALL    bdicheq:devotrobco(pempresa,v_sucursal,puser_insert,
                trim(v_trans_dev),trim(v_folio),trim(v_ctadepo),
                trim(pnumcheque), pmotdevo,v_monto,pcvebanco,
                "01") -- 01 moneda nacional
        RETURNING v_codret;
    
    END IF;    
    
    -- de credito
    IF v_transacc = v_trancredito THEN
    
        CALL    bdicred:devchqsbc(pempresa,trim(v_ctadepo),
                v_sucursal,puser_insert,trim(v_folio),pmotdevo,
                v_monto,pcvebanco,
                "01") -- 01 moneda nacional
        RETURNING v_codret;

	--JYDG SE AGREGA EL INSERT YA QUE NO REALIZA LA INSERCIÓN A bditef::cce_cheques_dev PARA CREDITO 20090401_1800
	insert into bditef:cce_cheques_dev 
          		(empresa,cvebanco,numcuenta,numcheque,
           		fechapresenta,numcte,cta_deposito,
           		monto,sucursal,motivo,codigo_retorno,usuario_alta,
           		fecha_alta)
		values  (pempresa,pcvebanco,v_ctacheq,pnumcheque,
		         v_fechapre,v_numcte,v_ctadepo,v_monto,
            		 v_sucursal,pmotdevo,"000",puser_insert,
            pfecha_insert); 
	--FIN JYDG SE AGREGA EL INSERT YA QUE NO REALIZA LA INSERCIÓN A bditef::cce_cheques_dev PARA CREDITO 20090401_1800
    END IF;     
    


    -- actualizar el codigo de retorno si no fue 000
    -- cuando la cuenta tiene problemas
    IF trim(v_codret) <> "000" THEN
        update  cce_cheques_dev 
        set     codigo_retorno = v_codret
        where   empresa = pempresa
        and     cvebanco = pcvebanco
        and     numcuenta = v_ctacheq
        and     numcheque = pnumcheque
        and     fechapresenta = v_fechapre;
        
        
        -- buscar la descripcion del codigo_retorno
        select  descripcion
        into    v_codretdescrip
        from    bdinteg:si_codret
        where   codigo_retorno = trim(v_codret)
        and     sistema="01";

    ELSE
-- JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
	  IF vcta_col = 0 THEN
		-- marcar el cheque como D evuelto SOLO CUANDO NO ES CUENTA COLATERAL en otro caso la deja como esta
        	update  bdicheq:sc_docret_sbc   --MOHA
		set     cancelado = "D",
	        monto = 0
        	where cuenta = v_ctadepo
			  and fecha_alta = vfecha_alta
			  and banco = pcvebanco
			  and numcuenta = vnumcuenta
			  and num_chq = pnumcheque
			  and monto_ori = v_monto;
   	  END IF;
-- FIN JYDG SE AGREGA PARA IDENTIFICAR CTA RELACIONADA 22/01/2009
    END IF;



END;    
RETURN v_codret,v_codretdescrip; 

END PROCEDURE;