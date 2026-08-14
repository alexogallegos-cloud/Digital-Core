package com.openpay.api.riskfraud;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : risk-fraud
//  LAYER     : WEB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 2    LOC approx: 212
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.RskEntity;

@RestController
public class RskController017 {

    // Collaborators (match the graph call edges):
    private final RskService232 rskService232;
    private final RskService299 rskService299;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
