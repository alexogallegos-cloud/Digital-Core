CREATE PROCEDURE "informix".sp_show_hogs() RETURNING CHAR(80);
DEFINE v_user CHAR(8);
DEFINE v_host LIKE sysmaster:syssessions.hostname;
DEFINE v_tid INTEGER;
DEFINE v_sid INTEGER;
DEFINE v_pid INTEGER;
DEFINE v_cnt INTEGER;
LET v_cnt = 0;

   SELECT us_tid, us_sid FROM sysmaster:sysuserthreads AS u, sysmaster:systhreads AS t
   WHERE u.us_tid = t.th_id
   AND t.th_state = 0
   AND us_sid >= 100
   INTO TEMP sphogstmp WITH NO LOG;
   LET v_cnt = v_cnt + 1;
   WHILE (v_cnt < 5)
      SYSTEM("sleep 1");
      INSERT INTO sphogstmp
      SELECT us_tid, us_sid
      FROM sysmaster:sysuserthreads AS u, sysmaster:systhreads AS t
      WHERE u.us_tid = t.th_id
      AND t.th_state = 0
      AND us_sid >= 100;
      LET v_cnt = v_cnt + 1;
   END WHILE;

FOREACH SELECT us_tid, COUNT(*) INTO v_tid, v_cnt FROM sphogstmp
   GROUP BY us_tid
   HAVING COUNT(*) > 1
   ORDER BY 2 DESC
         FOREACH SELECT DISTINCT us_sid, username, pid, hostname INTO v_sid, v_user, v_pid, v_host
            FROM sphogstmp AS h, sysmaster:syssessions AS s
            WHERE h.us_sid != DBINFO('sessionid')
            AND h.us_tid = v_tid
            AND h.us_sid = s.sid
            ORDER BY 1
            RETURN "SID " || v_sid || " (" || v_cnt || "/5,User='" || TRIM(v_user) || "',Host='" || TRIM(v_host) || "',PID=" || v_pid || ")"
            WITH RESUME;
         END FOREACH;
END FOREACH;
   DROP TABLE sphogstmp;
END PROCEDURE;