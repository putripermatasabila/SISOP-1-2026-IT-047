# SISOP-1-2026-IT-047
Nama    : Putri Permata Sabila <br>
NRP     : 5027251047 <br>
Kelas   : A <br>

## Laporan Resmi

### Soal 1

Pada soal 1 kita diberikan data penumpang di kereta dan diminta untuk menampilkan <br>
a. Jumlah seluruh penumpang <br>
b. Jumlah gerbong penumpang <br>
c. Penumpang tertua <br>
d. Rata-rata usia penumpang <br>
e. Jumlah penumpang *bussiness class*

Langkah pertama sebelum kita menampilkan data. kita harus mendowload passenger.csv dari spreadsheet masuk ke repository menggunakan `wget -O`

```sh
wget -O passenger.csv "https://docs.google.com/spreadsheets/d/1NHmyS6wRO7To7ta-NLOOLHkPS6valvNaX7tawsv1zfE/export?format=csv"
```

#### A) Menghitung jumlah penumpang yang ada di kereta
```sh
BEGIN {FS=","}NR>1 {count++}
END {print "Jumlah seluruh penumpang KANJ adalah ", count, " orang"}
```
#### B) Menghitung jumlah gerbong yang ada dalam kereta dengan menghitung *length* dari array kolom ke-4 
```sh
BEGIN {FS=","} NR>1 {carriage[$4]++}
END {print"Jumlah gerbong penumpang KANJ adalah",length(carriage)}
```
#### C) Mencari penumpang tertua dalam kereta dengan melakukan perbandingan di kolom ke-2 yang menyimpan umur, lalu ketika sudah selesai menyimpan nama penumpang tertua di `max_name`
```sh
BEGIN{FS=","}NR>1{if($2>max) {max =$2;max_name=$1}}END {print max_name, "adalah penumpang kereta tertua dengan usia", max,"tahun"} 
```
#### D) Menghitung rata-rata usia penumpang dengan menjumlahkan total umur di kolom ke-2 lalu membagi jumlah orang yang ada
***terdapat revisi dari asprak -> untuk membulatkan hasil rata-rata usia penumpang**
```sh
BEGIN {FS=","} NR>1 { total+=$2; count_person++ }
END {printf "Rata-rata usia penumpang adalah %d tahun\n", int(total/count_person + 0.5)}
```
#### E) Menhitung jumlah penumpang yang ada di bussiness class. Jika pada kolom ke-3 ditemukan "Businees" maka `count_business++`
```sh
BEGIN {FS=","} NR>1 {if ($3=="Business"){count_business++}}
END {print "Jumlah penumpang business class ada", count_business}
```
karena *command* yang digunakan untuk memunculkan *output*

```sh
awk -f KANJ.sh passenger.csv a/b/c/d/e 
```
maka berikut ini full code penggabungannya 

```sh
BEGIN {FS=",";choice = ARGV[2];delete ARGV[2]
if (choice != "a" && choice != "b"&& choice != "c" && choice != "d" && choice != "e"){
print"Soal tidak dikenali. Gunakan a,b,c,d atau e."; 
print"Contoh penggunaan: awk -f file.sh data.csv a"}
}

NR > 1 {
if (choice =="a") count++
if (choice =="b") carriage[$4]++
if (choice =="c") {if($2>max) {max =$2;max_name=$1}}
if (choice =="d") { total+=$2; count_person++ }
if (choice =="e") if ($3 =="Business")count_business++
}

END {
if (choice =="a") 
{print "Jumlah seluruh penumpang KANJ adalah ", count, " orang"}
if (choice=="b")
{print"Jumlah gerbong penumpang KANJ adalah",length(carriage)}
if (choice=="c")
{print max_name, "adalah penumpang kereta tertua dengan usia",max,"tahun"}
if (choice =="d")
{printf "Rata-rata usia penumpang adalah %d tahun\n", int(total/count_person + 0.5)}
if (choice=="e")
{print "Jumlah penumpang business class ada", count_business, "orang"}
} 
```
`ARGV` merupakan array yang menyimpan semua argumen di command line
- `ARGV[0]` = awk
- `ARGV[1]` = passenger.csv
- `ARGV[2]` = a/b/c/e

#### Output
<img width="954" height="491" alt="Screenshot 2026-03-25 181037" src="https://github.com/user-attachments/assets/1a8e8f02-359f-4bf5-a9ab-ad50a690a385" />

