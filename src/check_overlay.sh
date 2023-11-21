#!/bin/bash

# Tạo một mảng để lưu trữ các thư mục trong /var/lib/docker/overlay2
overlay2_dirs=($(find /var/lib/docker/overlay2 -maxdepth 1 -mindepth 1 -type d))

# Tạo một mảng để lưu trữ các container IDs
container_ids=($(docker ps -q))

# Tạo một mảng để lưu trữ các thư mục không khớp
mismatched_dirs=()

# Lặp qua các thư mục trong overlay2
for overlay2_dir in "${overlay2_dirs[@]}"; do
  # Lấy 4 ký tự đầu tiên của tên thư mục
  id_folder=$(basename "$overlay2_dir" | cut -c1-4)

  # Đặt cờ kiểm tra cho việc tìm thấy khớp
  found_match=false

  # Lặp qua các container
  for container_id in "${container_ids[@]}"; do
    # Kiểm tra xem id_folder có tồn tại trong LowerDir của container không
    if docker inspect -f '{{.GraphDriver.Data.LowerDir}}' "$container_id" | grep -q "$id_folder"; then
      found_match=true
      break
    fi
  done

  # Nếu không tìm thấy khớp, thêm vào danh sách không khớp
  if [ "$found_match" = false ]; then
    mismatched_dirs+=("$overlay2_dir")
  fi
done

# Hỏi người dùng xem họ muốn kiểm tra hay xóa thư mục
read -p "Do you want to check dirs or delete dirs? Enter 'c' for Check or 'd' for Delete: " answer

if [ "$answer" = "c" ]; then
  # In ra các thư mục không khớp
  echo "Các thư mục không khớp với các container đang chạy:"
  for mismatched_dir in "${mismatched_dirs[@]}"; do
    echo "$mismatched_dir"
  done
elif [ "$answer" = "d" ]; then
  for mismatched_dir in "${mismatched_dirs[@]}"; do
    rm -rf "$mismatched_dir"
    echo "Deleted dir $mismatched_dir"
  done
else
  echo "Invalid option. Please enter 'c' for Check or 'd' for Delete."
fi
