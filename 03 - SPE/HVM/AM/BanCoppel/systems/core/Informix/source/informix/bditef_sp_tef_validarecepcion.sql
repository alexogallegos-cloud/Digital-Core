CREATE PROCEDURE "informix".sp_tef_validarecepcion(ptipo INTEGER, pCuenta CHAR (20) )
RETURNING
CHAR(6) 		AS cod_ret,
VARCHAR(80) 	AS desc_ret;

---DECLARACIONES
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cErrorInfo			CHAR(80);
DEFINE cCodRet				CHAR(6);
DEFINE cCodRet1				CHAR(6);
DEFINE vMensajeRet			VARCHAR(80);
DEFINE sBandera			    SMALLINT;
DEFINE cBanco 				CHAR(3);

---INICIALIZACIONES
LET iSqlErr					= 0;
LET iIsamErr				= 0;
LET cErrorInfo				= '';
LET cCodRet					= '000000';
LET cCodRet1				= '000000';
LET vMensajeRet				= 'PROCESO EXITOSO';
LET sBandera		    	= 0;
LET cBanco					= '';

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET vMensajeRet = cErrorInfo;
			RETURN cCodRet, TRIM(vMensajeRet);
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/home/sysifx/vlv/sp_tef_validarecepcion.out';
	--TRACE ON;

	-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
    IF (NVL(pCuenta,"") = "" OR NVL(ptipo,0) NOT IN (2,3)) THEN
		LET cCodRet = '000001';
		LET vMensajeRet = 'Parámetros inválidos';
    END IF;

    IF ptipo = 2 THEN --Tarjeta de débito	
			IF NOT EXISTS (SELECT banco	
							FROM bdinteg:"informix".si_bancos
							WHERE banco = (SELECT cve_banco	
							   			FROM bdicheq:"informix".sc_bines 
										WHERE bin = SUBSTR(pCuenta, 1,6) AND UPPER(creditodebito) = 'D')
 							AND flg_tef_r = '1') THEN
				LET sBandera=1;				
			END IF;	
	
	ELIF ptipo = 3 THEN --Cuenta CLABE
		SELECT banco 
		INTO cBanco 
		FROM bdinteg:"informix".si_bancos WHERE banco = SUBSTR(pCuenta,1,3)	AND flg_tef_r = '1';
		
		IF TRIM(NVL(cBanco, '')) = '' THEN		
			LET sBandera=1;
		ELIF TRIM(NVL(cBanco, '')) = '137' THEN
			LET sBandera=2;	
		END IF;	
		
	END IF;
	
	IF sBandera = 1 THEN	
		LET cCodRet = '000002';
		EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","099")
									INTO cCodRet1,vMensajeRet;	
	ELIF sBandera = 2 THEN
		LET cCodRet = '000003';
		EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret("01","573")
									INTO cCodRet1,vMensajeRet;	
	END IF;			
    
	RETURN cCodRet, TRIM(vMensajeRet);

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que valida que la cuenta sea valida para recepcion de operaciones TEF en central',
'AUTOR: Jesus Manuel Aguilar Heredia',
'BASE DE DATOS: bditef',
'FECHA: Junio 2012',
'VERSION: 20120619.1021',
'MODIFICO: Valentin Lopez Valenzuela.',
'DESCRIPCION: Se agrego una validación para no permitir realizar transferencia de envio de fondos a BANCOPPEL. (ptipo = 3) ',
'BASE DE DATOS: bditef',
'FECHA: Agosto 2012',
'VERSION: 20120809.1544';

