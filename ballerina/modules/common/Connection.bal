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

// Shared HTTP transport for all per-domain submodules in this connector.
// One `Connection` constructs one underlying `http:Client`; every domain
// `Client` instance receives that same connection by injection — so a caller
// that talks to N domain modules ends up with one connection pool, not N.

import ballerina/http;

# OAuth 2.0 client-credentials configuration with the D365 token endpoint as default.
public type OAuth2ClientCredentialsGrantConfig record {|
    *http:OAuth2ClientCredentialsGrantConfig;
    # Token URL
    string tokenUrl = "https://login.microsoftonline.com/common/oauth2/v2.0/token";
|};

# Shared connection settings used to build the underlying `http:Client`.
public type ConnectionConfig record {|
    # Configurations related to client authentication
    OAuth2ClientCredentialsGrantConfig|http:BearerTokenConfig auth;
    # The HTTP version understood by the client
    http:HttpVersion httpVersion = http:HTTP_2_0;
    http:ClientHttp1Settings http1Settings = {};
    http:ClientHttp2Settings http2Settings = {};
    decimal timeout = 30;
    string forwarded = "disable";
    http:FollowRedirects followRedirects?;
    http:PoolConfiguration poolConfig?;
    http:CacheConfig cache = {};
    http:Compression compression = http:COMPRESSION_AUTO;
    http:CircuitBreakerConfig circuitBreaker?;
    http:RetryConfig retryConfig?;
    http:CookieConfig cookieConfig?;
    http:ResponseLimitConfigs responseLimits = {};
    http:ClientSecureSocket secureSocket?;
    http:ProxyConfig proxy?;
    http:ClientSocketConfig socketConfig = {};
    boolean validation = true;
    boolean laxDataBinding = true;
|};

# Holds the shared `http:Client`. Pass this to each domain submodule's
# `Client(conn)` constructor so they all reuse the same transport.
public isolated class Connection {
    private final http:Client httpClient;

    public isolated function init(ConnectionConfig config, string serviceUrl = "https://your-org.operations.dynamics.com/data") returns error? {
        http:ClientConfiguration httpConfig = {
            auth: config.auth,
            httpVersion: config.httpVersion,
            http1Settings: config.http1Settings,
            http2Settings: config.http2Settings,
            timeout: config.timeout,
            forwarded: config.forwarded,
            followRedirects: config.followRedirects,
            poolConfig: config.poolConfig,
            cache: config.cache,
            compression: config.compression,
            circuitBreaker: config.circuitBreaker,
            retryConfig: config.retryConfig,
            cookieConfig: config.cookieConfig,
            responseLimits: config.responseLimits,
            secureSocket: config.secureSocket,
            proxy: config.proxy,
            socketConfig: config.socketConfig,
            validation: config.validation,
            laxDataBinding: config.laxDataBinding
        };
        self.httpClient = check new (serviceUrl, httpConfig);
    }

    public isolated function getHttpClient() returns http:Client {
        return self.httpClient;
    }
}
