CREATE PROCEDURE "informix".sp_cont_conssaldosdiariosb4(pBandera CHAR(2),pSBandera CHAR(1),pNom_tabla CHAR(100),pUsuario char(10),pDepto char(3),
					pCuentacontable char(19), pCiudad CHAR(3), pSucursal CHAR(4), pMoneda CHAR(2), pFechaContable DATE, pExt CHAR(2))
RETURNING 	     	CHAR(5)  	AS Cod_Retorno,
					CHAR(100) 	AS ColName,
					VARCHAR(3)  AS Departamento,
					VARCHAR(50) AS Nombre,
					CHAR(4)    	AS Sucursal,
					CHAR(3)    	AS Puesto,
					CHAR(30)    AS Descripcion,
					CHAR(30)    AS RazonSocial,
					DATE 		AS Fecha,
					DATETIME HOUR TO SECOND 	AS Hora,
					CHAR (13) 	AS Rfc,
					CHAR (40) 	AS Domicilio_fiscal,
					CHAR (5) 	AS Codigo_postal,
					CHAR(2) 	AS Divisa, 
					CHAR(4) 	AS Sigla, 
					CHAR(3) 	AS Cve_intl, 
					CHAR(3) 	AS Cve_oficial, 
					CHAR(3) 	AS Empresa,
					CHAR(3)		AS Clave_region,
					CHAR(40)	AS Nombre_region,
					CHAR(4) 	AS Ccmayor, 
					CHAR(2) 	AS Ccsub, 
					CHAR(2) 	AS Ccsubsub, 
					CHAR(2) 	AS Ccssubsub, 
					CHAR(2) 	AS Ccsssubsub, 
					CHAR(2) 	AS Sector,  
					CHAR(1) 	AS Naturaleza, 
					CHAR(1) 	AS Auxiliar, 
					CHAR(1) 	AS Tipo_cuenta,
					CHAR(50)	AS Sucursal_Nombre,
					SMALLINT	AS sDia, 
					MONEY(18,2) AS mSaldoiniciodia, 
					MONEY(18,2) AS mCargosdia, 
					MONEY(18,2) AS mAbonosdia, 
					MONEY(18,2) AS mSaldoactual;
					
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	CHAR(5);
DEFINE vsqlerr      	INTEGER;
DEFINE pEmpresa 		char(3);
DEFINE cTabName			CHAR(100);
DEFINE cColName 		CHAR(100);
DEFINE cColType 		CHAR(4);
DEFINE cColLength 		CHAR(4);
define vsempresa		char(3);
define vsejecutivo      char(8);
define vsnombre         char(45);
define vssucursal       char(4);
define vspuesto         char(3);
define vsdepartamento   char(3);
define vspASsword       char(80);
define vspAS_cod        char(80);
define vsnombramiento   char(20);
define vslimaut_mn      DECIMAL(16,2);
define vslimaut_dls     DECIMAL(16,2);
define vsvigencia       date;
define vsperfil         INTEGER;
define vsASistente      char(80);
define vsuser_insert    char(45);
define vsfecha_insert   DATE;
define cDescripcion		char(30);
define cRazonSocial		char(30);
DEFINE cFecha			DATE;
DEFINE cHora			DATETIME HOUR TO SECOND;

DEFINE cRfc				CHAR(13);
DEFINE cDomicilioFiscal	CHAR(40);
DEFINE cCodigoPostal	CHAR(5);
DEFINE v_sclavemoneda	CHAR(3);
DEFINE v_snombremoneda	CHAR(40);
DEFINE v_ssigla			CHAR(4);		
DEFINE v_scve_intl		CHAR(3);
DEFINE v_scve_oficial 	CHAR(3);
DEFINE v_sempresa		CHAR(3);
DEFINE cClave_region	CHAR(3);
DEFINE cNombre_region	CHAR(40);

DEFINE cCcmayor			CHAR(4); 
DEFINE cCcsub			CHAR(2);
DEFINE cCcsubsub		CHAR(2);
DEFINE cCcssubsub		CHAR(2);
DEFINE cCcsssubsub		CHAR(2); 
DEFINE cSector			CHAR(2);
DEFINE cNaturaleza		CHAR(1); 
DEFINE cAuxiliar		CHAR(1);
DEFINE cTipo_cuenta		CHAR(1);
DEFINE cSucursal_Nombre CHAR(50);

DEFINE sDia				SMALLINT; 
DEFINE mSaldoiniciodia	MONEY(18,2);
DEFINE mCargosdia		MONEY(18,2);
DEFINE mAbonosdia		MONEY(18,2);
DEFINE mSaldoactual		MONEY(18,2);

DEFINE     v_ccmayor                CHAR(4);
DEFINE     v_ccsub                  CHAR(2);
DEFINE     v_ccsubsub               CHAR(2);
DEFINE     v_ccssubsub              CHAR(2);
DEFINE     v_ccsssubsub             CHAR(2);
DEFINE     v_sector                 CHAR(2);
DEFINE     v_sucursal               CHAR(4);
DEFINE     v_nombresucursal         CHAR(40);
DEFINE     v_ccosto_orig            CHAR(4);
DEFINE     v_cta_restringida_dest   CHAR(1);
DEFINE	   iContador				INTEGER;	

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vsqlerr    = 0;
LET scod_ret = "00000";
LET pEmpresa = '001';
LET cTabName ='';
LET cColName ='';
LET cColType ='';
LET cColLength ='';

let vsempresa			 = '';		
let vsejecutivo          = '';
let vsnombre             = '';
let vssucursal           = '';
let vspuesto             = '';
let vsdepartamento       = '';
let vspASsword           = '';
let vspAS_cod            = '';
let vsnombramiento       = '';
let vslimaut_mn          = NULL;
let vslimaut_dls         = NULL;
let vsvigencia           = NULL;
let vsperfil             = NULL;
let vsASistente          = '';
let vsuser_insert        = '';
let vsfecha_insert       = NULL;
LET cDescripcion		 = '';
LET cRazonSocial		 ='';
LET cFecha 				=NULL;
LET cHora				=NULL;
LET cRfc				= "";
LET cDomicilioFiscal	= "";
LET cCodigoPostal		= "";
LET v_sclavemoneda		= "";
LET v_snombremoneda		= "";
LET v_ssigla			= "";		
LET v_scve_intl			= "";
LET v_scve_oficial		= "";
LET v_sempresa			= "";
LET cClave_region		= "";
LET cNombre_region		= "";
LET v_sucursal          = "";
LET v_nombresucursal    = "";

LET cCcmayor			= "";
LET cCcsub				= "";
LET cCcsubsub			= "";
LET cCcssubsub			= "";
LET cCcsssubsub			= "";
LET cSector				= "";
LET cNaturaleza			= "";
LET cAuxiliar			= "";
LET cTipo_cuenta		= "";
LET cTipo_cuenta		= "";
LET cSucursal_Nombre	= '';

LET sDia				= 0; 
LET mSaldoiniciodia		= 0;
LET mCargosdia			= 0;
LET mAbonosdia			= 0;
LET mSaldoactual		= 0;
LET iContador 			= 0;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
	IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual;
	END IF;
