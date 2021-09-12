
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.11.3"
    }
  }
}

resource "kubectl_manifest" "vm" {
  wait      = true
  yaml_body = <<YAML
apiVersion: vmoperator.vmware.com/v1alpha1
kind: VirtualMachine
metadata:
  name: ${var.vm_name}
  namespace: ${var.vsphere_namespace}
  labels:
    app: ${var.vm_name}
spec:
  networkInterfaces:
    - networkName: ${var.vm_network_name}
      networkType: ${var.vm_networking}
  className: ${var.vm_class_name}
  imageName: ${var.vm_image_name}
  powerState: poweredOn
  storageClass: ${var.vm_storage_class}
  volumes:
    - name: myRootDisk
      vSphereVolume:
        deviceKey: 2000
        capacity:
          ephemeral-storage: "50Gi"
  vmMetadata:
    configMapName: ${var.vm_name}-cloudinit-cm
    transport: OvfEnv
YAML
  lifecycle {
    ignore_changes = [
      live_resource_version
    ]
  }
}
data "template_file" "cloud_init" {
  template = var.vm_image_name == "centos-stream-8-vmservice-v1alpha1-1619529007339" ? file("${path.module}/cloud-init/centos-cloud-init.tpl") : file("${path.module}/cloud-init/ubuntu-cloud-init.tpl")
  vars = {
    ssconfig_address = var.ssconfig_ip
  }
}

resource "kubernetes_config_map" "cm" {
  metadata {
    name      = "${var.vm_name}-cloudinit-cm"
    namespace = var.vsphere_namespace
  }

  data = {
    hostname  = var.vm_name
    user-data = base64encode(data.template_file.cloud_init.rendered)
    public-keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/Oze1viwl25VbRwvp6km5kiteWWw/Z+s3qAXPmyXe7Xezwphf7+nDVmwtQJHLXuMy0nr92XEvoh8aDOaSC1icwmjJKUxg1hk4RnTuA+3U/4RUTLuweVOqep4qykiZ0s0GjOmZqQswWB67CpsaugfzqkiQd2fNx25DQb+gac0Gl5lMt6Kyfj1kTaOM/MXuB9UyZH8QHH1bDi3NXi9xUexgqSxqLwRtTipslpnPgYjc6kNJqYdYj50XRJH0OhwglhrC1yhJNRXAZknXzq3h/XzgV26bzC58gDXAo5s4/Kpdrxy0owBSaEQFrHyKhZImT2MA9SgzSDrGdszUarMdbywzgXktaTL1evO26zqRLePM7NtWin1fCzzicNORYaprmvb7tvS1yqR52maXfnCc/leQfi/NboQqVGwTA6xM7DPijhYPGNTot1f8nfiw97VPH1GM5uHlEldUuGKRT3W1pQv9bHI4pw8Q8/23WTrlEq/NpbjOb6DBghnmHVHt9CUvsZBR9VMFpRBgVYdUau5UdwRDeZqeseGMRVGILD6vjPwlsu3j9eGcZHDRjL5ZE+ZjGuas5pfLhV1q0pVOeP3YWooEmnwZ0YGjDfGv2Q8jTn6hiqnA40dHUER3Z6MyBQQ6xGPq6PDLKAwTQI8eBcRyH96HqzXTDqFERcvPw6c5ewhsVQ== “aelareed@vmware.com”"
  }

}

resource "kubectl_manifest" "svc" {
  wait      = true
  yaml_body = <<YAML
apiVersion: vmoperator.vmware.com/v1alpha1
kind: VirtualMachineService
metadata:
  name: ${var.vm_name}-web-lb
  namespace: ${var.vsphere_namespace}
spec:
  selector:
    app: ${var.vm_name}
  type: LoadBalancer
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 80
YAML

}
resource "kubectl_manifest" "ssh_svc" {
  wait      = true
  yaml_body = <<YAML
apiVersion: vmoperator.vmware.com/v1alpha1
kind: VirtualMachineService
metadata:
  name: ${var.vm_name}-ssh-lb
  namespace: ${var.vsphere_namespace}
spec:
  selector:
    app: ${var.vm_name}
  type: LoadBalancer
  ports:
    - name: ssh
      port: 22
      protocol: TCP
      targetPort: 22
YAML

}