---
### Soal 2

Pada soal 2 kita diberikan skenario ekspedisi pencarian pusaka di Gunung Kawi. Terdapat dua script utama yang dibuat:
- `parserkoordinat.sh` untuk mengekstrak data koordinat dari file JSON menjadi format CSV
- `nemupusaka.sh` untuk menghitung titik tengah lokasi pusaka berdasarkan dua titik diagonal

#### Persiapan Awal

Langkah pertama adalah mengunduh file peta PDF menggunakan `gdown`. Karena `gdown` belum terinstall, perlu install terlebih dahulu:

```sh
sudo apt install python3-pip
pip install gdown
```

Setelah `gdown` tersedia, unduh file peta dari Google Drive dan simpan dengan nama sesuai ketentuan:

```sh
gdown --id <file_id> -O peta-ekspedisi-amba.pdf
```

#### Mencari Link Tersembunyi dalam PDF

Setelah mendapatkan file PDF, langkah selanjutnya adalah mencari tautan tersembunyi di dalamnya. Ada dua cara yang bisa digunakan:

```sh
grep -a "http" peta-ekspedisi-amba.pdf
```
```sh
awk '/http/' peta-ekspedisi-amba.pdf
```

Dari sana ditemukan link repository:
```
https://github.com/pocongcyber77/peta-gunung-kawi.git
```

Kemudian repository tersebut di-clone menggunakan SSH:

```sh
git clone git@github.com:pocongcyber77/peta-gunung-kawi.git
```

#### A) Mengekstrak Koordinat dari JSON (`parserkoordinat.sh`)
***terdapat revisi dari asprak -> menukar urutan print latitude dulu baru longitude**

Di dalam repository yang di-clone terdapat file `gsxtrack.json` yang berisi data titik lokasi dalam format JSON. Data ini masih mentah sehingga perlu di-parsing terlebih dahulu ke format yang lebih rapi.

Script `parserkoordinat.sh` menggunakan `awk` untuk membaca file JSON baris per baris dan mengekstrak field yang dibutuhkan:

```sh
awk '
/"id":/ && /"node_/ { gsub(/.*"id": "|",/, "", $0); id=$0 }
/"site_name":/ { gsub(/.*"site_name": "|",/, "", $0); site=$0 }
/"latitude":/  { gsub(/.*"latitude": |,/, "", $0); lat=$0 }
/"longitude":/ { gsub(/.*"longitude": |,/, "", $0); lon=$0; print id","site","lat","lon }
' gsxtrack.json | tee titik-penting.txt
```

Cara kerja `gsub` di sini adalah sebagai *global substitution*, yaitu mengganti semua kemunculan pola tertentu dalam baris dengan string lain. <br>
Pola `.*"id": "` artinya buang semua karakter dari awal sampai tanda kutip setelah `"id": `, dan `",` artinya buang sisa karakter di belakangnya. <br>
Hasilnya hanya nilai yang kita inginkan yang tersisa, lalu disimpan ke variabel. Setelah keempat field terkumpul (saat baris `longitude` dibaca), langsung di-print dalam satu baris dengan format `id,site_name,latitude,longitude`. <br>

`tee` digunakan untuk menyimpan di file tujuan sekalian menampilkan outpun pada terminal

#### B) Menghitung Titik Tengah Pusaka (`nemupusaka.sh`)

Dari clue yang diberikan, lokasi pusaka berada tepat di titik tengah dari semua titik bekas ekspedisi. Titik-titik tersebut ternyata membentuk sebuah persegi, sehingga titik tengahnya bisa dicari dengan menghitung rata-rata koordinat dua titik yang berposisi diagonal, yaitu `node_001` dan `node_003`.

```sh
awk 'BEGIN {FS=","} /node_001|node_003/ {total_lat+=$3;total_long+=$4} 
END {print "Koordinat pusat:";
print total_lat/2","total_long/2}' titik-penting.txt | tee posisipusaka.txt
```

Script ini memfilter hanya baris yang mengandung `node_001` atau `node_003`, menjumlahkan latitude dan longitude keduanya, lalu membaginya dengan 2 untuk mendapat titik tengah. Hasilnya disimpan ke `posisipusaka.txt`.

