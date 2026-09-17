create procedure "informix".sp_listaview(pfecha date,patm char(4))
RETURNING char(03),
		  char(10),
		  char(4) ,
		  char(18),
		  char(18),
		  char(18),
		  char(18),
		  char(18),
		  char(18),
		  char(18),
		  char(18),
		  char(16),
		  char(16);
		  
		  
		  
		--variables retorno   
DEFINE	  rfecha        char(10);
DEFINE    rsucursal     char(4) ;
DEFINE    rdeno1        char(30);
DEFINE    rdeno2        char(18);
DEFINE    rdeno3        char(18);
DEFINE    rdeno4        char(18);
DEFINE    radeno1       char(18);
DEFINE    radeno2       char(18);
DEFINE    radeno3       char(18);
DEFINE    radeno4       char(18);
DEFINE    rmonto        char(16);
DEFINE    ramonto       char(16);
define	cont			integer;
		  
		  
		  
		  
		  
		  
		  
		  
		   
	DEFINE cod_ret 	char(03);
	DEFINE	mensaje	char(50);
	
    DEFINE iSqlErr                integer;
    DEFINE iSamErr             integer;
    DEFINE vDesErr             VARCHAR(50);
	
 


begin	
 ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cod_ret = iSqlErr;    
			LET mensaje =  vDesErr;
        END IF;
        RETURN cod_ret,rfecha,rsucursal ,rdeno1,rdeno2,rdeno3 ,rdeno4,radeno1,radeno2,radeno3,radeno4,rmonto,ramonto  ; 
	
 END EXCEPTION;
 
	let cod_ret = '000'; 
	let rfecha   ='';
	let rsucursal='';
	let rdeno1   ='';
	let rdeno2   ='';
	let rdeno3   ='';
	let rdeno4   ='';
	let radeno1  ='';
	let radeno2  ='';
	let radeno3  ='';
	let radeno4  ='';
	let rmonto   ='';
	let ramonto  ='';	
	let cont =0;
	
	SELECT count(*)  
	into cont
	FROM bdisuc:ss_corteadminview WHERE atm = patm and fecha = pfecha;
	
	if cont <> 0 THEN
			SELECT *  
			into rfecha,rsucursal,rdeno1,rdeno2,rdeno3,rdeno4,radeno1,radeno2,radeno3,radeno4,rmonto,ramonto  
			FROM bdisuc:ss_corteadminview WHERE atm = patm and fecha = pfecha;
			
			RETURN cod_ret,rfecha,rsucursal,rdeno1,rdeno2,rdeno3,rdeno4,radeno1,radeno2,radeno3,radeno4,rmonto,ramonto  ;
	else
		let cod_ret= '007';
		let rdeno1='no se encontraron registros';
		let rdeno2=cont;
	end if ;
	
	 RETURN cod_ret,rfecha,rsucursal,rdeno1,rdeno2,rdeno3,rdeno4,radeno1,radeno2,radeno3,radeno4,rmonto,ramonto  ;
end	
end procedure;