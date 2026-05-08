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

import ballerina/test;
import ballerinax/microsoft.dynamics365.scm.common;
import ballerinax/microsoft.dynamics365.scm.production;
import ballerinax/microsoft.dynamics365.scm.warehouse;

@test:Config
function testSharedConnectionAcrossModules() returns error? {
    common:Connection conn = check new (
        config = {auth: {token: "demo-bearer-token"}},
        serviceUrl = "http://localhost:9091/data"
    );
    warehouse:Client _ = check new (conn);
    production:Client _ = check new (conn);
}