#### Output
<img width="1390" height="483" alt="Screenshot 2026-03-29 212450" src="https://github.com/user-attachments/assets/0d1fd049-1099-49ad-b6da-bf318a143317" />

---

### Soal 3

Pada soal 3 kita diminta membuat program manajemen kost interaktif berbasis CLI menggunakan Bash script dan AWK. Program ini memiliki menu utama yang terus berjalan (*looping*) hingga user memilih Exit.

#### Inisialisasi Folder dan File

Sebelum program berjalan, script memastikan semua folder dan file yang dibutuhkan sudah ada:
***terdapat revisi dari asprak -> pada saat demo masih belum otomatis inisialisasi saat ./kost_slebew.sh dijalankan.**

```sh
mkdir -p data sampah log rekap

[ -f data/penghuni.csv ] || touch data/penghuni.csv
[ -f sampah/history_hapus.csv ] || touch sampah/history_hapus.csv
[ -f log/tagihan.log ] || touch log/tagihan.log
[ -f rekap/laporan_bulanan.txt ] || touch rekap/laporan_bulanan.txt
```

`-p` pada `mkdir` digunakan supaya jika folder sudah ada tidak akan error. `[ -f ... ]` adalah perintah `test` yang mengecek apakah file sudah ada, jika belum (`||`), baru dibuat dengan `touch`.

#### 1) Tambah Penghuni Baru

Fitur ini menambahkan data penghuni baru ke `data/penghuni.csv`. Setiap input divalidasi sebelum disimpan:

```sh
read -p "Masukkan Nama: " nama
kamar=$(validate_kamar)
harga_sewa=$(validate_harga_sewa)
tanggal=$(insert_date)
status=$(validate_status)

echo "$nama,$kamar,$harga_sewa,$tanggal,$status" >> data/penghuni.csv
```

Masing-masing fungsi validasi bekerja dalam loop `while true` dan hanya keluar jika input sudah sesuai:

```sh
validate_kamar(){
    local kamar
    while true; do
        read -p "Masukkan Nomor Kamar: " kamar
        if [[ ! "$kamar" =~ ^[0-9]+$ ]]; then
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
```
Input harus angka positif dicek dengan regex `^[0-9]+$` di dalam `[[ ]]`. Selain itu nomor kamar juga dicek apakah sudah terdaftar di CSV menggunakan `grep -q`, jika sudah ada maka ditolak.

```sh
validate_harga_sewa(){
    local harga_sewa
    while true; do
        read -p "Masukkan Harga sewa: " harga_sewa
        if [[ "$harga_sewa" =~ ^[0-9]+$ && "$harga_sewa" -gt 0 ]]; then
            echo "$harga_sewa"
            break
        else
            echo "Harga sewa harus angka positif" >&2
        fi
    done
}
```
Input harus angka dan nilainya lebih dari 0.

```sh
validate_date(){
    local date_str="$1"
    if [[ "$date_str" > "$(date +%Y-%m-%d)" ]]; then
        echo "Tanggal melewati batas" >&2
        return 1
    fi
    if [[ ! "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Error format" >&2
        return 1
    fi
    if ! date -d "$date_str" &>/dev/null; then
        echo "Error invalid date" >&2
        return 1
    fi
    return 0
}
```
Fungsi ini dipanggil lewat `insert_date` untuk memvalidasi tanggal masuk. Terdapat tiga pengecekan: format harus sesuai pola `YYYY-MM-DD` dengan regex, tanggal tidak boleh melebihi hari ini, dan `date -d` digunakan untuk memastikan tanggal benar-benar valid (misalnya menolak tanggal seperti 2024-02-30).

```sh
validate_status(){
    local status
    while true; do
        read -p "Masukkan Status Awal (Aktif/Menunggak): " status
        if [[ "$status" == "Aktif" || "$status" == "Menunggak" ]]; then
            echo "$status"
            break
        else
            echo "Status tidak sesuai ketentuan" >&2
        fi
    done
}
```
Hanya menerima string `Aktif` atau `Menunggak`, selain itu ditolak.

#### 2) Hapus Penghuni

Fitur ini menghapus data penghuni dari database utama dan mengarsipkannya ke `sampah/history_hapus.csv` dengan tambahan tanggal penghapusan:

```sh
awk -v n="$nama" -v tgl="$tanggal_hapus" 'BEGIN {FS=","} $1==n {print $0","tgl}' data/penghuni.csv >> sampah/history_hapus.csv
sed -i "/^$nama,/d" data/penghuni.csv
```

