#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2154

# Copyright Istio Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -u
set -o pipefail

source "${REPO_ROOT}/content/en/docs/tasks/traffic-management/ingress/ingress_sni_passthrough/snips.sh"
source "${REPO_ROOT}/tests/util/samples.sh"

kubectl label namespace default istio-injection=enabled --overwrite

# Generate client and server certificates and keys
snip_generate_client_and_server_certificates_and_keys_1
snip_generate_client_and_server_certificates_and_keys_2

# Deploy an NGINX server
snip_deploy_an_nginx_server_1

snip_deploy_an_nginx_server_2

snip_deploy_an_nginx_server_3

snip_deploy_an_nginx_server_4

# waiting for nginx deployment to start
sample_wait_for_deployment default nginx

# validate NGINX server was deployed successfully 
snip_deploy_an_nginx_server_5

out=$(snip_deploy_an_nginx_server_5_out 2>&1)

_verify_contains "$out" "common name: nginx.example.com (matched)"
_verify_contains "$out" "server certificate expiration date OK"
_verify_contains "$out" "issuer: O=example Inc.; CN=example.com"

# configure an ingress gateway
snip_configure_an_ingress_gateway_1
snip_configure_an_ingress_gateway_2
snip_configure_an_ingress_gateway_3

# validate the output
out=$(snip_configure_an_ingress_gateway_3_out 2>&1)

_verify_contains "$out" "subject: CN=nginx.example.com; O=some organization"
_verify_contains "$out" "issuer: O=example Inc.; CN=example.com"
_verify_contains "$out" "SSL certificate verify ok."
