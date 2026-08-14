CREATE PROCEDURE "informix".sp_gen_msj(pEmpresa CHAR(3), pRegistros INTEGER)
RETURNING   CHAR(5);

DEFINE vsqlerr        INTEGER;
DEFINE vcodret        CHAR(5);

DEFINE v_pTipoMsj char(1);
DEFINE v_pIdMsj char(10);
DEFINE v_pIdPlantilla char(12);
DEFINE v_pNumclt char(20);
DEFINE v_pNumcta char(20);
DEFINE v_pNumTarjeta char(16);
DEFINE v_pTipoproc char(1);
DEFINE v_pStr1 char(30); 
DEFINE v_pStr2 char(30); 
DEFINE v_pStr3 char(30);
DEFINE v_pStr4 char (30); 
DEFINE v_pStr5 char(150);
DEFINE v_pStr6 char(100); 
DEFINE v_pStr7 char(60); 
DEFINE v_pStr8 char(60);
DEFINE v_pStr9 char(15); 
DEFINE v_pStr10 char(100);
DEFINE v_pcorreo_alterno char(100); 
DEFINE v_pcelular_alterno char(10);
DEFINE v_pImporte1 money (16,2); 
DEFINE v_pImporte2 money (16,2);
DEFINE v_pImporte3 money (16,2); 
DEFINE v_pImporte4 money (16,2); 
DEFINE v_pImporte5 money (16,2); 
DEFINE v_pfecha1 datetime year to fraction(3); 
DEFINE v_pfecha2 datetime year to fraction(3);
DEFINE v_pstatus char(1);
DEFINE v_contador SMALLINT;

LET vsqlerr = 0; 
LET vcodret = "00000";


