CREATE PROCEDURE "informix".consvalidacrednom_web(pEmpresa char(3), pCuenta char(20))

--DATOS A REGRESAR---

RETURNING

CHAR(5)  as Cod_Ret, 		--Codigo de Retorno
CHAR(20) as NumSol_PDN, 	--Numero Solicitud PDN
CHAR(4)  as Producto_PDN, 	--Producto PDN
CHAR(2)  as PDN,			--PDN
CHAR(2)  as PDN_Adeudo, 	--PDN adeudo
CHAR(20) as NumSol_AN, 		--Numero Solicitud PDN
CHAR(4)  as Producto_AN, 	--Producto PDN
CHAR(2)  as AN,				--AN
CHAR(2)  as AN_adeudo 		--AN adeudo

--DEFINICION DE VARIABLES--
DEFINE Vcod_Ret         CHAR(5);
DEFINE VnumSolicitudPDN CHAR(20);
DEFINE VnumSolicitudAN  CHAR(20);
DEFINE VnumProductoPDN  CHAR(4);
DEFINE VnumProductoAN   CHAR(4);
DEFINE VblnPDN			CHAR(2);
DEFINE VblnAN			CHAR(2);
DEFINE VblnPDN_adeudo	CHAR(2);
DEFINE VblnAN_adeudo	CHAR(2);
DEFINE VstatusCredPDN   CHAR(2);
DEFINE VstatusCredAN    CHAR(2);
DEFINE VmontoAdeudo     DECIMAL(18,2); 


--INICIALIZACION DE VARIABLES--
LET Vcod_Ret ="00001";
LET VnumSolicitudPDN= "";
LET VnumProductoPDN= "";
LET VnumSolicitudAN= "";
LET VnumProductoAN= "";
LET VblnPDN	="";		
LET VblnAN	="";
LET VblnPDN_adeudo ="";
LET VblnAN_adeudo  ="";
LET VmontoAdeudo=0;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;
	
	-- Valida que sea un producto Prestamo Directo de Nomina
       SELECT a.num_credito, b.num_producto, b.status_cred
        INTO VnumSolicitudPDN, VnumProductoPDN, VstatusCredPDN
        FROM bdicred:sd_ctascarg a
        INNER JOIN bdicred:sd_maecredcrd b
        ON a.num_credito=b.num_credito
        WHERE a.empresa=pEmpresa AND a.num_cta=pCuenta; 

        if VnumProductoPDN = "6400" then
            LET Vcod_Ret ="00000";
		--Valida si el Prestamo Directo de Nomina tiene adeudos             
            if VstatusCredPDN="AA" OR VstatusCredPDN="BA"  OR VstatusCredPDN="BT" then
                LET VblnPDN = "1";             
            end if
            if VblnPDN = "1" then
               SELECT sdo_cap_insoluto
               INTO VmontoAdeudo FROM bdicred:sd_maesdos  
               WHERE num_credito=VnumSolicitudPDN;
               IF VmontoAdeudo>0 THEN
                    LET VblnPDN_adeudo = "1";
               END IF
            end if; 
        end if;    
		
	-- Valida que sea un producto Anticipo Nomina	
		SELECT a.num_solicitud, b.num_producto,b.status_cred 
		INTO VnumSolicitudAN, VnumProductoAN,VstatusCredAN
        FROM bdisolic:ss_adn_solicitudcuenta a
        INNER JOIN bdicred:sd_maecred b
        ON a.num_solicitud=b.num_credito
        WHERE a.empresa=pEmpresa AND a.cuenta_nomina=pCuenta;  

        if VnumProductoAN = "7800" then
             LET Vcod_Ret ="00000";
		--Valida si el Anticipo de Nomina tiene adeudos 
            if VstatusCredAN="AA" OR VstatusCredAN="BA"  OR VstatusCredAN="BT"  then
                LET VblnAN = "1";
            END IF                
             
            if VblnAN = "1" then
               SELECT sdo_cap_insoluto
               INTO VmontoAdeudo FROM bdicred:sd_maesdos  
               WHERE num_credito=VnumSolicitudAN;
               IF VmontoAdeudo>0 THEN
                    LET VblnAN_adeudo = "1";    
               END IF
            end if; 
        end if;
      
        RETURN Vcod_Ret , VnumSolicitudPDN, VnumProductoPDN, VblnPDN, VblnPDN_adeudo, VnumSolicitudAN, VnumProductoAN, VblnAN, VblnAN_adeudo;
END PROCEDURE;