`awk` digunakan untuk menyalin baris yang cocok ke file arsip dengan tambahan kolom tanggal hapus. Setelah itu `sed -i` menghapus baris tersebut langsung dari file CSV.

#### 3) Tampilkan Daftar Penghuni

Fitur ini menampilkan seluruh data penghuni dalam format tabel yang rapi menggunakan `awk`:

```sh
awk 'BEGIN {FS=","; aktif=0; menunggak=0}
$5=="Aktif" {aktif++}
$5=="Menunggak" {menunggak++}
{printf " %-3d| %-14s| %-6s| %-15s| %s\n", NR, $1, $2, $3, $5}
END {
print "Total: " NR " penghuni | Aktif: " aktif " | Menunggak: " menunggak
}' data/penghuni.csv
```

`printf` dengan format `%-Nd` digunakan untuk rata kiri dengan lebar kolom tetap sehingga tampilan tabel konsisten. Di blok `END` ditampilkan ringkasan jumlah penghuni aktif dan menunggak.

#### 4) Update Status Penghuni

Fitur ini mengubah status penghuni (antara `Aktif` dan `Menunggak`) menggunakan `awk` dengan teknik file sementara:

```sh
awk -v n="$nama" -v s="$status_baru" 'BEGIN{FS=OFS=","} $1==n {$5=s} 1' data/penghuni.csv > data/tmp.csv && mv data/tmp.csv data/penghuni.csv
```

`OFS=","` memastikan field separator output tetap koma saat `awk` merekonstruksi baris. Pola `1` di akhir artinya print semua baris (true condition). Hasil ditulis ke file sementara `tmp.csv` lalu di-rename menggantikan file asli.

#### 5) Cetak Laporan Keuangan

Fitur ini menghitung total pemasukan, tunggakan, dan menampilkan daftar penghuni yang menunggak menggunakan `awk`:

```sh
awk 'BEGIN {FS=","; total_pemasukan=0; total_tunggakan=0}
{if ($5=="Aktif") {total_pemasukan+=$3}
 if ($5=="Menunggak") {total_tunggakan+=$3; nama_menunggak[$1]++}}
END {
printf "Total pemasukan (Aktif)  : Rp %d\n", total_pemasukan
printf "Total tunggakan          : Rp%d\n", total_tunggakan
for (n in nama_menunggak) printf "  - %s\n", n
}' data/penghuni.csv | tee -a rekap/laporan_bulanan.txt
```

Array `nama_menunggak` digunakan untuk mengumpulkan nama penghuni yang menunggak tanpa duplikasi. Output ditampilkan ke terminal sekaligus di-append ke `rekap/laporan_bulanan.txt` menggunakan `tee -a`.

#### 6) Kelola Cron (Pengingat Tagihan)

Fitur ini mengelola cron job untuk pengingat tagihan otomatis. Terdapat tiga sub-fitur, yaitu lihat, daftarkan, dan hapus cron job.

Saat script dipanggil dengan argumen `--check-tagihan` (oleh cron), script akan mencari penghuni yang menunggak dan mencatatnya ke log:

```sh
if [[ "$1" == "--check-tagihan" ]]; then
    date_automate_save=$(date "+%Y-%m-%d %H:%M:%S")
    awk -v das="$date_automate_save" 'BEGIN {FS=","} $5=="Menunggak" {
    print "["das"] TAGIHAN: "$1 "(Kamar " $2") -Menunggak Rp"$3
    }' data/penghuni.csv >> log/tagihan.log
    exit 0
fi
```

Untuk mendaftarkan cron job baru, mekanismenya adalah dengan mengambil daftar crontab yang ada, membuang entri lama (jika ada), lalu menambahkan entri baru:

```sh
crontab -l 2>/dev/null | grep -v "kost_slebew.sh --check-tagihan" > mycron
echo "$minutes $hour * * * $(realpath $0) --check-tagihan" >> mycron
crontab mycron
rm mycron
```

`crontab -l` untuk list cron aktif, `2>/dev/null` membuang error jika belum ada cron sama sekali. `grep -v` mengambil semua baris kecuali entri lama. `realpath $0` digunakan agar path script selalu absolute sehingga cron bisa menemukannya dari mana saja.

#### Output

