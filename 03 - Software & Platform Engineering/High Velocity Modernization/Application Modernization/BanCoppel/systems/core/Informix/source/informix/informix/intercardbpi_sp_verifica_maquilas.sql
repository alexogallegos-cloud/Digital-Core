CREATE PROCEDURE "informix".sp_verifica_maquilas()

RETURNING 	VARCHAR(6) as Cod_ret,
			VARCHAR(80) as Men_ret;
			


-- Variables generales 

	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	
-- Variables de retorno
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);


-- Variables para banderas de maquila automatica	
	DEFINE  vsmaqaut          CHAR (1);
	DEFINE  vsdlunmaqaut	  CHAR (1);
	DEFINE  vsdmarmaqaut	  CHAR (1);
	DEFINE  vsdmiemaqaut	  CHAR (1);
	DEFINE  vsdjuemaqaut	  CHAR (1);
	DEFINE  vsdviemaqaut	  CHAR (1);
	DEFINE  vsdsabmaqaut	  CHAR (1);
	DEFINE  vsddommaqaut	  CHAR (1);
	
--  Variables para banderas de maquila manual	
	DEFINE  vsmaqman		  CHAR (1);
	DEFINE  vsdlunmaqman	  CHAR (1);
	DEFINE  vsdmarmaqman	  CHAR (1);
	DEFINE  vsdmiemaqman	  CHAR (1);
	DEFINE  vsdjuemaqman	  CHAR (1);
	DEFINE  vsdviemaqman	  CHAR (1);
	DEFINE  vsdsabmaqman	  CHAR (1);
	DEFINE  vsddommaqman	  CHAR (1);

--  Variable para verificacion de maquilas 
	DEFINE  vsbanvermaq	  CHAR (1);
	
	DEFINE vifecha_hoy 		integer;
	
--	SET DEBUG FILE TO "/informix/HomeInformix/rrm/sp_verifica_maquilas.out";
--	TRACE ON;

BEGIN

   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET  = SQL_ERR;
		LET P_MENSAJE  = ERROR_INFO  || ' ' || ISAM_ERR;
	  
      RETURN 	NVL(P_COD_RET,''),
				NVL (P_MENSAJE,'');
				
	  
   END EXCEPTION;

-- Variables de codigo de retorno	
	LET P_COD_RET = '';
	LET P_MENSAJE = '';

-- Variables para banderas de maquila automatica	
	LET  vsmaqaut = '';
	LET  vsdlunmaqaut = '';
	LET  vsdmarmaqaut = '';
	LET  vsdmiemaqaut = '';
	LET  vsdjuemaqaut = '';
	LET  vsdviemaqaut = '';
	LET  vsdsabmaqaut = '';
	LET  vsddommaqaut = '';
	
--  Variables para banderas de maquila manual	
	LET  vsmaqman = '';
	LET  vsdlunmaqman = '';
	LET  vsdmarmaqman = '';
	LET  vsdmiemaqman = '';
	LET  vsdjuemaqman = '';
	LET  vsdviemaqman = '';
	LET  vsdsabmaqman = '';
	LET  vsddommaqman = '';

