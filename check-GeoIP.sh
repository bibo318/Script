#!/bin/bash

# Đường dẫn đến file chứa danh sách IP
IP_FILE="ip-scan-sorted.txt"
# Tên file CSV để lưu kết quả
OUTPUT_CSV="ipGeo-scan.csv"

# Kiểm tra nếu file không tồn tại hoặc không đọc được
if [ ! -f "$IP_FILE" ]; then
    echo "File $IP_FILE không tồn tại hoặc không đọc được."
    exit 1
fi

# Xóa file CSV nếu tồn tại để tạo file mới
if [ -f "$OUTPUT_CSV" ]; then
    rm "$OUTPUT_CSV"
fi

# Ghi header cho file CSV
echo "Lượt truy cập,IP kiểm tra,Quốc gia" > "$OUTPUT_CSV"

# Đọc từng địa chỉ IP từ file và sử dụng geoiplookup để tra cứu vị trí
while IFS= read -r line; do
    access_count=$(echo "$line" | awk '{print $1}')
    ip=$(echo "$line" | awk '{print $2}')
    country=$(geoiplookup "$ip" | grep "GeoIP Country Edition" | awk -F ': ' '{print $2}' | awk '{print $2}')
    code=$(geoiplookup "$ip" | grep "GeoIP Country Edition" | awk -F ': ' '{print $2}' | awk '{print $1}')
    location="$country $code"
    echo "$access_count $ip $location" >> "$OUTPUT_CSV"
    echo "Đã ghi thông tin cho IP: $ip"
done < "$IP_FILE"

echo "Hoàn thành. Kết quả được lưu trong file $OUTPUT_CSV."
