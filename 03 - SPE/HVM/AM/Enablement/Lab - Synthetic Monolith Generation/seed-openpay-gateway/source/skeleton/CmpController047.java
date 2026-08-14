package com.openpay.manager.compliance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : compliance
//  LAYER     : WEB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 4    LOC approx: 239
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AccountingEntry;
import com.openpay.dto.CmpEntity;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;

@RestController
public class CmpController047 {

    // Collaborators (match the graph call edges):
    private final CmpService071 cmpService071;
    private final CmpService282 cmpService282;
    private final RbacService rbacService;
    private final UserService userService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
