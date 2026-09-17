create procedure "informix".parametros()
returning  int,int,int,lvarchar,char(1),int,int,lvarchar,int,int,int,int,varchar(7),varchar(7),varchar(7),varchar(7),char(2), char(2), char(2), char(2), varchar(7),varchar(7),varchar(7),varchar(7),decimal(9,2),decimal(9,2),decimal(9,2),decimal(9,2);

define revolvente char(04);
define pago_fijo char(04);
define empresarial char(4);
define monto_saldo int;
define num_ctas_mayor int;
define num_ctas_min int;
define cred_no_conc lvarchar;
define valor_mop_no_con char(1);
define mop_malo int;
define num_meses_max_eva int;
define rango_pago2 lvarchar;
define num_meses_min int;
define cali_buena int;
define cali_reg int;
define cali_mala int;
define rango_cal_cli_bue varchar(7);
define rango_cal_cli_rega varchar(7);
define rango_cal_cli_regm varchar(7);
define rango_cal_cli_mal varchar(7);
define val_bueno char(2); 
define val_regulara char(2); 
define val_regularm char(2); 
define val_malo char(2); 
define rango_factor1 varchar(7);
define rango_factor2 varchar(7);
define rango_factor3 varchar(7);
define rango_factor4 varchar(7);
define factor1 decimal(9,2);
define factor2 decimal(9,2);
define factor3 decimal(9,2);
define factor4 decimal(9,2);

select valor into revolvente from bdicred:sd_param where cod_param = 95;

select valor into pago_fijo from bdicred:sd_param where cod_param = 94;

select valor into empresarial from bdicred:sd_param where cod_param = 93;

select valor into  monto_saldo           from br_param where cod_param = 10 ;

select valor into  num_ctas_mayor        from br_param where cod_param = 20 ;

select valor into  num_ctas_min          from br_param where cod_param = 21 ;

select valor into  cred_no_conc          from br_param where cod_param = 30 ;

select valor into  valor_mop_no_con      from br_param where cod_param = 40 ;

select valor into  mop_malo     from br_param where cod_param = 41 ;

select valor into  num_meses_max_eva     from br_param where cod_param = 50 ;

select valor into  rango_pago2           from br_param where cod_param = 51 ;

select valor into  num_meses_min         from br_param where cod_param = 52 ;

select valor into  cali_buena            from br_param where cod_param = 60 ;

select valor into  cali_reg              from br_param where cod_param = 61 ;

select valor into  cali_mala             from br_param where cod_param = 62 ;

select valor into  rango_cal_cli_bue     from br_param where cod_param = 70 ;

select valor into  rango_cal_cli_rega    from br_param where cod_param = 71 ;

select valor into  rango_cal_cli_regm    from br_param where cod_param = 72 ;


select valor into  rango_cal_cli_mal     from br_param where cod_param = 73 ;

select valor into  val_bueno             from br_param where cod_param = 80 ;

select valor into  val_regulara          from br_param where cod_param = 81 ;

select valor into  val_regularm          from br_param where cod_param = 82 ;

select valor into  val_malo              from br_param where cod_param = 83 ;

select valor into  rango_factor1         from br_param where cod_param = 90 ;

select valor into  rango_factor2         from br_param where cod_param = 91 ;

select valor into  rango_factor3         from br_param where cod_param = 92 ;

select valor into  rango_factor4         from br_param where cod_param = 93 ;

select valor into  factor1               from br_param where cod_param = 100 ;

select valor into  factor2               from br_param where cod_param = 101 ;

select valor into  factor3               from br_param where cod_param = 102 ;

select valor into  factor4               from br_param where cod_param = 103 ;

return monto_saldo         ,num_ctas_mayor ,num_ctas_min           ,cred_no_conc  ,valor_mop_no_con  ,mop_malo,num_meses_max_eva    ,rango_pago2      ,num_meses_min   ,cali_buena         ,cali_reg             ,cali_mala          ,rango_cal_cli_bue,rango_cal_cli_rega,rango_cal_cli_regm,rango_cal_cli_mal,val_bueno    ,val_regulara    ,val_regularm,val_malo      ,rango_factor1,rango_factor2,rango_factor3,rango_factor4,factor1          ,factor2          ,factor3          ,factor4    ;

end procedure
;