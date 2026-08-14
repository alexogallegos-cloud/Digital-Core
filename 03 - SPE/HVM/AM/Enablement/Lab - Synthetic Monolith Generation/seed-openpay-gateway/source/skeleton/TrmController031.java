package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : WEB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 4    LOC approx: 269
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.dto.TrmEntity;
import com.openpay.dto.TrmRequest;

@RestController
public class TrmController031 {

    // Collaborators (match the graph call edges):
    private final ConfigService configService;
    private final RbacService rbacService;
    private final TrmService148 trmService148;
    private final TrmService242 trmService242;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
