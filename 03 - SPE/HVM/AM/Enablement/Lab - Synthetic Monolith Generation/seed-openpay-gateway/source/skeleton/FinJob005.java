package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : JOB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 6    LOC approx: 174
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.FinRequest;
import com.openpay.dto.FinResponse;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;

@Scheduled
public class FinJob005 {

    // Collaborators (match the graph call edges):
    private final FinService052 finService052;
    private final FinService068 finService068;
    private final FinService077 finService077;
    private final FinService275 finService275;
    private final FinService277 finService277;
    private final UserService userService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