END EXCEPTION;

 --SET DEBUG FILE TO '/tmp/mfinis/sp_cont_consSaldosDiariosb4.out';
 --TRACE ON;

 -- Valida Parametros de Entrada

  IF pBandera	=''  THEN
    LET scod_ret = "00003";
    RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual;
  END IF;
  IF pBandera='1' AND pNom_tabla='' THEN
	LET scod_ret = "00003";
    RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual;
  END IF;
  IF pBandera='2' AND pSBandera='' THEN
	LET scod_ret = "00003";
    RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual;
  END IF;
  IF pBandera='2' AND (pSBandera='1' OR pSBandera='2') AND pUsuario='' THEN
	LET scod_ret = "00003";
    RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual;
  END IF;
  IF pBandera='3' AND pDepto='' THEN
	LET scod_ret = "00003";
    RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual;
  END IF;
  IF pBandera='5' AND (pUsuario='')THEN
	LET scod_ret = "00003";
    RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual;
  END IF;
  IF pBandera='11' AND (pCuentacontable='')THEN
	LET scod_ret = "00003";
    RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual;
  END IF;


 --Fin Valida Parametros de Entrada
  
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

	IF pBandera = '1' THEN
		FOREACH
			EXECUTE PROCEDURE bdicont:"informix".sp_cont_sysb4(2, pNom_tabla) -- bdicont
			INTO scod_ret,cTabName,cColName,cColType,cColLength
			return scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual WITH RESUME;
		END FOREACH;
	ELIF pBandera = '2' THEN
		IF pSBandera='1' THEN
			FOREACH
				EXECUTE PROCEDURE bdicont:"informix".sp_si_ejecutb4('3',pUsuario,'') -- OLTP
				INTO scod_ret,vsempresa, vsejecutivo, vsnombre , vssucursal     
							, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
							, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
							, vsperfil, vsASistente, vsuser_insert, vsfecha_insert
				RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual WITH RESUME;
			END FOREACH;
		ELIF pSBandera='2' THEN
			EXECUTE PROCEDURE bdicont:"informix".sp_si_ejecutb4('2',pUsuario,'') -- OLTP
			INTO scod_ret, vsempresa, vsejecutivo, vsnombre , vssucursal     
					, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
					, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
					, vsperfil, vsASistente, vsuser_insert, vsfecha_insert;
		END IF;
	ELIF pBandera='3' THEN
		FOREACH
			EXECUTE PROCEDURE bdicont:"informix".sp_si_departamentosb4('1',pDepto)
			INTO scod_ret,cDescripcion
			RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual WITH RESUME;
		END FOREACH;
	ELIF pBandera='4' THEN		
		EXECUTE PROCEDURE bdicont:"informix".sp_si_empresasb4('1',pEmpresa)
		INTO scod_ret,cRazonSocial;
	ELIF pBandera='5' THEN
		FOREACH
			EXECUTE PROCEDURE bdicont:"informix".sp_si_sucursalesb4('1',pUsuario)
			INTO scod_ret,vssucursal,vsnombre
			RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual WITH RESUME;
		END FOREACH;
	ELIF pBandera='6' THEN 
		EXECUTE PROCEDURE bdicont:"informix".sp_selfechacontable(pEmpresa)
		INTO scod_ret,cFecha,cHora;
		IF scod_ret='000' THEN	
			LET scod_ret='00000';
		END IF;
	ELIF pBandera='7' THEN 
		EXECUTE PROCEDURE bdinteg:"informix".sp_selempresa(pEmpresa)
		INTO cRazonSocial,cRfc,cDomicilioFiscal,cCodigoPostal;
	ELIF pBandera='8' THEN 
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_selmoneda(pEmpresa)
			INTO scod_ret,v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cDescripcion
			IF scod_ret='000' THEN	
				LET scod_ret='00000';
			END IF;
			RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual WITH RESUME;
		END FOREACH;
	ELIF pBandera='9' THEN
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_selciudades(pEmpresa)
			INTO scod_ret,cClave_region,cNombre_region			
			IF scod_ret='000' THEN	
				LET scod_ret='00000';
			END IF;
			RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual WITH RESUME;
		END FOREACH;
	ELIF pBandera='10' THEN
		FOREACH
			EXECUTE PROCEDURE bdinteg:"informix".sp_selcatcontable(pEmpresa)
			INTO scod_ret,cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cDescripcion, cNaturaleza, cAuxiliar, cTipo_cuenta
			IF scod_ret='000' THEN	
				LET scod_ret='00000';
			END IF;
			RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual WITH RESUME;
		END FOREACH;
	ELIF pBandera='11' THEN

			/*LET v_ccmayor      = substr(pCuentacontable,1,4);
        	LET v_ccsub        = substr(pCuentacontable,6,2);
        	LET v_ccsubsub     = substr(pCuentacontable,9,2);
        	LET v_ccssubsub    = substr(pCuentacontable,12,2);
        	LET v_ccsssubsub   = substr(pCuentacontable,15,2);
        	LET v_sector       = substr(pCuentacontable,18,2);*/

		FOREACH
			EXECUTE PROCEDURE bdicont:"informix".sp_obtenercc(pEmpresa,'',pCuentacontable,'01')
			INTO scod_ret,cSucursal_Nombre
			IF scod_ret='000' THEN	
				LET scod_ret='00000';
			END IF;

			RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
				v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
				cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual WITH RESUME;

            END FOREACH;

        	/*SELECT cta_restringida_dest
        	INTO   v_cta_restringida_dest
        	FROM   bdinteg:si_catalog
        	WHERE  ccmayor = v_ccmayor
        	AND    ccsub = v_ccsub
        	AND    ccsubsub = v_ccsubsub
        	AND    ccssubsub = v_ccssubsub
        	AND    ccsssubsub = v_ccsssubsub
        	AND    sector = v_sector;

        	IF v_cta_restringida_dest = 'N' THEN

            FOREACH
					SELECT {+INDEX bdinteg:si_sucursales idx_si_sucursales_sucursal_nombre} sucursal, nombre
                	INTO   v_sucursal, v_nombresucursal
                	FROM   bdinteg:si_sucursales
                	ORDER BY sucursal

					LET cSucursal_Nombre = v_sucursal || ' ' || v_nombresucursal;

                	RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
					v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
					cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual WITH RESUME;
            END FOREACH;
			-- 99999
        	ELSE

            FOREACH

                SELECT sucursal
                INTO   v_sucursal
                FROM   bdicont:co_cta_ccdest
                WHERE  empresa    = pEmpresa
                AND    ccmayor    = v_ccmayor
                AND    ccsub      = v_ccsub
                AND    ccsubsub   = v_ccsubsub
                AND    ccssubsub  = v_ccssubsub
                AND    ccsssubsub = v_ccsssubsub
                AND    sector     = v_sector
                ORDER BY sucursal
      
                SELECT nombre
                INTO   v_nombresucursal
                FROM   bdinteg:si_sucursales
                WHERE  empresa    = pEmpresa
                AND    sucursal = v_sucursal;*/

				/*RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
				v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
				cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,v_sucursal||" "||v_nombresucursal, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual WITH RESUME;

            END FOREACH;*/
	ELIF pBandera='12' THEN
    	IF pCiudad = '' THEN	
				LET pCiudad = null;
	  END IF;
    IF pSucursal = '' THEN	
				LET pSucursal = null;
	  END IF;
    
		FOREACH
			EXECUTE PROCEDURE bdicont:"informix".sp_selsdodias(pEmpresa,pCuentacontable,pCiudad, pSucursal, pMoneda, pFechaContable, pExt)
			INTO scod_ret, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual
			IF scod_ret='000' THEN	
				LET scod_ret='00000';
			END IF;

			LET iContador = iContador + 1;
			RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual WITH RESUME;
		END FOREACH;

		IF iContador = 0 THEN 
			LET scod_ret='00017';
			RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
			v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual;
		END IF;
	
	ELIF pBandera = '13' THEN

		DELETE {+INDEX ("informix".sw_sucursales_tmp idx_cod_retorno)} FROM "informix".sw_sucursales_tmp;

		FOREACH

		 	SELECT {+INDEX bdinteg:si_sucursales idx_si_sucursales_sucursal_nombre} sucursal, nombre
                INTO   v_sucursal, v_nombresucursal
                FROM   bdinteg:si_sucursales
                ORDER BY sucursal
			
			LET cSucursal_Nombre = v_sucursal || ' ' || v_nombresucursal;
		
			INSERT INTO "informix".sw_sucursales_tmp(cod_retorno, colname, departamento, nombre, sucursal, puesto, descripcion, razonsocial, fecha, hora, rfc, domicilio_fiscal, codigo_postal, divisa, sigla, cve_intl, cve_oficial, empresa, clave_region, nombre_region, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, naturaleza, auxiliar, tipo_cuenta, sucursal_nombre, sdia, msaldoiniciodia, mcargosdia, mabonosdia, msaldoactual) 
			VALUES('00000', '', '', '', '', '', '', '', TODAY , CURRENT	, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', cSucursal_Nombre, 0, 0, 0, 0, 0);
		
		END FOREACH;
		
	END IF;
	
	IF DBINFO('sqlca.sqlerrd2') = 0  THEN
		LET scod_ret= '00017';
		RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
		v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual;
	ELIF not(pBandera='1' OR (pBandera='2' AND pSBandera='1') OR pBandera='3' OR pBandera='5' OR pBandera='8' OR pBandera='9' OR pBandera='10' OR pBandera='11' OR pBandera='12') THEN 
		RETURN scod_ret,cColName,vsdepartamento,vsnombre,vssucursal,vspuesto,cDescripcion,cRazonSocial,cFecha,cHora,cRfc,cDomicilioFiscal,cCodigoPostal,
		v_sclavemoneda, v_ssigla, v_scve_intl, v_scve_oficial, v_sempresa,cClave_region,cNombre_region,
			cCcmayor, cCcsub, cCcsubsub, cCcssubsub, cCcsssubsub, cSector, cNaturaleza, cAuxiliar, cTipo_cuenta,cSucursal_Nombre, sDia, mSaldoiniciodia, mCargosdia, mAbonosdia, mSaldoactual;
	END IF;

END
END PROCEDURE
DOCUMENT
"AUTOR : Eder Solis Lopez",
'MODULO: Contabilidad',
"FUNCIONAMIENTO:SP padre de Contabilidad B4 de la Funcionalidad Consulta Saldos Diarios",
"FECHA : 26-12-2022",
"BD    : bdicont";

CREATE PROCEDURE "informix".sp_cont_productotransaccionb5(
				pBandera CHAR(2),
 				pSbandera CHAR(1),
				pEmpleado CHAR(8),
				pNombre CHAR(104),
				pStatus CHAR(1),
				pFuncion SMALLINT,
				pCedula SMALLINT,
				pTipo SMALLINT,
				pFuncionAnt SMALLINT,
				pCedulaAnt SMALLINT,
				pStatusAnt SMALLINT,
				pCccmayor CHAR(10),
				pCccsub CHAR(10),
				pCccsubsub CHAR(10),
				pCccsssub CHAR(10),
				pCccssssub CHAR(10),
				pCsector CHAR(10),				
				pAccmayor CHAR(10),
				pAccsub CHAR(10),
				pAccsubsub CHAR(10),
				pAccsssub CHAR(10),
				pAccssssub CHAR(10),
				pAsector CHAR(10),
				pSistema CHAR(10),
				pSecuencia CHAR(10),
				pTransaccion CHAR(10),
				pProducto CHAR(10),
				pDescripcion CHAR(50)
			)
RETURNING 	    CHAR(5)   AS Cod_Retorno,
				CHAR(100) AS dato1,
				CHAR(100) AS dato2,
				CHAR(100) AS dato3,
				CHAR(10) AS dato4,
				CHAR(10) AS dato5,
				CHAR(10) AS dato6,
				CHAR(10) AS dato7,
				CHAR(10) AS dato8,
				CHAR(10) AS dato9,
				CHAR(10) AS dato10,
				CHAR(10) AS dato11,
				CHAR(10) AS dato12,
				CHAR(10) AS dato13,
				CHAR(10) AS dato14,
				CHAR(10) AS dato15,
				CHAR(10) AS dato16,
				CHAR(10) AS codigo,
				CHAR(200) AS descProd,
				CHAR(3) AS sistema, 
				CHAR(35) AS descripcion,
				CHAR(4) AS producto, 
				CHAR(4) AS transaccion,
				CHAR(50) AS descTran,
				CHAR(1) AS naturaleza,
				INTEGER AS secuencia, 
				CHAR(10) AS c_ccmayor, 
				CHAR(10) AS c_ccsub, 
				CHAR(10) AS c_ccsubsub, 
				CHAR(10) AS c_ccsssub, 
				CHAR(10) AS c_ccssssub, 
				CHAR(10) AS c_sector, 
				CHAR(10) AS a_ccmayor, 
				CHAR(10) AS a_ccsub, 
				CHAR(10) AS a_ccsubsub, 
				CHAR(10) AS a_ccsssub, 
				CHAR(10) AS a_ccssssub, 
				CHAR(10) AS a_sector,
				CHAR(4) AS numero
					;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	CHAR(5);
DEFINE vsqlerr      	INTEGER;
DEFINE cDato1 CHAR(100);
DEFINE cDato2_2 CHAR(100);
DEFINE cDato3 CHAR(100);
DEFINE cDato4 CHAR(10);
DEFINE cDato5 CHAR(10);
DEFINE cDato6 CHAR(10);
DEFINE cDato7 CHAR(10);
DEFINE cDato8 CHAR(10);
DEFINE cDato9 CHAR(10);
DEFINE cDato10 CHAR(10);
DEFINE cDato11 CHAR(10);
DEFINE cDato12 CHAR(10);
DEFINE cDato13 CHAR(10);
DEFINE cDato14 CHAR(10);
DEFINE cDato15 CHAR(10);
DEFINE cDato16 CHAR(10);
DEFINE cCodigo CHAR(10);
DEFINE cDescProd CHAR(200);
DEFINE cDescripcion CHAR(35);
DEFINE cSistema CHAR(3);
DEFINE cProducto CHAR(4);
DEFINE cTransaccion CHAR(4);
DEFINE cDescTran CHAR(50);
DEFINE cNaturaleza CHAR(1);
DEFINE iSecuencia INTEGER;
DEFINE cCccmayor CHAR(10);
DEFINE cCccsub CHAR(10);
DEFINE cCccsubsub CHAR(10);
DEFINE cCccsssub CHAR(10);
DEFINE cCccssssub CHAR(10);
DEFINE cCsector CHAR(10);
DEFINE cAccmayor CHAR(10);
DEFINE cAccsub CHAR(10);
DEFINE cAccsubsub CHAR(10);
DEFINE cAccsssub CHAR(10);
DEFINE cAccssssub CHAR(10); 
DEFINE cAsector CHAR(10);
DEFINE cNumero CHAR(4);
DEFINE iregistros INTEGER;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vsqlerr    = 0;
LET scod_ret = "00000";
LET cDato1 = '';
LET cDato2_2 = '';
LET cDato3 = '';
LET cDato4 = '';
LET cDato5 = '';
LET cDato6 = '';
LET cDato7 = '';
LET cDato8 = '';
LET cDato9 = '';
LET cDato10 = '';
LET cDato11 = '';
LET cDato12 = '';
LET cDato13 = '';
LET cDato14 = '';
LET cDato15 = '';
LET cDato16 = '';
LET cCodigo = '';
LET cDescProd = '';
LET cSistema = '';
LET cDescripcion = '';
LET cProducto = '';
LET cTransaccion = '';
LET cDescTran = '';
LET cNaturaleza = '';
LET iSecuencia = 0;
LET cCccmayor = '';
LET cCccsub = '';
LET cCccsubsub = '';
LET cCccsssub = '';
LET cCccssssub = '';
LET cCsector = '';
LET cAccmayor = '';
LET cAccsub = '';
LET cAccsubsub = '';
LET cAccsssub = '';
LET cAccssssub = '';
LET cAsector = '';
LET cNumero = '';
LET iregistros = 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
	IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo, cDescProd, cSistema, cDescripcion,
					cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector,
					cNumero ;
	END IF;
END EXCEPTION;


 -- Valida Parametros de Entrada

  IF pBandera	='' OR
	(pBandera='1' AND (pEmpleado = '' OR pNombre = '' OR pStatus = '' OR pFuncion IS NULL OR  pCedula IS NULL OR  pTipo  IS NULL OR pFuncionAnt IS NULL OR pCedulaAnt IS NULL)) OR
	((pBandera='2') AND (pSbandera = '' OR pCccmayor = '' OR pCccsub = '' OR pCccsubsub = '' OR pCccsssub = '' OR pCccssssub = '' OR pCsector = '' OR 
		pAccmayor = '' OR pAccsub = '' OR  pAccsubsub = '' OR pAccsssub = '' OR pAccssssub = '' OR  pAsector = '' OR pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto  = '')) OR
	((pBandera='3' OR pBandera='5' OR pBandera='8') AND (pSistema = '')) OR
	(pBandera='4' AND (pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto  = '')) OR
	((pBandera='7') AND (pSistema = '' OR pSecuencia = '' OR pTransaccion = '' OR pProducto = ''))
  THEN
    LET scod_ret = "00003";
    RETURN scod_ret,cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo, cDescProd, cSistema, cDescripcion,
					cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector,
					cNumero ;
  END IF;

  --SET DEBUG FILE TO '/tmp/mfinis/sp_cont_productoTransaccionb5.out';
  --TRACE ON;
 
 --Fin Valida Parametros de Entrada
  
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

	IF pBandera = '1' THEN
		EXECUTE PROCEDURE bdicnweb:"informix".sp_registractualizacelulascclb5(pEmpleado, pNombre, pStatus,pFuncion, pCedula, pTipo, pFuncionAnt, pCedulaAnt, pStatusAnt)
		INTO scod_ret;
	ELIF pBandera = '2' THEN
		EXECUTE PROCEDURE bdicnweb:"informix".sp_ris_actualizainsertaprodtransaccionb5(pSbandera,
																						pCccmayor, pCccsub, pCccsubsub, pCccsssub, pCccssssub, pCsector, 
																						pAccmayor, pAccsub, pAccsubsub, pAccsssub, pAccssssub, pAsector,
																						pSistema, pSecuencia, pTransaccion, pProducto,pEmpleado)
		INTO scod_ret;	
	ELIF pBandera='3' THEN
		--Se agrego un for each
		FOREACH
			EXECUTE PROCEDURE bdicnweb:"informix".sp_ris_consultacriteriostransaccionesb5(pSistema, pProducto, pTransaccion, pDescripcion,pEmpleado)
			INTO scod_ret,cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo, cDescProd
			
			LET cTransaccion = SUBSTR(cDato3,2,4);
			LET cDescTran = pDescripcion;
			LET cSistema = pSistema;
			LET cProducto = pProducto;


			RETURN scod_ret,cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo, TRIM(cDescProd), cSistema, cDescripcion,
					cProducto, cTransaccion, TRIM(cDescTran), cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector,
					cNumero WITH RESUME;
			
			END FOREACH;
	ELIF pBandera='4' THEN
		EXECUTE PROCEDURE bdicnweb:"informix".sp_ris_consultaprodtransaccionb5(pSistema, pSecuencia, pTransaccion, pProducto)
		INTO scod_ret;
		
		IF scod_ret = '00000' THEN
			LET cNumero = "1";
		ELIF scod_ret = '99999' THEN
			LET cNumero = "0";
			LET scod_ret = '00000';
		END IF

	ELIF pBandera='5' THEN
		FOREACH
			EXECUTE PROCEDURE bdicnweb:"informix".sp_ris_consultaproductosb5(pSistema,pEmpleado)
			INTO scod_ret, cCodigo, cDescProd
			
			RETURN scod_ret,cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo, cDescProd, cSistema, cDescripcion,
					cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector,
					cNumero WITH RESUME;
		END FOREACH;
	ELIF pBandera='6' THEN
		FOREACH
			EXECUTE PROCEDURE bdicnweb:"informix".sp_ris_consultasistemasb5()
			INTO scod_ret, cSistema, cDescripcion
			RETURN scod_ret,cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo, cDescProd, cSistema, cDescripcion,
					cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector,
					cNumero WITH RESUME;
		END FOREACH;
	ELIF pBandera='7' THEN
		EXECUTE PROCEDURE bdicnweb:"informix".sp_ris_consultatransaccionb5(pSistema, pSecuencia, pTransaccion, pProducto)
		INTO scod_ret, cSistema, cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector, cDescProd;

	ELIF pBandera='8' THEN
		FOREACH
			EXECUTE PROCEDURE bdicnweb:"informix".sp_ris_consultatransaccionesb5(pSistema)
			INTO scod_ret,cNumero, cDescripcion, cNaturaleza
			RETURN scod_ret,cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo, cDescProd, cSistema, cDescripcion,
					cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector,
					cNumero WITH RESUME;
		END FOREACH;

	ELIF pBandera = '9' THEN
		FOREACH
			EXECUTE PROCEDURE bdicnweb:"informix".sp_ris_consultacatalogo(pEmpleado, pSistema, pCccmayor,pCccsub ,pCccsubsub ,pCccsssub ,pCccssssub ,pCsector)
			INTO scod_ret, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cDescripcion
			RETURN scod_ret,cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo, cDescProd, cSistema, cDescripcion,
					cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector,
					cNumero WITH RESUME;

		END FOREACH;
	END IF;
	
	IF DBINFO('sqlca.sqlerrd2') = 0  THEN
		LET scod_ret= '00017';
		RETURN scod_ret,cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo, cDescProd, cSistema, cDescripcion,
					cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector,
					cNumero;
	ELIF not (pBandera='5' OR pBandera='6' OR pBandera='8' OR pBandera = '3' OR pBandera = '9') THEN
		RETURN scod_ret,cDato1, cDato2_2, cDato3, cDato4, cDato5, cDato6, cDato7, cDato8, cDato9, cDato10, cDato11, cDato12, cDato13, cDato14, cDato15, cDato16, cCodigo, cDescProd, cSistema, cDescripcion,
					cProducto, cTransaccion, cDescTran, cNaturaleza, iSecuencia, cCccmayor, cCccsub, cCccsubsub, cCccsssub, cCccssssub, cCsector, cAccmayor, cAccsub, cAccsubsub, cAccsssub, cAccssssub, cAsector,
					cNumero;
	END IF;

END
END PROCEDURE
DOCUMENT
"AUTOR : Eder Solis Lopez",
'MODULO: Contabilidad',
"FUNCIONAMIENTO:SP padre de Contabilidad B5 de la Funcionalidad â Producto Transaccion",
"FECHA : 31-01-2023",
"BD    : bdicont";

CREATE PROCEDURE "informix".sp_cont_cargamovimientob3(pBandera CHAR(2),pSBandera CHAR(1),pNomArchivo CHAR(100),pFecha DATE,pCve_Usuario CHAR(8),pContrasena CHAR(6),
	pImporte MONEY,pProceso CHAR(20),pCodigo CHAR(3),pCc_orig CHAR(4), pFecha_captura DATE, pCuenta_mayor CHAR(4), pSubcta CHAR(2), pSubsubcta CHAR(2), pSubsubsubcta CHAR(2), 
				pSubsubsubsubcta CHAR(2), pSector CHAR(2), pRegion CHAR(3), pSucursal CHAR(4), pNum_auxiliar CHAR(12), pFecha_valida DATE, pMoneda CHAR(2), pNaturaleza CHAR(1), 
				pConcepto CHAR(80), pControlPoliza INTEGER)
				
  
RETURNING 	     	CHAR(5)  AS cod_Retorno,
					CHAR(50) AS valor,
					INTEGER AS num_Reg,
					CHAR(4) AS dias_Retroact,
					DATE AS fecha,
					DATE AS fechaCaptura,
					CHAR(8) AS usuario,
					CHAR(2) AS moneda,
					CHAR(4) AS costoOrig,
					MONEY as importe,
					INTEGER AS controlPoliza,
					CHAR(4) AS sucursal,
					CHAR(6) AS clave_autorizacion,
					CHAR(62) AS cuentaContable,
					CHAR(53) AS descError,
					CHAR(10) AS lineareg ;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	CHAR(5);
DEFINE vsqlerr      	INTEGER;

DEFINE cValor 		CHAR(50);
DEFINE cNumReg		INTEGER;
DEFINE cDiasRetroact CHAR(4);
DEFINE cFecha		DATE;
DEFINE cFechaCaptura DATE;
DEFINE cUsuario		CHAR(8);
DEFINE cMoneda		CHAR(2);
DEFINE cCostoOrig	CHAR(4);
DEFINE cImporte		MONEY;
DEFINE cControlPoliza INTEGER;
DEFINE cSucursal 	CHAR(4);
DEFINE pClave_autorizacion CHAR(6);
DEFINE dDiaFeriado DATE;
DEFINE cDescDiaFeriado CHAR(30);
DEFINE cLaborableSN CHAR(1);
DEFINE cCuentaContable CHAR(62);
DEFINE cDescError CHAR(53);
DEFINE iCodigoint INTEGER;
DEFINE iLineaReg CHAR(10);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vsqlerr    = 0;
LET scod_ret = "00000";

LET cValor			='';
LET cNumReg			=0;
LET cDiasRetroact	='';
LET cFecha			='';
LET cFechaCaptura	='';
LET cUsuario		='';
LET cMoneda			='';
LET cCostoOrig		='';
LET cImporte		=0;
LET cControlPoliza 	=0;
LET cSucursal		='';
LET pClave_autorizacion = '';
LET dDiaFeriado = '';
LET cDescDiaFeriado = '';
LET cLaborableSN = '';
LET cCuentaContable = '';
LET cDescError = '';
LET iCodigoint = 0;
LET iLineaReg = '0';

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN

	ON EXCEPTION SET vsqlerr
		IF vsqlerr != 0 THEN
		  LET scod_ret=vsqlerr;
		  RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
		END IF;
	END EXCEPTION;


	--SET DEBUG FILE TO '/tmp/mfinis/sp_cont_cargamovimientob3.out';
	--TRACE ON;
	
 -- Valida Parametros de Entrada

	IF pBandera	=''  THEN
		LET scod_ret = "00003";
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;
	IF (pBandera ='2') AND (pNomArchivo='' OR pFecha is null) THEN
		LET scod_ret = "00003";
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;
	IF (pBandera ='3' AND pSBandera='') OR (pBandera ='3' AND (pSBandera='1' OR pSBandera='4') AND (pCve_Usuario='')) THEN
		LET scod_ret = "00003";
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;
	--antes 5
	IF (pBandera ='3' AND pSBandera='') OR (pBandera ='3' AND pSBandera='2' AND ( pCve_Usuario='')) THEN 
		LET scod_ret = "00003";
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;
	--antes 6
	IF (pBandera ='3' AND pSBandera='') OR (pBandera ='3' AND pSBandera='3' AND (pFecha is null OR pCve_Usuario='')) THEN
		LET scod_ret = "00003";
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;

	IF (pBandera ='5') AND (pFecha is null OR pCve_Usuario='' OR pNomArchivo='') THEN
		LET scod_ret = "00003";
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;
	IF (pBandera ='6') AND (pFecha is null OR pCve_Usuario='' OR pContrasena='' OR pImporte='') THEN
		LET scod_ret = "00003";
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;
	IF (pBandera ='7') AND ( pFecha is null OR pProceso='' OR pCodigo='' ) THEN
		LET scod_ret = "00003";
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;
	IF (pBandera ='8') AND ( pCc_orig='' OR pCve_Usuario='' OR pFecha_captura='' OR pCuenta_mayor='' OR pSubcta='' OR pSubsubcta='' OR pSubsubsubcta='' OR  
				pSubsubsubsubcta='' OR pSector='' OR pRegion='' OR pSucursal='' OR pNum_auxiliar='' OR pFecha_valida='' OR pMoneda='' OR pNaturaleza='' OR pImporte='' OR 
				pConcepto='') THEN
		LET scod_ret = "00003";
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;
	IF (pBandera ='10') AND (pFecha_captura='' OR pCve_Usuario='' OR pContrasena='' OR pImporte='') THEN 
		LET scod_ret = "00003";
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;

	IF (pBandera ='13') AND ( pCve_Usuario='' OR pControlPoliza='' OR pFecha_captura='') THEN
		LET scod_ret = "00003";
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;

 --Fin Valida Parametros de Entrada
 
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

	IF pBandera = '1' THEN
		
		SELECT valor 
		into cValor
		from bdinteg:"informix".si_param
		WHERE descripcion = 'IP_HUELLA';
	ELIF pBandera = '2' THEN
		EXECUTE PROCEDURE bdicont:"informix".valida_archivo_importa(pNomArchivo,pFecha)
		INTO scod_ret;
		IF scod_ret='000' THEN 
			LET scod_ret='00000'; 
		END IF;
	ELIF pBandera = '3' AND pSBandera='1' THEN
		EXECUTE PROCEDURE bdicont:"informix".sp_cont_co_integracionb3('1',pCve_Usuario,'')
		INTO scod_ret,cNumReg,cValor,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte;
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	
	ELIF pBandera = '3' AND pSBandera='2' THEN --varios ***** --antes 5
		FOREACH
			EXECUTE PROCEDURE bdicont:"informix".sp_cont_co_integracionb3('2',pCve_Usuario,'')
			INTO scod_ret,cNumReg,cValor,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte
			
			
			RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg WITH RESUME;
		END FOREACH;

	ELIF pBandera = '3' AND pSBandera='3' THEN --antes 6
		EXECUTE PROCEDURE bdicont:"informix".sp_cont_co_integracionb3('3',pCve_Usuario,pFecha)
		INTO scod_ret,cNumReg,cValor,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte;
	
	ELIF pBandera = '3' AND pSBandera='4' THEN --antes 16
		EXECUTE PROCEDURE bdicont:"informix".sp_cont_co_integracionb3('4',pCve_Usuario,'')
		INTO scod_ret,cNumReg,cValor,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte;
		
	ELIF pBandera = '4' THEN
		SELECT dias_retroact 
		INTO cDiasRetroact
		FROM bdicont:"informix".co_param
		WHERE empresa = '001';

		
	ELIF pBandera = '5' THEN

			DELETE FROM bdicont:"informix".sw_verificastatuscarga_archcont WHERE usuario_insert = pCve_Usuario;
			INSERT INTO bdicont:"informix".sw_verificastatuscarga_archcont VALUES (0,pCve_Usuario,'I','N','',0);
		
			EXECUTE PROCEDURE bdicont:"informix".importa(pFecha, '001', pNomArchivo, pCve_Usuario)
			INTO scod_ret,cControlPoliza;
            COMMIT;

		IF NVL(scod_ret,'') <> '000' THEN 
			LET scod_ret = '99999';
			UPDATE bdicont:"informix".sw_verificastatuscarga_archcont
			SET status = 'E', error_proceso ='S', error = scod_ret, numpoliza = cControlPoliza
			WHERE usuario_insert = pCve_Usuario;
			LET cValor = 'E';

            DELETE FROM bdicont:"informix".co_integracion where usuario_int = pCve_Usuario;
		ELSE 
			LET scod_ret = '00000';
			UPDATE bdicont:"informix".sw_verificastatuscarga_archcont
			SET status = 'T', error_proceso ='N', error = scod_ret, numpoliza = cControlPoliza
			WHERE usuario_insert = pCve_Usuario;
			LET cValor = 'T';

			/*ELIMINACIÃN DE INFORMACIÃN */
			DELETE FROM bdicont:"informix".co_integracion where usuario_int = pCve_Usuario;
		END IF;	

		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;

	ELIF pBandera = '6' THEN
		update bdicont:"informix".co_clv_retroact  
		set estatus_uso = 'S' 
		where clave_autorizacion =pContrasena and fecha_captura = pFecha and usuario_solicita = pCve_Usuario and estatus_uso = 'N' and importe =pImporte;
	ELIF pBandera = '7' THEN
		EXECUTE PROCEDURE bdicont:"informix".contproc('001' , pFecha, pProceso, pCodigo);
	ELIF pBandera = '8' THEN
		EXECUTE PROCEDURE bdicont:"informix".insertarcointegracion('001', pCc_orig, pCve_Usuario, pFecha_captura, pCuenta_mayor, pSubcta, pSubsubcta, pSubsubsubcta, 
				pSubsubsubsubcta, pSector, pRegion, pSucursal, pNum_auxiliar, pFecha_valida, pMoneda, pNaturaleza, pImporte, pConcepto, pCve_Usuario)
		INTO scod_ret;
		IF scod_ret='000' THEN LET scod_ret='00000'; END iF;
	ELIF pBandera = '9' THEN
		SELECT valor 
		into cValor
		from bdicont:"informix".co_vbparam 
		WHERE desc_campo = 'importa' OR desc_campo= 'importa_ftp_ip' OR desc_campo= 'importa_ftp_usuario' OR desc_campo= 'importa_ftp_passwd';
	ELIF pBandera = '10' THEN
		Select sucursal 
		into cSucursal
		From bdinteg:"informix".si_ejecut
		Where empresa = '001' and ejecutivo = pCve_Usuario;
		
		IF NVL(cSucursal,'') <> '' THEN
			SELECT clave_autorizacion 
			INTO pClave_autorizacion
			FROM bdicont:"informix".co_clv_retroact 
			WHERE fecha_captura = pFecha_captura AND usuario_solicita = pCve_Usuario AND clave_autorizacion = pContrasena AND estatus_uso = 'N' 
			AND importe = pImporte;
			
			IF NVL(pClave_autorizacion,'') = '' THEN
				LET scod_ret = '00000';
				LET pClave_autorizacion = '';
				
				RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
			END IF;
		END IF;
	ELIF pBandera = '12' THEN
			SELECT fecha_hoy 
			INTO cFecha 
			FROM bdicont:"informix".co_fechas 
			WHERE empresa = '001';

	ELIF pBandera = '13' THEN
		DELETE 
		FROM bdicont:"informix".co_poliza
		WHERE usuario = pCve_Usuario AND control_poliza =  pControlPoliza AND fecha_captura =pFecha_captura  AND empresa = '001';
	ELIF pBandera = '14' THEN
		EXECUTE PROCEDURE bdinteg:sp_validardiaferiado('001', pFecha)
		INTO scod_ret, dDiaFeriado, cDescDiaFeriado, cLaborableSN;
		
		IF NVL(scod_ret,'') = '00002' AND NVL(cLaborableSN,'') = 'N' THEN 
			LET scod_ret = '00000';
			LET cNumReg = 1;
		ELSE
			LET cNumReg = 0;
			LET scod_ret = '00000';
		END IF;
	ELIF pBandera = '15' THEN

		FOREACH
			SELECT a.secuencia, a.empresa, a.usuario, a.fecha_captura, a.fecha_captura, a.auxiliar, 
			CASE WHEN NVL(a.auxiliar,'') = '' THEN (TRIM(a.ccmayor)||' '||TRIM(a.ccsub)||' '||TRIM(a.ccsubsub)||' '||TRIM(a.ccssubsub)||' '||TRIM(a.ccsssubsub)||' '||TRIM(a.sector))
			ELSE TRIM(a.ccmayor)||' '||TRIM(a.ccsub)||' '||TRIM(a.ccsubsub)||' '||TRIM(a.ccssubsub)||' '||TRIM(a.ccsssubsub)||' '||TRIM(a.sector)||' '||TRIM(a.auxiliar) END, 
			cod_ret||' '||b.descripcion 
			INTO cNumReg, cDiasRetroact, cUsuario, cFecha, cFechaCaptura, cValor, cCuentaContable, cDescError
			FROM bdicont:co_auditerr AS a 
			INNER JOIN bdinteg:"informix".si_codret AS b ON b.codigo_retorno = a.cod_ret 
			WHERE a.usuario = pCve_Usuario AND sistema = '07'

			LET cControlPoliza = cControlPoliza + 1;

			RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg WITH RESUME;
		END FOREACH;
	ELIF pBandera = '16' THEN
		DELETE FROM bdicont:co_auditerr where usuario = pCve_Usuario;
		SELECT razon_social
		INTO cValor
		FROM bdinteg:si_empresas WHERE empresa = '001';

	ELIF pBandera = '17' THEN-- 17

			EXECUTE PROCEDURE bdicont:"informix".sp_cont_verificastatus_cargaarchivo(pCve_Usuario, '1')
			INTO scod_ret, cDiasRetroact, cMoneda, cUsuario, cControlPoliza, iLineaReg;

	ELIF pBandera = '18' THEN
		EXECUTE PROCEDURE bdicont:"informix".sp_cargarchivomovimiento_b3(pSBandera,pCve_Usuario , pConcepto , pNomArchivo , pFecha ) 
		INTO scod_ret, cValor;
		COMMIT;
	END IF;

	IF pBandera = '15' AND cControlPoliza = '0' THEN
		LET scod_ret = '00017';
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;
	
	IF DBINFO('sqlca.sqlerrd2') = 0 AND NOT(pBandera = '7') THEN
		LET scod_ret= '00017';
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	ELIF not(pBandera = '3' AND pSBandera='2' OR pBandera = '15') THEN
		RETURN scod_ret,cValor,cNumReg,cDiasRetroact,cFecha,cFechaCaptura,cUsuario,cMoneda,cCostoOrig,cImporte,cControlPoliza,cSucursal,pClave_autorizacion,cCuentaContable,cDescError, iLineaReg;
	END IF;
	
END
END PROCEDURE
DOCUMENT
"AUTOR : Eder Solis Lopez",
'MODULO: Contabilidad',
"FUNCIONAMIENTO:SP padre de Contabilidad B3 de la Funcionalidad â Contabilidad Carga Movimiento",
"FECHA : 17-11-2022",
"AUTOR : JosÃ© Antonio RamÃ­rez Franco",
"FECHA : 17-11-2023",
"MODIFICACION: Se aÃ±ade una nueva bandera NÂ° 18 para la carga y validacion del archivo",
"AUTOR : JosÃ© Antonio RamÃ­rez Franco",
"FECHA : 08-08-2024",
"MODIFICACION: Se actualiza la bandera 17 para que retorne el campo de nÃºmero de linea correspondiente a donde se encuentre un error en las validaciones del archivo.",
"BD    : bdicont";

CREATE PROCEDURE "informix".sp_cont_catalogob3(pTipo_cuenta CHAR(1))
	RETURNING 	CHAR(5) AS codret, 
				CHAR(10) AS ccmayor, 
				CHAR(10) AS ccsub, 
				CHAR(10) AS ccsubsub, 
				CHAR(10) AS ccssubsub,
				CHAR(10) AS ccsssubsub, 
				CHAR(10) AS sector, 
				CHAR(50) as nombre;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotalRegistros INTEGER;
	DEFINE Cccmayor CHAR(10);
	DEFINE Cccsub CHAR(10);
	DEFINE Cccsubsub CHAR(10);
	DEFINE Cccssubsub CHAR(10);
	DEFINE Cccsssubsub CHAR(10);
	DEFINE cSector CHAR(10);
	DEFINE cNombre CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotalRegistros = 0;
	LET Cccmayor = '';
	LET Cccsub = '';
	LET Cccsubsub = '';
	LET Cccssubsub = '';
	LET Cccsssubsub = '';
	LET cSector = '';
	LET cNombre = '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, Cccmayor, Cccsub, Cccsubsub, Cccssubsub, Cccsssubsub, cSector, cNombre;
		END EXCEPTION
		
		IF pTipo_cuenta =''  THEN 
			LET cCodRet = '00003';		
			RETURN cCodRet, Cccmayor, Cccsub, Cccsubsub, Cccssubsub, Cccsssubsub, cSector, cNombre;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/Eduardo/sp_cont_catalog.out';
		--TRACE ON;
		
		--Se define la consulta y almacena en las variables
		FOREACH
			SELECT ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, nombre   
			INTO Cccmayor, Cccsub, Cccsubsub, Cccssubsub, Cccsssubsub, cSector, cNombre
			FROM bdinteg:"informix".si_catalog
			WHERE empresa = '001' AND tipo_cuenta = pTipo_cuenta
			LET iTotalRegistros = iTotalRegistros + 1;
			RETURN cCodRet, Cccmayor, Cccsub, Cccsubsub, Cccssubsub, Cccsssubsub, cSector, cNombre WITH RESUME;
		END FOREACH;
		
		--termina la consulta
		
		IF iTotalRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, Cccmayor, Cccsub, Cccsubsub, Cccssubsub, Cccsssubsub, cSector, cNombre;
		END IF;		
		
	END
	
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Avila PÃ©rez Tagle',
'FECHA: 23/11/2022',
'MODULO: CONTABILIDAD',
'DESCRIPCION: SPL encargado de recuperar el catalogo';

CREATE PROCEDURE "informix".sp_cont_divisasb4()
	RETURNING 	CHAR(5) AS codret, 
				CHAR(2) AS divisa, 
				CHAR(30) AS descripcion;
				
	DEFINE cCodRet CHAR(5);
	DEFINE ISqlErr INTEGER;
	DEFINE cDivisa CHAR(2);
	DEFINE cDescripcion CHAR(30);
	DEFINE iTotalRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET ISqlErr = 0;
	LET cDivisa = '';
	LET cDescripcion = '';
	LET iTotalRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cDivisa, cDescripcion;
		END EXCEPTION
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cont_divisasb4.out';
		--TRACE ON;
		
		--Se define la consulta		
		FOREACH
			SELECT divisa, descripcion 
			INTO cDivisa, cDescripcion
			FROM bdinteg:"informix".si_divisas 
			WHERE empresa = '001'
		
			RETURN cCodRet, cDivisa, cDescripcion WITH RESUME;
		END FOREACH;
		--se termina la consulta
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00017';
			RETURN cCodRet, cDivisa, cDescripcion;
		END IF;
		
	END
	
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Avila PÃÂÃÂ©rez Tagle',
'FECHA: 23/11/2022',
'MODULO: CONTABILIDAD',
'DESCRIPCION: SPL encargado de recuperar la divisa correspondiente a la empresa';

CREATE PROCEDURE "informix".sp_cont_empresasb3(pBandera CHAR(1))
	RETURNING 	CHAR(5) AS codret, 
				CHAR(3) AS empresa, 
				CHAR(30) AS razon_social;
				
	DEFINE cCodRet CHAR(5);
	DEFINE ISqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRazon_social CHAR(30);
	DEFINE iTotalRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET ISqlErr = 0;
	LET cEmpresa = '';
	LET cRazon_social = '';
	LET iTotalRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEmpresa, cRazon_social;
		END EXCEPTION
		
		IF pBandera = ''  THEN 
			LET cCodRet = '00003';		
			RETURN cCodRet, cEmpresa, cRazon_social;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cont_empresas.out';
		--TRACE ON;
		
		--Se define la consulta		
		IF pBandera = '1' THEN
			SELECT empresa, razon_social 
			INTO cEmpresa, cRazon_social
			FROM bdinteg:"informix".si_empresas
      WHERE empresa = '001';
		END IF;
		
		IF pBandera = '2' THEN
			SELECT empresa, razon_social  
			INTO cEmpresa, cRazon_social
			FROM bdinteg:"informix".si_empresas
			WHERE empresa = '001';
		END IF;
		--se termina la consulta
		IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cEmpresa, cRazon_social;
		END IF;		
		
		RETURN cCodRet, cEmpresa, cRazon_social;
		
	END
	
END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Avila PÃÂ©rez Tagle',
'FECHA: 23/11/2022',
'MODULO: CONTABILIDAD',
'DESCRIPCION: SPL encargado de recuperar la empresa y razon social';

CREATE PROCEDURE "informix".sp_si_empresasb4(pBandera CHAR(1),pEmpresa char(3))
RETURNING 	     	CHAR(5)  AS Cod_Retorno,
					CHAR(30)    as RazonSocial;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     	CHAR(5);
DEFINE vsqlerr      	INTEGER;
define cRazonSocial		char(30);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET vsqlerr    = 0;
LET scod_ret = "00000";
let cRazonSocial			 = '';		

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
	IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, cRazonSocial;
	END IF;
END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/mfinis/sp_si_empresasb4.out"; 
	--TRACE ON;

 -- Valida Parametros de Entrada

  IF pBandera	=''  THEN
    LET scod_ret = "00003";
    RETURN scod_ret, cRazonSocial;
  END IF;
  IF pBandera	='1' AND (pEmpresa='') THEN
    LET scod_ret = "00003";
    RETURN scod_ret, cRazonSocial;
  END IF;

  
 --Fin Valida Parametros de Entrada
  
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

	IF pBandera = '1' THEN
		Select razon_social 
		into cRazonSocial
		from bdinteg:"informix".si_empresas  
		where empresa = pEmpresa;
	END IF;
	
	IF DBINFO('sqlca.sqlerrd2') = 0  THEN
		LET scod_ret= '00017';
	END IF;
	RETURN scod_ret, cRazonSocial;

END
END PROCEDURE
DOCUMENT
"AUTOR : Eder Solis Lopez",
'MODULO: Contabilidad',
"FUNCIONAMIENTO:SP secundario de Contabilidad B4 de la tabla bdinteg:si_empresas ",
"FECHA : 26-12-2022",
"BD    : bdicont";

CREATE PROCEDURE "informix".sp_gen_devob3(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pDireccionMac CHAR(12), pTipo CHAR(1), pIdCheque INTEGER, pIdConsulta CHAR(1),  pNombreArchivo CHAR(22), pRutaDescarga CHAR(100), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING   CHAR(5)     AS codret,
                DATE        AS fecha_hoy,
    			DATE        AS fecha_ant,
	    		CHAR(8)        AS prox_fecha,
                DATE        AS fecha_habil_prox,
                CHAR(3)     AS id_banco,
		        CHAR(40)    AS desc_banco,
		        CHAR(20)    AS cuenta,
		        INTEGER     AS cheque,    
		        MONEY(16,2) AS importe,
		        CHAR(40)    AS mot_devol,
		        CHAR(1)     AS generado_dev, 
		        CHAR(8)     AS fecha_transfer, 
		        CHAR(15)    AS importe_c, 
		        CHAR(7)     AS lote_entrada, 
		        CHAR(4)     AS sec_entrada, 
		        CHAR(7)     AS lote_salida, 
		        CHAR(4)     AS sec_salida, 
		        CHAR(2)     AS cve_transacc, 
		        CHAR(3)     AS plaza_compensa, 
		        CHAR(13)    AS num_cuenta, 
		        CHAR(10)    AS num_cheque, 
		        CHAR(1)     AS dig_inter, 
		        CHAR(1)     AS dig_premar, 
		        CHAR(3)     AS cod_seguridad, 
		        CHAR(8)     AS ubicacion_fisica, 
		        CHAR(1)     AS truncamiento, 
		        CHAR(2)     AS mot_devol2, 
		        CHAR(8)     AS fecha_presini, 
		        CHAR(2)     AS plaza_inter, 
		        CHAR(13)    AS rfc_ben, 
		        CHAR(18)    AS curp_ben, 
		        CHAR(2)     AS tipo_ctadep, 
		        CHAR(20)    AS cuenta_dep, 
		        CHAR(40)    AS nombre_ben, 
		        CHAR(2)     AS alertamiento, 
		        CHAR(12)    AS folio_segur, 
		        CHAR(2)     AS status,
		        INTEGER     AS total_registros,
		        MONEY(18,2) AS total_importe,
		        CHAR(1)     AS duplicado,
		        INTEGER     AS id_registro,
		        CHAR(2)		AS num_bloque;

  --DECLARACIÃN DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
	DEFINE iSqlErr                  INTEGER;
    DEFINE dFechaHoy                DATE;
	DEFINE dFechaAnt                DATE; 
	DEFINE dProxFecha               CHAR(8); 
    DEFINE dFechaHabilProx          DATE; 
    DEFINE cBcoPresenta     		CHAR(3);
	DEFINE cNombreBanco             CHAR(40);
	DEFINE cCuenta                  CHAR(20);
	DEFINE iCheque                  INTEGER;
	DEFINE mImporte                 MONEY(16,2);
    DEFINE cDetDatosMotivo 			CHAR(40);
	DEFINE cGeneradoDev     		CHAR(1); 
	DEFINE cFechaTransfer   		CHAR(8);
	DEFINE cImporte                 CHAR(15);
	DEFINE cLoteEntrada     		CHAR(7);
	DEFINE cSecEntrada              CHAR(4);   
	DEFINE cLoteSalida              CHAR(7);   
	DEFINE cSecSalida               CHAR(4); 
	DEFINE cCveTransacc     		CHAR(2); 
	DEFINE cPlazaCompensa   		CHAR(3); 
	DEFINE cNumCuenta               CHAR(13);
	DEFINE cNumCheque               CHAR(10);
	DEFINE cDigInter                CHAR(1); 
	DEFINE cDigPremar               CHAR(1); 
	DEFINE cCodSeguridad    		CHAR(3); 
	DEFINE cUbicacionFisica 		CHAR(8); 
	DEFINE cTruncamiento    		CHAR(1); 
	DEFINE cMotDevol2               CHAR(2);
	DEFINE cFechaPresini			CHAR(8);
	DEFINE cPlazaInter              CHAR(2); 
	DEFINE cRfcBen                  CHAR(13);  
	DEFINE cCurpBen                 CHAR(18);
	DEFINE cTipoCtadep              CHAR(2);
	DEFINE cCuentaDep               CHAR(20);
	DEFINE cNombreBen               CHAR(40);
	DEFINE cAlertamiento    		CHAR(2); 
	DEFINE cFolioSegur              CHAR(12);
	DEFINE cStatus					CHAR(2);
    DEFINE iTotalReg				INTEGER;
    DEFINE mTotalImporte			MONEY(18,2);
    DEFINE cDuplicado				CHAR(1);
	DEFINE iIdRegistro     		    INTEGER;
    DEFINE cNumBloque				CHAR(2);
	-- NUEVO 
	DEFINE dFechaProx				DATE;
    
 --INICIALIZACIÃN DE VARIABLES
    LET cCodRet                     = '00000';
    LET iSqlErr                     = 0;
    LET dFechaHoy                   = '';
	LET dFechaAnt                   = '';
	LET dProxFecha                  = ''; 
    LET dFechaHabilProx             = '';
    LET cBcoPresenta     			= '';
	LET cNombreBanco             	= '';
	LET cCuenta                  	= '';
	LET iCheque                  	= 0;
	LET mImporte                 	= 0.00;
    LET cDetDatosMotivo 			= '';
	LET cGeneradoDev     			= '';
	LET cFechaTransfer   			= '';
	LET cImporte                 	= '';
	LET cLoteEntrada     			= '';
	LET cSecEntrada             	= '';  
	LET cLoteSalida              	= '';  
	LET cSecSalida               	= '';
	LET cCveTransacc     			= '';
	LET cPlazaCompensa   			= '';
	LET cNumCuenta               	= '';
	LET cNumCheque               	= '';
	LET cDigInter                	= '';
	LET cDigPremar               	= '';
	LET cCodSeguridad    			= '';
	LET cUbicacionFisica 			= '';
	LET cTruncamiento    			= '';
	LET cMotDevol2               	= '';
	LET cFechaPresini				= '';
	LET cPlazaInter              	= '';
	LET cRfcBen                  	= '';  
	LET cCurpBen                 	= '';
	LET cTipoCtadep              	= '';
	LET cCuentaDep               	= '';
	LET cNombreBen               	= '';
	LET cAlertamiento    			= '';
	LET cFolioSegur              	= '';
	LET cStatus						= '';
    LET iTotalReg					= 0;
    LET mTotalImporte				= 0.00;
    LET cDuplicado					= '';
	LET iIdRegistro     			= 0;
    LET cNumBloque 					= '';
	--NUEVO
	LET dFechaProx					= '';

    BEGIN
    	 ON EXCEPTION SET iSqlErr
		    LET cCodRet = iSqlErr;
		    RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, dFechaHabilProx, cBcoPresenta,cNombreBanco, cCuenta, iCheque, mImporte, cDetDatosMotivo, cGeneradoDev, cFechaTransfer,
			    cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			    cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			    cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus,
			    iTotalReg, mTotalImporte,cDuplicado, iIdRegistro, cNumBloque;
        END EXCEPTION;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, dFechaHabilProx, cBcoPresenta,cNombreBanco, cCuenta, iCheque, mImporte, cDetDatosMotivo, cGeneradoDev, cFechaTransfer,
			    cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			    cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			    cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus,
			    iTotalReg, mTotalImporte, cDuplicado, iIdRegistro, cNumBloque; 
        END IF;
			
		--SET DEBUG FILE TO '/tmp/mfinis/sp_gen_devob3.out';
		--TRACE ON;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF pBandera =  '1' THEN 
            EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizapagocheque(pUsuario, pIdFuncion, pFecha, pDireccionMac, pIdCheque)
            INTO cCodRet;

        ELIF pBandera =  '2' THEN 
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consgeneralfechas(pUsuario, pIdFuncion, pIdConsulta)
            INTO cCodRet, dFechaHoy, dFechaAnt, dFechaProx;
			LET dProxFecha = TO_CHAR(dFechaProx);

        ELIF pBandera =  '3' THEN 
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consgralproximafechahabil(pUsuario, pIdFuncion, pIdConsulta, pFecha)
            INTO cCodRet, dFechaHabilProx;

        ELIF pBandera =  '4' THEN 
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_consultadetallechequesdev(pUsuario, pIdFuncion , pFecha , '1' , pTipo, pDireccionMac , pRegistros, pRecuperacion)
                INTO cCodRet, cBcoPresenta,cNombreBanco, cCuenta, iCheque, mImporte, cDetDatosMotivo, cGeneradoDev, cFechaTransfer,
			        cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			        cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			        cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus,
			        iTotalReg, mTotalImporte, cDuplicado, iIdRegistro

                    RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, dFechaHabilProx, cBcoPresenta,cNombreBanco, cCuenta, iCheque, mImporte, cDetDatosMotivo, cGeneradoDev, cFechaTransfer,
			        cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			        cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			        cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus,
			        iTotalReg, mTotalImporte, cDuplicado, iIdRegistro, cNumBloque WITH RESUME;
            END FOREACH;
        ELIF pBandera =  '5' THEN 
             --Idconsulta 1 o 2
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consultadetallechequesdev_totales(pUsuario, pIdFuncion, pFecha, pIdConsulta, pTipo, pDireccionMac)
            INTO cCodRet, iTotalReg, dProxFecha, cNumBloque;

        ELIF pBandera =  '6' THEN 
            EXECUTE PROCEDURE bdicnweb:"informix".sp_genarchivodevoluciones(pUsuario, pIdFuncion, pFecha, pTipo, pNombreArchivo, pRutaDescarga, pDireccionMac)
            INTO cCodRet;
        END IF;

        IF pBandera <> "4" THEN
            RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, dFechaHabilProx, cBcoPresenta,cNombreBanco, cCuenta, iCheque, mImporte, cDetDatosMotivo, cGeneradoDev, cFechaTransfer,
			    cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			    cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			    cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus,
			    iTotalReg, mTotalImporte,cDuplicado, iIdRegistro, cNumBloque;
        END IF;

        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
            RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, dFechaHabilProx, cBcoPresenta,cNombreBanco, cCuenta, iCheque, mImporte, cDetDatosMotivo, cGeneradoDev, cFechaTransfer,
			    cImporte, cLoteEntrada, cSecEntrada, cLoteSalida, cSecSalida, cCveTransacc, cPlazaCompensa, cNumCuenta, cNumCheque,
			    cDigInter, cDigPremar, cCodSeguridad, cUbicacionFisica, cTruncamiento, cMotDevol2, cFechaPresini, cPlazaInter,
			    cRfcBen, cCurpBen, cTipoCtadep, cCuentaDep, cNombreBen, cAlertamiento, cFolioSegur, cStatus,
			    iTotalReg, mTotalImporte, cDuplicado, iIdRegistro, cNumBloque;
        END IF;
    END;
END PROCEDURE


DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 06/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 CAM GENERADOR ARCHIVOS DEVOLUCIONES',
'DESCRIPCION: SP MAESTRO ENCARGADO DE REALIZAR LAS FUNCIONALIDADES DE BLOQUE 3 GENERADOR ARCHIVOS DEVOLUCIONES',
'AUTOR: VERONICA SANCHEZ',
'FECHA: 22/12/2025',
'DESCRIPCION: SE AJUSTA PROCEDIMIENTO ALMACENADO PARA RETORNAR EL VALOR FECHA PROXIMA DE TIPO DATE A CHAR SOBRE LA BANDERA 4, PARA RECUPERAR LA FECHA DE FORMA CORRECTA.';

CREATE PROCEDURE "informix".sp_cam_cargamanualb3(pBandera CHAR(2),pUsuario CHAR(8), pIdFuncion CHAR(10),  pNombreArchivo CHAR(22), pDireccionMac CHAR(12), pCodOperacion CHAR(5), pFecha DATE,
												 pStatusImgF CHAR(1), pStatusImgT CHAR(1), pIdConsulta CHAR(1), pIdDetalle INTEGER, pIdRegistro CHAR(2), pRutaArchivo CHAR(100), pBloqueArchivo CHAR(117), 
												 pNroSecuencia INTEGER, pTipoProceso CHAR(12))
RETURNING CHAR(5) 	  		AS codret,
		CHAR(5) 	  	AS cod_operacion,
		CHAR(100)   	AS desc_archivo,
		CHAR(22) 	  	AS datos_nombre_archivo,
		CHAR(2) 	  	AS datos_cod_operacion,
		CHAR(22) 	  	AS datos_num_cuenta,
		INTEGER 	  	AS datos_num_cheque,
		CHAR(50) 	  	AS datos_motivo_devol,
		MONEY(14,2)  	AS importe,
		CHAR(1) 	  	AS datos_carga_imgf,
		CHAR(1)     	AS datos_carga_imgt,
		INTEGER     	AS id_detalle,
		INTEGER     	AS num_registros,
		CHAR(12) 	  	AS seccion,
		CHAR(2)     	AS campo,
		CHAR(100)   	AS mensaje_error,
		INTEGER     	AS linea,
		CHAR(1) 	  	AS bandera_det_error,
		CHAR(1)     	AS muestra_msn,
		CHAR(1)     	AS status,
		CHAR(1) 	  	AS error_proceso,
		CHAR(5) 	  	AS error;
			  
					
	--DEFINICIÃN DE VARIABLES
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodOperacion CHAR(5);
	DEFINE cDescArchivo CHAR(100);
	DEFINE cNombreArchivo CHAR(22);
	DEFINE cNumCuenta CHAR(22);
	DEFINE iNumCheque INTEGER;
	DEFINE cMotivoDev CHAR(50);
	DEFINE mImporte MONEY(14,2);
	DEFINE cStatusCargaImgF CHAR(1);
	DEFINE cStatusCargaImgT CHAR(1);
	DEFINE iIdDetalle INTEGER;
	DEFINE iNumRegistros INTEGER;
	DEFINE cSeccion CHAR(12);
	DEFINE cCampo CHAR(2);
	DEFINE cDescMensaje CHAR(100);
	DEFINE iLinea INTEGER;
	DEFINE cBanDetError CHAR(1);
	DEFINE cMuestraMsn CHAR(1);
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);

	--INICIALIZACIÃN DE VARIABLES
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodOperacion = '';
	LET cDescArchivo = '';	
	LET cNombreArchivo = '';
	LET cNumCuenta = '';
	LET iNumCheque = 0;
	LET cMotivoDev = '';
	LET mImporte = 0.00;
	LET cStatusCargaImgF = '';
	LET cStatusCargaImgT = '';
	LET iIdDetalle = 0;
	LET iNumRegistros = 0;
	LET cSeccion = '';
	LET cCampo = '';
	LET cDescMensaje = '';
	LET iLinea = 0;
	LET cBanDetError = 'f';
	LET cMuestraMsn = 'f';
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';

		BEGIN
			
			ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError;
			END EXCEPTION;
			
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cam_cargaManualb3.out';
		--TRACE ON;
		
		IF pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pBandera = '1' THEN
			EXECUTE PROCEDURE bdicnweb:"informix".sp_aplicacargaarchcecoban(pUsuario, pIdFuncion, pNombreArchivo, pDireccionMac, pCodOperacion, pFecha)
			INTO cCodRet;
			RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError;

		ELIF pBandera = '2' THEN
			EXECUTE PROCEDURE bdicnweb:"informix".sp_aplicacargaarchimgcecoban(pUsuario, pIdFuncion, pNombreArchivo , pDireccionMac, pFecha , pStatusImgF , pStatusImgT , pIdDetalle )
			INTO cCodRet;
			RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError;

		ELIF pBandera = '3' THEN
			FOREACH
				EXECUTE PROCEDURE bdicnweb:"informix".sp_catarchivoimportar(pUsuario, pIdFuncion)
				INTO cCodRet, cCodOperacion, cDescArchivo
				RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError WITH RESUME;
			END FOREACH;

		ELIF pBandera = '4' THEN
			FOREACH
				EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallearchcecoban(pUsuario, pIdFuncion, pNombreArchivo , pDireccionMac , pFecha , 0, 0)
				INTO cCodRet,cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,mImporte
				RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError WITH RESUME;
			END FOREACH;

		ELIF pBandera = '5' THEN
			FOREACH
				EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallearchimgcecoban(pUsuario, pIdFuncion, pNombreArchivo, pDireccionMac, pFecha, 0, 0)
				INTO cCodRet,cNombreArchivo,cNumCuenta,iNumCheque,mImporte,cStatusCargaImgF,cStatusCargaImgT,iIdDetalle
				RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError WITH RESUME;
			END FOREACH;
		ELIF pBandera = '6' THEN
				EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallearchimgcecoban_totales(pUsuario, pIdFuncion, pNombreArchivo, pDireccionMac, pFecha)
				INTO cCodRet, iNumRegistros;
				RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError;
			
		ELIF pBandera = '7' THEN
			FOREACH	
				EXECUTE PROCEDURE bdicnweb:"informix".sp_conserroresarchcecoban(pUsuario, pIdFuncion, pIdConsulta , pNombreArchivo , pDireccionMac, pFecha,0,0)
				INTO cCodRet,cSeccion,cCampo,cDescMensaje,iLinea
				RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError WITH RESUME;
			END FOREACH;
		
		ELIF pBandera = '8' THEN
			EXECUTE PROCEDURE bdicnweb:"informix".sp_conserroresarchcecoban_totales(pUsuario, pIdFuncion, pIdConsulta, pNombreArchivo, pDireccionMac, pFecha)
			INTO cCodRet, iNumRegistros;
			RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError;

		ELIF pBandera = '9' THEN
			FOREACH
				EXECUTE PROCEDURE bdicnweb:"informix".sp_consultaimgnula(pUsuario, pIdFuncion, pNombreArchivo, pDireccionMac , pFecha, pStatusImgF, pStatusImgT, pIdDetalle)
				INTO cCodRet
				RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError WITH RESUME;
			END FOREACH;

		ELIF pBandera = '10' THEN
			EXECUTE PROCEDURE bdicnweb:"informix".sp_lecturarchivodatosimportar(pUsuario, pIdFuncion, pNombreArchivo, pRutaArchivo, pDireccionMac, pCodOperacion, pFecha)
			INTO cCodRet,cBanDetError,cMuestraMsn;
			RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError;

		ELIF pBandera = '11' THEN
			EXECUTE PROCEDURE bdicnweb:"informix".sp_recibedatosarchivoimagenes(pUsuario, pIdFuncion, pIdConsulta, pNombreArchivo, pIdRegistro, pBloqueArchivo, pNroSecuencia, pDireccionMac, pFecha)
			INTO cCodRet, cBanDetError;
			RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError;

		ELIF pBandera = '12' THEN
			EXECUTE PROCEDURE bdicnweb:"informix".sp_validarchivoimportar(pUsuario, pIdFuncion, pNombreArchivo, pCodOperacion, pFecha)
			INTO cCodRet;
			RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError;

		ELIF pBandera = '13' THEN
			EXECUTE PROCEDURE bdicnweb:"informix".sp_verificastatusarchivo(pUsuario, pIdFuncion , pTipoProceso , pNombreArchivo)
			INTO cCodRet,cStatus,cBanDetError,cMuestraMsn,cErrorProceso,cError;	
			RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError;
		END IF;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';	
			RETURN TRIM(cCodRet), cCodOperacion, cDescArchivo, cNombreArchivo,cCodOperacion,cNumCuenta,iNumCheque,cMotivoDev,
				   mImporte, cStatusCargaImgF, cStatusCargaImgT, iIdDetalle, iNumRegistros, cSeccion,cCampo,cDescMensaje,iLinea, cBanDetError, cMuestraMsn, cStatus, cErrorProceso, cError;		
		END IF;

	END;
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 05/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 CAM',
'DESCRIPCION: SP PADRE ENCARGADO DE LAS FUNCIONALIDAD DE CAMARAS CARGA MANUAL';

CREATE PROCEDURE "informix".sp_cam_monitorarchivosb3(pBandera CHAR(2), pUsuario CHAR(10), pIdFuncion CHAR(10), pFechaConsulta DATE, pRegistros INTEGER, pRecuperacion INTEGER, pNombreArchivo CHAR(22), pTipo CHAR(3), pStatus CHAR(16))
RETURNING   CHAR(5)     AS codret,                       
			CHAR(22)    AS nombre_archivo,                               
			CHAR(3)     AS cod_operacion,                           
			CHAR(25)    AS hora_entrada,                               
			CHAR(10)    AS lectura,                           
			INTEGER     AS tot_reg,                      
			CHAR(100)   AS comentario,                
			CHAR(10)    AS fecha_aplic,                     
			CHAR(25)    AS hora_aplic,
			CHAR(16)    AS status,
			CHAR(1)     AS procesado,
            CHAR(20)    AS cuenta,                               
			INTEGER     AS num_cheque,                           
			MONEY(16,2) AS importe,                                                       
			CHAR(3)     AS img_f,                      
			CHAR(3)     AS img_t,                                   
			CHAR(5)     AS codigo_ret,
			DATE        AS fecha_proceso,
			CHAR(2)     AS motivo_dev,
			CHAR(35)    AS desc_motivodev,
            INTEGER     AS num_operaciones,                                                                                                                   
			INTEGER     AS img_recibidas,                      
			INTEGER     AS img_faltates;


/*=====================================
|     DEFINICIÃN DE VARIABLES         |
=====================================*/
    DEFINE cCodRet          CHAR(5);
	DEFINE iSqlErr          INTEGER;

	DEFINE cNombreArch      CHAR(22);
	DEFINE cCodOperacion    CHAR(3);
	DEFINE cHoraEntrada     CHAR(25);
    DEFINE cLectura         CHAR(10);
    DEFINE iTotalRegistros  INTEGER;
    DEFINE cComentario      CHAR(100);
    DEFINE cFechaAplic      CHAR(10);
    DEFINE cHoraAplic       CHAR(25);
    DEFINE cCveStatus       CHAR(2);
    DEFINE cProcesado       CHAR(1);
    DEFINE cCuenta          CHAR(20);
	DEFINE iNumCheque       INTEGER;
	DEFINE mImporte         MONEY(16,2);
	DEFINE cImgStat1        CHAR(1);
	DEFINE cImgStat2        CHAR(1);
	DEFINE cCodigoRet       CHAR(5);
	DEFINE dFechaProceso    DATE;
	DEFINE cMotivoDev       CHAR(2);
    DEFINE cDescMotivoDev   CHAR(35);
    DEFINE iNumOperaciones INTEGER;
    DEFINE iTotalImgRec INTEGER;
    DEFINE iTotalImgFalt INTEGER;
    
  

/*======================================
|     DECLARACIÃN DE VARIABLES         |
========================================*/

    LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNombreArch = '';
	LET cCodOperacion = '';
    LET cHoraEntrada = '';
    LET cLectura = '';	
	LET iTotalRegistros = 0;
	LET cComentario = '';
	LET cFechaAplic = '';
	LET cHoraAplic = '';
	LET cCveStatus = '';
	LET cProcesado = '';
    LET cCuenta = '';
	LET iNumCheque = 0;
	LET mImporte = 0.00;
	LET cImgStat1 = '';
	LET cImgStat2 = '';
	LET cCodigoRet = '';
	LET dFechaProceso = '';
	LET cMotivoDev = '';
    LET cDescMotivoDev = '';
    LET iNumOperaciones = 0;
    LET iTotalImgRec = 0;
    LET iTotalImgFalt = 0;
	
    BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet), cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cCveStatus, cProcesado,
                   cCuenta, iNumCheque, mImporte,cImgStat1, cImgStat2, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev, iNumOperaciones ,iTotalImgRec, iTotalImgFalt; 
		END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cam_monitorArchivosb3.out';
        --TRACE ON;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN 
			LET cCodRet = '00003';
			RETURN TRIM(cCodRet), cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cCveStatus, cProcesado,
                   cCuenta, iNumCheque, mImporte,cImgStat1, cImgStat2, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev, iNumOperaciones ,iTotalImgRec, iTotalImgFalt; 
		END IF;

        IF pBandera = 1 THEN
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_consarchrecibidos(pUsuario , pIdFuncion, pFechaConsulta , pRegistros , pRecuperacion)
                INTO cCodRet, cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cCveStatus, cProcesado
                RETURN TRIM(cCodRet), cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cCveStatus, cProcesado,
                   cCuenta, iNumCheque, mImporte,cImgStat1, cImgStat2, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev, iNumOperaciones ,iTotalImgRec, iTotalImgFalt WITH RESUME; 
            END FOREACH
        ELIF pBandera = 2 THEN
             EXECUTE PROCEDURE bdicnweb:"informix".sp_consarchrecibidos_totales(pUsuario, pIdFuncion, pFechaConsulta)
             INTO cCodRet, iTotalRegistros;
             RETURN TRIM(cCodRet), cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cCveStatus, cProcesado,
                   cCuenta, iNumCheque, mImporte,cImgStat1, cImgStat2, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev, iNumOperaciones, iTotalImgRec, iTotalImgFalt; 

        ELIF pBandera = 3 THEN
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_consultadetallearchivo(pUsuario, pIdFuncion,pNombreArchivo, pTipo, pStatus, pFechaConsulta, pRegistros , pRecuperacion)
			    INTO  cCodRet, cCuenta, iNumCheque, mImporte, cCodOperacion, cImgStat1, cImgStat2, cCveStatus, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev 
               RETURN TRIM(cCodRet), cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cCveStatus, cProcesado,
                   cCuenta, iNumCheque, mImporte,cImgStat1, cImgStat2, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev, iNumOperaciones ,iTotalImgRec, iTotalImgFalt WITH RESUME;
            END FOREACH
        ELIF pBandera = 4 THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consultadetallearchivo_totales(pUsuario, pIdFuncion, pNombreArchivo, pTipo , pStatus, pFechaConsulta)
            INTO cCodRet, iTotalRegistros;
            RETURN TRIM(cCodRet), cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cCveStatus, cProcesado,
                   cCuenta, iNumCheque, mImporte,cImgStat1, cImgStat2, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev, iNumOperaciones ,iTotalImgRec, iTotalImgFalt; 

        ELIF pBandera = 5 THEN
            FOREACH
                EXECUTE  PROCEDURE bdicnweb:"informix".sp_consdetallesumarioarch(pUsuario , pIdFuncion , pNombreArchivo, pTipo , pStatus , pFechaConsulta)
                INTO cCodRet, iNumOperaciones, mImporte, iTotalRegistros, iTotalImgRec, iTotalImgFalt
                RETURN TRIM(cCodRet), cNombreArch, cCodOperacion, cHoraEntrada, cLectura, iTotalRegistros, cComentario, cFechaAplic, cHoraAplic, cCveStatus, cProcesado,
                   cCuenta, iNumCheque, mImporte,cImgStat1, cImgStat2, cCodigoRet, dFechaProceso, cMotivoDev, cDescMotivoDev, iNumOperaciones ,iTotalImgRec, iTotalImgFalt WITH RESUME;
            END FOREACH;
        END IF;

    END;
