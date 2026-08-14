CREATE PROCEDURE "informix".sp_graba_indicador(		   pempresa 	CHAR(3), 
                                                       pNumcredito	CHAR(20),
													   pMonto		DECIMAL(18,2),
                                                       pTransacc	VARCHAR(4),
													   pCodigoFun	CHAR(3),
													   pCodigoRef	INTEGER,
                                                       pFecha DATE, 
													   pFolio 	CHAR(16),
													   pVencido		INTEGER,													   
													   Monto2		DECIMAL (18,2),
													   pIndicador SMALLINT
													   )  
       RETURNING char(5);
   


--declaracion de variables
------------------------------------------------------------
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cMensaje		CHAR(80);
DEFINE	cCod_ret		CHAR(6);

--DEFINE	vIndicador		LIKE bdicred:sd_indicador_cred.row;
DEFINE	vPagoCliente	CHAR(1);
DEFINE	vcantReg		SMALLINT;
------------------------------------------------
------------------------------------------------
DEFINE	vtipotrans			char(1);
DEFINE	vlSentido		    char(1);
DEFINE  vlTransaccion		CHAR(4);
DEFINE vMtoReversion			DECIMAL(16,2);

DEFINE vFecPrimerCompra		DATE; 
DEFINE vMtoPrimerCompra 	DECIMAL(16,2);
DEFINE vTransPrimerCompra 	CHAR(4);
DEFINE vfecPrimerDisp		DATE; 
DEFINE vMontoPrimerDisp		DECIMAL(16,2); 
DEFINE vTransPrimerDisp		CHAR(4);
DEFINE vFolioPosDisp		CHAR(16);  
DEFINE vFolioAtmDisp		CHAR(16);  
DEFINE vFolioVntDisp		CHAR(16); 		  			  
DEFINE vFecUltPago			DATE; 
DEFINE vMtoUltPago			DECIMAL(16,2);
DEFINE vTransUltPago		CHAR(4);	
DEFINE vFolioUltPago		CHAR(16); 
DEFINE vAtmDispMto			DECIMAL(16,2);
DEFINE vAtmDispFec			DATE;
DEFINE vAtmDispTransacc		CHAR(4);
DEFINE vPosDispMto			DECIMAL(16,2);
DEFINE vPosDispFecha		DATE;
DEFINE vPosDispTransacc		CHAR(4);
DEFINE vvntDispMto			DECIMAL(16,2);
DEFINE vvntDispFec			DATE; 
DEFINE vFecUltPagoRev		DATE; 
DEFINE vMtoUltPagoRev		DECIMAL(16,2);      
DEFINE vTransUltPagoRev		CHAR(4);
DEFINE UltPagoRev		CHAR(16); 
DEFINE vatmDispMtoRev		DECIMAL(16,2);
DEFINE vAtmDispFecRev		DATE;
DEFINE vAtmDispTransaccRev	CHAR(4);
DEFINE vFolioAtmDispRev		CHAR(16); 
DEFINE vPosDispMtoRev		DECIMAL(16,2);
DEFINE vPosDispFecRev		DATE;
DEFINE vPosDispTransaccRev	CHAR(4); 
DEFINE vFolioPosDispRev		CHAR(16); 	    
DEFINE vvntDispMtoRev		DECIMAL(16,2);
DEFINE vvntDispFecRev		DATE; 
DEFINE vFolioVntDispRev		CHAR(16);
DEFINE vfolioultpagorev		CHAR(16);
DEFINE vRevPAGO				CHAR(1);
DEFINE vRevATM				CHAR(1);
DEFINE vRevPOS				CHAR(1);
DEFINE vRevVTN				CHAR(1);
DEFINE vlnum_avisos         CHAR(1);
DEFINE vlSaldoMaximo		DECIMAL (16,2);

DEFINE  vMtoAcumulado	DECIMAL(18,2);
DEFINE	vNumTrans	INTEGER;
DEFINE	bContinua	Char(1);
DEFINE	vlNumVencidos		SMALLINT;
DEFINE  vIndFico    CHAR(1);

DEFINE vproceso			CHAR(4);
DEFINE cRCodRet			CHAR(6);

--vPagoCliente|| '-Indicador-'||pIndicador||'-vtipotrans-'|| vtipotrans  

------------------------------------------------

--SET DEBUG FILE TO '/temp/sp_graba_indicador.out';
--SET DEBUG FILE TO '/informix/macf/sp_graba_indicador.out';
--TRACE ON;

    LET cCod_ret      = '000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';	
	
	LET vPagoCliente  = '';
	LET vMtoPrimerCompra  = NULL;
	LET vFecPrimerCompra	= NULL;		
	LET vtipotrans = '';	
	
	LET vFecPrimerCompra	=DATE(1);
	LET vMtoPrimerCompra 	=0;
	LET vTransPrimerCompra 	='';
	LET vfecPrimerDisp		=NULL;
	LET vMontoPrimerDisp	=NULL;
	LET vTransPrimerDisp	='';
	LET vFolioUltPago		='';
	LET vFolioPosDisp		='';
	LET vFolioAtmDisp		='';
	LET vFolioVntDisp		='';
	LET vFecUltPago			=DATE(1);
	LET vMtoUltPago			=0;
	LET vTransUltPago		='';
	LET vFolioUltPago		='';
	LET vAtmDispMto			=0;
	LET vAtmDispFec			=DATE(1);
	LET vAtmDispTransacc	='';
	LET vFolioAtmDisp		='';
	LET vPosDispMto			=0;
	LET vPosDispFecha		=DATE(1);
	LET vPosDispTransacc	='';
	LET vvntDispMto			=0;
	LET vvntDispFec			=DATE(1);	
	LET vFecUltPagoRev		=DATE(1);
	LET vMtoUltPagoRev		=0;
	LET vTransUltPagoRev	='';
	LET vFolioUltPagoRev	='';
	    
	LET vatmDispMtoRev		=0;
	LET vAtmDispFecRev		=DATE(1);
	LET vAtmDispTransaccRev	='';
	LET vFolioAtmDispRev	='';
	LET vPosDispMtoRev		=0;
	LET vPosDispFecRev		=DATE(1);
	LET vPosDispTransaccRev	='';
	LET vFolioPosDispRev	='';
	LET vvntDispMtoRev		=0;
	LET vvntDispFecRev		=DATE(1);
	LET vFolioVntDispRev	='';	
	LET bContinua = 'V';		
	LET vlSentido = '';
	LET vMtoReversion = 0;  
	LET	vlNumVencidos = 0;
	LET vRevPAGO = '';
	LET vRevATM = '';
	LET vRevPOS = '';
	LET vRevVTN = '';
    LET vlnum_avisos = 0;
	LET vlSaldoMaximo = 0.0;
    LET vIndFico = '';
	
	LET vproceso		= '0119';
	LET cRCodRet		= '00000';
	
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			insert into bdicobranza:cb_bitacora (mensaje) values  (error_info);		
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCod_ret, trim(cMensaje)||'-'||isam_err::CHAR ||'-'||trim(pNumcredito)||'-'||pFecha, '02') Returning cRCodRet;
            RETURN cCod_ret;
        END EXCEPTION;		
    SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		--insert into bdicobranza:cb_bitacora (mensaje) values  (pCodigoFun||'-Primer Compra-'||pTransacc);		
		---Consulta indicadores que pueden tener reversiÃÂ³n
		select ---monto_primer_compra, f_primer_compra, pos_disp_fecha, atm_disp_fecha,  vnt_disp_fecha		
			  f_primer_compra, monto_primer_compra, trans_primer_compra,  	
			  f_primer_disp, monto_primer_disp, trans_primer_disp,    		
			  nvl(folio_ultimo_pago,''), nvl(folio_pos_disp,''), nvl(folio_atm_disp,''), --folio_vnt_disp,       	
			  fecha_ultimo_pago,monto_ultimo_pago,trans_ultimo_pago,nvl(folio_ultimo_pago,''),
			  atm_disp_monto,atm_disp_fecha,atm_disp_transacc,--folio_atm_disp,
		       pos_disp_monto,pos_disp_fecha,pos_disp_transacc, --folio_pos_disp,
               vnt_disp_monto,vnt_disp_fecha, nvl(folio_vnt_disp,''),
			   fecha_ultimo_pago_rev, monto_ultimo_pago_rev, trans_ultimo_pago_rev,nvl(folio_ultimo_pago_rev,''),	    	    
			   atm_disp_monto_rev,atm_disp_fecha_rev,atm_disp_transacc_rev,nvl(folio_atm_disp_rev,''),
		       pos_disp_monto_rev,pos_disp_fecha_rev,pos_disp_transacc_rev, nvl(folio_pos_disp_rev,''),	    
			   vnt_disp_monto_rev,vnt_disp_fecha_rev, nvl(folio_vnt_disp_rev,'')

			   
		  into vFecPrimerCompra, vMtoPrimerCompra, vTransPrimerCompra,  	
			   vfecPrimerDisp, vMontoPrimerDisp, vTransPrimerDisp ,   					   
			   vFolioultPago, vFolioPosDisp, vFolioAtmDisp, --vFolioVntDisp,		  			  
			   vFecUltPago, vMtoUltPago,vTransUltPago,vFolioUltPago,
			   vAtmDispMto,vAtmDispFec,vAtmDispTransacc,--vFolioAtmDisp,
		       vPosDispMto,vPosDispFecha,vPosDispTransacc, --vFolioPosDisp,
               vvntDispMto,vvntDispFec, vFolioVntDisp,			   
			   vFecUltPagoRev, vMtoUltPagoRev, vTransUltPagoRev,vFolioUltPagoRev,
			   vatmDispMtoRev,vAtmDispFecRev,vAtmDispTransaccRev,vFolioAtmDispRev,
		       vPosDispMtoRev,vPosDispFecRev,vPosDispTransaccRev, vFolioPosDispRev,	    
			   vvntDispMtoRev,vvntDispFecRev, vFolioVntDispRev
		 from bdicred:sd_indicador_cred
		WHERE empresa = pEmpresa
          and num_credito = pNumcredito;  
		  
		
		LET vCantReg = DBINFO("sqlca.sqlerrd2");
        --- Inserta el indicador en Caso de que no exista
        IF vCantReg = 0 THEN
            insert into bdicred:"informix".sd_indicador_cred (empresa,num_credito, fecha_alta)
            values(pempresa,pNumcredito, pFecha );
        END IF;  
        
		  SELECT indicador, canal, sentido, indicador_fico
            INTO vPagoCliente, vtipotrans, vlSentido, vIndFico
		    FROM bdicred:sd_transfun		  
		    WHERE (transacc =pTransacc and transacc <>'') or  
			( codigo_fun = pCodigoFun
		      and codigo_ref = pCodigoRef );
			  				  
			--insert into bdicobranza:cb_bitacora (mensaje) values  (pFolio||'?Es Pago?'||vlSentido|| '--'||vFolioVntDisp||'--'||vfolioatmdisp ||'--'||vfolioposdisp);				  
		-- Valida si la operacion es de cargo o abono.
		IF vlSentido = 'C' THEN	
		  select sdo_cap_insoluto   into vlSaldoMaximo
		   from bdicred:sd_maesdos  
           where empresa ='001'
             and num_credito = pNumcredito;
		END IF;
		---Si es un cargo o tiene reverso de cargo		
		IF vlSentido = 'C' THEN
		  if (pIndicador =3) and ( ( pFolio =vFolioVntDisp  or pFolio = vfolioatmdisp or pFolio =vfolioposdisp ) ) then
		  --Hay Reverso del ultimo Folio, se regresan ultimos valores guardados
		    
			if vtipotrans ='V' then				---Canal es Ventanilla  
			  let pFecha    = vvntDispFecRev ;
			  let pMonto    = vvntDispMtoRev ;              
			  let pFolio    = vFolioVntDispRev;						   			  
			  
			  if nvl(vFolioVntDispRev,'') =''  then let vRevVTN ='V'; end if;
			  
			  let vvntDispFecRev = null ;
			  let vvntDispMtoRev= null;
			  let vfoliovntDispRev= null;			   			  
			  LET vMtoReversion = vvntDispMto;  			  			  
			
			elif  vtipotrans ='P' then			---Si es canal POS  
			  let pFecha    = vPosDispFecRev;
			  let pMonto    = vPosDispMtoRev ;
              let pTransacc = vPosDispTransaccRev;
			  let pFolio    = vFolioPosDispRev;						  
			  
			  if nvl(vFolioPosDispRev,'')='' then let vRevPOS ='V'; end if;

			  let vposDispFecRev = null ;
			  let vposDispMtoRev= null;
              let vposDispTransaccRev= null;			  
			  let vfolioPosDisp= null;		  
			  LET vMtoReversion = vPosDispMto;  			  
			
			elif  vtipotrans ='A' then			---Si es canal ATM
			  let pFecha    = vAtmDispFecRev ;
			  let pMonto    = vatmDispMtoRev ;
              let pTransacc = vAtmDispTransaccRev;
			  let pFolio    = vFolioAtmDispRev;						  
			  
			  if nvl(vFolioAtmDispRev,'')=''  then let vRevATM ='V'; end if;
			  
			  let vatmDispFecRev = null ;
			  let vatmDispMtoRev= null;
              let vatmDispTransaccRev= null;
			  let vfolioatmDispRev= null;			  
			  LET vMtoReversion = vAtmDispMto;  
			end if;
		  elif (pIndicador =3) and ( ( pFolio =Nvl(vFolioVntDispRev,'')  or pFolio = Nvl(vFolioAtmDispRev,'') or 
		                               pFolio =Nvl(vFolioPosDispRev,'') ) ) then
		     -- Si el que se va a reversar es el folio de respaldo se limpian los valores de Respaldo
		    if vtipotrans ='V' then
			  let vvntDispFecRev = null;
			  let vvntDispMtoRev= null;
			  let vfoliovntDispRev= null;
			  
			elif  vtipotrans ='P' then
			  let vposDispFecRev = null;
			  let vposDispMtoRev= null;
			  let vposDispTransaccRev= null;
			  let vfolioPosDisp= null;
			  
			elif  vtipotrans ='A' then			  
			  let vatmDispFecRev = null;
			  let vatmDispMtoRev= null;
			  let vatmDispTransaccRev= null;
			  let vfolioatmDispRev= null;
			  
			end if;		  
		  elif (pIndicador =3) and ( pFolio <>vFolioVntDisp  AND pFolio <> vfolioatmdisp AND pFolio <> vfolioposdisp )then
		    --Si es ReversiÃÂ³n de un  folio distinto no se realiza ningun accion .
            let bContinua = 'F'; 
          end if;			
		  if (pIndicador =1) then
		    /* Si es el indicador de Pago sin reversa, se asignan a los campos de reversa los
			 datos del registro anterior.    */			
	        if vtipotrans ='V' then
			  let vvntDispFecRev = vvntDispFec ;
			  let vvntDispMtoRev= vvntDispMto;
			  let vfoliovntDispRev= vFolioVntDisp;			  
			  
            elif  vtipotrans ='P' then
			  let vposDispFecRev = vPosDispFecha ;
			  let vposDispMtoRev= vPosDispMto;
              let vposDispTransaccRev= vPosDispTransacc;			  
			  let vfolioPosDisp= vfolioPosDisp;		  
			  
	        elif  vtipotrans ='A' then			
			  let vatmDispFecRev = vAtmDispFec ;
			  let vatmDispMtoRev= vAtmDispMto;
              let vatmDispTransaccRev= vAtmDispTransacc;
			  let vfolioatmDispRev= vFolioAtmDisp;			  
			  
		    end if;
		  end if;	---Indicador de Cargo
		ELIF  vlSentido = 'A' THEN  ---- Si es pago o Reverso de Pago		   		  
		  if (pIndicador =3) and ( pFolio = vFolioultPago ) then --- Verifica Reverso de Ultimo Pago		  
		    --Si es el mismo Folio se regresan los valores anteriores.
			let pFecha    = vFecUltPagoRev ;
			let pMonto    = vMtoUltPagoRev ;
            let pCodigoFun = vTransUltPagoRev;
			let pFolio    = vFolioUltPagoRev;						
			if (nvl(vFolioUltPagoRev,'')  ='')  then let vRevPAGO ='V'; end if;			
			let vfecultpagoRev = null;
			let vmtoUltpagoRev= null;
            let vtransUltpagoRev= null;
			let vfolioultpagoRev= null;						
			LET vMtoReversion = vMtoUltPago;  
	  
		  elif (pIndicador =3) and ( pFolio = vFolioUltPagoRev ) then	
		    let vfecultpagoRev = null;
			let vmtoUltpagoRev= null;
            let vtransUltpagoRev= null;
			let vfolioultpagoRev= null;
			
		  elif (pIndicador =3) and ( pFolio <> vFolioultPago ) then 
            let bContinua = 'F'; 	
		  end if;		  
		  if (pIndicador =2) then
		    --En los campos de reverso se guardan los valores anteriores
		    let vfecultpagoRev = vFecUltPago ;
			let vmtoUltpagoRev= vMtoUltPago;
            let vtransUltpagoRev= vTransUltPago;
			let vfolioultpagoRev= vFolioUltPago;
						
			SELECT COUNT(num_credito)		  
			  INTO vlNumVencidos
		      FROM "informix".sd_amortiza_credito
		     WHERE empresa     = pempresa
		       AND num_credito = pNumcredito
		       AND capital_status IN ('2','7','6');			   			   
		  end if;	
		END IF;
		---Monto Acumulado es igual al Monto de la transaccion y el Numero de transacciÃÂ³n es 1
		LET vMtoAcumulado =pMonto;
		LET vNumTrans =1;
		---Monto Acumulado es igual al Monto de la transaccion y el Numero de transacciÃÂ³n es 1
		IF (pIndicador =3) and (bContinua ='V') THEN  
		  LET vMtoAcumulado = (Nvl(vMtoReversion,0)) * -1;		
		  LET vNumTrans =-1; 
		END IF;
