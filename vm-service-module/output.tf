data "kubernetes_service" "web_lb" {
  depends_on = [
    time_sleep.wait_10_seconds
  ]
  metadata {
    name      = "${var.vm_name}-web-lb"
    namespace = var.vsphere_namespace
  }
}
resource "time_sleep" "wait_10_seconds" {
  depends_on      = [kubectl_manifest.svc]
  create_duration = "10s"
}
output "web_lb_ip" {
  value = data.kubernetes_service.web_lb.status.0.load_balancer.0.ingress.0.ip
}
