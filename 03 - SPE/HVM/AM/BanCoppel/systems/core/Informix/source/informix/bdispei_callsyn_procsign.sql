CREATE PROCEDURE "informix".callsyn_procsign()
   DEFINE l_type char(15);
   DEFINE l_idmsg char(15);
   LET l_type = '1';
   LET l_idmsg = '1';
   -- code to execute if user tries to execute a specified

   SYSTEM 'syn_procsign bdispei ' || l_type || ' ' || l_idmsg || ' 1';

END PROCEDURE;