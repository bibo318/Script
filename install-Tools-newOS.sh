#!/bin/bash

# Kiểm tra xem node_exporter đã được cài đặt chưa
if systemctl is-active --quiet node_exporter; then
    echo "node_exporter đã được cài đặt trên hệ thống này."
else
    # Cài đặt epel-release và open-vm-tools
    yum install epel-release open-vm-tools -y

    # Cài đặt Development Tools
    yum groupinstall 'Development Tools' -y

    # Tải xuống và cài đặt node_exporter
    latest_version="1.7.0"
    wget "https://github.com/prometheus/node_exporter/releases/download/v${latest_version}/node_exporter-${latest_version}.linux-amd64.tar.gz"
    tar xvfz "node_exporter-${latest_version}.linux-amd64.tar.gz"
    mv "node_exporter-${latest_version}.linux-amd64/node_exporter" /usr/local/bin/
    chmod +x /usr/local/bin/node_exporter
    useradd -rs /bin/false node_exporter

    # Tạo file dịch vụ node_exporter trong systemd
    cat > /etc/systemd/system/node_exporter.service << 'EOL'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.processes --collector.systemd --collector.tcpstat --collector.network_route --collector.interrupts --collector.buddyinfo --no-collector.nvme

[Install]
WantedBy=multi-user.target
EOL

    # Reload systemd và khởi động dịch vụ node_exporter
    systemctl daemon-reload
    systemctl start node_exporter

    # Kiểm tra trạng thái dịch vụ và enable tự động khởi động
    systemctl status node_exporter
    systemctl enable node_exporter

    # Xóa thư mục và file tar.gz node_exporter sau khi cài đặt xong
    rm -rf "node_exporter-${latest_version}.linux-amd64"
    rm "node_exporter-${latest_version}.linux-amd64.tar.gz"
fi
