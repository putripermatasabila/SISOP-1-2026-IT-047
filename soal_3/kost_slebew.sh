#!/bin/bash


if [[ "$1" == "--check-tagihan" ]]; then
	#penggunaan " ada karena terdapat spasi beda saat di function hapus_penghuni 
	cd /home/putri_permata_sabila/sisop/SISOP-1-2026-IT-047/soal_3
	 date_automate_save=$(date "+%Y-%m-%d %H:%M:%S")

	awk -v das="$date_automate_save" 'BEGIN {FS=","} $5=="Menunggak" {
	print "["das"] TAGIHAN: "$1 "(Kamar " $2") -Menunggak Rp"$3
	}' data/penghuni.csv >> log/tagihan.log 
	exit 0 
fi 

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


buat_cron(){
local hour minutes
while true; do
read -p "Masukkan Jam (0-23): " hour
if [[ "$hour" =~ ^[0-9]+$ &&  "$hour" -le 23 ]]; then break
else echo "Input tidak valid, masukkan jam (0-23)"
fi
done

while true;do
read -p "Masukkan Menit (0-59): " minutes
if [[ "$minutes" =~ ^[0-9]+$ &&  "$minutes" -le 59 ]]; then break
else echo "Input tidak valid, masukkan jam (0-59)"
fi
done

#&>/dev/null buang stdout stderr
#2>/dev/null buang stderr aja
# -v berarti memilih semuanya kecuali --check-tagihan"
crontab -l 2>/dev/null | grep -v "kost_slebew.sh --check-tagihan" > mycron 

echo "$minutes $hour * * * $(realpath $0) --check-tagihan">> mycron
crontab mycron
rm mycron

}

lihat_cron(){

echo ""
echo "--- Daftar Cron Job Pengingat Tagihan ---"
crontab -l 2>/dev/null | grep "kost_slebew.sh --check-tagihan" || echo "Tidak ada pengingat yang aktif"

echo ""
read -p "Tekan [ENTER] untuk kembali ke menu kelola cron..." dummy
echo ""
}

hapus_cron(){
crontab -l  2>/dev/null | grep -v "kost_slebew.sh --check-tagihan" > mycron
crontab mycron
rm mycron
echo ""
echo "[✓] Cron job pengingat tagihan berhasil dihapus."
echo ""
read -p "Tekan [ENTER] untuk kembali ke menu kelola cron..." dummy
echo ""
}

menu_cron(){
while true; do
echo ""
echo "========================================================="
echo "                    MENU KELOLA CRON                     "
echo "========================================================="
echo "1. Lihat Cron Job Aktif"
echo "2. Daftarkan Cron Job Pengingat"
echo "3. Hapus Cron Job Pengingat"
echo "4. Kembali"
echo "========================================================="
read -p "Pilih [1-4]: " pilihan

if [ "$pilihan" == "2" ];then buat_cron
elif [ "$pilihan" == "1" ]; then lihat_cron
elif [ "$pilihan" == "3" ]; then hapus_cron
elif [ "$pilihan" == "4" ]; then break 
break 
else printf "Input tidak valid (Masukkan 1-4)"
fi

done
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

		if [[ ! "$kamar" =~ ^[0-9]+$ ]];then 
			echo "Nomor kamar harus positif" >&2
			continue
		fi
		kamar=$((10#$kamar))
		if grep -q ",$kamar," data/penghuni.csv; then
			echo "Kamar tidak tersedia" >&2
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

tampilkan_daftar(){
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "              DAFTAR PENGHUNI KOST SLEBEW                "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " No | Nama          | Kamar | Harga Sewa     | Status    "
echo "---------------------------------------------------------" 
awk 'BEGIN {FS=","; aktif=0; menunggak=0}
$5=="Aktif" {aktif++}
$5=="Menunggak" {menunggak++}
{printf " %-3d| %-14s| %-6s| %-15s| %s\n", NR, $1, $2, $3, $5}
END {
print "---------------------------------------------------------"
print "Total: " NR " penghuni | Aktif: " aktif " | Menunggak: " menunggak
print "---------------------------------------------------------"}' data/penghuni.csv
echo ""
}

hapus_penghuni(){
        local nama tanggal_hapus
echo ""
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "                   HAPUS PENGHUNI                        "
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        while true; do
                read -p "Masukkan nama penghuni yang akan dihapus:" nama
                if grep -q "^$nama," data/penghuni.csv; then
                        break;
                else
                        echo "Nama tidak ditemukan, coba lagi" >&2
                        tampilkan_daftar
                fi
        done
        tanggal_hapus=$(date +%Y-%m-%d)
        awk -v n="$nama" -v tgl="$tanggal_hapus" 'BEGIN {FS=","} $1==n {print $0","tgl}' data/penghuni.csv >> sampah/history_hapus.csv
        sed -i "/^$nama,/d" data/penghuni.csv

echo ""
echo "[✓] Data penghuni $nama berhasil diarsipkan ke sampah/history_hapus.csv dan dihapus sistem"
echo ""

read -p "Tekan [ENTER] untuk kembali ke menu..." dummy
echo ""
}


update_status(){
local nama status_baru
echo ""
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "                     UPDATE STATUS                       "
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        while true; do
                read -p "Masukkan nama penghuni:" nama
                if grep -q "^$nama," data/penghuni.csv; then
                        break;
                else
                        echo "Nama tidak ditemukan, coba lagi" >&2
			tampilkan_daftar
                fi
        done
        while true; do
                read -p "Masukkan Status Baru (Aktif/Menunggak):  " status_baru
                if  [[ "$status_baru" == "Aktif" ||  "$status_baru" == "Menunggak" ]];then
			break
                else
                        echo "Status tidak sesuai ketentuan" >&2
                fi
        done

	awk -v n="$nama" -v s="$status_baru" 'BEGIN{FS=OFS=","} $1==n {$5=s} 1' data/penghuni.csv > data/tmp.csv && mv data/tmp.csv data/penghuni.csv
	
echo ""
echo "[✓] Status $nama berhasil diubah menjadi $status_baru"
echo ""

read -p "Tekan [ENTER] untuk kembali ke menu..." dummy
echo ""

}

cetak_laporan(){
echo ""
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "              LAPORAN EKUNGAN KOST SLEBEW                "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
awk 'BEGIN {FS=","; total_pemasukan=0; total_tunggakan=0; count_kamar=0}
{count_kamar++;if ($5=="Aktif") {total_pemasukan+=$3};if ($5=="Menunggak") {total_tunggakan+=$3; nama_menunggak[$1]++}}
END {
printf "Total pemasukan (Aktif)  : Rp %d\n", total_pemasukan
printf "Total tunggakan          : Rp%d\n", total_tunggakan
printf "Jumlah kamar terisi      : %d\n", count_kamar
printf "----------------------------------------------------- \n"
printf "Daftar penghuni menunggak:  \n"
if (length(nama_menunggak)==0) printf "  Tidak ada tunggakan." 
else for (n in  nama_menunggak) printf "  - %s\n", n
}' data/penghuni.csv | tee -a rekap/laporan_bulanan.txt



echo ""
echo "[✓] Laporan berhasil disimpan ke rekap/laporan_bulanan.txt"
echo ""

read -p "Tekan [ENTER] untuk kembali ke menu..." dummy
echo ""
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
	elif [ "$option" == "4" ];then
		update_status
	elif [ "$option" == "5" ];then
		cetak_laporan
	elif [ "$option" == "6" ];then
                menu_cron
	else
		echo "Input tidak valid, masukkan angka 1-7"
	fi
done
