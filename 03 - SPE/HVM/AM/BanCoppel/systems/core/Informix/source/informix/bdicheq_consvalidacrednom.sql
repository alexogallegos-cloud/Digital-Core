CREATE PROCEDURE "informix".consvalidacrednom(pEmpresa char(3), pCuenta char(20))

--DATOS A REGRESAR---

RETURNING

char(5)  as Cod_Ret, 	--Codigo de Retorno
char(20) as NumSol_PDN, 	--Numero Solicitud PDN
char(4) as Producto_PDN, 	--Producto PDN
char(2) as PDN,	--PDN
char(2) as PDN_Adeudo, 	--PDN adeudo
char(20) as NumSol_AN, 	--Numero Solicitud PDN
char(4) as Producto_AN, 	--Producto PDN
char(2) as AN,	--AN
char(2) as AN_adeudo 	--AN adeudo

--DEFINICION DE VARIABLES--

DEFINE Vcod_Ret         char(5);
DEFINE VnumSolicitudPDN char(20);
DEFINE VnumSolicitudAN  char(20);
DEFINE VnumProductoPDN  char(4);
DEFINE VnumProductoAN   char(4);
DEFINE VblnPDN			char(2);
DEFINE VblnAN			char(2);
DEFINE VblnPDN_adeudo	char(2);
DEFINE VblnAN_adeudo	char(2);
DEFINE VstatusCredPDN   char(2);
DEFINE VstatusCredAN    char(2);
DEFINE VmontoAdeudo     decimal(18,2); 


--INICIALIZACION DE VARIABLES--

LET Vcod_Ret ="001";
LET VnumSolicitudPDN= "";
LET VnumProductoPDN= "";
LET VnumSolicitudAN= "";
LET VnumProductoAN= "";
LET VblnPDN	="";		
LET VblnAN	="";
LET VblnPDN_adeudo ="";
LET VblnAN_adeudo  ="";
LET VmontoAdeudo=0;
	
	-- Valida que sea un producto Prestamo Directo de Nomina
       SELECT a.num_credito, b.num_producto, b.status_cred
        INTO VnumSolicitudPDN, VnumProductoPDN, VstatusCredPDN
        FROM bdicred:sd_ctascarg a
        INNER JOIN bdicred:sd_maecredcrd b
        ON a.num_credito=b.num_credito
        WHERE a.empresa=pEmpresa AND a.num_cta=pCuenta; 

        if VnumProductoPDN = "6400" then
            LET Vcod_Ret ="000";
		--Valida si el Prestamo Directo de Nomina tiene adeudos             
            if VstatusCredPDN="AA" OR VstatusCredPDN="BA"  OR VstatusCredPDN="BT"
			OR VstatusCredPDN="E1" OR VstatusCredPDN="E2"  OR VstatusCredPDN="E3"
			then
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
             LET Vcod_Ret ="000";
		--Valida si el Anticipo de Nomina tiene adeudos 
            if VstatusCredAN="AA" OR VstatusCredAN="BA"  OR VstatusCredAN="BT"  
			OR VstatusCredAN="E1" OR VstatusCredAN="E2"  OR VstatusCredAN="E3"
			then
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