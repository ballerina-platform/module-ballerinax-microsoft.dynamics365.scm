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

// Create a sales order in D365 from an upstream "order created" signal.
// SalesOrderHeadersV2 lives in the `sales` submodule.

import ballerina/http;
import ballerina/io;
import ballerinax/microsoft.dynamics365.scm.common;
import ballerinax/microsoft.dynamics365.scm.sales;
import ballerinax/microsoft.dynamics365.scm.mock.server;

public function main() returns error? {
    http:Listener mockListener = check server:startMock();

    common:Connection conn = check new (
        config = {auth: {token: "demo-bearer-token"}},
        serviceUrl = "http://localhost:9091/data"
    );
    sales:Client so = check new (conn);

    io:println("Existing sales orders:");
    sales:SalesOrderHeadersV2Collection page = check so->listSalesOrderHeadersV2();
    foreach sales:SalesOrderHeaderV2 s in page.value ?: [] {
        io:println(string `  ${s.SalesOrderNumber ?: ""}   [${s.dataAreaId ?: ""}]`);
    }

    sales:SalesOrderHeaderV2 draft = {
        dataAreaId: "USMF",
        SalesOrderNumber: "SO-DEMO-001"
    };
    sales:SalesOrderHeaderV2 created = check so->createSalesOrderHeadersV2(payload = draft);
    io:println("");
    io:println(string `Created ${created.SalesOrderNumber ?: ""}`);
    io:println(string `  etag:  ${created["@odata.etag"].toString()}`);

    check mockListener.gracefulStop();
}
