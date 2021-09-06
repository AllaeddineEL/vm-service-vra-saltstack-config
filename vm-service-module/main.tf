
resource "kubernetes_manifest" "vm" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "vmoperator.vmware.com/v1alpha1"
    "kind"       = "VirtualMachine"
    "metadata" = {
      "labels" = {
        "app" = var.vm_name
      }
      "name" = var.vm_name
    }
    "spec" = {
      "className" = var.vm_class_name
      "imageName" = var.vm_image_name
      "networkInterfaces" = [
        {
          "networkName" = ""
          "networkType" = var.vm_networking
        },
      ]
      "powerState"   = "poweredOn"
      "storageClass" = var.vm_storage_class
      "vmMetadata" = {
        "configMapName" = "${var.vm_name}-cloudinit-cm"
        "transport"     = "OvfEnv"
      }
      "volumes" = [
        {
          "name" = "myRootDisk"
          "vSphereVolume" = {
            "capacity" = {
              "ephemeral-storage" = "50Gi"
            }
            "deviceKey" = 2000
          }
        },
      ]
    }
  }
}

data "template_file" "init" {
  template = file("${path.module}/cloud-init.tpl")
  vars = {
    consul_address = "${aws_instance.consul.private_ip}"
  }
}

resource "kubernetes_manifest" "cm" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "hostname"  = var.vm_name
      "user-data" = <<-EOT
    I2Nsb3VkLWNvbmZpZwpjaHBhc3N3ZDoKICAgIGxpc3Q6IHwKICAgICAgY2VudG9zOlZNd2FyZTEhCiAgICBleHBpcmU6IGZhbHNlCmdyb3VwczoKICAtIGRvY2tlcgp1c2VyczoKICAtIGRlZmF1bHQKICAtIG5hbWU6IGNlbnRvcwogICAgc3NoLWF1dGhvcml6ZWQta2V5czoKICAgICAgLSBzc2gtcnNhIEFBQUFCM056YUMxeWMyRUFBQUFEQVFBQkFBQUNBUUMvT3plMXZpd2wyNVZiUnd2cDZrbTVraXRlV1d3L1orczNxQVhQbXlYZTdYZXp3cGhmNytuRFZtd3RRSkhMWHVNeTBucjkyWEV2b2g4YURPYVNDMWljd21qSktVeGcxaGs0Um5UdUErM1UvNFJVVEx1d2VWT3FlcDRxeWtpWjBzMEdqT21acVFzd1dCNjdDcHNhdWdmenFraVFkMmZOeDI1RFFiK2dhYzBHbDVsTXQ2S3lmajFrVGFPTS9NWHVCOVV5Wkg4UUhIMWJEaTNOWGk5eFVleGdxU3hxTHdSdFRpcHNscG5QZ1lqYzZrTkpxWWRZajUwWFJKSDBPaHdnbGhyQzF5aEpOUlhBWmtuWHpxM2gvWHpnVjI2YnpDNThnRFhBbzVzNC9LcGRyeHkwb3dCU2FFUUZySHlLaFpJbVQyTUE5U2d6U0RyR2RzelVhck1kYnl3emdYa3RhVEwxZXZPMjZ6cVJMZVBNN050V2luMWZDenppY05PUllhcHJtdmI3dHZTMXlxUjUybWFYZm5DYy9sZVFmaS9OYm9RcVZHd1RBNnhNN0RQaWpoWVBHTlRvdDFmOG5maXc5N1ZQSDFHTTV1SGxFbGRVdUdLUlQzVzFwUXY5YkhJNHB3OFE4LzIzV1RybEVxL05wYmpPYjZEQmdobm1IVkh0OUNVdnNaQlI5Vk1GcFJCZ1ZZZFVhdTVVZHdSRGVacWVzZUdNUlZHSUxENnZqUHdsc3UzajllR2NaSERSakw1WkUrWmpHdWFzNXBmTGhWMXEwcFZPZVAzWVdvb0VtbndaMFlHakRmR3YyUThqVG42aGlxbkE0MGRIVUVSM1o2TXlCUVE2eEdQcTZQRExLQXdUUUk4ZUJjUnlIOTZIcXpYVERxRkVSY3ZQdzZjNWV3aHNWUT09IOKAnGFlbGFyZWVkQHZtd2FyZS5jb23igJ0KICAgIHN1ZG86IEFMTD0oQUxMKSBOT1BBU1NXRDpBTEwKICAgIGdyb3Vwczogc3VkbywgZG9ja2VyCiAgICBzaGVsbDogL2Jpbi9iYXNoCm5ldHdvcms6CiAgdmVyc2lvbjogMgogIGV0aGVybmV0czoKICAgICAgZW5zMTkyOgogICAgICAgICAgZGhjcDQ6IHRydWUKcGFja2FnZXM6CiAgLSBuZ2lueAogIC0gbmV0LXRvb2xzCnl1bV9yZXBvczoKICAgIHNhbHQtcHkzLXJlcG86CiAgICAgIGJhc2V1cmw6IGh0dHBzOi8vcmVwby5zYWx0c3RhY2suY29tL3B5My9yZWRoYXQvOC8kYmFzZWFyY2gvbGF0ZXN0CiAgICAgIG5hbWU6IFNhbHRTdGFjayBMYXRlc3QgUmVsZWFzZSBDaGFubmVsIFB5dGhvbiAzIGZvciBSSEVML0NlbnRvcyAkcmVsZWFzZXZlcgogICAgICBlbmFibGVkOiB0cnVlCiAgICAgIGZhaWxvdmVybWV0aG9kOiBwcmlvcml0eQogICAgICBncGdjaGVjazogZmFsc2UKY2xvdWRfY29uZmlnX21vZHVsZXM6CiAtIHl1bS1hZGQtcmVwbwogLSBydW5jbWQKY2xvdWRfZmluYWxfbW9kdWxlczoKIC0gc2FsdC1taW5pb24gICAKc2FsdF9taW5pb246CiAgICBjb25mOgogICAgICAgIG1hc3RlcjogMTAuMjEzLjEyNi41MQogICAgZ3JhaW5zOgogICAgICAgIHJvbGU6CiAgICAgICAgICAgIC0gd2ViCnJ1bmNtZDoKICAtIGVjaG8gJzxoMT5sYi1jZW50b3MtMTwvaDE+JyA+IC91c3Ivc2hhcmUvbmdpbngvaHRtbC9pbmRleC5odG1sCiAgLSBjaG93biByb290OnJvb3QgL3Vzci9zaGFyZS9uZ2lueC9odG1sL2luZGV4Lmh0bWwKICAtIHN5c3RlbWN0bCBzdGFydCBuZ2lueAogIC0gZmlyZXdhbGwtb2ZmbGluZS1jbWQgLS1hZGQtc2VydmljZT1odHRwCiAgLSBmaXJld2FsbC1jbWQgLS1yZWxvYWQ=
    EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name" = "${var.vm_name}-cloudinit-cm"
    }
  }
}

resource "kubernetes_manifest" "cm" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "vmoperator.vmware.com/v1alpha1"
    "kind"       = "VirtualMachineService"
    "metadata" = {
      "name" = "${var.vm_name}-web-lb"
    }
    "spec" = {
      "ports" = [
        {
          "name"       = "http"
          "port"       = 80
          "protocol"   = "TCP"
          "targetPort" = 80
        },
      ]
      "selector" = {
        "app" = var.vm_name
      }
      "type" = "LoadBalancer"
    }
  }

}