--  Variable para verificacion de maquilas 
	LET  vsbanvermaq	= '';
	LET vifecha_hoy = 7;
	
	set isolation to dirty read;
	set lock mode to wait 3;
	select weekday(fecha_hoy) into vifecha_hoy from Bdinteg:"informix".si_fechas;
	
	set isolation to dirty read;
	set lock mode to wait 3;
	select 	BanMaqAut, BanMaqMan, BanVerifMaq 
		into vsmaqaut, vsmaqman, vsbanvermaq
	from  Intercard:"informix".paraminventarios;

	if vsbanvermaq = 'V' then 
		LET P_COD_RET = '00001';
		LET P_MENSAJE = 'Hay maquilas activas que verificar';
	else 
		LET P_COD_RET = '00002';
		LET P_MENSAJE = 'No estan programadas las maquilas de forma correcta';
		RETURN	
				NVL(P_COD_RET,''),
				NVL (P_MENSAJE,'');
	end if;
	
	if (p_cod_ret = '00001') then
		
		if ((vsmaqaut = 'V') and (vsmaqman = 'V')) then
					set isolation to dirty read;
					select 	BanDLunMaqAut, BanDMarMaqAut, BanDMieMaqAut, BanDJueMaqAut,	BanDVieMaqAut, BanDSabMaqAut, BanDDomMaqAut, 
							BanDLunMaqMan,	BanDMarMaqMan, BanDMieMaqMan, BanDJueMaqMan, BanDVieMaqMan, BanDSabMaqMan,BanDDomMaqMan
					into 
							vsdlunmaqaut, vsdmarmaqaut, vsdmiemaqaut, vsdjuemaqaut,	vsdviemaqaut, vsdsabmaqaut, vsddommaqaut, 
							vsdlunmaqman, vsdmarmaqman, vsdmiemaqman, vsdjuemaqman, vsdviemaqman, vsdsabmaqman, vsddommaqman
					from Intercard:"informix".paraminventarios;
				
				if ((vifecha_hoy = 0)  and (vsddommaqaut = 'V') and (vsddommaqman = 'F')) then 
				
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 1)  and (vsdlunmaqaut = 'V') and (vsdlunmaqman = 'F')) then
				
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 2)  and (vsdmarmaqaut = 'V') and (vsdmarmaqman = 'F')) then

					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 3)  and (vsdmiemaqaut = 'V') and (vsdmiemaqman = 'F')) then
					
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 4)  and (vsdjuemaqaut = 'V') and (vsdjuemaqman = 'F')) then
					
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 5)  and (vsdviemaqaut = 'V') and (vsdviemaqman = 'F')) then
					
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 6)  and (vsdsabmaqaut = 'V') and (vsdsabmaqman = 'F')) then
					
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 0)  and (vsddommaqaut = 'F') and (vsddommaqman = 'V')) then 
					
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 1)  and (vsdlunmaqaut = 'F') and (vsdlunmaqman = 'V')) then
					
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 2)  and (vsdmarmaqaut = 'F') and (vsdmarmaqman = 'V')) then
					
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 3)  and (vsdmiemaqaut = 'F') and (vsdmiemaqman = 'V')) then
					
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 4)  and (vsdjuemaqaut = 'F') and (vsdjuemaqman = 'V')) then
					
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 5)  and (vsdviemaqaut = 'F') and (vsdviemaqman = 'V')) then
				
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 6)  and (vsdsabmaqaut = 'F') and (vsdsabmaqman = 'V')) then
					
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				else 
				
					LET P_COD_RET = '00004';
					LET P_MENSAJE = 'No hay maquila automatica o manual configurada correctamente';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				end if;

		elif ((vsmaqaut = 'V') and (vsmaqman = 'F')) then
		
				set isolation to dirty read;
				select 	BanDLunMaqAut, BanDMarMaqAut, BanDMieMaqAut, BanDJueMaqAut,	BanDVieMaqAut, BanDSabMaqAut, BanDDomMaqAut
						into vsdlunmaqaut, vsdmarmaqaut, vsdmiemaqaut, vsdjuemaqaut, vsdviemaqaut, vsdsabmaqaut, vsddommaqaut
				from Intercard:"informix".paraminventarios;
				
				if ((vifecha_hoy = 0)  and (vsddommaqaut = 'V')) then 
					
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 1)  and (vsdlunmaqaut = 'V')) then
				
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 2)  and (vsdmarmaqaut = 'V')) then
					
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
					
				elif ((vifecha_hoy = 3)  and (vsdmiemaqaut = 'V')) then
					
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 4)  and (vsdjuemaqaut = 'V')) then
				
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 5)  and (vsdviemaqaut = 'V')) then
				
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 6)  and (vsdsabmaqaut = 'V')) then
				
					LET P_COD_RET = '00010';
					LET P_MENSAJE = 'Ejecutar maquila automática';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
				else
				
					LET P_COD_RET = '00004';
					LET P_MENSAJE = 'No hay maquila automatica configurada correctamente';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
				end if;

		elif ((vsmaqaut = 'F') and (vsmaqman = 'V')) then
				set isolation to dirty read;
				select 	BanDLunMaqMan,	BanDMarMaqMan, BanDMieMaqMan, BanDJueMaqMan, BanDVieMaqMan, BanDSabMaqMan,BanDDomMaqMan
						into vsdlunmaqman, vsdmarmaqman, vsdmiemaqman, vsdjuemaqman, vsdviemaqman, vsdsabmaqman, vsddommaqman
				from Intercard:"informix".paraminventarios;
				
				if ((vifecha_hoy = 0)  and (vsddommaqman = 'V')) then 
				
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 1)  and (vsdlunmaqman = 'V')) then
				
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 2)  and (vsdmarmaqman = 'V')) then
				
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 3)  and (vsdmiemaqman = 'V')) then
				
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 4)  and (vsdjuemaqman = 'V')) then
				
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 5)  and (vsdviemaqman = 'V')) then
				
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				elif ((vifecha_hoy = 6)  and (vsdsabmaqman = 'V')) then
					
					LET P_COD_RET = '00020';
					LET P_MENSAJE = 'Ejecutar maquila manual';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
							
				else 
				
					LET P_COD_RET = '00004';
					LET P_MENSAJE = 'No hay maquila manual configurada';
					RETURN	
							NVL(P_COD_RET,''),
							NVL (P_MENSAJE,'');
				end if;
		end if;
	else
		
		LET P_COD_RET = '00002';
		LET P_MENSAJE = 'No estan programadas las maquilas de forma correcta';
			RETURN	
				NVL(P_COD_RET,''),
				NVL (P_MENSAJE,'');
	end if;
	
end
end procedure
;