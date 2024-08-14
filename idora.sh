#!/bin/bash

# Fungsi untuk menampilkan bantuan
show_help() {
    echo "Penggunaan: ./idora.sh -l <aktif_url_list> [-h]"
    echo ""
    echo "Opsi:"
    echo "  -l <aktif_url_list>  Mengambil daftar URL aktif dari file yang ditentukan."
    echo "  -h                   Menampilkan pesan bantuan ini."
    exit 0
}

# Memeriksa apakah argumen telah diberikan
if [[ $# -eq 0 ]]; then
    show_help
fi

# Mengambil opsi dari argumen
while getopts "l:h" opt; do
    case $opt in
        l)
            aktif_url_list=$OPTARG
            ;;
        h)
            show_help
            ;;
        *)
            show_help
            ;;
    esac
done

# Pastikan file aktif URL list telah diberikan
if [[ -z "$aktif_url_list" ]]; then
    echo "Error: File daftar URL aktif harus ditentukan dengan opsi -l."
    show_help
fi

# Pastikan direktori untuk menyimpan file telah dibuat
mkdir -p js secret

# Inisialisasi counter
counter=1

# Loop untuk memproses URL aktif
while read -r url; do
  js_file="js/js${counter}.txt"
  secret_file="secret/secret${counter}.txt"
  
  # Menjalankan katana untuk setiap URL aktif
  katana -u "$url" -jc -d 2 | grep ".js$" | uniq | sort > "$js_file"
  
  # Proses SecretFinder untuk setiap file .js yang ditemukan
  cat "$js_file" | while read -r js_url; do
    secretfinder -i "$js_url" -o cli >> "$secret_file"
  done

  # Increment counter
  counter=$((counter + 1))

done < "$aktif_url_list"

echo "Proses selesai. Semua file .js disimpan di folder 'js' dan hasil SecretFinder disimpan di folder 'secret'."