BEGIN
	ON EXCEPTION SET vsqlerr
	   SET DEBUG FILE TO "/resplogifx/conciliachq/crea_msj.err";
		   TRACE ON;
           IF vsqlerr <> 0 THEN
              LET vcodret = vsqlerr;
           RETURN vcodret;
           END IF;
    END EXCEPTION;
	
     --SET DEBUG FILE TO '/resplogifx/conciliachq/crea_msj.out';
	 --TRACE ON;
	
	 SET ISOLATION TO DIRTY READ;
	 --INICIA EL CONTADOR
	-- LET v_contador = 0;
	 
	 --COMIENZA A PROCESAR LA INFORMACION QUE ESTA EN ESTATUS 'A'
	 FOREACH WITH HOLD
	         SELECT  {+INDEX(tbl_registro_msj idxtbl_registro_msj)}
                     first pRegistros 
                     ltrim(trim(ptipomsj)),ltrim(trim(pidmsj)), ltrim(trim(pidplantilla)), ltrim(trim(pnumclt)), ltrim(trim(pnumcta)), ltrim(trim(pnumtarjeta)), 
			         ltrim(trim(ptipoproc)),ltrim(trim(pstr1)), ltrim(trim(pstr2)),ltrim(trim(pstr3)),ltrim(trim(pstr4)),ltrim(trim(pstr5)), 
					 ltrim(trim(pstr6)), ltrim(trim(pstr7)),ltrim(trim(pstr8)),ltrim(trim(pstr9)),ltrim(trim(pstr10)),ltrim(trim(pcorreo_alterno)), 
					 ltrim(trim(pcelular_alterno)),  pimporte1,    pimporte2, pimporte3, pimporte4, 
					 pimporte5, pfecha1, pfecha2, pstatus 
			   INTO  v_pTipoMsj, v_pIdMsj, v_pIdPlantilla, v_pNumclt, v_pNumcta, v_pNumTarjeta, 
					 v_pTipoproc, v_pStr1, v_pStr2, v_pStr3, v_pStr4, v_pStr5, 
					 v_pStr6, v_pStr7, v_pStr8, v_pStr9, v_pStr10, v_pcorreo_alterno, 
					 v_pcelular_alterno, v_pImporte1,v_pImporte2,v_pImporte3, v_pImporte4, 
					 v_pImporte5, v_pfecha1, v_pfecha2, v_pstatus 	
               FROM  bdispei:tbl_registro_msj 
			  WHERE  pNumclt >= '000001002'
                AND  ptipomsj in('1','2')
                AND  pfecha1 = pfecha1
                AND  pstatus = 'A'
			  
                   
					 --DEPENDIENDO EL TIPO DE MENSAJE REALIZA LA EJECUCION 
			         IF v_pTipoMsj = '1' THEN 
			                   EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
			                  (v_pTipoMsj, v_pIdMsj, v_pIdPlantilla, v_pNumclt, v_pNumcta, v_pNumTarjeta, 
					           v_pTipoproc, v_pStr1, v_pStr2, v_pStr3, v_pStr4, v_pStr5, v_pStr6, 
                               v_pStr7, v_pStr8, v_pStr9, v_pStr10, v_pcorreo_alterno, v_pcelular_alterno, 
					           v_pImporte1,v_pImporte2,v_pImporte3, v_pImporte4, v_pImporte5, v_pfecha1, v_pfecha2) INTO vcodret;
			  
			         ELSE 
					        IF v_pTipoMsj = '2' THEN 
			                   EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento
			                  (v_pTipoMsj, v_pIdMsj, v_pIdPlantilla, v_pNumclt, v_pNumcta, v_pNumTarjeta, 
					           v_pTipoproc, v_pStr1, v_pStr2, v_pStr3, v_pStr4, v_pStr5, v_pStr6, 
                               v_pStr7, v_pStr8, v_pStr9, v_pStr10, v_pcorreo_alterno, v_pcelular_alterno, 
					           v_pImporte1,v_pImporte2,v_pImporte3, v_pImporte4, v_pImporte5, v_pfecha1, v_pfecha2) INTO vcodret;
							 END IF; 
				     END IF; 
					 
						
					--SI LA EJECUCION FUE CORRECTA, REALIZA LA ACTUALIZACION DEL STATUS AL REGISTRO QUE PROCESO 
					 
					IF vcodret = '00000' THEN 
					--   RETURN  vcodret;
					--CONTINUE FOREACH;  
					--ELSE  					
					     BEGIN;
					     				
                              UPDATE {+INDEX(tbl_registro_msj idxtbl_registro_msj)}
                                     bdispei:tbl_registro_msj 
					             SET pstatus = 'E' 
					           WHERE pNumclt = v_pNumclt 
					             AND pTipoMsj= v_pTipoMsj
					             AND pfecha1 = v_pfecha1
					             AND pstatus = 'A';
					     COMMIT;		
					END IF;

					
					  --LIMPIA VARIABLES
					   LET v_pTipoMsj         = '';
                       LET v_pIdMsj           = '';
                       LET v_pIdPlantilla     = '';
                       LET v_pNumclt          = '';
                       LET v_pNumcta          = '';
                       LET v_pNumTarjeta      = '';
                       LET v_pTipoproc        = '';
                       LET v_pStr1            = '';
                       LET v_pStr2            = '';
                       LET v_pStr3            = '';
                       LET v_pStr4            = '';
                       LET v_pStr5            = '';
                       LET v_pStr6            = '';
                       LET v_pStr7            = '';
                       LET v_pStr8            = '';
                       LET v_pStr9            = '';
                       LET v_pStr10           = '';
                       LET v_pcorreo_alterno  = '';
                       LET v_pcelular_alterno = '';
                       LET v_pImporte1        = 0 ;
                       LET v_pImporte2        = 0 ;
                       LET v_pImporte3        = 0 ;
                       LET v_pImporte4        = 0 ;
                       LET v_pImporte5        = 0 ;
                       LET v_pstatus          = '';
					   
					 --  LET v_contador = v_contador + 1;
					   
					 --  IF v_contador = 1000 THEN
					 --     LET vcodret = '00000';
                     --    RETURN  vcodret;	
                     --  END IF; 	

	 END FOREACH;

LET vcodret = "00000";	 

RETURN  vcodret;
END; 
END PROCEDURE;