#!/usr/bin/env bash

set -e

echo "Installing Kustomize"

curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