END PROCEDURE

DOCUMENT 'AUTOR: ING JOSÃ ANTONIO RAMIREZ FRANCO',
'FECHA: 01/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 DE CAMARAS RECIBIDAS',
'DESCRIPCION: SP MAESTRO ENCARGO DE EJECUTAR LOS SP DE MONITOR ARCHIVOS RECIBIDOS',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_monitor_cheques_propios_b3(pBandera CHAR(1), pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
	--Se asignan los valores de retorno en las consultas, valores seleccionados, se definen tal cual de la consulta
		RETURNING 	CHAR(5)     As codret,
					INTEGER     AS operados,
			        INTEGER     AS digitalizados,
			        INTEGER     AS por_recibir,
                    CHAR(4)     AS sucursal,
			        CHAR(40)    AS nombre_suc,
			        CHAR(20)    AS cuenta,
			        INTEGER     AS num_cheque,
			        MONEY(16,2) AS monto,
			        CHAR(21)    AS fecha_hora,
			        CHAR(16)    AS folio_suc,
			        CHAR(4)     AS transaccion,
			        CHAR(1)     AS digitalizado;   

/*=====================================
|     DEFINICIÃN DE VARIABLES         |
=====================================*/
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr          INTEGER;

    DEFINE iOperados        INTEGER;
	DEFINE iDigitalizados   INTEGER;
	DEFINE iPorRecibir      INTEGER;
    DEFINE cSucursal        CHAR(4); 	
    DEFINE cNombreSuc       CHAR(40);      
	DEFINE cCuenta          CHAR(20);
	DEFINE iNumCheque       INTEGER;
    DEFINE mMonto           MONEY(16,2);
    DEFINE cFechaHora       CHAR(21);
    DEFINE cFolioSuc        CHAR(16);  
    DEFINE cTransaccion     CHAR(4); 
    DEFINE cDigitalizado    CHAR(1);

/*======================================
|     DECLARACIÃN DE VARIABLES         |
======================================*/
    LET cCodRet = '00000';
	LET iSqlErr = 0;

    LET iOperados       = 0;
	LET iDigitalizados  = 0;
	LET iPorRecibir     = 0;
    LET cSucursal       = '';  
    LET cNombreSuc      = '';
	LET cCuenta         = '';
	LET iNumCheque      = 0;
	LET mMonto          = 0.00; 
    LET cFechaHora      = '';
    LET cFolioSuc       = '';
    LET cTransaccion    = '';
    LET cDigitalizado   = '';

    BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iOperados, iDigitalizados, iPorRecibir, cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado;  
		END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_monitor_cheques_propios_b3.out';
        --TRACE ON;
        
        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003'; -- COD:PARAMETROS VACIOS
			RETURN TRIM(cCodRet), iOperados, iDigitalizados, iPorRecibir, cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado;  
        END IF;

        IF pBandera = 1 THEN

            EXECUTE PROCEDURE bdicnweb:"informix".sp_consresumenmovcheques(pUsuario, pIdFuncion)
            INTO cCodRet, iOperados, iDigitalizados, iPorRecibir;
		    RETURN TRIM(cCodRet), iOperados, iDigitalizados, iPorRecibir, cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado;  

        ELIF pBandera = 2 THEN
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallemovchequespropios(pUsuario, pIdFuncion, pRegistros , pRecuperacion)
                INTO cCodRet,  cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado
		        RETURN TRIM(cCodRet), iOperados, iDigitalizados, iPorRecibir, cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado WITH RESUME;
            END FOREACH

        END IF;

        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017'; 
		    RETURN TRIM(cCodRet), iOperados, iDigitalizados, iPorRecibir, cSucursal, cNombreSuc, cCuenta, iNumCheque, mMonto, cFechaHora, cFolioSuc, cTransaccion, cDigitalizado;  

		END IF;
    END;
END PROCEDURE

DOCUMENT 'AUTOR: ING JOSÃ ANTONIO RAMIREZ FRANCO',
'FECHA: 05/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 DE CAMARAS RECIBIDAS MONITOR CHEQUES PROPIOS',
'DESCRIPCION: SP MAESTRO ENCARGO DE EJECUTAR LOS SP DE MONITOR CHEQUE PROPIOS',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_cam_asigna_rev_firmasb3 (pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER, pCheques CHAR(250), pEjecutivo CHAR(8))
    RETURNING   CHAR(5)         AS codret,
				CHAR(20)        AS cuenta,
				INTEGER         AS cheque,
				DECIMAL(16,2)   AS importe,
				CHAR(2)         AS revisadoFirmas,
				CHAR(54)        AS usuarioValida,
				CHAR(38)        AS motivoDevol,
                INTEGER         AS totalChequesPendientes,
		        CHAR(22)        AS nombreArchivo,
		        INTEGER         AS secuencia,
                CHAR(8)         AS ejecutivo,
			    CHAR(45)        AS nombre_ejecutivo,
                INTEGER         AS totalCheques,
		        INTEGER         AS totalChequesPorRevisar,
		        INTEGER         AS totalChequesRevisados;


    --DECLARACIÃN DE VARIABLES
    DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE dImporte DECIMAL(16,2);
	DEFINE cRevisadoFirmas CHAR(2);
	DEFINE cUsuarioValida CHAR(8);
	DEFINE cMotivoDevolucion CHAR(38);
    DEFINE iTotalChequesPendientes INTEGER;
    DEFINE cNombreArchivo CHAR(22);
	DEFINE cSecuencia INTEGER;
    DEFINE cEjecutivo CHAR(8);
	DEFINE cNombreEjecutivo CHAR(45);
    DEFINE iTotalCheques INTEGER;
	DEFINE iTotalChequesPorRevisar INTEGER;
	DEFINE iTotalChequesRevisados INTEGER;
	

    --INICIALIZACIÃN DE VARIABLES
    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cCuenta = "";
	LET iCheque = 0;
	LET dImporte = 0;
	LET cRevisadoFirmas = "";
	LET cUsuarioValida = "";
	LET cMotivoDevolucion = "";
    LET iTotalChequesPendientes = 0;
    LET cNombreArchivo = '';
	LET cSecuencia  = 0;
    LET cEjecutivo = '';
	LET cNombreEjecutivo = '';
    LET iTotalCheques  = 0;
	LET iTotalChequesPorRevisar = 0;
	LET iTotalChequesRevisados = 0;
	

    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, cUsuarioValida, cMotivoDevolucion, 
                   iTotalChequesPendientes, cNombreArchivo, cSecuencia, cEjecutivo, cNombreEjecutivo, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados;
		END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cam_asigna_rev_firmasb3.out';
		--TRACE ON;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = "00003";
            RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, cUsuarioValida, cMotivoDevolucion, 
                   iTotalChequesPendientes, cNombreArchivo, cSecuencia, cEjecutivo, cNombreEjecutivo, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados;
        END IF;

        IF pBandera = '1' THEN
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_catchequesdetalle(pUsuario, pIdFuncion, pFecha, pRegistros, pRecuperacion)
                INTO cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, cUsuarioValida, cMotivoDevolucion
                RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, cUsuarioValida, cMotivoDevolucion, 
                   iTotalChequesPendientes, cNombreArchivo, cSecuencia, cEjecutivo, cNombreEjecutivo, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados WITH RESUME;
            END FOREACH;
        ELIF pBandera = '2' THEN
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_catchequespendientes(pUsuario, pIdFuncion, pFecha, pRegistros, pRecuperacion)
                INTO cCodRet, iTotalChequesPendientes, cNombreArchivo, cSecuencia, cUsuarioValida
                RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, cUsuarioValida, cMotivoDevolucion, 
                   iTotalChequesPendientes, cNombreArchivo, cSecuencia, cEjecutivo, cNombreEjecutivo, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados WITH RESUME;
            END FOREACH;
        ELIF pBandera = '3' THEN 
                EXECUTE PROCEDURE bdicnweb:"informix".sp_catguardasignaciones(pUsuario, pIdFuncion, pCheques, pEjecutivo, pFecha)
                INTO cCodRet;
                RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, cUsuarioValida, cMotivoDevolucion, 
                   iTotalChequesPendientes, cNombreArchivo, cSecuencia, cEjecutivo, cNombreEjecutivo, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados;
        ELIF pBandera = '4' THEN
                FOREACH
                    EXECUTE PROCEDURE bdicnweb:"informix".sp_catrevisoresfirmas(pUsuario, pIdFuncion)
                    INTO cCodRet, cEjecutivo, cNombreEjecutivo
                    RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, cUsuarioValida, cMotivoDevolucion, 
                   iTotalChequesPendientes, cNombreArchivo, cSecuencia, cEjecutivo, cNombreEjecutivo, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados WITH RESUME;
                END FOREACH;
        ELIF pBandera = '5' THEN
                EXECUTE PROCEDURE bdicnweb:"informix".sp_cattotalchequesdetalle(pUsuario, pIdFuncion, pFecha)
                INTO cCodRet, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados;
                RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, cUsuarioValida, cMotivoDevolucion, 
                   iTotalChequesPendientes, cNombreArchivo, cSecuencia, cEjecutivo, cNombreEjecutivo, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados;
        END IF;

        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cCuenta, iCheque, dImporte, cRevisadoFirmas, cUsuarioValida, cMotivoDevolucion, 
                   iTotalChequesPendientes, cNombreArchivo, cSecuencia, cEjecutivo, cNombreEjecutivo, iTotalCheques, iTotalChequesPorRevisar, iTotalChequesRevisados;
		END IF;
    END 
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 06/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 CAM ',
'DESCRIPCION: SP MAESTRO ENCARGADO DE REALIZAR LAS FUNCIONES DE LA CAMARA ASIGNA REVISIÃN FIRMAS DEL BLOQUE 3',
'AUTOR: VERONICA SANCHEZ',
'FECHA: 19/11/2025',
'DESCRIPCION: Se ajusta banderas 1, 2 y 4 para agregar WITH RESUME para recuperar mÃ¡s de in registro',
'MODULO: CONTABILIDAD';

CREATE PROCEDURE "informix".sp_conscheqb3(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pFechaInicio CHAR(10), pFechaFin CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER, pCliente CHAR(20), pCuenta CHAR(20), pCheque CHAR(7), pClaveBanco CHAR(3))
RETURNING   CHAR(5)     AS codret,
            INTEGER     AS num_registros,
            CHAR(4)     AS sucursal,
			CHAR(40)    AS nombre_suc,
			CHAR(20)    AS cuenta,
			CHAR(5)     AS cheque,
			MONEY(16,2) AS importe,
		    CHAR(20)    AS fecha_hora,
			CHAR(16)    AS folio_suc,
			CHAR(4)     AS transacc,
			CHAR(20)    AS cliente,
			SMALLINT    AS secuencia,
			CHAR(1)     AS bandera_visor,
            DATE        AS fecha_hoy,
			DATE        AS fecha_ant,
			DATE        AS prox_fecha,
            CHAR(2)     AS numero_firmas,
			CHAR(120)   AS combinacion,
			CHAR(20)    AS tipo_firma,
			CHAR(3)     AS banco,
			DATE        AS fecha_presenta,
			CHAR(4)     AS codigo_docto,
			SMALLINT    AS secuencia_docto,
			CHAR(1)     AS hay_imgfirmas,
            CHAR(3)     AS imgFormato;	


    --DECLARACIÃN DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
	DEFINE iSqlErr                  INTEGER;
    DEFINE iNumRegistros            INTEGER;
    DEFINE cSucursal                CHAR(4);
	DEFINE cNombreSuc               CHAR(40);
	DEFINE cCuenta                  CHAR(20);
	DEFINE cNumCheque               CHAR(5);
	DEFINE mMonto                   MONEY(16,2);
	DEFINE dFechaHora               CHAR(20);
	DEFINE cFolioSuc                CHAR(16);
	DEFINE cTransacc                CHAR(4);
	DEFINE cCliente                 CHAR(20);
	DEFINE sSecuencia               SMALLINT;
    DEFINE cBanderaVisor            CHAR(1);
    DEFINE dFechaHoy                DATE;
	DEFINE dFechaAnt                DATE; 
	DEFINE dProxFecha               DATE;
    DEFINE cNumFirmas               CHAR(2);
	DEFINE cCombFirmas              CHAR(120);
	DEFINE cTipoFirma               CHAR(20);
	DEFINE cCveBanco                CHAR(3);
	DEFINE dFechaPresenta           DATE;
	DEFINE cCodDocumento            CHAR(4);
	DEFINE iSecDocto                SMALLINT;
	DEFINE cHayImgFirmas            CHAR(1); 
    DEFINE cImgFormato              CHAR(3);

    --INICIALIZACIÃN DE VARIABLES
    LET cCodRet                     = '00000';
    LET iSqlErr                     = 0;
    LET iNumRegistros               = 0;
    LET cSucursal                   = '';
	LET cNombreSuc                  = '';
	LET cCuenta                     = '';
	LET cNumCheque                  = '';
	LET mMonto                      = 0.00;
	LET dFechaHora                  = '';
	LET cFolioSuc                   = '';
	LET cTransacc                   = '';
	LET cCliente                    = '';
    LET sSecuencia                  = 0;
    LET cBanderaVisor               = 'f';
    LET dFechaHoy                   = '';
	LET dFechaAnt                   = '';
	LET dProxFecha                  = ''; 
    LET cNumFirmas                  = '';
	LET cCombFirmas                 = '';
	LET cTipoFirma                  = '';
	LET cCveBanco                   = '';
	LET dFechaPresenta              = '';
	LET cCodDocumento               = '';
	LET iSecDocto                   = 0;
	LET cHayImgFirmas               = 'f';
    LET cImgFormato                 = '';

    BEGIN
        ON EXCEPTION SET iSqlErr
		    LET cCodRet = iSqlErr;
		    RETURN TRIM(cCodRet), iNumRegistros, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, 
                       cCliente, sSecuencia, cBanderaVisor, dFechaHoy, dFechaAnt, dProxFecha,
                       cNumFirmas,cCombFirmas,cTipoFirma, cCveBanco, dFechaPresenta,cCodDocumento,iSecDocto,cHayImgFirmas, cImgFormato;
        END EXCEPTION;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
		    RETURN TRIM(cCodRet), iNumRegistros, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, 
                       cCliente, sSecuencia, cBanderaVisor, dFechaHoy, dFechaAnt, dProxFecha,
                       cNumFirmas,cCombFirmas,cTipoFirma, cCveBanco, dFechaPresenta,cCodDocumento,iSecDocto,cHayImgFirmas, cImgFormato;
        END IF;

        
        --SET DEBUG FILE TO '/tmp/mfinis/sp_conscheqb3.out';
		--TRACE ON;
 
        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        

        IF pBandera = '1' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallechequespagadossuc_totales(pUsuario, pIdFuncion, pFechaInicio, pFechaFin)
			INTO cCodRet, iNumRegistros;
            
        ELIF  pBandera = '2' THEN
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallechequespagadossuc(pUsuario, pIdFuncion, pFechaInicio, pFechaFin, pRegistros, pRecuperacion) 
			    INTO cCodRet, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, cCliente, sSecuencia, cBanderaVisor

                RETURN TRIM(cCodRet), iNumRegistros, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, 
                       cCliente, sSecuencia, cBanderaVisor, dFechaHoy, dFechaAnt, dProxFecha,
                       cNumFirmas,cCombFirmas,cTipoFirma, cCveBanco, dFechaPresenta,cCodDocumento,iSecDocto,cHayImgFirmas, cImgFormato WITH RESUME;
            END FOREACH;           

        ELIF  pBandera = '3' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consgeneralfechas(pUsuario, pIdFuncion, pIdConsulta)
			INTO cCodRet, dFechaHoy, dFechaAnt, dProxFecha;

         ELIF  pBandera = '4' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consultafirmascomb(pUsuario, pIdFuncion, pCliente, pCuenta, pCheque)
            INTO cCodRet, cNumFirmas, cCombFirmas, cTipoFirma, cCuenta, cNumCheque, cCveBanco, dFechaPresenta,
                 cCliente, cCodDocumento,iSecDocto,cHayImgFirmas;

         ELIF  pBandera = '5' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_validaimagencheque(pUsuario, pIdFuncion, pClaveBanco, pCuenta , pCheque)
			INTO cCodRet, cImgFormato;
        END IF;

        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
            RETURN TRIM(cCodRet), iNumRegistros, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, 
                       cCliente, sSecuencia, cBanderaVisor, dFechaHoy, dFechaAnt, dProxFecha,
                       cNumFirmas,cCombFirmas,cTipoFirma, cCveBanco, dFechaPresenta,cCodDocumento,iSecDocto,cHayImgFirmas, cImgFormato;
        END IF;

        IF  pBandera <> '2' THEN
            RETURN TRIM(cCodRet), iNumRegistros, cSucursal, cNombreSuc, cCuenta, cNumCheque, mMonto, dFechaHora, cFolioSuc, cTransacc, 
                       cCliente, sSecuencia, cBanderaVisor, dFechaHoy, dFechaAnt, dProxFecha,
                       cNumFirmas,cCombFirmas,cTipoFirma, cCveBanco, dFechaPresenta,cCodDocumento,iSecDocto,cHayImgFirmas, cImgFormato;
        END IF;
    END
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 07/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 CAMARA CHEQUES PAGADOS POR SUCURSAL',
'DESCRIPCION: SP MAESTRO ENCARGADO DE REALIZAR LAS FUNCIONALIDADES DE BLOQUE 3 CHEQUES PAGADOS POR SUCURSAL';

CREATE PROCEDURE "informix".sp_cam_firmas_visual_chequesb3(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(8), pMotivoDev CHAR(2),
                                                           pIdConsCheque INTEGER, pIdEjecucion CHAR(1), pTramaConsecutivo CHAR(250), pRegistros INTEGER, 
                                                           pRecuperacion INTEGER)
    RETURNING CHAR(5)     AS codret,
              DATE        AS fecha_hoy,
			  DATE        AS fecha_ant,
			  DATE        AS prox_fecha,	
              CHAR(20)    AS cuenta,
			  INTEGER     AS cheque,
			  MONEY(16,2) AS importe,
			  CHAR(45)    AS sucursal,
			  CHAR(20)    AS num_cliente,
			  CHAR(125)   AS cliente,
			  CHAR(38)    AS motivo_devol,
			  CHAR(32)    AS firmas,
			  CHAR(1)     AS hay_firmas,
			  INTEGER     AS id_consecutivo,
              INTEGER     AS num_registros,
			  INTEGER     AS contador_imagenes,
			  CHAR(1)     AS reg_firmas,
			  CHAR(120)   AS comb_firmantes,
		      CHAR(3)     AS cve_banco,
			  DATE        AS fechapresenta,
			  CHAR(4)     AS cod_documento,
			  SMALLINT    AS secuencia,
			  INTEGER     AS id_registro;		


    --DECLARACIÃN DE VARIABLES
    DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE dFechaHoy DATE;
	DEFINE dFechaAnt DATE; 
	DEFINE dProxFecha DATE;  
    DEFINE cCuenta CHAR(20);
	DEFINE iCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
    DEFINE cSucursal CHAR(45);
    DEFINE cNumCte CHAR(20);
    DEFINE cCliente CHAR(125);
	DEFINE cMotivoDevol CHAR(38);	
	DEFINE cFirmas CHAR(32);
	DEFINE cHayFirmas CHAR(1);
    DEFINE iIdConsCheque INTEGER;
    DEFINE iContImagenes INTEGER;
	DEFINE iNumRegistros INTEGER;
    DEFINE cRegFirmas CHAR(1);
    DEFINE cCombFirmantes CHAR(120);
	DEFINE cCveBanco CHAR(3);
	DEFINE dFechaPresenta DATE;
	DEFINE cCodDocumento CHAR(4);
	DEFINE cSecuencia SMALLINT;	
	DEFINE iRecuperacion INTEGER;


    --INICIALIZACIÃN DE VARIABLES
    LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET dFechaHoy = '';
	LET dFechaAnt = '';
	LET dProxFecha = ''; 
    LET cCuenta = '';
	LET iCheque = 0;
	LET mImporte = 0.00;
	LET cMotivoDevol = '';
	LET cNumCte = '';
	LET cCliente = '';
	LET cSucursal = '';
	LET cFirmas = '';
	LET cHayFirmas = '';
	LET iIdConsCheque = 0;
    LET iContImagenes = 0;
	LET iNumRegistros = 0;
    LET cRegFirmas ='';
    LET cCombFirmantes='';
	LET cCveBanco='';
	LET dFechaPresenta='';
	LET cCodDocumento='';
	LET cSecuencia= 0;
	LET iRecuperacion= 0;

    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN  cCodRet, dFechaHoy, dFechaAnt, dProxFecha, cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,
                    cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque, iContImagenes, iNumRegistros, cRegFirmas,
                    cCombFirmantes, cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iRecuperacion;
		END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cam_firmas_visual_chequesb3.out';
		--TRACE ON;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN  cCodRet, dFechaHoy, dFechaAnt, dProxFecha, cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,
                    cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque, iContImagenes, iNumRegistros, cRegFirmas,
                    cCombFirmantes, cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iRecuperacion;
        END IF;

        IF pBandera = "1" THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizadatoscheque(pUsuario, pIdFuncion, pFecha, pMotivoDev, pIdConsCheque, pIdEjecucion)
            INTO cCodRet;
            RETURN  cCodRet, dFechaHoy, dFechaAnt, dProxFecha, cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,
                    cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque, iContImagenes, iNumRegistros, cRegFirmas,
                    cCombFirmantes, cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iRecuperacion;

        ELIF pBandera = "2" THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_aplicabonocuenta(pUsuario, pIdFuncion, pFecha, pTramaConsecutivo)
            INTO cCodRet;
            RETURN  cCodRet, dFechaHoy, dFechaAnt, dProxFecha, cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,
                    cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque, iContImagenes, iNumRegistros, cRegFirmas,
                    cCombFirmantes, cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iRecuperacion;

        ELIF pBandera = "3" THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consgeneralfechas(pUsuario , pIdFuncion, pIdEjecucion)
            INTO cCodRet, dFechaHoy, dFechaAnt, dProxFecha;
            RETURN  cCodRet, dFechaHoy, dFechaAnt, dProxFecha, cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,
                    cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque, iContImagenes, iNumRegistros, cRegFirmas,
                    cCombFirmantes, cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iRecuperacion;

        ELIF pBandera = "4" THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_statusdescarga(pUsuario, pIdFuncion, pTramaConsecutivo)
            INTO cCodRet;
            RETURN  cCodRet, dFechaHoy, dFechaAnt, dProxFecha, cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,
                    cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque, iContImagenes, iNumRegistros, cRegFirmas,
                    cCombFirmantes, cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iRecuperacion;

        ELIF pBandera = "5" THEN
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_validadetallerevcheques(pUsuario, pIdFuncion, pFecha, pRegistros, pRecuperacion)
                INTO cCodRet, cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque
                RETURN  cCodRet, dFechaHoy, dFechaAnt, dProxFecha, cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,
                    cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque, iContImagenes, iNumRegistros, cRegFirmas,
                    cCombFirmantes, cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iRecuperacion WITH RESUME;
            END FOREACH;

        ELIF pBandera = "6" THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_validadetallerevcheques_totales(pUsuario, pIdFuncion, pFecha)
            INTO cCodRet,iNumRegistros,iContImagenes;
            RETURN  cCodRet, dFechaHoy, dFechaAnt, dProxFecha, cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,
                    cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque, iContImagenes, iNumRegistros, cRegFirmas,
                    cCombFirmantes, cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iRecuperacion;

        ELIF pBandera = "7" THEN
        FOREACH
            EXECUTE PROCEDURE bdicnweb:"informix".sp_validaimagenchequesfirmas(pUsuario, pIdFuncion, pFecha, pRegistros, pRecuperacion)
            INTO cCodRet,cCuenta,iCheque,cNumCte,cCliente,cSucursal,mImporte,cRegFirmas,cCombFirmantes,
			     cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iIdConsCheque,iRecuperacion
                 RETURN  cCodRet, dFechaHoy, dFechaAnt, dProxFecha, cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,
                    cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque, iContImagenes, iNumRegistros, cRegFirmas,
                    cCombFirmantes, cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iRecuperacion WITH RESUME;
        END FOREACH
        
         IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            LET cCodRet = '00017';
			RETURN  cCodRet, dFechaHoy, dFechaAnt, dProxFecha, cCuenta,iCheque,mImporte,cSucursal,cNumCte,cCliente,
            cMotivoDevol,cFirmas,cHayFirmas,iIdConsCheque, iContImagenes, iNumRegistros, cRegFirmas,
            cCombFirmantes, cCveBanco,dFechaPresenta,cCodDocumento,cSecuencia,iRecuperacion;
		 END IF;
         
        END IF;
    END;
END PROCEDURE


DOCUMENT 'AUTOR: ING JOSÃ ANTONIO RAMIREZ FRANCO',
'FECHA: 06/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 CAM',
'DESCRIPCION: SP MAESTRO ENCARGADO DE LAS FUNCIONES DEL B3 VALIDACIÃN VISUAL DE CHEQUES';

CREATE PROCEDURE "informix".sp_cam_devforzadab3(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pMotivoDev CHAR(2), pFecha CHAR(8), pIdConsCheque INTEGER, pIdConsulta CHAR(1), pNumero CHAR(20),pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING   CHAR(5)     AS codret,
                CHAR(20)    AS no_cliente,
			    CHAR(107)   AS nombre_cliente,
			    CHAR(13)    AS rfc,
			    DATE        AS fecha_nac,
			    CHAR(44)    AS banco,
			    CHAR(20)    AS no_cuenta,
			    INTEGER     AS no_cheque,
			    MONEY(16,2) AS importe,
			    CHAR(2)     AS truncado,
			    CHAR(19)    AS estatus,
			    CHAR(38)    AS causa_dev,
			    CHAR(18)    AS importe2,
			    INTEGER     AS secuencia, 
			    CHAR(22)    AS nombre_archivo, 
			    INTEGER     AS id_consecutivo,
                INTEGER     AS num_registros,
                DATE        AS fecha_hoy,
			    DATE        AS fecha_ant,
			    DATE        AS prox_fecha,
                CHAR(2)     AS codigo,
				CHAR(35)    AS descripcion;
    
    --DECLARACIÃN DE VARIABLES
    DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;

    DEFINE cNumCte CHAR(20);
	DEFINE cNombreCte CHAR(107);
	DEFINE cRfc CHAR(13);
	DEFINE dFechaNac DATE;
	DEFINE cBanco CHAR(44);
	DEFINE cNoCuenta CHAR(20);
	DEFINE iNoCheque INTEGER;
	DEFINE mImporte MONEY(16,2);
    DEFINE cTruncado CHAR(2);
	DEFINE cEstatus CHAR(19);
	DEFINE cCausaDev CHAR(38);
	DEFINE cImporte2 CHAR(18);
    DEFINE iSecuencia INTEGER;
	DEFINE cNombreArchivo CHAR(22);
	DEFINE iIdConsCheque INTEGER;
    DEFINE iNumRegistros INTEGER;
    DEFINE dFechaHoy DATE;
	DEFINE dFechaAnt DATE; 
	DEFINE dProxFecha DATE;  
    DEFINE cCodigo CHAR(2);
	DEFINE cDescripcion CHAR(35);

    --INICIALIZACIÃN DE VARIABLES
    LET cCodRet = '00000';
    LET iSqlErr = 0;

    LET cNumCte = '';
	LET cNombreCte = "";
	LET cRfc = "";
	LET dFechaNac ='';
	LET cBanco = "";
	LET cNoCuenta = "";
	LET iNoCheque = 0;
	LET mImporte =0.00;
    LET cTruncado = "";
	LET cEstatus = "";
	LET cCausaDev = "";
	LET cImporte2 = "";
    LET iSecuencia = 0;
	LET cNombreArchivo = "";
	LET iIdConsCheque = 0;
    LET iNumRegistros = 0;
    LET dFechaHoy = '';
	LET dFechaAnt = '';
	LET dProxFecha = ''; 
    LET cCodigo = '';
	LET cDescripcion = '';

    BEGIN
		ON EXCEPTION SET iSqlErr
		    LET cCodRet = iSqlErr;
		    RETURN TRIM(cCodRet), cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque, iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha, cCodigo, cDescripcion;
		 END EXCEPTION;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN TRIM(cCodRet), cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque, iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha, cCodigo, cDescripcion;
        END IF;
			
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cam_devforzadab3.out';
		--TRACE ON;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF pBandera = '1' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_aplicadevolucioncheque(pUsuario, pIdFuncion, pMotivoDev, pFecha, pIdConsCheque)
            INTO cCodRet;
            RETURN TRIM(cCodRet), cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque, iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha, cCodigo, cDescripcion;
            
        ELIF pBandera = '2' THEN
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallechequespagados(pUsuario, pIdFuncion, pIdConsulta , pNumero , pFecha, pRegistros, pRecuperacion)
                INTO cCodRet, cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque
                RETURN TRIM(cCodRet), cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque, iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha, cCodigo, cDescripcion WITH RESUME;
            END FOREACH;

        ELIF pBandera = '3' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallechequespagados_totales(pUsuario, pIdFuncion, pIdConsulta, pNumero, pFecha )            
            INTO cCodRet, iNumRegistros;
            RETURN TRIM(cCodRet), cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque, iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha, cCodigo, cDescripcion;

        ELIF pBandera = '4' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consgeneralfechas(pUsuario, pIdFuncion, pIdConsulta)
            INTO cCodRet, dFechaHoy, dFechaAnt, dProxFecha;
            RETURN TRIM(cCodRet), cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque, iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha, cCodigo, cDescripcion;

        ELIF pBandera = '5' THEN
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_ope_catalogomotivos(pUsuario, pIdFuncion)
                INTO cCodRet, cCodigo, cDescripcion
                RETURN TRIM(cCodRet), cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque, iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha, cCodigo, cDescripcion WITH RESUME;
            END FOREACH
        END IF;

        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
            RETURN TRIM(cCodRet), cNumCte, cNombreCte, cRfc, dFechaNac, cBanco, cNoCuenta, iNoCheque, mImporte, cTruncado, cEstatus, cCausaDev, cImporte2, iSecuencia, cNombreArchivo, iIdConsCheque, iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha, cCodigo, cDescripcion;
		END IF;
    END
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 06/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 CAM',
'DESCRIPCION: SP MAESTRO ENCARGADO DE REALIZAR LAS FUNCIONALIDADES DE BLOQUE 3 CAMARA DEVOLUCIÃN FORZADA';

CREATE PROCEDURE "informix".sp_cam_datosdia(pBandera CHAR(1), pUsuario CHAR(8), pIdFuncion CHAR(10),  pWhere CHAR(15), pIdParametro CHAR(15))
        RETURNING   CHAR(5)   AS codret,
			        DATE      AS FechaHoy,
			        CHAR(3)   AS NoBanco,
			        CHAR(1)   AS Procesado,
			        DATE      AS FechaHabilAnt,
                    CHAR(2)   AS codigo,
				    CHAR(35)  AS descripcion,
                    CHAR(100) AS valor;

--==== DEFINICIÃN DE VARIABLES =====
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE dFecha           DATE;
    DEFINE cNoBanco         CHAR(3);
    DEFINE cProcesado       CHAR(1);
    DEFINE dFechaHabilAnt   DATE;
    DEFINE cCodigo          CHAR(2);
	DEFINE cDescripcion     CHAR(35);
    DEFINE cValor           CHAR(100);

-----DECLARACIÃN DE VARIABLES ----
    LET cCodRet = '00000';
    LET iSqlErr = 0;
    LET dFecha = null;
	LET cNoBanco = '';    
	LET cProcesado = '';
    LET dFechaHabilAnt = null;
    LET cCodigo = '';
	LET cDescripcion = '';
    LET cValor = '';


    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet),dFecha,cNoBanco,cProcesado,dFechaHabilAnt, cCodigo, cDescripcion, cValor;
		END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cam_datosdia.out';
        --TRACE ON;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF  pBandera = '' OR  pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN TRIM(cCodRet),dFecha,cNoBanco,cProcesado,dFechaHabilAnt, cCodigo, cDescripcion, cValor;
		END IF;

        IF  pBandera = '1' THEN
            EXECUTE PROCEDURE "informix".sp_datosdiahoy_cod47_2(pUsuario, pIdFuncion)
            INTO cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt; 
            RETURN TRIM(cCodRet),dFecha,cNoBanco,cProcesado,dFechaHabilAnt, cCodigo, cDescripcion, cValor;

        ELIF pBandera = '2' THEN
            FOREACH
                EXECUTE PROCEDURE "informix".sp_ope_catalogomotivos2(pUsuario, pIdFuncion)
                INTO cCodRet, cCodigo, cDescripcion
                RETURN TRIM(cCodRet),dFecha,cNoBanco,cProcesado,dFechaHabilAnt, cCodigo, cDescripcion, cValor WITH RESUME;
            END FOREACH;

        ELIF pBandera = '3' THEN
            EXECUTE PROCEDURE "informix".sp_consultaparametrosgenerales2(pUsuario, pIdFuncion, pWhere, pIdParametro)
            INTO cCodRet, cValor;
            RETURN TRIM(cCodRet),dFecha,cNoBanco,cProcesado,dFechaHabilAnt, cCodigo, cDescripcion, cValor;
        END IF;

          IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017'; 
            RETURN TRIM(cCodRet),dFecha,cNoBanco,cProcesado,dFechaHabilAnt, cCodigo, cDescripcion, cValor;
		END IF;


    END;
END PROCEDURE

DOCUMENT 'AUTOR: ING JOSÃ ANTONIO RAMIREZ FRANCO',
'FECHA: 23/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Consulta parÃ¡metros de inicio de carga para pantalla',
'DESCRIPCION: SP MAESTRO ENCARGO DE EJECUTAR SPs CLON DE CAMARA COMPENSACIÃN PARA LA CARGA DE PANTALLA',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_ope_catalogomotivos2(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  CHAR(2) AS codigo,
				  CHAR(35) AS descripcion;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cCodigo CHAR(2);
	DEFINE cDescripcion CHAR(35);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cCodigo = '';
	LET cDescripcion = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigo, cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_catalogomotivos2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodigo, cDescripcion;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodigo, cDescripcion;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultadevcam()
			INTO cCodRetSp, cCodigo, cDescripcion
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_consultadevcam';
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, cCodigo, cDescripcion;
			ELSE
				RETURN cCodRet, cCodigo, cDescripcion WITH RESUME;
			END IF;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 17/02/2016',
'DESCRIPCION: spl CLON que consulta el catalogo motivos de devoluciÃ³n',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_datosdiahoy_cod47_2(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
				  DATE AS dFechaHoy,
				  CHAR(3) AS cNoBanco,
				  CHAR(1) AS cProcesado,
				  DATE AS dFechaHabilAnt;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE cNoBanco CHAR(3);
	DEFINE cNombreArchivo CHAR(30);
	DEFINE iNombrePro INTEGER;
	DEFINE cProcesado CHAR(1);
	DEFINE dFechaHabilAnt DATE;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCodRetSp = '';
	LET dFecha = null;
	LET cNoBanco = '';
	LET cNombreArchivo = '';
	LET iNombrePro = 0;
	LET dFechaHabilAnt = null;
	LET cProcesado = 'f';

	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_datosdiahoy_cod47_2.out';
		--TRACE ON;

		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD

		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END IF;

		--obtiene la fecha Habil del dia.
		SELECT {+INDEX (bdinteg:'informix'.si_fechas idx_si_fechas_fecha_hoy)} fecha_hoy INTO dFecha FROM bdinteg:'informix'.si_fechas;

		--calcula fecha de devolucion habil anterior
		EXECUTE PROCEDURE bditef:'informix'.cal_habil_ant(dFecha)
		INTO cCodRetSp, dFechaHabilAnt;

		IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½?N DEL SP bditef:cal_habil_ant';
		ELIF cCodRetSp::INTEGER = 110 THEN
				LET cCodRet = '00003';
				RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
		END IF;

		--consulta numero banco propio
		SELECT valor INTO cNoBanco FROM bdinteg:si_param WHERE empresa = '001' and cod_param='5';

		--valida si ya fue procesada una eliminaciÃ³n el dÃ­a de hoy
		LET cNombreArchivo = 'ELI_'||TO_CHAR(DATE(dFecha), '%d%m%Y')||'_MN';
		SELECT COUNT(nombrearchivo)
		INTO iNombrePro
		FROM bditef:cce_encabezado
		WHERE nombrearchivo = cNombreArchivo;

		IF iNombrePro <> 0 THEN
			LET cProcesado= 't';
		END IF;

		RETURN cCodRet,dFecha,cNoBanco,cProcesado,dFechaHabilAnt;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA:17/03/2016 ',
'MODULO: OPERACIONES',
'FUNCIONALIDAD:SPL CLON Generador de Archivos',
'DESCRIPCION:SPL CLON Obtiene la fecha actual, cadigo de banco propio y validacion de archivo ya procesado.',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_consultaparametrosgenerales2(pUsuario CHAR(8), pIdFuncion CHAR(10), pWhere CHAR(15), pIdParametro CHAR(15))
		RETURNING CHAR(5) AS codret,
				  CHAR(100) AS valor;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cValor CHAR(100);
	DEFINE cQuery CHAR(500);
	DEFINE sIdFuncion CHAR(10);
	DEFINE sNombreBase CHAR(12);
	DEFINE sNmbreTabla CHAR(40);
	DEFINE sCampo CHAR(20);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cValor = '';
	LET cQuery = '';
	LET sIdFuncion = '';
	LET sNombreBase = '';
	LET sNmbreTabla = '';
	LET sCampo = '';


	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaparametrosgenerales2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pWhere = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cValor;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cValor;
		END IF;

			IF pWhere <> '' THEN
				
				IF pIdParametro = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet, cValor;
				END IF;
				
				SELECT id_funcion, nombre_base, nombre_tabla, nombre_campo
				INTO  sIdFuncion, sNombreBase, sNmbreTabla, sCampo
				FROM bdicnweb:"informix".sw_parametros_generales 
				WHERE id_funcion = pIdFuncion 
				AND id_parametro = pIdParametro;

				IF NVL(sIdFuncion,'') = '' OR NVL(sNombreBase,'') = '' OR NVL(sNmbreTabla,'') = '' OR NVL(sCampo,'') = '' THEN
					LET cCodRet = '00190'; --NO EXISTE VALOR PARA ESTE PARAMETRO
					RETURN cCodRet, cValor;			
				END IF;
			
				LET cQuery = "SELECT" || " "||TRIM(sCampo) || " " ||"FROM" || " " || TRIM(sNombreBase) || ":" ||"'informix'."||TRIM(sNmbreTabla)|| " " ||
				"WHERE" || " " || TRIM(pWhere) || " " ||"=" || " '" || TRIM(pIdParametro) ||"';";
				
				PREPARE countQry FROM TRIM(cQuery);
				DECLARE countcur CURSOR FOR countQry;
				OPEN countcur;
				FETCH countcur INTO cValor;
				IF (SQLCODE = 100) THEN
					LET cCodRet = '00190'; --NO EXISTE VALOR PARA ESTE PARAMETRO
					RETURN cCodRet, cValor;
				END IF;
				WHILE(SQLCODE = 0)
					RETURN cCodRet, cValor WITH RESUME;
					FETCH countcur INTO cValor;
				END WHILE
				CLOSE countcur;
				FREE countcur;
				FREE countQry;
				
			END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 08/07/2015',
'DESCRIPCION: SPL Clon que realiza la consulta de algun parametro de acuerdo a los datos insertados.',
'Donde: pWhere se refiere al nombre del campo a comparar y pIdParametro al valor del parametro a comparar.',
'FUNCIONALIDAD: Envï¿½o/Recepciï¿½n Archivos Bancoppel - Cecoban', 
'MODULO: TEF',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_cam_pro_ctasb3(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pFecha DATE)
RETURNING CHAR(5)   AS codret,
          DATE      AS fecha_hoy,
		  DATE      AS fecha_ant,
		  DATE      AS prox_fecha,
          INTEGER   AS total_registros,
          CHAR(1)   AS status,
		  CHAR(1)   AS error_proceso,
		  CHAR(5)   AS error;

  --DECLARACIÃN DE VARIABLES
    DEFINE cCodRet                  CHAR(5);
	DEFINE iSqlErr                  INTEGER;
    DEFINE dFechaHoy                DATE;
	DEFINE dFechaAnt                DATE; 
	DEFINE dProxFecha               DATE; 
    DEFINE iTotalRegistros          INTEGER;
    DEFINE cStatus                  CHAR(1);
	DEFINE cErrorProceso            CHAR(1);
	DEFINE cError                   CHAR(5);
 
    --INICIALIZACIÃN DE VARIABLES
    LET cCodRet                     = '00000';
    LET iSqlErr                     = 0;
    LET dFechaHoy                   = '';
	LET dFechaAnt                   = '';
	LET dProxFecha                  = ''; 
    LET iTotalRegistros             = 0;
    LET cStatus                     = '';
	LET cErrorProceso               = '';
	LET cError                      = '';

    BEGIN
        ON EXCEPTION SET iSqlErr
		    LET cCodRet = iSqlErr;
		    RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, iTotalRegistros, cStatus, cErrorProceso, cError;
        END EXCEPTION;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
		    RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, iTotalRegistros, cStatus, cErrorProceso, cError;
        END IF;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cam_pro_ctasb3.out';
		--TRACE ON;
 
        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        
        IF pBandera = '1' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consgeneralfechas(pUsuario, pIdFuncion, pIdConsulta)
			INTO cCodRet, dFechaHoy, dFechaAnt, dProxFecha;
            
        ELIF  pBandera = '2' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_procesacargoscuenta(pUsuario, pIdFuncion, pIdConsulta, pFecha)
            INTO cCodRet,iTotalRegistros;

        ELIF  pBandera = '3' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_verificastatuscargocta(pUsuario, pIdFuncion)
			INTO cCodRet,cStatus,iTotalRegistros,cErrorProceso,cError;	
        END IF;


        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
		    RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, iTotalRegistros, cStatus, cErrorProceso, cError;
        END IF;

        RETURN TRIM(cCodRet), dFechaHoy, dFechaAnt, dProxFecha, iTotalRegistros, cStatus, cErrorProceso, cError;
    END
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 07/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 CAMARA PROCESO MANUAL CARGO DE CUENTA',
'DESCRIPCION: SP MAESTRO ENCARGADO DE REALIZAR LAS FUNCIONALIDADES DE BLOQUE 3 CARGO CUENTA';

CREATE PROCEDURE "informix".sp_cam_conctlprocb3(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pIdConsulta CHAR(1), pFecha DATE,  pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING   CHAR(5)     AS codret,
                CHAR(20)    AS proceso,
			    CHAR(10)    AS status,
			    CHAR(8)     AS ejecutivo,
			    DATETIME HOUR TO SECOND AS hora_ini,
			    DATETIME HOUR TO SECOND AS hora_fin,
			    CHAR(5)     AS codret_sp,
                CHAR(20)    AS cuenta,
    			INTEGER     AS cheque,
                INTEGER     AS num_registros,
                DATE        AS fecha_hoy,
			    DATE        AS fecha_ant,
			    DATE        AS prox_fecha;	



  --DECLARACIÃN DE VARIABLES
    DEFINE cCodRet        CHAR(5);
	DEFINE iSqlErr        INTEGER;
    DEFINE cProceso       CHAR(20);
    DEFINE cStatus        CHAR(10);
	DEFINE cEjecutivo     CHAR(8);
	DEFINE dHoraIni       DATETIME HOUR TO SECOND; 
	DEFINE dHoraFin       DATETIME HOUR TO SECOND;
	DEFINE cCodretSp      CHAR(5);
    DEFINE cCuenta        CHAR(20);
	DEFINE iCheque        INTEGER;
    DEFINE iNumRegistros  INTEGER;
    DEFINE dFechaHoy      DATE;
	DEFINE dFechaAnt      DATE; 
	DEFINE dProxFecha     DATE;  
    


    --INICIALIZACIÃN DE VARIABLES
    LET cCodRet     = '00000';
    LET iSqlErr     = 0;
    LET cProceso    = '';
	LET cEjecutivo  = '';
	LET dHoraIni    = ''; 
	LET dHoraFin    = '';
	LET cCodretSp   = '';
	LET cStatus     = '';
    LET cCuenta     = '';
	LET iCheque     = 0;
    LET iNumRegistros = 0;
    LET dFechaHoy   = '';
	LET dFechaAnt   = '';
	LET dProxFecha  = ''; 

     BEGIN
        ON EXCEPTION SET iSqlErr
		    LET cCodRet = iSqlErr;
		    RETURN TRIM(cCodRet), cProceso, cStatus, cEjecutivo, dHoraIni, dHoraFin, cCodretSp,cCuenta, iCheque,iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha;
        END EXCEPTION;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
            LET cCodRet = '00003';
            RETURN TRIM(cCodRet), cProceso, cStatus, cEjecutivo, dHoraIni, dHoraFin, cCodretSp,cCuenta, iCheque,iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha;
        END IF;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cam_conctlprocb3.out';
		--TRACE ON;
 
        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF pBandera = '1' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetalleaplicacioncargoscta(pUsuario, pIdFuncion, pFecha)
            INTO cCodRet, cProceso, cStatus, cEjecutivo, dHoraIni, dHoraFin, cCodretSp;

        ELIF pBandera = '2' THEN
            FOREACH
                EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallechequesprocnocturno(pUsuario, pIdFuncion, pFecha, pRegistros, pRecuperacion)
                INTO cCodRet, cCuenta, iCheque, cProceso, dHoraIni, cCodretSp
                RETURN TRIM(cCodRet), cProceso, cStatus, cEjecutivo, dHoraIni, dHoraFin, cCodretSp,cCuenta, iCheque,iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha WITH RESUME;
            END FOREACH

        ELIF pBandera = '3' THEN
            
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consdetallechequesprocnocturno_totales(pUsuario, pIdFuncion , pFecha)
            INTO cCodRet, iNumRegistros;
            
        ELIF pBandera = '4' THEN
            EXECUTE PROCEDURE bdicnweb:"informix".sp_consgeneralfechas(pUsuario, pIdFuncion, pIdConsulta)
            INTO cCodRet, dFechaHoy, dFechaAnt, dProxFecha;
        END IF;

        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
        END IF;    

        IF pBandera <> '2' THEN
        RETURN TRIM(cCodRet), cProceso, cStatus, cEjecutivo, dHoraIni, dHoraFin, cCodretSp,cCuenta, iCheque,iNumRegistros, dFechaHoy, dFechaAnt, dProxFecha;
        END IF;



    END
END PROCEDURE

DOCUMENT 'AUTOR: ING. JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 07/06/2023',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: CONSULTA DE FUNCIONALIDAD BLOQUE 3 CAMARAS CARGADO DE CUENTA ',
'DESCRIPCION: SP MAESTRO ENCARGADO DE REALIZAR LAS FUNCIONALIDADES DE BLOQUE 3 CARGADO DE PROCESO NOCTURNO';


CREATE PROCEDURE "informix".auditor(pempresa char(3),w_fecha date)



   define dusuario              char(8);

   define dcontrol_poliza       integer;

   define dfecha_captura        date;

   define dsecuencia            integer;

   define dempresa              char(3);

   define dccmayor              char(10);

   define dccsub                char(10);

   define dccsubsub             char(10);

   define dccssubsub            char(10);

   define dccsssubsub           char(10);

   define dsector               char(10);

   define dciudad               char(3);

   define dsucursal             char(4);

   define dnro_auxiliar         char(12);

   define dnaturaleza           char(1);

   define dmonto                money(18,2);

   define ddescripcion_det      char(30);

   define dfecha_valida         date;

   define dmoneda               char(2);

   define dvalor_cambio         money(12,7);

   define dvalor_div_cambio     money(12,7);

   define dmca_aplic            char(1);

   define dpoliza_usuario       char(8);

   define dtipo_mov             char(1);

   define dccosto_orig          char(4);



   define cod_ret    	        char(3);

   define v_user                char(8);

   define v_sucursal            char(4);

   define v_perfil              smallint;

   define v_userini             char(8);

   define v_userfin             char(8);

   define v_regini              char(3);

   define v_regfin              char(3);

   define v_sucini              char(4);

   define v_sucfin              char(4);

   define v_monto               money(18,2);



   define v_tipo_cuenta         char(1);

   define v_auxiliar            char(1);

   define v_nivel               smallint;

   define v_regional            char(3);

   define v_region              integer;

   define i                     integer;

   define contador              integer;

   define conta                 integer;

   define nreg                  integer;

   define v_origen              char(1);

   define v_moneda              char(2);

   define v_creditos            money(18,2);

   define v_debitos             money(18,2);

   define v_cuenta              char(1);

   define inserta               char(2);

   define v_mc1                 smallint;

   define v_mc2                 smallint;

   define lv_ano                smallint;

   define lv_mes                smallint;

   define lv_dia                smallint;

   define band_existe           smallint;

   define wfecha1               date;

--   set debug file to "/pisa/auditor.out";
--   trace on;

   let dusuario = " ";

   let dcontrol_poliza = 0;

   let dfecha_captura = w_fecha;

   let dsecuencia = 0;

   let dempresa = pempresa;

   let dccmayor = " ";

   let dccsub = " ";

   let dccsubsub = " ";

   let dccssubsub = " ";

   let dccsssubsub = " ";

   let dsector = " ";

   let dnro_auxiliar = " ";

   let dccosto_orig = "";

   let cod_ret = "000";





   select mescierre1,mescierre2

   into   v_mc1,      v_mc2

   from   co_param

   where empresa = pempresa;



   delete from co_auditerr

   where empresa = pempresa;



   {if weekday(w_fecha) = 1 then

      let wfecha1 = w_fecha - 2 units day;

   else

      let wfecha1 = w_fecha;

   end if}



   begin work;

   --set isolation to dirty read;
   --set lock mode to wait;
   
   lock table co_detpol in exclusive mode;


   foreach

      select

         usuario,

         control_poliza,

         moneda,

         sum(monto)

      into

         dusuario,

         dcontrol_poliza,

         dmoneda,

         v_debitos

      from

         co_detpol

      where

         fecha_captura = w_fecha

         --fecha_captura between wfecha1 and w_fecha

      and

         naturaleza = "D"

      and

         empresa = pempresa

      group by

         usuario,

         control_poliza,

         moneda

      order by

         usuario,

         control_poliza,

         moneda



      select

         sum(monto)

      into

         v_creditos

      from

         co_detpol

      where

         usuario = dusuario

      and

         control_poliza = dcontrol_poliza

      and

         fecha_captura = w_fecha

         --fecha_captura between wfecha1 and w_fecha

      and

         moneda = dmoneda

      and

         naturaleza = "C"

      and

         empresa = pempresa;



      if (v_creditos is null) then

         let v_creditos = 0;

     end if



      if (v_debitos is null) then

         let v_debitos = 0;

      end if
      if (v_debitos <> v_creditos) then
         let cod_ret = "106";
         insert into
         co_auditerr

         values

         (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

         dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

      end if

   end foreach

   commit work;



   begin work;

      set isolation to dirty read;

      update co_detpol

      set nro_auxiliar = " "

         where (nro_auxiliar = "0" or nro_auxiliar = "000000000"

                or nro_auxiliar = "999999999" or nro_auxiliar = "000000000000"

                or nro_auxiliar = "999999999999") and

                fecha_captura   = w_fecha and

                empresa         = pempresa;

   commit work;



   foreach

      select

         empresa,

         usuario,

         control_poliza,

         fecha_captura,

         moneda

      into

         dempresa,

         dusuario,

         dcontrol_poliza,

         dfecha_captura,

         dmoneda

      from

         co_poliza

      where

         fecha_captura = w_fecha

         --fecha_captura between wfecha1 and w_fecha

      and

         empresa = pempresa



      select

         count(*)

      into

         i

      from

         co_detpol

      where

         usuario = dusuario

      and

         control_poliza = dcontrol_poliza

      and

         fecha_captura = dfecha_captura

      and

         moneda = dmoneda

      and

         empresa = pempresa;



      if i = 0 or i is null then

         delete from

            co_poliza

         where

            usuario = dusuario

         and

            control_poliza = dcontrol_poliza

         and

            fecha_captura = dfecha_captura

         and

            moneda = dmoneda;

      end if

   end foreach



   begin work;

   set isolation to dirty read;

   foreach

      select

         usuario,

         control_poliza,

         fecha_captura,

         naturaleza,

         moneda,

         sum(monto)

      into

         dusuario,

         dcontrol_poliza,

         dfecha_captura,

         dnaturaleza,

         dmoneda,

         v_monto

      from

         co_detpol

      where

         fecha_captura = w_fecha

         --fecha_captura between wfecha1 and w_fecha

      and

         empresa = pempresa

      group by

         usuario,

         control_poliza,

         fecha_captura,

         naturaleza,

         moneda



      select

         count(*)

      into

         i

      from

         co_poliza

      where

         usuario = dusuario

      and

         control_poliza = dcontrol_poliza

      and

        fecha_captura = dfecha_captura

      and

        moneda = dmoneda;



      if i = 0 or i is null then

         insert into

            co_poliza

         values

            (pempresa,

             dusuario,

             dcontrol_poliza,

             dfecha_captura,

             v_monto,

             v_monto,

             v_monto,

             dmoneda,

             "Encabezado creado por auditor");

      end if

   end foreach

   commit work;



   let contador = 0;

   let conta = 0;



   begin work;

   set isolation to dirty read;

   select

      count(*)

   into

      conta

   from

      co_detpol

   where

      fecha_captura = w_fecha

      --fecha_captura between wfecha1 and w_fecha

   and

      empresa = pempresa;



   if (conta is null) then

      let conta = 0;

   end if



   let contador = contador + conta;

   select valor_cambio

   into v_moneda

   from co_param

   where empresa = pempresa;



   let nreg = 0;



   foreach

      select

         "D",

         *

      into

         v_origen,

         dusuario,

         dcontrol_poliza,

         dfecha_captura,

         dsecuencia,

         dempresa,

         dccmayor,

         dccsub,

         dccsubsub,

         dccssubsub,

         dccsssubsub,

         dsector,

         dciudad,

         dsucursal,

         dnro_auxiliar,

         dnaturaleza,

         dmonto,

         ddescripcion_det,

         dfecha_valida,

         dmoneda,

         dvalor_cambio,

         dvalor_div_cambio,

         dmca_aplic,

         dpoliza_usuario,

         dtipo_mov,

         dccosto_orig

      from

         co_detpol

      where

         fecha_captura = w_fecha

         --fecha_captura between wfecha1 and w_fecha

      and

         empresa = pempresa

      LET band_existe = 0;

      {if month(dfecha_captura) != month(dfecha_valida) then

         if (month(dfecha_valida) = v_mc1 or

             month(dfecha_valida) = v_mc2) then

            let lv_ano = year(dfecha_valida);

            let lv_mes = month(dfecha_valida);

            let lv_dia = diasmes(lv_ano,lv_mes);

            if lv_dia != day(dfecha_valida) then

               let cod_ret = "135";

               insert into

               co_auditerr

               values

               (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,

                dccmayor,dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,

                dnro_auxiliar,cod_ret);

            end if

         end if

      end if}



      select

         tipo_cuenta,

         auxiliar

      into

         v_tipo_cuenta,

         v_auxiliar

      from

         bdinteg:si_catalog

      where

         empresa    = dempresa    and

	 ccmayor    = dccmayor    and

	 ccsub      = dccsub      and

	 ccsubsub   = dccsubsub   and

	 ccssubsub  = dccssubsub  and

	 ccsssubsub = dccsssubsub and

	 sector     = dsector;



      if (v_tipo_cuenta is null) then

	 let cod_ret = "100";       {Cuenta contable no existe}

         let band_existe = 1;

         insert into

         co_auditerr

         values

         (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

         dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

      end if

     if band_existe <> 1 then

   	{ Valida que la cuenta no sea de encabezado ni totalizadora }

      if (v_tipo_cuenta = "E" or v_tipo_cuenta = "T") then

         let cod_ret = "101";

         insert into

         co_auditerr

         values

         (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

         dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

      end if



      if (v_auxiliar = "N") then

         if (dnro_auxiliar <> " ") then

            let cod_ret = "118";

            insert into

            co_auditerr

            values

            (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

             dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

         end if

      else

         select

            numero

         into

            v_auxiliar

         from

            co_auxiliar

         where

            empresa = dempresa

         and

            numero = dnro_auxiliar;



         if (v_auxiliar is null) then

            let cod_ret = "102";

            insert into

            co_auditerr

            values

            (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

             dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

         end if

      end if



      select

         sucursal

      into

         v_sucursal

      from

         bdinteg:si_sucursales

      where

         empresa = dempresa

      and sucursal = dsucursal;



      if (v_sucursal is null) then

         let cod_ret = "103";

         insert into

         co_auditerr

         values

         (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

          dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

      end if



      let v_region = 0;

      select count(*)

      into v_region

      from bdinteg:si_regional

      where empresa = dempresa

      and   regional = dciudad;



      if v_region <= 0 then

         let cod_ret = "105";

         insert into

         co_auditerr

         values

         (dusuario,dcontrol_poliza,dfecha_captura,dsecuencia,dempresa,dccmayor,

          dccsub,dccsubsub,dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

      end if



      let v_nivel = 0;

      if dccsssubsub > "00" then

         let v_nivel = 4;

      end if

      if dccssubsub > "00" then

         let v_nivel = 3;

      end if

      if dccsubsub > "00" then

         let v_nivel = 2;

      end if

      if dccsub > "00" then

         let v_nivel = 1;

      end if



      for i = 1 to v_nivel

	  if i = 4 then

             select

                tipo_cuenta

             into

                v_cuenta

             from

             bdinteg:si_catalog

             where

                bdinteg:si_catalog.empresa    =   dempresa   and

                bdinteg:si_catalog.ccmayor    =   dccmayor   and

                bdinteg:si_catalog.ccsub      =   dccsub     and

                bdinteg:si_catalog.ccsubsub   =   dccsubsub  and

                bdinteg:si_catalog.ccssubsub  =   dccssubsub and

                bdinteg:si_catalog.ccsssubsub =   "00"       and

                bdinteg:si_catalog.sector     =   "00";



             if (v_cuenta is null) then

                let cod_ret = "100";

                insert into

                co_auditerr

                values

                (dusuario,dcontrol_poliza,dfecha_captura,

                 dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                 dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

             else

                if (v_cuenta <> "T") then

                   if dccmayor <> "7000" then

                      let cod_ret = "113";

                      insert into

                      co_auditerr

                      values

                      (dusuario,dcontrol_poliza,dfecha_captura,

                      dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                      dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

                   end if

                end if

             end if

          end if

          if i = 3 then

             select

                tipo_cuenta

             into

                v_cuenta

             from

             bdinteg:si_catalog

             where

                bdinteg:si_catalog.empresa    =   dempresa   and

                bdinteg:si_catalog.ccmayor    =   dccmayor   and

                bdinteg:si_catalog.ccsub      =   dccsub     and

                bdinteg:si_catalog.ccsubsub   =   dccsubsub  and

                bdinteg:si_catalog.ccssubsub  =   "00"       and

                bdinteg:si_catalog.ccsssubsub =   "00"       and

                bdinteg:si_catalog.sector     =   "00";



             if (v_cuenta is null) then

                let cod_ret = "100";

                insert into

                co_auditerr

                values

                (dusuario,dcontrol_poliza,dfecha_captura,

                 dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                 dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

             else

                if (v_cuenta <> "T") then

                   if dccmayor <> "7000" then

                      let cod_ret = "113";

                      insert into

                      co_auditerr

                      values

                      (dusuario,dcontrol_poliza,dfecha_captura,

                      dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                      dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

                   end if

                end if

             end if

          end if

          if i = 2 then

             select

                tipo_cuenta

             into

                v_cuenta

             from

             bdinteg:si_catalog

             where

                bdinteg:si_catalog.empresa    =   dempresa   and

                bdinteg:si_catalog.ccmayor    =   dccmayor   and

                bdinteg:si_catalog.ccsub      =   dccsub     and

                bdinteg:si_catalog.ccsubsub   =   "00"       and

                bdinteg:si_catalog.ccssubsub  =   "00"       and

                bdinteg:si_catalog.ccsssubsub =   "00"       and

                bdinteg:si_catalog.sector     =   "00";



             if (v_cuenta is null) then

                let cod_ret = "100";

                insert into

                co_auditerr

                values

                (dusuario,dcontrol_poliza,dfecha_captura,

                 dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                 dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

             else

                if (v_cuenta <> "T") then

                 if dccmayor <> "7000" then

                   let cod_ret = "113";

                   insert into

                   co_auditerr

                   values

                   (dusuario,dcontrol_poliza,dfecha_captura,

                    dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                    dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

                  end if

                end if

             end if

          end if

	  if i = 1 then

             select

                tipo_cuenta

             into

                v_cuenta

             from

             bdinteg:si_catalog

             where

                bdinteg:si_catalog.empresa    =   dempresa   and

                bdinteg:si_catalog.ccmayor    =   dccmayor   and

                bdinteg:si_catalog.ccsub      =   "00"       and

                bdinteg:si_catalog.ccsubsub   =   "00"       and

                bdinteg:si_catalog.ccssubsub  =   "00"       and

                bdinteg:si_catalog.ccsssubsub =   "00"       and

                bdinteg:si_catalog.sector     =   "00";



             if (v_cuenta is null) then

                let cod_ret = "100";

                insert into

                co_auditerr

                values

                (dusuario,dcontrol_poliza,dfecha_captura,

                 dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                 dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

             else

                if (v_cuenta <> "T"

                   and dccmayor[3,4] = "00"

                   and dccmayor[1] <> 5

                   and dccmayor[1] <> 6) then

                   if dccmayor <> "7000" then

                   let cod_ret = "113";

                   insert into

                   co_auditerr

                   values

                   (dusuario,dcontrol_poliza,dfecha_captura,

                    dsecuencia,dempresa,dccmayor,dccsub,dccsubsub,

                    dccssubsub,dccsssubsub,dsector,dnro_auxiliar,cod_ret);

                   end if

                end if

             end if

         end if

      end for

     end if

   end foreach

   commit work;



end procedure;