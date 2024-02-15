#!/bin/bash

# Tạo một mảng để lưu trữ các thư mục trong /var/lib/docker/overlay2
overlay2_dirs=($(find /var/lib/docker/overlay2 -maxdepth 1 -mindepth 1 -type d))

# Tạo một mảng để lưu trữ các container IDs
container_ids=($(docker ps -q))

# Tạo một mảng để lưu trữ các thư mục không khớp
mismatched_dirs=()

# Mảng để lưu trữ thông tin tên container
container_names=()

# Lặp qua các thư mục trong overlay2
for overlay2_dir in "${overlay2_dirs[@]}"; do
  id_folder=$(basename "$overlay2_dir" | cut -c1-4)
  found_match=false
  container_name=""

  for container_id in "${container_ids[@]}"; do
    if docker inspect -f '{{.GraphDriver.Data.LowerDir}}' "$container_id" | grep -q "$id_folder"; then
      found_match=true
      # Lưu tên container
      container_name=$(docker inspect -f '{{.Name}}' "$container_id" | sed 's/^\/\|\s//g')
      break
    fi
  done

  if [ "$found_match" = false ]; then
    mismatched_dirs+=("$overlay2_dir")
    container_names+=("N/A")
  else
    container_names+=("$container_name")
  fi
done

read -p "Do you want to check dirs or delete dirs? Enter 'c' for Check or 'd' for Delete: " answer

if [ "$answer" = "c" ]; then
  echo "Các thư mục không khớp với các container đang chạy, dung lượng của chúng, và tên container:"
  for i in "${!mismatched_dirs[@]}"; do
    echo -n "${mismatched_dirs[i]} (Dung lượng: "
    du -sh "${mismatched_dirs[i]}" | cut -f1
    echo -n ") - Container: ${container_names[i]}"
    echo
  done
elif [ "$answer" = "d" ]; then
  for mismatched_dir in "${mismatched_dirs[@]}"; do
    rm -rf "$mismatched_dir"
    echo "Deleted dir $mismatched_dir"
  done
else
  echo "Invalid option. Please enter 'c' for Check or 'd' for Delete."
fi
