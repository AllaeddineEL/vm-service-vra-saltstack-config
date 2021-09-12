install_nginx:
  pkg.installed:
    - name: nginx
start_nginx:
  service.running:
    - name: nginx

{% if grains['os'] == 'CentOS Stream' %}
public:
  firewalld.present:
    - name: public
    - services:
      - http
{% endif %}      