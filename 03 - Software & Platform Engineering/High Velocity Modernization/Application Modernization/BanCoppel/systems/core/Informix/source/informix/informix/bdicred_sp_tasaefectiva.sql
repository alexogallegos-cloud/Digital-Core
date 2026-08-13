create procedure "informix".sp_tasaefectiva(pmonto decimal(18,2),pcomisap decimal(18,2),ptasacontrac_an decimal(18,9),ppagos integer,ptipofac char(1)) --trace1
									
        --CHAR(1); -- Bandera
		--RETURNING   CHAR(5), CHAR(100), char(60);
		RETURNING  DECIMAL(18,8), DECIMAL(18,5);

--Declaracion de variables.
/*
DEFINE sql_err      INT;
DEFINE cod_ret      CHAR(6);
DEFINE s_regreso    CHAR(1);
*/

DEFINE iSqlErr      					INTEGER;
DEFINE iIsamErr         				INTEGER;
DEFINE cErrorInfo       				CHAR(100);
DEFINE cCodRet          				CHAR(6);
DEFINE cMensajeRet    					CHAR(100);
DEFINE cMensajeRet2    	CHAR(60);
DEFINE Ini_proc char(22);  	DEFINE Fin_proc char(22);

DEFINE vporcen_tasa_men DECIMAL(18,9); 
DEFINE vtasa_mensual  DECIMAL (18,9);
DEFINE vtasa_mensual_1 DECIMAL(18,15);
DEFINE vpago_int_mensual DECIMAL(18,9); 
DEFINE vtasa_pagointmens DECIMAL(18,9); 
DEFINE vpago_mensual DECIMAL(18,9); 
DEFINE var3prosum DECIMAL(18,9); 
DEFINE vtotal_pagos_per DECIMAL(18,9); 
DEFINE vvalinicial DECIMAL(18,9); 
DEFINE Var6 DECIMAL(18,9); 
DEFINE vtotal DECIMAL(18,9); 
DEFINE Var8 DECIMAL(18,9); 
DEFINE Var9 DECIMAL(18,9); 
DEFINE Var10 DECIMAL(18,9); 
DEFINE Var11 DECIMAL(18,9); 
DEFINE Var12 DECIMAL(18,9); 
DEFINE Var13 DECIMAL(18,9); 
DEFINE Var14 DECIMAL(18,9); 
DEFINE Var15 DECIMAL(18,9); 
DEFINE Var16 DECIMAL(18,9); 
DEFINE Var17 DECIMAL(18,9);
DEFINE Var17Aux DECIMAL(18,9);  
DEFINE FlagVar17 DECIMAL(1,0);
DEFINE FlagVar18 DECIMAL(1,0);
DEFINE Var18 DECIMAL(18,9);  
DEFINE vcontper integer;
--DEFINE COUNTER_REG DECIMAL(5,0);
DEFINE VarInc DECIMAL(18,9); 
DEFINE VarInc2 DECIMAL(18,9);
DEFINE VarIncSum DECIMAL(18,9); 
DEFINE VVan DECIMAL (18,9);
DEFINE VVan2 DECIMAL (18,9);
DEFINE vtir DECIMAL(18,9); 

DEFINE vtir_mensual DECIMAL (18,9);
DEFINE vtir_anual DECIMAL (18,9);
DEFINE vportir_an DECIMAL (18,9);
DEFINE var_dec DECIMAL (18,15);

--LET s_regreso = '0';

LET iSqlErr                         = 0;
LET iIsamErr         				= 0;
LET cErrorInfo       				= "";
LET cCodRet          				= "00000";


LET vporcen_tasa_men =0;
LET vtasa_mensual = 0;
LET vtasa_mensual_1 =0;
LET  vpago_int_mensual =0;
LET  vtasa_pagointmens =0;
LET  vpago_mensual =0;
LET  var3prosum =0;
LET  vtotal_pagos_per =0;
LET  vvalinicial =0;
LET  Var6 =0;
LET  vtotal =0;
LET  Var8 =0;
LET  Var9 =0;
LET  Var10 =0;
LET  Var11 =0;
LET  Var12 =0;
LET  Var13 =0;
LET  Var14 =0;
LET  Var15 =0;
LET  Var16 =0;
LET  Var17 =0;
LET  Var17Aux =0; 
LET  FlagVar17 =0;
LET  FlagVar18 =0;
LET  Var18 =0; 
LET  vcontper =1;
--LET  COUNTER_REG DECIMAL(5,0);
LET  VarInc =0;
LET  VarInc2 =0;
LET  VarIncSum =0;
LET VVan = 0;
LET  vtir =0;
LEt var_dec = 0;

