package com.openpay.manager.merchants;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : merchants
//  LAYER     : JOB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 3    LOC approx: 286
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.MerRequest;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;

@Scheduled
public class MerJob006 {

    // Collaborators (match the graph call edges):
    private final MerService062 merService062;
    private final MerService198 merService198;
    private final NotificationService notificationService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