create procedure "informix".stat_cheque (
                    pempresa    char(3),
                    pcuenta     char(20),
                    pnrocheque  integer)
       returning    char(5),    --codret
                    char(2);    --motdevol

    -- v1.0 validacion extra cuando el cheque no ha sido
    -- aplicado pero ya esta en la base de datos
    -- lalo jun10
                    
    -- v1.0 version inicial
    -- eduardo espinosa oct09
    -- devuelve el status de la cuenta/cheque

                    
    define vsqlerr      integer;
    define vcodret      char(5);
    define vmotdevol    char(2);
    define vcuenta      char(20);
    define vstatuscta   char(1);
    define vmotivo      char(2);
    define vchequestat  char(1); 
    define vcargo       char(1);
    
    let vcodret     = "000";
    let vmotdevol   = "00";
    let vcargo      = "S";

    
    
--set debug file to "/pisa/liberoltp/pisa_ftes/cecoban/stat_cheque.txt";
--trace on;
        
begin
    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vcodret,vmotdevol;
        end if
    end exception;

    --- valida que la cta/numcheque no venga vacio
    if  trim(pcuenta) = "" or pcuenta is null 
        or pnrocheque = "" or pnrocheque < 1 then
            let vcodret = "100";
            return vcodret,vmotdevol;
    end if



    -- MOTIVO 02 No tiene cuenta con nosotros el librador
    -- Valida que Exista la Cuenta de Cheques 
    -- o que si la cuenta esta cancelada (status_cta="2")
    
    select  cuenta, status_cta,motivo
    into    vcuenta, vstatuscta, vmotivo
    from    bdicheq:sc_maechq
    where   cuenta = pcuenta;
    
    
    if dbinfo("sqlca.sqlerrd2") = 0 or vstatuscta = "2" then
    
            let vmotdevol   = "02";
            return vcodret,vmotdevol;
            
    else
    
        -- cta bloqueada pero acepta cargos
        if  vstatuscta = "3" then
            select  cargo 
            into    vcargo
            from    bdicheq:sc_bloqueo
            where   codigo = vmotivo;

            if vcargo = "N" then
                let vmotdevol   = "09"; -- cta bloqueada
                return vcodret,vmotdevol;
            end if
        end if        


        
        -- cuenta bloqueada no hacer nada
        -- validar los status del cheque
        
        if vcargo = "S" then
        
            select  estado
            into    vchequestat
            from    bdicheq:sc_contch
            where   empresa = pempresa
            and     cuenta  = pcuenta
            and     numero  = pnrocheque;

            -- no encontro registros
            -- La numeración del cheque no corresponde 
            
            if dbinfo("sqlca.sqlerrd2") = 0 then 
                let vmotdevol   = "51";       
            end if

            -- activo (cheque para intentar cargarle)
            if vchequestat = "A" or vchequestat = "U" then
                -- cta OK  
            end if

            -- ya pagado
            if vchequestat = "P" or vchequestat = "M" then
                let vmotdevol   = "16";
            end if 
            
            -- presentado por camara
            if vchequestat = "N"  then
                let vmotdevol   = "18";
            end if             

            -- revocado
            if vchequestat = "R"  then
                let vmotdevol   = "08";
            end if                

            -- cancelado
            -- CHEQUE EXTRAVIADO
            if vchequestat = "C"  then
                let vmotdevol   = "52";
            end if 

            -- incompleto
            if vchequestat = "I"  then
                let vmotdevol   = "51";
            end if 

            -- destruido
            if vchequestat = "D"   then
                let vmotdevol   = "23";
            end if 
            
            -- bloqueado orden jud
            -- TENEMOS ORDEN JUDICIAL DE NO PAGAR
            if vchequestat = "J"  then
                let vmotdevol   = "07";
            end if 

            -- bloqueado autoridades
            if vchequestat = "B"  then
                let vmotdevol   = "09";
            end if 
            
            
            -- validacion extra 
            
            if exists (select c_cuenta from cce_propios_det
                        where c_cuenta = pcuenta 
                        and c_cheque = pnrocheque
				and status = '01') then
                        
                let vmotdevol   = "16";
            end if 
            
            

        end if --validar los status del cheque


                
    end if    --cuenta, sdo_actual
 

    return vcodret,vmotdevol;    
    
end

END PROCEDURE;