--insert into bdicobranza:cb_bitacora (mensaje) values  ('Vencidos'||vlNumVencidos||'bContinua'||bContinua||'pindicador'||pindicador);				  		
		------ Convenios
		IF ( pindicador =5)  then let bContinua ='V'; end if;   
		IF (bContinua ='V' ) then 		
			if ( pindicador =5) then 		    		  
				update bdicred:"informix".sd_indicador_cred
				set monto_ult_convenio = pmonto,
			       fecha_ult_convenio = pfecha 				   
				where empresa = pempresa
				  and num_credito = pnumcredito;	   			   
			elif vpagocliente = 'V' then 		  				
			  if (vlSentido = 'C' ) then
				-- identifica primer compra					
				 if ( vMtoPrimerCompra is null)  then
				   let vMtoPrimerCompra = pmonto;
				   let vFecPrimerCompra = pfecha;
                   let vTransPrimerCompra = pTransacc;
                 end if;
                 if ( vMontoPrimerDisp is null)  then
				   let vMontoPrimerDisp = pmonto;
				   let vfecPrimerDisp = pfecha;
                   let vTransPrimerDisp = pTransacc;
                 end if;
				 --actualiza primer compra   
				  -- update bdicred:"informix".sd_indicador_cred
		         -- --    set f_primer_compra = vFecPrimerCompra,
			          --    monto_primer_compra = vMtoPrimerCompra				
			        ---where empresa = pempresa
                     -- and num_credito = pnumcredito;  
			      
			  -- actualiza cargo por pos
              if (vtipotrans = 'P') then			     
			     update bdicred:"informix".sd_indicador_cred
		            set pos_disp_monto 		= pmonto,
						pos_disp_fecha 		= pfecha,
						pos_disp_transacc 	= ptransacc,
						folio_pos_disp 		= pfolio,
						pos_disp_fecha_rev 	= vPosDispFecRev,
						pos_disp_monto_rev	= vPosDispMtoRev,
						pos_disp_transacc_rev= vPosDispTransaccRev,
						folio_pos_disp_rev	= vFolioPosDispRev,							
						num_pos				=   nvl(num_pos,0) +vnumtrans,
						monto_pos 			= nvl(monto_pos,0) +vmtoacumulado,
                        num_posc				=   nvl(num_posc,0) +vnumtrans,
						monto_posc			= nvl(monto_posc,0) +vmtoacumulado,
						pos_reverso			= vRevPOS,
                        f_primer_compra = vFecPrimerCompra,
                        monto_primer_compra = vMtoPrimerCompra,
                        trans_primer_compra= vTransPrimerCompra,
                        fecha_ultima_compra = pfecha,
                        monto_ultima_compra = pmonto,
						saldo_maximo = (case when saldo_maximo >= vlSaldoMaximo then saldo_maximo else vlSaldoMaximo end),
						fecha_sdo_maximo = (case when saldo_maximo >= vlSaldoMaximo then fecha_sdo_maximo else pfecha end),
                        fechaultimocambio = current
				  where empresa = pempresa
					and num_credito = pnumcredito;
			  -- actualiza cargo por atm
		      elif (vtipotrans = 'A') then 									  
		        update bdicred:"informix".sd_indicador_cred
		         set atm_disp_monto 	= pmonto,
					 atm_disp_fecha 	=	pfecha,
					 atm_disp_transacc 	= ptransacc ,					 
					 folio_atm_disp		= pFolio,					 
					 atm_disp_fecha_rev = vAtmDispFecRev ,
					 atm_disp_monto_rev	= vatmDispMtoRev,
					 atm_disp_transacc_rev	= vAtmDispTransaccRev,
					 folio_atm_disp_rev		= vFolioAtmDispRev,					 
					 num_atm				=   nvl(num_atm,0) +vnumtrans,
					 monto_atm 				= nvl(monto_atm,0) +vmtoacumulado,
					 atm_reverso			= vRevATM,
                     num_atmc				=   nvl(num_atmc,0) +vnumtrans,
					 monto_atmc				= nvl(monto_atmc,0) +vmtoacumulado,
                     f_primer_disp  = vfecPrimerDisp,
                     monto_primer_disp = vMontoPrimerDisp,
                     trans_primer_disp = vTransPrimerDisp,
                     fecha_ultima_compra = pfecha,
                     monto_ultima_compra = pmonto,
					 saldo_maximo = (case when saldo_maximo >= vlSaldoMaximo then saldo_maximo else vlSaldoMaximo end),
					 fecha_sdo_maximo = (case when saldo_maximo >= vlSaldoMaximo then fecha_sdo_maximo else pfecha end),
                     fechaultimocambio = current,
					 -- RQM 09 473 Triad MACF
					 comision_disp_efectivo = (case when vIndFico = '1' then nvl(comision_disp_efectivo,0) + pmonto else nvl(comision_disp_efectivo,0) end),
					 monto_otras_trnx = (case when vIndFico = '4' then nvl(monto_otras_trnx,0) + pmonto else nvl(monto_otras_trnx,0) end),  --6893,6894,6895
					 comision_anualidad = (case when vIndFico = '5' then nvl(comision_anualidad,0) + pmonto else nvl(comision_anualidad,0) end) -- 8244 y 8246
					 -- RQM 09 473 Triad MACF
			   where empresa = pempresa
                 and num_credito = pnumcredito;				 
			-- actualiza cargo por ventanilla	 
              elif  (vtipotrans = 'V') then                 
		        update bdicred:"informix".sd_indicador_cred
		         set vnt_disp_monto 	= pmonto,
					 vnt_disp_fecha 	=	pfecha ,
					 num_vtn			=   nvl(num_vtn,0) +vnumtrans,
					 monto_vtn 			= nvl(monto_vtn,0) +vmtoacumulado,
                     num_vtnc			=   nvl(num_vtnc,0) +vnumtrans,
					 monto_vtnc 			= nvl(monto_vtnc,0) +vmtoacumulado,
					 folio_vnt_disp 	= pFolio,
	                 vnt_disp_fecha_rev = vvntDispFecRev ,
					 vnt_disp_monto_rev	= vvntDispMtoRev,
					 folio_vnt_disp_rev	= vFolioVntDispRev,
					 vnt_reverso			= vRevATM,
                     f_primer_disp  = vfecPrimerDisp,
                     monto_primer_disp = vMontoPrimerDisp,
                     trans_primer_disp = vTransPrimerDisp,
                     fecha_ultima_compra = pfecha,
                     monto_ultima_compra = pmonto,
					 saldo_maximo = (case when saldo_maximo >= vlSaldoMaximo then saldo_maximo else vlSaldoMaximo end),
					 fecha_sdo_maximo = (case when saldo_maximo >= vlSaldoMaximo then fecha_sdo_maximo else pfecha end),
                     fechaultimocambio = current,
					 -- RQM 09 473 Triad MACF
					 num_pagos_hist = nvl(num_pagos_hist,0) + 1,
					 comision_disp_efectivo = (case when vIndFico = '1' then nvl(comision_disp_efectivo,0) + pMonto else nvl(comision_disp_efectivo,0) end),
					 comision_apertura = (case when vIndFico = '2' then nvl(comision_apertura,0) + pmonto else 0 end), 
					 fecha_comision_apertura = (case when vIndFico = '2' then pfecha else date(1) end),
					 monto_otras_trnx = (case when vIndFico = '4' then nvl(monto_otras_trnx,0) + pMonto else nvl(monto_otras_trnx,0) end) --7577,7578
					 -- RQM 09 473 Triad MACF
					 
			   where empresa = pempresa
                 and num_credito = pnumcredito;								
			  end if;	 
            --elif ( pindicador =2) then -- abonos			     		        
			elif (vlSentido = 'A' ) then
			--insert into bdicobranza:cb_bitacora (mensaje) values  ('Aplica Pago'||pnumcredito);				  
		          update bdicred:"informix".sd_indicador_cred		           
				   set fecha_ultimo_pago 	= pfecha,
			       monto_ultimo_pago 		= pmonto,
                   trans_ultimo_pago 		= pCodigoFun, --vltransaccion,
				   folio_ultimo_pago 		= pfolio,				   
				   --folio_ultimo_pago = vFolioUltPago,			
				   fecha_ultimo_pago_rev 	= vFecUltPagoRev ,
				   monto_ultimo_pago_rev	= vMtoUltPagoRev ,
				   trans_ultimo_pago_rev	= vTransUltPagoRev,
				   folio_ultimo_pago_rev	= vFolioUltPagoRev,			
				   num_pagos   = nvl(num_pagos,0) +vnumtrans,
				   monto_pagos = nvl(monto_pagos,0) +vmtoacumulado,
                   num_pagosc   = nvl(num_pagosc,0) +vnumtrans,
				   monto_pagosc = nvl(monto_pagosc,0) +vmtoacumulado,
                   num_vencidos = vlNumVencidos,
				   reverso_ultimo_pago = vRevPago ,   
                   fechaultimocambio = current,
				   -- RQM 09 473 Triad MACF
				   monto_devoluciones = (case when vIndFico = '3' then nvl(monto_devoluciones,0) + pMonto else nvl(monto_devoluciones,0) end), -- 6813
				   monto_otras_trnx = (case when vIndFico = '4' then nvl(monto_otras_trnx,0) + pMonto else nvl(monto_otras_trnx,0) end)  --7041,8249,8251
				   -- RQM 09 473 Triad MACF
				   
			    where empresa = pempresa
                 and num_credito = pnumcredito;		  				 
			--insert into bdicobranza:cb_bitacora (mensaje) values  ('Aplica Pago'||pnumcredito);				  	 
		    end if;    		
		  end if;	
		End if;  
    RETURN cCod_ret;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se inserta o actualiza el indicador de CrÃÂ©dito',
'AUTOR : Faviola MartÃÂ­nez JuÃÂ¡rez',
'FECHA : 01/Agosto/2011',
'BD: BDICRED',
'VERSION:201108.1805';

CREATE PROCEDURE "informix".apercred1_pp_domicilia_web(
			 pEmpresa       VARCHAR(3), 	-- EMPRESA
             pSolicitud     VARCHAR(20), 	-- NUMERO DE SOLICITUD
		 	 pEjecutivo     CHAR(8),		-- EJECUTIVO
			 pPlazo			INTEGER,		-- PLAZO EN MESES PARA PAGAR EL CREDITO
			 pNombrePres	CHAR(50),		-- NOMBRE DEL PRESTAMO
			 pMonto			DECIMAL(18,2),	-- MONTO APROBADO
			 pCuentaCap		CHAR(20),		-- CUENTA DE CAPTACION
			 pMensualidad	MONEY(18,2),	-- IMPORTE MENSUAL
			 pFrecuencia    INTEGER 		-- Frecuencia de pago (--1.- Mensual credinomina / --2.- Quincenal credinomina)
			 )
RETURNING CHAR(5),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);


--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE cCodRet				VARCHAR(5);		-- CODIGO DE RETORNO
DEFINE cCodRet3				VARCHAR(6);		-- CODIGO DE RETORNO ABONOREF BDICHEQ
DEFINE cCodRetTDif			CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE cErrorInfo           VARCHAR(80);	-- MENSAJE DE ERROR
DEFINE mTasaInteres         DECIMAL(18,2);	-- TASA DE INTERES
DEFINE mTasaMora            DECIMAL(18,2);	-- TASA MORATORIA
DEFINE mSobreTasa           DECIMAL(18,2);	-- SOBRETASA
DEFINE mSobreTasa_MORA      DECIMAL(18,2);	-- SOBRETASA MORA
DEFINE mTasaFavor           DECIMAL(18,2);	-- TASA A FAVOR
DEFINE mSobreTasaFAV        DECIMAL(18,2);	-- SOBRETASA A FAVOR DEL CLIENTE
DEFINE cFactor	            CHAR(1);		-- FACTOR
DEFINE cFactor_Mora	        CHAR(1);		-- FACTOR MORA
DEFINE dFechaApert          DATE;			-- FECHA DE INICIO DEL PRESTAMO
DEFINE dFechaVenc           DATE;			-- FECHA DE TERMINACION DEL PRESTAMO
DEFINE iSqlErr              INTEGER;		-- CODIGO DE ERROR
DEFINE iIsamError           INTEGER;		-- CODIGO DE ERROR
DEFINE cNumCte              CHAR(20);		-- NUMERO DE CLIENTE
DEFINE cTpCte               CHAR(1);		-- TIPO DE CLIENTE
DEFINE mIngreso             DECIMAL(18,2);	-- INGRESO DEL CLIENTE
DEFINE cFactorFAV           CHAR(1);		-- FACTOR A FAVOR DEL CLIENTE
DEFINE cProducto            CHAR(4);		-- CODIGO DE PRODUCTO
DEFINE cDivisa              CHAR(2);		-- DIVISA
DEFINE cSucursal            CHAR(4);		-- CODIGO DE SUCURSAL
DEFINE cFolio	            CHAR(16);		-- FOLIO PARA GENERACION DE MOVIMIENTOS DIARIOS
DEFINE cMensaje             CHAR(200);		-- MENSAJE MAS NOMBRE DE EJECUTIVO
DEFINE dFechaT              DATE;			-- FECHA DEL MES POSTERIOR A LA APERTURA
DEFINE sDiaCorte            SMALLINT;		-- DIA DE CORTE
DEFINE i		     		SMALLINT;		-- VARIABLE PARA ITERACION
DEFINE mCatIva		    	DECIMAL(18,2);	-- VALOR DEL CAT DEL IVA
DEFINE cMercadeo            CHAR(1);		-- PUBLICACION
DEFINE sSecIngreso 			SMALLINT;		-- SECUENCIA DE INGRESOS
DEFINE mTasaInteresProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE mTasaMoraProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE cPeriodoPag			CHAR(1);		-- PERIODICIDAD DEL PAGO
DEFINE iDiasTraspCap		INTEGER;		-- DIAS PARA TRASPASO DE CAPITAL
DEFINE iDiasTraspInt		INTEGER;		-- DIAS PARA TRASPASO DE INTERESES
DEFINE cNumeroFolio 		CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE cTransacc 			CHAR(4);	 	-- FOLIO DE TRANSACCION DEL ABONO
DEFINE iNumReg				INTEGER;		-- NUMERO DE REGISTROS DE UNA OPERACION
DEFINE dIvaSuc              DECIMAL(5,3);   -- IVA DE LA SUCURSAL DONDE SE GENERO LA SOLICITUD
DEFINE idAbono              CHAR(1);
DEFINE sDiasPeriodo         SMALLINT;
DEFINE dtDiaprimero         DATE;
DEFINE dtFecha_cargo  		DATE;
DEFINE mDispo         		MONEY(14,2);
DEFINE mCargo         		MONEY(14,2);
DEFINE mIvaComisionApertura MONEY(14,2);
DEFINE mComisionApertura    MONEY(14,2);
DEFINE dPorcComisionAper    DECIMAL(9,6);
DEFINE cTransaccIvaCargo    CHAR(4);
DEFINE cTransaccCargo       CHAR(4);
DEFINE iContador         	SMALLINT;
DEFINE mTotalPagar			DECIMAL(18,2);
DEFINE iNum_periodos    	INTEGER;
DEFINE dtFecha_cuota    	DATE;
DEFINE dSdo_inicial     	MONEY(14,2);
DEFINE dPago_mensual    	MONEY(14,2);
DEFINE dMto_Interes     	MONEY(14,2);
DEFINE dIva_interes     	MONEY(14,2);
DEFINE dCapital         	MONEY(14,2);
DEFINE dSdo_final       	MONEY(14,2);
DEFINE sDias_periodo    	SMALLINT;
DEFINE dtFecha_Aper			DATE;
DEFINE iDiaPago      		INTEGER;
DEFINE cNumMesesPagos   	CHAR(3);
DEFINE cCodRet2         	CHAR(6);
DEFINE cMensajeRet      	VARCHAR(80,1);
DEFINE vCatFinal        	DECIMAL(21,10);
DEFINE dPagoReq      		DECIMAL(18,2);
DEFINE pNumCel       		CHAR(13);
DEFINE sCodRetEvento 		CHAR(5);
DEFINE pMontoSolOtorga		DECIMAL(18,2);	-- MONTO APROBADO PRODUCTO 6800,7100
DEFINE vcod_ret				CHAR (6);
DEFINE cta_Clabe			CHAR (18);
DEFINE count_maecrd			SMALLINT;
DEFINE count_mdoscrd		SMALLINT;
DEFINE count_maeanexcrd		SMALLINT;
DEFINE count_ctascarg		SMALLINT;
DEFINE count_amortcrd		SMALLINT;
DEFINE count_ssautoriz		SMALLINT;
DEFINE cIFRS				CHAR(1);
DEFINE cStatus_cred 		CHAR(2);
DEFINE iAtr_Act_ifrs		INTEGER;
DEFINE iPlazo_pago          INTEGER;
DEFINE vCancelVig           INTEGER;
DEFINE vFechaVig 			DATE;
DEFINE CanalSol             CHAR(1);
DEFINE count_suc			SMALLINT;						


