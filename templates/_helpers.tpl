{{/*
# Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
#
# WSO2 LLC. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "..name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "..fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "..chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "..labels" -}}
helm.sh/chart: {{ include "..chart" . }}
{{ include "..selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "..selectorLabels" -}}
app.kubernetes.io/name: {{ include "..name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Validate Cloud Provider Specific Configurations..
*/}}
{{- define "..validateCloudProviderConfig" -}}
  {{- $values := .Values.deployment -}}

  {{/* Validate Ingress Configuration */}}
  {{- $ingressAwsEnabled := and (hasKey $values.ingress "aws") $values.ingress.aws.enabled }}
  {{- $ingressAzureEnabled := and (hasKey $values.ingress "azure") $values.ingress.azure.enabled }}
  {{- if and $ingressAwsEnabled $ingressAzureEnabled }}
    {{- fail (printf "Validation Error in 'deployment.ingress': Both 'aws.enabled' (value: %v) and 'azure.enabled' (value: %v) are true. Only one cloud provider should be enabled for Ingress at a time." $values.ingress.aws.enabled $values.ingress.azure.enabled) }}
  {{- end }}

  {{/* Validate Persistence Configuration */}}
  {{- $persistenceAwsEnabled := and (hasKey $values.persistence "aws") $values.persistence.aws.enabled }}
  {{- $persistenceAzureEnabled := and (hasKey $values.persistence "azure") $values.persistence.azure.enabled }}
  {{- if and $persistenceAwsEnabled $persistenceAzureEnabled }}
    {{- fail (printf "Validation Error in 'deployment.persistence': Both 'aws.enabled' (value: %v) and 'azure.enabled' (value: %v) are true. Only one cloud provider should be enabled for Persistence at a time." $values.persistence.aws.enabled $values.persistence.azure.enabled) }}
  {{- end }}

  {{/* Validate SecretStore Configuration */}}
  {{- $secretStoreAwsEnabled := and (hasKey $values.secretStore "aws") $values.secretStore.aws.enabled }}
  {{- $secretStoreAzureEnabled := and (hasKey $values.secretStore "azure") $values.secretStore.azure.enabled }}
  {{- if and $secretStoreAwsEnabled $secretStoreAzureEnabled }}
    {{- fail (printf "Validation Error in 'deployment.secretStore': Both 'aws.enabled' (value: %v) and 'azure.enabled' (value: %v) are true. Only one cloud provider should be enabled for SecretStore at a time." $values.secretStore.aws.enabled $values.secretStore.azure.enabled) }}
  {{- end }}

  {{/* Validate External Credentials Configuration */}}
  {{- if and $values.externalCredentials.enabled $values.secretStore.enabled }}
    {{- fail (printf "Validation Error in 'deployment.externalCredentials': Both 'externalCredentials.enabled' (value: %v) and 'secretStore.enabled' (value: %v) are true. Only one source should be enabled for the server credentials at a time." $values.externalCredentials.enabled $values.secretStore.enabled) }}
  {{- end }}
{{- end -}}
