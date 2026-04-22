// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

// Create a bill of materials - lists the BOM lines of an existing template,
// creates a new BOM header, and prints what the service echoed back.

import ballerina/http;
import ballerina/io;
import ballerinax/microsoft.dynamics365.scm;
import ballerinax/microsoft.dynamics365.scm.mock.server;

public function main() returns error? {
    http:Listener mockListener = check server:startMock();

    scm:Client fo = check new (
        config = {auth: {token: "demo-bearer-token"}},
        serviceUrl = "http://localhost:9091/data"
    );

    scm:BillOfMaterials template = check fo->getBillOfMaterials(
        dataAreaId = "USMF",
        billOfMaterialsId = "BOM-HUB-001"
    );
    io:println(string `Template BOM: ${template.BillOfMaterialsName ?: ""} (${template.BillOfMaterialsId ?: ""})`);

    scm:BillOfMaterialLinesCollection lines = check fo->listBillOfMaterialLines(
        queries = {filter: "BillOfMaterialsId eq '" + (template.BillOfMaterialsId ?: "") + "'"}
    );
    io:println(string `  lines: ${(<scm:BillOfMaterialLine[]>lines.value).length()}`);
    foreach scm:BillOfMaterialLine l in <scm:BillOfMaterialLine[]>lines.value {
        decimal qty = l.Quantity ?: 0d;
        io:println(string `    line ${l.LineNumber ?: 0d}  ${l.ItemNumber ?: ""}  qty=${qty} ${l.UnitSymbol ?: ""}`);
    }

    scm:BillOfMaterials draft = {
        dataAreaId: "USMF",
        BillOfMaterialsId: "BOM-DEMO-001",
        BillOfMaterialsName: "Surface Pro Hub - Demo revision",
        SiteId: template.SiteId,
        ItemGroupId: template.ItemGroupId,
        IsApproved: "No",
        ActivationDate: "2026-06-01",
        ExpirationDate: "2027-05-31"
    };

    scm:BillOfMaterials created = check fo->createBillOfMaterials(payload = draft);
    io:println("");
    io:println(string `Created ${created.BillOfMaterialsId ?: ""}`);
    io:println(string `  name:  ${created.BillOfMaterialsName ?: ""}`);
    io:println(string `  etag:  ${created["@odata.etag"].toString()}`);

    check mockListener.gracefulStop();
}