--***********************
--INICIALIZA VARIABLES
--***********************
LET cCodRet      		= '00000';
LET cCodRet3			= '000';
LET cCodRetTDif			= '';
LET cErrorInfo    		= 'PROCESO EXITOSO';
LET mTasaInteres 		= 0;
LET mTasaMora 			= 0;
LET mSobreTasa   		= 0;
LET mSobreTasa_MORA		= 0;
LET mTasaFavor   		= 0;
LET mSobreTasaFAV		= 0;
LET cFactor	  			= "";
LET cFactor_Mora		= "";
LET dFechaApert 		= DATE(1);
LET dFechaVenc 			= DATE(1);
LET iSqlErr    			= 0;
LET iIsamError 			= 0;
LET cErrorInfo 			= "";
LET cNumCte    			= "";
LET cTpCte     			= "";
LET mIngreso   			= 0;
LET cFactorFAV 			= "";
LET cProducto  			= "";
LET cDivisa    			= "";
LET cSucursal			= "";
LET cFolio				= "";
LET cMensaje 			= "";
LET dFechaT  			= DATE(1);
LET sDiaCorte			= 0;
LET i 					= 0;
LET mCatIva				= 0;
LET cMercadeo 			= "";
LET sSecIngreso			= 0;
LET mTasaInteresProd	= 0;
LET cPeriodoPag			= "";
LET iDiasTraspCap		= 0;
LET iDiasTraspInt		= 0;
LET cNumeroFolio		= "";
LET cTransacc			= "";
LET iNumReg				= 0;
LET dIvaSuc             = 0;
LET idAbono             = "N";
LET sDiasPeriodo        = 0;
LET dtDiaprimero  	 	= DATE(1);
LET dtFecha_cargo  	    = DATE(1);
LET mDispo              = 0;
LET mCargo      	    = 0;
LET mIvaComisionApertura = 0;
LET mComisionApertura	= 0;
LET dPorcComisionAper   = 0;
LET cTransaccIvaCargo   = "";
LET cTransaccCargo      = "";
LET iContador      	    = 0;
LET mTotalPagar			= 0;
LET iNum_periodos		= 0;
LET dtFecha_cuota      	= DATE(1);
LET dSdo_inicial      	= 0;
LET dPago_mensual      	= 0;
LET dMto_Interes      	= 0;
LET dIva_interes      	= "";
LET dCapital      	   	= "";
LET dSdo_final      	= 0;
LET sDias_periodo      	= 0;
LET dtFecha_Aper      	= DATE(1);
LET iDiaPago       		= 0; 
LET cNumMesesPagos  	= "";
LET cCodRet2            = "000000";
LET cMensajeRet         = "Se realizo el calculo correctamente";
LET vCatFinal 			= 0;
LET dPagoReq 			= 0;
LET pNumCel  			= '';
LET sCodRetEvento		= '';
LET pMontoSolOtorga     = 0; 
LET vcod_ret			= '000';
LET cta_Clabe			= '';	
LET count_maecrd		= 0;
LET count_mdoscrd		= 0;
LET count_maeanexcrd	= 0;
LET count_ctascarg		= 0;
LET count_amortcrd		= 0;
LET count_ssautoriz		= 0;
LET cIFRS				= '';
LET cStatus_cred 		= '';
LET iAtr_Act_ifrs		= 0;
LET iPlazo_pago         = 0;
LET vCancelVig          = 0;
LET vFechaVig           = '';
LET CanalSol            = '';
LET count_suc 			= 0;					 

