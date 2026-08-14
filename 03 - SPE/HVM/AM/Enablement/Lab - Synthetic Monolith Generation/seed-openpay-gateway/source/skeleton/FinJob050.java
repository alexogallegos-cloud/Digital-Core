package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : JOB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 7    LOC approx: 265
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Scheduled
public class FinJob050 {

    // Collaborators (match the graph call edges):
    private final FinService002 finService002;
    private final FinService005 finService005;
    private final FinService052 finService052;
    private final FinService068 finService068;
    private final FinService275 finService275;
    private final NotificationService notificationService;
    private final RbacService rbacService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
