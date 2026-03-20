#!/bin/bash

menu_display(){
echo ""
echo "========================================================="
echo "             SISTEM MANAJEMEN KOST SLEBEW                "
echo "========================================================="
echo "ID | OPTION"
echo "---------------------------------------------------------"
echo " 1 | Tambah Penghuni Baru"
echo " 2 | Hapus Penghuni"
echo " 3 | Tampilkan Daftar Penghuni"
echo " 4 | Update Status Penghuni"
echo " 5 | Cetak Laporan Keuangan"
echo " 6 | Kelola Cron (Pengingat Tagihan)"
echo " 7 | Exit Program"
echo "========================================================="
echo ""
}

insert_date(){
	while true; do
        	read -p "Masukkan Tanggal Masuk (YYYY-MM-DD): " date_in
        	if  validate_date "$date_in" ; then
        	echo "$date_in"
		break
        	fi
	done
}

validate_kamar(){
	local kamar
	while true; do
		read -p "Masukkan Nomor Kamar: " kamar
		kamar=$((10#$kamar))
		if grep -q ",$kamar," data/penghuni.csv; then
			echo "Kamar sudah ditempati" >&2
		else
			echo "$kamar"
			break
		fi
	done
} 
validate_harga_sewa(){
	local harga_sewa
        while true; do
                read -p "Masukkan Harga sewa: " harga_sewa
                if  [[ "$harga_sewa" =~ ^[0-9]+$ &&  "$harga_sewa" -gt 0 ]] ; then
                	echo "$harga_sewa"
			break
		else
			echo "Harga sewa harus angka positif" >&2
                fi
        done
}

validate_status(){
	local status
        while true; do
                read -p "Masukkan Status Awal (Aktif/Menunggak):  " status
                if  [[ "$status" == "Aktif" ||  "$status" == "Menunggak" ]]; then
                        echo "$status"
                        break
                else
                        echo "Status tidak sesuai ketentuan" >&2
                fi
        done
}

validate_date(){
	local date_str="$1"
	if [[ "$date_str" > "$(date +%Y-%m-%d)" ]]; then
	echo "Tanggal melewati batas" >&2
	return 1
	fi

	if  [[ ! "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then 
	echo "Error format" >&2 
	return 1
	fi

	if ! date -d "$date_str" &>/dev/null; then
	echo "Error invalid date" >&2
	return 1
	fi

	return 0
}

create_penghuni(){
local nama kamar harga_sewa tanggal status
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "                   TAMBAH PENGHUNI                       "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
read -p "Masukkan Nama: " nama
kamar=$(validate_kamar)
harga_sewa=$(validate_harga_sewa)
tanggal=$(insert_date)
status=$(validate_status)
echo ""

echo "[✓] Penghuni $nama berhasil ditambahkan ke Kamar $kamar dengan status $status."
echo ""

echo "$nama,$kamar,$harga_sewa,$tanggal,$status" >> data/penghuni.csv

read -p "Tekan [ENTER] untuk kembali ke menu..." dummy

}

hapus_penghuni(){
	local nama tanggal_hapus
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "                   HAPUS PENGHUNI                        "
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	while true; do
		read -p "Masukkan nama penghuni yang akan dihapus:" nama
		if grep -q "^$nama," data/penghuni.csv; then
			break;
		else
			echo "Nama tidak ditemukan, coba lagi" >&2
		fi
	done
	tanggal_hapus=$(date +%Y-%m-%d)
	awk -v n="$nama" -v tgl="$tanggal_hapus" 'BEGIN {FS=","} $1==n {print $0","tgl}' data/penghuni.csv >> sampah/history_hapus.csv
	sed -i "/^$nama,/d" data/penghuni.csv

echo ""
echo "[✓] Data penghuni $nama berhasil diarsipkan ke sampah/history_hapus.csv dan dihapus sistem "
echo "" 

read -p "Tekan [ENTER] untuk kembali ke menu..." dummy
echo ""
}

tampilkan_daftar(){
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "              DAFTAR PENGHUNI KOST SLEBEW                "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " No | Nama          | Kamar | Harga Sewa     | Status    "
echo "---------------------------------------------------------" 
awk 'BEGIN {FS=","}
$5=="Aktif" {aktif++}
$5=="Menunggak" {menunggak++}
{printf " %-3d| %-14s| %-6s| %-15s| %s\n", NR, $1, $2, $3, $5}
END {print "Total: " NR " | Aktif: " aktif " | Menunggak: " menunggak}' data/penghuni.csv
}

while true; do

	menu_display
	read -p "Enter option [1-7]: " option
	if [ "$option" == "7" ]; then
		break
	elif [ "$option" == "1" ]; then 
   		create_penghuni
	elif [ "$option" == "2" ]; then
                hapus_penghuni
	elif [ "$option" == "3" ]; then
                 tampilkan_daftar
	else
		echo "Input tidak valid, masukkan angka 1-7"
	fi
done