--SET DEBUG FILE TO '/tmp/apercred1_pp_domicilia_web.out';
-- TRACE ON;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
		LET cErrorInfo  = cErrorInfo;

		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
        IF idAbono = "S" THEN         
             CALL bdicheq:"informix".reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;
             IF cCodRet <> "000" THEN
                LET cCodRet    = "00004";
             END IF;
        END IF;
        LET cCodRet    = iSqlErr;
        RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SE VALIDA QUE LOS DATOS DE ENTRADA SEAN CORRECTOS
	IF NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "" OR NVL(pEjecutivo,"") = ""  OR NVL(pNombrePres,"") = "" OR NVL(pCuentaCap,"") = "" THEN
		LET cCodRet = "00002";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF
	
	-- Valida si se encuentra activa funcionalidad de IFRS
	SELECT valor INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
	IF cIFRS = 'A' THEN
		LET cStatus_cred = 'E1';
		LET iAtr_Act_ifrs = 0;
	ELSE
		LET cStatus_cred = 'AA';
		LET iAtr_Act_ifrs = NULL;
	END IF;	
	
	-- SE OBTIENE LA CLAVE DEL PRODUCTO, EL CODIGO DE DIVISA, EL MONTO DEL PRESTAMO SOLICITADO, LA SUCURSAL Y EL MONTO AUTORIZADO--se mueve consulta JMAH
	SELECT a.num_producto, a.divisa, b.sucursal, b.monto_autorizado
	INTO cProducto, cDivisa, cSucursal, pMontoSolOtorga
	FROM bdisolic:"informix".ss_solicitudes b
	INNER JOIN "informix".sd_definicion a ON a.empresa = b.empresa AND a.num_producto = b.num_producto
	WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud;
	
    IF cProducto IN ('6800','7100') THEN
		LET pMonto = pMontoSolOtorga;
    END IF;
	
	IF cProducto = '6400' THEN--JMAH
		IF NVL(pPlazo,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF NVL(pMonto,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF NVL(pMensualidad,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF iContador <> 2 THEN 
			LET cCodRet = "00002";
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;	
    ELSE
	  IF NVL(pPlazo,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF NVL(pMonto,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;		
		IF iContador <> 2 THEN 
			LET cCodRet = "00002";
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;	
	END IF;	
	
	--SE VALIDA QUE NO EXISTA EL CREDITO
	--Se omite la tabla sd_ctascarg de los productos 6300,6800,7600 y 7700 ya que se domicilia antes y hace el insert a la tabla previamente.
	SELECT COUNT(num_credito) INTO count_maecrd FROM "informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT COUNT(num_credito) INTO count_mdoscrd FROM "informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT COUNT(num_credito) INTO count_maeanexcrd FROM "informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	--SELECT COUNT(num_credito) INTO count_ctascarg FROM "informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud;
	SELECT COUNT(num_credito) INTO count_amortcrd FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND fecha_cuota = dFechaT AND num_credito = pSolicitud;
	SELECT COUNT(num_solicitud) INTO count_ssautoriz FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";

	-- CAX 14112024 se valida sucursal 
	SELECT count(*) INTO count_suc FROM bdinteg:si_sucursales WHERE sucursal = cSucursal and tpo_sucursal <> 'S';
	SELECT COUNT(num_credito) INTO count_ctascarg FROM "informix".sd_ctascarg WHERE empresa = pEmpresa AND num_credito = pSolicitud;
									
	--IF EXISTS (SELECT num_credito FROM "informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	IF count_maecrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM "informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF count_mdoscrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM "informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF count_maeanexcrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM "informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud) THEN
	--ELIF count_ctascarg > 0 THEN
	--	LET cCodRet = "000001";
	--	RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND fecha_cuota = dFechaT AND num_credito = pSolicitud) THEN
	ELIF count_amortcrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP") THEN
	ELIF count_ssautoriz > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	ELIF count_suc > 0 THEN   ---VALIDA QUE LA SUCURSAL SEA OPERATIVA
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	ELIF pMonto <= 0 THEN  --- VALIDA QUE EL MONTO SEA MAYOR A CERO
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	ELIF count_ctascarg = 0 THEN --- VALIDA QUE TENGA CUENTA CARGO CHEQUES
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;														  
	END IF;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
	SELECT valor INTO mCatIva
	FROM   "informix".sd_param
	WHERE  cod_param = '034';
	
	IF mCatIva IS NULL THEN
		LET mCatIva = 0;
	END IF

    -- SE DETERMINAN LAS DIFERENTES TASAS DE INTERES	
	EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(pEmpresa, pSolicitud, '') INTO cCodRetTDif, mTasaInteres, mTasaMora;
	IF cCodRetTDif <> '000000' THEN
		LET cCodRet = SUBSTRING (cCodRetTDif FROM 1 FOR 5);
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;	

	SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo, a.fact_sobret_mora, a.sobretasa_mora
	INTO cFactor,            mSobreTasa,  sDiaCorte,   cPeriodoPag,	  cFactor_Mora, 	  mSobreTasa_MORA	
	FROM "informix".sd_definicion a
	INNER JOIN bdisolic:"informix".ss_solicitudes b ON (a.empresa = b.empresa AND a.num_producto = b.num_producto and b.num_solicitud = pSolicitud);

	LET mTasaInteresProd = mTasaInteres;

	IF cFactor = "+" THEN
		LET mTasaInteres = mTasaInteres + mSobreTasa;
	ELIF cFactor = "-" THEN
		LET mTasaInteres = mTasaInteres - mSobreTasa;
	ELIF cFactor = "*" THEN
		LET mTasaInteres = mTasaInteres * mSobreTasa;
	ELSE
		LET mTasaInteres = mTasaInteres / mSobreTasa;
	END IF
			
	--Valida que la solicitud sea de flujo One Click.
	SELECT canal_sol INTO CanalSol FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = pSolicitud;
	
	--6 igual a Sucursal, 7 igual a App.
	IF(CanalSol = '6' OR CanalSol = '7') THEN
		--Toma la tasa que proporciono el area de credito para los clientes pre aprobados.
		SELECT tasa INTO mTasaInteres FROM bdicred:"informix".sd_pre_aprobados_trx WHERE solicitud = pSolicitud;
		
		LET mTasaInteresProd = mTasaInteres;
		
		--obtiene la sucursal que se esta llevando la apertura del prestamo para la solicitud de one click con base al ejecutivo.
		-- Si pEjecutivo es igual a 0 el flujo viene desde la App, si es diferente de 0 el flujo viene de sucursal.
		IF pEjecutivo = "0" OR pEjecutivo IS NULL THEN
			--Se toma la sucursal origen del cliente. se agrego el case para cambiar la sucursal 8503 por la 6700 actividad DUD
			SELECT CASE WHEN cte.sucursal='8503' THEN '6700' ELSE cte.sucursal END
			INTO cSucursal 
			FROM bdinteg:"informix".si_cliente cte 
			JOIN bdisolic:"informix".ss_solicitudes sol ON (cte.numcte = sol.numcte)
			WHERE sol.empresa = pEmpresa AND sol.num_solicitud = pSolicitud;
		ELSE
			--Se toma la sucursal de acuerdo al ejecutivo que esta realizando el proceso de formalizacion del prestamo.
			SELECT sucursal INTO cSucursal FROM bdinteg:"informix".si_ejecut WHERE empresa = pEmpresa AND ejecutivo = pEjecutivo;
		END IF;
		
		-- CAX Mayo 2026 se valida sucursal y en caso de que sea no operativa se asigna la suc 6700 por default 
		SELECT count(*) INTO count_suc FROM bdinteg:si_sucursales WHERE sucursal = cSucursal and tpo_sucursal <> 'S';
	
		IF count_suc > 0 THEN 
			LET cSucursal = '6700';
		END IF;
		
	END IF;

	LET mTasaMoraProd = mTasaMora;

	IF cFactor_Mora = "+" THEN
		LET mTasaMora = mTasaMora + mSobreTasa_MORA;
	ELIF cFactor_Mora = "-" THEN
		LET mTasaMora = mTasaMora - mSobreTasa_MORA;
	ELIF cFactor_Mora = "*" THEN
		LET mTasaMora = mTasaMora * mSobreTasa_MORA;
	ELSE
		LET mTasaMora = mTasaMora / mSobreTasa_MORA;
	END IF

	--INTERES A FAVOR DEL CLIENTE
	SELECT c.valor, a.factor_sobretasa, a.sobretasa
	INTO mTasaFavor, cFactorFAV, mSobreTasaFAV
	FROM "informix".sd_anexodefinicion a
	INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
	INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_base
	WHERE b.empresa = pEmpresa AND num_solicitud = pSolicitud
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_base);

	IF cFactorFAV = "+" THEN
		LET mTasaFavor = mTasaFavor + mSobreTasaFAV;
	ELIF cFactorFAV = "-" THEN
		LET mTasaFavor = mTasaFavor - mSobreTasaFAV;
	ELIF cFactorFAV = "*" THEN
		LET mTasaFavor = mTasaFavor * mSobreTasaFAV;
	ELSE
		LET mTasaFavor = mTasaFavor / mSobreTasaFAV;
	END IF	

	-- SE OBTIENEN LAS FECHAS DE INICIO, Y FIN DEL PRESTAMO Y LA FECHA DEL SIGUIENTE MES DESPUES DE LA APERTURA DEL CREDITO
	SELECT fecha_hoy INTO dFechaApert FROM "informix".sd_fechas WHERE empresa = pEmpresa;	
	--se modifica la forma en que se se obtiene la fecha del primer pago del credito para homologarlo con la proyeccion.
	IF cProducto = '6400' THEN    ---Periodo de pago credinomina		
		--se obtiene la fecha de la proxima cuota.
		EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapago('001',dFechaApert,pSolicitud)
		INTO cCodRet,dFechaT,iDiaPago;	
		
		IF cCodRet::INTEGER <> 0  THEN	
			LET cCodRet    = "00008";	--Ocurrio un Error al obtener la fecha de primer pago del credito para credinomina.
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;
		CALL "informix".sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;	 			
	END IF;
	
	IF cProducto = '6400' THEN---Periodo de pago Mensual prestamo 	--JMAH
		--se obtiene fecha de vencimiento para credinomina
		FOREACH 
	     	EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (pMonto,pPlazo,pMensualidad,cProducto,cSucursal,1,0,pSolicitud,"",pFrecuencia)
			INTO cCodRet,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
			dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos			
			
			IF cCodRet::INTEGER <> 0  THEN				
				LET cCodRet    = "00007";	--Ocurrio un Error al obtener la fecha de vencimiento del credito para credinomina.
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;
			
			IF iNum_periodos=1 THEN
				LET pMensualidad = dPago_mensual;
				LET pMonto = dSdo_inicial;					
			END IF;					
			
			LET dFechaVenc = dtFecha_cuota;					
	    END FOREACH;
		LET pPlazo = iNum_periodos; 
	ELSE
		CALL "informix".monthadd(dFechaApert,1) RETURNING dFechaT;
	    CALL "informix".sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;	  
        IF cProducto IN ('6800','7100') THEN
			IF cProducto = '6800' THEN
				SELECT TRIM(valor) INTO iPlazo_pago
                FROM bdicred:sd_param                  
                WHERE empresa  = pEmpresa AND cod_param = 'A01';
 
				CALL "informix".monthadd(dFechaApert,iPlazo_pago) RETURNING dFechaVenc;
			ELSE
			   CALL "informix".monthadd(dFechaApert,36) RETURNING dFechaVenc;
			END IF;
		ELSE
            CALL "informix".monthadd(dFechaApert,pPlazo) RETURNING dFechaVenc;
        END IF;
	END IF;	
	
	IF cCodRet::INTEGER <> 0 THEN
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;
	--AAME 20150317 RQM 10 550 Se anexan nuevos productos de prestamo ('7600','7700') para que realice la proyeccion.
	--CYRV 20171113 RQM 10 915 Se agrega nuevo prestamos a proyeccion 6800 y 7100
	--IF (cProducto = '6300') OR (cProducto = '6400') OR (cProducto = '7600') OR (cProducto = '7700') OR (cProducto = '6800') OR (cProducto = '7100') THEN
	IF cProducto IN ('6300','6400','7600','7700','6800','7100') THEN
	--VALIDACION PARA CALCULAR EL MONTO TOTAL A PAGAR PARA UN PRESTAMO PERSONAL
		FOREACH 
			--SE OBTIENE CON EL PROYECTA PRESTAMO CADA UNA DE LAS MENSUALIDADES PARA SUMARLAS y CALCULAR EL MONTO TOTAL A PAGAR
		EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (pMonto,pPlazo,0,cProducto,cSucursal,1,0,pSolicitud,"",pFrecuencia)
		INTO cCodRet,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
		dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos
			--SE VALIDAD PARA VER SI EL PROYECTA PRESTAMO SE EJECUTO CORRECTAMENTE
			IF cCodRet::INTEGER <> 0  THEN
				LET cCodRet = SUBSTRING (cCodRet FROM 1 FOR 5);
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;
			--VARIABLE QUE GUARDA LA SUMA DE LAS MENSUALIDADES
			LET mTotalPagar = mTotalPagar + dPago_mensual::DECIMAL(18,2);	
			IF iNum_periodos=1 THEN
				LET pMensualidad = dPago_mensual;
			END IF;			
	    END FOREACH;
	END IF;
	
	SELECT a.iva
    INTO dIvaSuc
    FROM bdinteg:"informix".si_sucursales a
    WHERE a.sucursal = cSucursal
    AND a.empresa  = pEmpresa;
		  
	--- Genera cuenta Clabe
	EXECUTE PROCEDURE bdicred:"informix".sp_gen_clabe_interbancaria (pEmpresa,pSolicitud,cProducto)
	INTO vcod_ret, cta_Clabe;		  
	
    --***** SE INSERTA INFORMACION EN SD_MAECREDCRD
	INSERT INTO "informix".sd_maecredcrd
		   (empresa,                        num_credito,
			num_producto,                   ejecutivo,
			numcte,                         aval_cte,
			aval_linea,                     divisa,
			sucursal,                       id_origen,
			origen,                         cod_tipo_linea,
			cod_linea,                      status_cred,
			bandera_renovac,                bandera_prorroga,
			periodo_plazo,                  plazo,
			fecha_apertura,                 fecha_vencim,
			period_pago_cap,                period_pag_int,
			dias_trasp_cap,                 dias_trasp_int,
			tasa_fija_o_var,                cod_tasa_base,
			factor_sobretasa,               sobretasa,
			tasa_interes,                   cod_tasa_mora,
			sobretasa_mora,                 fact_sobret_mora,
			tasa_moratorios,                tasa_preferencial,
			sobretasa_preferencial,         factor_preferencial,
			valor_preferencial,             fecha_pago_cap,
			fecha_pago_int,                 es_fisica,
			bandera_fi_fo,                  actividad,
			tipo_calculo,                   num_aper_ant,
			rev_tasa_var_per,               dia_para_revisar,
			cod_prod,                       bandera_ministra,
			credito_externo,                califica_riesgo,
			cod_agricola,                   pagos_sostenidos,
			campo_trab1,                    campo_trab2,
			campo_trab3,                    campo_trab4
			,cuenta_clabe
		   )
	SELECT  sol.empresa                		,pSolicitud
		   ,sol.num_producto                ,NVL(anx.ejecutivo_sol,'')
		   ,sol.numcte                      ,''
		   ,''                              ,NVL(def.divisa,1)
		   ,NVL(sol.sucursal,'')            ,''
		   ,''                              ,''
		  -- IFRS ,''                              ,'AA'
		   ,''                              ,cStatus_cred
		   ,'S'                             ,'N'
		   ,SUBSTR(tipo_pago,1,1)		   --,NVL(def.periodo_plazo,'')     
		   
		   ,pPlazo
		   ,dFechaApert  					,dFechaVenc
		   ,NVL(def.period_pago_cap,'')     ,NVL(def.period_pag_int,'')
		   ,NVL(def.dias_traspaso_cap,0)    ,NVL(def.dias_traspaso_int,0)
		   ,NVL(def.tasa_fija_o_var,'')     ,NVL(def.cod_tasa_base,'')
		   ,NVL(def.factor_sobretasa,'')    ,NVL(def.sobretasa,'')
		   ,mTasaInteresProd                ,NVL(def.cod_tasa_mora,'')
		   ,NVL(def.sobretasa_mora,0)       ,NVL(def.fact_sobret_mora,'')
		   ,NVL(mTasaMoraProd,0)            ,''
		   ,0                               ,''
		   ,0                               ,dFechaT
		   ,dFechaT							,NVL(tip.es_fisica,'')
		   ,''                              ,''
		   ,NVL(def.tipo_calculo,'')        ,dIvaSuc
		   ,''                              ,NVL(def.dia_para_revisar,0)
		   ,''                              ,SUBSTR(tipo_pago,1,1)	--cPeriodoPag
		   ,''                              ,''
		   ,''                              ,0
		   ,0                               ,0
		   ,''                              ,''
		   ,cta_Clabe
	FROM bdisolic:"informix".ss_solicitudes sol
		INNER JOIN "informix".sd_definicion def ON def.empresa = sol.empresa AND def.num_producto = sol.num_producto
		INNER JOIN bdisolic:"informix".ss_anexosol anx ON anx.num_solicitud = sol.num_solicitud AND anx.empresa = sol.empresa
		INNER JOIN bdinteg:"informix".si_cliente cli ON cli.empresa = sol.empresa AND cli.numcte = sol.numcte
		INNER JOIN bdinteg:"informix".si_tipper tip ON tip.tpo_persona = cli.tpo_persona
		INNER JOIN "informix".sd_cattipopago pago ON pago.empresa = pEmpresa AND valor = pFrecuencia 
		WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;	
		
	LET iNumReg = dbinfo("sqlca.sqlerrd2");

	IF iNumReg = 0 THEN
		LET cCodRet = "00003";
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;
	
	IF(CanalSol = '6' OR CanalSol = '7') THEN
		UPDATE bdicred:"informix".sd_maecredcrd SET sucursal = cSucursal WHERE num_credito = pSolicitud;
	END IF;

     --***** SE INSERTA INFORMACION EN SD_MAECREDANEXOCRD (DATOS PARA TARJETA DE CREDITO)
    BEGIN
	    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
			LET cCodRet    = iSqlErr;
			LET cErrorInfo  = cErrorInfo;
	        RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	    END EXCEPTION;

		IF cProducto = "6400" THEN --JMAH
			--se obtiene el porcentaje de comision por apertura.
			SELECT valor INTO dPorcComisionAper
			FROM   "informix".sd_param
			WHERE  cod_param = '040';
			
			--se obtiene la transaccion con la que registrara el cargo de la comision
			SELECT valor INTO cTransaccCargo
			FROM   "informix".sd_param
			WHERE  cod_param = '041';
			--se obtiene la transaccion con la que registrara el iva del cargo de la comision
			SELECT valor INTO cTransaccIvaCargo
			FROM   "informix".sd_param
			WHERE  cod_param = '042';
	
            IF ( dPorcComisionAper is null ) THEN LET dPorcComisionAper = 0; END IF;

            IF ( dPorcComisionAper > 0 ) then
                LET mComisionApertura= ROUND(pMonto * (dPorcComisionAper/100),2);
			END IF
		END IF
		
		--RQM 10 751
		-- RQM 10 737 
		LET dPagoReq = pMonto / ((1- pow((1+((mTasaInteres /100)/( pFrecuencia * 12 ))),-pPlazo)) / ((mTasaInteres /100)/( pFrecuencia * 12 )) ) ;
			
		EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir_pp(pMonto,dPagoReq,pPlazo,(12 * pFrecuencia),mComisionApertura) 
		into cCodRet2,cMensajeRet,vCatFinal;
		
		LET mCatIva = vCatFinal;
				
		IF cCodRet2::integer  <> 0 THEN
			LET cCodRet = "00003";
			DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
			DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
			DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
            DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;
	 
		INSERT INTO "informix".sd_maecredanexocrd
			(empresa, 				 		num_credito,
			 localidad,              		dia_corte,
	         dias_gracia_mora, 		 		tp_dias_calc_mora,
	         dias_fecha_max_pago,	 		tp_dias_fecha_pago,
	         cod_tasa_base_cte, 	 		factor_sobretasa_cte,
	         sobretasa_cte, 		 		tasa_interes_cte,
	         fecha_vencto, 			 		prox_fecha_pago,
	         fecha_proceso,			 		fecha_ult_pago,
	         nombre_pres, 					cat)
		SELECT pEmpresa              		,pSolicitud,
               ""                    		,(CASE WHEN NVL(def.num_producto,"") = "6400"  THEN DAY(dFechaT) ELSE  DAY(dFechaApert) END) ,--JMAH
			   NVL(def.gracia_calc_mora,0)  ,'',
			  (CASE WHEN NVL(def.num_producto,"") = "6400"  THEN DAY(dFechaT) ELSE  DAY(dFechaApert) END),--JMAH -- DAY(dFechaApert)      		,
			   (CASE WHEN NVL(nom.Frecuencia_pgo,0) = 0  THEN NVL(def.maneja_linea::INTEGER,0) ELSE  NVL(nom.Frecuencia_pgo,0) END) ,
			   NVL(def.cod_tasa_base,'')	,NVL(def.factor_sobretasa,''),
			   NVL(def.sobretasa,0)    		,mTasaInteresProd,
			   ""                    		,dFechaT,
			   dFechaApert           		,"",
			   pNombrePres,					vCatFinal
		FROM "informix".sd_definicion def
        INNER JOIN bdisolic:"informix".ss_solicitudes c ON c.empresa = def.empresa AND c.num_producto = def.num_producto
		LEFT JOIN  bdisolic:"informix".ss_sol_nomina nom ON (nom.empresa = c.empresa AND nom.num_solicitud = c.num_solicitud)		
		--INNER JOIN bdicred:sd_anexodefinicion b ON b.empresa = def.empresa AND b.num_producto = c.num_producto
		--AND b.cod_prod = def.cod_tipcred
		WHERE c.empresa = pEmpresa AND c.num_solicitud = pSolicitud;
    END;
	
	--***** SE INSERTA INFORMACION EN SD_MAESDOSCRD
	LET iNumReg = dbinfo("sqlca.sqlerrd2");

	IF iNumReg = 0 THEN
		LET cCodRet = "00003";
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;

    BEGIN
	    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
			LET cCodRet    = iSqlErr;
	        LET cErrorInfo  = cErrorInfo;
	        RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	    END EXCEPTION;

        IF cProducto IN ('6800','7100') THEN
            INSERT INTO "informix".sd_maesdoscrd
                    (
                        empresa, 			num_credito,
                        fecha_ult_mov, 		sdo_int_anticip,
                        sdo_int_ant_dev, 	sdo_intereses,
                        sdo_dia_ant_int, 	sdo_mes_ant_int,
                        sdo_acum_mes_int, 	sdo_retenido,
                        sdo_acum_cap_int, 	sdo_exig_int,
                        sdo_no_exig, 		provision_normal,
                        dias_acum_int, 		sdo_moratorio,
                        sdo_dia_ant_mor, 	sdo_mes_ant_mor,
                        sdo_contab_mora, 	dias_acum_mora,
                        sdo_capital, 		sdo_cap_insoluto,
                        sdo_dia_ant_cap, 	sdo_mes_ant_cap,
                        sdo_acum_mes_cap, 	mto_capitalizado,
                        mto_ministra_cap, 	cargos_dia_cap,
                        abonos_dia_cap, 	cargos_mes_cap,
                        abonos_mes_cap, 	dias_acum_cap,
                        monto_vencido, 		mto_venc_trasp,
                        monto_financiado, 	monto_reservado,
                        sdo_acum_vencido, 	dias_acum_intper,
                        sdo_global_int, 	sdo_acum_intper,
                        monto_otorgado, 	provi_venc_normal,
                        provi_venc_anticip, cap_tras_no_venci,
                        mto_venc_int, 		mto_venc_tra_int,
                        mto_finan_vdo, 		mto_reser_int,
                        mto_fin_ven_trasp, 	mto_fin_vig_trasp,
                        int_tra_no_exig, 	sdo_trab4,
						atr

                    )
            SELECT 		 sol.empresa             ,pSolicitud
                        ,dFechaApert            ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,mTotalPagar
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,pMonto					,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
						,iAtr_Act_ifrs
            FROM   bdisolic:"informix".ss_solicitudes sol
            WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;

        ELSE
            INSERT INTO "informix".sd_maesdoscrd
                    (
                        empresa, 			num_credito,
                        fecha_ult_mov, 		sdo_int_anticip,
                        sdo_int_ant_dev, 	sdo_intereses,
                        sdo_dia_ant_int, 	sdo_mes_ant_int,
                        sdo_acum_mes_int, 	sdo_retenido,
                        sdo_acum_cap_int, 	sdo_exig_int,
                        sdo_no_exig, 		provision_normal,
                        dias_acum_int, 		sdo_moratorio,
                        sdo_dia_ant_mor, 	sdo_mes_ant_mor,
                        sdo_contab_mora, 	dias_acum_mora,
                        sdo_capital, 		sdo_cap_insoluto,
                        sdo_dia_ant_cap, 	sdo_mes_ant_cap,
                        sdo_acum_mes_cap, 	mto_capitalizado,
                        mto_ministra_cap, 	cargos_dia_cap,
                        abonos_dia_cap, 	cargos_mes_cap,
                        abonos_mes_cap, 	dias_acum_cap,
                        monto_vencido, 		mto_venc_trasp,
                        monto_financiado, 	monto_reservado,
                        sdo_acum_vencido, 	dias_acum_intper,
                        sdo_global_int, 	sdo_acum_intper,
                        monto_otorgado, 	provi_venc_normal,
                        provi_venc_anticip, cap_tras_no_venci,
                        mto_venc_int, 		mto_venc_tra_int,
                        mto_finan_vdo, 		mto_reser_int,
                        mto_fin_ven_trasp, 	mto_fin_vig_trasp,
                        int_tra_no_exig, 	sdo_trab4,
						atr
                    )
            SELECT 		 sol.empresa             ,pSolicitud
                        ,dFechaApert            ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,pMonto                 ,pMonto
                        ,0                      ,0
                        ,0                      ,mTotalPagar
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,pMonto					,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
						,iAtr_Act_ifrs
            FROM   bdisolic:"informix".ss_solicitudes sol
            WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;
        END IF;
	END;

	LET iNumReg = dbinfo("sqlca.sqlerrd2");

	IF iNumReg = 0 THEN
		LET cCodRet = "00003";
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;

	SELECT TRIM(valor)  INTO  vCancelVig
	FROM bdicred:"informix".sd_param 						
	WHERE empresa  = pEmpresa AND cod_param = '067'; --Parametro de Cancelacion de Vigencia de linea
			
	EXECUTE PROCEDURE bdicred:monthadd(dFechaApert, vCancelVig) INTO vFechaVig;
	
    -- CARGA LINEA DE CREDITO INI 
    IF cProducto IN ('6800','7100') THEN	
		IF cProducto = '6800' THEN
			INSERT INTO "informix".sd_linea_prestamo
                    (empresa,
                     num_credito,
                     monto_linea,
                     fecha_otorga,
                     linea_disponible,
                     sec_credito,
                     fecha_cancela,
					 fecha_venc_linea)
              VALUES (pEmpresa,
                      pSolicitud,
                      pMonto,
                      dFechaApert,
                      pMonto, 
                      0,
                      NULL,
					  vFechaVig);
			LET iNumReg = dbinfo("sqlca.sqlerrd2");
		ELSE
			INSERT INTO "informix".sd_linea_prestamo
                    (empresa,
                     num_credito,
                     monto_linea,
                     fecha_otorga,
                     linea_disponible,
                     sec_credito,
                     fecha_cancela)
              VALUES (pEmpresa,
                      pSolicitud,
                      pMonto,
                      dFechaApert,
                      pMonto, 
                      0,
                      NULL);
			LET iNumReg = dbinfo("sqlca.sqlerrd2");
		END IF;
		
        IF iNumReg = 0 THEN
            LET cCodRet = "00003";
            DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
            DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
            DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            --DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
            DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
            DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
            RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
        END IF;
    END IF;
    -- CARGA LINEA DE CREDITO FIN

	-- SE GENERA EL FOLIO
	CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet, cNumeroFolio;

	-- SE ASIGNA EL FOLIO DE LA TRANSACCION
	IF cProducto = "6400" THEN ---para producto credinomina se utilizara esta transaccion.
		LET cTransacc = "0314";
	ELSE
		LET cTransacc = "0247";
	END IF;

    EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
								cProducto        , 3,
                                "001"            , dFechaApert,
                                pMonto           , cNumeroFolio,
                                cSucursal        , cDivisa,
                                "0000",'APERTURA','')
	INTO cCodRet, cErrorInfo;



	IF cCodRet <> "00000" THEN
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF

    IF cProducto NOT IN ('6800','7100') THEN
        EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
                                    cProducto        , 66,
                                    "002"            , dFechaApert,
                                    pMonto           , cNumeroFolio,
                                    cSucursal        , cDivisa,
                                    "0000",'DISPOSICION','')
        INTO cCodRet, cErrorInfo;
    END IF;

	IF cCodRet <> "00000" THEN
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF

	-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
	INSERT INTO "informix".sd_amortiza_creditocrd
		(
			empresa, 			num_credito,
			fecha_cuota, 		tipo_cuota,
			capital_mto_cuota, 	capital_debe,
			capital_pagado, 	capital_status,
			capital_status_ant, capital_fecha_pago,
			interes_debe, 		interes_pagado,
			interes_status, 	interes_status_ant,
			interes_fecha_pago, iva_debe,
			iva_pagado, 		iva_status,
			iva_status_ant, 	iva_fecha_pago,
			mora_provi_ordi, 	mora_provi_cope,
			mora_sdo_ordi, 		mora_sdo_ordi_pag,
			mora_sdo_cope, 		mora_sdo_cope_pag,
			mora_bonificado, 	mora_status,
			mora_iva_debe, 		mora_iva_pagado,
			mora_iva_status, 	mora_iva_fecha_pago,
			num_pago, 			campo_trabajo1,
			campo_trabajo2, 	campo_trabajo3,
			campo_trabajo4
		)
	VALUES
		(
			pEmpresa,			pSolicitud,
			dFechaT,			"3",
			pMensualidad,		0,
			0,					"3",
			"3",				"",
			0,					0,
			"1",				"1",
			"",					0,
			0,					"1",
			"1",				"",
			0,					0,
			0,					0,
			0,					0,
			0,					"1",
			0,					0,
			"1",				"",
			1,					0,
			0,					"",
			""
		);
	--SE INSERTA EN LA TABLA bdicred:sd_ctascarg
	--INSERT INTO "informix".sd_ctascarg (empresa, numero, con_cap_inte, naturaleza, num_credito, tipo_cta, num_cta, num_nomina) VALUES(pEmpresa,0,'','A',pSolicitud,'',pCuentaCap,'');

    -- SE ACTUALIZA EL ESTATUS DE LA SOLICITUD
    UPDATE bdisolic:"informix".ss_solicitudes 
	SET status_solicitud = "AP" 
	WHERE empresa = pEmpresa 
	AND num_solicitud = pSolicitud;

    --FMV 23abr13: Inserta cascaron para indicadores de prestamo a plazo
    INSERT INTO bdicred:sd_indicador_cred_crd (empresa, num_credito, fecha_alta,monto_mensual)
	VALUES (pEmpresa, pSolicitud, dFechaApert,pMensualidad);

    SELECT nombre 
	INTO cMensaje 
	FROM bdinteg:"informix".si_ejecut 
	WHERE ejecutivo = pEjecutivo 
	AND empresa = pEmpresa;

    LET cMensaje = "Apertura de Credito Autorizada por: " || TRIM(cMensaje);

	-- SE INSERTA EN LA TABLA DE AUTORIZACIONES DE SOLICITUD
    INSERT INTO bdisolic:"informix".ss_autorizacion (empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
	VALUES(pEmpresa, pEjecutivo, pSolicitud, "AP", cMensaje, dFechaApert, dFechaApert, USER, TODAY);

	-- SE GENERA EL ABONO 
	IF cProducto NOT IN ('6800','7100') THEN
        CALL bdicheq:"informix".abono_ref (pEmpresa, cSucursal, pEjecutivo, cTransacc, cTransacc, cNumeroFolio, pCuentaCap, 0,
		pMonto, pMonto, 0, 0, 0, "01", pSolicitud||" "||pNombrePres, '0', pEjecutivo) RETURNING cCodRet3;
    END IF;

	-- SI NO SE PUDO GENERAR EL ABONO SE REVERSAN TODOS LOS MOVIMIENTOS QUE SE HABIAN ECHO
	IF cCodRet3 <> "000" THEN
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet3,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    ELSE 
        LET idAbono = "S";         
	END IF;
	
	IF cProducto = "6400" THEN --JMAH		
		IF ( dPorcComisionAper > 0 ) then
			LET mComisionApertura= ROUND(pMonto * (dPorcComisionAper/100),2);
		    --SE REALIZA CARGO POR COMISION DE APERTURA
			CALL bdicheq:"informix".cargo_ref(pEmpresa, cSucursal, pEjecutivo, cTransaccCargo, "0000", cNumeroFolio,pCuentaCap, 0, mComisionApertura, 
            cDivisa,"", "0", pEjecutivo)
            RETURNING cCodRet, cTransacc, dtFecha_cargo, mDispo, mCargo;
			
            IF cCodRet::INTEGER <> 0  THEN
				DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
                DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
                DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                --DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
                DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
                
				CALL bdicheq:"informix".reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;
                
				IF cCodRet <> "000" THEN
					LET cCodRet    = "00004";
				ELSE
					LET cCodRet    = "00005";	--Ocurrio un Error al realizar el cargo  de la comision por apertura
				END IF;

                RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;

            LET mIvaComisionApertura = ROUND(mComisionApertura * dIvaSuc,2); --iva de la comision            
            CALL bdicheq:"informix".cargo_ref(pEmpresa, cSucursal, pEjecutivo,cTransaccIvaCargo, "0000", cNumeroFolio,
            pCuentaCap, 0, mIvaComisionApertura, cDivisa,"", "0", pEjecutivo)
            RETURNING cCodRet, cTransacc, dtFecha_cargo, mDispo, mCargo;

            IF cCodRet::INTEGER <> 0  THEN
				DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
				DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
				DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
				DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
                
				CALL bdicheq:"informix".reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;

				IF cCodRet <> "000" THEN
					LET cCodRet    = "00004";
				ELSE
					LET cCodRet    = "00006";	--Ocurrio un Error al realizar el cargo por iva de la comision por apertura
				END IF;
				
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;
		END IF;
	END IF;
	
    -- SE ACTUALIZAN LOS DATOS DEL CLIENTE
    SELECT a.numcte, tipo_cliente, NVL(ingreso_mensual,0)
    INTO cNumCte, cTpCte, mIngreso
    FROM bdinteg:"informix".si_cliente a
	INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.numcte = a.numcte
	INNER JOIN bdisolic:"informix".ss_resum_scor_fin c ON c.empresa = b.empresa AND c.num_solicitud = b.num_solicitud
	WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud;

    -- Saca la Publicacion de si_ctepf Jose Luis Puebla
    SELECT string1 INTO cMercadeo
    FROM   bdinteg:"informix".si_ctepf
    WHERE  numcte = cNumCte;

    IF cTpCte = "1" THEN
		SELECT MAX(sec_ingreso) INTO sSecIngreso FROM bdinteg:"informix".si_ingresos WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = 'T';

		UPDATE bdinteg:"informix".si_ingresos SET ingreso_mensual = mIngreso
		WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = "T" AND sec_ingreso = sSecIngreso;
    ELSE

		UPDATE bdinteg:"informix".si_cliente SET tipo_cliente = "1" WHERE numcte = cNumCte;

		SELECT NVL(MAX(sec_ingreso), 0) + 1 INTO sSecIngreso
		FROM bdinteg:"informix".si_ingresos
		WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = "T";

		INSERT INTO bdinteg:"informix".si_ingresos (empresa, numcte, sec_ingreso, tipo_ingreso, ingreso_mensual)
		VALUES (pEmpresa, cNumCte, sSecIngreso, "T", mIngreso);
    END IF

    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008
    LET mTasaMora = mTasaMora - mTasaInteres;
    IF mTasaMora < 0 THEN --Si es Menor a Cero la vuelve Positivo
		LET mTasaMora = mTasaMora * -1;
    END IF

    -- Actualiza informacion para la bitacora de la solicitud (auditoria-cnbv)      
    UPDATE bdisolic:"informix".ss_revision_determinacion SET plazo = pPlazo, pago_mens = pMensualidad WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	
    IF cProducto IN ('6800','7100') THEN
		SELECT NVL(telefono,'')
		INTO pNumCel
        FROM bdinteg:si_telefonos_actual 
        WHERE numcte = cNumCte
        AND tipo_tel = '2' 
        AND status_tel = 'A';

        IF (pNumCel <> '') THEN
			CALL bdimnsj:"informix".sp_registra_evento(2,'SMS_RECI','PPF_SMSAP1','000000000','','',1, '','','','','','','','','','','',pNumCel,0,0,0,0,0,'','') RETURNING sCodRetEvento;
			CALL bdimnsj:"informix".sp_registra_evento(2,'SMS_RECI','PPF_SMSAP2','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,'','') RETURNING sCodRetEvento;
        END IF;
    END IF;
	
    RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
END;
END PROCEDURE
DOCUMENT
'AUTOR: DR Roro',
'Descripcion: Apertura de prestamo personal con domiciliacion',
'Fecha: 2020/10/07',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Jorge M REYES',
'Descripcion: Se agrega flujo oneclick para cambiar la tasa de interes desde trx',
'Fecha: 2022/11/04',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Rodolfo Tortolero',
'Descripcion: Se agrega flujo oneclick para que tome la sucursal origen del cliente cuando la solicitud viene desde la aplicacion.',
'Fecha: 2023/06/007',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Angel Anguiano',
'Descripcion: Se agrega cambio de sucursal 8503 por 6700 oneclick.',
'Fecha: 2024/02/28',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Cinthia Aguilar',
'Descripcion: Se agrega validacion para asignar sucursal 6700 por default',
'Fecha: 2025/05/21',
'BD: BDICRED',
'--------------------------------------------------------------';

CREATE PROCEDURE "informix".apercred1_pp_domicilia_web(
			 pEmpresa       VARCHAR(3), 	-- EMPRESA
             pSolicitud     VARCHAR(20), 	-- NUMERO DE SOLICITUD
		 	 pEjecutivo     CHAR(8),		-- EJECUTIVO
			 pPlazo			INTEGER,		-- PLAZO EN MESES PARA PAGAR EL CREDITO
			 pNombrePres	CHAR(50),		-- NOMBRE DEL PRESTAMO
			 pMonto			DECIMAL(18,2),	-- MONTO APROBADO
			 pCuentaCap		CHAR(20),		-- CUENTA DE CAPTACION
			 pMensualidad	MONEY(18,2),	-- IMPORTE MENSUAL
			 pFrecuencia    INTEGER, 		-- Frecuencia de pago (--1.- Mensual credinomina / --2.- Quincenal credinomina)
			 pAceptoIncremento    CHAR(9) 	-- MUESTRA SI ACEPTA O NO EL AUMENTO DE LINEA DE CREDITO A FUTURO
			 )
RETURNING CHAR(5),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);


--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE cCodRet				VARCHAR(5);		-- CODIGO DE RETORNO
DEFINE cCodRet3				VARCHAR(6);		-- CODIGO DE RETORNO ABONOREF BDICHEQ
DEFINE cCodRetTDif			CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE cErrorInfo           VARCHAR(80);	-- MENSAJE DE ERROR
DEFINE mTasaInteres         DECIMAL(18,2);	-- TASA DE INTERES
DEFINE mTasaMora            DECIMAL(18,2);	-- TASA MORATORIA
DEFINE mSobreTasa           DECIMAL(18,2);	-- SOBRETASA
DEFINE mSobreTasa_MORA      DECIMAL(18,2);	-- SOBRETASA MORA
DEFINE mTasaFavor           DECIMAL(18,2);	-- TASA A FAVOR
DEFINE mSobreTasaFAV        DECIMAL(18,2);	-- SOBRETASA A FAVOR DEL CLIENTE
DEFINE cFactor	            CHAR(1);		-- FACTOR
DEFINE cFactor_Mora	        CHAR(1);		-- FACTOR MORA
DEFINE dFechaApert          DATE;			-- FECHA DE INICIO DEL PRESTAMO
DEFINE dFechaVenc           DATE;			-- FECHA DE TERMINACION DEL PRESTAMO
DEFINE iSqlErr              INTEGER;		-- CODIGO DE ERROR
DEFINE iIsamError           INTEGER;		-- CODIGO DE ERROR
DEFINE cNumCte              CHAR(20);		-- NUMERO DE CLIENTE
DEFINE cTpCte               CHAR(1);		-- TIPO DE CLIENTE
DEFINE mIngreso             DECIMAL(18,2);	-- INGRESO DEL CLIENTE
DEFINE cFactorFAV           CHAR(1);		-- FACTOR A FAVOR DEL CLIENTE
DEFINE cProducto            CHAR(4);		-- CODIGO DE PRODUCTO
DEFINE cDivisa              CHAR(2);		-- DIVISA
DEFINE cSucursal            CHAR(4);		-- CODIGO DE SUCURSAL
DEFINE cFolio	            CHAR(16);		-- FOLIO PARA GENERACION DE MOVIMIENTOS DIARIOS
DEFINE cMensaje             CHAR(200);		-- MENSAJE MAS NOMBRE DE EJECUTIVO
DEFINE dFechaT              DATE;			-- FECHA DEL MES POSTERIOR A LA APERTURA
DEFINE sDiaCorte            SMALLINT;		-- DIA DE CORTE
DEFINE i		     		SMALLINT;		-- VARIABLE PARA ITERACION
DEFINE mCatIva		    	DECIMAL(18,2);	-- VALOR DEL CAT DEL IVA
DEFINE cMercadeo            CHAR(1);		-- PUBLICACION
DEFINE sSecIngreso 			SMALLINT;		-- SECUENCIA DE INGRESOS
DEFINE mTasaInteresProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE mTasaMoraProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE cPeriodoPag			CHAR(1);		-- PERIODICIDAD DEL PAGO
DEFINE iDiasTraspCap		INTEGER;		-- DIAS PARA TRASPASO DE CAPITAL
DEFINE iDiasTraspInt		INTEGER;		-- DIAS PARA TRASPASO DE INTERESES
DEFINE cNumeroFolio 		CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE cTransacc 			CHAR(4);	 	-- FOLIO DE TRANSACCION DEL ABONO
DEFINE iNumReg				INTEGER;		-- NUMERO DE REGISTROS DE UNA OPERACION
DEFINE dIvaSuc              DECIMAL(5,3);   -- IVA DE LA SUCURSAL DONDE SE GENERO LA SOLICITUD
DEFINE idAbono              CHAR(1);
DEFINE sDiasPeriodo         SMALLINT;
DEFINE dtDiaprimero         DATE;
DEFINE dtFecha_cargo  		DATE;
DEFINE mDispo         		MONEY(14,2);
DEFINE mCargo         		MONEY(14,2);
DEFINE mIvaComisionApertura MONEY(14,2);
DEFINE mComisionApertura    MONEY(14,2);
DEFINE dPorcComisionAper    DECIMAL(9,6);
DEFINE cTransaccIvaCargo    CHAR(4);
DEFINE cTransaccCargo       CHAR(4);
DEFINE iContador         	SMALLINT;
DEFINE mTotalPagar			DECIMAL(18,2);
DEFINE iNum_periodos    	INTEGER;
DEFINE dtFecha_cuota    	DATE;
DEFINE dSdo_inicial     	MONEY(14,2);
DEFINE dPago_mensual    	MONEY(14,2);
DEFINE dMto_Interes     	MONEY(14,2);
DEFINE dIva_interes     	MONEY(14,2);
DEFINE dCapital         	MONEY(14,2);
DEFINE dSdo_final       	MONEY(14,2);
DEFINE sDias_periodo    	SMALLINT;
DEFINE dtFecha_Aper			DATE;
DEFINE iDiaPago      		INTEGER;
DEFINE cNumMesesPagos   	CHAR(3);
DEFINE cCodRet2         	CHAR(6);
DEFINE cMensajeRet      	VARCHAR(80,1);
DEFINE vCatFinal        	DECIMAL(21,10);
DEFINE dPagoReq      		DECIMAL(18,2);
DEFINE pNumCel       		CHAR(13);
DEFINE sCodRetEvento 		CHAR(5);
DEFINE pMontoSolOtorga		DECIMAL(18,2);	-- MONTO APROBADO PRODUCTO 6800,7100
DEFINE vcod_ret				CHAR (6);
DEFINE cta_Clabe			CHAR (18);
DEFINE count_maecrd			SMALLINT;
DEFINE count_mdoscrd		SMALLINT;
DEFINE count_maeanexcrd		SMALLINT;
DEFINE count_ctascarg		SMALLINT;
DEFINE count_amortcrd		SMALLINT;
DEFINE count_ssautoriz		SMALLINT;
DEFINE cIFRS				CHAR(1);
DEFINE cStatus_cred 		CHAR(2);
DEFINE iAtr_Act_ifrs		INTEGER;
DEFINE iPlazo_pago          INTEGER;
DEFINE vCancelVig           INTEGER;
DEFINE vFechaVig 			DATE;
DEFINE CanalSol             CHAR(1);
DEFINE count_suc			SMALLINT;
--variables de validacion de cierre					
DEFINE dFechaIntegral   DATE;
DEFINE dFechaCierreCred   DATE;
DEFINE dFechaHabilAnt		DATE;
DEFINE cStatusCierreCred  CHAR(1);
DEFINE cIndCierreCheq   CHAR(1);

--***********************
--INICIALIZA VARIABLES
--***********************
LET cCodRet      		= '00000';
LET cCodRet3			= '000';
LET cCodRetTDif			= '';
LET cErrorInfo    		= 'PROCESO EXITOSO';
LET mTasaInteres 		= 0;
LET mTasaMora 			= 0;
LET mSobreTasa   		= 0;
LET mSobreTasa_MORA		= 0;
LET mTasaFavor   		= 0;
LET mSobreTasaFAV		= 0;
LET cFactor	  			= "";
LET cFactor_Mora		= "";
LET dFechaApert 		= DATE(1);
LET dFechaVenc 			= DATE(1);
LET iSqlErr    			= 0;
LET iIsamError 			= 0;
LET cErrorInfo 			= "";
LET cNumCte    			= "";
LET cTpCte     			= "";
LET mIngreso   			= 0;
LET cFactorFAV 			= "";
LET cProducto  			= "";
LET cDivisa    			= "";
LET cSucursal			= "";
LET cFolio				= "";
LET cMensaje 			= "";
LET dFechaT  			= DATE(1);
LET sDiaCorte			= 0;
LET i 					= 0;
LET mCatIva				= 0;
LET cMercadeo 			= "";
LET sSecIngreso			= 0;
LET mTasaInteresProd	= 0;
LET cPeriodoPag			= "";
LET iDiasTraspCap		= 0;
LET iDiasTraspInt		= 0;
LET cNumeroFolio		= "";
LET cTransacc			= "";
LET iNumReg				= 0;
LET dIvaSuc             = 0;
LET idAbono             = "N";
LET sDiasPeriodo        = 0;
LET dtDiaprimero  	 	= DATE(1);
LET dtFecha_cargo  	    = DATE(1);
LET mDispo              = 0;
LET mCargo      	    = 0;
LET mIvaComisionApertura = 0;
LET mComisionApertura	= 0;
LET dPorcComisionAper   = 0;
LET cTransaccIvaCargo   = "";
LET cTransaccCargo      = "";
LET iContador      	    = 0;
LET mTotalPagar			= 0;
LET iNum_periodos		= 0;
LET dtFecha_cuota      	= DATE(1);
LET dSdo_inicial      	= 0;
LET dPago_mensual      	= 0;
LET dMto_Interes      	= 0;
LET dIva_interes      	= "";
LET dCapital      	   	= "";
LET dSdo_final      	= 0;
LET sDias_periodo      	= 0;
LET dtFecha_Aper      	= DATE(1);
LET iDiaPago       		= 0; 
LET cNumMesesPagos  	= "";
LET cCodRet2            = "000000";
LET cMensajeRet         = "Se realizo el calculo correctamente";
LET vCatFinal 			= 0;
LET dPagoReq 			= 0;
LET pNumCel  			= '';
LET sCodRetEvento		= '';
LET pMontoSolOtorga     = 0; 
LET vcod_ret			= '000';
LET cta_Clabe			= '';	
LET count_maecrd		= 0;
LET count_mdoscrd		= 0;
LET count_maeanexcrd	= 0;
LET count_ctascarg		= 0;
LET count_amortcrd		= 0;
LET count_ssautoriz		= 0;
LET cIFRS				= '';
LET cStatus_cred 		= '';
LET iAtr_Act_ifrs		= 0;
LET iPlazo_pago         = 0;
LET vCancelVig          = 0;
LET vFechaVig           = '';
LET CanalSol            = '';
LET count_suc 			= 0;
--variables de validacion de cierre					 
LET dFechaIntegral   = DATE(1);
LET dFechaCierreCred   = DATE(1);
LET dFechaHabilAnt   = DATE(1);
LET cStatusCierreCred  = '1';
LET cIndCierreCheq   = '1';
--SET DEBUG FILE TO '/ifxsif01/ciaguilar/APERTURA_CREDITO/apercred1_pp_domicilia_web.out';
-- TRACE ON;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
		LET cErrorInfo  = cErrorInfo;

		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
        IF idAbono = "S" THEN         
             CALL bdicheq:"informix".reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;
             IF cCodRet <> "000" THEN
                LET cCodRet    = "00004";
             END IF;
        END IF;
        LET cCodRet    = iSqlErr;
        RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SE VALIDA QUE LOS DATOS DE ENTRADA SEAN CORRECTOS
	IF NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "" OR NVL(pEjecutivo,"") = ""  OR NVL(pNombrePres,"") = "" OR NVL(pCuentaCap,"") = "" THEN
		LET cCodRet = "00002";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF
	
	-- Valida si se encuentra activa funcionalidad de IFRS
	SELECT valor INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
	IF cIFRS = 'A' THEN
		LET cStatus_cred = 'E1';
		LET iAtr_Act_ifrs = 0;
	ELSE
		LET cStatus_cred = 'AA';
		LET iAtr_Act_ifrs = NULL;
	END IF;	
	
	-- SE OBTIENE LA CLAVE DEL PRODUCTO, EL CODIGO DE DIVISA, EL MONTO DEL PRESTAMO SOLICITADO, LA SUCURSAL Y EL MONTO AUTORIZADO--se mueve consulta JMAH
	SELECT a.num_producto, a.divisa, b.sucursal, b.monto_autorizado
	INTO cProducto, cDivisa, cSucursal, pMontoSolOtorga
	FROM bdisolic:"informix".ss_solicitudes b
	INNER JOIN "informix".sd_definicion a ON a.empresa = b.empresa AND a.num_producto = b.num_producto
	WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud;
	
    IF cProducto IN ('6800','7100') THEN
		LET pMonto = pMontoSolOtorga;
    END IF;
	
	IF cProducto = '6400' THEN--JMAH
		IF NVL(pPlazo,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF NVL(pMonto,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF NVL(pMensualidad,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF iContador <> 2 THEN 
			LET cCodRet = "00002";
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;	
    ELSE
	  IF NVL(pPlazo,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF NVL(pMonto,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;		
		IF iContador <> 2 THEN 
			LET cCodRet = "00002";
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;	
	END IF;	
	
	--SE VALIDA QUE NO EXISTA EL CREDITO
	--Se omite la tabla sd_ctascarg de los productos 6300,6800,7600 y 7700 ya que se domicilia antes y hace el insert a la tabla previamente.
	SELECT COUNT(num_credito) INTO count_maecrd FROM "informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT COUNT(num_credito) INTO count_mdoscrd FROM "informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT COUNT(num_credito) INTO count_maeanexcrd FROM "informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	--SELECT COUNT(num_credito) INTO count_ctascarg FROM "informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud;
	SELECT COUNT(num_credito) INTO count_amortcrd FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND fecha_cuota = dFechaT AND num_credito = pSolicitud;
	SELECT COUNT(num_solicitud) INTO count_ssautoriz FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
 	--validacion de cierre
	SELECT fecha_hoy INTO dFechaIntegral FROM bdinteg:"informix".si_fechas WHERE empresa = '001';
	SELECT MAX(fecha) INTO dFechaCierreCred FROM "informix".sd_contproc WHERE empresa = '001' AND proceso = "CierrePrest";
	SELECT status_proc INTO cStatusCierreCred FROM "informix".sd_contproc WHERE proceso = "CierrePrest" AND fecha = dFechaCierreCred;
	SELECT ind_cierre INTO cIndCierreCheq FROM bdicheq:"informix".sc_fechas WHERE empresa = '001';

	EXECUTE PROCEDURE "informix".sp_valfechabil((dFechaIntegral - 1),'-') INTO cCodRet2, dFechaHabilAnt;
		
	IF cIndCierreCheq = '0' OR dFechaCierreCred <> dFechaHabilAnt OR UPPER(cStatusCierreCred) <> 'F' THEN	
		LET cCodRet="00009";
        RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;
	--
	--Valida que la solicitud sea de flujo One Click.
	SELECT canal_sol INTO CanalSol FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = pSolicitud;
	
	--6 igual a Sucursal, 7 igual a App.
	IF(CanalSol = '6' OR CanalSol = '7') THEN
		--Toma la tasa que proporciono el area de credito para los clientes pre aprobados.
		SELECT tasa INTO mTasaInteres FROM bdicred:"informix".sd_pre_aprobados_trx WHERE solicitud = pSolicitud;
		
		LET mTasaInteresProd = mTasaInteres;
		
		--obtiene la sucursal que se esta llevando la apertura del prestamo para la solicitud de one click con base al ejecutivo.
		-- Si pEjecutivo es igual a 0 el flujo viene desde la App, si es diferente de 0 el flujo viene de sucursal.
		IF pEjecutivo = "0" OR pEjecutivo IS NULL THEN
			--Se toma la sucursal origen del cliente. se agrego el case para cambiar la sucursal 8503 por la 6700 actividad DUD
			SELECT CASE WHEN cte.sucursal='8503' THEN '6700' ELSE cte.sucursal END
			INTO cSucursal 
			FROM bdinteg:"informix".si_cliente cte 
			JOIN bdisolic:"informix".ss_solicitudes sol ON (cte.numcte = sol.numcte)
			WHERE sol.empresa = pEmpresa AND sol.num_solicitud = pSolicitud;
		ELSE
			--Se toma la sucursal de acuerdo al ejecutivo que esta realizando el proceso de formalizacion del prestamo.
			SELECT sucursal INTO cSucursal FROM bdinteg:"informix".si_ejecut WHERE empresa = pEmpresa AND ejecutivo = pEjecutivo;
		END IF;
		
		-- CAX Mayo 2026 se valida sucursal y en caso de que sea no operativa se asigna la suc 6700 por default 
		SELECT count(*) INTO count_suc FROM bdinteg:si_sucursales WHERE sucursal = cSucursal and tpo_sucursal = 'S';
	
		IF count_suc = 0 THEN 
			LET cSucursal = '6700';
		END IF;
	END IF;
	
	-- CAX 09092025 se valida sucursal que sea tipo S (operativa)
	SELECT count(*) INTO count_suc FROM bdinteg:si_sucursales WHERE sucursal = cSucursal and tpo_sucursal = 'S';
	SELECT COUNT(num_credito) INTO count_ctascarg FROM "informix".sd_ctascarg WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	
	--IF EXISTS (SELECT num_credito FROM "informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	IF count_maecrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM "informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF count_mdoscrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM "informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF count_maeanexcrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM "informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud) THEN
	--ELIF count_ctascarg > 0 THEN
	--	LET cCodRet = "000001";
	--	RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND fecha_cuota = dFechaT AND num_credito = pSolicitud) THEN
	ELIF count_amortcrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP") THEN
	ELIF count_ssautoriz > 0 THEN   
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	ELIF count_suc = 0 THEN   ---VALIDA QUE LA SUCURSAL SEA OPERATIVA
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	ELIF pMonto <= 0 THEN  --- VALIDA QUE EL MONTO SEA MAYOR A CERO
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	ELIF count_ctascarg = 0 THEN --- VALIDA QUE TENGA CUENTA CARGO CHEQUES
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
	SELECT valor INTO mCatIva
	FROM   "informix".sd_param
	WHERE  cod_param = '034';
	IF mCatIva IS NULL THEN
	   LET mCatIva = 0;
	END IF

    -- SE DETERMINAN LAS DIFERENTES TASAS DE INTERES	
	EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(pEmpresa, pSolicitud, '') INTO cCodRetTDif, mTasaInteres, mTasaMora;
	IF cCodRetTDif <> '000000' THEN
		LET cCodRet = SUBSTRING (cCodRetTDif FROM 1 FOR 5);
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;	

	SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo, a.fact_sobret_mora, a.sobretasa_mora
	INTO cFactor,            mSobreTasa,  sDiaCorte,   cPeriodoPag,	  cFactor_Mora, 	  mSobreTasa_MORA	
	FROM "informix".sd_definicion a
	INNER JOIN bdisolic:"informix".ss_solicitudes b ON (a.empresa = b.empresa AND a.num_producto = b.num_producto and b.num_solicitud = pSolicitud);

	LET mTasaInteresProd = mTasaInteres;

	IF cFactor = "+" THEN
		LET mTasaInteres = mTasaInteres + mSobreTasa;
	ELIF cFactor = "-" THEN
		LET mTasaInteres = mTasaInteres - mSobreTasa;
	ELIF cFactor = "*" THEN
		LET mTasaInteres = mTasaInteres * mSobreTasa;
	ELSE
		LET mTasaInteres = mTasaInteres / mSobreTasa;
	END IF

	LET mTasaMoraProd = mTasaMora;

	IF cFactor_Mora = "+" THEN
		LET mTasaMora = mTasaMora + mSobreTasa_MORA;
	ELIF cFactor_Mora = "-" THEN
		LET mTasaMora = mTasaMora - mSobreTasa_MORA;
	ELIF cFactor_Mora = "*" THEN
		LET mTasaMora = mTasaMora * mSobreTasa_MORA;
	ELSE
		LET mTasaMora = mTasaMora / mSobreTasa_MORA;
	END IF

	--INTERES A FAVOR DEL CLIENTE
	SELECT c.valor, a.factor_sobretasa, a.sobretasa
	INTO mTasaFavor, cFactorFAV, mSobreTasaFAV
	FROM "informix".sd_anexodefinicion a
	INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
	INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_base
	WHERE b.empresa = pEmpresa AND num_solicitud = pSolicitud
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_base);

	IF cFactorFAV = "+" THEN
		LET mTasaFavor = mTasaFavor + mSobreTasaFAV;
	ELIF cFactorFAV = "-" THEN
		LET mTasaFavor = mTasaFavor - mSobreTasaFAV;
	ELIF cFactorFAV = "*" THEN
		LET mTasaFavor = mTasaFavor * mSobreTasaFAV;
	ELSE
		LET mTasaFavor = mTasaFavor / mSobreTasaFAV;
	END IF	

	-- SE OBTIENEN LAS FECHAS DE INICIO, Y FIN DEL PRESTAMO Y LA FECHA DEL SIGUIENTE MES DESPUES DE LA APERTURA DEL CREDITO
	SELECT fecha_hoy INTO dFechaApert FROM "informix".sd_fechas WHERE empresa = pEmpresa;	
	--se modifica la forma en que se se obtiene la fecha del primer pago del credito para homologarlo con la proyeccion.
	IF cProducto = '6400' THEN    ---Periodo de pago credinomina		
		--se obtiene la fecha de la proxima cuota.
		EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapago('001',dFechaApert,pSolicitud)
		INTO cCodRet,dFechaT,iDiaPago;	
		IF cCodRet::INTEGER <> 0  THEN	
			LET cCodRet    = "00008";	--Ocurrio un Error al obtener la fecha de primer pago del credito para credinomina.
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;	
		CALL "informix".sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;	 			
	END IF;
	
	IF cProducto = '6400' THEN---Periodo de pago Mensual prestamo 	--JMAH
		--se obtiene fecha de vencimiento para credinomina
		FOREACH 
		EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (pMonto,pPlazo,pMensualidad,cProducto,cSucursal,1,0,pSolicitud,"",pFrecuencia)
		INTO cCodRet,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
		dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos			
		
			IF cCodRet::INTEGER <> 0  THEN				
				LET cCodRet    = "00007";	--Ocurrio un Error al obtener la fecha de vencimiento del credito para credinomina.
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;
			
			IF iNum_periodos=1 THEN
				LET pMensualidad = dPago_mensual;
				LET pMonto = dSdo_inicial;					
			END IF;					
				LET dFechaVenc = dtFecha_cuota;					
	    END FOREACH;
		
		LET pPlazo = iNum_periodos; 
	ELSE
		CALL "informix".monthadd(dFechaApert,1) RETURNING dFechaT;
	    CALL "informix".sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;	  
        IF cProducto IN ('6800','7100') THEN
			IF cProducto = '6800' THEN
				SELECT TRIM(valor) INTO iPlazo_pago
				FROM bdicred:sd_param                  
                WHERE empresa  = pEmpresa AND cod_param = 'A01';
 
				CALL "informix".monthadd(dFechaApert,iPlazo_pago) RETURNING dFechaVenc;
			ELSE
				CALL "informix".monthadd(dFechaApert,36) RETURNING dFechaVenc;
			END IF;
        ELSE
			CALL "informix".monthadd(dFechaApert,pPlazo) RETURNING dFechaVenc;
        END IF;
	END IF;	
	
	IF cCodRet::INTEGER <> 0 THEN
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;
	--AAME 20150317 RQM 10 550 Se anexan nuevos productos de prestamo ('7600','7700') para que realice la proyeccion.
	--CYRV 20171113 RQM 10 915 Se agrega nuevo prestamos a proyeccion 6800 y 7100
	--IF (cProducto = '6300') OR (cProducto = '6400') OR (cProducto = '7600') OR (cProducto = '7700') OR (cProducto = '6800') OR (cProducto = '7100') THEN
	IF cProducto IN ('6300','6400','7600','7700','6800','7100') THEN
	--VALIDACION PARA CALCULAR EL MONTO TOTAL A PAGAR PARA UN PRESTAMO PERSONAL
		FOREACH 
		--SE OBTIENE CON EL PROYECTA PRESTAMO CADA UNA DE LAS MENSUALIDADES PARA SUMARLAS y CALCULAR EL MONTO TOTAL A PAGAR
	    EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (pMonto,pPlazo,0,cProducto,cSucursal,1,0,pSolicitud,"",pFrecuencia)
		INTO cCodRet,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
		dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos
			
			--SE VALIDAD PARA VER SI EL PROYECTA PRESTAMO SE EJECUTO CORRECTAMENTE
			IF cCodRet::INTEGER <> 0  THEN
				LET cCodRet = SUBSTRING (cCodRet FROM 1 FOR 5);
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;
			
			--VARIABLE QUE GUARDA LA SUMA DE LAS MENSUALIDADES
			LET mTotalPagar = mTotalPagar + dPago_mensual::DECIMAL(18,2);	
			IF iNum_periodos=1 THEN
				LET pMensualidad = dPago_mensual;
			END IF;			
	    END FOREACH;
	END IF;
	
	SELECT a.iva
	INTO dIvaSuc
    FROM bdinteg:"informix".si_sucursales a
    WHERE a.sucursal = cSucursal
    AND a.empresa  = pEmpresa;
		  
	--- Genera cuenta Clabe
	EXECUTE PROCEDURE bdicred:"informix".sp_gen_clabe_interbancaria (pEmpresa,pSolicitud,cProducto)
	INTO vcod_ret, cta_Clabe;		  
	
	--***** SE INSERTA INFORMACION EN SD_MAECREDCRD
	INSERT INTO "informix".sd_maecredcrd
		   (empresa,                        num_credito,
			num_producto,                   ejecutivo,
			numcte,                         aval_cte,
			aval_linea,                     divisa,
			sucursal,                       id_origen,
			origen,                         cod_tipo_linea,
			cod_linea,                      status_cred,
			bandera_renovac,                bandera_prorroga,
			periodo_plazo,                  plazo,
			fecha_apertura,                 fecha_vencim,
			period_pago_cap,                period_pag_int,
			dias_trasp_cap,                 dias_trasp_int,
			tasa_fija_o_var,                cod_tasa_base,
			factor_sobretasa,               sobretasa,
			tasa_interes,                   cod_tasa_mora,
			sobretasa_mora,                 fact_sobret_mora,
			tasa_moratorios,                tasa_preferencial,
			sobretasa_preferencial,         factor_preferencial,
			valor_preferencial,             fecha_pago_cap,
			fecha_pago_int,                 es_fisica,
			bandera_fi_fo,                  actividad,
			tipo_calculo,                   num_aper_ant,
			rev_tasa_var_per,               dia_para_revisar,
			cod_prod,                       bandera_ministra,
			credito_externo,                califica_riesgo,
			cod_agricola,                   pagos_sostenidos,
			campo_trab1,                    campo_trab2,
			campo_trab3,                    campo_trab4
			,cuenta_clabe
		   )
	SELECT  sol.empresa                		,pSolicitud
		   ,sol.num_producto                ,NVL(anx.ejecutivo_sol,'')
		   ,sol.numcte                      ,''
		   ,''                              ,NVL(def.divisa,1)
		   ,NVL(sol.sucursal,'')            ,''
		   ,''                              ,''
		  -- IFRS ,''                              ,'AA'
		   ,''                              ,cStatus_cred
		   ,'S'                             ,'N'
		   ,SUBSTR(tipo_pago,1,1)		   --,NVL(def.periodo_plazo,'')     
		   
		   ,pPlazo
		   ,dFechaApert  					,dFechaVenc
		   ,NVL(def.period_pago_cap,'')     ,NVL(def.period_pag_int,'')
		   ,NVL(def.dias_traspaso_cap,0)    ,NVL(def.dias_traspaso_int,0)
		   ,NVL(def.tasa_fija_o_var,'')     ,NVL(def.cod_tasa_base,'')
		   ,NVL(def.factor_sobretasa,'')    ,NVL(def.sobretasa,'')
		   ,mTasaInteresProd                ,NVL(def.cod_tasa_mora,'')
		   ,NVL(def.sobretasa_mora,0)       ,NVL(def.fact_sobret_mora,'')
		   ,NVL(mTasaMoraProd,0)            ,''
		   ,0                               ,''
		   ,0                               ,dFechaT
		   ,dFechaT							,NVL(tip.es_fisica,'')
		   ,''                              ,''
		   ,NVL(def.tipo_calculo,'')        ,dIvaSuc
		   ,''                              ,NVL(def.dia_para_revisar,0)
		   ,''                              ,SUBSTR(tipo_pago,1,1)	--cPeriodoPag
		   ,''                              ,''
		   ,''                              ,0
		   ,0                               ,0
		   ,''                              ,''
		   ,cta_Clabe
	FROM bdisolic:"informix".ss_solicitudes sol
		INNER JOIN "informix".sd_definicion def ON def.empresa = sol.empresa AND def.num_producto = sol.num_producto
		INNER JOIN bdisolic:"informix".ss_anexosol anx ON anx.num_solicitud = sol.num_solicitud AND anx.empresa = sol.empresa
		INNER JOIN bdinteg:"informix".si_cliente cli ON cli.empresa = sol.empresa AND cli.numcte = sol.numcte
		INNER JOIN bdinteg:"informix".si_tipper tip ON tip.tpo_persona = cli.tpo_persona
		INNER JOIN "informix".sd_cattipopago pago ON pago.empresa = pEmpresa AND valor = pFrecuencia 
		WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;	
		
	LET iNumReg = dbinfo("sqlca.sqlerrd2");

	IF iNumReg = 0 THEN
		LET cCodRet = "00003";
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;
	
	IF(CanalSol = '6' OR CanalSol = '7') THEN
		UPDATE bdicred:"informix".sd_maecredcrd SET sucursal = cSucursal WHERE num_credito = pSolicitud;
	END IF;

     --***** SE INSERTA INFORMACION EN SD_MAECREDANEXOCRD (DATOS PARA TARJETA DE CREDITO)
    BEGIN
	    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
			LET cCodRet    = iSqlErr;
			LET cErrorInfo  = cErrorInfo;
	        RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	    END EXCEPTION;

		IF cProducto = "6400" THEN --JMAH
		--se obtiene el porcentaje de comision por apertura.
			SELECT valor INTO dPorcComisionAper
			FROM   "informix".sd_param
			WHERE  cod_param = '040';
			
			--se obtiene la transaccion con la que registrara el cargo de la comision
			SELECT valor INTO cTransaccCargo
			FROM   "informix".sd_param
			WHERE  cod_param = '041';
			--se obtiene la transaccion con la que registrara el iva del cargo de la comision
			SELECT valor INTO cTransaccIvaCargo
			FROM   "informix".sd_param
			WHERE  cod_param = '042';
	
            IF ( dPorcComisionAper is null ) THEN LET dPorcComisionAper = 0; END IF;

            IF ( dPorcComisionAper > 0 ) then
				LET mComisionApertura= ROUND(pMonto * (dPorcComisionAper/100),2);
			END IF
		END IF
		
		--RQM 10 751
		--RQM 10 737 
		LET dPagoReq = pMonto / ((1- pow((1+((mTasaInteres /100)/( pFrecuencia * 12 ))),-pPlazo)) / ((mTasaInteres /100)/( pFrecuencia * 12 )) ) ;
			
		EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir_pp(pMonto,dPagoReq,pPlazo,(12 * pFrecuencia),mComisionApertura) 
		into cCodRet2,cMensajeRet,vCatFinal;
		LET mCatIva = vCatFinal;
				
		IF cCodRet2::integer  <> 0 THEN
			LET cCodRet = "00003";
			DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
			DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
			DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
			DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;
	
		INSERT INTO "informix".sd_maecredanexocrd
			(empresa, 				 		num_credito,
			 localidad,              		dia_corte,
	         dias_gracia_mora, 		 		tp_dias_calc_mora,
	         dias_fecha_max_pago,	 		tp_dias_fecha_pago,
	         cod_tasa_base_cte, 	 		factor_sobretasa_cte,
	         sobretasa_cte, 		 		tasa_interes_cte,
	         fecha_vencto, 			 		prox_fecha_pago,
	         fecha_proceso,			 		fecha_ult_pago,
	         nombre_pres, 					cat)
		SELECT pEmpresa              		,pSolicitud,
               ""                    		,(CASE WHEN NVL(def.num_producto,"") = "6400"  THEN DAY(dFechaT) ELSE  DAY(dFechaApert) END) ,--JMAH
			   NVL(def.gracia_calc_mora,0)  ,'',
			  (CASE WHEN NVL(def.num_producto,"") = "6400"  THEN DAY(dFechaT) ELSE  DAY(dFechaApert) END),--JMAH -- DAY(dFechaApert)      		,
			   (CASE WHEN NVL(nom.Frecuencia_pgo,0) = 0  THEN NVL(def.maneja_linea::INTEGER,0) ELSE  NVL(nom.Frecuencia_pgo,0) END) ,
			   NVL(def.cod_tasa_base,'')	,NVL(def.factor_sobretasa,''),
			   NVL(def.sobretasa,0)    		,mTasaInteresProd,
			   ""                    		,dFechaT,
			   dFechaApert           		,"",
			   pNombrePres,					vCatFinal
		FROM "informix".sd_definicion def
		INNER JOIN bdisolic:"informix".ss_solicitudes c ON c.empresa = def.empresa AND c.num_producto = def.num_producto
		LEFT JOIN  bdisolic:"informix".ss_sol_nomina nom ON (nom.empresa = c.empresa AND nom.num_solicitud = c.num_solicitud)		
		--INNER JOIN bdicred:sd_anexodefinicion b ON b.empresa = def.empresa AND b.num_producto = c.num_producto
		--AND b.cod_prod = def.cod_tipcred
		WHERE c.empresa = pEmpresa AND c.num_solicitud = pSolicitud;
    END;
	
    --***** SE INSERTA INFORMACION EN SD_MAESDOSCRD
	LET iNumReg = dbinfo("sqlca.sqlerrd2");

	IF iNumReg = 0 THEN
		LET cCodRet = "00003";
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;

    BEGIN
	    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
			LET cCodRet    = iSqlErr;
	        LET cErrorInfo  = cErrorInfo;
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	    END EXCEPTION;

        IF cProducto IN ('6800','7100') THEN
            INSERT INTO "informix".sd_maesdoscrd
                    (
                        empresa, 			num_credito,
                        fecha_ult_mov, 		sdo_int_anticip,
                        sdo_int_ant_dev, 	sdo_intereses,
                        sdo_dia_ant_int, 	sdo_mes_ant_int,
                        sdo_acum_mes_int, 	sdo_retenido,
                        sdo_acum_cap_int, 	sdo_exig_int,
                        sdo_no_exig, 		provision_normal,
                        dias_acum_int, 		sdo_moratorio,
                        sdo_dia_ant_mor, 	sdo_mes_ant_mor,
                        sdo_contab_mora, 	dias_acum_mora,
                        sdo_capital, 		sdo_cap_insoluto,
                        sdo_dia_ant_cap, 	sdo_mes_ant_cap,
                        sdo_acum_mes_cap, 	mto_capitalizado,
                        mto_ministra_cap, 	cargos_dia_cap,
                        abonos_dia_cap, 	cargos_mes_cap,
                        abonos_mes_cap, 	dias_acum_cap,
                        monto_vencido, 		mto_venc_trasp,
                        monto_financiado, 	monto_reservado,
                        sdo_acum_vencido, 	dias_acum_intper,
                        sdo_global_int, 	sdo_acum_intper,
                        monto_otorgado, 	provi_venc_normal,
                        provi_venc_anticip, cap_tras_no_venci,
                        mto_venc_int, 		mto_venc_tra_int,
                        mto_finan_vdo, 		mto_reser_int,
                        mto_fin_ven_trasp, 	mto_fin_vig_trasp,
                        int_tra_no_exig, 	sdo_trab4,
						atr

                    )
            SELECT 		 sol.empresa             ,pSolicitud
                        ,dFechaApert            ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,mTotalPagar
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,pMonto					,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
						,iAtr_Act_ifrs
            FROM   bdisolic:"informix".ss_solicitudes sol
            WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;

        ELSE
            INSERT INTO "informix".sd_maesdoscrd
                    (
                        empresa, 			num_credito,
                        fecha_ult_mov, 		sdo_int_anticip,
                        sdo_int_ant_dev, 	sdo_intereses,
                        sdo_dia_ant_int, 	sdo_mes_ant_int,
                        sdo_acum_mes_int, 	sdo_retenido,
                        sdo_acum_cap_int, 	sdo_exig_int,
                        sdo_no_exig, 		provision_normal,
                        dias_acum_int, 		sdo_moratorio,
                        sdo_dia_ant_mor, 	sdo_mes_ant_mor,
                        sdo_contab_mora, 	dias_acum_mora,
                        sdo_capital, 		sdo_cap_insoluto,
                        sdo_dia_ant_cap, 	sdo_mes_ant_cap,
                        sdo_acum_mes_cap, 	mto_capitalizado,
                        mto_ministra_cap, 	cargos_dia_cap,
                        abonos_dia_cap, 	cargos_mes_cap,
                        abonos_mes_cap, 	dias_acum_cap,
                        monto_vencido, 		mto_venc_trasp,
                        monto_financiado, 	monto_reservado,
                        sdo_acum_vencido, 	dias_acum_intper,
                        sdo_global_int, 	sdo_acum_intper,
                        monto_otorgado, 	provi_venc_normal,
                        provi_venc_anticip, cap_tras_no_venci,
                        mto_venc_int, 		mto_venc_tra_int,
                        mto_finan_vdo, 		mto_reser_int,
                        mto_fin_ven_trasp, 	mto_fin_vig_trasp,
                        int_tra_no_exig, 	sdo_trab4,
						atr
                    )
            SELECT 		 sol.empresa             ,pSolicitud
                        ,dFechaApert            ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,pMonto                 ,pMonto
                        ,0                      ,0
                        ,0                      ,mTotalPagar
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,pMonto					,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
						,iAtr_Act_ifrs
            FROM   bdisolic:"informix".ss_solicitudes sol
            WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;
        END IF;
	END;

	LET iNumReg = dbinfo("sqlca.sqlerrd2");

	IF iNumReg = 0 THEN
		LET cCodRet = "00003";
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;

	SELECT TRIM(valor)  INTO  vCancelVig
	FROM bdicred:"informix".sd_param 						
	WHERE empresa  = pEmpresa AND cod_param = '067'; --Parametro de Cancelacion de Vigencia de linea
			
	EXECUTE PROCEDURE bdicred:monthadd(dFechaApert, vCancelVig) INTO vFechaVig;
	
    -- CARGA LINEA DE CREDITO INI 
    IF cProducto IN ('6800','7100') THEN
		IF cProducto = '6800' THEN
			INSERT INTO "informix".sd_linea_prestamo
                    (empresa,
                     num_credito,
                     monto_linea,
                     fecha_otorga,
                     linea_disponible,
                     sec_credito,
                     fecha_cancela,
					 fecha_venc_linea,
					 acepto_incremento) --Se agrega campo "acepto_incremento" - RQM 10 1543
            VALUES (pEmpresa,
                      pSolicitud,
                      pMonto,
                      dFechaApert,
                      pMonto, 
                      0,
                      NULL,
					  vFechaVig,
					  pAceptoIncremento);
			LET iNumReg = dbinfo("sqlca.sqlerrd2");
		ELSE
			INSERT INTO "informix".sd_linea_prestamo
                    (empresa,
                     num_credito,
                     monto_linea,
                     fecha_otorga,
                     linea_disponible,
                     sec_credito,
                     fecha_cancela)
            VALUES (pEmpresa,
                      pSolicitud,
                      pMonto,
                      dFechaApert,
                      pMonto, 
                      0,
                      NULL);
			LET iNumReg = dbinfo("sqlca.sqlerrd2");
		END IF;

        IF iNumReg = 0 THEN
            LET cCodRet = "00003";
            DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
            DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
            DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            --DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
            DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
            DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
            RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
        END IF;
    END IF;
    -- CARGA LINEA DE CREDITO FIN

	-- SE GENERA EL FOLIO
	CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet, cNumeroFolio;

	-- SE ASIGNA EL FOLIO DE LA TRANSACCION
	IF cProducto = "6400" THEN ---para producto credinomina se utilizara esta transaccion.
		LET cTransacc = "0314";
	ELSE
		LET cTransacc = "0247";
	END IF;

    EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
								cProducto        , 3,
                                "001"            , dFechaApert,
                                pMonto           , cNumeroFolio,
                                cSucursal        , cDivisa,
                                "0000",'APERTURA','')
	INTO cCodRet, cErrorInfo;

	IF cCodRet <> "00000" THEN
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF

    IF cProducto NOT IN ('6800','7100') THEN
        EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
                                    cProducto        , 66,
                                    "002"            , dFechaApert,
                                    pMonto           , cNumeroFolio,
                                    cSucursal        , cDivisa,
                                    "0000",'DISPOSICION','')
        INTO cCodRet, cErrorInfo;
    END IF;

	IF cCodRet <> "00000" THEN
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF


	-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
	INSERT INTO "informix".sd_amortiza_creditocrd
		(
			empresa, 			num_credito,
			fecha_cuota, 		tipo_cuota,
			capital_mto_cuota, 	capital_debe,
			capital_pagado, 	capital_status,
			capital_status_ant, capital_fecha_pago,
			interes_debe, 		interes_pagado,
			interes_status, 	interes_status_ant,
			interes_fecha_pago, iva_debe,
			iva_pagado, 		iva_status,
			iva_status_ant, 	iva_fecha_pago,
			mora_provi_ordi, 	mora_provi_cope,
			mora_sdo_ordi, 		mora_sdo_ordi_pag,
			mora_sdo_cope, 		mora_sdo_cope_pag,
			mora_bonificado, 	mora_status,
			mora_iva_debe, 		mora_iva_pagado,
			mora_iva_status, 	mora_iva_fecha_pago,
			num_pago, 			campo_trabajo1,
			campo_trabajo2, 	campo_trabajo3,
			campo_trabajo4
		)
	VALUES
		(
			pEmpresa,			pSolicitud,
			dFechaT,			"3",
			pMensualidad,		0,
			0,					"3",
			"3",				"",
			0,					0,
			"1",				"1",
			"",					0,
			0,					"1",
			"1",				"",
			0,					0,
			0,					0,
			0,					0,
			0,					"1",
			0,					0,
			"1",				"",
			1,					0,
			0,					"",
			""
		);

	--SE INSERTA EN LA TABLA bdicred:sd_ctascarg
	--INSERT INTO "informix".sd_ctascarg (empresa, numero, con_cap_inte, naturaleza, num_credito, tipo_cta, num_cta, num_nomina) VALUES(pEmpresa,0,'','A',pSolicitud,'',pCuentaCap,'');

    -- SE ACTUALIZA EL ESTATUS DE LA SOLICITUD
    UPDATE bdisolic:"informix".ss_solicitudes 
	SET status_solicitud = "AP" 
	WHERE empresa = pEmpresa 
	AND num_solicitud = pSolicitud;

    --FMV 23abr13: Inserta cascaron para indicadores de prestamo a plazo
    INSERT INTO bdicred:sd_indicador_cred_crd (empresa, num_credito, fecha_alta,monto_mensual)
	VALUES (pEmpresa, pSolicitud, dFechaApert,pMensualidad);

    SELECT nombre 
	INTO cMensaje 
	FROM bdinteg:"informix".si_ejecut 
	WHERE ejecutivo = pEjecutivo 
	AND empresa = pEmpresa;

    LET cMensaje = "Apertura de Credito Autorizada por: " || TRIM(cMensaje);

	-- SE INSERTA EN LA TABLA DE AUTORIZACIONES DE SOLICITUD
    INSERT INTO bdisolic:"informix".ss_autorizacion (empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
	VALUES(pEmpresa, pEjecutivo, pSolicitud, "AP", cMensaje, dFechaApert, dFechaApert, USER, TODAY);

	-- SE GENERA EL ABONO 
	IF cProducto NOT IN ('6800','7100') THEN
        CALL bdicheq:"informix".abono_ref (pEmpresa, cSucursal, pEjecutivo, cTransacc, cTransacc, cNumeroFolio, pCuentaCap, 0,
		pMonto, pMonto, 0, 0, 0, "01", pSolicitud||" "||pNombrePres, '0', pEjecutivo) RETURNING cCodRet3;
    END IF;

	-- SI NO SE PUDO GENERAR EL ABONO SE REVERSAN TODOS LOS MOVIMIENTOS QUE SE HABIAN ECHO
	IF cCodRet3 <> "000" THEN
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		--DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet3,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    ELSE 
        LET idAbono = "S";         
	END IF;
	
	IF cProducto = "6400" THEN --JMAH
		IF ( dPorcComisionAper > 0 ) then
			LET mComisionApertura= ROUND(pMonto * (dPorcComisionAper/100),2);
			
			--SE REALIZA CARGO POR COMISION DE APERTURA
            CALL bdicheq:"informix".cargo_ref(pEmpresa, cSucursal, pEjecutivo, cTransaccCargo, "0000", cNumeroFolio,pCuentaCap, 0, mComisionApertura, 
            cDivisa,"", "0", pEjecutivo)
            RETURNING cCodRet, cTransacc, dtFecha_cargo, mDispo, mCargo;
			
            IF cCodRet::INTEGER <> 0  THEN
				DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
				DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                --DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
				DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
				DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
                
				CALL bdicheq:"informix".reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;
                IF cCodRet <> "000" THEN
					LET cCodRet    = "00004";
				ELSE
					LET cCodRet    = "00005";	--Ocurrio un Error al realizar el cargo  de la comision por apertura
				END IF;

                RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;

            LET mIvaComisionApertura = ROUND(mComisionApertura * dIvaSuc,2); --iva de la comision            
            CALL bdicheq:"informix".cargo_ref(pEmpresa, cSucursal, pEjecutivo,cTransaccIvaCargo, "0000", cNumeroFolio,
            pCuentaCap, 0, mIvaComisionApertura, cDivisa,"", "0", pEjecutivo)
            RETURNING cCodRet, cTransacc, dtFecha_cargo, mDispo, mCargo;

            IF cCodRet::INTEGER <> 0  THEN
				DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
                DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
                DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                --DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
                DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
                
				CALL bdicheq:"informix".reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;
                
				IF cCodRet <> "000" THEN
					LET cCodRet    = "00004";
				ELSE
					LET cCodRet    = "00006";	--Ocurrio un Error al realizar el cargo por iva de la comision por apertura
				END IF;

                RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;
		END IF;
	END IF;
	
    -- SE ACTUALIZAN LOS DATOS DEL CLIENTE
    SELECT a.numcte, tipo_cliente, NVL(ingreso_mensual,0)
    INTO cNumCte, cTpCte, mIngreso
    FROM bdinteg:"informix".si_cliente a
	INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.numcte = a.numcte
	INNER JOIN bdisolic:"informix".ss_resum_scor_fin c ON c.empresa = b.empresa AND c.num_solicitud = b.num_solicitud
	WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud;

    -- Saca la Publicacion de si_ctepf Jose Luis Puebla
    SELECT string1 INTO cMercadeo
    FROM   bdinteg:"informix".si_ctepf
    WHERE  numcte = cNumCte;

    IF cTpCte = "1" THEN
		SELECT MAX(sec_ingreso) INTO sSecIngreso FROM bdinteg:"informix".si_ingresos WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = 'T';

		UPDATE bdinteg:"informix".si_ingresos SET ingreso_mensual = mIngreso
		WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = "T" AND sec_ingreso = sSecIngreso;
    ELSE
		UPDATE bdinteg:"informix".si_cliente SET tipo_cliente = "1" WHERE numcte = cNumCte;

		SELECT NVL(MAX(sec_ingreso), 0) + 1 INTO sSecIngreso
		FROM bdinteg:"informix".si_ingresos
		WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = "T";

		INSERT INTO bdinteg:"informix".si_ingresos (empresa, numcte, sec_ingreso, tipo_ingreso, ingreso_mensual)
		VALUES (pEmpresa, cNumCte, sSecIngreso, "T", mIngreso);
    END IF

    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008
    LET mTasaMora = mTasaMora - mTasaInteres;
    IF mTasaMora < 0 THEN --Si es Menor a Cero la vuelve Positivo
		LET mTasaMora = mTasaMora * -1;
    END IF

    -- Actualiza informacion para la bitacora de la solicitud (auditoria-cnbv)      
    UPDATE bdisolic:"informix".ss_revision_determinacion SET plazo = pPlazo, pago_mens = pMensualidad WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	
    IF cProducto IN ('6800','7100') THEN
        SELECT NVL(telefono,'')
		INTO pNumCel
		FROM bdinteg:si_telefonos_actual 
        WHERE numcte = cNumCte
        AND tipo_tel = '2' 
        AND status_tel = 'A';

        IF (pNumCel <> '') THEN
			CALL bdimnsj:"informix".sp_registra_evento(2,'SMS_RECI','PPF_SMSAP1','000000000','','',1, '','','','','','','','','','','',pNumCel,0,0,0,0,0,'','') RETURNING sCodRetEvento;
			CALL bdimnsj:"informix".sp_registra_evento(2,'SMS_RECI','PPF_SMSAP2','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,'','') RETURNING sCodRetEvento;
        END IF;
    END IF;
	
    RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
END;
END PROCEDURE
DOCUMENT
'AUTOR: DR Roro',
'Descripcion: Apertura de prestamo personal con domiciliacion',
'Fecha: 2020/10/07',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Jorge M REYES',
'Descripcion: Se agrega flujo oneclick para cambiar la tasa de interes desde trx',
'Fecha: 2022/11/04',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Rodolfo Tortolero',
'Descripcion: Se agrega flujo oneclick para que tome la sucursal origen del cliente cuando la solicitud viene desde la aplicacion.',
'Fecha: 2023/06/007',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Alan Castro Paredes',
'Descripcion: Se agrega campo acepto_incremento para el flujo del otorgamiento del prestamo digital- RQM 10 1543.',
'Fecha: 2023/08/11',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Angel Anguiano',
'Descripcion: Se agrega cambio de sucursal 8503 por 6700 oneclick.',
'Fecha: 2024/02/28',
'Version: 1.00',
'BD: BDICRED',
'--------------------------------------------------------------',
'AUTOR: Cinthia Aguilar',
'Descripcion: Se agrega validacion para que la sucursal sea operativa',
'Fecha: 2025/09/09',
'BD: BDICRED',
 '--------------------------------------------------------------',
'AUTOR: Cinthia Aguilar',
'Descripcion: Se agrega validacion para asignar sucursal 6700 por default',
'Fecha: 2025/05/21',
'BD: BDICRED',
'--------------------------------------------------------------';


CREATE PROCEDURE "informix".levanta_sdos()

DEFINE v_cred CHAR(20);
DEFINE v_cap MONEY(14,2);
DEFINE v_int MONEY(14,2);

	FOREACH SELECT num_credito, capital, interes
	          INTO v_cred, v_cap, v_int
	          FROM auxcreacred

		UPDATE sd_maesdos SET sdo_capital = v_cap,
				       sdo_cap_insoluto = v_cap,
				       sdo_no_exig = v_int   
		 WHERE num_credito = v_cred;

	END FOREACH

END PROCEDURE;