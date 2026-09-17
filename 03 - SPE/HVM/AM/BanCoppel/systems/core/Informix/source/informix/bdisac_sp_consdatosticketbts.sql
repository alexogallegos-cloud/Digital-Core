CREATE PROCEDURE "informix".sp_consdatosticketbts(pFolioSuc CHAR(20))

    --DATOS A REGRESAR---
    RETURNING
    CHAR(5), CHAR(11), CHAR(40), CHAR(40), CHAR(40), CHAR(40), CHAR(5), 
	CHAR(20), CHAR(1);   

    --DEFINICION DE VARIABLES--
    DEFINE sql_err           INT;
    DEFINE cCodRet           CHAR(5);
   
    DEFINE cR_First_Name     CHAR(40);
	DEFINE cR_Middle_Name    CHAR(40);
	DEFINE cR_Last_Name      CHAR(40);
	DEFINE cR_Mother_M_Name  CHAR(40);
	DEFINE cR_Identif_Type   CHAR(5);
	DEFINE cR_Identif_Nm     CHAR(20);
	DEFINE cFormaPago        CHAR(1);
	DEFINE cNumConfirmacion  CHAR(11);
	
		
        --INICIALIZACION DE VARIABLES--
    LET sql_err          = 0;
    LET cCodRet          = '00000';
	LET cR_First_Name    = "";
	LET cR_Middle_Name   = "";
	LET cR_Last_Name     = "";
	LET cR_Mother_M_Name = "";
	LET cR_Identif_Type = "";
	LET cR_Identif_Nm = "";
	LET cFormaPago = "";
	LET cNumConfirmacion = "";
	
	
    --SET DEBUG FILE TO "/respaldosbd/Dulce/sp_ConsDatosTicketBTS.out";
   -- TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet, cNumConfirmacion, cR_First_Name, cR_Middle_Name, cR_Last_Name, cR_Mother_M_Name, cR_Identif_Type, 
			cR_Identif_Nm, cFormaPago;  
        END IF;
    END EXCEPTION;

    IF NVL(pFolioSuc,'') = '' THEN
		LET cCodRet =   '00001'; --Faltan parámetros
		RETURN cCodRet, cNumConfirmacion, cR_First_Name, cR_Middle_Name, cR_Last_Name, cR_Mother_M_Name, cR_Identif_Type, 
		cR_Identif_Nm, cFormaPago;  
	END IF;

	IF EXISTS (SELECT referencia1 FROM bdisac:sac_movimientos WHERE folio_suc = pFolioSuc AND status_cancelado = "N" 
	          AND numcategoria = '07' AND numconvenio = '004') THEN
        SELECT NVL(forma_pago,''), NVL(referencia1,'')
		INTO cFormaPago, cNumConfirmacion
	    FROM bdisac:sac_movimientos 
		WHERE folio_suc = pFolioSuc
		AND numcategoria = '07' 
		AND numconvenio = '004'
		AND status_cancelado = "N";
		SET ISOLATION TO DIRTY READ;
   		IF EXISTS(SELECT confirmation_nm FROM bdisac:sac_bts_payi WHERE bank_ref_nm = pFolioSuc AND opcode = "1100" 
		           AND confirmation_nm = cNumConfirmacion) THEN
		    SELECT NVL(r_first_name,''), NVL(r_middle_name,''), NVL(r_last_name,''), NVL(r_mother_m_name,''), 
			       NVL(r_identif_type,''), NVL(r_identif_nm,'')
			INTO cR_First_Name, cR_Middle_Name, cR_Last_Name, cR_Mother_M_Name, cR_Identif_Type, cR_Identif_Nm
			FROM bdisac:sac_bts_payi 
			WHERE bank_ref_nm = pFolioSuc 
			AND opcode = "1100" 
		    AND confirmation_nm = cNumConfirmacion;
		
		ELSE		   
		    LET cCodRet =   '00003'; 
	    END IF;	
	ELSE
	    LET cCodRet =   '00002'; 
    END IF;
	--CHECAR LOS COD RET
	  
	
    RETURN cCodRet, cNumConfirmacion, cR_First_Name, cR_Middle_Name, cR_Last_Name, cR_Mother_M_Name, cR_Identif_Type, cR_Identif_Nm, cFormaPago;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para obtener datos de un movimiento de cobro de remesa para la reimpresion de ticket.',
'AUTOR : Dulce Ramirez',
'FECHA : 23/Diciembre/2010',
'Ver.  : 1.1',
'BD    : bdisac',
'VER   : 1.1';

CREATE PROCEDURE "informix".sp_consinfobtssif(cUsuario char(10))
RETURNING VARCHAR(6),VARCHAR(80),DATE,VARCHAR(5);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha           DATE;
DEFINE  vSucursal        VARCHAR(5);


BEGIN
   
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE,dFecha,vSucursal;
   END EXCEPTION;

--**************************************************************
-- By Manuel Osuna Valencia (Transaccion por Producto,Empresa)--*
-- Debug del Procedure                                        --*
 --SET DEBUG FILE TO "/tmp/manuel.out";                       --*
 --TRACE ON;                                                  --*
--**************************************************************

   LET P_COD_RET = '00000';
   LET P_MENSAJE = '';
   let vSucursal = '';
   let dFecha = '';

	--Sacar la Fecha del Sistema
	select fecha_hoy into dFecha  from bdinteg:si_fechas;
	
	select nombre into P_MENSAJE from bdinteg:si_ejecut where ejecutivo = trim(cUsuario);
	
	select valor into  vSucursal from bdisac:sac_param where cod_param = '999';
	
		
	RETURN P_COD_RET,P_MENSAJE,dFecha,vSucursal;
END;
END PROCEDURE;