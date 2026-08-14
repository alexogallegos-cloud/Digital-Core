package com.openpay.manager.compliance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : compliance
//  LAYER     : WEB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 3    LOC approx: 81
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AccountingEntry;
import com.openpay.dto.CmpRequest;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;

@RestController
public class CmpController046 {

    // Collaborators (match the graph call edges):
    private final CmpService098 cmpService098;
    private final CmpService197 cmpService197;
    private final UserService userService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