BEGIN

    --Errores no controlados.
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
	  	  LET cMensajeRet2 = '';
		 -- IF (val_trans_Commit = -1) THEN
			--rollback work;
		 --- END IF; 
			
		  RETURN cCodRet, cMensajeRet;    END EXCEPTION;
	
--SET DEBUG FILE TO "/RESPALDOS/INFOSAT/TIR/sp_tasaefectiva_v2.out";
--TRACE ON;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
--SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc   FROM sysmaster:sysshmvals;

IF ptasacontrac_an = 0 OR pmonto <= pcomisap OR ppagos = 0 THEN
		LET vtir_mensual = 0;
		LET vtir_anual = 0;
		LET vportir_an =0;		
ELIF pcomisap = 0 THEN
	LET vporcen_tasa_men = ptasacontrac_an/12;	
	LET vtasa_mensual = vporcen_tasa_men/100;	
	
	LET vtir_mensual = vtasa_mensual;
	LET vtir_anual = ptasacontrac_an/100;
	LET vportir_an =ptasacontrac_an;	
ELSE

  LET vporcen_tasa_men = ptasacontrac_an/12;
  LET vtasa_mensual = vporcen_tasa_men/100;
  
  
  LET vpago_int_mensual = (pmonto*vtasa_mensual);
  
  LET vtasa_pagointmens = ((1- (POW((1+vtasa_mensual),-ppagos))));
  
  LET vpago_mensual = vpago_int_mensual/vtasa_pagointmens;

  LET vtotal_pagos_per = vpago_mensual * ppagos;  
  
  LET vvalinicial = -1*(pmonto-pcomisap);
  
  LET vcontper = 1;
  
  LET vtotal = 0;

--Calculo VAN ORIGINAL  
  WHILE vcontper <= ppagos LOOP	
	LET vtotal = vtotal+(vpago_mensual/(pow(1+vtasa_mensual,vcontper)));
	LET vcontper = (vcontper+1);
  END LOOP
	LET VVan = vvalinicial + vtotal;
	
    LET vcontper = 1;  
	LET vtotal = 0;
	LET VVan2 = VVan;	
	let var_dec = .001;
	
	LET vtasa_mensual_1 = vtasa_mensual;	
--Proyeccion VAN, para definicion de TIR
	WHILE round(VVan2,4) <> 0 LOOP
		let var_dec = var_dec / 10;
		let VVan2 = 1;
		WHILE  VVan2 > 0 LOOP	
			LET vtasa_mensual_1 = vtasa_mensual_1 + var_dec;	
			LET vcontper = 1;  
			LET vtotal = 0;
			LET VVan2 = 0;
			WHILE vcontper <= ppagos LOOP
				LET vtotal = vtotal+(vpago_mensual/(pow(1+vtasa_mensual_1,vcontper)));
				LET vcontper = (vcontper+1);
			END LOOP
			LET VVan2 =vvalinicial + vtotal;
		END LOOP
		if VVan2 < 0 then
			let vtasa_mensual_1 = vtasa_mensual_1 - var_dec;		
		end if;
	END LOOP
     
	 LET vtir_mensual = round(vtasa_mensual_1,8);
	 LET vtir_anual = round(vtir_mensual * 12,5);
	 LET vportir_an =vtir_anual*100;
END IF;	 
--SELECT DBINFO('utc_to_datetime', sh_curtime) INTO fin_proc  FROM sysmaster:sysshmvals;
	
   -- LET cCodRet     = "00000";
    --LET cMensajeRet = "TIR: " ||vtasa_mensual_1;
	--LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc ;	
	
	--RETURN cCodRet, cMensajeRet, cMensajeRet2;
	
	RETURN vtir_mensual,vtir_anual;END
END PROCEDURE

;