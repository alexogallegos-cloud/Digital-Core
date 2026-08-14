package com.openpay.api.riskfraud;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : risk-fraud
//  LAYER     : WEB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 3    LOC approx: 155
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.RskRequest;
import com.openpay.dto.RskResponse;

@RestController
public class RskController086 {

    // Collaborators (match the graph call edges):
    private final CmpService178 cmpService178;
    private final RskService232 rskService232;
    private final RskService252 rskService252;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
