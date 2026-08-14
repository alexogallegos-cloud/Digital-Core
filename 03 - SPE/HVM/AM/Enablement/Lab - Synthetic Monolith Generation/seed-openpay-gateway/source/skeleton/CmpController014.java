package com.openpay.manager.compliance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : compliance
//  LAYER     : WEB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 2    LOC approx: 271
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.CmpEntity;
import com.openpay.dto.CmpResponse;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;

@RestController
public class CmpController014 {

    // Collaborators (match the graph call edges):
    private final InfService167 infService167;
    private final RbacService rbacService;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
